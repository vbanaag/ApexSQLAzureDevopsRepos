SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		<Moroni Garcia>
-- Create date: <2-15-2021>
-- Description:	<Main Sp to populate encounters datamart>
-- Changed by : Jovy Banaag 01/11/2022 - Added Case statement in Openquery for Telehealth All per Amber's request
-- Changed by : Jovy Banaag 04/21/2022 - Added code to update provider names with provider names from DimProvider tables
-- Changed by : Nagendra Pollali 05-19-2023 - Replace AgeYears and AgeDays calculations with EPIC delivered functions and AgeGroup assignment with uhc_GenericAgeGroup function.
-- =============================================
CREATE PROCEDURE  [dbo].[EncountersDataMart_Sp]
	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

   
IF OBJECT_ID('tempdb..#temp') IS NOT NULL
    DROP TABLE #temp

select 
 [Csn]
,[Pat Id]--used to link to Patient Demographics not for display
,[Contact Date]
,[Enc Type Id] --used to create filters not for display
,dbo.InitCap([Enc Type]) as [Enc Type]
,dbo.InitCap([Enc PCP Prov]) as [Enc PCP Prov]
,dbo.InitCap([Enc Prov Name]) as [Enc Prov Name]
,dbo.InitCap([Enc Prov Type]) as [Enc Prov Type]
,dbo.InitCap([Enc Prov Specialty]) as [Enc Prov Specialty]
,[Enc Prov NPI]
,[Enc Prov Title]
,dbo.InitCap([Enc Department]) as [Enc Department]
,dbo.InitCap([Enc Dept Area Grp]) as [Enc Dept Area Grp]
,dbo.InitCap([Enc Dept SPC Outreach Grp]) as [Enc Dept SPC Outreach Grp]
,dbo.InitCap([Enc Dept Specialty]) as [Enc Dept Specialty]
,cast([Enc Close Date] as date) as [Enc Close Date]

,cast(NULL as int) as [Pat Age Years]			 
,cast(NULL as int) as [Pat Age Days]				 
,cast(NULL as varchar(255)) as [Pat Age Group]			  
,cast(NULL as int) as [Pat Age Group Index]	

,cast([Date of Birth] as date) as [Date of Birth]

,[Appt Status Id] --used to create filters not for display
,dbo.InitCap([Appt Status]) as [Appt Status]
,cast([Appt Time] as date) as [Appt Time]
,[Appt Length]
,cast([Appt Date] as date) as [Appt Date]
,[App Prc Id] --used to create filters not for display
,dbo.InitCap([Appt Name]) as [Appt Name]
,cast([Appt Check in Time] as date) as [Appt Check in Time]
,[Appt Check in Hour]
,cast([Appt Check out Time] as date) as [Appt Check out Time]
,cast([Appt Cancel Date] as date) as [Appt Cancel Date]
,dbo.InitCap([Appt Cancel Reason Name]) as [Appt Cancel Reason Name] 
,[Hosp Account Id]
,[Inpatient Data Id] --used to link to Flowsheet rows not for display
,dbo.InitCap([Referring Prov]) as [Referring Prov]
,dbo.InitCap([Referring Prov Dept]) as [Referring Prov Dept]  
,dbo.InitCap([Referring Prov Specialty]) as [Referring Prov Specialty]
,dbo.InitCap([Enc Reason]) as [Enc Reason]
,dbo.InitCap([Lead Visit Class]) as [Lead Visit Class]
,dbo.InitCap([Lead Visit Enc Reason]) as [Lead Visit Enc Reason]
,[Appt Time Hour]
,[Enc Department Id]
,[Enc Prov Id]

-----------------------------------------------------------------------------------
---------------------FLAGS--------------------------------------------------------
,[Is Referring Prov Epicare]
,[Is Appt Research]
,[Is Enc Closed]
,[Is New Patient Visit]
,[Is Telehealth Visit]
,[Is Telehealth]  --Added by Jovy Banaag 1/11/2022
,[Is No Show]
,[Is Face to Face]
,[Is Deliquency Face to Face]
,[Is Telephone]
,[Is Canceled No Show]
,[Is AVS Printed]
,[Is AVS Refused]
,[Is Closed Same Day]
,[Is Multi Day]
,[Is Lead Visit]
,[Is Mchat Visit]


