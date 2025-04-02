SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO


-- =============================================
-- Author:		<Jovy Banaag>
-- Create date: <5/12/2023>
-- Description:	<Stored procedure to load Employment History data into datamart>
-- Changed by : Jovy Banaag 07/27/2023 - Added new fields for HR Turnover report
-- Changed by : Jovy Banaag 02/04/2025 - Added conversion code for dates
-- =============================================
CREATE PROCEDURE [dbo].[EmploymentHistoryDataMart_Sp] 
	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	Declare @test2 as varchar(55), @test3 as varchar(30)

--Getting data
IF OBJECT_ID('tempdb..#temp') IS NOT NULL
DROP TABLE #temp

Select distinct [Person Number],
	[Legal Employer],
	[Worker Type],
	[Person Type],
	[Legal Employer Hire Date],
	[Enterprise Hire Date],
	[Termination Date],
	[Action Type],
	[Action Code],
	[Action Reason],
	[Magnet Description],
	[Effective Start Date],
	[Effective End Date],
	[Assignment Number],
	[Assignment Status],
	[Business Unit],
	[Primary Flag],
	[Primary Work Relationship Flag],
	[Primary Assignment Flag],
	[Position],
	[Job],
	[Job Family],
	[Job Function],
	[Management Level],
	[Overtime Status],
	[EEO-1 Category],
	[Grade],
	[Grade Salary Minimum],
	[Grade Salary Midpoint],
	[Grade Salary Maximum],
	[Department],
	[Location],
	[Location Address 1],
	[Location Address 2],
	[Location City],
	[Location State],
	[Location Zip Code],
	[Location County],
	[Assignment Category],
	[Regular or Temporary],
	[Full-Time or Part-Time],
	[Hourly Paid or Salaried],
	[Working Hours],
	[FTE],
	[Experience Date],
	[Work Schedule],
	[Contingent Worker Type],
	[Contingent Worker Category],
	[Contingent Vendor],
	[Contract Start Date],
	[Remote Worker Status],
	[Manager],
	[Area of Responsibility (HR Business Partner)],
	[Recommended for Rehire],
	[Recommended for Rehire Reason],
	[Action Type Description],														--Added by Jovy Banaag 7/27/2023
	[Action Code Description],														--Added by Jovy Banaag 7/27/2023
	[Action Reason Description],													--Added by Jovy Banaag 7/27/2023
	[Effective Sequence],															--Added by Jovy Banaag 7/27/2023
	[Position Code],																--Added by Jovy Banaag 7/27/2023
	[Job Code],																		--Added by Jovy Banaag 7/27/2023
	[Job Family Code],																--Added by Jovy Banaag 7/27/2023
	[Job Function Code],															--Added by Jovy Banaag 7/27/2023
	[Location Code],																--Added by Jovy Banaag 7/27/2023
	[Assignment Status Type Code],													--Added by Jovy Banaag 7/27/2023
	[Manager Person Number]															--Added by Jovy Banaag 7/27/2023
into #temp
--select * from #temp
From EmploymentHistoryStaging

--Truncating datamart
Truncate table EmploymentHistoryDataMart

