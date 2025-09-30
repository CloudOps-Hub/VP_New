/**
 * @description       : Helper class to construct and perfrom queries
 * @author            : Rahul, Odion, Jordan, Dhruv
 * @group             : 
 * @last modified on  : 01/12/2021
 * @last modified by  : Rahul Nagpure
 * Modifications Log 
 * Ver   Date         Author          				Modification
 * 1.0   01/12/2021   Rahul, Odion, Jordan, Dhruv   Initial Version
 **/

public with sharing class MDM_AutoUpdateQueryHelper {
    
    /**
     * @description Returns SObjectType => Field list map from Auto Update Matching Rule
     * @param autoUpdateRuleMap
     * @param fieldLengthMap
     * @return objectFieldListMap
     */
    public static Map<String, Set<String>> getObjectFieldListMap(
        Map<String, List<MDM_Auto_Update_Matching_Rule__c>> autoUpdateRuleMap,
        Map<String, Integer> fieldLengthMap
    ) {
        Map<String, Set<String>> objectFieldListMap = new Map<String, Set<String>>();
        for(String stagingSObjectName : autoUpdateRuleMap.keySet()) {
            Set<String> stagingFieldSet = new Set<String>();
            for(MDM_Auto_Update_Matching_Rule__c autoUpdateRule : autoUpdateRuleMap.get(stagingSObjectName)) {
                for(MDM_AutoUpdateWrapper.MatchingKey matchingKey : (List<MDM_AutoUpdateWrapper.MatchingKey>) JSON.deserialize(
                        autoUpdateRule.MDM_Matching_Key__c, List<MDM_AutoUpdateWrapper.MatchingKey>.class
                )) { stagingFieldSet.add(matchingKey.field); }
                
                for(MDM_AutoUpdateWrapper.FieldAction fieldAction : (List<MDM_AutoUpdateWrapper.FieldAction>) JSON.deserialize(
                        autoUpdateRule.MDM_Field_Action__c, List<MDM_AutoUpdateWrapper.FieldAction>.class
                )) { stagingFieldSet.add(fieldAction.field); } 
            }
            
            String goldenSObjectName = MDM_AutoUpdateJob.STAGING_TO_GOLDEN_SOBJECT_TYPE_MAP.get(stagingSObjectName);
            Set<String> goldenFieldSet = new Set<String>();
            for(Schema.SObjectField field : Schema.getGlobalDescribe().get(goldenSObjectName).getDescribe(SObjectDescribeOptions.FULL).fields.getMap().values()) {  
                Schema.DescribeFieldResult fieldResult = field.getDescribe(); 
                if(stagingFieldSet.contains(fieldResult.getName())) {
                 	goldenFieldSet.add(fieldResult.getName());
                    fieldLengthMap.put(goldenSObjectName + fieldResult.getName(), fieldResult.getLength());
                }
            }
            
            objectFieldListMap.put(stagingSObjectName, stagingFieldSet);
            objectFieldListMap.put(goldenSObjectName, goldenFieldSet);
        }
        
        return objectFieldListMap;
    }
    
}