into #temp
from 
OPENQUERY([CHSCLARITY-PRD],

--IF OBJECT_ID('tempdb..#ENCOUNTER') IS NOT NULL
--    DROP TABLE #ENCOUNTER
'SELECT DISTINCT
   PAT_ENC.PAT_ENC_CSN_ID as [Csn]
  ,PAT_ENC.PAT_ID as [Pat Id]
  ,cast(PAT_ENC.CONTACT_DATE as date) as [Contact Date] 
  ,PAT_ENC.ENC_TYPE_C as [Enc Type Id]
  ,ZC_DISP_ENC_TYPE.NAME as [Enc Type]
  ,dbo_CLARITY_SER_EncPCP.PROV_NAME as [Enc PCP Prov]
  ,CLARITY_SER.PROV_NAME as [Enc Prov Name]
  ,CLARITY_SER.PROV_TYPE as [Enc Prov Type]
  ,ZC_SPECIALTY_VisitProv.NAME as [Enc Prov Specialty]
  ,CLARITY_SER_2.NPI as [Enc Prov NPI]
  ,CLARITY_SER.CLINICIAN_TITLE as [Enc Prov Title]
  ,CLARITY_DEP.DEPARTMENT_NAME as [Enc Department]
  ,CLARITY_DEP.RPT_GRP_TWO as [Enc Dept Area Grp]
  ,CLARITY_DEP.RPT_GRP_THREE as [Enc Dept SPC Outreach Grp]
  ,CLARITY_DEP.SPECIALTY as [Enc Dept Specialty] 
  ,PAT_ENC.ENC_CLOSE_DATE as [Enc Close Date]
  ,PAT_ENC.APPT_STATUS_C as [Appt Status Id] 
  ,ZC_APPT_STATUS.NAME as [Appt Status]
  ,PAT_ENC.APPT_TIME as [Appt Time]
  ,PAT_ENC.APPT_LENGTH as [Appt Length]
  ,PAT_ENC.APPT_MADE_DATE as [Appt Date]
  ,PAT_ENC.APPT_PRC_ID as [App Prc Id]
  ,CLARITY_PRC.PRC_NAME as [Appt Name]
  ,PAT_ENC.CHECKIN_TIME as [Appt Check in Time]
  ,datepart(hh,PAT_ENC.CHECKIN_TIME) as [Appt Check in Hour]
  ,PAT_ENC.CHECKOUT_TIME as [Appt Check out Time]
  ,PAT_ENC.APPT_CANCEL_DATE as [Appt Cancel Date]
  ,ZC_CANCEL_REASON.NAME as [Appt Cancel Reason Name]  
  ,PAT_ENC.HSP_ACCOUNT_ID as [Hosp Account Id]
  ,PAT_ENC.INPATIENT_DATA_ID as [Inpatient Data Id]
  ,REFERRAL_SOURCE.REFERRING_PROV_NAM as [Referring Prov]
  ,DEP_ReferralSrc.DEPARTMENT_NAME as [Referring Prov Dept]  
  ,ZC_SPECIALTY.NAME as [Referring Prov Specialty]
  ,RSN_VISIT.ENC_REASON_NAME as [Enc Reason]
   ----------FLAGS-------------
,case
	when SER_ReferralSrc.EPICCARE_PROV_YN in (''Y'') then 1
	Else 0
 End as [Is Referring Prov Epicare]
,Case
	when PAT_ENC_3.APPT_RESCH_YN in (''Y'') then 1
	Else 0
 End as [Is Appt Research]
,Case
	when PAT_ENC.ENC_CLOSED_YN in (''Y'') 
	then 1
	Else 0
 End as [Is Enc Closed]
,CASE --NEW PATIENT VISIT
	WHEN CLARITY_PRC.PRC_NAME LIKE ''%NEW%'' 
	AND PAT_ENC.APPT_PRC_ID <> ''1045''        
	AND (PAT_ENC.ENC_TYPE_C=50 OR PAT_ENC.ENC_TYPE_C=101 OR PAT_ENC.ENC_TYPE_C=3)        
	AND (PAT_ENC.APPT_STATUS_C=2 OR PAT_ENC.APPT_STATUS_C=6)        
	THEN 1
 else 0
 END AS [Is New Patient Visit]
,CASE --TELEHEALTH
 WHEN BENEFIT_GROUP_C in (''10904'',''10903'')    
	AND (PAT_ENC.ENC_TYPE_C in (3,49,50,51,55,101,201,1003,2105,2533,2535,2520,2537,76))          
	AND (PAT_ENC.APPT_STATUS_C=2 OR PAT_ENC.APPT_STATUS_C=6)        
	THEN 1
 Else 0
 END AS [Is Telehealth Visit]
 ,CASE --TELEHEALTH ALL
WHEN BENEFIT_GROUP_C in (''10904'',''10903'')    
       AND (PAT_ENC.ENC_TYPE_C in (3,49,50,51,55,101,201,1003,2105,2533,2535,2520,2537,76))      
THEN 1
Else 0
END AS [Is Telehealth]
,CASE --NO SHOW
	WHEN PAT_ENC.APPT_STATUS_C = 4 
	THEN 1 
 Else 0
 END as [Is No Show]
,CASE -- FACE TO FACE
	WHEN PAT_ENC.ENC_TYPE_C IN (3,49,50,51,55,101,201,1003,2105,2533,2535,2520,2537,76)
	AND PAT_ENC.APPT_STATUS_C IN (2,6,7)
	THEN 1
 Else 0
 END as [Is Face to Face]

,CASE -- DELIQUENCY FACE TO FACE
	WHEN PAT_ENC.ENC_TYPE_C IN (101,2537,201,2101,2105,2522,2533)
	AND PAT_ENC.APPT_STATUS_C IN (2,6,7)
	THEN 1
 Else 0
 END as [Is Deliquency Face to Face]

,CASE -- TELEPHONE
	WHEN PAT_ENC.ENC_TYPE_C=70
	THEN 1
 Else 0
 END AS [Is Telephone]
,CASE --CANCELED NO SHOW
	WHEN (V_SCHED_APPT.APPT_CANC_DTTM > DATEADD(hh,-1,PAT_ENC.APPT_TIME)) 
	AND 
	PAT_ENC.CANCEL_REASON_C in (''1'',''29'',''22'',''5'',''8'',''24'',''10'',''26'',''28'',''12'',''30'',''32'',''34'',''35'',''36'',''37'',''38'')
	THEN 1
 Else 0
 END as [Is Canceled No Show]
,CASE -- AVS Printed
	WHEN (Datediff(D,PAT_ENC.AVS_PRINT_TM,PAT_ENC.CONTACT_DATE) <=3) 
	THEN 1
 Else 0
 END as [Is AVS Printed]
,CASE -- AVS Refused
	WHEN (datediff(day,PAT_ENC_2.AVS_REFUSED_DTTM,PAT_ENC.CONTACT_DATE) <=3) 
	THEN 1 
 Else 0
 END as [Is AVS Refused]
,CASE -- Broke down to two different flag columns 
	WHEN PAT_ENC.CONTACT_DATE = PAT_ENC.ENC_CLOSE_DATE
	THEN 1
 Else 0	 
 END as [Is Closed Same Day]
,CASE -- Broke down to two different flag columns 
	WHEN PAT_ENC.CONTACT_DATE <> PAT_ENC.ENC_CLOSE_DATE
	THEN 1
 Else 0	 
 END as [Is Multi Day]
,CASE 
	WHEN ENC_REASON_NAME like ''%YEAR WELL CHECK'' 
	or ENC_REASON_NAME like ''KINDERGARTEN%'' 
	or ENC_REASON_ID = 212
	THEN ENC_REASON_NAME
	ELSE ''Other''
 END as [Lead Visit Enc Reason]
,CASE
	WHEN RSN_VISIT.ENC_REASON_NAME like ''%YEAR WELL CHECK'' 
	or RSN_VISIT.ENC_REASON_NAME like ''KINDERGARTEN%''
	THEN 1
 Else 0
 END AS [Is Lead Visit]
,CASE
	WHEN ENC_REASON_ID = 212 OR ENC_REASON_ID = 213 OR ENC_REASON_ID = 741
	THEN 1
 Else 0
 END as [Is Mchat Visit]
,CASE
	WHENENC_REASON_ID = 212	
	THEN ''18 Month''
	WHEN ENC_REASON_ID = 213 OR ENC_REASON_ID = 741
	THEN ''2 Year''
	ELSE ''Other''
 END as [Lead Visit Class]
,PATIENT.BIRTH_DATE as [Date of Birth]
,Datepart(HH,APPT_TIME) as [Appt Time Hour]
,PAT_ENC.DEPARTMENT_ID [Enc Department Id]
,PAT_ENC.VISIT_PROV_ID as [Enc Prov Id]

FROM
  clarity.dbo.PAT_ENC 
  LEFT JOIN clarity.dbo.CLARITY_DEP ON (PAT_ENC.DEPARTMENT_ID=CLARITY_DEP.DEPARTMENT_ID)
 RIGHT JOIN clarity.dbo.PATIENT ON (PATIENT.PAT_ID=PAT_ENC.PAT_ID)
  LEFT JOIN clarity.dbo.PATIENT_3  ON (PATIENT_3.PAT_ID=PATIENT.PAT_ID)
  LEFT JOIN clarity.dbo.CLARITY_SER ON (CLARITY_SER.PROV_ID=PAT_ENC.VISIT_PROV_ID)
  LEFT JOIN clarity.dbo.ZC_DISP_ENC_TYPE ON (PAT_ENC.ENC_TYPE_C=ZC_DISP_ENC_TYPE.DISP_ENC_TYPE_C)
  LEFT JOIN clarity.dbo.CLARITY_PRC ON (CLARITY_PRC.PRC_ID=PAT_ENC.APPT_PRC_ID)
  LEFT JOIN clarity.dbo.CLARITY_SER_2 ON (CLARITY_SER_2.PROV_ID=PAT_ENC.VISIT_PROV_ID)
  LEFT JOIN clarity.dbo.CLARITY_SER_SPEC  dbo_CLARITY_SER_SPEC_VisitProv ON (dbo_CLARITY_SER_SPEC_VisitProv.PROV_ID=PAT_ENC.VISIT_PROV_ID and dbo_CLARITY_SER_SPEC_VisitProv.LINE = 1 or dbo_CLARITY_SER_SPEC_VisitProv.LINE Is Null )
  LEFT JOIN clarity.dbo.ZC_SPECIALTY  ZC_SPECIALTY_VisitProv ON (ZC_SPECIALTY_VisitProv.SPECIALTY_C=dbo_CLARITY_SER_SPEC_VisitProv.SPECIALTY_C)
  LEFT JOIN clarity.dbo.ZC_APPT_STATUS ON (PAT_ENC.APPT_STATUS_C=ZC_APPT_STATUS.APPT_STATUS_C)
  LEFT JOIN clarity.dbo.CLARITY_SER  dbo_CLARITY_SER_EncPCP ON (dbo_CLARITY_SER_EncPCP.PROV_ID=PAT_ENC.PCP_PROV_ID)
  LEFT JOIN clarity.dbo.REFERRAL_SOURCE ON (REFERRAL_SOURCE.REFERRING_PROV_ID=PAT_ENC.REFERRAL_SOURCE_ID)
  LEFT JOIN clarity.dbo.CLARITY_SER  SER_ReferralSrc ON (REFERRAL_SOURCE.REFERRING_PROV_ID=SER_ReferralSrc.PROV_ID)
  LEFT JOIN clarity.dbo.CLARITY_SER_2  SER2_ReferralSrc ON (SER_ReferralSrc.PROV_ID=SER2_ReferralSrc.PROV_ID)
  LEFT JOIN clarity.dbo.CLARITY_DEP  DEP_ReferralSrc ON (SER2_ReferralSrc.PRIMARY_DEPT_ID=DEP_ReferralSrc.DEPARTMENT_ID)
  LEFT JOIN clarity.dbo.CLARITY_SER_SPEC ON (SER_ReferralSrc.PROV_ID=CLARITY_SER_SPEC.PROV_ID and CLARITY_SER_SPEC.LINE = 1 or CLARITY_SER_SPEC.LINE Is Null )
  LEFT JOIN clarity.dbo.ZC_SPECIALTY ON (CLARITY_SER_SPEC.SPECIALTY_C=ZC_SPECIALTY.SPECIALTY_C)
  LEFT JOIN clarity.dbo.ZC_CANCEL_REASON ON (PAT_ENC.CANCEL_REASON_C=ZC_CANCEL_REASON.CANCEL_REASON_C)
  LEFT JOIN clarity.dbo.PAT_ENC_RSN_VISIT RSN_VISIT on RSN_VISIT.PAT_ENC_CSN_ID=PAT_ENC.PAT_ENC_CSN_ID and RSN_VISIT.LINE=1
  LEFT JOIN clarity.dbo.V_SCHED_APPT on V_SCHED_APPT.PAT_ENC_CSN_ID = PAT_ENC.PAT_ENC_CSN_ID
  LEFT JOIN clarity.dbo.PAT_ENC_3 ON PAT_ENC_3.PAT_ENC_CSN = PAT_ENC.PAT_ENC_CSN_ID
  LEFT JOIN clarity.dbo.PAT_ENC_2 on PAT_ENC_2.PAT_ENC_CSN_ID = PAT_ENC.PAT_ENC_CSN_ID
  LEFT JOIN clarity.dbo.CLARITY_PRC_2 ON CLARITY_PRC.PRC_ID=CLARITY_PRC_2.PRC_ID
			
WHERE
(PATIENT_3.IS_TEST_PAT_YN Is Null OR PATIENT_3.IS_TEST_PAT_YN <> ''Y'' )

AND

(PAT_ENC.ENC_CLOSE_DATE >= DATEADD(dd,-20,GETDATE()) 
 OR PAT_ENC.CONTACT_DATE >= DATEADD(dd,-20,GETDATE()) )
--PAT_ENC.CONTACT_DATE >=''1/1/2020''
   
  '
   )
  
