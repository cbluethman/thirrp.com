using System;
using System.Diagnostics;
using System.Reflection;
using System.Net.Mail;
using System.Text;
using System.Text.RegularExpressions;
using System.Web;
using System.Net;
using System.IO;
using System.Configuration;

public static class Logger
{
    public static void Error(String message)
    {
        if ( IsLogLevel( "error" ) )
            WriteEntry(message, "error");
    }

    public static void Error(Exception e)
    {
        if ( IsLogLevel( "error" ) )
            WriteEntry(e.Message, "error");
    }

    public static void Warning(String message)
    {
        if ( IsLogLevel( "warning" ) )
            WriteEntry(message, "warning");
    }

    public static void Info(String message)
    {
        if ( IsLogLevel( "info" ) )
            WriteEntry(message, "info");
    }

    public static void EnterMethod(String str)
    {
        if (IsLogLevel("info"))
            WriteEntry("Entering: " + str, "info");
    }

    private static Boolean IsLogLevel(String type)
    {
        Boolean blnReturn;
        String strLogLevel = ConfigurationManager.AppSettings["LogLevel"];

        blnReturn = strLogLevel.Contains(type);
        
        return (blnReturn);
    }

    private static void WriteEntry(String message, String type)
    {

        using (FileStream fs = new FileStream(HttpContext.Current.Server.MapPath("~/App_Data/log.txt"), FileMode.Append, FileAccess.Write))
        {
            TextWriterTraceListener myListener = new TextWriterTraceListener(fs);

            Trace.Listeners.Add(myListener);
            myListener.WriteLine(String.Format("{0},{1},{2},{3}",
                DateTime.Now.ToString("yyyy-MM-dd HH:mm:ss"),
                HttpContext.Current.Request.ServerVariables["REMOTE_ADDR"],
                type,
                message));
            Trace.Flush();
            myListener.Flush();
        }  // using fs

    }

    private static void SendMail()
    {
        MailMessage objMail = new MailMessage();
        SmtpClient SMTPServer = new SmtpClient();

        SMTPServer.Host = "mail.thirrp.comm";
//        SMTPServer.Port = 465;
        SMTPServer.Credentials = new NetworkCredential("user", "pass");
//        SMTPServer.EnableSsl = true;

        objMail.To.Add("errors@thirrp.com");

        String strWebSite = Regex.Replace(HttpContext.Current.Request.Url.Host, @"^www\.", String.Empty, RegexOptions.IgnoreCase);

        objMail.From = new MailAddress("no-reply@" + strWebSite);
        objMail.SubjectEncoding = System.Text.Encoding.UTF8;
        objMail.BodyEncoding = System.Text.Encoding.UTF8;
        objMail.Priority = MailPriority.Normal;
        objMail.Subject = "Error in the Site";
        objMail.IsBodyHtml = false;

        StringBuilder sb = new StringBuilder();

        sb.Append(HttpContext.Current.Server.GetLastError().ToString());
        sb.Append(Environment.NewLine);
        sb.Append(Environment.NewLine);
        sb.Append(HttpContext.Current.Request.Url.PathAndQuery);
        sb.Append(Environment.NewLine);
        sb.Append(Environment.NewLine);
        sb.Append(HttpContext.Current.Request.RawUrl);
        sb.Append(Environment.NewLine);
        sb.Append(Environment.NewLine);
        sb.Append(HttpContext.Current.Request.ServerVariables["REMOTE_ADDR"]);
        sb.Append(Environment.NewLine);
        sb.Append(Environment.NewLine);

        objMail.Body = sb.ToString();

        SMTPServer.Send(objMail);
    }

}