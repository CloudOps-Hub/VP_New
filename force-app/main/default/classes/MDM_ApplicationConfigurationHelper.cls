/**
* @description       : 
* @author            : Komal Sonsale
* @group             : 
* @last modified on  : 06-16-2021
* @last modified by  : Komal Sonsale
* Modifications Log 
* Ver   Date         Author          Modification
* 1.0   06-16-2021   Komal Sonsale   Initial Version
**/
public with sharing class MDM_ApplicationConfigurationHelper {
    
    /**
    * @description 
    * @author Komal Sonsale | 06-16-2021 
    * @param triggerWrapper 
    **/
    public static void triggerConditionForTriggerHelperInvoke(MDM_TriggerWrapper triggerWrapper){
        if(triggerWrapper.isBefore && trigger.isInsert) { 
            allowOneRecord(triggerWrapper);
        }
    }
    
    /**
    * @description 
    * @author Komal Sonsale | 06-16-2021 
    * @param triggerWrapper 
    **/
    static void allowOneRecord(MDM_TriggerWrapper triggerWrapper) {
        List<MDM_Application_Configuration__c> applictionConfigList;
        try{
            applictionConfigList = [Select Id from MDM_Application_Configuration__c WITH SECURITY_ENFORCED];
        } catch(Exception e){
            MDM_HandleCustomException.logException(e);
        }
        Integer listSize = applictionConfigList.size();
        for(sObject applicationCongig : triggerWrapper.newSObjectList) {
            if(listSize == 1) {
                applicationCongig.addError('You are not allowed to create more than one record of Application Configuration');
            }
        }
    }
    
}