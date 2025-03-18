SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Moroni Garcia>
-- Create date: <02-12-2021>
-- Description:	<Full Update>
-- Changed by : Jovy Banaag 7-22-2022 - Code change to add gender fields per Amber; changed text fields to Pascal case
-- Changed by : Jovy Banaag 3-12-2025 - Added this line for code change to test GitHub source control
-- =============================================
CREATE PROCEDURE [dbo].[DimPatient_Sp] 
	-- Add the parameters for the stored procedure here
	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

-- Truncating table before update
Truncate table [dbo].[DimPatient]

-- Updating table
insert into [dbo].[DimPatient]
(
 [Id]
,[Mrn]
,[Name]
,[Last Name]
,[First Name]
,[Middle Name]
,[Address 1]
,[Address 2]
,[City]
,[State]
,[County]
,[Country]
,[Zip]
,[Home Phone]
,[Work Phone]
,[Other Phone]
,[Email]
,[No Email Reason]
,[Birth Date]
,[Ethnicity]
,[Religion]
,[Language]
,[Sex]
,[Race]
,[Cur PCP Name]
,[Cur PCP Dept]
,[Cur PCP Dept Area Group]
,[Deceased Date]
,[Birth Labor]
,[Hosp Days]
,[Born Hosp Name]
,[Born Hosp Location]
,[Meds Last Review Time]
,[Meds Last Review User]
,[Allergey Update Date]
,[Allergy Update User]
,[Birth Lenght]
,[Birth Weight]
,[Birth Head Cir]
,[Disch Weight]
,[Apgar 1]
,[Apgar 5]
,[Apgar 10]
,[Gest Age]
,[Gest Age Days]
,[Is Test Patient]
,[MyChart Status]
,[Gender Identity]														-- Added by Jovy Banaag 7/22/2022
,[Gender]																-- Added by Jovy Banaag 7/22/2022
)
SELECT
 [Id]
,[Mrn]
,dbo.InitCap([Name]) as [Name]											-- Changed by Jovy Banaag 7/22/2022
,dbo.InitCap([Last Name]) as [Last Name]								-- Changed by Jovy Banaag 7/22/2022
,dbo.InitCap([First Name]) as [First Name]								-- Changed by Jovy Banaag 7/22/2022
,dbo.InitCap([Middle Name]) as [Middle Name]							-- Changed by Jovy Banaag 7/22/2022
,dbo.InitCap([Address 1]) as [Address 1]								-- Changed by Jovy Banaag 7/22/2022
,dbo.InitCap([Address 2]) as [Address 2]								-- Changed by Jovy Banaag 7/22/2022
,dbo.InitCap([City]) as [City]											-- Changed by Jovy Banaag 7/22/2022
,dbo.InitCap([State]) as [State]										-- Changed by Jovy Banaag 7/22/2022
,dbo.InitCap([County]) as [County]										-- Changed by Jovy Banaag 7/22/2022
,[Country]
,[Zip]
,[Home Phone]
,[Work Phone]
,[Other Phone]
,[Email]
,[No Email Reason]
,[Birth Date]
,dbo.InitCap([Ethnicity]) as [Ethnicity]								-- Changed by Jovy Banaag 7/22/2022
,dbo.InitCap([Religion]) as [Religion]									-- Changed by Jovy Banaag 7/22/2022
,dbo.InitCap([Language]) as [Language]									-- Changed by Jovy Banaag 7/22/2022
,[Sex]
,dbo.InitCap([Race]) as [Race]											-- Changed by Jovy Banaag 7/22/2022
,dbo.InitCap([Cur PCP Name]) as [Cur PCP Name]							-- Changed by Jovy Banaag 7/22/2022
,dbo.InitCap([Cur PCP Dept]) as [Cur PCP Dept]							-- Changed by Jovy Banaag 7/22/2022
,dbo.InitCap([Cur PCP Dept Area Group]) as [Cur PCP Dept Area Group]	-- Changed by Jovy Banaag 7/22/2022
,[Deceased Date]
,[Birth Labor]
,[Hosp Days]
,dbo.InitCap([Born Hosp Name]) as [Born Hosp Name]						-- Changed by Jovy Banaag 7/22/2022
,dbo.InitCap([Born Hosp Location]) as [Born Hosp Location]				-- Changed by Jovy Banaag 7/22/2022
,[Meds Last Review Time]
,dbo.InitCap([Meds Last Review User]) as [Meds Last Review User]		-- Changed by Jovy Banaag 7/22/2022	
,[Allergey Update Date]
,dbo.InitCap([Allergy Update User]) as [Allergy Update User]			-- Changed by Jovy Banaag 7/22/2022
,[Birth Lenght]
,[Birth Weight]
,[Birth Head Cir]
,[Disch Weight]
,[Apgar 1]
,[Apgar 5]
,[Apgar 10]
,[Gest Age]
,[Gest Age Days]
,[Is Test Patient]
,[MyChart Status]
,[Gender Identity]														-- Added by Jovy Banaag 7/22/2022
,dbo.InitCap([Gender]) as [Gender]										-- Added by Jovy Banaag 7/22/2022

