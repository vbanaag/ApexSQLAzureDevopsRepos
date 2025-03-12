SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		Moroni Garcia
-- Create date: 4/16/2021
-- Description:	Data processing logic to update the CensusDataMart table
-- Changed by : Jovy Banaag 08/25/2022 - Added department ID 1061060 in Case statement per Amber's request
-- Changed by : Nagendra Pollali 05-19-2023 - Replace AgeYears and AgeDays calculations with EPIC delivered functions and AgeGroup assignment with uhc_GenericAgeGroup function.
-- =============================================
CREATE PROCEDURE [dbo].[CensusDataMart_Sp]

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	
IF OBJECT_ID('tempdb..#temp') IS NOT NULL
DROP TABLE #temp

select
 [dbo].[InitCap]([Accommodation]) as [Accommodation]
,[dbo].[InitCap]([Area]) as [Area]
,[dbo].[InitCap]([Base Class]) as [Base Class]
,[Base Class C]
,[Bed Csn Id]
,[Bed Id]
,[Bed Label]
,[Csn]
,[Date Delete]
,[Date Effective]
,[Date Event Start]
,[Date Hosp Admission]
,[Date Hosp Discharge]
,[Date of Birth]
,[dbo].[InitCap]([Department]) as [Department]
,[dbo].[InitCap]([Disposition]) as [Disposition]
,[Event Department Id]
,[Event Id]
,[Event Type C]
,[Event SubType C]
,[Event Type C In]
,[Event Type C Out]
,[dbo].[InitCap]([Event Type In]) as [Event Type In]
,[dbo].[InitCap]([Event Type Out]) as [Event Type Out]
,[dbo].[InitCap]([Financial Class]) as [Financial Class]
,[Is Admission]
,[Is Discharge]
,[Is Inpatient]
,[Is Inpatient Admission]
,[Is Inpatient less 24 hours]
,[Is Observation]
,[Is Observation Admission]
,[Is Outpatient Admission]
,[Is Patient Ed]
,[Is Patient Left Ed]
,[Is Same Day Inpatient]
,[Is Same Day Observation]
,[Is Transfer In]
,[Is Transfer out]
,[dbo].[InitCap]([Location]) as [Location]
,[Mrn]
,[dbo].[InitCap]([Patient Class]) as [Patient Class]
,[Patient Class C]
,[Patient Id]
,[dbo].[InitCap]([Patient Service]) as [Patient Service]
,[Patient Service C]
,[dbo].[InitCap]([Payor]) as [Payor]
,[dbo].[InitCap]([Plan]) as [Plan]
,[Rev Loc Id]
,[dbo].[InitCap]([Rev Loc Name]) as [Rev Loc Name]
,[Room]
,[Room Csn Id]
,[Room Id]
,[Room Name]
,[dbo].[InitCap]([Service]) as [Service]
,[Service Area Id]
,[dbo].[InitCap]([Service Area]) as [Service Area]
,[To Base Class C]
,cast(null as varchar(255)) as [Patient Age]
,cast(null as int) as [Patient Age Years] 
,cast(null as int) as [Patient Age Days] 
,cast(null as varchar(255)) as [Patient Age Group]
,[ED Disposition]

