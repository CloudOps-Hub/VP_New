/**
 * @description       : 
 * @author            : Priya Sharma
 * @group             : 
 * @last modified on  : 06-10-2021
 * @last modified by  : Komal Sonsale
 * Modifications Log 
 * Ver   Date         Author         Modification
 * 1.0   03-23-2021   Priya Sharma   Initial Version
**/
@SuppressWarnings('PMD.ExcessivePublicCount')
public with sharing class MDM_CustomerAPIWrapper {

    public static Map<String, String> fieldMapping = new Map<String, String> {
        'mdmId' => 'MDM_ID__c',
        'name' => 'Name',
        'description' => 'MDM_Description__c',
        'status' => 'MDM_Customer_Status__c',
        'type' => 'MDM_Account_Type__c',
        'isdeleted' => 'MDM_Is_Deleted__c',
        'createddate' => 'CreatedDate',
        'lastmodifieddate' => 'LastModifiedDate',
        'industryType'=>'MDM_Industry_Type__c',
        'doiordob'=> 'MDM_DOI_or_DOB__c',
        'customerId'=>'MDM_Customer_Id__c'
    };
   
    /**
     * @description wrapper for Address
     */
    @SuppressWarnings('PMD.TooManyFields')
    public class MDM_Address {
        public String addressID;
        public String address1;
        public String address2;
        public String address3;
        public String addressType;
        public String city;
        public string country;
        public String state;
        public String countryCode;
        public String zipcode;
        public String phone;
        public String extension;
        public string fax;
        public string email;
        public string description;
        public String addressStatus;
        public String addressSourceSystem;
        public String addressSourceSystemPrimary;
        public String addressSourceSystemId;
        public String verifiedAddress; 
        public String isPrimary; 
    }
    
    /**
     * @description wrapper for Contact Address JSON
     */
    public class MDM_ContactAddress {
        public String contactID;
        public String contactName;
        public String suffix;
        public String title;
        public string status;
        public String phone;
        public String fax;
        public String email;
        public String extension;
        public String contactSourceSystem;
        public String contactSourceSystemId;
        public MDM_Address[] addresses;
    }
    
    /**
     * @description wrapper for Get customer request
     */
    public class MDM_GetCustomerRequest {
        public String statusFilter;
        public String[] field;
        public String[] mdmIds;
        public String part;
        public String accountType;
        public Boolean isValid = true;
    }

    /**
     * @description wrapper for error
     */
    public class MDM_Error {
        public String detail;
        public String message;
        public String stackTrace;
        /**
         * @description Constructor
         * @param detail
         * @param message
         * @param stackTrace
         */
        public MDM_Error(String detail, String message, String stackTrace) {
            this.detail = detail;
            this.message = message;
            this.stackTrace = stackTrace;
        }
    }
    /**
     * @description wrapper for Customer Response
     */
    @SuppressWarnings('PMD.TooManyFields')
    public class MDM_GetCustomerResponse {
        public String mdmId;
        public String name;
        public String description;
        public String status;
        public String accountType;
        public String industryType;
        public Date doiordob;
        public String customerId;
        public String isDeleted; 
        public DateTime lastModifiedDate;
        public DateTime createdDate;
        public MDM_ExternalID[] externalIDs;
        public MDM_ContactAddress[] contactAddresses;
        
    }
    /**
     * @description : wrapper will have customer, contact, adresss and child customer map
     */
    public class CustConAddressMap{
        public Map<ID, List<MDM_Contact__c>> contactsMap = new Map<ID, List<MDM_Contact__c>>();
        public Map<ID, List<MDM_Address__c>> addressesMap = new Map<ID, List<MDM_Address__c>>();
      
    }
 
    /**
     * @description wrapper for Reference system Id
     */
    @SuppressWarnings('PMD.FieldNamingConventions') //consumed by external system
    public class MDM_ExternalID {
        public String id;
        public String name;
        public String sourceSystem;
        public String type;
        public Boolean isPrimary;
    }

    /**
     * @description wrapper for Search Customer Response
     */
    public class MDM_SearchResponse {
        public String mdmId;
        public String name;
        public String accountType;
        public String status;
        public String description;
        public DateTime lastModifiedDate;
        public DateTime createdDate;
        public String industryType;
        public Date doiordob;
        public String customerId;
       
        public MDM_ExternalID[] externalIDs;
        public String error;
        public String mdmIds;
        public String externalID;
        public String isDeleted; 
        
    }

    /**
     * @description wrapper for Search customer request
     */
    public class MDM_SearchRequest {
        public String limitation; //limit is a keyword
        public String statusFilter;
        public String[] externalSystemIDs;
        public String[] mdmIds;
        public String[] sourceSystems;
        public String query;
        public String customerType;
        public String lastModifiedDateFrom;
        public String lastModifiedDateTo;
        public Boolean isValidSearch = true;
    }


    /**
     * @description wrapper for list of customers
     */
    public class MDM_Response {
        public MDM_GetCustomerResponse[] customers;
        public Integer totalNumberOfRecords;
    }
  
}