/**
 * @description       : Contains the Generic Methods for MDM Search functionality using duplicate and matching rule records.
 * @author            : Komal Sonsale
 * @group             : 
 * @last modified on  : 05-27-2021
 * @last modified by  : Komal Sonsale
 * Modifications Log 
 * Ver   Date         Author          Modification
 * 1.0   03-30-2021   Komal Sonsale   Initial Version
**/

public with sharing class MDM_CustomerTokenMatcher {
    
    /**
    * @description : Function to set field filter tokens
    * @param findCustGolden 
    * @param customerModal 
    **/
    public static void setupCustomerIds(MDM_TokenMatcherWrapper.CustGoldenMatchWrapper findCustGolden, 
    MDM_TokenMatcherWrapper.CustomerDataModal customerModal) 
    {
        String sourceId = String.valueOf (customerModal.MDM_Source_Customer.get ('MDM_Source_System_Id__c'));
        String sourceName = String.valueOf (customerModal.MDM_Source_Customer.get ('MDM_Source_System__c'));
        if (!String.isBlank(sourceId) && !String.isBlank(sourceName)) {
            findCustGolden.isSourceInSearch = true;
            List<MDM_Source_Customer__c> sources = new List<MDM_Source_Customer__c>();
            if(Schema.sObjectType.MDM_Source_Customer__c.isAccessible()) {
                sources = [
                    SELECT MDM_Customer__r.Id
                    FROM MDM_Source_Customer__c
                    WHERE MDM_Source_System_Id__c =: sourceId AND MDM_Source_System__c =: sourceName WITH SECURITY_ENFORCED
                ];
            }
            for (MDM_Source_Customer__c cust : sources) {
                findCustGolden.customerIds.add (cust.MDM_Customer__r.Id);
            }
        }
    }

    /**
    * @description : Function to set field filter tokens based on word based matching rule
    * @param findCustGolden 
    * @param fConf 
    * @param fieldFilterTokens 
    **/
    public static void setCustWordBasedFilterTokens(MDM_TokenMatcherWrapper.CustGoldenMatchWrapper findCustGolden, 
                                                MDM_TokenMatcherWrapper.FieldConfig fConf, List<String> fieldFilterTokens) 
    {
        findCustGolden.threshold = fConf.threshold;
        if (fConf.wordConfigs.size () > 0) {
            findCustGolden.threshold = 100.0;
            findCustGolden.isWordTokenAdded = true;
        }
        for (MDM_TokenMatcherWrapper.WordConfig conf : fConf.wordConfigs) {
            if (conf.isStartWith) {
                fieldFilterTokens.add (conf.word + '%');
            } else {
                fieldFilterTokens.add ('%' + conf.word + '%');
            }
        }
    }

    /**
    * @description : Function to set field filter tokens based on word based matching rule
    * @param findCustGolden 
    * @param wordBasedMatchingRule 
    **/
    public static void setupCustomerWhereClauseList(MDM_TokenMatcherWrapper.CustGoldenMatchWrapper findCustGolden, 
                                                    Map<String, Map<String, MDM_TokenMatcherWrapper.FieldConfig>> wordBasedMatchingRule)
    {   
        List<String> fieldFilterTokens = new List<String> ();
        findCustGolden.threshold = 99.0;
        if (wordBasedMatchingRule != null && wordBasedMatchingRule.containsKey (findCustGolden.objName)) {
            if (wordBasedMatchingRule.get (findCustGolden.objName).containsKey (findCustGolden.field)) {
                MDM_TokenMatcherWrapper.FieldConfig fConf = wordBasedMatchingRule.get (findCustGolden.objName).get (findCustGolden.field);
                setCustWordBasedFilterTokens(findCustGolden, fConf, fieldFilterTokens);
            }
        } 
        if (findCustGolden.threshold == 99.0) {
            findCustGolden.threshold = findCustGolden.fieldThreshold.get (findCustGolden.field);
        }
        if (findCustGolden.threshold == 100.0) {
            fieldFilterTokens.add ('' + findCustGolden.fieldValue + '');
        } else if (findCustGolden.threshold == 1.0) {
            fieldFilterTokens.add ('%' + findCustGolden.fieldValue + '%');
        } else {
            if (findCustGolden.threshold != 0.0) {
                MDM_CreateContactAddrWhereClause.setCustomerFieldFilterTokens(findCustGolden, findCustGolden.fieldValue, fieldFilterTokens);
            }
        }
        String whrClause = '';
        if (findCustGolden.field == 'Name') {
            findCustGolden.custNameTokens = fieldFilterTokens;
            findCustGolden.fieldValue = '%' + findCustGolden.fieldValue + '%';
            whrClause = '(' + findCustGolden.field + ' Like :value OR ';
            whrClause += findCustGolden.tokenFieldMap.get (findCustGolden.field) + ' Like :custNameTokens)';
        } else if (findCustGolden.field == 'MDM_Account_Type__c') {
            findCustGolden.custRecordTypeTokens = fieldFilterTokens;
            whrClause = findCustGolden.tokenFieldMap.get (findCustGolden.field) + ' Like :custRecordTypeTokens';
        }
        findCustGolden.whrClauseList.add (whrClause);
        findCustGolden.startFetchRecords = true;
    }

    /**
    * @description : Function to append where clause to original query
    * @param findCustGolden 
    * @param customerModal 
    * @param wordBasedMatchingRule 
    **/
    public static void appendCustWhereClauseToQuery(MDM_TokenMatcherWrapper.CustGoldenMatchWrapper findCustGolden, 
    MDM_TokenMatcherWrapper.CustomerDataModal customerModal, 
     Map<String, Map<String, MDM_TokenMatcherWrapper.FieldConfig>> wordBasedMatchingRule)
    {
        String custWhrClause = '';
        findCustGolden.whrClauseList = new List<String> ();
        sObject sObj = customerModal.MDM_Customer;
        if (sObj != NULL) {
            for (String field : findCustGolden.tokenFieldMap.keySet ()) { 
                findCustGolden.field = field;
                findCustGolden.fieldValue = (String) sObj.get (findCustGolden.field);
                if (!String.isEmpty (findCustGolden.fieldValue)) {
                    setupCustomerWhereClauseList(findCustGolden, wordBasedMatchingRule);
                } 
            }
        }
        if (findCustGolden.customerIds.size () > 0) {
            //include customer Id filter if exists
            String whrClause = 'Id IN :customerIds';
            findCustGolden.whrClauseList.add (whrClause);                                                
        }
        else {
            //if source params are used but no match, regardless of customer name - return no result
            if(findCustGolden.isSourceInSearch) {
                findCustGolden.whrClauseList = new List<String> ();
            }
        }     
        if (findCustGolden.whrClauseList.size () > 0) {
            findCustGolden.isCustomerInSearch = true;
            custWhrClause = 'WHERE ' + String.join (findCustGolden.whrClauseList, ' AND ');                        
            findCustGolden.query = String.format (findCustGolden.query, new List<String> { custWhrClause, '{0}', '{1}', '{2}', '{3}' });                    	
        }
    }

    /**
    * @description : Returns customer modal using JSON
    * @param customerModalJSON 
    * @param sObjectName 
    * @return sObject 
    **/
    public static sObject getCustomerStageValue (String customerModalJSON, String sObjectName) {
        sObject sObj = null;
        MDM_TokenMatcherWrapper.CustomerDataModal customerModal = 
            (MDM_TokenMatcherWrapper.CustomerDataModal) JSON.deserialize (
                customerModalJSON, MDM_TokenMatcherWrapper.CustomerDataModal.class);
        if (sObjectName == MDM_TokenMatcherService.customerSObjectSequence[0]) {
            sObj = customerModal.MDM_Customer;
        }  else if (sObjectName == MDM_TokenMatcherService.customerSObjectSequence[1]) {
            sObj = customerModal.MDM_Contact;
        } else if (sObjectName == MDM_TokenMatcherService.customerSObjectSequence[2]) {
            sObj = customerModal.MDM_Address;
        } else if (sObjectName == MDM_TokenMatcherService.customerSObjectSequence[3]) { 
            sObj = customerModal.MDM_Source_Customer;
        }
        return sObj;
    }

    /**
    * @description : Function for Collect And Return Golden Records for core MDM sObject
    * @param goldMatchWrapper 
    * @param customerModal 
    * @param wordBasedMatchingRule 
    **/
    public static void getCustomerGoldenResults(MDM_TokenMatcherWrapper.GetGoldenMatchesWrapper goldMatchWrapper, 
    MDM_TokenMatcherWrapper.CustomerDataModal customerModal, 
    Map<String, Map<String, MDM_TokenMatcherWrapper.FieldConfig>> wordBasedMatchingRule)
    {        
        if (goldMatchWrapper.performWordBasedSearch) {
            goldMatchWrapper.results.add (MDM_TokenMatcherService.findCustomerGoldenMatches (customerModal, wordBasedMatchingRule));
        }
        if (wordBasedMatchingRule != null && wordBasedMatchingRule.containsKey (goldMatchWrapper.sObjectType)) {
            for (String field : wordBasedMatchingRule.get (goldMatchWrapper.sObjectType).keySet ()) {
                MDM_TokenMatcherWrapper.FieldConfig fConf = wordBasedMatchingRule.get (goldMatchWrapper.sObjectType).get (field);
                fConf.wordConfigs = new List<MDM_TokenMatcherWrapper.WordConfig> ();
            }
        }
        goldMatchWrapper.results.add (MDM_TokenMatcherService.findCustomerGoldenMatches (customerModal, wordBasedMatchingRule));
    }
    
}