into #temp
from 
OPENQUERY([CHSCLARITY-PRD],

'
SELECT ClarAdt.EVENT_ID as [Event Id],ClarAdt.EVENT_TYPE_C as [Event Type C],AdtInt.START_DTTM as [Date Event Start],AdtInt.OUT_EVENT_TYPE_C as [Event Type C Out]
  ,AdtInt.IN_EVENT_TYPE_C as [Event Type C In],ClarAdt.EVENT_SUBTYPE_C as [Event SubType C],ClarAdt.DEPARTMENT_ID as [Event Department Id]
  ,ClarDe.DEPARTMENT_NAME as [Department],ClarAdt.ROOM_CSN_ID as[Room Csn Id],ClarAdt.BED_CSN_ID as [Bed Csn Id],ClarAdt.EFFECTIVE_TIME as [Date Effective]
  ,ClarAdt.PAT_ID as [Patient Id],ClarAdt.PAT_ENC_CSN_ID as [Csn],ClarAdt.PAT_CLASS_C	as [Patient Class C],ClarAdt.PAT_SERVICE_C as	[Patient Service C]
  ,ClarAdt.DELETE_TIME as [Date Delete],ClarAdt.BASE_PAT_CLASS_C as [Base Class C],ClarAdt.BED_ID as [Bed Id],ClarBed.BED_LABEL as [Bed Label]
  ,ClarDe.REV_LOC_ID as [Rev Loc Id],ClarLo.LOC_NAME as [Rev Loc Name],ClarDe.SERV_AREA_ID as [Service Area Id],CLARITY_SA.SERV_AREA_NAME as [Service Area]
  ,ClarAdt.ROOM_ID	as [Room Id],CLARITY_ROM.ROOM_NAME as	[Room Name],AdtInt.TO_BASE_CLASS_C as [To Base Class C],ZC_PAT_CLASS.NAME as [Patient Class]
  ,ZcPatSe.NAME as [Patient Service] ,ZcReBaCl.NAME as [Base Class],ZcEvTyOut.ABBR as [Event Type Out],ZcEvTy.ABBR as [Event Type In]
  ,PatEnHsp.HOSP_DISCH_TIME as [Date Hosp Discharge],PatEnHsp.HOSP_ADMSN_TIME as [Date Hosp Admission],Pat.BIRTH_DATE as [Date of Birth]
  ,ZcDis.NAME as [Disposition],ZcFiCl.NAME as [Financial Class],CLARITY_EPM.PAYOR_NAME as [Payor],CLARITY_EPP.BENEFIT_PLAN_NAME as	[Plan]
  ,ZcAcc.NAME as[Accommodation],pat.pat_mrn_id as Mrn
 ,Case	WHEN ClarAdt.PAT_SERVICE_C IS NULL THEN ''No Hospital Service''
	WHEN ZcPatSe.HOSP_SERV_C IS NULL THEN ''Unknown Hospital Service''
	WHEN ZcPatSe.NAME IS NULL THEN ''Unnamed Hospital Service''
	ELSE  ZcPatSe.NAME
	End as [Service]
,CASE	WHEN ClarDe.REV_LOC_ID IS NULL THEN ''No Locationt''	
	WHEN (ClarLo.LOC_ID) IS NULL THEN ''Unknown Locationt''
	WHEN (ClarLo.LOC_NAME) IS NULL THEN ''Unnamed Location''
	ELSE  ClarLo.LOC_NAME
	END as [Location]
 ,CASE	WHEN ClarAdt.ROOM_CSN_ID Is Null THEN ''No Room''
	WHEN CLARITY_ROM.ROOM_CSN_ID  Is Null THEN ''Unknown Room''
   	WHEN CLARITY_ROM.ROOM_NAME Is Null THEN ''Unnamed Room''
	ELSE CLARITY_ROM.ROOM_NAME
	END as [Room]
,Case 	When ClarAdt.EVENT_TYPE_C = 6 and ClarAdt.PAT_CLASS_C = 101 and AdtInt.END_DTTM Is Null	Then 1
  	Else 0
	End as [Is Inpatient]
,Case When ClarAdt.EVENT_TYPE_C = 6 and ClarAdt.PAT_CLASS_C = 104 and AdtInt.END_DTTM Is Null	Then 1
  	Else 0
	End as [Is Observation]
,CASE	WHEN AdtInt.IN_EVENT_TYPE_C = 1
	and AdtInt.START_DTTM <=GetDate() 	and (AdtInt.END_DTTM Is Null or AdtInt.END_DTTM > GetDate()) THEN 1
	ELSE 0
	END as [Is Admission]
,CASE	WHEN AdtInt.IN_EVENT_TYPE_C = 7 and AdtInt.START_DTTM <=GetDate() 	and (AdtInt.END_DTTM Is Null or AdtInt.END_DTTM > GetDate()) THEN 1
	ELSE 0
	END as [Is Outpatient Admission]
,CASE	WHEN AdtInt.IN_EVENT_TYPE_C = 1 and AdtInt.START_DTTM <=GetDate() and ClarAdt.PAT_CLASS_C  <> (104) 	and (AdtInt.END_DTTM Is Null or AdtInt.END_DTTM > GetDate()) THEN 1
	ELSE 0
	END as [Is Inpatient Admission]
,CASE	WHEN AdtInt.IN_EVENT_TYPE_C = 1 and AdtInt.START_DTTM <=GetDate() and ClarAdt.PAT_CLASS_C  = (104) and (AdtInt.END_DTTM Is Null or AdtInt.END_DTTM > GetDate()) THEN 1
	ELSE 0 
	END as [Is Observation Admission]
,CASE WHEN (ClarAdt.EVENT_TYPE_C =2 or (AdtInt.OUT_EVENT_TYPE_C = 4 and ClarAdt.EVENT_TYPE_C = 2)) and ClarAdt.PAT_CLASS_C  IN (104) 
	and (CASE WHEN (CONVERT(VARCHAR(10),ClarAdt.EFFECTIVE_TIME,101)) = (CONVERT(VARCHAR(10),ClarAdt.EFFECTIVE_TIME,101)) and (AdtInt.END_DTTM Is Null or AdtInt.END_DTTM > GetDate()) THEN 1
		ELSE 0
		END ) = 1
	THEN 1
	ELSE 0
	END as [Is Same Day Observation]
,CASE
	WHEN ClarAdt.EVENT_TYPE_C =2 and AdtInt.OUT_EVENT_TYPE_C =2 and ClarAdt.PAT_CLASS_C  IN (101) 
	and 
		(CASE
			WHEN (CONVERT(VARCHAR(10),ClarAdt.EFFECTIVE_TIME,101) ) = (CONVERT(VARCHAR(10),ClarAdt.EFFECTIVE_TIME,101))
			and (AdtInt.END_DTTM Is Null or AdtInt.END_DTTM > GetDate())
			THEN 1
			ELSE 0
		END ) = 1
	THEN 1
	ELSE 0
END as [Is Same Day Inpatient]
,CASE 	WHEN ClarAdt.PAT_CLASS_C  IN (101) and DATEDIFF(d,PatEnHsp.HOSP_ADMSN_TIME,PatEnHsp.HOSP_DISCH_TIME) <1 and (AdtInt.OUT_EVENT_TYPE_C = 2
	or (AdtInt.OUT_EVENT_TYPE_C = 4 and ClarAdt.EVENT_TYPE_C = 2))
		and AdtInt.START_DTTM <=GetDate()
	and (AdtInt.END_DTTM Is Null or AdtInt.END_DTTM > GetDate())
	THEN 1
	ELSE 0
END as [Is Inpatient less 24 hours]
 ,CASE WHEN (AdtInt.OUT_EVENT_TYPE_C = 2
	or (AdtInt.OUT_EVENT_TYPE_C = 4 and ClarAdt.EVENT_TYPE_C = 2))
		and AdtInt.START_DTTM <=GetDate()
	and (AdtInt.END_DTTM Is Null or AdtInt.END_DTTM > GetDate())
		THEN 1
ELSE 0
END as [Is Discharge] 
 ,CASE WHEN AdtInt.IN_EVENT_TYPE_C = 3 and AdtInt.START_DTTM <=GetDate() and (AdtInt.END_DTTM Is Null or AdtInt.END_DTTM > GetDate()) THEN 1
ELSE 0
END as [Is Transfer In]
 ,CASE
	WHEN AdtInt.OUT_EVENT_TYPE_C = 4 and AdtInt.START_DTTM <=GetDate() and (AdtInt.END_DTTM Is Null or AdtInt.END_DTTM > GetDate()) 		THEN 1
ELSE 0
END as [Is Transfer out]
,Case
	--when ClarAdt.DEPARTMENT_ID in (''1061011'',''1061012'',''1061013'',''1061014'') then ''Ms''				--Commented by Jovy Banaag 8/25/2022
	when ClarAdt.DEPARTMENT_ID in (''1061011'',''1061012'',''1061013'',''1061014'',''1061060'') then ''Ms''		--Added by Jovy Banaag 8/25/2022
	when ClarAdt.DEPARTMENT_ID in (''1061020'',''1061014'') then ''Nicu''
	when ClarAdt.DEPARTMENT_ID in (''1061040'',''1061030'') then ''Picu''
	when ClarAdt.DEPARTMENT_ID in (''1061050'') then ''Ccu''
	else ''Other''
end as [Area]
,cast(NULL as int) as [Is Patient Ed]
,cast(NULL as int) as [Is Patient Left Ed]
,ZC_ED_DISPOSITION.NAME [ED Disposition]
FROM clarity.dbo.CLARITY_BED as ClarBed 
  RIGHT JOIN clarity.dbo.CLARITY_ADT as ClarAdt ON ClarAdt.BED_CSN_ID=ClarBed.BED_CSN_ID
   LEFT JOIN clarity.dbo.PAT_ENC_HSP as PatEnHsp  ON ClarAdt.PAT_ENC_CSN_ID=PatEnHsp.PAT_ENC_CSN_ID
   LEFT JOIN clarity.dbo.ADT_INTERPRETATION as AdtInt ON ClarAdt.EVENT_ID=AdtInt.EVENT_ID
   LEFT JOIN clarity.dbo.ZC_REP_BASE_CLASS as ZcReBaCl ON AdtInt.TO_BASE_CLASS_C=ZcReBaCl.INT_REP_BASE_CLS_C
   LEFT JOIN clarity.dbo.ZC_EVENT_TYPE as ZcEvTy ON AdtInt.IN_EVENT_TYPE_C=ZcEvTy.EVENT_TYPE_C
   LEFT JOIN clarity.dbo.ZC_EVENT_TYPE as ZcEvTyOut ON AdtInt.OUT_EVENT_TYPE_C=ZcEvTyOut.EVENT_TYPE_C
   LEFT JOIN clarity.dbo.CLARITY_DEP as ClarDe ON ClarAdt.DEPARTMENT_ID=ClarDe.DEPARTMENT_ID
   LEFT JOIN clarity.dbo.CLARITY_LOC as ClarLo ON ClarDe.REV_LOC_ID=ClarLo.LOC_ID
   LEFT JOIN clarity.dbo.CLARITY_SA ON ClarDe.SERV_AREA_ID=CLARITY_SA.SERV_AREA_ID
   LEFT JOIN clarity.dbo.CLARITY_ROM ON ClarAdt.ROOM_CSN_ID=CLARITY_ROM.ROOM_CSN_ID
   LEFT JOIN clarity.dbo.PATIENT as Pat ON ClarAdt.PAT_ID=Pat.PAT_ID
   LEFT JOIN clarity.dbo.ZC_PAT_CLASS ON ClarAdt.PAT_CLASS_C=ZC_PAT_CLASS.ADT_PAT_CLASS_C
   LEFT JOIN clarity.dbo.ZC_PAT_SERVICE as ZcPatSe ON ClarAdt.PAT_SERVICE_C=ZcPatSe.HOSP_SERV_C
   LEFT JOIN clarity.dbo.ZC_DISCH_DISP as ZcDis ON PatEnHsp.DISCH_DISP_C=ZcDis.DISCH_DISP_C
   LEFT JOIN clarity.dbo.HSP_ACCOUNT as HspAcc ON PatEnHsp.HSP_ACCOUNT_ID=HspAcc.HSP_ACCOUNT_ID
   LEFT JOIN clarity.dbo.CLARITY_EPP ON HspAcc.PRIMARY_PLAN_ID=CLARITY_EPP.BENEFIT_PLAN_ID
   LEFT JOIN clarity.dbo.CLARITY_EPM ON HspAcc.PRIMARY_PAYOR_ID=CLARITY_EPM.PAYOR_ID
   LEFT JOIN clarity.dbo.ZC_FIN_CLASS as ZcFiCl ON HspAcc.ACCT_FIN_CLASS_C=ZcFiCl.FIN_CLASS_C
   LEFT JOIN clarity.dbo.ZC_ACCOMMODATION as ZcAcc ON ClarAdt.ACCOMMODATION_C=ZcAcc.ACCOMMODATION_C
   LEFT JOIN clarity.dbo.PATIENT_3 as Pat3 ON Pat3.PAT_ID=PatEnHsp.PAT_ID 
   LEFT join clarity.dbo.ZC_ED_DISPOSITION  ON PatEnHsp.ED_DISPOSITION_C=ZC_ED_DISPOSITION.ED_DISPOSITION_C
WHERE
 ClarAdt.DELETE_TIME Is Null and  
 ClarAdt.EVENT_SUBTYPE_C  <>  2 
 and ClarAdt.EFFECTIVE_TIME >= DATEADD(yy,-2, DATEADD(YY, DATEDIFF(YY,0,GETDATE()), 0)) 
 and ClarAdt.EVENT_TYPE_C <>5
 and (Pat3.IS_TEST_PAT_YN  <> ''Y'' or Pat3.IS_TEST_PAT_YN  IS NULL)
 ')
 
--------------------Flag for ED patient that get admitted to Inpatient--------------------

IF OBJECT_ID('tempdb..#EdPatAdmin') IS NOT NULL
DROP TABLE #EdPatAdmin

select a.*
into #EdPatAdmin
from 
OPENQUERY([CHSCLARITY-PRD],

 'SELECT
  PAT_ENC_HSP.PAT_ENC_CSN_ID as csn
 ,ED_IEV_EVENT_INFO.EVENT_TYPE
FROM
  clarity.dbo.PAT_ENC_HSP 
  RIGHT JOIN clarity.dbo.ED_IEV_PAT_INFO ON (PAT_ENC_HSP.PAT_ENC_CSN_ID=ED_IEV_PAT_INFO.PAT_ENC_CSN_ID)
  RIGHT JOIN clarity.dbo.ED_IEV_EVENT_INFO ON (ED_IEV_PAT_INFO.EVENT_ID=ED_IEV_EVENT_INFO.EVENT_ID)  
WHERE
  ED_IEV_EVENT_INFO.EVENT_TYPE  IN  ( ''65''  ) and ED_IEV_EVENT_INFO.EVENT_DEPT_ID = ''1036310''
   ') as a
  inner join #temp b
  on a.csn = b.csn 
 
-------Patient who came to the ED but left without being seen by provider---------

IF OBJECT_ID('tempdb..#EdNoProv') IS NOT NULL
DROP TABLE #EdNoProv

select a.*
into #EdNoProv
from 
OPENQUERY([CHSCLARITY-PRD],

'SELECT  
  PAT_ENC_HSP.PAT_ENC_CSN_ID as csn
 ,PAT_ENC_HSP.ED_DISPOSITION_C
 ,ZC_ED_DISPOSITION.NAME
 ,PAT_ENC_HSP.ED_DEPARTURE_TIME
 FROM
  clarity.dbo.PATIENT
  RIGHT OUTER JOIN clarity.dbo.PAT_ENC_HSP ON (PATIENT.PAT_ID=PAT_ENC_HSP.PAT_ID)
  RIGHT OUTER JOIN clarity.dbo.ZC_ED_DISPOSITION ON (PAT_ENC_HSP.ED_DISPOSITION_C=ZC_ED_DISPOSITION.ED_DISPOSITION_C)
  WHERE PAT_ENC_HSP.ED_DISPOSITION_C in (6,7) '
  ) as a
  inner join #temp b
  on a.csn = b.csn 

------------------Updating ED Flags-------------------

update a 
set a.[Is Patient Ed] = 1
from #temp a
inner join #EdPatAdmin b
ON a.Csn = b.csn

update #temp
set [Is Patient Ed] = 0
where [Is Patient Ed] is null

update a 
set a.[Is Patient Left Ed] = 1
from #temp a
inner join #EdNoProv b
ON a.Csn = b.csn

update #temp
set [Is Patient Left Ed] = 0
where [Is Patient Left Ed] is null

----------------Updating Age fields--------------

IF OBJECT_ID('tempdb..#Age') IS NOT NULL
DROP TABLE #Age

select a.*
into #Age
from 
OPENQUERY([CHSCLARITY-PRD],
 'select distinct  
  Pat.PAT_ID as [Patient Id]
 ,Case 
	WHEN Clarity.EPIC_UTIL.EFN_DATEDIFF(''ageyears'',Pat.BIRTH_DATE,PatEnHsp.HOSP_ADMSN_TIME) < 1  and 
            Clarity.EPIC_UTIL.EFN_DATEDIFF(''agemonths'',Pat.BIRTH_DATE,PatEnHsp.HOSP_ADMSN_TIME) < 1 and 
            Clarity.EPIC_UTIL.EFN_DATEDIFF(''ageweeks'',Pat.BIRTH_DATE,PatEnHsp.HOSP_ADMSN_TIME) < 1
	THEN str(Clarity.EPIC_UTIL.EFN_DATEDIFF(''agedays'',Pat.BIRTH_DATE,PatEnHsp.HOSP_ADMSN_TIME)) + '' Days'' 

	WHEN Clarity.EPIC_UTIL.EFN_DATEDIFF(''ageyears'',Pat.BIRTH_DATE,PatEnHsp.HOSP_ADMSN_TIME) < 1  and 
            Clarity.EPIC_UTIL.EFN_DATEDIFF(''agemonths'',Pat.BIRTH_DATE,PatEnHsp.HOSP_ADMSN_TIME) <1
	THEN str(Clarity.EPIC_UTIL.EFN_DATEDIFF(''ageweeks'',Pat.BIRTH_DATE,PatEnHsp.HOSP_ADMSN_TIME)) + '' Weeks''

	WHEN Clarity.EPIC_UTIL.EFN_DATEDIFF(''ageyears'',Pat.BIRTH_DATE,PatEnHsp.HOSP_ADMSN_TIME) < 1 
	THEN Str(Clarity.EPIC_UTIL.EFN_DATEDIFF(''agemonths'',Pat.BIRTH_DATE,PatEnHsp.HOSP_ADMSN_TIME)) + '' Mnths''

ELSE Str(Clarity.EPIC_UTIL.EFN_DATEDIFF(''ageyears'',Pat.BIRTH_DATE,PatEnHsp.HOSP_ADMSN_TIME)) + '' Yrs''
END as [Patient Age]

FROM 
Clarity.dbo.PAT_ENC_HSP PatEnHsp
left join Clarity.dbo.PATIENT as Pat 
ON PatEnHsp.PAT_ID=Pat.PAT_ID'
) as a
inner join #temp b
on a.[Patient Id]=b.[Patient Id]

/* Replace AgeYears, AgeDays AgeGroup Cal: PNBEG1
--Updating Age and age groups
update a 
set a.[Patient Age] = b.[Patient Age]
from #temp a
inner join #Age b 
ON a.[Patient Id] = b.[Patient Id]

update #temp
set [Patient Age Years] = 
datediff(yy,[Date of Birth],[Date Hosp Admission]) - 
 case 
       when dateadd(yy,datediff(yy,[Date of Birth],[Date Hosp Admission]),[Date of Birth])>[Date Hosp Admission] then 1
else 0 end

update #temp
set [Patient Age Years] = 0
where [Patient Age Years] = -1

--Calculating age in days
update #temp
set [Patient Age Days] = DATEDIFF(dd,[Date of Birth],[Date Hosp Admission])

update m
set m.[Patient Age Group] =
case 
	when cast([Patient Age Days] as int) between 0 and 28 then '0-28 days'
	when cast([Patient Age Days] as int) between 29 and 365 then '29-365 days'
end 
from #temp m
where [Patient Age Years] = 0

update m
set m.[Patient Age Group] =
case
	when [Patient Age Years] between 1 and 4 then '1-4 yrs'
	when [Patient Age Years] between 5 and 9 then '5-9 yrs'
	when [Patient Age Years] between 10 and 14 then '10-14 yrs'
	when [Patient Age Years] between 15 and 17 then '15-17 yrs'
	when [Patient Age Years] >17 then '>=18 yrs'
end
from #temp m
where cast([Patient Age Years] as int) > 0
PNEND1*/


--Calculating age in years
update #temp
set [Patient Age Years] = CareTransform_Epic.dbo.efn_datediff('Ageyears',[Date of Birth],[Date Hosp Admission])

--Calculating age in days
update #temp
set [Patient Age Days] = CareTransform_Epic.dbo.efn_datediff('Agedays',[Date of Birth],[Date Hosp Admission])

--Assign AgeGroup
alter table #temp
alter column [Patient Age Group] varchar(50)

update m
set m.[Patient Age Group] = CareTransform_Epic.dbo.ufn_ChsGenericAgeGroup([Patient Age Days],[Patient Age Years])
from #temp m

-----------------------------------------

truncate table [dbo].[CensusDataMart]

insert into [dbo].[CensusDataMart]
(
 [Accommodation]
,[Area]
,[Base Class]
,[Base Class C]
,[Bed Csn Id]
,[Bed Id]
,[Bed Label]
,[Csn]
,[Date Delete]
,[Date Effective]
,[Date Event Start]
,[Date Hosp Admission]
,[Date Hosp Discharge]
,[Date of Birth]
,[Department]
,[Disposition]
,[Event Department Id]
,[Event Id]
,[Event Type C]
,[Event SubType C]
,[Event Type C In]
,[Event Type C Out]
,[Event Type In]
,[Event Type Out]
,[Financial Class]
,[Is Admission]
,[Is Discharge]
,[Is Inpatient]
,[Is Inpatient Admission]
,[Is Inpatient less 24 hours]
,[Is Observation]
,[Is Observation Admission]
,[Is Outpatient Admission]
,[Is Patient Ed]
,[Is Patient Left Ed]
,[Is Same Day Inpatient]
,[Is Same Day Observation]
,[Is Transfer In]
,[Is Transfer out]
,[Location]
,[Mrn]
,[Patient Age]
,[Patient Age Years]
,[Patient Age Days]
,[Patient Age Group]
,[Patient Class]
,[Patient Class C]
,[Patient Id]
,[Patient Service]
,[Patient Service C]
,[Payor]
,[Plan]
,[Rev Loc Id]
,[Rev Loc Name]
,[Room]
,[Room Csn Id]
,[Room Id]
,[Room Name]
,[Service]
,[Service Area Id]
,[Service Area]
,[To Base Class C]
,[ED Disposition]
)
select 
[Accommodation]
,[Area]
,[Base Class]
,[Base Class C]
,[Bed Csn Id]
,[Bed Id]
,[Bed Label]
,[Csn]
,[Date Delete]
,[Date Effective]
,[Date Event Start]
,[Date Hosp Admission]
,[Date Hosp Discharge]
,[Date of Birth]
,[Department]
,[Disposition]
,[Event Department Id]
,[Event Id]
,[Event Type C]
,[Event SubType C]
,[Event Type C In]
,[Event Type C Out]
,[Event Type In]
,[Event Type Out]
,[Financial Class]
,[Is Admission]
,[Is Discharge]
,[Is Inpatient]
,[Is Inpatient Admission]
,[Is Inpatient less 24 hours]
,[Is Observation]
,[Is Observation Admission]
,[Is Outpatient Admission]
,[Is Patient Ed]
,[Is Patient Left Ed]
,[Is Same Day Inpatient]
,[Is Same Day Observation]
,[Is Transfer In]
,[Is Transfer out]
,[Location]
,[Mrn]
,[Patient Age]
,[Patient Age Years]
,[Patient Age Days]
,[Patient Age Group]
,[Patient Class]
,[Patient Class C]
,[Patient Id]
,[Patient Service]
,[Patient Service C]
,[Payor]
,[Plan]
,[Rev Loc Id]
,[Rev Loc Name]
,[Room]
,[Room Csn Id]
,[Room Id]
,[Room Name]
,[Service]
,[Service Area Id]
,[Service Area]
,[To Base Class C]
,[ED Disposition]
from  #temp


END
GO
