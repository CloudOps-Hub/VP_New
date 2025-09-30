/**
 * @description       : 
 * @author            : Priya Sharma
 * @group             : 
 * @last modified on  : 05-27-2021
 * @last modified by  : Komal Sonsale
 * Modifications Log 
 * Ver   Date         Author         Modification
 * 1.0   04-16-2021   Priya Sharma   Initial Version
**/

//suppressed as it contains all search API methods 
@SuppressWarnings('PMD.CyclomaticComplexity,PMD.CognitiveComplexity')
public with sharing class MDM_CustomerSearchAPIHandler {
    /**
     * @description : validate if query parameter customerType is valid
     * @param searchRequest
     */
    public static void validateCustomerType(MDM_CustomerAPIWrapper.MDM_SearchRequest searchRequest){
        List<String> types = MDM_CustomerAPI_Handler.getRecordTypes();
        searchRequest.customerType = RestContext.request.params.get('customerType');
        if(searchRequest.customerType == '' || searchRequest.customerType == 'null') {
            searchRequest.customerType = NULL;
        }
        if(searchRequest.customerType != NULL) {
            if(!types.contains(searchRequest.customerType.toLowerCase())) {
                RestContext.response.responseBody = Blob.valueOf(
                    JSON.serialize(MDM_CustomerAPI_Handler.createErrorMessage(200, 'Invalid query parameter: customerType',
                                                                              'Error 400, BAD REQUEST'))); 
                searchRequest.isValidSearch = false;
            }
        }
    }

    /**
     * @description :validate if query parameter mdmIds is valid
     * @param searchRequest
     * @param parameterCount
     * @return Integer
     */
    public static Integer validateMDMIDs(MDM_CustomerAPIWrapper.MDM_SearchRequest searchRequest, Integer parameterCount){
        if(RestContext.request.params.get('mdmIds') != NULL && 
        RestContext.request.params.get('mdmIds') != '' && 
        RestContext.request.params.get('mdmIds') != 'null') {
            searchRequest.mdmIds = RestContext.request.params.get('mdmIds').split(',');
            parameterCount++;
        } else {
            searchRequest.mdmIds = NULL;
        }
        return parameterCount;
    }

    /**
     * @description : validate if query parameter limit is valid
     * @param searchRequest
     */
    public static void validateQueryParamterLimit(MDM_CustomerAPIWrapper.MDM_SearchRequest searchRequest){
        searchRequest.limitation = RestContext.request.params.get('limit');
        if(searchRequest.limitation == '' || searchRequest.limitation == 'null') {
            searchRequest.limitation = NULL;
        }
        if(searchRequest.limitation != NULL) {
            if(!searchRequest.limitation.isNumeric()) {
               RestContext.response.responseBody = Blob.valueOf(
                    JSON.serialize(MDM_CustomerAPI_Handler.createErrorMessage(200, 
                    'Invalid query parameter: limit. Type Error: limit should be numeric.',
                    'Error 400, BAD REQUEST'))); 
               searchRequest.isValidSearch = false;
            }  
        }
    }

    /**
     * @description : validate if query parameter statusFilter is valid
     * @param searchRequest
     */
    public static void validateStatusFilters(MDM_CustomerAPIWrapper.MDM_SearchRequest searchRequest){
        List<String> statusFilters = new List<String>();
        for(Schema.PicklistEntry pe: MDM_Customer__c.MDM_Customer_Status__c.getDescribe().getPicklistValues()) {
            statusFilters.add(pe.getValue().toLowercase());    
        }
        searchRequest.statusFilter = RestContext.request.params.get('statusFilter');
        if(searchRequest.statusFilter == '' || searchRequest.statusFilter == 'null') {
            searchRequest.statusFilter = NULL;
        }
        if(searchRequest.statusFilter != NULL) {
            if(!statusFilters.contains(searchRequest.statusFilter.toLowerCase())) {
               RestContext.response.responseBody = Blob.valueOf(
                    JSON.serialize(MDM_CustomerAPI_Handler.createErrorMessage(200, 'Invalid query parameter: statusFilter.', 
                                                                              'Error 400, BAD REQUEST'))); 
                searchRequest.isValidSearch = false;
            }   
        }
    }

    /**
     * @description : validate if query parameter lastModifiedDateFrom is valid
     * @param searchRequest
     */
    public static void validateLastModifiedDateFrom(MDM_CustomerAPIWrapper.MDM_SearchRequest searchRequest){
        String lastModifiedDateFrom = RestContext.request.params.get('lastModifiedDateFrom');
        if(lastModifiedDateFrom == '' || lastModifiedDateFrom == 'null') {
            lastModifiedDateFrom = NULL;
        }
        if(lastModifiedDateFrom != NULL) {
            try {
                Date dateFrom = Date.valueOf(lastModifiedDateFrom);
                searchRequest.lastModifiedDateFrom = ('0000' + dateFrom.year()).right(4) + 
                    '-' + ('00' + dateFrom.month()).right(2) + '-' + ('00' + dateFrom.day()).right(2) + 'T00:00:00z';   
            }
            catch(Exception e) {
                RestContext.response.responseBody = Blob.valueOf(
                    JSON.serialize(MDM_CustomerAPI_Handler.createErrorMessage(200, 'Invalid date: lastModifiedDateFrom',
                                                                              'Error 400, BAD REQUEST'))); 
                searchRequest.isValidSearch = false;
            }
        }
    }

    /**
     * @description : validate if query parameter lastModifiedDateTo is valid
     * @param searchRequest
     */
    public static void validateLastModifiedDateTo(MDM_CustomerAPIWrapper.MDM_SearchRequest searchRequest){
        String lastModifiedDateTo = RestContext.request.params.get('lastModifiedDateTo');
        if(lastModifiedDateTo == '' || lastModifiedDateTo == 'null') {
            lastModifiedDateTo = NULL;
        }
        if(lastModifiedDateTo != NULL) {
            try {
                Date dateTo = Date.valueOf(lastModifiedDateTo);
                searchRequest.lastModifiedDateTo = ('0000' + dateTo.year()).right(4) +
                    '-' + ('00' + dateTo.month()).right(2) + '-' + ('00' + dateTo.day()).right(2) + 'T23:59:59z';
            }
            catch(Exception e) {
                RestContext.response.responseBody = Blob.valueOf(
                    JSON.serialize(MDM_CustomerAPI_Handler.createErrorMessage(200, 'Invalid date: lastModifiedDateTo',
                                                                              'Error 400, BAD REQUEST'))); 
                searchRequest.isValidSearch = false;
            }
        }
    }

    /**
     * @description : validate if query parameter query is valid
     * @param searchRequest
     * @param parameterCount
     * @return Integer
     */
    public static Integer validateQueryParameter(MDM_CustomerAPIWrapper.MDM_SearchRequest searchRequest, Integer parameterCount){
        searchRequest.query = RestContext.request.params.get('query');
        if(searchRequest.query == '' || searchRequest.query == 'null' || searchRequest.query == NULL) {
            searchRequest.query = NULL;
        }
        else {
            parameterCount++;
        }
        return parameterCount;
    }

    /**
     * @description : validate if query parameter sourceSystems is valid
     * @param searchRequest
     */
    public static void validateSourceSystem(MDM_CustomerAPIWrapper.MDM_SearchRequest searchRequest){
        List<String> sourceSystemsList = new List<String>();
        for(Schema.PicklistEntry pe: MDM_Source_Customer__c.MDM_Source_System__c.getDescribe().getPicklistValues()) {
            sourceSystemsList.add(pe.getValue().toLowercase());    
        }
        if(RestContext.request.params.get('sourceSystems') == '' || 
        RestContext.request.params.get('sourceSystems') == NULL || 
        RestContext.request.params.get('sourceSystems') == 'null') {
            searchRequest.sourceSystems = NULL;
        }
        else {
            for(String inputField: RestContext.request.params.get('sourceSystems').split(',')) {
                if(!sourceSystemsList.contains(inputField.toLowercase())) {
                    RestContext.response.responseBody = Blob.valueOf(
                        JSON.serialize(MDM_CustomerAPI_Handler.createErrorMessage(200, 'Invalid query parameter: sourceSystems.', 
                                                                                  'Error 400, BAD REQUEST'))); 
                   searchRequest.isValidSearch = false;
                }
            }
            searchRequest.sourceSystems = RestContext.request.params.get('sourceSystems').split(',');
        }
    }

    /**
     * @description : validate if query parameter externalSystemIDs is valid
     * @param searchRequest
     * @param parameterCount
     */
    public static void validateExternalSystemIds(MDM_CustomerAPIWrapper.MDM_SearchRequest searchRequest, Integer parameterCount){
        if(RestContext.request.params.get('externalSystemIDs') != NULL && 
        RestContext.request.params.get('externalSystemIDs') != '' && 
        RestContext.request.params.get('externalSystemIDs') != 'null') {
            searchRequest.externalSystemIDs = RestContext.request.params.get('externalSystemIDs').split(',');
            parameterCount++;
        }
        else {
            searchRequest.externalSystemIDs = NULL;
        }
        //if mdmIds, query and externalSystemIDs are all NULL, give error
        if(searchRequest.mdmIds==NULL && 
        searchRequest.query==NULL && 
        searchRequest.externalSystemIDs==NULL && 
        searchRequest.lastModifiedDateFrom==NULL) {
            RestContext.response.responseBody = Blob.valueOf(
                JSON.serialize(MDM_CustomerAPI_Handler.createErrorMessage(200, 
                        'A search must be done on either keyword, External System ID,'+ 
                        'MDM ID or LastModifiedDate range(lastModifiedDateFrom mandatory).', 
                        'Error 400, BAD REQUEST'))); 
            searchRequest.isValidSearch = false;
        }
        
        //if more than one of mdmIds, query and externalSystemIDs are not NULL, give error
        if(parameterCount > 1) {
            RestContext.response.responseBody = Blob.valueOf(
                JSON.serialize(MDM_CustomerAPI_Handler.createErrorMessage(200, 
                    'Invalid query parameters. You can specify only one of mdmIds, query or externalSystemIDs.', 
                    'Error 400, BAD REQUEST'))); 
            searchRequest.isValidSearch = false;
        }
    }

    
    /**
     * @description : retrieve search results based on lastModifiedDate range
     * @param searchRequest
     * @param response
     */
    public static void retriveCustBasedOnLastModifiedDate(MDM_CustomerAPIWrapper.MDM_SearchRequest searchRequest,
        List<MDM_CustomerAPIWrapper.MDM_SearchResponse> response)
    {
        String statusFilter = searchRequest.statusFilter;
        String customerType = searchRequest.customerType;
        if(searchRequest.mdmIds==NULL && searchRequest.externalSystemIDs==NULL && 
            searchRequest.query==NULL && searchRequest.lastModifiedDateFrom!=NULL) {
           
            String query = 'SELECT MDM_ID__c, Name, MDM_Account_Type__c, MDM_Customer_Status__c, MDM_Description__c,'+
                ' MDM_Is_Deleted__c,MDM_Customer_Id__c ,MDM_Industry_Type__c, MDM_DOI_or_DOB__c,   '+
                'CreatedDate, LastModifiedDate,' +
                
                '(SELECT MDM_Source_System__c, Name, MDM_Source_System_ID__c FROM Source_Customers__r LIMIT 200)' +
                'FROM MDM_Customer__c WHERE LastModifiedDate >= ' + searchRequest.lastModifiedDateFrom +
                (searchRequest.statusFilter==NULL?' ':' AND MDM_Customer_Status__c = :statusFilter') +
                (searchRequest.customerType==NULL?' ':' AND MDM_Account_Type__c = :customerType') +
                (searchRequest.lastModifiedDateTo==NULL?' ':' AND LastModifiedDate <= ' + searchRequest.lastModifiedDateTo) +
                (searchRequest.limitation==NULL?' ':' LIMIT ' + searchRequest.limitation);
            
            List<MDM_Customer__c> queryResult = Database.query(String.escapeSingleQuotes(query));
            for(MDM_Customer__c customer: queryResult) {
                response.add(MDM_CustomerAPI_Handler.searchIndividualCustomer(customer, NULL, NULL));
            }
        }
    }

    /**
     * @description : get MDM Id's
     * @param searchRequest
     * @return String[]
     */
    static String[] getMDMIds(MDM_CustomerAPIWrapper.MDM_SearchRequest searchRequest){
        String[] ids = new List<String>();
        if(searchRequest.mdmIds != NULL) {
            for(String id: searchRequest.mdmIds) {
                ids.add(id);
            }
        }
        return ids;
    }

    /**
     * @description : retrieve search results based on mdmIds
     * @param searchRequest
     * @param response
     * @param mdmIdsNotInResponse
     */
    public static void retriveCustBasedOnMDMIds(MDM_CustomerAPIWrapper.MDM_SearchRequest searchRequest,
            List<MDM_CustomerAPIWrapper.MDM_SearchResponse> response, List<String> mdmIdsNotInResponse)
    {
        String statusFilter = searchRequest.statusFilter;
        String customerType = searchRequest.customerType;
        if(searchRequest.mdmIds!=NULL) {
            String[] ids = new List<String>();
            ids = getMDMIds(searchRequest);            
            mdmIdsNotInResponse = searchRequest.mdmIds;
        
            String query = 'SELECT MDM_ID__c, Name, MDM_Account_Type__c, MDM_Customer_Status__c, MDM_Description__c,'+
                ' MDM_Is_Deleted__c,MDM_Customer_Id__c ,MDM_Industry_Type__c, MDM_DOI_or_DOB__c,  ' +
                'CreatedDate, LastModifiedDate,' + 
                '(SELECT MDM_Source_System__c, Name, MDM_Source_System_ID__c FROM Source_Customers__r LIMIT 200)' +
                'FROM MDM_Customer__c WHERE  MDM_ID__c IN :ids '+
                (searchRequest.statusFilter==NULL?' ':' AND MDM_Customer_Status__c = :statusFilter') +
                (searchRequest.customerType==NULL?' ':' AND MDM_Account_Type__c = :customerType') +
                (searchRequest.lastModifiedDateFrom==NULL?' ':' AND LastModifiedDate >= ' + searchRequest.lastModifiedDateFrom) +
                (searchRequest.lastModifiedDateTo==NULL?' ':' AND LastModifiedDate <= ' + searchRequest.lastModifiedDateTo) +
                (searchRequest.limitation==NULL?' ':' LIMIT ' + searchRequest.limitation);            
            List<MDM_Customer__c> queryResult = Database.query(String.escapeSingleQuotes(query));
            addResponseBasedOnMDMIds(response, mdmIdsNotInResponse, queryResult);
        }
    }

    /**
     * @description : add to response based on mdmIds
     * @param response
     * @param mdmIdsNotInResponse
     * @param queryResult
     */
    static void addResponseBasedOnMDMIds(List<MDM_CustomerAPIWrapper.MDM_SearchResponse> response,
            List<String> mdmIdsNotInResponse, List<MDM_Customer__c> queryResult){
        for(MDM_Customer__c customer: queryResult) {
            Integer index = mdmIdsNotInResponse.indexOf(customer.MDM_ID__c);
            if(index>=0 && index<mdmIdsNotInResponse.size()) {
                mdmIdsNotInResponse.remove(index);    
            }
            response.add(MDM_CustomerAPI_Handler.searchIndividualCustomer(customer, NULL, NULL));
        }
    }

    /**
     * @description : retrieve search results based on query
     * @param searchRequest
     * @param response
     */
    public static void retriveBasesOnQuery(MDM_CustomerAPIWrapper.MDM_SearchRequest searchRequest,
                    List<MDM_CustomerAPIWrapper.MDM_SearchResponse> response)
    {   
        String statusFilter = searchRequest.statusFilter;
        String customerType = searchRequest.customerType;
        if(searchRequest.query != NULL) {  
            String queryName = NULL;
            queryName = '%' + searchRequest.query + '%';            
          
            String query = 'SELECT MDM_ID__c, Name, MDM_Account_Type__c, MDM_Customer_Status__c, MDM_Description__c,'+
                ' MDM_Is_Deleted__c,MDM_Customer_Id__c ,MDM_Industry_Type__c, MDM_DOI_or_DOB__c,  ' + 
                'CreatedDate, LastModifiedDate,' + 
               
                '(SELECT MDM_Source_System__c, Name, MDM_Source_System_ID__c FROM Source_Customers__r LIMIT 200)' +
                'FROM MDM_Customer__c WHERE Name LIKE :queryName' +
                (searchRequest.statusFilter==NULL?' ':' AND MDM_Customer_Status__c = :statusFilter') +
                (searchRequest.customerType==NULL?' ':' AND MDM_Account_Type__c = :customerType') +
                (searchRequest.lastModifiedDateFrom==NULL?' ':' AND LastModifiedDate >= ' + searchRequest.lastModifiedDateFrom) +
                (searchRequest.lastModifiedDateTo==NULL?' ':' AND LastModifiedDate <= ' + searchRequest.lastModifiedDateTo) +
                (searchRequest.limitation==NULL?' ':' LIMIT ' + searchRequest.limitation);
        
            List<MDM_Customer__c> queryResult = Database.query(String.escapeSingleQuotes(query));
            for(MDM_Customer__c customer: queryResult) {
               response.add(MDM_CustomerAPI_Handler.searchIndividualCustomer(customer, NULL, NULL));
            }
        }
    }

    /**
     * @description : get customer result based on source system IDs
     * @param queryResult1
     * @return List<MDM_Customer__c> 
     */
    static List<MDM_Customer__c> getQuery1Result(List<MDM_Source_Customer__c> queryResult1){
        Set<ID> sourceParentIDs; sourceParentIDs = getSourceParentIDs(queryResult1);            
        String query = 'SELECT Id,' + 
            '(SELECT MDM_Source_System__c, Name, MDM_Source_System_ID__c FROM Source_Customers__r LIMIT 200)' +
            ' FROM MDM_Customer__c WHERE ID IN :sourceParentIDs';
        return Database.query(String.escapeSingleQuotes(query));
    }

    /**
     * @description : retrieve search results based on externalSystemIDs
     * @param searchRequest
     * @param response
     * @param externalSystemIDsNotInResponse
     */
    public static void retrieveBasedOnExternalIds(MDM_CustomerAPIWrapper.MDM_SearchRequest searchRequest,
                    List<MDM_CustomerAPIWrapper.MDM_SearchResponse> response, List<String> externalSystemIDsNotInResponse)
    {    
        if(searchRequest.externalSystemIDs!=NULL) {
            String statusFilter = searchRequest.statusFilter;
        	String customerType = searchRequest.customerType;
            List<String> ids1; ids1 = getExternalIds(searchRequest);
            List<String> sourceSystems = getSourceSystems(searchRequest);
            externalSystemIDsNotInResponse = searchRequest.externalSystemIDs;
            
            String query = 'SELECT MDM_Source_System_Id__c, MDM_Customer__r.MDM_Is_Deleted__c, ' +
                ' MDM_Customer__r.MDM_ID__c, MDM_Customer__r.Name, MDM_Customer__r.MDM_Customer_Id__c ,MDM_Customer__r.MDM_Industry_Type__c, MDM_Customer__r.MDM_DOI_or_DOB__c ' +
                ', MDM_Customer__r.MDM_Account_Type__c, MDM_Customer__r.MDM_Customer_Status__c, MDM_Customer__r.MDM_Description__c' +
                ', MDM_Customer__r.CreatedDate, MDM_Customer__r.LastModifiedDate FROM MDM_Source_Customer__c' +
                ' WHERE MDM_Source_System_Id__c IN :ids1 '+
                (searchRequest.statusFilter==NULL?' ':' AND MDM_Customer__r.MDM_Customer_Status__c = :statusFilter') +
                (searchRequest.sourceSystems==NULL?' ':' AND MDM_Source_System__c IN :sourceSystems') + 
                (searchRequest.customerType==NULL?' ':' AND MDM_Account_Type__c = :customerType') +
                (searchRequest.lastModifiedDateFrom==NULL?' ':' AND MDM_Customer__r.LastModifiedDate >= ' +
                 searchRequest.lastModifiedDateFrom) +
                (searchRequest.lastModifiedDateTo==NULL?' ':' AND MDM_Customer__r.LastModifiedDate <= ' + 
                 searchRequest.lastModifiedDateTo) +
                (searchRequest.limitation==NULL?' ':' LIMIT ' + searchRequest.limitation);  
            List<MDM_Source_Customer__c> queryResult1 = Database.query(String.escapeSingleQuotes(query)); 
            addSourceCustResponse(queryResult1,externalSystemIDsNotInResponse,response);          
        }
    }

    /**
     * @description : addSourceCustResponse
     * @param queryResult1
     * @param externalSystemIDsNotInResponse
     * @param response
     */
    static void addSourceCustResponse(List<MDM_Source_Customer__c> queryResult1, List<String> externalSystemIDsNotInResponse, 
                 List<MDM_CustomerAPIWrapper.MDM_SearchResponse> response)
    {
        Map<ID, MDM_Customer__c> idCustomerMap =  getIdCustomerMap(getQuery1Result(queryResult1));         
        for(MDM_Source_Customer__c sourceCustomer: queryResult1) {
            Integer index = externalSystemIDsNotInResponse.indexOf(sourceCustomer.MDM_Source_System_Id__c);
            if(index>=0 && index<externalSystemIDsNotInResponse.size()) {
                externalSystemIDsNotInResponse.remove(index);    
            }
            response.add(MDM_CustomerAPI_Handler.searchIndividualCustomer(NULL, sourceCustomer, 
                            idCustomerMap.get(sourceCustomer.MDM_Customer__c)));
        }
    }

    /**
     * @description : return idCustomerMap
     * @param queryResult2
     * @return Map<ID, MDM_Customer__c>
     */
    static Map<ID, MDM_Customer__c> getIdCustomerMap(List<MDM_Customer__c> queryResult2){
        Map<ID, MDM_Customer__c> idCustomerMap = new Map<ID, MDM_Customer__c>();
        for(MDM_Customer__c customer: queryResult2) {
            idCustomerMap.put(customer.ID, customer);
        }
        return idCustomerMap;
    }

    /**
     * @description : get sourceParentIds
     * @param queryResult1
     * @return Set<ID>
     */
    static Set<ID> getSourceParentIDs(List<MDM_Source_Customer__c> queryResult1){                   
        Set<ID> sourceParentIDs = new Set<ID>();            
        for(MDM_Source_Customer__c sourceCustomer: queryResult1) {
            sourceParentIDs.add(sourceCustomer.MDM_Customer__c); 
        }
        return sourceParentIDs; 
    }
    
    /**
     * @description : return externalIds
     * @param searchRequest
     * @return List<String>
     */
    static List<String> getExternalIds(MDM_CustomerAPIWrapper.MDM_SearchRequest searchRequest){
        List<String> ids1 = new List<String>();
        if(searchRequest.externalSystemIDs != NULL) {
            for(String id: searchRequest.externalSystemIDs) {
                ids1.add(id);
            }
        }
        return ids1;
    }

    /**
     * @description : return sourceSystems
     * @param searchRequest
     * @return List<String>
     */
    static List<String> getSourceSystems(MDM_CustomerAPIWrapper.MDM_SearchRequest searchRequest){
        List<String> sourceSystems = new List<String>(); 
        if(searchRequest.sourceSystems != NULL) {
            for(String sourceSystem: searchRequest.sourceSystems) {
                sourceSystems.add(sourceSystem);
            }
        }
        return sourceSystems;
    }

    /**
     * @description : add external systemIDs error to response body
     * @param response
     * @param searchRequest
     * @param externalSystemIDsNotInResponse
     */
    public static void addExternalSysIdsErrorResponse(List<MDM_CustomerAPIWrapper.MDM_SearchResponse> response,
         MDM_CustomerAPIWrapper.MDM_SearchRequest searchRequest, List<String> externalSystemIDsNotInResponse)
    {
        if(searchRequest.externalSystemIDs != NULL && externalSystemIDsNotInResponse.size() > 0) {
            for(String externalSystemID: externalSystemIDsNotInResponse) {
                MDM_CustomerAPIWrapper.MDM_SearchResponse errorResponse = new MDM_CustomerAPIWrapper.MDM_SearchResponse();
                errorResponse.externalID = externalSystemID;
                errorResponse.error = 'No MDM record found for externalSystemID = ' + externalSystemID + '.';
                response.add(errorResponse);
            }
        }
    }

    /**
     * @description : add mdmIds error to response body
     * @param response
     * @param searchRequest
     * @param mdmIdsNotInResponse
     */
    public static void addMDMIdsErrorResponse(List<MDM_CustomerAPIWrapper.MDM_SearchResponse> response,
         MDM_CustomerAPIWrapper.MDM_SearchRequest searchRequest, List<String> mdmIdsNotInResponse)
    {
        if(searchRequest.mdmIds != NULL && mdmIdsNotInResponse.size() > 0) {
            for(String mdmId: mdmIdsNotInResponse) {
                MDM_CustomerAPIWrapper.MDM_SearchResponse errorResponse = new MDM_CustomerAPIWrapper.MDM_SearchResponse();
                errorResponse.mdmIds = mdmId;
                errorResponse.error = 'No MDM record found for mdmId = ' + mdmId + '.';
                response.add(errorResponse);
            }
        }
    }
}