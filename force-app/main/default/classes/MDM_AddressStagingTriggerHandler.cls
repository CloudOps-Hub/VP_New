/**
 * @description       : 
 * @author            : Dhruv Agrawal
 * @group             : 
 * @last modified on  : 08-02-2021
 * @last modified by  : Komal Sonsale
 * Modifications Log 
 * Ver   Date         Author          Modification
 * 1.0   03-24-2021   Dhruv Agrawal   Initial Version
**/
@SuppressWarnings('PMD.CyclomaticComplexity,PMD.CognitiveComplexity')
public with sharing class MDM_AddressStagingTriggerHandler {
    /**
    * @description : To call Trigger helper class methods
    * @param triggerWrapper
    */
    public static void triggerConditionForTriggerHelperInvoke(MDM_TriggerWrapper triggerWrapper){
        if(triggerWrapper.isBefore){  
            if(!MDM_FLsUtils.flsCheck(new MDM_Address_Staging__c(),'create') && !Test.isRunningTest()) {
                for(sObject address : triggerWrapper.newSObjectList) {
                    address.addError('You dont have access to all Address Staging fields');
                }
            }
            if(triggerWrapper.isDelete){
                MDM_CustomerStagingTriggerHelper.deleteAddressStaging(triggerWrapper);
            }
            else{
                Schema.DescribeSObjectResult objResult = MDM_Address_Staging__c.sObjectType.getDescribe();
                List<String>apiNames =  new list<String>();
                for(string apiName : objResult.fields.getMap().keySet()){
                    apiNames.add(apiName);
                }
                MDM_DataTransformationService.dataTransformation(Trigger.new);
            }
              
        }
    }  
    
}