/**
 * @description       : 
 * @author            : Priya Sharma
 * @group             : 
 * @last modified on  : 05-28-2021
 * @last modified by  : Komal Sonsale
 * Modifications Log 
 * Ver   Date         Author         Modification
 * 1.0   04-16-2021   Priya Sharma   Initial Version
**/

//suppressed as it contains all get individual API methods 
@SuppressWarnings('PMD.CyclomaticComplexity,PMD.CognitiveComplexity')
public with sharing class MDM_GetIndividualCustomerAPIHandler {
    /**
     * @description : adding fields to the response based on query parameter 'field'
     * @param queryResult
     * @param response
     * @param customerRequest
     */
	public static void addQueryFieldsToResponse(MDM_Customer__c queryResult, MDM_CustomerAPIWrapper.MDM_GetCustomerResponse response,
                        MDM_CustomerAPIWrapper.MDM_GetCustomerRequest customerRequest)
    {    
        if(customerRequest.field != NULL) {
            populateCustRequestfield(queryResult, response, customerRequest);
            if(customerRequest.field.contains('lastModifiedDate')){
                response.lastModifiedDate = queryResult.LastModifiedDate; 
            }
            if(customerRequest.field.contains('createdDate') ){
                response.createdDate = queryResult.CreatedDate; 
            }             
        } else {
            response.mdmId = queryResult.MDM_ID__c;
            response.name = queryResult.Name;
            response.description = queryResult.MDM_Description__c;
            response.status = queryResult.MDM_Customer_Status__c;
            response.accountType = queryResult.MDM_Account_Type__c;
            response.isDeleted = String.valueOf(queryResult.MDM_is_Deleted__c); 
            response.lastModifiedDate = queryResult.LastModifiedDate;  
            response.createdDate = queryResult.CreatedDate;
			response.industryType = queryResult.MDM_Industry_Type__c;
            response.customerId = queryResult.MDM_Customer_Id__c ;
            response.doiordob = queryResult.MDM_DOI_or_DOB__c ;
                    
        }
    }

    

    /**
     * @description : adding source customers to the response if query parameter 'part' contains 'externalIDs'
     * @param queryResult
     * @param response
     * @param customerRequest
     */
    public static void addExternalIDsResponse(MDM_Customer__c queryResult, MDM_CustomerAPIWrapper.MDM_GetCustomerResponse response,
                             MDM_CustomerAPIWrapper.MDM_GetCustomerRequest customerRequest)
    {
        if(customerRequest.part==NULL || customerRequest.part.containsIgnoreCase('externalIDs')) {
            if(!queryResult.Source_Customers__r.isEmpty()) {
                response.externalIDs = new List<MDM_CustomerAPIWrapper.MDM_ExternalID>();
                for(MDM_Source_Customer__c sourceCustomer: queryResult.Source_Customers__r) {
                    MDM_CustomerAPIWrapper.MDM_ExternalID externalIDLocal = new MDM_CustomerAPIWrapper.MDM_ExternalID();
                    externalIDLocal.id = sourceCustomer.MDM_Source_System_ID__c;
                    externalIDLocal.name = sourceCustomer.Name;
                    externalIDLocal.sourceSystem = sourceCustomer.MDM_Source_System__c;
    
                    externalIDLocal.type = sourceCustomer.MDM_Account_Type__c;
                    externalIDLocal.isPrimary = sourceCustomer.MDM_Is_Primary__c;
                    response.externalIDs.add(externalIDLocal);
                }   
            }
        }
    }

   

    /**
     * @description : prepare adddress to response
     * @param custConAddressMapWrap
     * @param customer
     * @param response
     * @return Map<ID,List<MDM_CustomerAPIWrapper.MDM_Address>>
     */
    public static Map<ID,List<MDM_CustomerAPIWrapper.MDM_Address>> prepareAddressToResponse(
        MDM_CustomerAPIWrapper.CustConAddressMap custConAddressMapWrap, MDM_Customer__c customer,
        MDM_CustomerAPIWrapper.MDM_GetCustomerResponse response)
    {    
        Map<ID,List<MDM_CustomerAPIWrapper.MDM_Address>> contactAddressesMap = new Map<ID,List<MDM_CustomerAPIWrapper.MDM_Address>>();
        if(custConAddressMapWrap.addressesMap.get(customer.ID) != NULL) {
            List<MDM_CustomerAPIWrapper.MDM_Address> addressesLocal = new List<MDM_CustomerAPIWrapper.MDM_Address>();
            for(MDM_Address__c address: custConAddressMapWrap.addressesMap.get(customer.ID)) {
                MDM_CustomerAPIWrapper.MDM_Address addressLocal = new MDM_CustomerAPIWrapper.MDM_Address();
                addressLocal.addressId = address.Id;
                addressLocal.address1 = address.MDM_Address_1__c;
                addressLocal.address2 = address.MDM_Address_2__c;
                addressLocal.address3 = address.MDM_Address_3__c;
                addressLocal.addressType = address.MDM_Address_Type__c;
                addressLocal.city = address.MDM_City__c;
                addressLocal.country = address.MDM_Country__c;
                addressLocal.state = address.MDM_State__c;
                addressLocal.countryCode = address.MDM_Country_Code__c;
                addressLocal.zipCode = address.MDM_Zip_Code__c;
                addressLocal.phone = address.MDM_Phone__c;
                addressLocal.extension = address.MDM_Extension__c;
                addressLocal.fax = address.MDM_Fax__c;
                addressLocal.email = address.MDM_Email__c;
                addressLocal.description = address.MDM_Description_Notes__c;
                addressLocal.addressStatus = address.MDM_Status__c;
                addressLocal.addressSourceSystem = address.MDM_External_System_Name__c;
                addressLocal.addressSourceSystemPrimary = String.valueOf(address.MDM_Source_System_Primary__c);
                addressLocal.addressSourceSystemId = address.MDM_Source_System_Address_Id__c != NULL ? 
                                             String.valueOf(address.MDM_Source_System_Address_Id__c) : NULL;
                addressLocal.verifiedAddress = String.valueOf(address.MDM_Source_System_Verified__c); 
                addressLocal.isPrimary = String.valueOf(address.MDM_Primary__c);
                contactAddressesMap.putAll(populateContactAddressesMap(address,addressLocal, addressesLocal));
            }
            addAddressToResponse(addressesLocal, response);  
        }
        return contactAddressesMap;
    }

    /**
     * @description : contactAddressesMap
     * @param address
     * @param addressLocal
     * @param addressesLocal
     * @return Map<ID,List<MDM_CustomerAPIWrapper.MDM_Address>>
     */
    static Map<ID,List<MDM_CustomerAPIWrapper.MDM_Address>> populateContactAddressesMap(MDM_Address__c address, 
        MDM_CustomerAPIWrapper.MDM_Address addressLocal, List<MDM_CustomerAPIWrapper.MDM_Address> addressesLocal)
    {
        Map<ID,List<MDM_CustomerAPIWrapper.MDM_Address>> contactAddressesMap = new Map<ID,List<MDM_CustomerAPIWrapper.MDM_Address>>();
        if(address.MDM_Contact__c != NULL) {
            if(contactAddressesMap.get(address.MDM_Contact__c) != NULL) {
                List<MDM_CustomerAPIWrapper.MDM_Address> addressesInMap = contactAddressesMap.get(address.MDM_Contact__c);
                addressesInMap.add(addressLocal);
                contactAddressesMap.put(address.MDM_Contact__c, addressesInMap);
            } else {
                contactAddressesMap.put(address.MDM_Contact__c, new List<MDM_CustomerAPIWrapper.MDM_Address> {addressLocal});
            }
        } else {
            addressesLocal.add(addressLocal);
        }
        return contactAddressesMap;
    }
    
    /**
     * @description : populate customerRequest.fields
     * @param queryResult
     * @param response
     * @param customerRequest
    */
    static void populateCustRequestfield(MDM_Customer__c queryResult, MDM_CustomerAPIWrapper.MDM_GetCustomerResponse response,
                MDM_CustomerAPIWrapper.MDM_GetCustomerRequest customerRequest)
    {
        response.name = customerRequest.field.contains('name') ? queryResult.Name : NULL;
        response.mdmId = customerRequest.field.contains('mdmId') ? queryResult.MDM_ID__c : NULL;
        response.description = customerRequest.field.contains('description') ? queryResult.MDM_Description__c : NULL;
        response.status = customerRequest.field.contains('status') ? queryResult.MDM_Customer_Status__c : NULL;
        response.accountType = customerRequest.field.contains('accountType') ? queryResult.MDM_Account_Type__c : NULL;
        response.industryType = customerRequest.field.contains('industryType') ? queryResult.MDM_Industry_Type__c : NULL;
        response.customerId = customerRequest.field.contains('customerId') ? queryResult.MDM_Customer_Id__c : NULL;
        response.doiordob = customerRequest.field.contains('doiordob') ? queryResult.MDM_DOI_or_DOB__c : NULL;
        
        response.isDeleted = customerRequest.field.contains('isDeleted') ? String.valueOf(queryResult.MDM_is_Deleted__c) : NULL; 
        
        
    }
    
    /**
     * @description : Add address to response
     * @param addressesLocal
     * @param response
     */
    public static void addAddressToResponse(List<MDM_CustomerAPIWrapper.MDM_Address> addressesLocal,
            MDM_CustomerAPIWrapper.MDM_GetCustomerResponse response)
    {
        if(addressesLocal.size() > 0) {
            if(response.contactAddresses == NULL) {
                response.contactAddresses = new List<MDM_CustomerAPIWrapper.MDM_ContactAddress>();
            }
            MDM_CustomerAPIWrapper.MDM_ContactAddress contactAddressLocal = new MDM_CustomerAPIWrapper.MDM_ContactAddress();
            contactAddressLocal.addresses = addressesLocal;
            response.contactAddresses.add(contactAddressLocal);    
        } 
    }
    
    /**
     * @description : add contact to response
     * @param contact
     * @param contactAddressesMap 
     * @param response
     */
    public static void addContactToResponse(MDM_Contact__c contact, Map<ID,List<MDM_CustomerAPIWrapper.MDM_Address>> contactAddressesMap, 
                     MDM_CustomerAPIWrapper.MDM_GetCustomerResponse response)
    {
        MDM_CustomerAPIWrapper.MDM_ContactAddress contactAddressLocal = new MDM_CustomerAPIWrapper.MDM_ContactAddress();
        contactAddressLocal.contactId = contact.Id;
        contactAddressLocal.contactName = contact.Name;
        contactAddressLocal.suffix = contact.MDM_Name_Suffix__c;
        contactAddressLocal.title = contact.MDM_Title__c;
        contactAddressLocal.status = contact.MDM_Status__c;
        contactAddressLocal.phone = contact.MDM_Phone__c;
        contactAddressLocal.fax = contact.MDM_Fax__c;
        contactAddressLocal.email = contact.MDM_Email__c;
        contactAddressLocal.extension = contact.MDM_Extension__c;
        contactAddressLocal.contactSourceSystem = contact.MDM_External_System_Name__c;
        contactAddressLocal.contactSourceSystemId = contact.MDM_Source_System_Contact_Id__c != NULL ? 
            String.valueOf(contact.MDM_Source_System_Contact_Id__c) : NULL;
        contactAddressLocal.addresses = contactAddressesMap.get(contact.ID);
        if(response.contactAddresses == NULL) {
            response.contactAddresses = new List<MDM_CustomerAPIWrapper.MDM_ContactAddress>();
        }
        response.contactAddresses.add(contactAddressLocal);
    }
}