----------------------Updating Provider Names using values in Dim Provider table-----------------
update a								-- Added by Jovy Banaag 4/21/2022
set a.[Enc PCP Prov] = b.[Provider]
from  #temp a 
inner join [dbo].[DimProvider] b
ON a.[Enc Prov Id] = b.[Provider Id]

update a                                -- Added by Jovy Banaag 4/21/2022
set a.[Enc Prov Name] = b.[Provider]
from  #temp a 
inner join [dbo].[DimProvider] b
ON a.[Enc Prov Id] = b.[Provider Id]


--////////////////////////// ****** Updating other columns ******//////////////////////////////
/* Replace AgeYears, AgeDays AgeGroup Cal: PNBEG1
--Calculating age in years

update #temp
set [Pat Age Years] = 
datediff(yy,[Date of Birth],[Contact Date] ) - 
case 
    when dateadd(yy,datediff(yy,[Date of Birth],[Contact Date] ),[Date of Birth]) > [Contact Date] then 1
else 0 end

update #temp
set [Pat Age Years] = 0
where [Pat Age Years] = -1

--Calculating age in days
update #temp
set [Pat Age Days] = DATEDIFF(dd,[Date of Birth],[Contact Date] )

update m
set m.[Pat Age Group] =
case 
when cast([Pat Age Days] as int) between 0 and 28 then '0-28 days'
when cast([Pat Age Days] as int) between 29 and 365 then '29-365 days'
end 
from #temp m
where [Pat Age Years] = 0

update m
set m.[Pat Age Group] =
case
when [Pat Age Years] between 1 and 4 then '1-4 yrs'
when [Pat Age Years] between 5 and 9 then '5-9 yrs'
when [Pat Age Years] between 10 and 14 then '10-14 yrs'
when [Pat Age Years] between 15 and 17 then '15-17 yrs'
when [Pat Age Years] > 17 then '>=18 yrs'
end
from #temp m
where cast([Pat Age Years] as int) > 0
PNEND1*/

