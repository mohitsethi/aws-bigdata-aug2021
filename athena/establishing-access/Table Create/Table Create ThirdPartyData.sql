SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[ThirdPartyData](
	[CardNumber] [varchar](13) NOT NULL,
	[MerchantID] [uniqueidentifier] NOT NULL,
	[MerchantName] [varchar](50) NOT NULL,
	[Status] [varchar](25) NOT NULL,
	[DateIssued] [datetime] NULL,
	[DateActivated] [datetime] NULL,
	[DateVoided] [datetime] NULL,
	[DateExpires] [datetime] NULL,
	[CardType] [varchar](25) NOT NULL,
	[AmountIssued] [money] NOT NULL,
	[Balance] [money] NOT NULL,
	[PrintLocation] [varchar](25) NOT NULL,
	[DatePrinted] [datetime] NULL,
	[CardVersion] [decimal](18, 2) NOT NULL,
	[AuthorizationCode] [varchar](8) NULL
) ON [PRIMARY]

GO