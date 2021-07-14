using System;
using System.Data.Services;
using System.Data.Services.Common;
using System.Collections.Generic;
using System.Collections.Specialized;
using System.Linq;
using System.Web;
using System.Net;
using System.ServiceModel;
using System.ServiceModel.Web;
using System.ServiceModel.Activation;
using parastr_thirrpModel;
using System.Text.RegularExpressions;
using System.IO;
using System.Configuration;

namespace DataServicesJSONP
{
    [JSONPSupportBehavior]
    [ServiceBehavior(InstanceContextMode = InstanceContextMode.PerCall)]
    [AspNetCompatibilityRequirements(RequirementsMode = AspNetCompatibilityRequirementsMode.Allowed)]

    public class Service : DataService<Entities>
    {
        private UserInfo ui_;
        private String func = System.Reflection.MethodBase.GetCurrentMethod().ToString();

        // This method is called only once to initialize service-wide policies.
        public static void InitializeService(DataServiceConfiguration config)
        {
            Logger.EnterMethod(System.Reflection.MethodBase.GetCurrentMethod().ToString());

            config.SetEntitySetAccessRule("*", EntitySetRights.All);
            config.SetServiceOperationAccessRule("*", ServiceOperationRights.All);
            config.DataServiceBehavior.MaxProtocolVersion = DataServiceProtocolVersion.V2;
        }

        private Boolean ValidUser(UserInfo ui)
        {
            Logger.EnterMethod(System.Reflection.MethodBase.GetCurrentMethod().ToString());
            Boolean blnReturn = true;

            if (null == ui)
            {
                blnReturn = false;
            }
            else
            {
                NameValueCollection nvcHeaders = HttpContext.Current.Request.Headers;
                String[] s = nvcHeaders.GetValues("Cookie");

                if (null == s)
                {
                    blnReturn = false;
                }
                else
                {
                    String sCookie = s[0];

                    if (false == sCookie.StartsWith("ASP.NET_SessionId="))
                    {
                        blnReturn = false;
                    }
                }
            }

            return (blnReturn);
        }

        private Boolean PushAnswer(Int32? intUserId, Int32 intQuestionId, Int32 intBadgeCount)
        {
            Logger.EnterMethod(System.Reflection.MethodBase.GetCurrentMethod().ToString());
            Boolean blnReturn = true;
            Entities e = new Entities();

            Logger.Info("Ready for sproc GetPushToken: " +
                "intUserId = " + intUserId);

            String strToken;
            List<String> lstToken = e.GetPushToken(intUserId).ToList();

            if (lstToken.Count() > 0 && (strToken = lstToken.ElementAt(0).ToString()).Length > 0)
            {
                String strURL = "https://go.urbanairship.com/api/push/";
                String strData = "{\"device_tokens\":[\"" + strToken + "\"],\"aps\":{\"badge\":" + intBadgeCount.ToString() + ",\"sound\":\"default\",\"alert\":\"Thirrp has come up with an answer to your question!\"}}";
                HttpWebRequest request = null;

                Logger.Info("Push Payload: " + strData);

                try
                {
                    request = (HttpWebRequest)WebRequest.Create(strURL);
                }
                catch (Exception ee)
                {
                    Logger.Error(ee);
                    blnReturn = false;
                }

                CredentialCache cc = new CredentialCache();
                String strAppKey = ConfigurationManager.AppSettings["AppKey"];
                String strAppMasterSecret = ConfigurationManager.AppSettings["AppMasterSecret"];

                Logger.Info("UA credentials: " + strAppKey + " AND " + strAppMasterSecret);

                cc.Add(new Uri(strURL), "Basic", new NetworkCredential(strAppKey, strAppMasterSecret));

                request.Credentials = cc;
                request.ContentType = "application/json";
                request.Method = "POST";
                request.ContentLength = strData.Length;

                try
                {
                    using (Stream stmRequest = request.GetRequestStream())
                    {
                        stmRequest.Write(System.Text.Encoding.ASCII.GetBytes(strData), 0, strData.Length);
                    }
                }
                catch (Exception ee)
                {
                    Logger.Error(ee);
                    blnReturn = false;
                }

                try
                {
                    using (HttpWebResponse response = (HttpWebResponse)request.GetResponse())
                    {
                        if (HttpStatusCode.OK == response.StatusCode)
                        {
                            // Do nothing
                        }
                    }
                }
                catch (Exception ee)
                {
                    Logger.Error(ee);
                    blnReturn = false;
                }

            }
            else
            {
                blnReturn = false;
            }

            return (blnReturn);
        }  // PushAnswer

