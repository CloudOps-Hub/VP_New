/**
 * @description       : 
 * @author            : Dhruv Agrawal
 * @group             : 
 * @last modified on  : 05-28-2021
 * @last modified by  : Dhruv Agrawal
 * Modifications Log 
 * Ver   Date         Author          Modification
 * 1.0   04-16-2021   Dhruv Agrawal   Initial Version
**/

public with sharing class MDM_CustomerTriggerHelper {
    
    public static Boolean isUpdated = false;
    public static Boolean skipTrigger = false;
   
    /**
    *   @description : This Function will check trigger condition before calling methods 
    *  @param  triggerWrapper
    */
    public static void triggerConditionForMethodInvoke(MDM_TriggerWrapper triggerWrapper){
        if(skipTrigger) { return; }
        if(triggerWrapper.isBefore) {
            if(triggerWrapper.isInsert || triggerWrapper.isUpdate) {
                calculateDQIScore(triggerWrapper); 
                setRecordTypeId(triggerWrapper.newSObjectList);
            }
        }
    }
    
    /**
     * @description Used to set RecordTypeId on customer record using Account Type field
     * @param customerList
     */
    static void setRecordTypeId(List<MDM_Customer__c> customerList) {
        Map<String, String> recordTypeMap = new Map<String, String>();
        for(RecordType recordType : [SELECT Id, Name FROM RecordType WHERE SobjectType = 'MDM_Customer__c']) {
            recordTypeMap.put(recordType.Name, recordType.Id);
        }
        for(MDM_Customer__c customer : customerList) {
            if(customer.RecordTypeId == NULL) { customer.RecordTypeId = recordTypeMap.get(customer.MDM_Account_Type__c); }
        }
    }
    
    /** 
    *  @description : This Function will update parent Customer
    *  @param  triggerWrapper
    *  @param  customerIdAPIName 
    */
    public static void updateLastModifiedDate(MDM_TriggerWrapper triggerWrapper, String customerIdAPIName) {
        Map<Id, MDM_Customer__c> customerMap = new Map<Id, MDM_Customer__c>();
        for(sObject record : triggerWrapper.isDelete ? triggerWrapper.oldSObjectList : triggerWrapper.newSObjectList) {
            if(record.get(customerIdAPIName) == NULL) { continue; }
            String key = String.valueOf(record.get(customerIdAPIName));
            customerMap.put(key, new MDM_Customer__c(Id = key));   
        }
        skipTrigger = true;
        try{
            update customerMap.values();
        } catch (Exception e) {
          MDM_HandleCustomException.logException(e);
        }
        skipTrigger = false;
    }
    
    /**
    * @description : This Function will check whether the profile is SysAdmin
    * @CreatedDate :	07/07/2020
    *  @return : Boolean 
    */
    public static Boolean checkSysAdminProfile(){
        if([SELECT Id, Name FROM Profile WHERE Id = :userinfo.getProfileId()].Name == 'System Administrator') { return true; }
        return false;
    }
    
    /**
    * @description 
    * @author Dhruv Agrawal | 05-28-2021 
    * @param triggerWrapper 
    **/
    public static void calculateDQIScore(MDM_TriggerWrapper triggerWrapper) {
     
        List<MDM_Customer__c> newCustomerList = triggerWrapper.newSObjectList;
        List<MDM_DQI_Attribute__c> dqiAttributeList = [SELECT MDM_Object_Name__c, MDM_Field_Name__c,
                                                       MDM_Field_Label__c, MDM_Percentage__c, MDM_Is_Active__c
                                                       FROM MDM_DQI_Attribute__c 
                                                       WHERE MDM_Object_Name__c = 'MDM_Customer__c'
                                                       AND MDM_Is_Active__c = true WITH SECURITY_ENFORCED];
        
        for(MDM_Customer__c newCustomer : newCustomerList) {
            Double dqi = 100;
            String description = '';
            List<String> descriptionList = new List<String>();
            for(MDM_DQI_Attribute__c dqiAttribute: dqiAttributeList) {
                if(newCustomer.get(dqiAttribute.MDM_Field_Name__c) == null) {
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
            newCustomer.MDM_DQI_Description__c = description;
            newCustomer.MDM_DQI_Score__c = dqi;
        }           
    }
}