/**
 * @description       : 
 * @author            : Dhruv Agrawal
 * @group             : 
 * @last modified on  : 06-10-2021
 * @last modified by  : Komal Sonsale
 * Modifications Log 
 * Ver   Date         Author          Modification
 * 1.0   04-26-2021   Dhruv Agrawal   Initial Version
**/
@SuppressWarnings('PMD.CyclomaticComplexity,PMD.CognitiveComplexity')
public with sharing class MDM_DQIAttributeTriggerHelper {
    public static Decimal customerPercentage=0;
    public static Decimal addressPercentage=0;
    public static Decimal contactPercentage=0;
    
 /**
    *  @description : This Function will check trigger condition before calling methods 
    *  @param triggerWrapper
    */
    public static void triggerConditionForMethodInvoke(MDM_TriggerWrapper triggerWrapper){
        if(triggerWrapper.isBefore) {
            if(triggerWrapper.isInsert || triggerWrapper.isUpdate) {
                beforeInsertUpdate(triggerWrapper);
            }        
         } 
    }
    
    static void beforeInsertUpdate(MDM_TriggerWrapper triggerWrapper){
        List<MDM_DQI_Attribute__c> newdqiList = triggerWrapper.newSObjectList;
        //System.debug('dqiList'+newdqiList);
        List<MDM_DQI_Attribute__c> olddqiList = new List<MDM_DQI_Attribute__c>();
        try{
         olddqiList = [Select Id,MDM_Data_Quality__r.MDM_Object__c, MDM_Percentage__c, MDM_Is_Active__c
                                                 from MDM_DQI_Attribute__c where Id not in:newdqiList AND MDM_Is_Active__c = true with Security_Enforced ];}
        catch(Exception E){
			 MDM_HandleCustomException.logException(e);
        }
        //System.debug('olddqiList'+olddqiList);
        for(MDM_DQI_Attribute__c dqi:newdqiList ){
            if(dqi.MDM_Object_Name__c == 'MDM_Customer__c'){
                customerPercentage = customerPercentage + dqi.MDM_Percentage__c;
            }else if(dqi.MDM_Object_Name__c == 'MDM_Address__c'){
                addressPercentage = addressPercentage + dqi.MDM_Percentage__c;
            }else if(dqi.MDM_Object_Name__c == 'MDM_Contact__c'){
                contactPercentage = contactPercentage + dqi.MDM_Percentage__c;
            }
            
        }
        
        for(MDM_DQI_Attribute__c ar: olddqiList){
            if(ar.MDM_Data_Quality__r.MDM_Object__c == 'MDM_Customer__c')
            {customerPercentage += ar.MDM_Percentage__c;
            }else  if(ar.MDM_Data_Quality__r.MDM_Object__c == 'MDM_Address__c')
            {addressPercentage += ar.MDM_Percentage__c;
            }else  if(ar.MDM_Data_Quality__r.MDM_Object__c == 'MDM_Contact__c')
            {contactPercentage += ar.MDM_Percentage__c;
            }
        }
        
        if(customerPercentage>100 || addressPercentage>100 || contactPercentage>100 ){
            for(sObject dqi : triggerWrapper.newSObjectList) {
            	dqi.addError('Total Percentage Cannot exceed 100');
        	}
        }
    }
}