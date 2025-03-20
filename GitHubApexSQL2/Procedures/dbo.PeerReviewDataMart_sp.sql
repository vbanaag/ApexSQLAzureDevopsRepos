SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		Jovy Banaag
-- Create date: 01-18-2022
-- Description:	ETL logic to update PeerReview tables as part of on-going OPPE project.  
-- Changed by : Jovy Banaag 2-9-2022 - Code change to cleanse data of pipe delimiters
-- Changed by : Jovy Banaag 2-10-2022 - Add new column File State
-- Changed by : Jovy Banaag 8-22-2023 - Code change for handling multiple NPIs in one row
-- =============================================
CREATE PROCEDURE [dbo].[PeerReviewDataMart_sp] 
	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

IF OBJECT_ID('tempdb..#temp') IS NOT NULL
DROP TABLE #temp


select
    [PeerReview ID],  
    [First Name],  
	/*
	Case
		When (CHARINDEX('|',NPI) > 0 or CHARINDEX('|',[First Name]) > 0 or CHARINDEX('|',[Last Name]) > 0 or CHARINDEX('|',[Date of Occurence]) > 0)  
		Then SUBSTRING(REPLACE([First Name],'|',' '),1,CHARINDEX(' ',REPLACE([First Name],'|',' ')) - 1) --1st First Name
		Else REPLACE([First Name],'|',' ')
	End as [First Name],
	*/
	[Last Name], 
	/*
	Case
		When (CHARINDEX('|',NPI) > 0 or CHARINDEX('|',[First Name]) > 0 or CHARINDEX('|',[Last Name]) > 0 or CHARINDEX('|',[Date of Occurence]) > 0) 
		Then SUBSTRING(REPLACE([Last Name],'|',' '),1,CHARINDEX(' ',REPLACE([Last Name],'|',' ')) - 1) --1st Last Name
		Else REPLACE([Last Name],'|',' ')
	End as [Last Name],
	*/
    [NPI],
	/*
	Case
		When (CHARINDEX('|',NPI) > 0 or CHARINDEX('|',[First Name]) > 0 or CHARINDEX('|',[Last Name]) > 0 or CHARINDEX('|',[Date of Occurence]) > 0) 
		Then 
			Case
				When len(NPI) > 11
				Then ltrim(SUBSTRING(REPLACE(NPI,'|',' '),1,CHARINDEX(' ',REPLACE(NPI,'|',' ')) - 1)) --1st NPI
				Else ltrim(REPLACE(NPI,'|',' '))
			End
		Else ltrim(REPLACE(NPI,'|',' '))
	End as NPI,
	*/
	[Date of Occurence], 
    [Trigger Category], 
	[Trigger Combined], 
    [Screening Decision Combined],   
    [Screening Final Decision Combined], 
	[File Name],
	[File State] -- Added by Jovy Banaag 2/10/2022 
into #temp
from [dbo].[PeerReviewStaging]
WHERE len(REPLACE(NPI, ' ', '')) < 11		-- Added by Jovy Banaag 8/22/2023 


--------------Deleting duplicate records-------------- 
DELETE s
FROM PeerReviewDataMart AS s
INNER JOIN #temp AS t
ON s.[PeerReview ID] = t.[PeerReview ID] 
------------------------------------------------------ 

insert into [dbo].[PeerReviewDataMart]
(
    [PeerReview ID]  
    ,[First Name]  
    ,[Last Name]   
    ,[NPI]  
	,[Date of Occurence] 
    ,[Trigger Category] 
	,[Trigger Combined] 
    ,[Screening Decision Combined]   
    ,[Screening Final Decision Combined] 
	,[File Name]
	,[File State] -- Added by Jovy Banaag 2/10/2022 
)
select 
    [PeerReview ID]  
    ,[First Name]  
    ,[Last Name]   
    ,[NPI]  
	,[Date of Occurence] 
    ,[Trigger Category] 
	,[Trigger Combined] 
    ,[Screening Decision Combined]   
    ,[Screening Final Decision Combined]  
	,[File Name]
	,[File State] -- Added by Jovy Banaag 2/10/2022
from #temp


END
GO
