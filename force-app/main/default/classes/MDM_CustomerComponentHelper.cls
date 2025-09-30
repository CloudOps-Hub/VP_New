/**
 * @description       : 
 * @author            : Dhruv Agrawal
 * @group             : 
 * @last modified on  : 06-10-2021
 * @last modified by  : Komal Sonsale
 * Modifications Log 
 * Ver   Date         Author          Modification
 * 1.0   03-26-2021   Dhruv Agrawal   Initial Version
**/


public with sharing class MDM_CustomerComponentHelper {
    /**
     * @description : this wrapper will have customer search details
     */
    public class MDM_GetCustomerWrapper{
        String sObjectName;
        String sObjectFields;
        String sObjectFilterField;
        String fieldToken;
    }

    /** 
    * @description : Returns the query result based on sobject name ,filter fields, field token
    * @param customerJSON
    * @return MDM_GeneraliseResult 
    */
    @auraEnabled
    Public static MDM_GeneraliseResult getCustomers(String customerJSON) {
        MDM_GetCustomerWrapper custWrap = (MDM_GetCustomerWrapper) JSON.deserialize(customerJSON, MDM_GetCustomerWrapper.class); 
        String likeToken = '%'+custWrap.fieldToken+'%';
        MDM_GeneraliseResult finalResult = new MDM_GeneraliseResult();
        String query = 'SELECT Id,'+ String.escapeSingleQuotes(custWrap.sObjectFields) +' FROM ';
        query += String.escapeSingleQuotes(custWrap.sObjectName) +' WHERE ';
        query += String.escapeSingleQuotes(custWrap.sObjectFilterField) +' LIKE \'';
        query += String.escapeSingleQuotes(likeToken) +'\' LIMIT 500';
        finalResult.result = Database.query(query);
        finalResult.isSuccess= true;
        return finalResult;
    }
    
    /** 
    * @description : will return Map of all sobjectName,sobjectFields provided in JSON.
    * @param jsonFields
    * @return MDM_GeneraliseResult 
    */
    @AuraEnabled
    public static MDM_GeneraliseResult getCustomerField(String jsonFields){
        MDM_GeneraliseResult finalResult = new MDM_GeneraliseResult();
        List<String> custRegistartionFieldList = (List<String>) JSON.deserialize(jsonFields, List<String>.class);
        Map<String,Set<String>> objectFieldListMap = new Map<String,Set<String>>();
        String sObjectType='' ;
        for(String custField : custRegistartionFieldList){
            Map<String,List<String>> custRegistartionFieldMap =
                	(Map<String,List<String>>) JSON.deserialize(custField,Map<String,List<String>>.class);
            for(String fieldLstType : custRegistartionFieldMap.keySet()){
                if(fieldLstType == 'sObjectType'){
                    sObjectType = custRegistartionFieldMap.get('sObjectType')[0];
                }else{
                    if(!objectFieldListMap.containsKey(sObjectType)){
                        objectFieldListMap.put(sObjectType,new Set<String>());
                    }
                    objectFieldListMap.get(sObjectType).addAll(custRegistartionFieldMap.get(fieldLstType));
                }
            }
            
        }
        try{
            finalResult.result = getVerifiedObjectFieldListMap(objectFieldListMap);
            finalResult.isSuccess= true;
        }catch(Exception e){
 			MDM_HandleCustomException.logException(e);
            finalResult.isSuccess= false;
            finalResult.displayMessage = e.getMessage();
        }        
        return finalResult;
    }

    /**
     * @description : this method will return verifiedObjectFieldListMap
     * @param objectFieldListMap
     * @return Map<String,Set<String>>
     */

    static Map<String,Set<String>> getVerifiedObjectFieldListMap(Map<String,Set<String>> objectFieldListMap){
        Map<String,Set<String>> verifiedObjectFieldListMap = new Map<String,Set<String>>();
        for(String sObj : objectFieldListMap.keySet()){
            MDM_GeneraliseResult verifiedObjFieldResult = validateSobjectFields(sObj,objectFieldListMap.get(sObj));
            if(verifiedObjFieldResult.isSuccess){
                Map<String,Set<String>> sObjectFieldListMap = (Map<String,Set<String>>)(verifiedObjFieldResult.result);
                verifiedObjectFieldListMap.putAll(sObjectFieldListMap);
            }
        }
        return verifiedObjectFieldListMap; 
    }
      
    /** 
    * @description : will return Map of sobjectName and set of sobject field APIname..
    * @param sObjectName
    * @param fields
    * @return MDM_GeneraliseResult 
    */
    static MDM_GeneraliseResult validateSobjectFields(String sObjectName, Set<String> fields){
        MDM_GeneraliseResult finalResult = new MDM_GeneraliseResult();
        MDM_GeneraliseResult fieldResult = MDM_SchemaService.getFields(sObjectName);
        List<MDM_SchemaService.FieldDescriptor> verifiedObjectFieldResult = new List<MDM_SchemaService.FieldDescriptor>();
        Map<String,Set<String>> sObjectFieldListMap = new Map<String,Set<String>>();
        for(MDM_SchemaService.FieldDescriptor fieldDetail : (List<MDM_SchemaService.FieldDescriptor>)fieldResult.Result){
            
            if(fields.contains(fieldDetail.fieldName)){
                verifiedObjectFieldResult.add(fieldDetail);
                if(!sObjectFieldListMap.containsKey(sObjectName)){
                    sObjectFieldListMap.put(sObjectName,new Set<String>{fieldDetail.fieldName});
                }
                sObjectFieldListMap.get(sObjectName).add(fieldDetail.fieldName);
            }
        }
        
        finalResult.result = sObjectFieldListMap;
        finalResult.isSuccess = true;
        return finalResult;
    }
    
    /** 
    * @description : getFields() will return the schema of sobjectfields.    
    * @param sObjectType
    * @return MDM_GeneraliseResult 
    */
    @AuraEnabled
    public static MDM_GeneraliseResult getFields(String sObjectType) {
        return MDM_SchemaService.getFields(sObjectType);
    }
           
    /** 
    * @description : method for geting related results of customer Staging Record from its recordID.
    * @param recordID
    * @return : list<object>
    */
    @AuraEnabled
    public static list<object> getRelatedLists(String recordID) {
        List<object> result=new List<object>();
        //try{
            MDM_Customer_Staging__c custStaging=[
                SELECT Id, MDM_Industry_Type__c, (
                    SELECT Id,Name,MDM_Source_System__c,MDM_Source_System_Id__c
                     FROM Source_Customer_Stagings__r
                ),
                (
                    SELECT Id,name,MDM_Address_1__c,MDM_Address_2__c,MDM_Address_3__c,MDM_City__c,MDM_State__c,
                    MDM_Source_System_Id__c,MDM_Country__c,MDM_Address_Type__c,MDM_Email__c,MDM_Phone__c,
                    MDM_Contact_Staging__c,MDM_Contact_Staging__r.Name,MDM_Status__c,MDM_External_System_Name__c,
                    MDM_Source_System_Primary__c,MDM_Source_System_Verified__c
                    FROM Address_Stagings__r
                ),(
                    SELECT Id, Name,MDM_Phone__c,MDM_Email__c,MDM_Source_System_Id__c,MDM_External_System_Name__c 
                    FROM Contact_Stagings__r
                )
                FROM MDM_Customer_Staging__c WHERE Id=:recordID WITH SECURITY_ENFORCED limit 1
            ];
            
            result.add(custStaging.Address_Stagings__r);
            result.add(custStaging.Contact_Stagings__r);
            result.add(custStaging.Source_Customer_Stagings__r);
        return result;
    }
}