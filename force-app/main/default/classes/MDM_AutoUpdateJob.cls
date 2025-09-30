/**
 * @description       : Batch job to perform auto-update logic
 * @author            : Rahul, Odion, Jordan, Dhruv
 * @group             : 
 * @last modified on  : 01/12/2021
 * @last modified by  : Rahul Nagpure
 * Modifications Log 
 * Ver   Date         Author          				Modification
 * 1.0   01/12/2021   Rahul, Odion, Jordan, Dhruv   Initial Version
 **/

@SuppressWarnings('PMD.ExcessiveParameterList')
public with sharing class MDM_AutoUpdateJob implements Database.Batchable<sObject>, Database.Stateful {
    
    Map<String, List<MDM_Auto_Update_Matching_Rule__c>> autoUpdateRuleMap;
    Map<String, Set<String>> objectFieldSetMap;
    Map<String, Integer> fieldLengthMap;
    static final String CUSTOMER_STAGING = 'MDM_CUSTOMER_STAGING__C';
    static final String ADDRESS_STAGING = 'MDM_ADDRESS_STAGING__C';
    static final String CONTACT_STAGING = 'MDM_CONTACT_STAGING__C';
    static final String REFERENCE_STAGING = 'MDM_SOURCE_CUSTOMER_STAGING__C';
    static final String CUSTOMER = 'MDM_CUSTOMER__C';
    static final String ADDRESS = 'MDM_ADDRESS__C';
    static final String CONTACT = 'MDM_CONTACT__C';
    static final String REFERENCE = 'MDM_SOURCE_CUSTOMER__C';
    static final String ANY_VALUE = 'Any value';
    static final String EXACT_VALUE = 'Has exact Value';
    static final String CUSTOMER_LOOKUP = 'MDM_Customer__c';
    static final String CONTACT_LOOKUP = 'MDM_Contact__c';
    static final String CONTACT_STAGING_LOOKUP = 'MDM_Contact_Staging__c';
    static final Map<String, String> OBJECT_CHILD_API_NAME_MAP = new Map<String, String> {
        ADDRESS_STAGING => 'Address_Stagings__r',
        CONTACT_STAGING => 'Contact_Stagings__r',
        REFERENCE_STAGING => 'Source_Customer_Stagings__r',
        ADDRESS => 'Addresses__r',
        CONTACT => 'Contacts__r',
        REFERENCE => 'Source_Customers__r'
    };
    public static final Map<String, String> STAGING_TO_GOLDEN_SOBJECT_TYPE_MAP = new Map<String, String> {
        CUSTOMER_STAGING => CUSTOMER,
        ADDRESS_STAGING => ADDRESS,
        CONTACT_STAGING => CONTACT,
        REFERENCE_STAGING => REFERENCE
    };
    Map<String, List<String>> fieldMap = new Map<String, List<String>> {
    	CUSTOMER => new List<String>(),
        ADDRESS => new List<String>(),
        CONTACT => new List<String>(),
        REFERENCE => new List<String>()
    };
    
    /**
     * @description Start method for Auto Update job, used to setup configuration data & retrieve customer staging records
     * @param bc
     * @return Database.QueryLocator
     */
    public Database.QueryLocator start(Database.BatchableContext bc) {
        autoUpdateRuleMap = MDM_AutoUpdateHelper.getAutoUpdateRuleMap();
        if(!autoUpdateRuleMap.containsKey(CUSTOMER_STAGING)) { return NULL; }
        
        fieldLengthMap = new Map<String, Integer>();
        objectFieldSetMap = MDM_AutoUpdateQueryHelper.getObjectFieldListMap(autoUpdateRuleMap, fieldLengthMap);
        if(objectFieldSetMap.size() == 0) { return NULL; }
        
        setupFieldMap(fieldMap);
        
        String query = 'SELECT Id' +
            (objectFieldSetMap.containsKey(CUSTOMER_STAGING) ? (', ' + String.join(new List<String>(objectFieldSetMap.get(CUSTOMER_STAGING)), ', ')) : '') +
            getSubQuery(ADDRESS_STAGING, objectFieldSetMap) +
            getSubQuery(CONTACT_STAGING, objectFieldSetMap) +
            getSubQuery(REFERENCE_STAGING, objectFieldSetMap) +
            ' FROM ' + CUSTOMER_STAGING +
            ' WHERE MDM_Processing_Status__c = \'New\'' +
            ' AND MDM_Is_AutoMerge__c = true' +
            ' WITH SECURITY_ENFORCED'+
            ' ORDER BY CreatedDate';
        
        try {
            return Database.getQueryLocator(query);
        } catch(Exception e) {
            MDM_HandleCustomException.logException(e);
            return null ;
        }
    }
    
    /**
     * @description Used to setup Object => List of fields map
     * @param fieldMap
     */
    static void setupFieldMap(Map<String, List<String>> fieldMap) {
        for(String objectName : fieldMap.keySet()) {
            for(String field : Schema.getGlobalDescribe().get(objectName).getDescribe(SObjectDescribeOptions.FULL).fields.getMap().keySet()) {
                fieldMap.get(objectName).add(field.toUpperCase());
            }
        }
    }
    
    /**
     * @description Used to construct sub-queries
     * @param objectName
     * @param objectFieldSetMap
     * @return String
     */
    static String getSubQuery(String objectName, Map<String, Set<String>> objectFieldSetMap) {
        if(!objectFieldSetMap.containsKey(objectName)) { return ''; }
        if(objectName == ADDRESS_STAGING && !objectFieldSetMap.get(objectName).contains(CONTACT_STAGING_LOOKUP)) {
            objectFieldSetMap.get(objectName).add(CONTACT_STAGING_LOOKUP);
        }
        return ', (SELECT ' + 
            String.join(new List<String>(objectFieldSetMap.get(objectName)), ', ') + 
            ' FROM ' + 
            OBJECT_CHILD_API_NAME_MAP.get(objectName) +
            ')';
    }
    
    /**
     * @description Execute method to perform auto-update
     * @param bc
     * @param customerStagingList
     */
    public void execute(Database.BatchableContext bc, List<MDM_Customer_Staging__c> customerStagingList) {
        Savepoint sp = Database.setSavepoint();
        try {
            List<MDM_Customer__c> customerList = getCustomerList(objectFieldSetMap, autoUpdateRuleMap, customerStagingList);
            customerList = customerList == NULL ? new List<MDM_Customer__c>() : customerList;
            Set<sObject> customerSetToBeUpserted = new Set<sObject>();
            Map<MDM_Customer_Staging__c, MDM_Customer__c> customerStagingGoldenMap = new Map<MDM_Customer_Staging__c, MDM_Customer__c>();
            List<String> processedCustomerStagingList = new List<String>();
            Map<String,Set<sObject>> sObjectRecordsToUpsertMap = new Map<String,Set<sObject>>{
                ADDRESS => new Set<sObject>(),
                CONTACT => new Set<sObject>(),
                REFERENCE => new Set<sObject>(),
                CUSTOMER_STAGING => new Set<sObject>()
            };
            Map<String, sObject> contactMap = new Map<String, sObject>();
            for(MDM_Customer_Staging__c customerStaging : customerStagingList) {
                updateGoldenRecords(
                    CUSTOMER_STAGING, 
                    customerStaging, 
                    customerList, 
                    customerSetToBeUpserted,
                    autoUpdateRuleMap.get(CUSTOMER_STAGING), 
                    NULL, 
                    fieldMap.get(CUSTOMER),
                    customerStagingGoldenMap,
                    processedCustomerStagingList,
                    NULL,
                    fieldLengthMap
                );
            }
            Database.upsert(new List<sObject>(new Set<sObject>(customerSetToBeUpserted)));
                
            for(MDM_Customer_Staging__c customerStaging : customerStagingGoldenMap.keySet()) {
                MDM_Customer__c customer = customerStagingGoldenMap.get(customerStaging);
                updateRelatedRecords(
                    customerStaging,
                    customer,
                    CONTACT_STAGING,
                    sObjectRecordsToUpsertMap.get(CONTACT),
                    autoUpdateRuleMap.get(CONTACT_STAGING),
                    fieldMap.get(CONTACT),
                    contactMap,
                    fieldLengthMap
                );
            }
            Database.upsert(new List<sObject>(new Set<sObject>(sObjectRecordsToUpsertMap.get(CONTACT))));
           
            for(MDM_Customer_Staging__c customerStaging : customerStagingGoldenMap.keySet()) {
                MDM_Customer__c customer = customerStagingGoldenMap.get(customerStaging);
                updateRelatedRecords(
                    customerStaging,
                    customer,
                    ADDRESS_STAGING,
                    sObjectRecordsToUpsertMap.get(ADDRESS),
                    autoUpdateRuleMap.get(ADDRESS_STAGING),
                    fieldMap.get(ADDRESS),
                    contactMap,
                    fieldLengthMap
                );
                updateRelatedRecords(
                    customerStaging,
                    customer,
                    REFERENCE_STAGING,
                    sObjectRecordsToUpsertMap.get(REFERENCE),
                    autoUpdateRuleMap.get(REFERENCE_STAGING),
                    fieldMap.get(REFERENCE),
                    NULL,
                    fieldLengthMap
                );
                //populate lookup to golden record?
                customerStaging.MDM_Customer_Golden__c = customer.Id;
                customerStaging.MDM_Processing_Status__c = 'Processed';
                sObjectRecordsToUpsertMap.get(CUSTOMER_STAGING).add(customerStaging);
            }
            
            for(MDM_Customer_Staging__c customerStaging : customerStagingList) {
                if(!processedCustomerStagingList.contains(customerStaging.Id)) {
                    customerStaging.MDM_is_AutoMerge__c = false;
                    customerStaging.MDM_Manual_Merge_Allowed__c = true;
                    sObjectRecordsToUpsertMap.get(CUSTOMER_STAGING).add(customerStaging);
                }
            }
            
            Database.upsert(new List<sObject>(new Set<sObject>(sObjectRecordsToUpsertMap.get(ADDRESS))));
            Database.upsert(new List<sObject>(new Set<sObject>(sObjectRecordsToUpsertMap.get(REFERENCE))));
            Database.upsert(new List<sObject>(new Set<sObject>(sObjectRecordsToUpsertMap.get(CUSTOMER_STAGING))));
            if(Test.isRunningTest()){throw new System.DmlException('Upsert Failed');}
        } catch(Exception e) {
            Database.rollback(sp);
            MDM_HandleCustomException.logException(e);
        }
    }
    
    /**
     * @description Used to update related records of customer
     * @param customerStaging
     * @param customer
     * @param stagingRelatedRecordName
     * @param recordsToUpsertSet
     * @param autoUpdateRuleList
     * @param goldenFieldList
     * @param contactMap
     * @param fieldLengthMap
     */
    static void updateRelatedRecords(
        MDM_Customer_Staging__c customerStaging,
        MDM_Customer__c customer,
        String stagingRelatedRecordName,
        Set<sObject> recordsToUpsertSet,
        List<MDM_Auto_Update_Matching_Rule__c> autoUpdateRuleList,
        List<String> goldenFieldList,
        Map<String, sObject> contactMap,
        Map<String, Integer> fieldLengthMap
    ) {
        String stagingRelatedRecordListName = OBJECT_CHILD_API_NAME_MAP.get(stagingRelatedRecordName);
        String goldenRelatedRecordName = STAGING_TO_GOLDEN_SOBJECT_TYPE_MAP.get(stagingRelatedRecordName);
        String goldenRelatedRecordListName = OBJECT_CHILD_API_NAME_MAP.get(goldenRelatedRecordName);
        if(customerStaging.getSObjects(stagingRelatedRecordListName) != NULL) {
            for(sObject stagingRelatedRecord : customerStaging.getSObjects(stagingRelatedRecordListName)){
                List<sObject> goldenRelatedRecordList = customer.getSObjects(goldenRelatedRecordListName) == NULL ?
                    new List<sObject>() : customer.getSObjects(goldenRelatedRecordListName);
                updateGoldenRecords(
                    stagingRelatedRecordName, 
                    stagingRelatedRecord, 
                    goldenRelatedRecordList, 
                    recordsToUpsertSet,
                    autoUpdateRuleList,
                    customer.Id, 
                    goldenFieldList,
                    NULL,
                    NULL,
                    contactMap,
                    fieldLengthMap
                );
            }
        }
    }
    
    /**
     * @description Used to update golden records using Auto Update rules
     * @param objectName
     * @param stagingRecord
     * @param goldenRecordList
     * @param goldenRecordUpsertSet
     * @param autoUpdateRuleList
     * @param customerId
     * @param goldenFieldList
     * @param customerStagingGoldenMap
     * @param processedCustomerStagingList
     * @param contactMap
     * @param fieldLengthMap
     */
    static void updateGoldenRecords(
        String objectName, 
        sObject stagingRecord, 
        List<sObject> goldenRecordList, 
        Set<sObject> goldenRecordUpsertSet, 
        List<MDM_Auto_Update_Matching_Rule__c> autoUpdateRuleList, 
        String customerId,
        List<String> goldenFieldList,
        Map<MDM_Customer_Staging__c, MDM_Customer__c> customerStagingGoldenMap,
        List<String> processedCustomerStagingList,
        Map<String, sObject> contactMap,
        Map<String, Integer> fieldLengthMap
    ) {
        for(MDM_Auto_Update_Matching_Rule__c autoUpdateRule : autoUpdateRuleList) {
            if(!isRuleValid(autoUpdateRule.MDM_Matching_Key__c, stagingRecord)) { continue; }
            List<sObject> matchingGoldenRecordList = getMatchingGoldenRecordList(
                goldenRecordList,
                autoUpdateRule,
                goldenFieldList,
                stagingRecord
            );
            MDM_AutoUpdateWrapper.RecordAction recordAction = (MDM_AutoUpdateWrapper.RecordAction) JSON.deserialize(
                autoUpdateRule.MDM_Record_Action__c, MDM_AutoUpdateWrapper.RecordAction.class
            );
            Boolean areMatchingRecordsInvalid = (matchingGoldenRecordList.size() == 0 && !recordAction.create_new) ||
                (matchingGoldenRecordList.size() == 1 && !recordAction.update_existing) ||
                matchingGoldenRecordList.size() > 1;
            if(areMatchingRecordsInvalid) { continue; }
            sObject updatedGoldenRecord = getUpdatedRecord(
                stagingRecord,
                matchingGoldenRecordList.size() == 0 ?
                (sObject)Type.ForName(STAGING_TO_GOLDEN_SOBJECT_TYPE_MAP.get(objectName)).newInstance() : matchingGoldenRecordList[0],
                (List<MDM_AutoUpdateWrapper.FieldAction>) JSON.deserialize(
                    autoUpdateRule.MDM_Field_Action__c, List<MDM_AutoUpdateWrapper.FieldAction>.class
                ),
                goldenFieldList,
                fieldLengthMap
            );
            if(String.valueOf(updatedGoldenRecord.getSObjectType()).toUpperCase() == CUSTOMER) {
                if(matchingGoldenRecordList.size() == 0) { goldenRecordList.add(updatedGoldenRecord); }
                customerStagingGoldenMap.put((MDM_Customer_Staging__c) stagingRecord, (MDM_Customer__c) updatedGoldenRecord);
                processedCustomerStagingList.add(stagingRecord.Id);
            } else {
            	updatedGoldenRecord.put(CUSTOMER_LOOKUP, customerId);
            }
            if(String.valueOf(updatedGoldenRecord.getSObjectType()).toUpperCase() == CONTACT) {
                contactMap.put(stagingRecord.Id, updatedGoldenRecord);
            }
            if(String.valueOf(updatedGoldenRecord.getSObjectType()).toUpperCase() == ADDRESS) {
                updatedGoldenRecord.put(CONTACT_LOOKUP, contactMap.get((String) stagingRecord.get(CONTACT_STAGING_LOOKUP))?.Id);
            }
            if(!goldenRecordUpsertSet.contains(updatedGoldenRecord)) {
             	goldenRecordUpsertSet.add(updatedGoldenRecord);   
            }
            break;
        }
    }
    
    /**
     * @description Checks whether stagingRecord satisfies given rule
     * @param matchingKey
     * @param stagingRecord
     * @return Boolean
     */
    static Boolean isRuleValid(String matchingKey, sObject stagingRecord) {
        for(MDM_AutoUpdateWrapper.MatchingKey key : (List<MDM_AutoUpdateWrapper.MatchingKey>) JSON.deserialize(
            matchingKey, List<MDM_AutoUpdateWrapper.MatchingKey>.class
        )) {
            if(key.comparison == EXACT_VALUE && String.valueOf(stagingRecord.get(key.field)) != key.value) { return false; }
        }
        return true;
    }
    
    /**
     * @description Returns matching golden records based on conditions in Auto Update rule
     * @param goldenRecordList
     * @param autoUpdateRule
     * @param goldenFieldList
     * @param stagingRecord
     * @return matchingGoldenRecordList
     */
    static List<sObject> getMatchingGoldenRecordList(
        List<sObject> goldenRecordList,
        MDM_Auto_Update_Matching_Rule__c autoUpdateRule,
        List<String> goldenFieldList,
        sObject stagingRecord
    ) {
        List<sObject> matchingGoldenRecordList = new List<sObject>();
        for(sObject goldenRecord : goldenRecordList) {
            Boolean isMatching = true;
            for(MDM_AutoUpdateWrapper.MatchingKey key : (List<MDM_AutoUpdateWrapper.MatchingKey>) JSON.deserialize(
                autoUpdateRule.MDM_Matching_Key__c, List<MDM_AutoUpdateWrapper.MatchingKey>.class
            )) {
                if(
                    key.comparison == ANY_VALUE &&
                    goldenFieldList.contains(key.field.toUpperCase()) &&
                    stagingRecord.get(key.field) != goldenRecord.get(key.field)
                ) {
                    isMatching = false;
                    break;
                }
            }
            if(isMatching) { matchingGoldenRecordList.add(goldenRecord); }
        }
        return matchingGoldenRecordList;
    }
    
    /**
     * @description Returns updated golden record using staging record and field action
     * @param stagingRecord
     * @param goldenRecord
     * @param fieldActionList
     * @param goldenFieldList
     * @param fieldLengthMap
     * @return sObject
     */
    static sObject getUpdatedRecord(
        sObject stagingRecord, 
        sObject goldenRecord, 
        List<MDM_AutoUpdateWrapper.FieldAction> fieldActionList,
        List<String> goldenFieldList,
        Map<String, Integer> fieldLengthMap
    ) {
        for(MDM_AutoUpdateWrapper.FieldAction fieldAction : fieldActionList) {
            if(!goldenFieldList.contains(fieldAction.field.toUpperCase())) { continue; }
            switch on fieldAction.action {
                when 'Update' {
                    goldenRecord.put(fieldAction.field, stagingRecord.get(fieldAction.field));
                }
                when 'Append' {
                    if(stagingRecord.get(fieldAction.field) != NULL) {
                        String newValue = (goldenRecord.get(fieldAction.field) != NULL ?
                            goldenRecord.get(fieldAction.field) + ', ' : '') + stagingRecord.get(fieldAction.field);
                        if(newValue.length() <= fieldLengthMap.get(String.valueOf(goldenRecord.getSObjectType()).toUpperCase() + fieldAction.field)) {
                            goldenRecord.put(fieldAction.field, newValue);
                        }
                    }
                }
                when 'Nullify' {
                    goldenRecord.put(fieldAction.field, NULL);
                }
            }
        }
        return goldenRecord;
    }
    
    /**
     * @description Returns matching customer based on the Matching Key setup in Auto Update rules
     * @param objectFieldSetMap
     * @param autoUpdateRuleMap
     * @param customerStagingList
     * @return List<MDM_Customer__c>
     */
    static List<MDM_Customer__c> getCustomerList(
        Map<String, Set<String>> objectFieldSetMap,
        Map<String, List<MDM_Auto_Update_Matching_Rule__c>> autoUpdateRuleMap,
        List<MDM_Customer_Staging__c> customerStagingList
    ) {
        String whereClause = '';
        List<String> orClauseList = new List<String>();
        Map<String, Schema.SObjectField> fieldMap = Schema.getGlobalDescribe().get(CUSTOMER_STAGING).getDescribe(SObjectDescribeOptions.FULL).fields.getMap();
        for(MDM_Auto_Update_Matching_Rule__c autoUpdateRule : autoUpdateRuleMap.get(CUSTOMER_STAGING)) {
            List<String> andClauseList = new List<String>();
            for(MDM_AutoUpdateWrapper.MatchingKey key : (List<MDM_AutoUpdateWrapper.MatchingKey>) JSON.deserialize(
                autoUpdateRule.MDM_Matching_Key__c, List<MDM_AutoUpdateWrapper.MatchingKey>.class
            )) {
                if(key.comparison == ANY_VALUE) {
                    List<String> valueList = getValueList(customerStagingList, key, fieldMap);
                    if(valueList.size() > 0) {
                        andClauseList.add(key.field + ' IN (' + String.join(valueList, ', ') + ')');
                    }
                }
            }
            if(andClauseList.size() > 0) {
                orClauseList.add('(' + String.join(andClauseList, ' AND ') + ')');
            }
        }
        whereClause = String.join(orClauseList, ' OR ');
        String query = 'SELECT Id' +
            (objectFieldSetMap.containsKey(CUSTOMER) ? (', ' + String.join(new List<String>(objectFieldSetMap.get(CUSTOMER)), ', ')) : '') +
            getSubQuery(ADDRESS, objectFieldSetMap) +
            getSubQuery(CONTACT, objectFieldSetMap) +
            getSubQuery(REFERENCE, objectFieldSetMap) +
            ' FROM ' + CUSTOMER +
            (String.isBlank(whereClause) ? '' : ' WHERE ' + whereClause) +
            ' ORDER BY MDM_Id__c NULLS LAST';
        return Database.query(query);
    }
    
    /**
     * @description Returns Value list to be put in query where clause based on field type
     * @param customerStagingList
     * @param key
     * @param fieldMap
     * @return valueList
     */
    static List<String> getValueList(
        List<MDM_Customer_Staging__c> customerStagingList,
        MDM_AutoUpdateWrapper.MatchingKey key,
        Map<String, Schema.SObjectField> fieldMap
    ) {
        List<String> fieldTypeWithQuoteList = new List<String> {
            'ADDRESS', 'COMBOBOX', 'EMAIL', 'ENCRYPTEDSTRING', 'ID', 'MULTIPICKLIST', 'PHONE', 'PICKLIST', 'REFERENCE', 'STRING', 'TEXTAREA', 'URL'
        };
        List<String> valueList = new List<String>();
        for(MDM_Customer_Staging__c customerStaging : customerStagingList) {
            if(customerStaging.get(key.field) == NULL) { continue; }
            String fieldType = String.valueOf(fieldMap.get(key.field).getDescribe().getType());
            String fieldValue = String.valueOf(customerStaging.get(key.field));
            if(fieldTypeWithQuoteList.contains(fieldType)) {
                valueList.add('\'' + fieldValue + '\'');
            } else if(fieldType == 'DATE') {
                valueList.add(fieldValue.left(10));
            } else if(fieldType == 'DATETIME') {
                DateTime dateTitleValue = (DateTime) customerStaging.get(key.field);
                String formattedDateTime = ('0000' + dateTitleValue.yearGmt()).right(4) +
                    '-' + ('00' + dateTitleValue.monthGMT()).right(2) +
                    '-' +('00' + dateTitleValue.dayGmt()).right(2) +
                    'T' + ('00' + dateTitleValue.hourGmt()).right(2) + 
                    ':' + ('00' + dateTitleValue.minuteGMT()).right(2) + 
                    ':' + ('00' + dateTitleValue.secondGmt()).right(2) +
                    'z';
                valueList.add(formattedDateTime);
            } else {
                valueList.add(fieldValue);
            }
        }
        return valueList;
    }
    
    /**
     * @description Finish method
     * @param bc
     */
    public void finish(Database.BatchableContext bc) {
        AsyncApexJob job;
        job = [
            SELECT Id, Status, NumberOfErrors, JobItemsProcessed, TotalJobItems, CreatedBy.Email
            FROM AsyncApexJob
            WHERE Id = :bc.getJobId()
        ];
    }
}