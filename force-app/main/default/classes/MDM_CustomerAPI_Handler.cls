/**
 * @description       : 
 * @author            : Priya Sharma
 * @group             : 
 * @last modified on  : 05-28-2021
 * @last modified by  : Komal Sonsale
 * Modifications Log 
 * Ver   Date         Author         Modification
 * 1.0   04-05-2021   Priya Sharma   Initial Version
**/

//suppressed as it contains all the API calls 
@SuppressWarnings('PMD.CyclomaticComplexity,PMD.CognitiveComplexity')
global with sharing class MDM_CustomerAPI_Handler {        
    /**
     * @description Create error message.
     * @param statusCode
     * @param detail
     * @param message
     * @return MDM_CustomerAPIWrapper.MDM_Error
     */ 
    public static MDM_CustomerAPIWrapper.MDM_Error createErrorMessage(Integer statusCode, String detail, String message) {
        RestContext.response.statusCode = statusCode;
        RestContext.response.addHeader('Content-Type', 'application/json');
        return new MDM_CustomerAPIWrapper.MDM_Error(detail, message, '');
    }

    /**
     * @description create payload for individual customer in response
     * @param customer
     * @param customerRequest
     * @param custConAddressMapWrap
     * @return MDM_GetCustomerResponse 
     */
    public static MDM_CustomerAPIWrapper.MDM_GetCustomerResponse getIndividualCustomer(MDM_Customer__c customer,
             MDM_CustomerAPIWrapper.MDM_GetCustomerRequest customerRequest, MDM_CustomerAPIWrapper.CustConAddressMap custConAddressMapWrap) 
    {
        MDM_Customer__c queryResult = customer;
        MDM_CustomerAPIWrapper.MDM_GetCustomerResponse response = new MDM_CustomerAPIWrapper.MDM_GetCustomerResponse();
        //adding fields to the response based on query parameter 'field'      
        MDM_GetIndividualCustomerAPIHandler.addQueryFieldsToResponse(queryResult, response, customerRequest);
    
        //adding source customers to the response if query parameter 'part' contains 'externalIDs'
        MDM_GetIndividualCustomerAPIHandler.addExternalIDsResponse(queryResult, response, customerRequest);

        

        //adding contacts and addresses to the response if query parameter 'part' contains 'contactAddresses'
        if(customerRequest.part==NULL || customerRequest.part.containsIgnoreCase('contactAddresses')) {
            Map<ID,List<MDM_CustomerAPIWrapper.MDM_Address>> contactAddressesMap =
                     MDM_GetIndividualCustomerAPIHandler.prepareAddressToResponse(custConAddressMapWrap, customer, response);
            if(custConAddressMapWrap.contactsMap.get(customer.ID) != NULL) {
                for(MDM_Contact__c contact: custConAddressMapWrap.contactsMap.get(customer.ID)) {
                    MDM_GetIndividualCustomerAPIHandler.addContactToResponse(contact, contactAddressesMap, response);
                }
            }            
        }        
        return response;
    }
    
    /**
     * @description : getcustomerIDs
     * @param customerRequest
     * @return String[]
     */
    static String[] getIds(MDM_CustomerAPIWrapper.MDM_GetCustomerRequest customerRequest){
        String[] ids = new List<String>();
        if(customerRequest.mdmIds != NULL) {
            for(String id: customerRequest.mdmIds) {
                ids.add(id);
            }
        }                                 
        return ids;
    }
    /**
     * @description GET Customer
     */
    public static void get() {
        MDM_CustomerAPIWrapper.MDM_GetCustomerResponse[] response = new List<MDM_CustomerAPIWrapper.MDM_GetCustomerResponse>();       
        MDM_CustomerAPIWrapper.MDM_GetCustomerRequest customerRequest = new MDM_CustomerAPIWrapper.MDM_GetCustomerRequest();        
       
        
        MDM_CustomerGetAPIHandler.validateMDMIDs(customerRequest); if(!customerRequest.isValid){ return ;}
        //validate query parameter customerType if null or blank and is valid
        MDM_CustomerGetAPIHandler.validateCustomerType(customerRequest); if(!customerRequest.isValid){ return ;}    
        //validate query parameter statusfilter if null or blank and is valid
        MDM_CustomerGetAPIHandler.validateQueryStatus(customerRequest);  if(!customerRequest.isValid){ return ;}      
        //validate query parameter field if null or blank and is valid
        MDM_CustomerGetAPIHandler.validateQueryParameterField(customerRequest); if(!customerRequest.isValid){ return ;}
        //validate query parameter part if null or blank and is valid 
        MDM_CustomerGetAPIHandler.validateQueryParameterPart(customerRequest); if(!customerRequest.isValid){ return ;}
      
        List<MDM_Customer__c> queryResult= MDM_CustomerGetAPIHandler.getCustomerList(customerRequest,getIds(customerRequest));
        MDM_CustomerAPIWrapper.CustConAddressMap custConAddressMapWrap = new MDM_CustomerAPIWrapper.CustConAddressMap();    
        //create contactAddresses as per required format
        MDM_CustomerGetAPIHandler.populateConAddChildMap(custConAddressMapWrap, queryResult, customerRequest);  
        for(MDM_Customer__c customer: queryResult) {
            response.add(getIndividualCustomer(customer, customerRequest, custConAddressMapWrap));
        }
        if(response.size()==0) {
            RestContext.response.responseBody = Blob.valueOf(
                JSON.serialize(MDM_CustomerAPI_Handler.createErrorMessage(200,
                         'No records found for given query.', 'Error 404, EMPTY RESPONSE'))); 
            return;
        }

        MDM_CustomerAPIWrapper.MDM_Response finalResponse = new MDM_CustomerAPIWrapper.MDM_Response();
        finalResponse.totalNumberOfRecords = MDM_CustomerGetAPIHandler.countNumberOfRecords(customerRequest,getIds(customerRequest));
        finalResponse.customers = response;
        RestContext.response.addHeader('Content-Type', 'application/json');
        RestContext.response.responseBody = Blob.valueOf(JSON.serialize(finalResponse, true));
    }
    
    /**
     * @description create payload for individual customer in search response
     * @param customer
     * @param sourceCustomer
     * @param sourceParentCustomer
     * @return MDM_SearchResponse
     */
    public static MDM_CustomerAPIWrapper.MDM_SearchResponse searchIndividualCustomer(
        MDM_Customer__c customer, 
        MDM_Source_Customer__c sourceCustomer, 
        MDM_Customer__c sourceParentCustomer
    ) {
        MDM_CustomerAPIWrapper.MDM_SearchResponse response = new MDM_CustomerAPIWrapper.MDM_SearchResponse();
        if(sourceCustomer == NULL) {
            getCustomersResponse(customer, response);
        } else {
            getRefSysCustomersResponse(sourceCustomer, response);
           
        }
        return response;
    }

    /**
     * @description : get customer response if sourcecustomer is null
     * @param customer
     * @param response
     */
    static void getCustomersResponse(MDM_Customer__c customer, MDM_CustomerAPIWrapper.MDM_SearchResponse response){
        response.mdmId = customer.MDM_ID__c;
        response.name = customer.Name;
        response.accountType = customer.MDM_Account_Type__c;  
        response.status = customer.MDM_Customer_Status__c;
        response.description = customer.MDM_Description__c;
        response.createdDate = customer.CreatedDate;
        response.lastModifiedDate = customer.LastModifiedDate;
        response.isDeleted = String.valueOf(customer.MDM_is_Deleted__c);
        response.industryType = customer.MDM_Industry_Type__c;
        response.customerId = customer.MDM_Customer_Id__c ;
        response.doiordob = customer.MDM_DOI_or_DOB__c ;
       
        
        if(!customer.Source_Customers__r.isEmpty()) {
            response.externalIDs = new List<MDM_CustomerAPIWrapper.MDM_ExternalID>();
            for(MDM_Source_Customer__c srcCustomer: customer.Source_Customers__r) {
                MDM_CustomerAPIWrapper.MDM_ExternalID externalIDLocal = new MDM_CustomerAPIWrapper.MDM_ExternalID();
                externalIDLocal.id = srcCustomer.MDM_Source_System_ID__c;
                externalIDLocal.name = srcCustomer.Name;
                externalIDLocal.sourceSystem = srcCustomer.MDM_Source_System__c;
                response.externalIDs.add(externalIDLocal);
            }
        }
    }




    /**
     * @description : get sourceCustomer.MDM_Customer__r response
     * @param sourceCustomer
     * @param response
     */
    static void getRefSysCustomersResponse(MDM_Source_Customer__c sourceCustomer, MDM_CustomerAPIWrapper.MDM_SearchResponse response){
        if(sourceCustomer.MDM_Customer__r != NULL) {
            response.mdmId = sourceCustomer.MDM_Customer__r.MDM_Id__c;
            response.name = sourceCustomer.MDM_Customer__r.Name;
            response.accountType = sourceCustomer.MDM_Customer__r.MDM_Account_Type__c; 
            response.status = sourceCustomer.MDM_Customer__r.MDM_Customer_Status__c;
            response.description = sourceCustomer.MDM_Customer__r.MDM_Description__c;
            response.createdDate = sourceCustomer.MDM_Customer__r.CreatedDate;
            response.lastModifiedDate = sourceCustomer.MDM_Customer__r.LastModifiedDate;
            response.isDeleted = String.valueOf(sourceCustomer.MDM_Customer__r.MDM_Is_Deleted__c); 
            response.industryType = sourceCustomer.MDM_Customer__r.MDM_Industry_Type__c;
            response.customerId = sourceCustomer.MDM_Customer__r.MDM_Customer_Id__c ;
            response.doiordob = sourceCustomer.MDM_Customer__r.MDM_DOI_or_DOB__c ;
        }
    }

    /**
     * @description : get customer recordtypes 
     * @return List<String>
     */
    public static List<String> getRecordTypes(){
        List<String> types = new List<String>();
        for(Schema.PicklistEntry pe: MDM_Customer__c.MDM_Account_Type__c.getDescribe().getPicklistValues()) {
            types.add(pe.getValue().toLowercase());    
        }
        return types;
    }

    /**
     * @description Search Customer
     */
    @SuppressWarnings('PMD.NcssMethodCount')
    public static void search() {
        MDM_CustomerAPIWrapper.MDM_SearchRequest searchRequest = new MDM_CustomerAPIWrapper.MDM_SearchRequest();
        List<String> externalSystemIDsNotInResponse = new List<String>();
        List<String> mdmIdsNotInResponse = new List<String>();
        List<MDM_CustomerAPIWrapper.MDM_SearchResponse> response = new List<MDM_CustomerAPIWrapper.MDM_SearchResponse>();
        Integer parameterCount = 0;
        //validate if query parameter customerType is valid
        MDM_CustomerSearchAPIHandler.validateCustomerType(searchRequest); if(!searchRequest.isValidSearch){ return; }       
        //validate if query parameter mdmIds is valid
        parameterCount = MDM_CustomerSearchAPIHandler.validateMDMIDs(searchRequest, parameterCount); 
        if(!searchRequest.isValidSearch){ return; }           
        //validate if query parameter limit is valid
        MDM_CustomerSearchAPIHandler.validateQueryParamterLimit(searchRequest); if(!searchRequest.isValidSearch){ return; }    
        //validate if query parameter statusFilter is valid
        MDM_CustomerSearchAPIHandler.validateStatusFilters(searchRequest);  if(!searchRequest.isValidSearch){ return; }          
        //validate if query parameter lastModifiedDateFrom is valid
        MDM_CustomerSearchAPIHandler.validateLastModifiedDateFrom(searchRequest); if(!searchRequest.isValidSearch){ return; }           
        //validate if query parameter lastModifiedDateTo is valid
        MDM_CustomerSearchAPIHandler.validateLastModifiedDateTo(searchRequest);  if(!searchRequest.isValidSearch){ return; }    
        //validate if query parameter query is valid
        parameterCount = MDM_CustomerSearchAPIHandler.validateQueryParameter(searchRequest, parameterCount); 
        if(!searchRequest.isValidSearch){ return; }    
        //validate if query parameter sourceSystems is valid
        MDM_CustomerSearchAPIHandler.validateSourceSystem(searchRequest); if(!searchRequest.isValidSearch){ return; }       
        //validate if query parameter externalSystemIDs is valid
        MDM_CustomerSearchAPIHandler.validateExternalSystemIds(searchRequest, parameterCount);
        if(!searchRequest.isValidSearch){ return; }    
        //retrieve search results based on lastModifiedDate range
        MDM_CustomerSearchAPIHandler.retriveCustBasedOnLastModifiedDate(searchRequest, response);
        //retrieve search results based on mdmIds
        MDM_CustomerSearchAPIHandler.retriveCustBasedOnMDMIds(searchRequest, response, mdmIdsNotInResponse);
        //retrieve search results based on query
        MDM_CustomerSearchAPIHandler.retriveBasesOnQuery(searchRequest, response);
        //retrieve search results based on externalSystemIDs
        MDM_CustomerSearchAPIHandler.retrieveBasedOnExternalIds(searchRequest, response, externalSystemIDsNotInResponse);
        //set error to response body
        if(response.size()==0) {
            RestContext.response.responseBody = Blob.valueOf(
                JSON.serialize(MDM_CustomerAPI_Handler.createErrorMessage(200, 
                    'No records found for given query.', 'Error 404, EMPTY RESPONSE'))); 
            return;
        }
        RestContext.response.addHeader('Content-Type', 'application/json');
        MDM_CustomerSearchAPIHandler.addExternalSysIdsErrorResponse(response, searchRequest, externalSystemIDsNotInResponse);        
        MDM_CustomerSearchAPIHandler.addMDMIdsErrorResponse(response, searchRequest,mdmIdsNotInResponse);
        RestContext.response.responseBody = Blob.valueOf(JSON.serialize(response, true));
    }    
}