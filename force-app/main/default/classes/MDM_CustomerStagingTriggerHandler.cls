/**
 * @description       : 
 * @author            : Dhruv Agrawal
 * @group             : 
 * @last modified on  : 04-05-2021
 * @last modified by  : Komal Sonsale
 * Modifications Log 
 * Ver   Date         Author          Modification
 * 1.0   03-23-2021   Dhruv Agrawal   Initial Version
**/
public with sharing class MDM_CustomerStagingTriggerHandler {
    
    /**
    * @description : To call Trigger helper class methods
    * @param triggerWrapper
    */
    public static void triggerConditionForTriggerHelperInvoke(MDM_TriggerWrapper triggerWrapper){
        if(!system.isBatch()) {
            if(Trigger.isBefore && !Trigger.isDelete) {
                MDM_DataTransformationService.dataTransformation(Trigger.new);  
            }   
        }
        //Method to change Registration Status to Completed AFTER corresponding Staging record is Processed
        MDM_CustomerStagingTriggerHelper.triggerConditionForMethodInvoke(triggerWrapper);
    }
}