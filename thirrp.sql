USE [parastr_devthirrp]
GO
/****** Object:  User [parastr_dba01]    Script Date: 02/04/2012 14:44:36 ******/
IF NOT EXISTS (SELECT * FROM sys.database_principals WHERE name = N'parastr_dba01')
CREATE USER [parastr_dba01] FOR LOGIN [parastr_dba01] WITH DEFAULT_SCHEMA=[parastr_dba01]
GO
/****** Object:  Schema [parastr_dba01]    Script Date: 02/04/2012 14:44:36 ******/
IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = N'parastr_dba01')
EXEC sys.sp_executesql N'CREATE SCHEMA [parastr_dba01] AUTHORIZATION [parastr_dba01]'
GO
/****** Object:  Table [parastr_dba01].[Users]    Script Date: 02/04/2012 14:44:39 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[parastr_dba01].[Users]') AND type in (N'U'))
BEGIN
CREATE TABLE [parastr_dba01].[Users](
	[UserId] [int] IDENTITY(1,1) NOT NULL,
	[DeviceID] [char](40) NOT NULL,
	[DeviceToken] [char](64) NULL,
	[BadgeCount] [int] NULL,
 CONSTRAINT [PK_Users] PRIMARY KEY CLUSTERED 
(
	[UserId] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
END
GO
SET ANSI_PADDING OFF
GO
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[parastr_dba01].[Users]') AND name = N'IX_DeviceID')
CREATE UNIQUE NONCLUSTERED INDEX [IX_DeviceID] ON [parastr_dba01].[Users] 
(
	[DeviceID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
GO
/****** Object:  Table [parastr_dba01].[Questions]    Script Date: 02/04/2012 14:44:39 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[parastr_dba01].[Questions]') AND type in (N'U'))
BEGIN
CREATE TABLE [parastr_dba01].[Questions](
	[QuestionId] [int] IDENTITY(1,1) NOT NULL,
	[Locale] [nvarchar](10) NULL,
	[Question] [nvarchar](4000) NULL,
	[Answer] [nvarchar](4000) NULL,
	[AskUserId] [int] NULL,
	[AskDateTime] [datetime] NULL,
	[AnswerUserId] [int] NULL,
	[AnswerDateTime] [datetime] NULL,
	[Archived] [bit] NULL,
	[ViewedAnswer] [bit] NULL,
 CONSTRAINT [PK_Questions] PRIMARY KEY CLUSTERED 
(
	[QuestionId] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
END
GO
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[parastr_dba01].[Questions]') AND name = N'IX_AnswerUserId')
CREATE NONCLUSTERED INDEX [IX_AnswerUserId] ON [parastr_dba01].[Questions] 
(
	[AnswerUserId] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
GO
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[parastr_dba01].[Questions]') AND name = N'IX_AskUserId')
CREATE NONCLUSTERED INDEX [IX_AskUserId] ON [parastr_dba01].[Questions] 
(
	[AskUserId] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
GO
/****** Object:  StoredProcedure [parastr_dba01].[usp_SavePushToken]    Script Date: 02/04/2012 14:46:15 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[parastr_dba01].[usp_SavePushToken]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [parastr_dba01].[usp_SavePushToken]
(
	@intUserId INT,
	@cDeviceToken CHAR(64)
)

AS

	update Users
	set DeviceToken = @cDeviceToken
	where ( UserId = @intUserId )


RETURN
' 
END
GO
/****** Object:  StoredProcedure [parastr_dba01].[usp_GetPushToken]    Script Date: 02/04/2012 14:46:15 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[parastr_dba01].[usp_GetPushToken]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [parastr_dba01].[usp_GetPushToken]
(
	@intUserId INT
)

AS

select isnull( a.DeviceToken, '''' ) from Users a
	where ( a.UserId = @intUserId )


RETURN
' 
END
GO
/****** Object:  StoredProcedure [parastr_dba01].[usp_GetUser]    Script Date: 02/04/2012 14:46:15 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[parastr_dba01].[usp_GetUser]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [parastr_dba01].[usp_GetUser]
(
	@cDeviceID CHAR(40)
)
AS

if exists ( select * from Users a where a.DeviceID = @cDeviceID )
begin
	select * from Users a where a.DeviceID = @cDeviceID
end
else
begin
	insert into Users ( DeviceID, BadgeCount )
	output inserted.*
	values ( @cDeviceID, 0 )
end


/* DBCC CHECKIDENT(''Customer'', RESEED, 0) */
' 
END
GO
/****** Object:  StoredProcedure [parastr_dba01].[usp_GetBadgeCount]    Script Date: 02/04/2012 14:46:15 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[parastr_dba01].[usp_GetBadgeCount]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [parastr_dba01].[usp_GetBadgeCount]
(
	@intUserId INT
)

AS

	select isnull( a.BadgeCount, 0 ) from Users a
	where ( a.UserId = @intUserId )

RETURN
' 
END
GO
/****** Object:  StoredProcedure [parastr_dba01].[usp_SetBadgeCount]    Script Date: 02/04/2012 14:46:15 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[parastr_dba01].[usp_SetBadgeCount]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [parastr_dba01].[usp_SetBadgeCount]
(
	@intUserId INT,
	@intBadgeCount INT
)

AS

if ( @intBadgeCount > -1 )
begin
	update Users
	set BadgeCount = @intBadgeCount
	where ( UserId = @intUserId )
end

RETURN
' 
END
GO
/****** Object:  StoredProcedure [parastr_dba01].[usp_GetQuestion]    Script Date: 02/04/2012 14:46:15 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[parastr_dba01].[usp_GetQuestion]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [parastr_dba01].[usp_GetQuestion]
	@intQuestionId INT
AS

select * from Questions a
	where ( @intQuestionId = a.QuestionId )

RETURN
' 
END
GO
/****** Object:  StoredProcedure [parastr_dba01].[usp_InsertQuestion]    Script Date: 02/04/2012 14:46:15 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[parastr_dba01].[usp_InsertQuestion]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [parastr_dba01].[usp_InsertQuestion]
(
	@varLocale VARCHAR(10),
	@varQuestion VARCHAR(4096),
	@intUserId INT
)
AS
	declare @dtAskDateTime DATETIME;

	set @dtAskDateTime = getdate( );

	insert into Questions ( Locale, Question, AskDateTime, AskUserId )
		output inserted.*
		values ( @varLocale, @varQuestion, @dtAskDateTime, @intUserId );


RETURN
' 
END
GO
/****** Object:  StoredProcedure [parastr_dba01].[usp_GetQuestionToAnswer]    Script Date: 02/04/2012 14:46:15 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[parastr_dba01].[usp_GetQuestionToAnswer]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [parastr_dba01].[usp_GetQuestionToAnswer]
(
	@varLocale VARCHAR(10),
	@intUserId INT
)
AS
	select top 1 * from Questions a
	where ( @varLocale = a.Locale and @intUserId <> a.AskUserId and a.Answer IS NULL )
	order by a.AskDateTime asc;


RETURN
' 
END
GO
/****** Object:  StoredProcedure [parastr_dba01].[usp_AnswerQuestion]    Script Date: 02/04/2012 14:46:15 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[parastr_dba01].[usp_AnswerQuestion]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [parastr_dba01].[usp_AnswerQuestion]
(
	@intQuestionId INT,
	@varAnswer VARCHAR(4096),
	@intUserId INT
)
AS

declare @dtAnswerDateTime DATETIME;

set @dtAnswerDateTime = getdate( );

update Questions
	set Answer = @varAnswer,
	AnswerDateTime = @dtAnswerDateTime,
	AnswerUserId = @intUserId
	where ( QuestionId = @intQuestionId and Answer is null )

select * from Questions a
	where ( @intQuestionId = a.QuestionId )
' 
END
GO
/****** Object:  StoredProcedure [parastr_dba01].[usp_GetQuestionsByUserId]    Script Date: 02/04/2012 14:46:15 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[parastr_dba01].[usp_GetQuestionsByUserId]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [parastr_dba01].[usp_GetQuestionsByUserId]
	@intUserId INT
AS

select * from Questions a
	where ( @intUserId = a.AskUserId and ( a.Archived = 0 or a.Archived is null ) )
	order by a.AskDateTime asc;

RETURN
' 
END
GO
/****** Object:  StoredProcedure [parastr_dba01].[usp_DidViewAnswer]    Script Date: 02/04/2012 14:46:15 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[parastr_dba01].[usp_DidViewAnswer]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [parastr_dba01].[usp_DidViewAnswer]
	@intQuestionId INT
AS

declare @badgecount int
declare @userid int

select @userid = a.AskUserId from Questions a
	where ( @intQuestionId = a.QuestionId )
select @badgecount = a.BadgeCount from Users a
	where ( @userid = a.UserId )
set @badgecount = @badgecount - 1
exec usp_SetBadgeCount @intUserId=@userid, @intBadgeCount=@badgecount
update Questions
	set ViewedAnswer = 1
	where ( @intQuestionId = QuestionId )

RETURN
' 
END
GO
/****** Object:  StoredProcedure [parastr_dba01].[usp_ArchiveQuestion]    Script Date: 02/04/2012 14:46:15 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[parastr_dba01].[usp_ArchiveQuestion]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [parastr_dba01].[usp_ArchiveQuestion]
(
	@intQuestionId INT
)
AS

declare @viewedanswer bit

select @viewedanswer = a.ViewedAnswer from Questions a
	where ( @intQuestionId = a.QuestionId )

if ( @viewedanswer != 1 )
begin
	declare @badgecount int
	declare @userid int

	select @userid = a.AskUserId from Questions a
		where ( @intQuestionId = a.QuestionId )
	select @badgecount = a.BadgeCount from Users a
		where ( @userid = a.UserId )
	set @badgecount = @badgecount - 1
	exec usp_SetBadgeCount @intUserId=@userid, @intBadgeCount=@badgecount
end

update Questions
	set Archived = 1
	where QuestionId = @intQuestionId
' 
END
GO
/****** Object:  ForeignKey [FK_Questions_AnswerUserId]    Script Date: 02/04/2012 14:44:39 ******/
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[parastr_dba01].[FK_Questions_AnswerUserId]') AND parent_object_id = OBJECT_ID(N'[parastr_dba01].[Questions]'))
ALTER TABLE [parastr_dba01].[Questions]  WITH CHECK ADD  CONSTRAINT [FK_Questions_AnswerUserId] FOREIGN KEY([AnswerUserId])
REFERENCES [parastr_dba01].[Users] ([UserId])
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[parastr_dba01].[FK_Questions_AnswerUserId]') AND parent_object_id = OBJECT_ID(N'[parastr_dba01].[Questions]'))
ALTER TABLE [parastr_dba01].[Questions] CHECK CONSTRAINT [FK_Questions_AnswerUserId]
GO
/****** Object:  ForeignKey [FK_Questions_AskUserId]    Script Date: 02/04/2012 14:44:39 ******/
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[parastr_dba01].[FK_Questions_AskUserId]') AND parent_object_id = OBJECT_ID(N'[parastr_dba01].[Questions]'))
ALTER TABLE [parastr_dba01].[Questions]  WITH CHECK ADD  CONSTRAINT [FK_Questions_AskUserId] FOREIGN KEY([AskUserId])
REFERENCES [parastr_dba01].[Users] ([UserId])
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[parastr_dba01].[FK_Questions_AskUserId]') AND parent_object_id = OBJECT_ID(N'[parastr_dba01].[Questions]'))
ALTER TABLE [parastr_dba01].[Questions] CHECK CONSTRAINT [FK_Questions_AskUserId]
GO