        private void Log(String s)
        {
            String strFile = HttpContext.Current.Server.MapPath("~/App_Data/log.txt");
            FileMode fm = new FileMode();

            fm = File.Exists(strFile) ? FileMode.Append : FileMode.CreateNew;

            using (FileStream fs = new FileStream(strFile, fm))
            {
                using (StreamWriter sw = new StreamWriter(fs))
                {
                    sw.Write(s);
                    sw.Write(System.Environment.NewLine);
                }  // using sw
            }  // using fs

        }  // Log

        private void UploadFile(String strServer, String strUserName, String strPassword, String strFile)
        {
            Logger.EnterMethod(System.Reflection.MethodBase.GetCurrentMethod().ToString());

            using (System.Net.WebClient client = new System.Net.WebClient())
            {
                client.Credentials = new System.Net.NetworkCredential(strUserName, strPassword);
                client.UploadFile(strServer + "/" + new FileInfo(strFile).Name, "STOR", strFile);
            }
        }

        private void UploadData(String strServer, String strUserName, String strPassword, String strData)
        {
            Logger.EnterMethod(System.Reflection.MethodBase.GetCurrentMethod().ToString());
            strData = Regex.Replace(strData, @"[ ]", String.Empty);

            using (System.Net.WebClient client = new System.Net.WebClient())
            {
                client.Credentials = new System.Net.NetworkCredential(strUserName, strPassword);
                client.UploadData(strServer + "/" + strData + "data.txt", "STOR", System.Text.Encoding.ASCII.GetBytes(strData));
            }
        }

        [WebGet]
        public Int32 RegisterDevice(String s)
        {
            Logger.EnterMethod(System.Reflection.MethodBase.GetCurrentMethod().ToString());
            Int32 intReturn;
            s = s ?? String.Empty;
            s = s.ToUpper().Trim();

            // Check iOS, Andriod, WP7
            if (false == Regex.IsMatch(s, @"[A-F0-9]{40}") &&
                false == Regex.IsMatch(s, @"[A-F0-9]{8}-[A-F0-9]{4}-[A-F0-9]{4}-[A-F0-9]{4}-[A-F0-9]{12}"))
            {
                intReturn = 1;
            }
            // Already have session
            else if (null != HttpContext.Current.Session["UserInfo"])
            {
                intReturn = 0;
            }
            // New session coming up
            else
            {
                Entities e = new Entities();
                Users u = e.GetUser(s).ElementAt(0);
                UserInfo ui = new UserInfo();

                ui.UserId = u.UserId;
                ui.DeviceID = u.DeviceID;
                HttpContext.Current.Session["UserInfo"] = ui;
                intReturn = 0;
            }  // if - register

            return (intReturn);
        }  // RegisterDevice

        [WebGet]
        public Int32 AnswerQuestion(String strQuestionId, String strAnswer)
        {
            Logger.EnterMethod(System.Reflection.MethodBase.GetCurrentMethod().ToString());
            Int32 blnReturn = 0;

            this.ui_ = (UserInfo)HttpContext.Current.Session["UserInfo"];

            if (ValidUser(ui_))
            {
                strQuestionId = strQuestionId ?? String.Empty;
                strQuestionId = strQuestionId.Trim();
                strAnswer = strAnswer ?? String.Empty;
                strAnswer = strAnswer.Trim();

                Int32 intQuestionId = Convert.ToInt32(strQuestionId);
                Entities e = new Entities();
                Int32 intBadgeCount;
                Questions q = e.AnswerQuestion(intQuestionId, strAnswer, ui_.UserId).ElementAt(0);

                intBadgeCount = (Int32) e.GetBadgeCount(q.AskUserId).Single();

                if ( true != q.Archived && true == PushAnswer(q.AskUserId, intQuestionId, ++intBadgeCount) )
                {
                    e.SetBadgeCount(q.AskUserId, intBadgeCount);
                }

            }
            else
            {
                blnReturn = 1;
            }  // if

            return (blnReturn);
        }  // AnswerQuestion

        [WebGet]
        public List<Questions> GetQuestionToAnswer(String strLocale)
        {
            Logger.EnterMethod(System.Reflection.MethodBase.GetCurrentMethod().ToString());
            this.ui_ = (UserInfo)HttpContext.Current.Session["UserInfo"];

            if (ValidUser(ui_))
            {
                strLocale = strLocale ?? String.Empty;
                strLocale = strLocale.Trim();

                return (new Entities().GetQuestionToAnswer(strLocale, ui_.UserId).ToList());
            }
            else
            {
                return (new List<Questions>().ToList());
            }  // if

        }  // GetQuestionToAnswer

