/**
 * @description       : 
 * @author            : Priya Sharma
 * @group             : 
 * @last modified on  : 04-22-2021
 * @last modified by  : Sourabh
 * Modifications Log 
 * Ver   Date         Author         Modification
 * 1.0   04-16-2021   Priya Sharma   Initial Version
**/

public with sharing class MDM_ContactTriggerHandler {
    /**
    * @description : To call Trigger helper class methods
    * @param triggerWrapper
    */
    public static void triggerConditionForTriggerHelperInvoke(MDM_TriggerWrapper triggerWrapper){
        MDM_ContactTriggerHelper.triggerConditionForMethodInvoke(triggerWrapper); 
        if(trigger.isAfter){
            // !IMPORTANT This must be the last call to be invoked from this trigger
            MDM_CustomerTriggerHelper.updateLastModifiedDate(triggerWrapper, 'MDM_Customer__c');
            // !IMPORTANT No code beyond this point
        }
    }
}