--Calculating age in years
update #temp
set [Pat Age Years] = CareTransform_Epic.dbo.efn_datediff('Ageyears',[Date of Birth],[Contact Date])

--Calculating age in days
update #temp
set [Pat Age Days] = CareTransform_Epic.dbo.efn_datediff('Agedays',[Date of Birth],[Contact Date])

--Assign AgeGroup
alter table #temp
alter column [Pat Age Group] varchar(50)

update m
set m.[Pat Age Group] = CareTransform_Epic.dbo.ufn_ChsGenericAgeGroup([Pat Age Days],[Pat Age Years])
from #temp m


update #temp
set [Pat Age Group Index] = 
case 
when [Pat Age Group] in ('0-28 days') then 1 
when [Pat Age Group] in ('29-365 days') then 2
when [Pat Age Group] in ('1-4 yrs') then 3 
when [Pat Age Group] in ('5-9 yrs') then 4 
when [Pat Age Group] in ('10-14 yrs') then 5
when [Pat Age Group] in ('15-17 yrs') then 6
when [Pat Age Group] in ('>=18 yrs') then 7
end 

------------------Deleting old data from datamart before inserting new data ----------------------
delete a
from dbo.EncountersDataMart a
inner join #temp b
ON a.[Contact Date] = b.[Contact Date] and a.[Csn] = b.[Csn] 


