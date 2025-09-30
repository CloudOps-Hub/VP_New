/* 
 * @author : Jordan, Rahul
 * @description  : Test class for MDM_CreateAutoUpdateMatchingRuleService and MDM_AutoUpdateMatchingRuleTriggerHelper.
 * Modification Log:
 * Version		Date		Author		Description
 * 1.0		 10/21/2021		Jordan		Initial Version					
 */
@isTest(SeeAllData = False)
public without sharing class MDM_CreateAutoUpdateMatchingRuleTest {
    /*   
    *  @author : Jordan     
    *  @description : Provides test coverage for all methods of MDM_CreateAutoUpdateMatchingRuleService
    */ 
    @isTest static void getSObjectList() {
        MDM_Auto_Update_Matching_Rule__c matchingRule = new MDM_Auto_Update_Matching_Rule__c ();
        matchingRule.MDM_Object__c = 'MDM_SOURCE_CUSTOMER__C';
        matchingRule.MDM_Object_Label__c = 'Reference System IDs (MDM_SOURCE_CUSTOMER__C)';
        matchingRule.MDM_Matching_Key__c = 
            '[{"field":"MDM_Source_System__c","comparison":"Has exact value","value":"Dun & Brad"},'+
            '{"field":"MDM_Source_System_Id_Type__c","comparison":"Has exact value","value":"Unique ID"},'+
            '{"field":"MDM_Id__c","comparison":"Any value","value":null}]';
        matchingRule.MDM_Record_Action__c = '{"create_new":true,"update_existing":true}';
        matchingRule.MDM_Field_Action__c = 
            '[{"field":"MDM_Source_System_Status__c","action":"Update"},'+
            '{"field":"MDM_Source_System_Title_Name__c","action":"Update"}]';
        matchingRule.MDM_Active__c = True;
        matchingRule.MDM_Default__c = False;
        
        test.startTest();
        MDM_GeneraliseResult result1 = MDM_CreateAutoUpdateMatchingRuleService.getSObjectList();
        List<String> objectList = (List<String>) result1.result;
        System.assertEquals(objectList.contains('Customer (MDM_CUSTOMER__C)'), True, 'SObject list fetched');
        
        MDM_GeneraliseResult result2 = MDM_CreateAutoUpdateMatchingRuleService.getSObjectFieldMap(matchingRule.MDM_Object__c);
        Map<String, String> sObjectFieldAPINameMap = (Map<String, String>) result2.result;
        System.assertEquals(sObjectFieldAPINameMap.get('Customer (MDM_CUSTOMER__C)'), 'MDM_Customer__c', 'Field map fetched');
        
        MDM_CreateAutoUpdateMatchingRuleService.saveRecord(matchingRule);
        MDM_GeneraliseResult result3 = MDM_CreateAutoUpdateMatchingRuleService.getRecord(matchingRule.Id);
        MDM_Auto_Update_Matching_Rule__c autoUpdateRule = (MDM_Auto_Update_Matching_Rule__c) result3.result;
        System.assertEquals(autoUpdateRule.MDM_Active__c, True, 'Rule created');
        test.stopTest();
    } 
}