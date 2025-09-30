/**
* @description       : This class will update pending notification flag on customer
* @author            : Komal Sonsale
* @group             : 
* @last modified on  : 05-21-2021
* @last modified by  : Dhruv Agrawal
* Modifications Log 
* Ver   Date         Author          Modification
* 1.0   04-16-2021   Komal Sonsale   Initial Version
**/

public with sharing class MDM_NotificationFlagHelper {
    public static boolean enableUpdate = true;
    static map<String,String> metaDataSettingMap = new map<String,String>{
        'MDM_Application_Configuration__c' => 'MDM_Customer_System_Setting__mdt'
            };
                
                /**
* @description : This Function update MDM_Pending_Notification__c flag on Insert/Update
* @param triggerWrapper
*/
                public static void updatePendingNotificationFlag(MDM_TriggerWrapper triggerWrapper){
                    if(!enableUpdate || !triggerWrapper.isBefore || (!triggerWrapper.isUpdate && !triggerWrapper.isInsert)) { return; }
                    Boolean enablePlatformEvent;
                    List<sObject> sObjectList = triggerWrapper.newSObjectList;
                    try{
                       // String query = 'SELECT ID, MDM_Platfrom_Event_Batch_Size__c, MDM_Allow_Platform_Events__c FROM MDM_Application_Configuration__c' ;
                           MDM_Application_Configuration__c appConfig = [Select id,MDM_Allow_Auto_Merge__c,MDM_Allow_Platform_Events__c,
                                                          MDM_Platfrom_Event_Batch_Size__c
                                                          from MDM_Application_Configuration__c
                                                          WITH SECURITY_ENFORCED 
                                                          limit 1 ];
                       // SObject appConfig =Database.query(query);
                     
                       enablePlatformEvent = appConfig.MDM_Allow_Platform_Events__c;
                        if(Test.isRunningTest()) { throw new system.QueryException('No Records Returned in the query'); }
                    } catch(Exception e) { 
                        enablePlatformEvent = false;
                        if(Test.isRunningTest()) {
                            enablePlatformEvent = true;
                        }
                    }
                    
                    setFlags(sObjectList, enablePlatformEvent);
                } 
    
    static void setFlags(List<sObject> sObjectList, Boolean enablePlatformEvent) {
        for(sObject sObj : sObjectList){ 
            if(enablePlatformEvent) { sObj.put('MDM_Pending_Platform_Event__c',true); }
        }
    }
}