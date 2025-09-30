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
public with sharing class MDM_CreateContactAddrWhereClause {
    /**
     * @description Function for prepare SOQL WHERE clause and fetching Title golden records.
     * @param findCustGolden sobject wrapper
     */
    public static void setAddrWhereClauseList(MDM_TokenMatcherWrapper.CustGoldenMatchWrapper findCustGolden) {
        if (!String.isEmpty (findCustGolden.fieldValue)) {
            List<String> fieldFilterTokens = new List<String> ();
            MDM_TokenMatcherServiceHelper.setCustFieldFilterTokens(findCustGolden, fieldFilterTokens);
            String whrClause = '';
            if (findCustGolden.field == 'MDM_City__c') {
                findCustGolden.addrCityTokens = fieldFilterTokens;
                whrClause = findCustGolden.tokenFieldMap.get (findCustGolden.field) + ' Like :addrCityTokens';
            } else if (findCustGolden.field == 'MDM_State__c') {
                findCustGolden.addrStateTokens = fieldFilterTokens;
                whrClause = findCustGolden.tokenFieldMap.get (findCustGolden.field) + ' Like :addrStateTokens';
            } else if (findCustGolden.field == 'MDM_Country__c') {
                findCustGolden.addrCountryTokens = fieldFilterTokens;
                whrClause = findCustGolden.tokenFieldMap.get (findCustGolden.field) + ' Like :addrCountryTokens';
            } else if (findCustGolden.field == 'MDM_Country_Code__c') {
                findCustGolden.addrCountryCodeTokens = fieldFilterTokens;
                whrClause = findCustGolden.tokenFieldMap.get (findCustGolden.field) + ' Like :addrCountryCodeTokens';
            }
         
            findCustGolden.whrClauseList.add (whrClause);
            findCustGolden.startFetchRecords = true;
        }
    }
    
    /**
     * @description Function for prepare SOQL WHERE clause and fetching Title golden records.
     * @param findCustGolden sobject wrapper
     * @param customerModal records to be excluded
     */
    public static void setAddrCustWhereClause(MDM_TokenMatcherWrapper.CustGoldenMatchWrapper findCustGolden,
    MDM_TokenMatcherWrapper.CustomerDataModal customerModal)
    {
        String addrWhrClause = '';
        findCustGolden.whrClauseList = new List<String> ();
        sObject sObj = customerModal.MDM_Address;
        if (sObj != NULL) {
            for (String field : findCustGolden.tokenFieldMap.keySet ()) {
                findCustGolden.field = field;
                findCustGolden.fieldValue = (String) sObj.get (findCustGolden.field);
                setAddrWhereClauseList(findCustGolden);
            }
        }
        if (findCustGolden.whrClauseList.size () > 0) {
            addrWhrClause = 'WHERE ' + String.join (findCustGolden.whrClauseList, ' AND ');
            String childInQuery = 'SELECT ' + MDM_TokenMatcherService.childToCustomerLookupField.get (
                findCustGolden.objName) + ' FROM ' + findCustGolden.objName + ' ' + addrWhrClause;
            if (findCustGolden.isCustomerInSearch) {
                childInQuery += ' LIMIT 50000';                            
                findCustGolden.query = String.format (findCustGolden.query, new List<String> { addrWhrClause, '{0}' });
            } else {
                String customerInQuery = 'WHERE Id IN (' + childInQuery + ') ';                            
                findCustGolden.query = String.format (findCustGolden.query, new List<String> { customerInQuery, addrWhrClause, '{0}' });
                findCustGolden.isAnyChildInSearch = true;
            }
        } else {
            addrWhrClause = '';
            if (findCustGolden.isCustomerInSearch) {                            
                findCustGolden.query = String.format (findCustGolden.query, new List<String> { addrWhrClause, '{0}', '{1}' });
            } else {                            
                findCustGolden.query = String.format (findCustGolden.query, new List<String> { '{0}', addrWhrClause, '{1}' });
            }
        }
    }
     /**
     * @description Function for prepare SOQL WHERE clause and fetching Title golden records.
     * @param findCustGolden sobject wrapper
     */
    public static void setContactWhereClauseList(MDM_TokenMatcherWrapper.CustGoldenMatchWrapper findCustGolden) {
        if (!String.isEmpty (findCustGolden.fieldValue)) {
            List<String> fieldFilterTokens = new List<String> ();
            MDM_TokenMatcherServiceHelper.setCustFieldFilterTokens(findCustGolden, fieldFilterTokens);
            String whrClause = '';
            if (findCustGolden.field == 'Name') {
                findCustGolden.contactNameTokens = fieldFilterTokens;
                whrClause = findCustGolden.tokenFieldMap.get (findCustGolden.field) + ' Like :contactNameTokens';
            }
            findCustGolden.whrClauseList.add (whrClause);
            findCustGolden.startFetchRecords = true;
        }
    }

    /**
     * @description Function for prepare SOQL WHERE clause and fetching Title golden records.
     * @param findCustGolden sobject wrapper
     * @param customerModal records to be excluded
     */
    public static void setContactWhereClause(MDM_TokenMatcherWrapper.CustGoldenMatchWrapper findCustGolden, 
    MDM_TokenMatcherWrapper.CustomerDataModal customerModal)
    {
        String contactWhrClause = '';
        findCustGolden.whrClauseList = new List<String> ();
        sObject sObj = customerModal.MDM_Contact;
        if (sObj != NULL) {
            for (String field : findCustGolden.tokenFieldMap.keySet ()) {
                findCustGolden.field = field;
                findCustGolden.fieldValue = (String) sObj.get (findCustGolden.field);
                setContactWhereClauseList(findCustGolden);
            }
        }
        if (findCustGolden.whrClauseList.size () > 0) {
            contactWhrClause = 'WHERE ' + String.join (findCustGolden.whrClauseList, ' AND ');
            String childInQuery = 'SELECT ' + MDM_TokenMatcherService.childToCustomerLookupField.get (findCustGolden.objName) + 
                					' FROM ' + findCustGolden.objName + ' ' + contactWhrClause;
            if (findCustGolden.isCustomerInSearch) {
                childInQuery += ' LIMIT 50000';                            
                findCustGolden.query = String.format (findCustGolden.query, new List<String> { contactWhrClause, '{0}', '{1}' });
            } else {
                String customerInQuery = 'WHERE Id IN (' + childInQuery + ') ';                            
                findCustGolden.query = String.format (findCustGolden.query, new List<String> { customerInQuery, contactWhrClause,
                    '{0}', '{1}' });                            
                findCustGolden.isAnyChildInSearch = true;
            }
        } else {
            contactWhrClause = '';
            if (findCustGolden.isCustomerInSearch) {  
                findCustGolden.query = String.format (findCustGolden.query, new List<String> { contactWhrClause, '{0}', '{1}' }); 
            } else {                            
                findCustGolden.query = String.format (findCustGolden.query, new List<String> { '{0}', contactWhrClause, '{1}', '{2}' });
            }
        }
    }

    /**
     * @description Function to set field filter tokens
     * @param findCustGolden
     * @param tokenSeq
     * @param fieldFilterTokens
     */
    public static void setCustomerFieldFilterTokens(MDM_TokenMatcherWrapper.CustGoldenMatchWrapper findCustGolden, 
                                             String tokenSeq, List<String> fieldFilterTokens) 
    {
        Integer tokenCount = Integer.valueOf (findCustGolden.threshold * findCustGolden.fieldValue.length ());
        if (findCustGolden.fieldValue.length () <= 3) { tokenCount = findCustGolden.fieldValue.length (); }
        List<String> fieldTokens = tokenSeq.split ('');
        Integer maxLoopSize = fieldTokens.size () - tokenCount;
        for (Integer i = 0; i <= maxLoopSize; i++) {
            List<String> tokens = new List<String> ();
            for (Integer j = i; j < (i + tokenCount); j++) {
                tokens.add (fieldTokens[j]);
            }
            fieldFilterTokens.add ('%' + String.join (tokens, '') + '%');
        }
    }
}