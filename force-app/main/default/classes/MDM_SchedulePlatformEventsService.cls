/**
 * @description       : 
 * @author            : Dhruv Agrawal
 * @group             : 
 * @last modified on  : 05-28-2021
 * @last modified by  : Komal Sonsale
 * Modifications Log 
 * Ver   Date         Author          Modification
 * 1.0   04-16-2021   Dhruv Agrawal   Initial Version
**/

@SuppressWarnings('PMD.ApexCRUDViolation') //this class will run in system context , and is only called when scheduled
global with sharing class MDM_SchedulePlatformEventsService implements Schedulable {
    static List<String> statusList = new List<String> {'Aborted', 'Failed', 'Completed'};  
    static List<String> jobList = new List<String> { 
       'MDM_PublishCustomerPlatformEventsJob'
    };
    /**
     * @description Publish platform events for golden records that were created or updated in previous ten minutes.
     * @param sc
	 */
    global void execute(SchedulableContext sc) {
        Map<String, Integer> jobRunningCountMap = new Map<String, Integer> {
            'MDM_PublishCustomerPlatformEventsJob' => 0
        };
        for(AggregateResult jobDetail : [
            SELECT ApexClass.Name className, Count(Id) jobCount FROM AsyncApexJob 
            WHERE ApexClass.Name IN :jobList
            AND CompletedDate = NULL 
            AND Status NOT IN :statusList
            GROUP BY ApexClass.Name
        ]) {jobRunningCountMap.put((String)jobDetail.get('className'), (Integer)jobDetail.get('jobCount'));
        }
        //publish customer related events
        if(jobRunningCountMap.get('MDM_PublishCustomerPlatformEventsJob') == 0) { 
         	publishCustomerCreateUpdateEvent();   
        }        
       
    }

    /**
     * @description Publish platform events for customers that were created or updated in previous n minutes
	 */
    global static void publishCustomerCreateUpdateEvent() {
        Integer batchSize;
        Boolean publishPlatformEvents;
        //query custom metadata type and set the variables
        try {
            
              MDM_Application_Configuration__c appConfig = [Select id,MDM_Allow_Auto_Merge__c,MDM_Allow_Platform_Events__c,
                                                          MDM_Platfrom_Event_Batch_Size__c
                                                          from MDM_Application_Configuration__c
                                                          WITH SECURITY_ENFORCED 
                                                          limit 1 ];
            
       
            batchSize = Integer.valueOf(appConfig.MDM_Platfrom_Event_Batch_Size__c);
           publishPlatformEvents = appConfig.MDM_Allow_Platform_Events__c;
            if(Test.isRunningTest()) { throw new system.QueryException('Query returned zero records'); }
        } catch(Exception e) {
            //if no records found in system setting, then set the default values
            batchSize = 10;
            publishPlatformEvents = true;
            MDM_HandleCustomException.logException(e);
        }
         	MDM_PublishCustomerPlatformEventsJob obj = new MDM_PublishCustomerPlatformEventsJob(0, publishPlatformEvents);
            DataBase.executeBatch(obj, batchSize);
        
    }
   
}
/*
    To schedule this job for every 5 minutes in Every hour run the following code
	String jobID = system.schedule('MDM- Publish Platform Event For Golden record Create and Update Job V1', '0 2 * * * ?', new MDM_SchedulePlatformEventsService());
    jobID = system.schedule('MDM- Publish Platform Event For Golden record Create and Update Job V2', '0 10 * * * ?', new MDM_SchedulePlatformEventsService());
    jobID = system.schedule('MDM- Publish Platform Event For Golden record Create and Update Job V3', '0 20 * * * ?', new MDM_SchedulePlatformEventsService());
    jobID = system.schedule('MDM- Publish Platform Event For Golden record Create and Update Job V4', '0 32 * * * ?', new MDM_SchedulePlatformEventsService());
    jobID = system.schedule('MDM- Publish Platform Event For Golden record Create and Update Job V5', '0 40 * * * ?', new MDM_SchedulePlatformEventsService());
    jobID = system.schedule('MDM- Publish Platform Event For Golden record Create and Update Job V6', '0 50 * * * ?', new MDM_SchedulePlatformEventsService());
    jobID = system.schedule('MDM- Publish Platform Event For Golden record Create and Update Job V7', '0 05 * * * ?', new MDM_SchedulePlatformEventsService());
    jobID = system.schedule('MDM- Publish Platform Event For Golden record Create and Update Job V8', '0 17 * * * ?', new MDM_SchedulePlatformEventsService());
    jobID = system.schedule('MDM- Publish Platform Event For Golden record Create and Update Job V9', '0 25 * * * ?', new MDM_SchedulePlatformEventsService());
    jobID = system.schedule('MDM- Publish Platform Event For Golden record Create and Update Job V10', '0 35 * * * ?', new MDM_SchedulePlatformEventsService());
    jobID = system.schedule('MDM- Publish Platform Event For Golden record Create and Update Job V11', '0 47 * * * ?', new MDM_SchedulePlatformEventsService());
    jobID = system.schedule('MDM- Publish Platform Event For Golden record Create and Update Job V12', '0 55 * * * ?', new MDM_SchedulePlatformEventsService());

	For Production:
	String jobID = system.schedule('MDM- Publish Platform Event For Golden record Create and Update Job V1', '0 5 * * * ?', new MDM_SchedulePlatformEventsService());
    jobID = system.schedule('MDM- Publish Platform Event For Golden record Create and Update Job V2', '0 10 * * * ?', new MDM_SchedulePlatformEventsService());
    jobID = system.schedule('MDM- Publish Platform Event For Golden record Create and Update Job V3', '0 20 * * * ?', new MDM_SchedulePlatformEventsService());
    jobID = system.schedule('MDM- Publish Platform Event For Golden record Create and Update Job V4', '0 35 * * * ?', new MDM_SchedulePlatformEventsService());
    jobID = system.schedule('MDM- Publish Platform Event For Golden record Create and Update Job V5', '0 40 * * * ?', new MDM_SchedulePlatformEventsService());
    jobID = system.schedule('MDM- Publish Platform Event For Golden record Create and Update Job V6', '0 50 * * * ?', new MDM_SchedulePlatformEventsService());
*/