        [WebGet]
        public List<Questions> GetQuestion(String strQuestionId)
        {
            Logger.EnterMethod(System.Reflection.MethodBase.GetCurrentMethod().ToString());
            this.ui_ = (UserInfo)HttpContext.Current.Session["UserInfo"];

            if (ValidUser(ui_))
            {
                strQuestionId = strQuestionId ?? String.Empty;
                strQuestionId = strQuestionId.Trim();

                Int32 intQuestionId = Convert.ToInt32(strQuestionId);

                return (new Entities().GetQuestion(intQuestionId).ToList());
            }
            else
            {
                return (new List<Questions>().ToList());
            }  // if

        }  // GetQuestion

        [WebGet]
        public List<Questions> InsertQuestion(String strLocale, String strQuestion)
        {
            Logger.EnterMethod(System.Reflection.MethodBase.GetCurrentMethod().ToString());
            this.ui_ = (UserInfo)HttpContext.Current.Session["UserInfo"];

            if (ValidUser(ui_))
            {
                strLocale = strLocale ?? String.Empty;
                strLocale = strLocale.Trim();
                strQuestion = strQuestion ?? String.Empty;
                strQuestion = strQuestion.Trim();

                Logger.Info("Ready for sproc InsertQuestion: strLocale = " +
                    strLocale + " strQuestion = " + strQuestion +
                    " ui_UserId = " + ui_.UserId );

                return (new Entities().InsertQuestion(strLocale,
                    strQuestion,
                    ui_.UserId).ToList());
            }
            else
            {
                return (new List<Questions>().ToList());
            }  // if

        }  // InsertQuestion

        [WebGet]
        public List<Questions> GetQuestionsByUserId()
        {
            Logger.EnterMethod(System.Reflection.MethodBase.GetCurrentMethod().ToString());
            this.ui_ = (UserInfo)HttpContext.Current.Session["UserInfo"];

            if (ValidUser(ui_))
            {
                return (new Entities().GetQuestionsByUserId(ui_.UserId).ToList());
            }
            else
            {
                return (new List<Questions>().ToList());
            }  // if

        }  // GetQuestionsByUserId

        [WebGet]
        public Int32 ArchiveQuestion(String strQuestionId)
        {
            Logger.EnterMethod(System.Reflection.MethodBase.GetCurrentMethod().ToString());
            Int32 blnReturn = 0;

            this.ui_ = (UserInfo)HttpContext.Current.Session["UserInfo"];

            if (ValidUser(ui_))
            {
                strQuestionId = strQuestionId ?? String.Empty;
                strQuestionId = strQuestionId.Trim();

                Int32 intQuestionId = Convert.ToInt32(strQuestionId);

                Entities e = new Entities();

                e.ArchiveQuestion(intQuestionId);
            }
            else
            {
                blnReturn = 1;
            }  // if

            return (blnReturn);
        }  // ArchiveQuestion

        [WebGet]
        public Int32 SavePushToken(String s)
        {
            Logger.EnterMethod(System.Reflection.MethodBase.GetCurrentMethod().ToString());
            Int32 blnReturn = 0;

            this.ui_ = (UserInfo)HttpContext.Current.Session["UserInfo"];

            if (ValidUser(ui_))
            {
                s = s ?? String.Empty;
                //s = Regex.Replace(s, @"[<> ]", String.Empty);

                Entities e = new Entities();

                e.SavePushToken(ui_.UserId, s);
            }
            else
            {
                blnReturn = 1;
            }  // if

            return (blnReturn);
        }  // SavePushToken

        [WebGet]
        public Int32 DidViewAnswer(String strQuestionId)
        {
            Logger.EnterMethod(System.Reflection.MethodBase.GetCurrentMethod().ToString());
            Int32 blnReturn = 0;

            this.ui_ = (UserInfo)HttpContext.Current.Session["UserInfo"];

            if (ValidUser(ui_))
            {
                strQuestionId = strQuestionId ?? String.Empty;
                strQuestionId = strQuestionId.Trim();

                Int32 intQuestionId = Convert.ToInt32(strQuestionId);

                Entities e = new Entities();

                e.DidViewAnswer(intQuestionId);
            }
            else
            {
                blnReturn = 1;
            }  // if

            return (blnReturn);
        }  // DidViewAnswer

    }  // Service

}  // namespace
