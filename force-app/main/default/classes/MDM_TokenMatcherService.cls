/**
 * @description       : Contains the Generic Methods for MDM Search functionality using duplicate and maching rule records.
 * @author            : Komal Sonsale
 * @group             : 
 * @last modified on  : 05-27-2021
 * @last modified by  : Komal Sonsale
 * Modifications Log 
 * Ver   Date         Author          Modification
 * 1.0   03-30-2021   Komal Sonsale   Initial Version
**/

public with sharing class MDM_TokenMatcherService {

    public Static Map<String, String> sObjectToChildRelationName = new Map<String, String> {
        'MDM_Contact__c' => 'Contacts__r',
        'MDM_Address__c' => 'Addresses__r',
        'MDM_Source_Customer__c' => 'Source_Customers__r'
    };
    
    public Static List<String> customerSObjectSequence = new List<String> {
        'MDM_Customer__c','MDM_Contact__c','MDM_Address__c',
        'MDM_Source_Customer__c'    
    };
    public Static Set<String> customerChildSObjects = new Set<String> {
        'MDM_Contact__c','MDM_Address__c',
        'MDM_Source_Customer__c' 
    };
    public Static Map<String, List<String>> customerModalDisplayFields = new Map<String, List<String>> {
        'MDM_Customer__c' => new List<String> {
            'MDM_ID__c','Name','MDM_Description__c','MDM_Customer_Status__c',
            'MDM_Account_Type__c','CreatedDate','LastModifiedDate',
            'MDM_DOI_or_DOB__c', 'MDM_Industry_Type__c', 'MDM_Customer_Id__c',
            'MDM_Customer_Type__c', 'MDM_Email__c', 'MDM_Phone__c' 
        },
        'MDM_Contact__c' => new List<String> { 
            'MDM_Name_Suffix__c', 'Name', 'MDM_Email__c', 'MDM_Phone__c', 'MDM_Status__c', 'MDM_Title__c' 
        },
        'MDM_Address__c' => new List<String> {
            'Name','MDM_Address_1__c','MDM_Address_2__c','MDM_Address_3__c','MDM_Address_Type__c',
            'MDM_City__c','MDM_State__c','MDM_Country__c','MDM_Country_Code__c','MDM_Email__c',
            'MDM_Phone__c','MDM_Contact__c','MDM_Contact__r.Name','MDM_Status__c',
            'MDM_External_System_Name__c','MDM_Source_System_Primary__c'
        },
        'MDM_Source_Customer__c' => new List<String> {	
            'MDM_Source_System__c','MDM_Source_System_Id__c','MDM_Customer__r.Id',
            'MDM_Customer__r.Name','MDM_Customer__r.MDM_ID__c'
        }
    };
    public Static Map<String, String> childToCustomerLookupField = new Map<String, String> {
        'MDM_Contact__c' => 'MDM_Customer__c',
        'MDM_Address__c' => 'MDM_Customer__c',
        'MDM_Source_Customer__c' => 'MDM_Customer__c'		
    };
    public static Set<String> excludeRecordIds = new Set<String> ();
    

    /**
     * @description Function for Collect And Return Golden Records for core MDM sObject.
     * @param goldenWrap Wrapper that contains dataModalJSON, wordBasedMatchingRuleJSON, 
     *                   sObjectType, parentObjectId, performWordBasedSearch
     * @return List<sObject>
     */
    public static List<Object> getGoldenMatches (MDM_LightningComponentService.MDM_FindGoldenMatchesWrapper goldenWrap) 
    {

        MDM_TokenMatcherWrapper.GetGoldenMatchesWrapper goldMatchWrapper = 
                new MDM_TokenMatcherWrapper.GetGoldenMatchesWrapper();
        String dataModalJSON = goldenWrap.dataModalJSON; 
        String wordBasedMatchingRuleJSON = goldenWrap.wordBasedMatchingRuleJSON; 
        goldMatchWrapper.sObjectType = goldenWrap.sObjectType;
        goldMatchWrapper.parentObjectId = goldenWrap.parentObjectId;
        goldMatchWrapper.performWordBasedSearch = goldenWrap.performWordBasedSearch;
        goldMatchWrapper.results = new List<Object> ();
        Map<String, Map<String, MDM_TokenMatcherWrapper.FieldConfig>> wordBasedMatchingRule = 
                            (Map<String, Map<String, MDM_TokenMatcherWrapper.FieldConfig>>) JSON.deserialize (
                                wordBasedMatchingRuleJSON, Map<String, Map<String, MDM_TokenMatcherWrapper.FieldConfig>>.class);
        excludeRecordIds = new Set<String> ();
        if (goldMatchWrapper.sObjectType == 'MDM_Customer__c') {
            MDM_TokenMatcherWrapper.CustomerDataModal customerModal = 
                (MDM_TokenMatcherWrapper.CustomerDataModal) JSON.deserialize (
                    dataModalJSON, MDM_TokenMatcherWrapper.CustomerDataModal.class);
            MDM_CustomerTokenMatcher.getCustomerGoldenResults(
                goldMatchWrapper, customerModal, wordBasedMatchingRule);
        }
        return goldMatchWrapper.results;
    }

    /**
     * @description Function for prepare SOQL WHERE clause and fetching Customer golden records.
     * @param customerModal
     * @param wordBasedMatchingRule
     * @return Map<Decimal, List<sObject>>
     */
    public static Map<Decimal, List<Object>> findCustomerGoldenMatches (
        MDM_TokenMatcherWrapper.CustomerDataModal customerModal,
        Map<String, Map<String, MDM_TokenMatcherWrapper.FieldConfig>> wordBasedMatchingRule
    ) {
        Map<Decimal, List<Object>> matchPercentSObjectsMap = new Map<Decimal, List<Object>> ();
        MDM_TokenMatcherWrapper.CustGoldenMatchWrapper findCustGolden = new MDM_TokenMatcherWrapper.CustGoldenMatchWrapper();
        String goldObjectName = 
            MDM_TokenizerService.getMDMsObjectNameFromEnum (MDM_TokenizerService.salesforceMDMObjects.MDM_Customer);
        // Loading of Duplicate Matching Rule.
        MDM_TokenizerService.loadDuplicateRuleConfiguration (goldObjectName);
        findCustGolden.query = 'SELECT {0} FROM ' + goldObjectName + ' {1}';
        if (customerModal != null) {
            findCustGolden.query = String.format (findCustGolden.query, new List<String> {
                String.join ((MDM_TokenMatcherServiceHelper.prepareModalFetchContent (
                            goldObjectName, customerSObjectSequence, customerModalDisplayFields)), ','), ' {0} WITH SECURITY_ENFORCED ' 
            });
            findCustGolden.startFetchRecords = false;
            findCustGolden.isCustomerInSearch = false;
            findCustGolden.isAnyChildInSearch = false;
            findCustGolden.isWordTokenAdded = false;
            findCustGolden.isSourceInSearch = false;
            findCustGolden.customerIds = new List<Id> ();
            if (customerSObjectSequence.size () == 4 && customerModal.MDM_Source_Customer != null) {
                // If source values are provided - get customer Ids with source name and Id
                MDM_CustomerTokenMatcher.setupCustomerIds(findCustGolden, customerModal);
            }
            setCustomerObjects(findCustGolden, customerModal, wordBasedMatchingRule);
            // Improvements: Roshan 
            findCustGolden.query += ' LIMIT 1000';
            List<SObject> fileterResultList = 
                MDM_CustomerTokenMatcherHelper.getCustomerFilteredResult(findCustGolden, excludeRecordIds);
            // Improvements: Roshan
            MDM_TokenMatcherWrapper.FindGoldenMatchWrapper findGolden = new MDM_TokenMatcherWrapper.FindGoldenMatchWrapper();
            findGolden.dataModalJSON = JSON.serialize (customerModal);
            findGolden.sfObject = MDM_TokenizerService.salesforceMDMObjects.MDM_Customer;
            findGolden.fileterResultList = fileterResultList;
            if (fileterResultList.size () > 300) {
                matchPercentSObjectsMap.put (0, fileterResultList);
            } else {
                if (findCustGolden.customerIds.size () > 0) {
                    matchPercentSObjectsMap.put (1, fileterResultList);
                } else {
                    matchPercentSObjectsMap = 
                        MDM_TokenMatcherServiceHelper.prepareRecordWeightMap (findGolden, customerSObjectSequence);
                }				
                matchPercentSObjectsMap = 
                    MDM_TokenMatcherServiceHelper.prepareRecordWeightMap (findGolden, customerSObjectSequence);
            }
        }
        
        return matchPercentSObjectsMap;
    }

     /**
     * @description Function for prepare SOQL WHERE clause and fetching Title golden records.
     * @param findCustGolden sobject wrapper
     * @param customerModal records to be excluded
     * @param wordBasedMatchingRule records to be excluded
     */
    public static void setCustomerObjects(
        MDM_TokenMatcherWrapper.CustGoldenMatchWrapper findCustGolden, 
        MDM_TokenMatcherWrapper.CustomerDataModal customerModal, 
        Map<String, Map<String, MDM_TokenMatcherWrapper.FieldConfig>> wordBasedMatchingRule)
    {
        for (String objName : customerSObjectSequence) {
            findCustGolden.objName = objName;
            findCustGolden.tokenFieldMap = MDM_TokenizerService.getConfiguredTokenFields (findCustGolden.objName);
            findCustGolden.fieldThreshold = MDM_TokenizerService.getConfiguredFieldThresholds (findCustGolden.objName);
            if (findCustGolden.objName == customerSObjectSequence[0]) {
                // for Customer Object : customerSObjectSequence[0]
                MDM_CustomerTokenMatcher.appendCustWhereClauseToQuery(findCustGolden, customerModal, wordBasedMatchingRule);
            } else if (findCustGolden.objName == customerSObjectSequence[1]) {
                // For Contact Object : customerSObjectSequence[1]
                MDM_CreateContactAddrWhereClause.setContactWhereClause(findCustGolden, customerModal);
            } else if (findCustGolden.objName == customerSObjectSequence[2]) {
                // For Address Object : customerSObjectSequence[2]
                MDM_CreateContactAddrWhereClause.setAddrCustWhereClause(findCustGolden, customerModal);
            } 
            else if (findCustGolden.objName == customerSObjectSequence[3]) {                    
                // For Source Customer Object : customerSObjectSequence[3]
                MDM_CustomerTokenMatcherHelper.setSrcCustWhereClause(findCustGolden, customerModal);
            }
        }
    }
}