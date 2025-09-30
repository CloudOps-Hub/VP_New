/**
 * @description       : 
 * @author            : Priya Sharma
 * @group             : 
 * @last modified on  : 05-28-2021
 * @last modified by  : Komal Sonsale
 * Modifications Log 
 * Ver   Date         Author         Modification
 * 1.0   04-16-2021   Priya Sharma   Initial Version
**/

public with sharing class MDM_ContactTriggerHelper {
    /** 
    * @description This Function will check trigger condition before calling methods 
    * @param triggerWrapper
    */
    public static void triggerConditionForMethodInvoke(MDM_TriggerWrapper triggerWrapper){
        if(triggerWrapper.isBefore) {
            if(triggerWrapper.isInsert || triggerWrapper.isUpdate) {
                calculateDQIScore(triggerWrapper);
                MDM_CustomerContactAddressTriggerHelper.preventUpdatingDeletedCustomer(triggerWrapper,false); 
            }
            if(triggerWrapper.isDelete){
                MDM_CustomerContactAddressTriggerHelper.preventUpdatingDeletedCustomer(triggerWrapper,true); 
            }
        } 
    }
    
    /**
    * @description 
    * @author Komal Sonsale | 05-27-2021 
    * @param triggerWrapper 
    **/
    public static void calculateDQIScore(MDM_TriggerWrapper triggerWrapper) {
     
        List<MDM_Contact__c> newContactList = triggerWrapper.newSObjectList;
        List<MDM_DQI_Attribute__c> dqiAttributeList = new List<MDM_DQI_Attribute__c>();
        try{
            dqiAttributeList = [SELECT MDM_Object_Name__c, MDM_Field_Name__c,
            MDM_Field_Label__c, MDM_Percentage__c, MDM_Is_Active__c
            FROM MDM_DQI_Attribute__c 
            WHERE MDM_Object_Name__c = 'MDM_Contact__c'
            AND MDM_Is_Active__c = true
            WITH SECURITY_ENFORCED];
        }
        catch(Exception e){
            MDM_HandleCustomException.logException(e);
        }
        
        for(MDM_Contact__c newContact : newContactList) {
            Double dqi = 100;
            String description = '';
          List<String> descriptionList = new List<String>();
            for(MDM_DQI_Attribute__c dqiAttribute: dqiAttributeList) {
                if(newContact.get(dqiAttribute.MDM_Field_Name__c) == null) {
                    dqi -= dqiAttribute.MDM_Percentage__c;
                    descriptionList.add(dqiAttribute.MDM_Field_Label__c);
                }                    
            }
            if(descriptionList.size() == 1) {
                description += descriptionList[0] + ' is missing';
            }
            if(descriptionList.size() > 1) {
                for(String descriptions: descriptionList) {
                    description += descriptions + ' , ';
                }
                integer length = description.length();
                description = description.substring(0, length-2);
                description += 'are missing';
            }            
            if(dqi == 100){
                description = 'All fields are Present';
            }
            newContact.MDM_DQI_Description__c = description;
            newContact.MDM_DQI_Score__c = dqi;
        }           
    }
}