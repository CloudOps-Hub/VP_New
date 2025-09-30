/**
 * @description       : 
 * @author            : Dhruv Agrawal
 * @group             : 
 * @last modified on  : 05-19-2021
 * @last modified by  : Komal Sonsale
 * Modifications Log 
 * Ver   Date         Author          Modification
 * 1.0   03-26-2021   Dhruv Agrawal   Initial Version
**/

public with sharing class MDM_SalesforceUitility {
    
    //TO:DO use enum for DMl operation
    public enum ApexDMLOptions { APEX_INSERT, APEX_UPDATE, APEX_DELETE, APEX_UNDELETE, APEX_MERGE }
    private static MDM_GeneraliseResult mdmGeneraliseResultInstance;

    /**
     * @description performs specified dml operation if the records are type casted
     * @param records
     * @param dmlOperation
     */
    public static void handleDMLOperation(List<sObject> records, String dmlOperation) {
        SObjectType objType = records[0].getSObjectType();
        if(dmlOperation.equalsIgnoreCase('Insert') && objType.getDescribe().isCreateable()) {    
            insert records;
        } else if(dmlOperation.equalsIgnoreCase('Update') && objType.getDescribe().isUpdateable()) {
            update records;
        } else if(dmlOperation.equalsIgnoreCase('Upsert') &&  objType.getDescribe().isCreateable() && objType.getDescribe().isUpdateable() ) {
            upsert records;
        } else if(dmlOperation.equalsIgnoreCase('Delete') && objType.getDescribe().isDeletable()) {
            delete records;
        } else if(dmlOperation.equalsIgnoreCase('undelete')) {
            undelete records;
        }
    }
    
    /** 
     * @description Method to handle apex DML operations.(bulkify)
     * @param sObjectList - sObject list for DML operation
     * @param sfObjectName - API name of base Object.
     * @param dmlOperation - contains specific DML operation to be done.
     * @return MDM_GeneraliseResult
     */
    public static MDM_GeneraliseResult apexDMLHandler(List<sObject> sObjectList, String sfObjectName, String dmlOperation) {
        mdmGeneraliseResultInstance = new MDM_GeneraliseResult();
        List<sObject> records = getTypeCastedSObjectList(sfObjectName);
        if(records != null) {
            records.addAll(sObjectList);        
            try {
                handleDMLOperation(records, dmlOperation);                
                mdmGeneraliseResultInstance.isSuccess = true;
                mdmGeneraliseResultInstance.displayMessage = 'Data ' + dmlOperation + ' Successful!';
                mdmGeneraliseResultInstance.result = records;
            } catch(Exception exp) {
                //logMessageFromException(exp);
                mdmGeneraliseResultInstance.displayMessage = 'Data ' + dmlOperation + ' Failure!';
            }
            return mdmGeneraliseResultInstance;
        }
        mdmGeneraliseResultInstance.displayMessage = 'Object Not Found --> ' + sfObjectName;
        return mdmGeneraliseResultInstance;
    }
    
    /** 
     * @description Method returns Type Casted SObject list.
     * @param sfObjectName - SF Object API name.
     * @return List<SObject> List Of Type Casted sObject List.
     */
    public static List<SObject> getTypeCastedSObjectList(String sfObjectName) {
    	mdmGeneraliseResultInstance = new MDM_GeneraliseResult();
        mdmGeneraliseResultInstance = checkSObjectAvailability(sfObjectName);
        if(mdmGeneraliseResultInstance.isSuccess) {
            Type sObjectListType = Type.ForName('List<' + sfObjectName + '>');             
            return (List<SObject>) sObjectListType.newInstance();
        }
        return null;
    }
    
    /** 
     * @description Method returns the recordtype Id(string) from it's name 
     * @param sfObjectName - SF Object API name.
     * @param recordTypeName - RecordType name of same Object.
     * @return MDM_GeneraliseResult - String(ID)
     */
    
    public static MDM_GeneraliseResult getObjectRecordTypeId(String sfObjectName, String recordTypeName) {
        String recordTypeId = '';
        mdmGeneraliseResultInstance = new MDM_GeneraliseResult();
        
        // Check sObject Availability in Org.
        mdmGeneraliseResultInstance = checkSObjectAvailability(sfObjectName);
        if (!mdmGeneraliseResultInstance.isSuccess) {
            mdmGeneraliseResultInstance.displayMessage = 'Object Not Found --> ' + sfObjectName;
            return mdmGeneraliseResultInstance;
        }
        
        // Get sObjectType result.
        Schema.SObjectType objType = Schema.getGlobalDescribe().get(sfObjectName);
        if (objType == null){
            mdmGeneraliseResultInstance.isSuccess = false;
            mdmGeneraliseResultInstance.displayMessage = 'Object Type Retrieve Failure For Object --> ' + sfObjectName;
            return mdmGeneraliseResultInstance;
        }
        
        //Generate a map of tokens for all the Record Types for the desired object
        Map<string, schema.recordtypeinfo> recordTypeInfo = objType.getDescribe().getRecordTypeInfosByName();
    
        if(!recordTypeInfo.containsKey(recordTypeName)) {
            mdmGeneraliseResultInstance.isSuccess = false;
            mdmGeneraliseResultInstance.displayMessage = 'Record Type "'+ recordTypeName +'" Does Not Exist For Object --> '+ sfObjectName;
            throw new RecordTypeException('Record type "'+ recordTypeName +'" does not exist.');
        } else {
            //Retrieve the record type id by name
            recordTypeId = recordTypeInfo.get(recordTypeName).getRecordTypeId();
            mdmGeneraliseResultInstance.displayMessage = 'Record Type Id Retrieved Successful!';
            mdmGeneraliseResultInstance.result = recordTypeId;
        }        
        return mdmGeneraliseResultInstance;
    }
	    

    /**
     * @description Method for check sObject Availability.
     * @param objName - API name of SF object(standard/custom)
     * @return MDM_GeneraliseResult Boolean is assure presence of object in SF.
     */
    public static MDM_GeneraliseResult checkSObjectAvailability(String objName) {
        mdmGeneraliseResultInstance = new MDM_GeneraliseResult();
        //get the string to sobject global map
        mdmGeneraliseResultInstance.isSuccess = Schema.getGlobalDescribe().containsKey(objName);
        mdmGeneraliseResultInstance.displayMessage = (mdmGeneraliseResultInstance.isSuccess) ? 
                                                  'sObject Available In Org' :
                                                  'sObject Not Available In Org';
        return mdmGeneraliseResultInstance;
    }
        
    /**
     * @description Public class to throw custom Exception.
     */
    public class RecordTypeException extends Exception{}
}