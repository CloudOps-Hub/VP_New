/**
 * @description       : 
 * @author            : Priya Sharma
 * @group             : 
 * @last modified on  : 04-22-2021
 * @last modified by  : Sourabh
 * Modifications Log 
 * Ver   Date         Author         Modification
 * 1.0   04-16-2021   Priya Sharma   Initial Version
**/

//suppressed as it contains all get API methods 
@SuppressWarnings('PMD.CyclomaticComplexity,PMD.CognitiveComplexity')
public with sharing class MDM_CustomerGetAPIHandler {
    /**
      * @description : validate query parameter mdmIds if null or blank
      * @param customerRequest
      */
     public static void validateMDMIDs(MDM_CustomerAPIWrapper.MDM_GetCustomerRequest customerRequest){
         //System.debug(RestContext.request.params.get('mdmIds'));
         if(RestContext.request.params.get('mdmIds') != NULL && RestContext.request.params.get('mdmIds') != '' && 
            RestContext.request.params.get('mdmIds') != 'null') {
             customerRequest.mdmIds = RestContext.request.params.get('mdmIds').split(',');
             if(customerRequest.mdmIds.size() > 30) {
                 RestContext.response.responseBody = Blob.valueOf(
                     JSON.serialize(MDM_CustomerAPI_Handler.createErrorMessage(200, 
                         'Maximum of 30 mdmIds are allowed.', 'Error 400, BAD REQUEST')));
                 customerRequest.isValid = false;
             }
         }
         else {
             RestContext.response.responseBody = Blob.valueOf(
                 JSON.serialize(MDM_CustomerAPI_Handler.createErrorMessage(200,
                      'Query parameter mdmIds is mandatory.', 'Error 400, BAD REQUEST'))); 
             customerRequest.isValid = false;
         }
     }
 
     /**
      * @description : validate query parameter customerType if null or blank and is valid
      * @param customerRequest
      */
     public static void validateCustomerType(MDM_CustomerAPIWrapper.MDM_GetCustomerRequest customerRequest){
         List<String> types = MDM_CustomerAPI_Handler.getRecordTypes();
         customerRequest.accountType = RestContext.request.params.get('customerType');
         if(customerRequest.accountType == '' || customerRequest.accountType == 'null') {
             customerRequest.accountType = NULL;
         }
         if(customerRequest.accountType != NULL) {
             if(!types.contains(customerRequest.accountType.toLowerCase())) {
                 RestContext.response.responseBody = Blob.valueOf(
                     JSON.serialize(MDM_CustomerAPI_Handler.createErrorMessage(200, 
                         'Invalid query parameter: customerType', 
                         'Error 400, BAD REQUEST'))); 
                 customerRequest.isValid = false;
             }
         }
     }
     
     /**
      * @description :  validate query parameter field if null or blank and is valid
      * @param customerRequest
      */
     public static void validateQueryParameterField(MDM_CustomerAPIWrapper.MDM_GetCustomerRequest customerRequest){
         String fieldString = RestContext.request.params.get('field');
         Set<String> fieldList = MDM_CustomerAPIWrapper.fieldMapping.keySet();
         if(fieldString == '' || fieldString == 'null') {
             fieldString = NULL;
             customerRequest.field = NULL;
         }
         if(fieldString != NULL) {
             customerRequest.field = RestContext.request.params.get('field').split(',');
             for(String inputField: customerRequest.field) {
                 if(!fieldList.contains(inputField.toLowercase())) {
                     RestContext.response.responseBody = Blob.valueOf(
                         JSON.serialize(MDM_CustomerAPI_Handler.createErrorMessage(200, 
                             'Invalid query parameter: field', 'Error 400, BAD REQUEST'))); 
                     customerRequest.isValid = false;
                 }
             }
         }
     }
     
     /**
      * @description : validate query parameter part if null or blank and is valid 
      * @param customerRequest
      */
     public static void validateQueryParameterPart(MDM_CustomerAPIWrapper.MDM_GetCustomerRequest customerRequest){
         List<String> parts = new List<String>{'child','parent','externalids','contactaddresses'};
         customerRequest.part = RestContext.request.params.get('part');
         if(customerRequest.part == '' || customerRequest.part == 'null') {
             customerRequest.part = NULL;
         }
         if(customerRequest.part != NULL) {
             for(String inputField: customerRequest.part.split(',')) {
                 if(!parts.contains(inputField.toLowercase())) {
                     RestContext.response.responseBody = Blob.valueOf(
                         JSON.serialize(MDM_CustomerAPI_Handler.createErrorMessage(200, 
                                 'Invalid query parameter: part', 'Error 400, BAD REQUEST'))); 
                     customerRequest.isValid = false;
                 }
             }    
         }
     }
 
     /**
      * @description : this will return string of cust fields
      * @param customerRequest
      * @return string 
      */
     static string getCustomerFields(MDM_CustomerAPIWrapper.MDM_GetCustomerRequest customerRequest){
         String fields = '';
         if(customerRequest.field == NULL) {
           
             fields = 'MDM_ID__c, Name, MDM_Description__c, MDM_Customer_Status__c, CreatedDate, LastModifiedDate,  '+
                      'MDM_Account_Type__c, MDM_is_Deleted__c,MDM_Industry_Type__c, MDM_Customer_Id__c,MDM_DOI_or_DOB__c';
         } else {
              for(String field : customerRequest.field) {
                 field = field.deleteWhitespace();
                 fields = fields + MDM_CustomerAPIWrapper.fieldMapping.get(field.toLowerCase()) + ',';
             }
             fields = fields.substring(0, fields.length() - 1);
         }
         return fields;
     }
     /**
      * @description : get customer list
      * @param customerRequest
      * @param ids
      * @return List<MDM_Customer__c>
      */
     public static List<MDM_Customer__c> getCustomerList(MDM_CustomerAPIWrapper.MDM_GetCustomerRequest customerRequest, String[] ids){
         //retrieve records
    
         String statusFilter = customerRequest.statusFilter;
         String accountType = customerRequest.accountType;
         String query = 'SELECT '+ getCustomerFields(customerRequest) +
             
             (customerRequest.part==NULL || customerRequest.part.containsIgnoreCase('externalIDs')?
              (',(SELECT Name, MDM_Source_System__c, MDM_Source_System_Id__c, MDM_Account_Type__c, MDM_Is_Primary__c FROM Source_Customers__r LIMIT 200)')
              :' ')+
             (customerRequest.part==NULL || customerRequest.part.containsIgnoreCase('contactAddresses')?
              (',(SELECT MDM_Customer__c, MDM_Source_System_Address_Id__c, MDM_Contact__c, MDM_Address_1__c, MDM_Address_2__c,' +
              ' MDM_Address_3__c, MDM_Address_Type__c, MDM_City__c, MDM_Country__c, MDM_State__c, MDM_Country_Code__c, MDM_Zip_Code__c,' +
              ' MDM_Phone__c, MDM_Extension__c, MDM_Fax__c, MDM_Email__c, MDM_Description_Notes__c, MDM_Status__c,' +
              ' MDM_External_System_Name__c, MDM_Source_System_Primary__c, MDM_Primary__c, MDM_Source_System_Verified__c FROM Addresses__r '+
              'LIMIT 200)')
              :' ')+
             (customerRequest.part==NULL || customerRequest.part.containsIgnoreCase('contactAddresses')?
              (',(SELECT MDM_Customer__c, MDM_Source_System_Contact_Id__c, Name, MDM_Extension__c, MDM_Name_Suffix__c,' +
              ' MDM_Title__c, MDM_Status__c, MDM_Phone__c, MDM_Fax__c, MDM_Email__c, MDM_External_System_Name__c FROM Contacts__r LIMIT 200)') 
              :' ')+
             'FROM MDM_Customer__c WHERE MDM_ID__c IN :ids '+
             (customerRequest.statusFilter==NULL?' ':' AND MDM_Customer_Status__c = :statusFilter' ) +
             (customerRequest.accountType==NULL?' ':' AND MDM_Account_Type__c = :accountType');
         return Database.query(String.escapeSingleQuotes(query));
     }
         /**
      * @description : prepare contact map
      * @param custConAddressMapWrap
      * @param customer
      */
     static void prepareContactMap(MDM_CustomerAPIWrapper.CustConAddressMap custConAddressMapWrap, MDM_Customer__c customer){
         for(MDM_Contact__c contact: customer.Contacts__r) {
             if(custConAddressMapWrap.contactsMap.containsKey(contact.MDM_Customer__c)) {
                 List<MDM_Contact__c> contactsInMap = custConAddressMapWrap.contactsMap.get(contact.MDM_Customer__c);
                 contactsInMap.add(contact);
                 custConAddressMapWrap.contactsMap.put(contact.MDM_Customer__c, contactsInMap);
             } else {
                 custConAddressMapWrap.contactsMap.put(contact.MDM_Customer__c, new List<MDM_Contact__c>{contact});
             }
         }
     }
 
     /**
      * @description : prepare Address map
      * @param custConAddressMapWrap
      * @param customer
      */
     static void prepareAddressMap(MDM_CustomerAPIWrapper.CustConAddressMap custConAddressMapWrap, MDM_Customer__c customer){
         for(MDM_Address__c address: customer.Addresses__r) {
             if(custConAddressMapWrap.addressesMap.containsKey(address.MDM_Customer__c)) {
                 List<MDM_Address__c> addressesInMap = custConAddressMapWrap.addressesMap.get(address.MDM_Customer__c);
                 addressesInMap.add(address);
                 custConAddressMapWrap.addressesMap.put(address.MDM_Customer__c, addressesInMap);
             } else {
                 custConAddressMapWrap.addressesMap.put(address.MDM_Customer__c, new List<MDM_Address__c>{address});
             }
         }
     }
 
    
 
     /**
      * @description : will return customer Ids
      * @param queryResult
      * @return List<ID> 
      */
     static List<ID> getCustIDs(List<MDM_Customer__c> queryResult){
         List<ID> customerIDs = new List<ID>();
         for(MDM_Customer__c customer: queryResult) {
             customerIDs.add(customer.ID);
         } 
         return customerIDs;
     }
 
     /**
      * @description : create contactAddresses as per required format
      * @param custConAddressMapWrap
      * @param queryResult
      * @param customerRequest
      */
     public static void populateConAddChildMap(MDM_CustomerAPIWrapper.CustConAddressMap custConAddressMapWrap, 
         List<MDM_Customer__c> queryResult, MDM_CustomerAPIWrapper.MDM_GetCustomerRequest customerRequest){
         if(customerRequest.part==NULL || customerRequest.part.containsIgnoreCase('contactAddresses')) {
             for(MDM_Customer__c customer: queryResult) {
                 prepareContactMap(custConAddressMapWrap, customer);
                 prepareAddressMap(custConAddressMapWrap, customer);  
             }
         }
         
     }
 
     /**
      * @description : counting total number of records for given query
      * @param customerRequest
      * @param ids
      * @return Integer
      */
     public static Integer countNumberOfRecords(MDM_CustomerAPIWrapper.MDM_GetCustomerRequest customerRequest, String[] ids){
         String queryToCount = 'SELECT count() '+
             'FROM MDM_Customer__c WHERE MDM_ID__c IN :ids ' +
             (customerRequest.statusFilter==NULL?' ':' AND MDM_Customer_Status__c = \'' + customerRequest.statusFilter + '\'' ) +
             (customerRequest.accountType==NULL?' ':' AND MDM_Account_Type__c = \'' + customerRequest.accountType + '\'');
         
         return Database.countQuery(queryToCount);
     }
     
     /**
      * @description : validate query parameter statusfilter if null or blank and is valid
      * @param customerRequest
      */
     public static void validateQueryStatus(MDM_CustomerAPIWrapper.MDM_GetCustomerRequest customerRequest){
         List<String> statusFilters = new List<String>();
         for(Schema.PicklistEntry pe: MDM_Customer__c.MDM_Customer_status__c.getDescribe().getPicklistValues()) {
             statusFilters.add(pe.getValue().toLowercase());    
         } 
         customerRequest.statusFilter = RestContext.request.params.get('statusFilter');
         if(customerRequest.statusFilter == '' || customerRequest.statusFilter == 'null') {
             customerRequest.statusFilter = NULL;    
         }
         if(customerRequest.statusFilter != NULL) {
             if(!statusFilters.contains(customerRequest.statusFilter.toLowerCase())) {
                 RestContext.response.responseBody = Blob.valueOf(
                     JSON.serialize(MDM_CustomerAPI_Handler.createErrorMessage(200, 'Invalid query parameter: statusFilter', 
                                                                               'Error 400, BAD REQUEST'))); 
                 customerRequest.isValid = false;
             }
         }
     }
 }