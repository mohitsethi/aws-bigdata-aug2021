SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[WiredBrainCoffeeData](
	[ID] [uniqueidentifier] NOT NULL,
	[StoreID] [int] NOT NULL,
	[CardNumber] [varchar](13) NOT NULL,
	[Status] [varchar](25) NOT NULL,
	[DateIssued] [datetime] NULL,
	[DateActivated] [datetime] NULL,
	[DateVoided] [datetime] NULL,
	[DateExpires] [datetime] NULL,
	[CardType] [varchar](25) NOT NULL,
	[AmountIssued] [money] NOT NULL,
	[Balance] [money] NOT NULL,
	[Notes] [varchar](max) NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO