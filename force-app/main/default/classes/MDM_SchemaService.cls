/**
 * @description       : 
 * @author            : Dhruv Agrawal
 * @group             : 
 * @last modified on  : 03-19-2021
 * @last modified by  : Dhruv Agrawal
 * Modifications Log 
 * Ver   Date         Author          Modification
 * 1.0   03-19-2021   Dhruv Agrawal   Initial Version
**/

public with sharing class MDM_SchemaService {
    /**
    * @description Returns schema of particular fields
    */
    public class FieldDescriptor implements Comparable {
        @AuraEnabled public String fieldName;
        @AuraEnabled public String fieldLabel;
        @AuraEnabled public Boolean isUpdatable;
        @AuraEnabled public Boolean isFilterable;
        @AuraEnabled public String fieldType;
        @AuraEnabled public Integer fieldLength;
        /**
         * @description Returns field schema
         * @param fieldName This field contains field name
         * @param fieldLabel This field contains field label
         * @param isUpdatable
         * @param isFilterable
         * @param fieldType
         * @param fieldLength
         */
        @SuppressWarnings('PMD.ExcessiveParameterList') //required to initialize all parameters of object
        public FieldDescriptor(
            String fieldName, String fieldLabel, Boolean isUpdatable, Boolean isFilterable, String fieldType, Integer fieldLength
        ) {
            this.fieldName = fieldName;
            this.fieldLabel = fieldLabel;
            this.isUpdatable = isUpdatable;
            this.isFilterable = isFilterable;
            this.fieldType = fieldType;
            this.fieldLength = fieldLength; 
        }
        /**
         * @description This field compares fieldLabel with Objects
         * @param objToCompare
         * @return fieldLabel
         */
        public Integer compareTo(Object objToCompare) {
            //Sort by BookName Alphabetically
            return fieldLabel.compareTo(((FieldDescriptor)objToCompare).fieldLabel);
        }
    }
    /**
     * @description Returns schema of Object
     */
    public class SObjectDescriptor implements Comparable {
        @AuraEnabled public String sObjectName;
        @AuraEnabled public String sObjectLabel;
        @AuraEnabled public Boolean isAccessible;
        @AuraEnabled public Boolean isCustom;
        @AuraEnabled public Boolean isCreateable;
        @AuraEnabled public Boolean isQueryable;
        /**
         * @description Returns Object schema
         * @param sObjectName This object contains field name
         * @param sObjectLabel This object contains field label
         * @param isAccessible
         * @param isCustom
         * @param isCreateable
         * @param isQueryable
         */
        @SuppressWarnings('PMD.ExcessiveParameterList') //required to initialize all parameters of object
        public SObjectDescriptor(
            String sObjectName, String sObjectLabel, Boolean isAccessible, Boolean isCustom, Boolean isCreateable, Boolean isQueryable
        ) {
            this.sObjectName = sObjectName;
            this.sObjectLabel = sObjectLabel;
            this.isAccessible = isAccessible;
            this.isCustom = isCustom;
            this.isCreateable = isCreateable;
            this.isQueryable = isQueryable;            
        }
        /**
         * @description This field compares sObjectLabel with Objects
         * @param objToCompare
         * @return sObjectLabel
         */
        public Integer compareTo(Object objToCompare) {
            //Sort by BookName Alphabetically
            return sObjectLabel.compareTo(((SObjectDescriptor)objToCompare).sObjectLabel);
        }
    }
   
    /** 
     * @description Returns the list of sObjects
     * @return : finalResult
     */
    @AuraEnabled
    public static  MDM_GeneraliseResult getSObjects(){
        MDM_GeneraliseResult finalResult = new MDM_GeneraliseResult();
        List<SObjectDescriptor> sObjectLabels = new List<SObjectDescriptor>();
        Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
        for ( Schema.SObjectType sObjType : schemaMap.values() ) {
            Schema.DescribeSObjectResult objResult = sObjType.getDescribe();
            sObjectLabels.add(new SObjectDescriptor(objResult.getName(),
                                                    objResult.getLabel(),
                                                    objResult.isAccessible(),
                                                    objResult.isCustom(),
                                                    objResult.isCreateable(),
                                                     objResult.isQueryable()));
        }
        sObjectLabels.sort();
        finalResult.result = sObjectLabels;
        return finalResult;
    }
   
    /** 
     * @description Returns the List<FieldDescriptor> for selectedsObjectType.
     * @param sObjectType
     * @return : finalResult
     */
    public static MDM_GeneraliseResult getFields(String sObjectType) {
        MDM_GeneraliseResult finalResult = new MDM_GeneraliseResult();
        List<FieldDescriptor> fields = new List<FieldDescriptor>();
        Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
        if( schemaMap.containsKey(sObjectType) ) {
            Schema.SObjectType leadSchema = schemaMap.get(sObjectType);
            Map<String, Schema.SObjectField> fieldMap = leadSchema.getDescribe().fields.getMap();
            for (String fieldName: fieldMap.keySet()) {
                Schema.DescribeFieldResult fieldDesc = fieldMap.get(fieldName).getDescribe();
                fields.add( new FieldDescriptor(fieldDesc.getName(),
                                                fieldDesc.getLabel(),
                                                fieldDesc.isUpdateable(),
                                                fieldDesc.isFilterable(),
                                                String.valueOf(fieldDesc.getType()),
                                                fieldDesc.getLength()));
            }
            fields.sort();
            finalResult.result = fields;
            finalResult.isSuccess = true;
        } else {
            finalResult.isSuccess = false;
            finalResult.displayMessage = 'sObject:'+ sObjectType +' Not Found!';
        }
        return finalResult;
    }
}