--alter table dbo.EncountersDataMart
--add [Is Telehealth] varchar(255) NULL

--truncate table dbo.EncountersDataMart
--select count(*) from dbo.EncountersDataMart
-------------------------------------------------------------------------------------------------

--Inserting data into datamart

insert into dbo.EncountersDataMart
(
 [Csn]                         
,[Pat Id]					   
,[Contact Date] 			   
,[Enc Type Id] 				   
,[Enc Type]					   
,[Enc PCP Prov]				   
,[Enc Prov Name]			   
,[Enc Prov Type]			   
,[Enc Prov Specialty]		   
,[Enc Prov NPI]				   
,[Enc Prov Title]
,[Enc Department]			   
,[Enc Dept Area Grp]		   
,[Enc Dept SPC Outreach Grp]   
,[Enc Dept Specialty] 		   
,[Enc Close Date]			   
,[Pat Age Years]			   
,[Pat Age Days]				   
,[Pat Age Group]			   
,[Pat Age Group Index]		   
,[Appt Status Id] 			   
,[Appt Status]				   
,[Appt Time]				   
,[Appt Length]				   
,[Appt Date]				   
,[App Prc Id] 				   
,[Appt Name]				   
,[Appt Check in Time]		   
,[Appt Check in Hour]		   
,[Appt Check out Time]		   
,[Appt Cancel Date]			   
,[Appt Cancel Reason Name]	   
,[Hosp Account Id]			   
,[Inpatient Data Id] 		   
,[Referring Prov]			   
,[Referring Prov Dept]		   
,[Is Referring Prov Epicare]   
,[Referring Prov Specialty]	   
,[Enc Reason]				   
,[Is Mchat Visit]				   
,[Lead Visit Class]			   
,[Lead Visit Enc Reason]	   
,[Is Appt Research]	           
,[Is Enc Closed]			   
,[Is New Patient Visit]		   
,[Is Telehealth Visit]	
,[Is Telehealth]  --Added by Jovy Banaag 1/11/2022
,[Is No Show]				   
,[Is Face to Face]			   
,[Is Deliquency Face to Face]  
,[Is Telephone]				   
,[Is Canceled No Show]		   
,[Is AVS Printed]			   
,[Is AVS Refused]			   
,[Is Closed Same Day]		   
,[Is Multi Day]				   
,[Is Lead Visit]	
,[Appt Time Hour]
,[Enc Department Id]
,[Enc Prov Id]
)
select 
 [Csn]                         
