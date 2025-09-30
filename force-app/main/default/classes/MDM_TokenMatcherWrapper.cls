/**
 * @description       : Contains the Generic Methods for MDM Search functionality using duplicate and matching rule records.
 * @author            : Komal Sonsale
 * @group             : 
 * @last modified on  : 05-26-2021
 * @last modified by  : Sourabh
 * Modifications Log 
 * Ver   Date         Author          Modification
 * 1.0   03-30-2021   Komal Sonsale   Initial Version
**/

@SuppressWarnings('PMD.ExcessivePublicCount') //Wrapper class is accessed from various classes
public with sharing class MDM_TokenMatcherWrapper {
     /**
    * @description : Wrapper class for Customer and its child model
    */
    @SuppressWarnings('PMD.VariableNamingConventions') //variable names similar to sObject names
    Public class CustomerDataModal {
        Public MDM_Customer__c MDM_Customer;
        Public MDM_Source_Customer__c MDM_Source_Customer; 
        Public MDM_Contact__c MDM_Contact;
        Public MDM_Address__c MDM_Address;
    }
    /**
     * @description : Wrapper for calling findCustomerGoldenMatches() method
     */
    @SuppressWarnings('PMD.TooManyFields') //Need wrapper throughout the code
    public class CustGoldenMatchWrapper {
        public Decimal threshold;
        public Boolean startFetchRecords;
        public Boolean isCustomerInSearch;
        public Boolean isAnyChildInSearch;
        public Boolean isWordTokenAdded;
        public Boolean isSourceInSearch;
        public String query;
        public String field;
        public String fieldValue;
        public String objName;
        public List<String> whrClauseList;
        public List<Object> fileterResultList;
        public List<String> custNameTokens;
        public List<String> custRecordTypeTokens;
        public List<Id> customerIds;
        public List<String> contactNameTokens;
        public List<String> addrCityTokens;
        public List<String> addrStateTokens;
        public List<String> addrCountryTokens;
        public List<String> addrCountryCodeTokens;
        public List<String> srcSystemTokens;
        public List<String> srcSystemIdTokens;
        public Map<String, String> tokenFieldMap;
        public Map<String, Decimal> fieldThreshold;
    }

    /**
    * @description : Wrapper class for Word Configuration
    */
    public class WordConfig {
        public string word;
        public boolean isStartWith;
    }

    /**
    * @description : Wrapper class for Field Configuration
    */
    public class FieldConfig {
        public Decimal threshold;
        public list<WordConfig> wordConfigs;
    }

    /**
    * @description : Wrapper class for Title and its child objects
    */
    public class GetGoldenMatchesWrapper {
        public String sObjectType;
        public List<Object> results;
        public Set<String> parentTitleIds;
        public String parentObjectId;
        public Boolean performWordBasedSearch;
    }

    /**
     * @description : Wrapper for calling findTitleGoldenMatches() method
     */
    @SuppressWarnings('PMD.TooManyFields') //Need wrapper throughout the code
    public class FindGoldenMatchWrapper {
        public Boolean startFetchRecords;
        public Boolean isTitleInSearch;
        public Boolean isWordTokenAdded;
        public String dataModalJSON;
        public String query;
        public String whrClause;
        public String value;
        public String objName;
        public String field;
        public Decimal threshold;
        public List<String> titleNameTokens;
        public List<String> titleProductTypeTokens;
        public Set<String> parentTitleIds;
        public MDM_TokenizerService.salesforceMDMObjects sfObject;
        public List<Object> fileterResultList;
        public Map<String, String> tokenFieldMap;
        public Map<String, Decimal> fieldThreshold;
    }

    /**
     * @description : Wrapper class to hold values of prepareRecordWeightMap()
     */
    public class PrepareRecordWeight{
        public Object obj;
        public sObject sObj;
        public String stagingValue;
        public String sObjName; 
        public String fieldName;
        public Decimal totalFieldCount;
        public Decimal thresholdSum;
    }
}