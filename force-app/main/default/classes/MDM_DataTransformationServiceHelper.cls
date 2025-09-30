/**
 * @description       : 
 * @author            : Priya Sharma
 * @group             : 
 * @last modified on  : 03-23-2021
 * @last modified by  : Priya Sharma
 * Modifications Log 
 * Ver   Date         Author         Modification
 * 1.0   03-23-2021   Priya Sharma   Initial Version
**/


 public with sharing class MDM_DataTransformationServiceHelper {
    
    public static Map<String, MDM_SchemaService.FieldDescriptor> fieldDescriptorMap;
    
    static String transformAnywhere(String fieldVal, MDM_Attribute_Transformation_Item__c listAttribute) {
        if(!listAttribute.MDM_Case_Sensitive__c) {
            fieldval = fieldval.replaceAll('(?i)'+listAttribute.MDM_Old_Value__c, listAttribute.MDM_New_Value__c);
        } else if(fieldVal.contains(listAttribute.MDM_Old_Value__c)) {fieldval = fieldval.replaceAll(listAttribute.MDM_Old_Value__c, listAttribute.MDM_New_Value__c);
            }
        return fieldVal;
    }

    static String transformCaseInsensitiveWord(String fieldVal, MDM_Attribute_Transformation_Item__c listAttribute) {
        List<string> fieldArray = fieldVal.split(' ');
        for(Integer index = 0; index<fieldArray.size(); index++) {
            if(fieldArray[index].equalsIgnoreCase(listAttribute.MDM_Old_Value__c)) {
                fieldArray[index] = listAttribute.MDM_New_Value__c;
            }
        }
        return String.join(fieldArray, ' ');
    }

    static String transformWord(String fieldVal, MDM_Attribute_Transformation_Item__c listAttribute) {
        if(!listAttribute.MDM_Case_Sensitive__c) { fieldVal = transformCaseInsensitiveWord(fieldVal, listAttribute); } 
        else if(fieldVal.contains(listAttribute.MDM_Old_Value__c)) {  
            string regex='\\b(\\w*(\\b'+listAttribute.MDM_Old_Value__c+'\\b)\\w*)\\b';
       		fieldval = fieldval.replaceAll(regex, listAttribute.MDM_New_Value__c);
        }
        return fieldVal;
    }

    /** 
     * @description Transforms each field values
     * @param record : record to be updated
     * @param dataTransormationRule
     * @param attributeItems
     */
    public static void transform(
        sObject record, 
        MDM_Data_Transformation_Rule__c dataTransormationRule,
        List<MDM_Attribute_Transformation_Item__c> attributeItems
    ) {
        String fieldApiName = dataTransormationRule.MDM_Data_Quality__r.MDM_Field_Api_Name__c;
        if(attributeItems == NULL || record.get(fieldApiName) == NULL) { return; }
        
        String fieldType = fieldDescriptorMap.get(dataTransormationRule.MDM_Data_Quality__r.MDM_Field_Api_Name__c).fieldType;
        
        Integer fieldLength = fieldDescriptorMap.get(dataTransormationRule.MDM_Data_Quality__r.MDM_Field_Api_Name__c).fieldLength; 
        for(MDM_Attribute_Transformation_Item__c listAttribute : attributeItems) {
            listAttribute.MDM_New_Value__c = listAttribute.MDM_New_Value__c == NULL ? '' : listAttribute.MDM_New_Value__c;
            string fieldVal = string.valueOf(record.get(fieldApiName));
            if(listAttribute.MDM_Type__c == 'Anywhere') { fieldVal = transformAnywhere(fieldVal, listAttribute); }
            if(listAttribute.MDM_Type__c == 'Word') { fieldVal = transformWord(fieldVal, listAttribute); }
            if(fieldType == 'STRING' && fieldval.length() > fieldLength) { fieldval = fieldval.left(fieldLength); }
            record.put(fieldApiName,fieldval);
        }
    }
}