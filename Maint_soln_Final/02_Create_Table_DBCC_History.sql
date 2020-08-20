--Create Table DBCC_History
--
Use DBAdmin
GO
IF OBJECT_ID('DBCC_History','U') IS NOT NULL
    DROP Table DBCC_History
GO

CREATE TABLE [DBAdmin].[dbo].[DBCC_History]
(
	[Error] [int] NULL,
	[Level] [int] NULL,
	[State] [int] NULL,
	[MessageText] [varchar](7000) NULL,
	[RepairLevel] [int] NULL,
	[Status] [int] NULL,
	[DbId] [int] NULL,
	[DbFragId] [int] NULL,
	[ObjectId] [int] NULL,
	[IndexId] [int] NULL,
	[PartitionID] [int] NULL,
	[AllocUnitID] [int] NULL,
	[RidDbId] [int] NULL,
	[RidPruId] [int] NULL,
	[File] [int] NULL,
	[Page] [int] NULL,
	[Slot] [int] NULL,
	[RefDbId] [int] NULL,
	[RefPruId] [int] NULL,
	[RefFile] [int] NULL,
	[RefPage] [int] NULL,
	[RefSlot] [int] NULL,
	[Allocation] [int] NULL,
	[TimeStamp] [datetime] NULL CONSTRAINT [DF_dbcc_history_TimeStamp] DEFAULT (GETDATE())
) ON [PRIMARY]
GO
-----------------------------------------------------------------------
-----------------------------------------------------------------------