from 
OPENQUERY([CHSCLARITY-PRD],

'
select 
 PATIENT.PAT_ID as [Id]
,PATIENT.PAT_MRN_ID as [Mrn]
,PATIENT.PAT_NAME as [Name]
,UPPER(PATIENT.PAT_LAST_NAME) as [Last Name]
,UPPER(PATIENT.PAT_FIRST_NAME) as [First Name]
,PATIENT.PAT_MIDDLE_NAME as [Middle Name]
,PATIENT.ADD_LINE_1 as [Address 1]
,PATIENT.ADD_LINE_2 as [Address 2]
,PATIENT.CITY as [City]
--,ZC_STATE.NAME as [State]
,ZC_STATE.ABBR as [State]
,ZC_COUNTY.NAME as [County]
,ZC_COUNTRY.NAME as [Country]
--,PATIENT.ZIP as [Pat Zip]
,Left(PATIENT.ZIP,5) as [Zip]
,PATIENT.HOME_PHONE as [Home Phone]
,PATIENT.WORK_PHONE as [Work Phone]
,OTHER_COMMUNCTN.OTHER_COMMUNIC_NUM as [Other Phone]
,PATIENT.EMAIL_ADDRESS as [Email]
,ZC_NO_EMAIL_REASON.NAME as [No Email Reason]
,PATIENT.BIRTH_DATE as [Birth Date]
,ZC_ETHNIC_GROUP.NAME as [Ethnicity]
,ZC_RELIGION.NAME as [Religion]
,ZC_LANGUAGE.NAME as [Language]
,ZC_SEX.ABBR as [Sex]
--,ZC_SEX.NAME as [Sex Name]
,ZC_PATIENT_RACE.NAME as [Race]
,SER_pcp.PROV_NAME as [Cur PCP Name]
,DEP_pcp.DEPARTMENT_NAME as [Cur PCP Dept]
,DEP_pcp.RPT_GRP_TWO as [Cur PCP Dept Area Group]  
,PATIENT.DEATH_DATE as [Deceased Date]
,PATIENT.PED_BIRTH_LABOR as [Birth Labor]
,PATIENT.PED_HOSP_DAYS as [Hosp Days]
,PATIENT.PED_HOSP_NAME as [Born Hosp Name] 
,PATIENT.PED_HOSP_LOCATION as [Born Hosp Location]
,PATIENT.MEDS_LAST_REV_TM as [Meds Last Review Time]
,PATIENT.MEDS_LST_REV_USR_ID as [Meds Last Review User]
,PATIENT.ALRGY_UPD_DATE as [Allergey Update Date]
,PATIENT.ALRGY_UPD_USER_ID as [Allergy Update User]
,PATIENT_3.PED_BIRTH_LEN_NUM as [Birth Lenght]
,PATIENT_3.PED_BIRTH_WT_NUM as [Birth Weight]
,PATIENT_3.PED_BIRTH_HD_CIRCUM as [Birth Head Cir]
,PATIENT_3.PED_DISCHRG_WGT_NUM as [Disch Weight]
,PATIENT_3.PED_APGAR_ONE_C as [Apgar 1]
,PATIENT_3.PED_APGAR_FIVE_C as [Apgar 5]
,PATIENT_3.PED_APGAR_TEN_C as [Apgar 10]
,PATIENT_3.PED_GEST_AGE_NUM as [Gest Age]
,PATIENT_3.PED_GEST_AGE_DAYS as [Gest Age Days]
,PATIENT_3.IS_TEST_PAT_YN as [Is Test Patient]
,ZC_MYCHART_STATUS.NAME as [MyChart Status]
,GENDER_IDENTITY_C	as [Gender Identity]						-- Added by Jovy Banaag 7/22/2022
,ZC_GENDER_CODE.NAME as [Gender]								-- Added by Jovy Banaag 7/22/2022
     
FROM
   clarity.dbo.ZC_LANGUAGE 
  RIGHT  JOIN  clarity.dbo.PATIENT ON ( ZC_LANGUAGE.LANGUAGE_C= PATIENT.LANGUAGE_C)
   LEFT  JOIN  clarity.dbo.ZC_RELIGION ON ( ZC_RELIGION.RELIGION_C= PATIENT.RELIGION_C)
   LEFT  JOIN  clarity.dbo.ZC_ETHNIC_GROUP ON ( ZC_ETHNIC_GROUP.ETHNIC_GROUP_C= PATIENT.ETHNIC_GROUP_C)
   LEFT  JOIN  clarity.dbo.ZC_SEX ON ( ZC_SEX.RCPT_MEM_SEX_C= PATIENT.SEX_C)
   LEFT  JOIN  clarity.dbo.ZC_STATE ON ( ZC_STATE.STATE_C= PATIENT.STATE_C)
   LEFT  JOIN  clarity.dbo.CLARITY_SER  SER_pcp ON (SER_pcp.PROV_ID= PATIENT.CUR_PCP_PROV_ID)
   LEFT  JOIN  clarity.dbo.CLARITY_SER_DEPT  dbo_CLARITY_SER_DEPT_PCP ON (dbo_CLARITY_SER_DEPT_PCP.PROV_ID=SER_pcp.PROV_ID)
   LEFT  JOIN  clarity.dbo.CLARITY_DEP  DEP_pcp ON (DEP_pcp.DEPARTMENT_ID=dbo_CLARITY_SER_DEPT_PCP.DEPARTMENT_ID and dbo_CLARITY_SER_DEPT_PCP.LINE=1)
   LEFT  JOIN  clarity.dbo.PATIENT_RACE ON ( PATIENT_RACE.PAT_ID= PATIENT.PAT_ID)
   LEFT  JOIN  clarity.dbo.ZC_PATIENT_RACE ON ( ZC_PATIENT_RACE.PATIENT_RACE_C= PATIENT_RACE.PATIENT_RACE_C)
   LEFT  JOIN  clarity.dbo.PATIENT_3 ON ( PATIENT_3.PAT_ID= PATIENT.PAT_ID)
   LEFT  JOIN  clarity.dbo.ZC_COUNTY ON ( ZC_COUNTY.COUNTY_C= PATIENT.COUNTY_C)
   LEFT  JOIN  clarity.dbo.ZC_COUNTRY ON ( ZC_COUNTRY.COUNTRY_C= PATIENT.COUNTRY_C)
   LEFT  JOIN  clarity.dbo.CLARITY_DEP  dbo_CLARITY_DEP_PatCurLoc ON (dbo_CLARITY_DEP_PatCurLoc.DEPARTMENT_ID= PATIENT.CUR_PRIM_LOC_ID)
   LEFT  JOIN  clarity.dbo.ZC_SUFFIX ON (ZC_SUFFIX.SUFFIX_C= PATIENT.PAT_NAME_SUFFIX_C)
   LEFT  JOIN  clarity.dbo.OTHER_COMMUNCTN ON ( PATIENT.PAT_ID=OTHER_COMMUNCTN.PAT_ID and OTHER_COMMUNCTN.CONTACT_PRIORITY = 1)
   LEFT  JOIN  clarity.dbo.ZC_PED_NOUR_METH ON (ZC_PED_NOUR_METH.PED_NOUR_METH_C= PATIENT.PED_NOUR_METH_C)
   LEFT  JOIN  clarity.dbo.PATIENT_4 ON (PATIENT_4.PAT_ID= PATIENT.PAT_ID)
   LEFT  JOIN  clarity.dbo.ZC_NO_EMAIL_REASON ON (ZC_NO_EMAIL_REASON.NO_EMAIL_REASON_C=PATIENT_4.NO_EMAIL_REASON_C)
   LEFT	 JOIN  clarity.dbo.PATIENT_MYC ON (PATIENT_MYC.PAT_ID = PATIENT.PAT_ID)   
   LEFT  JOIN  clarity.dbo.ZC_MYCHART_STATUS ON (ZC_MYCHART_STATUS.MYCHART_STATUS_C = PATIENT_MYC.MYCHART_STATUS_C)
   LEFT  JOIN  clarity.dbo.ZC_GENDER_CODE on ZC_GENDER_CODE.GENDER_CODE_C = PATIENT_4.GENDER_IDENTITY_C					-- Added by Jovy Banaag 7/22/2022
  
WHERE
( dbo_CLARITY_SER_DEPT_PCP.LINE = 1 or dbo_CLARITY_SER_DEPT_PCP.LINE IS NULL  )
  AND  
  (
   (
     PATIENT_RACE.LINE  Is Null  
    OR
     PATIENT_RACE.LINE  IN  (1)
   )
   AND
   (
     PATIENT_3.IS_TEST_PAT_YN  NOT IN  (''Y'')
    OR
     PATIENT_3.IS_TEST_PAT_YN  Is Null  
   )
  )'
  )
	
END
GO