,[Pat Id]					   
,[Contact Date] 			   
,[Enc Type Id] 				   
,[Enc Type]					   
,[Enc PCP Prov]				   
,[Enc Prov Name]			   
,[Enc Prov Type]			   
,[Enc Prov Specialty]		   
,[Enc Prov NPI]				   
,[Enc Prov Title]
,[Enc Department]			   
,[Enc Dept Area Grp]		   
,[Enc Dept SPC Outreach Grp]   
,[Enc Dept Specialty] 		   
,[Enc Close Date]			   
,[Pat Age Years]			   
,[Pat Age Days]				   
,[Pat Age Group]			   
,[Pat Age Group Index]		   
,[Appt Status Id] 			   
,[Appt Status]				   
,[Appt Time]				   
,[Appt Length]				   
,[Appt Date]				   
,[App Prc Id] 				   
,[Appt Name]				   
,[Appt Check in Time]		   
,[Appt Check in Hour]		   
,[Appt Check out Time]		   
,[Appt Cancel Date]			   
,[Appt Cancel Reason Name]	   
,[Hosp Account Id]			   
,[Inpatient Data Id] 		   
,[Referring Prov]			   
,[Referring Prov Dept]		   
,[Is Referring Prov Epicare]   
,[Referring Prov Specialty]	   
,[Enc Reason]				   
,[Is Mchat Visit]				   
,[Lead Visit Class]			   
,[Lead Visit Enc Reason]	   
,[Is Appt Research]	           
,[Is Enc Closed]			   
,[Is New Patient Visit]		   
,[Is Telehealth Visit]
,[Is Telehealth]  --Added by Jovy Banaag 1/11/2022
,[Is No Show]				   
,[Is Face to Face]			   
,[Is Deliquency Face to Face]  
,[Is Telephone]				   
,[Is Canceled No Show]		   
,[Is AVS Printed]			   
,[Is AVS Refused]			   
,[Is Closed Same Day]		   
,[Is Multi Day]				   
,[Is Lead Visit]
,[Appt Time Hour]
,[Enc Department Id]
,[Enc Prov Id]

from #temp

-- Deleting data oldr than two years
delete dbo.EncountersDataMart
where Year([Contact Date]) < YEAR(GETDATE())-3

END
GO
