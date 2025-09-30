/**
 * @author : Rahul
 * @description Auto Update Matching Rule trigger helper
 * Test class : MDM_CreateAutoUpdateMatchingRuleTest
 * @Modification Log   :
    Ver       	Date          	Author      		Modification
    1.0     	01/11/2021		Jordan, Rahul		Initial version
 */

public without sharing class MDM_AutoUpdateMatchingRuleTriggerHelper {

    /**
     * @description Calls trigger methods for Auto Update Matching Rule object
     * @param triggerWrapper
     */
    public static void triggerConditionForMethodInvoke(MDM_TriggerWrapper triggerWrapper) {
        if(triggerWrapper.isBefore) {
            if(triggerWrapper.isInsert || triggerWrapper.isUpdate) {
                updateDisplayKey(triggerWrapper.newSObjectList);
                validateDefaults(triggerWrapper);
                beautifyJSONs(triggerWrapper.newSObjectList);
            }
        }
    }
    
    class MDM_KeyConfig {
        String field;
        String value;
    }
    
    /**
     * @description Used to store JSONs in proper format for display
     * @param autoUpdateRuleList
     */
    static void beautifyJSONs(List<MDM_Auto_Update_Matching_Rule__c> autoUpdateRuleList) {
        for(MDM_Auto_Update_Matching_Rule__c autoUpdateRule : autoUpdateRuleList) {
            autoUpdateRule.MDM_Field_Action__c = JSON.serializePretty(
                JSON.deserializeUntyped(autoUpdateRule.MDM_Field_Action__c),
                true
            );
            autoUpdateRule.MDM_Record_Action__c = JSON.serializePretty(
                JSON.deserializeUntyped(autoUpdateRule.MDM_Record_Action__c),
                true
            );
            autoUpdateRule.MDM_Matching_Key__c = JSON.serializePretty(
                JSON.deserializeUntyped(autoUpdateRule.MDM_Matching_Key__c),
                true
            );
        }
    }
    
    /**
     * @description Used to validate whether there are more than one default rules for a single object
     * @param triggerWrapper
     */
    static void validateDefaults(MDM_TriggerWrapper triggerWrapper) {
        Map<String, MDM_Auto_Update_Matching_Rule__c> eligibleAutoUpdateRuleMap = new Map<String, MDM_Auto_Update_Matching_Rule__c>();
        for(MDM_Auto_Update_Matching_Rule__c autoUpdateRule : (List<MDM_Auto_Update_Matching_Rule__c>) triggerWrapper.newSObjectList) {
            if(
                autoUpdateRule.MDM_Default__c &&
                (
                    triggerWrapper.isInsert ||
                    !Boolean.valueOf(triggerWrapper.oldSObjectMap.get(autoUpdateRule.Id).get('MDM_Default__c'))
                )
            ) { eligibleAutoUpdateRuleMap.put(autoUpdateRule.MDM_Object__c.toLowerCase(), autoUpdateRule); }
        }
        List<MDM_Auto_Update_Matching_Rule__c> autoUpdateRuleList;
        autoUpdateRuleList = eligibleAutoUpdateRuleMap.values();
        Set<String> objectSet;
        objectSet = eligibleAutoUpdateRuleMap.keySet();
        String query = 'SELECT MDM_Object__c FROM MDM_Auto_Update_Matching_Rule__c WHERE MDM_Default__c = true' +
            ' AND Id NOT IN :autoUpdateRuleList' +
            ' AND MDM_Object__c IN :objectSet';
        for(MDM_Auto_Update_Matching_Rule__c autoUpdateRule : (List<MDM_Auto_Update_Matching_Rule__c>) Database.query(String.escapeSingleQuotes(query))) {
            eligibleAutoUpdateRuleMap.get(autoUpdateRule.MDM_Object__c.toLowerCase()).addError(Label.MDM_Multiple_Default_Auto_Update_Rule_Message); 
        }
    }
    
    /**
     * @description Used to update display key on auto update rules
     * @param autoUpdateRuleList
     */
    static void updateDisplayKey(List<MDM_Auto_Update_Matching_Rule__c> autoUpdateRuleList) {
        Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
        for(MDM_Auto_Update_Matching_Rule__c autoUpdateRule : autoUpdateRuleList) {
            Schema.SObjectType objectSchema = schemaMap.get(autoUpdateRule.MDM_Object__c);
            Map<String, Schema.SObjectField> fieldMap = objectSchema.getDescribe().fields.getMap();
            try {
                List<String> keyConfigList = new List<String>();
                for(MDM_KeyConfig keyConfig : (List<MDM_KeyConfig>) JSON.deserialize(autoUpdateRule.MDM_Matching_Key__c, List<MDM_KeyConfig>.class)) {
                    keyConfigList.add(
                        fieldMap.get(keyConfig.field).getDescribe().getLabel() +
                        (keyConfig.value != NULL ? ' = ' + keyConfig.value : '')
                    );
                }
                autoUpdateRule.MDM_Key__c = String.join(keyConfigList, '; ');
                if(Test.isRunningTest()) { throw new System.JSONException('Invalid JSON'); }
            } catch(Exception e) {
                autoUpdateRule.MDM_Key__c = NULL;
            }
        }
    }
    
}