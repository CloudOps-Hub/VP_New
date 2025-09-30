/**
 * @description       : 
 * @author            : Dhruv Agrawal
 * @group             : 
 * @last modified on  : 05-27-2021
 * @last modified by  : Komal Sonsale
 * Modifications Log 
 * Ver   Date         Author          Modification
 * 1.0   05-03-2021   Dhruv Agrawal   Initial Version
**/
@SuppressWarnings('PMD.ApexCRUDViolation') //this class will run in system context , and is only called when scheduled
global with sharing class MDM_ScheduleAutoUpdateJob implements Schedulable {
    static List<String> statusList = new List<String> {'Aborted', 'Failed', 'Completed'};  
    static List<String> jobList = new List<String> { 
       'MDM_AutoUpdateJob'
    };
    /**
     * @description Publish platform events for golden records that were created or updated in previous ten minutes.
     * @param sc
	 */
    global void execute(SchedulableContext sc) {
        Map<String, Integer> jobRunningCountMap = new Map<String, Integer> {
            'MDM_AutoUpdateJob' => 0
        };
        for(AggregateResult jobDetail : [
            SELECT ApexClass.Name className, Count(Id) jobCount FROM AsyncApexJob 
            WHERE ApexClass.Name IN :jobList
            AND CompletedDate = NULL 
            AND Status NOT IN :statusList
            GROUP BY ApexClass.Name
        ]) {jobRunningCountMap.put((String)jobDetail.get('className'), (Integer)jobDetail.get('jobCount'));
        }
        if(jobRunningCountMap.get('MDM_AutoUpdateJob') == 0) { 
            callAutoUpdateJob();   
        }        
       
    }

    /**
    * @description 
    * @author Komal Sonsale | 05-27-2021 
    **/
    global static void callAutoUpdateJob() {
        Integer batchSize=5;
        MDM_AutoUpdateJob obj = new MDM_AutoUpdateJob();
        DataBase.executeBatch(obj, batchSize);
        }
}
/* 
To schedule this job for every 5 minutes in Every hour run the following code
String jobID = system.schedule('MDM- Auto Update Schedule  Job V1', '0 2 * * * ?', new MDM_ScheduleAutoUpdateJob());
jobID = system.schedule('MDM- Auto Update Schedule  Job V2', '0 10 * * * ?', new MDM_ScheduleAutoUpdateJob());
jobID = system.schedule('MDM- Auto Update Schedule  Job V3', '0 20 * * * ?', new MDM_ScheduleAutoUpdateJob());
jobID = system.schedule('MDM- Auto Update Schedule  Job V4', '0 32 * * * ?', new MDM_ScheduleAutoUpdateJob());
jobID = system.schedule('MDM- Auto Update Schedule  Job V5', '0 40 * * * ?', new MDM_ScheduleAutoUpdateJob());
jobID = system.schedule('MDM- Auto Update Schedule  Job V6', '0 50 * * * ?', new MDM_ScheduleAutoUpdateJob());
jobID = system.schedule('MDM- Auto Update Schedule  Job V7', '0 05 * * * ?', new MDM_ScheduleAutoUpdateJob());
jobID = system.schedule('MDM- Auto Update Schedule  Job V8', '0 17 * * * ?', new MDM_ScheduleAutoUpdateJob());
jobID = system.schedule('MDM- Auto Update Schedule  Job V9', '0 25 * * * ?', new MDM_ScheduleAutoUpdateJob());
jobID = system.schedule('MDM- Auto Update Schedule  Job V10', '0 35 * * * ?', new MDM_ScheduleAutoUpdateJob());
jobID = system.schedule('MDM- Auto Update Schedule  Job V11', '0 47 * * * ?', new MDM_ScheduleAutoUpdateJob());
jobID = system.schedule('MDM- Auto Update Schedule  Job V12', '0 55 * * * ?', new MDM_ScheduleAutoUpdateJob());
 */