--Updating datamart	
insert into [dbo].[EmploymentHistoryDataMart]
(	[Person Number],
	[Legal Employer],
	[Worker Type],
	[Person Type],
	[Date Legal Employer Hire],
	[Date Enterprise Hire],
	[Date Termination],
	[Action Type Code],
	[Action],
	[Action Reason Code],
	[Magnet Description],
	[Date Effective Start],
	[Date Effective End],
	[Assignment Number],
	[Assignment Status],
	[Business Unit],
	[Primary Flag],
	[Primary Work Relationship Flag],
	[Primary Assignment Flag],
	[Position],
	[Job],
	[Job Family],
	[Job Function],
	[Management Level],
	[Overtime Status],
	[EEO-1 Category],
	[Grade],
	[Grade Salary Minimum],
	[Grade Salary Midpoint],
	[Grade Salary Maximum],
	[Department],
	[Location],
	[Location Address 1],
	[Location Address 2],
	[Location City],
	[Location State],
	[Location Zip Code],
	[Location County],
	[Assignment Category],
	[Regular or Temporary],
	[Full-Time or Part-Time],
	[Hourly Paid or Salaried],
	[Working Hours],
	[FTE],
	[Date Experience],
	[Work Schedule],
	[Contingent Worker Type],
	[Contingent Worker Category],
	[Contingent Vendor],
	[Date Contract Start],
	[Remote Worker Status],
	[Manager],
	[Area of Responsibility (HR Business Partner)],
	[Recommended for Rehire],
	[Recommended for Rehire Reason],
	[Action Type Description],														--Added by Jovy Banaag 7/27/2023
	[Action Code Description],														--Added by Jovy Banaag 7/27/2023
	[Action Reason Description],													--Added by Jovy Banaag 7/27/2023
	[Effective Sequence],															--Added by Jovy Banaag 7/27/2023
	[Position Code],																--Added by Jovy Banaag 7/27/2023
	[Job Code],																		--Added by Jovy Banaag 7/27/2023
	[Job Family Code],																--Added by Jovy Banaag 7/27/2023
	[Job Function Code],															--Added by Jovy Banaag 7/27/2023
	[Location Code],																--Added by Jovy Banaag 7/27/2023
	[Assignment Status Type Code],													--Added by Jovy Banaag 7/27/2023
	[Manager Person Number],														--Added by Jovy Banaag 7/27/2023
	[Department Id]																	--Added by Jovy Banaag 7/27/2023
)
select 	[Person Number],
	[dbo].[InitCap]([Legal Employer]) as [Legal Employer],
	[dbo].[InitCap]([Worker Type]) as [Worker Type],
	[dbo].[InitCap]([Person Type]) as [Person Type],
	Case
		When [Legal Employer Hire Date] is null or [Legal Employer Hire Date] = ''
			Then null
		Else convert(datetime, [Legal Employer Hire Date], 120)						--Added by Jovy Banaag 2/4/2025					
	End as [Legal Employer Hire Date],
	Case
		When [Enterprise Hire Date] is null or [Enterprise Hire Date] = ''
			Then null
		Else convert(datetime, [Enterprise Hire Date], 120)							--Added by Jovy Banaag 2/4/2025	
	End as [Enterprise Hire Date],
	Case
		When [Termination Date] is null or [Termination Date] = ''
			Then null
		Else convert(datetime, [Termination Date], 120)								--Added by Jovy Banaag 2/4/2025	
	End as [Termination Date],
	[dbo].[InitCap]([Action Type]) as [Action Type],
	[dbo].[InitCap]([Action Code]) as [Action Code],
	[dbo].[InitCap]([Action Reason]) as [Action Reason],
	[Magnet Description],
	Case
		When [Effective Start Date] is null or [Effective Start Date] = ''
			Then null
		Else convert(datetime, [Effective Start Date], 120)							--Added by Jovy Banaag 2/4/2025	
	End as [Effective Start Date],
	Case
		When [Effective End Date] is null or [Effective End Date] = ''
			Then null
		Else convert(datetime, [Effective End Date], 120)							--Added by Jovy Banaag 2/4/2025	
	End as [Effective End Date],
	[Assignment Number],
	[dbo].[InitCap]([Assignment Status]) as [Assignment Status],
	[Business Unit],
	[Primary Flag],
	[Primary Work Relationship Flag],
	[Primary Assignment Flag],
	[dbo].[InitCap]([Position]) as [Position],
	[dbo].[InitCap]([Job]) as [Job],
	[dbo].[InitCap]([Job Family]) as [Job Family],
	[Job Function],
	[Management Level],
	[dbo].[InitCap]([Overtime Status]) as [Overtime Status],
	[EEO-1 Category],
	[Grade],
	[Grade Salary Minimum],
	[Grade Salary Midpoint],
	[Grade Salary Maximum],
	[Department],
	[Location],
	[Location Address 1],
	[Location Address 2],
	[Location City],
	[Location State],
	[Location Zip Code],
	[Location County],
	[Assignment Category],
	[Regular or Temporary],
	[dbo].[InitCap]([Full-Time or Part-Time]) as [Full-Time or Part-Time],
	[dbo].[InitCap]([Hourly Paid or Salaried]) as [Hourly Paid or Salaried],
	[Working Hours],
	[FTE],
	Case
		When [Experience Date] is null or [Experience Date] = ''
			Then null
		Else convert(datetime, [Experience Date], 120)								--Added by Jovy Banaag 2/4/2025	
	End as [Experience Date],
	[dbo].[InitCap]([Work Schedule]) as [Work Schedule],
	[Contingent Worker Type],
	[Contingent Worker Category],
	[Contingent Vendor],
	Case
		When [Contract Start Date] is null or [Contract Start Date] = ''
			Then null
		Else convert(datetime, [Contract Start Date], 120)							--Added by Jovy Banaag 2/4/2025	
	End as [Contract Start Date],
	[Remote Worker Status],
	[dbo].[InitCap]([Manager]) as [Manager],
	[dbo].[InitCap]([Area of Responsibility (HR Business Partner)]) as [Area of Responsibility (HR Business Partner)],
	[Recommended for Rehire],
	[Recommended for Rehire Reason],
	[Action Type Description],															--Added by Jovy Banaag 7/27/2023
	[Action Code Description],															--Added by Jovy Banaag 7/27/2023
	[Action Reason Description],														--Added by Jovy Banaag 7/27/2023
	[Effective Sequence],																--Added by Jovy Banaag 7/27/2023
	[Position Code],																	--Added by Jovy Banaag 7/27/2023
	[Job Code],																			--Added by Jovy Banaag 7/27/2023
	[Job Family Code],																	--Added by Jovy Banaag 7/27/2023
	[Job Function Code],																--Added by Jovy Banaag 7/27/2023
	[Location Code],																	--Added by Jovy Banaag 7/27/2023
	[dbo].[InitCap]([Assignment Status Type Code]) as [Assignment Status Type Code],	--Added by Jovy Banaag 7/27/2023
	[Manager Person Number],															--Added by Jovy Banaag 7/27/2023
	LEFT([Department],8) as [Department Id]												--Added by Jovy Banaag 7/27/2023
from #temp

END


GO
