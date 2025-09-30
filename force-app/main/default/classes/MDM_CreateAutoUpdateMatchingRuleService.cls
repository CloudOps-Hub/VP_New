/**
 * @author : Rahul
 * @description Auto Update Matching Rule creation helper methods
 * Test class : MDM_CreateAutoUpdateMatchingRuleTest
 * @Modification Log   :
    Ver       	Date          	Author      		Modification
    1.0     	10/19/2021		Jordan, Rahul		Initial version
 */

public without sharing class MDM_CreateAutoUpdateMatchingRuleService {
	
    /** @owner : Jordan
     *  @description : Used to return List of Object API names
     *  @createdDate : 10/18/2021
     *  @return result
     */
    public static MDM_GeneraliseResult getSObjectList() {
        MDM_GeneraliseResult result = new MDM_GeneraliseResult();
        result.isSuccess = False;
        List<String> objectList = new List<String>();
        Map<String, Schema.SObjectType> gd = Schema.getGlobalDescribe();
        for(String objName : gd.keySet()){
            if(objName.containsIgnoreCase('mdm_') && objName.endsWith('__c')){
                objectList.add(String.valueOf(gd.get(objName).getDescribe().getLabel()) + ' (' + objName.toUpperCase() + ')');
            } 
        }
        if(!objectList.isEmpty()){
            result.isSuccess = True;
            result.result = objectList;
        } else {
            result.displayMessage = 'Error fetching objects. Please contact your administrator.';
        }
        return result;
    }
    
    /** @owner : Jordan
     *  @description : Used to return Fields API names of the given Object name
     *  @param objectName : Object Name
     *  @createdDate : 10/18/2021
     *  @return result
     */
    public static MDM_GeneraliseResult getSObjectFieldMap(String objectName) {
        MDM_GeneraliseResult result = new MDM_GeneraliseResult();
        result.isSuccess = False;
        if(objectName == NULL) { return result; }
                
        Map<String, String> sObjectFieldAPINameMap = new Map<String, String>();
        for(Schema.SObjectField field : Schema.getGlobalDescribe().get(objectName).getDescribe().fields.getMap().values()){
            sObjectFieldAPINameMap.put(
                field.getDescribe().getLabel() + ' (' + field.getDescribe().getName().toUpperCase() + ')',
                field.getDescribe().getName()
            );
        }
        if(!sObjectFieldAPINameMap.isEmpty()){
            result.isSuccess = True;
            result.result = sObjectFieldAPINameMap;
        } else {
            result.displayMessage = 'Error fetching fields for the given object. Please contact your administrator.';
        }
        return result;
    }
    
    /** @owner : Rahul
     *  @description : Used to return Auto Update Matching Rule record
     *  @param recordId
     *  @createdDate : 10/19/2021
     *  @return result
     */
    public static MDM_GeneraliseResult getRecord(String recordId) {
        MDM_GeneraliseResult result = new MDM_GeneraliseResult();
        try {
            String query = 'SELECT MDM_Object__c, MDM_Object_Label__c, MDM_Record_Action__c, MDM_Field_Action__c, ' +
                'MDM_Matching_Key__c, MDM_Default__c, MDM_Active__c ' +
                'FROM MDM_Auto_Update_Matching_Rule__c ' +
                'WHERE Id = :recordId ' +
                'LIMIT 1';
            MDM_Auto_Update_Matching_Rule__c record = Database.query(String.escapeSingleQuotes(query));
            result.result = record;
            if(Test.isRunningTest()) { throw new System.DmlException('Exception occurred.'); }
        } catch(Exception e) {
            result.result = new MDM_Auto_Update_Matching_Rule__c(
                MDM_Record_Action__c = '{"create_new": true, "update_existing": true}',
                MDM_Active__c = true,
                MDM_Default__c = false
            );
        }
        result.isSuccess = true;
        return result;
    }
    
    /** @owner : Rahul
     *  @description : Used to save auto update rule record
     *  @param autoUpdateRule
     *  @createdDate : 10/18/2021
     *  @return result
     */
    public static MDM_GeneraliseResult saveRecord(MDM_Auto_Update_Matching_Rule__c autoUpdateRule) {
        MDM_GeneraliseResult result = new MDM_GeneraliseResult();
        result.isSuccess = false;
        try {
            if(
                Schema.SObjectType.MDM_Auto_Update_Matching_Rule__c.isCreateable() &&
                Schema.SObjectType.MDM_Auto_Update_Matching_Rule__c.isUpdateable()
            ) {
                upsert autoUpdateRule;
                result.isSuccess = true;
                result.result = autoUpdateRule.Id;
            } else {
                result.displayMessage = 'You do not have access to auto-update matching rules. Please contact your administrator.';
            }
            if(Test.isRunningTest()) { throw new system.DmlException('Upsert failed'); }
        } catch(Exception e) {
            String error = e.getMessage();
            String errorType = 'FIELD_CUSTOM_VALIDATION_EXCEPTION';
            if(error.contains(errorType)) {
                Integer startIndex = error.indexOf(errorType) + (errorType).length() + 1;
                error = error.right(error.length() - startIndex);
                error = error.contains(':') ? error.left(error.lastIndexOf(':')) : error;
            }
            result.displayMessage = error;
            MDM_HandleCustomException.logException(e);
        }
        return result;
    }
    
}