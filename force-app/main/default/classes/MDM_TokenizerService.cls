/**
 * @description       : Contains the core Token Generation MDM functionality.
 * @author            : Komal Sonsale
 * @group             : 
 * @last modified on  : 04-22-2021
 * @last modified by  : Sourabh
 * Modifications Log 
 * Ver   Date         Author          Modification
 * 1.0   03-30-2021   Komal Sonsale   Initial Version
**/
public with sharing class MDM_TokenizerService {
    
    Public enum SalesforceMDMObjects { MDM_CUSTOMER }      
    Public static Map<String, Map<String, String>> sObjectTokenFieldMap = new Map<String, Map<String, String>>();
    Public static Map<String, Map<String, Decimal>> sObjectFieldThresholdMap = new Map<String, Map<String, Decimal>>();
    
    
    /**
    * @description Function will return sObject API Name from provided ENUM.
    * @author Anish Samant | 04-05-2021 
    * @param goldObjectEnum 
    * @return String 
    **/
    public static String getMDMsObjectNameFromEnum(salesforceMDMObjects goldObjectEnum) {
        String mdmObject = null;
        Map<salesforceMDMObjects, String> customerSObjectEnum = new Map<salesforceMDMObjects, String> {
            salesforceMDMObjects.MDM_Customer   => 'MDM_Customer__c'
        };
        if( customerSObjectEnum.containsKey(goldObjectEnum) ) {
            mdmObject = customerSObjectEnum.get(goldObjectEnum);
        }
        return mdmObject;
    }
    
    /**
    * @description Function To prepare Map of given sObject's fields and their token field.
    * @author Anish Samant | 04-05-2021 
    * @param tokenSObjectName 
    * @return Map<String, String> 
    **/
    public static Map<String, String> getConfiguredTokenFields(String tokenSObjectName) {
        Map<String, String> configuredTokenFields = new Map<String, String>();
        if( sObjectTokenFieldMap.containsKey(tokenSObjectName) ) { 
            configuredTokenFields = sObjectTokenFieldMap.get(tokenSObjectName);
        }
        return configuredTokenFields;
    }
    
    
    /**
    * @description Function To prepare Map of given sObject's fields and their matching method or threshold.
    * @author Anish Samant | 04-05-2021 
    * @param tokenSObjectName 
    * @return Map<String, Decimal> 
    **/
    public static Map<String, Decimal> getConfiguredFieldThresholds(String tokenSObjectName) {
        Map<String, Decimal> configuredFieldThreshold = new Map<String, Decimal>();
        if( sObjectFieldThresholdMap.containsKey(tokenSObjectName) ) { 
            configuredFieldThreshold = sObjectFieldThresholdMap.get(tokenSObjectName);
        }
        return configuredFieldThreshold;
    }
    
    
    /**
    * @description Function To configure Static Global Map for given sObject using Duplicate and Matching Rules.
    * @author Anish Samant | 04-05-2021 
    * @param goldObjectName 
    **/
    public static void loadDuplicateRuleConfiguration(String goldObjectName) {
        if(!String.isBlank(goldObjectName)) {
            if (Schema.sObjectType.MDM_Field_Match_Configuration__c.isAccessible() && 
            Schema.sObjectType.MDM_Duplicate_Match_Rule__c.isAccessible() && 
            Schema.sObjectType.MDM_Matching_Rule__c.isAccessible()) {
                for( MDM_Matching_Rule__c matchRule : [
                    SELECT MDM_Object_Name__c,
                    (SELECT MDM_Match_Field__c, MDM_Match_Method__c 
                     FROM Field_Match_Configurations__r) 
                    FROM MDM_Matching_Rule__c 
                    WHERE Id IN (SELECT MDM_Matching_Rule__c 
                                 FROM MDM_Duplicate_Match_Rule__c 
                                 WHERE MDM_Duplicate_Rule__r.MDM_Object_Name__c = : goldObjectName
                                 AND MDM_Duplicate_Rule__r.MDM_is_Active__c = true) WITH SECURITY_ENFORCED] ) 
                {
                    Map<String, String> configuredTokenFields = new Map<String, String>();
                    Map<String, Decimal> configuredFieldThreshold = new Map<String, Decimal>();
                    for(MDM_Field_Match_Configuration__c fieldMatchConfig: matchRule.Field_Match_Configurations__r ) {
                        configuredTokenFields.put(fieldMatchConfig.MDM_Match_Field__c, fieldMatchConfig.MDM_Match_Field__c);
                        configuredFieldThreshold.put(fieldMatchConfig.MDM_Match_Field__c, 
                                                     Decimal.valueOf( fieldMatchConfig.MDM_Match_Method__c.split('-')[1] ));
                    }
                    sObjectTokenFieldMap.put(matchRule.MDM_Object_Name__c, configuredTokenFields);
                    sObjectFieldThresholdMap.put(matchRule.MDM_Object_Name__c, configuredFieldThreshold);
                }
            } 
        }
    }
}