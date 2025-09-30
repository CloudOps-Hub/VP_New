/**
 * @description       : Contains the Generic Methods for MDM Search functionality using duplicate and matching rule records.
 * @author            : Komal Sonsale
 * @group             : 
 * @last modified on  : 04-22-2021
 * @last modified by  : Sourabh
 * Modifications Log 
 * Ver   Date         Author          Modification
 * 1.0   03-30-2021   Komal Sonsale   Initial Version
**/

public with sharing class MDM_CustomerTokenMatcherHelper {
    
    /**
     * @description : Function for prepare SOQL WHERE clause and fetching Title golden records.
     * @param findCustGolden sobject wrapper
     */
    public static void setSrcCustWhereClauseList(MDM_TokenMatcherWrapper.CustGoldenMatchWrapper findCustGolden) {
        if (!String.isEmpty (findCustGolden.fieldValue)) {
            List<String> fieldFilterTokens = new List<String> ();
            MDM_TokenMatcherServiceHelper.setCustFieldFilterTokens(findCustGolden, fieldFilterTokens);
            String whrClause = '';
            if (findCustGolden.field == 'MDM_Source_System__c') {
                findCustGolden.srcSystemTokens = fieldFilterTokens;
                whrClause = findCustGolden.tokenFieldMap.get (findCustGolden.field) + ' Like :srcSystemTokens';
            } else if (findCustGolden.field == 'MDM_Source_System_Id__c') {
                findCustGolden.srcSystemIdTokens = fieldFilterTokens;
                whrClause = findCustGolden.tokenFieldMap.get (findCustGolden.field) + ' Like :srcSystemIdTokens';
            }
            findCustGolden.whrClauseList.add (whrClause);
            findCustGolden.startFetchRecords = true;
        }
    }

    /**
     * @description : Function for prepare SOQL WHERE clause and fetching Title golden records.
     * @param findCustGolden sobject wrapper
     * @param customerModal records to be excluded
     */
    public static void setSrcCustWhereClause(MDM_TokenMatcherWrapper.CustGoldenMatchWrapper findCustGolden, 
    MDM_TokenMatcherWrapper.CustomerDataModal customerModal)
    {
        String srcCustomerWhrClause = '';
        findCustGolden.whrClauseList = new List<String> ();
        sObject sObj = customerModal.MDM_Source_Customer;
        if (sObj != NULL) {
            for (String field : findCustGolden.tokenFieldMap.keySet ()) {
                findCustGolden.field = field;
                findCustGolden.fieldValue = (String) sObj.get (findCustGolden.field);
                setSrcCustWhereClauseList(findCustGolden);
            }
        }
        if (findCustGolden.whrClauseList.size () > 0) {
            srcCustomerWhrClause = 'WHERE ' + String.join (findCustGolden.whrClauseList, ' AND ');
            String childInQuery = 'SELECT ' + MDM_TokenMatcherService.childToCustomerLookupField.get (
                findCustGolden.objName) + ' FROM ' + findCustGolden.objName + ' ' + srcCustomerWhrClause;
            if (findCustGolden.isCustomerInSearch) { 
                childInQuery += ' LIMIT 50000';
                findCustGolden.query = String.format (findCustGolden.query, new List<String> { srcCustomerWhrClause });
            } else {
                String customerInQuery = 'WHERE Id IN (' + childInQuery + ') ';
                findCustGolden.query = String.format (findCustGolden.query, new List<String> { customerInQuery, srcCustomerWhrClause });
                findCustGolden.isAnyChildInSearch = true;
            }
        } else {
            srcCustomerWhrClause = '';
            if (findCustGolden.isCustomerInSearch) {
                findCustGolden.query = String.format (findCustGolden.query, new List<String> { srcCustomerWhrClause });
            } else {
                findCustGolden.query = String.format (findCustGolden.query, new List<String> { '', srcCustomerWhrClause });
            }
        }
    }

    /**
     * @description : Function for prepare SOQL WHERE clause and fetching Title golden records.
     * @param fileterResultList sobject wrapper
     * @param excludeRecordIds records to be excluded
     * @return newFilteredResultList
     */
    public static List<SObject> getCustFilteredResultList(List<SObject> fileterResultList, 
                                                      Set<String> excludeRecordIds)
    {
        List<SObject> newFilteredResultList = new List<SObject> ();
        if (excludeRecordIds.size () > 0) {
            for (SObject sObj : fileterResultList) {
                if (!excludeRecordIds.contains ((string) sObj.get ('Id'))) {
                    newFilteredResultList.add (sObj);
                }
            }
        } else {
            newFilteredResultList = new List<SObject> (fileterResultList);
        }
        return newFilteredResultList;
    }

    /**
     * @description : Function for prepare SOQL WHERE clause and fetching Title golden records.
     * @param findCustGolden sobject wrapper
     * @param excludeRecordIds records to be excluded
     * @return newFilteredResultList
     */
    public static List<SObject> getCustomerFilteredResult(
        MDM_TokenMatcherWrapper.CustGoldenMatchWrapper findCustGolden, 
        Set<String> excludeRecordIds)
    {   String value;
        List<Id> customerIds; 
        List<String> custNameTokens;
        List<String> custRecordTypeTokens;
        //List<String> brandNameTokens;
        List<String> contactNameTokens;
        List<String> addrCityTokens;
        List<String> addrStateTokens;
        List<String> addrCountryTokens;
        List<String> addrCountryCodeTokens;
        List<String> srcSystemTokens;
        List<String> srcSystemIdTokens;
        value = findCustGolden.fieldValue;
        customerIds = findCustGolden.customerIds;
        custNameTokens = findCustGolden.custNameTokens;
        custRecordTypeTokens = findCustGolden.custRecordTypeTokens;
       
        contactNameTokens = findCustGolden.contactNameTokens;
        addrCityTokens = findCustGolden.addrCityTokens;
        addrStateTokens = findCustGolden.addrStateTokens;
        addrCountryTokens = findCustGolden.addrCountryTokens;
        addrCountryCodeTokens = findCustGolden.addrCountryCodeTokens;
        srcSystemTokens = findCustGolden.srcSystemTokens;
        srcSystemIdTokens = findCustGolden.srcSystemIdTokens;
        
        List<SObject> filterResultList = new List<SObject> ();
        if (findCustGolden.startFetchRecords) {
            filterResultList = Database.query (String.escapeSingleQuotes(findCustGolden.query));
            if (findCustGolden.isWordTokenAdded) {
                for (sObject sObj : filterResultList) {
                    excludeRecordIds.add ((string) sObj.get ('Id'));
                }
            } else {
                filterResultList = getCustFilteredResultList(filterResultList, excludeRecordIds);
            }
        }
        return filterResultList;
    }    
}