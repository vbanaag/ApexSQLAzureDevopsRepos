SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO


-- =============================================
-- Author:		<Jovy Banaag>
-- Create date: <5/4/2023>
-- Description:	<Stored procedure to load Personal Demographics data into datamart>
-- =============================================
create PROCEDURE [dbo].[PersonalDemographicsDataMart_Sp] 
	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;


--Getting data
IF OBJECT_ID('tempdb..#temp') IS NOT NULL
DROP TABLE #temp

Select distinct [Person Number],
	[First Name],
	[Middle Name],
	[Last Name],
	[Preferred Name],
	[Previous Last Name],
	[Suffix],
	[dbo].[InitCap]([Home Address Line 1]) as [Home Address Line 1],
	[dbo].[InitCap]([Home Address Line 2]) as [Home Address Line 2],
	[dbo].[InitCap]([Home City]) as [Home City],
	[Home State],
	[Home Zip Code],
	[Home County],
	Case
		When [Gender] = 'ORA_HRX_X'
		Then 'NonBinary'
		Else [Gender]
	End as [Gender],
	[dbo].[InitCap]([Ethnicity]) as [Ethnicity],
	[Date of Birth],
	[Date of Death],
	[Marital Status],
	[Bday List Exclude],
	[Prox Card Charge],
	[Confidentiality Agreement],
	[Compliance],
	[Employee Handbook],
	[CHMC 403b Orig Hire Date],
	[NPP 403b Orig Hire Date],
	[PTO Accrual Date],
	[Anniversary Date],
	[Seniority Date],
	[National Provider ID],
	[Work Email],
	[Personal Email],
	[Home Mobile Phone],
	[Home Phone],
	[Pager],
	[Voalte Number],
	[Work Fax],
	[Work Mobile Phone],
	[Work Phone],
	[Disable Veteran],
	[Active Duty Wartime or Campaign Badge Veteran],
	[Armed Forces Service Medal Veteran],
	[Recently Separated Veteran],
	[Veteran Self-Identification Status],
	[Self Disclosed Type],
	[Disability Start Date],
	[Disability Disclosure Date],	
	[Accommodation Request]
into #temp
From PersonalDemographicsStaging

--Truncating datamart
Truncate table PersonalDemographicsDataMart

--Updating datamart	
insert into [dbo].[PersonalDemographicsDataMart]
([Person Number],
	[First Name],
	[Middle Name],
	[Last Name],
	[Preferred Name],
	[Previous Last Name],
	[Suffix],
	[Home Address Line 1],
	[Home Address Line 2],
	[Home City],
	[Home State],
	[Home Zip Code],
	[Home County],
	[Gender],
	[Ethnicity],
	[Date of Birth],
	[Date of Death],
	[Marital Status],
	[Birthday List Exclude],
	[Proximity Card Charge],
	[Confidentiality Agreement],
	[Compliance],
	[Employee Handbook],
	[Date CHMC 403b Original Hire ],
	[Date NPP 403b Original Hire],
	[Date PTO Accrual],
	[Date Anniversary],
	[Date Seniority],
	[National Provider ID],
	[Work Email],
	[Home Email],
	[Home Mobile Phone],
	[Home Phone],
	[Pager],
	[Voalte Number],
	[Work Fax],
	[Work Mobile Phone],
	[Work Phone],
	[Disabled Veteran],
	[Active Duty Wartime or Campaign Badge Veteran],
	[Armed Forces Service Medal Veteran],
	[Recently Separated Veteran],
	[Veteran Self-Identification Status],
	[Self Disclosed Type],
	[Date Disability Start],
	[Date Disability Disclosure],
	[Accommodation Request]
)
select [Person Number],
	[First Name],
	[Middle Name],
	[Last Name],
	[Preferred Name],
	[Previous Last Name],
	[Suffix],
	[Home Address Line 1],
	[Home Address Line 2],
	[Home City],
	[Home State],
	[Home Zip Code],
	[Home County],
	[Gender],
	[Ethnicity],
	Case
		When [Date of Birth] is null or [Date of Birth] = ''
			Then null
		Else convert(datetime, [Date of Birth], 120)	
	End as [Date of Birth],
	Case
		When [Date of Death] is null or [Date of Death] = ''
			Then null
		Else convert(datetime, [Date of Death], 120)
	End as [Date of Death],
	[Marital Status],
	[Bday List Exclude],
	[Prox Card Charge],
	[Confidentiality Agreement],
	[Compliance],
	[Employee Handbook],
	Case
		When [CHMC 403b Orig Hire Date] is null or [CHMC 403b Orig Hire Date] = ''
			Then null
		Else convert(datetime, [CHMC 403b Orig Hire Date], 120)
	End as [CHMC 403b Orig Hire Date],
	Case
		When [NPP 403b Orig Hire Date] is null or [NPP 403b Orig Hire Date] = ''
			Then null
		Else convert(datetime, [NPP 403b Orig Hire Date], 120)
	End as [NPP 403b Orig Hire Date],
	Case
		When [PTO Accrual Date] is null or [PTO Accrual Date] = ''
			Then null
		Else convert(datetime, [PTO Accrual Date], 120)
	End as [PTO Accrual Date],
	Case
		When [Anniversary Date] is null or [Anniversary Date] = ''
			Then null
		Else convert(datetime, [Anniversary Date], 120)
	End as [Anniversary Date],
	Case
		When [Seniority Date] is null or [Seniority Date] = ''
			Then null
		Else convert(datetime, [Seniority Date], 120)
	End as [Seniority Date],
	[National Provider ID],
	[Work Email],
	[Personal Email],
	[Home Mobile Phone],
	[Home Phone],
	[Pager],
	[Voalte Number],
	[Work Fax],
	[Work Mobile Phone],
	[Work Phone],
	[Disable Veteran],
	[Active Duty Wartime or Campaign Badge Veteran],
	[Armed Forces Service Medal Veteran],
	[Recently Separated Veteran],
	[Veteran Self-Identification Status],
	[Self Disclosed Type],
	Case
		When [Disability Start Date] is null or [Disability Start Date] = ''
			Then null
		Else convert(datetime, [Disability Start Date], 120)
	End as [Disability Start Date],
	Case
		When [Disability Disclosure Date] is null or [Disability Disclosure Date] = ''
			Then null
		Else convert(datetime, [Disability Disclosure Date], 120)
	End as [Disability Disclosure Date],
	[Accommodation Request]
from #temp

END


GO
