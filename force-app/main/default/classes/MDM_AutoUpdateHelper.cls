/**
 * @description       : Helper class to perform auto-update logic
 * @author            : Rahul, Odion, Jordan, Dhruv
 * @group             : 
 * @last modified on  : 01/12/2021
 * @last modified by  : Rahul Nagpure
 * Modifications Log 
 * Ver   Date         Author          				Modification
 * 1.0   01/12/2021   Rahul, Odion, Jordan, Dhruv   Initial Version
 **/

public with sharing class MDM_AutoUpdateHelper {
	/**
     * @description  : This method will return a Map of all the active Auto Update Matching Rules.
     * @return Map<String, List<MDM_Auto_Update_Matching_Rule__c>> - Map of Object and its active auto update Rules
     */
    public static Map<String, List<MDM_Auto_Update_Matching_Rule__c>> getAutoUpdateRuleMap() {
        
        Map<String, List<MDM_Auto_Update_Matching_Rule__c>> autoUpdateRuleMap = new Map<String, List<MDM_Auto_Update_Matching_Rule__c>>();
        
        for(MDM_Auto_Update_Matching_Rule__c autoUpdateRuleRecord : [
            SELECT MDM_Default__c,MDM_Field_Action__c, MDM_Key__c,MDM_Matching_Key__c, MDM_Object_Label__c,
            MDM_Object__c, MDM_Record_Action__c
            FROM MDM_Auto_Update_Matching_Rule__c 
            WHERE MDM_Active__c = TRUE
            ORDER BY MDM_Default__c
        ]) {
            if(autoUpdateRuleMap.containsKey(autoUpdateRuleRecord.MDM_Object__c)) {
                autoUpdateRuleMap.get(autoUpdateRuleRecord.MDM_Object__c.toUpperCase()).add(autoUpdateRuleRecord);
            } else {
                autoUpdateRuleMap.put(autoUpdateRuleRecord.MDM_Object__c.toUpperCase(), new List<MDM_Auto_Update_Matching_Rule__c>{ autoUpdateRuleRecord });
            }
        }
        
        return autoUpdateRuleMap;
    }
    
}