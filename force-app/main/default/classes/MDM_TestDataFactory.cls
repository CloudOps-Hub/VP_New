/**
* @description       : 
* @author            : Dhruv Agrawal
* @group             : 
* @last modified on  : 05-28-2021
* @last modified by  : Dhruv Agrawal
* Modifications Log 
* Ver   Date         Author          Modification
* 1.0   04-12-2021   Dhruv Agrawal   Initial Version
**/

@isTest
public class MDM_TestDataFactory{
    /**
    * @description This wrapper class contains customer details
    */
    public class FactoryParamWrapper {
        public Integer customerCount;
        public Integer contactCount;
        public Integer addressCount;
        public Integer sourceCustomerCount;
        public Boolean isContactInsert;
        public Boolean isContactAddressInsert;
        public Boolean isAddressInsert;
        public Boolean isSrcCustomerInsert;
        
    /**
    * @description contains customer details
    * @param customerCount
    
    * @param contactCount
    * @param addressCount
    * @param sourceCustomerCount
    
    * @param isContactInsert
    * @param isAddressInsert
    * @param isContactAddressInsert
    * @param isSrcCustomerInsert
    */
        @SuppressWarnings('PMD.ExcessiveParameterList') //require all parameters to initialize object
        public FactoryParamWrapper(
            Integer customerCount,
            
            Integer contactCount,
            Integer addressCount,
            Integer sourceCustomerCount,
            
            Boolean isContactInsert,
            Boolean isAddressInsert,
            Boolean isContactAddressInsert,
            Boolean isSrcCustomerInsert
        ) {
            this.customerCount = customerCount;
            
            this.contactCount = contactCount;
            this.addressCount = addressCount;
            this.sourceCustomerCount=sourceCustomerCount;
            
            this.isContactAddressInsert = isContactAddressInsert;
            this.isContactInsert = isContactInsert;
            this.isAddressInsert = isAddressInsert;
            this.isSrcCustomerInsert = isSrcCustomerInsert;
        }
    }
    
    /**
    * @description 
    * @author Dhruv Agrawal | 05-28-2021 
    * @param wrapper 
    * @param customerId 
    **/
    static void createCustomerRelatedRecords(factoryParamWrapper wrapper, Id customerId) {
        if(wrapper.isContactInsert) {
            createContactRecords(customerId, wrapper);
        }
        if(wrapper.isAddressInsert) {
            createAddressRecords(Null, customerId, wrapper);
        }
        if(wrapper.isSrcCustomerInsert) {
            createSourceCustomer(customerId, wrapper);
        }
    }
    
    /**
    * @description This method will create customer records based of customerCount passed in factoryParamWrapper
    * @param wrapper
    */
    public static void createCustomers(factoryParamWrapper wrapper) {
        List<MDM_Customer__c> customerList = new List<MDM_Customer__c>();
        for(Integer i=0; i < wrapper.customerCount;i++){
            MDM_Customer__c customerRecord = new MDM_Customer__c(
                Name ='TestCustomer_' + i,
                MDM_Description__c = 'Description Test ' + i,
                MDM_Account_Type__c = 'Individual Account',
                MDM_Customer_Status__c = 'Active'
            );
            customerList.add(customerRecord);
        }
        if( customerList.size() > 0 ) {
            insert customerList;
            for(MDM_Customer__c customer : customerList ) { createCustomerRelatedRecords(wrapper, customer.Id); }
        }
    }
    /** 
    * @description This method will create MDM_Source_Customer__c
    * records based of sourceCustomerCount and parentId passed in factoryParamWrapper
    * @param parentId
    * @param wrapper
    */
    public static void createSourceCustomer(String parentId, factoryParamWrapper wrapper) {
        List<MDM_Source_Customer__c> sourcecustomerList = new List<MDM_Source_Customer__c>();
        for(Integer i=0; i < wrapper.sourceCustomerCount; i++){
            MDM_Source_Customer__c sourcecustomerRecord = new MDM_Source_Customer__c(
                Name = 'TestSourceCustomer' + i,
                MDM_Customer__c = parentId,
                MDM_Account_Type__c = 'Individual Account',
                MDM_is_Deleted__c = False,
                MDM_Source_System__c = 'System',
                MDM_Source_System_Id__c = '11111' 
            );
            sourcecustomerList.add(sourcecustomerRecord);
        }
        if( sourcecustomerList.size() > 0 ) {
            insert sourcecustomerList;
        }
    }
    
    /**
    * @description This method will create MDM_Contact__c records based of contactCount
    * and parentId passed in factoryParamWrapper
    * @param parentId
    * @param wrapper
    */
    public static void createContactRecords(String parentId, factoryParamWrapper wrapper){  
        List<MDM_Contact__c> contactList = new List<MDM_Contact__c>();  
        for(Integer i = 0; i < wrapper.contactCount; i++) {
            MDM_Contact__c contact = new MDM_Contact__c(
                Name = 'TestContact_' + i,
                MDM_Email__c = 'TestContact' + i + '@gmail.com',
                MDM_is_Deleted__c = False,
                MDM_Phone__c = '98765'+String.valueOf(i)+'1212',
                MDM_Status__c = 'Active',
                MDM_Customer__c = parentId
            );
            
            contactList.add(contact);
        }
        if( contactList.size() > 0 ) {
            insert contactList;
            for(MDM_Contact__c contact : contactList ) {
                if(wrapper.isContactAddressInsert){
                    createAddressRecords(contact.id, parentId, wrapper);
                }
            }
        }
    }
    
    /**
    * @description This method will create MDM_Address__c records based of addressCount, contactId and parentId
    * passed in factoryParamWrapper
    * @param contactId
    * @param parentId
    * @param wrapper
    */
    public static void createAddressRecords(String contactId, String parentId, factoryParamWrapper wrapper){
        List<MDM_Address__c> addressList = new List<MDM_Address__c>();  
        for(Integer i = 0; i < wrapper.addressCount; i++) {
            MDM_Address__c address = new MDM_Address__c(
                MDM_Address_1__c = 'TestAddress1 ' + i ,
                MDM_Address_2__c = 'TestAddress2 ' + i ,
                MDM_Address_3__c   = 'TestAddress3 ' + i ,
                MDM_City__c   = 'Pune',
                MDM_Customer__c = parentId,
                MDM_Contact__c = contactId,
                MDM_State__c = 'Maharshatra',
                MDM_Country__c = 'India',
                MDM_Country_Code__c = 'IND'
            );
            addressList.add(address);
        }
        if( addressList.size() > 0 ) {
            insert addressList;
        }
    }
   
    /**
    * @description 
    * @author Dhruv Agrawal | 05-28-2021 
    * @return MDM_Customer_Staging__c 
    **/
    public static MDM_Customer_Staging__c createCustomerStagingRecords() {        
        MDM_Customer_Staging__c  custStaging = new MDM_Customer_Staging__c(
            Name ='Test Staging',
            MDM_Account_Type__c ='Individual Account',
            MDM_Customer_Status__c ='Active',
            MDM_Email__c ='test@cree.com',
            MDM_DOI_or_DOB__c = System.today(),
            MDM_Phone__c= '846293223',
            MDM_Source_LastModified__c = System.today() );
        
        insert custStaging;
        return custStaging;
    }
    
    /**
    * @description 
    * @author Dhruv Agrawal | 05-28-2021 
    * @return MDM_Customer__c 
    **/
    public static MDM_Customer__c createCustomer(){
        MDM_Customer__c customerRecord =new MDM_Customer__c();
        customerRecord.Name='CREE';
        customerRecord.MDM_Account_Type__c='Business Account';
        customerRecord.MDM_Email__c ='test@cree.com';
        insert customerRecord;
        return customerRecord;
    }
    
    /**
    * @description 
    * @author Dhruv Agrawal | 05-28-2021 
    * @return MDM_Address_Staging__c 
    **/
    public static MDM_Address_Staging__c createAddressStaging() {
        MDM_Address_Staging__c  addressStaging = new MDM_Address_Staging__c();
        addressStaging.MDM_Address_1__c ='California';
        addressStaging.MDM_Customer_Staging__c =createCustomerStagingRecords().Id;
        addressStaging.MDM_Country__c = 'USA';
        addressStaging.MDM_Email__c = 'test@cree.com';
        addressStaging.MDM_City__c ='Nagpur';
        insert addressStaging;
        return addressStaging;
    }
    
    /**
    * @description 
    * @author Dhruv Agrawal | 05-28-2021 
    * @return MDM_Contact_Staging__c 
    **/
    public static MDM_Contact_Staging__c createContactStaging() {
        MDM_Contact_Staging__c  contactStaging = new MDM_Contact_Staging__c();
        contactStaging.Name ='CREE';
        contactStaging.MDM_Customer_Staging__c =createCustomerStagingRecords().Id;
        contactStaging.MDM_Email__c = 'test@cree.com';
        contactStaging.MDM_Phone__c = '9763256807';
        insert contactStaging;
        return contactStaging;
    }
   
    /**
    * @description 
    * @author Dhruv Agrawal | 05-28-2021 
    * @param landingCount 
    **/
    public static void createCustomerLandingRecords(Integer landingCount) {        
        List<MDM_Customer_Landing__c> custLandingList = new List<MDM_Customer_Landing__c>();
        for(Integer i=0;i<landingCount;i++){
            MDM_Customer_Landing__c custLanding = new MDM_Customer_Landing__c(
                MDM_Source_System__c = 'Bridge',
                MDM_Account_Type__c = 'Individual Account',
                MDM_Processing_Status__c = 'New',
                MDM_Description__c = 'Test 567'
            );
            custLandingList.add(custLanding);
        }
        insert custLandingList;
    }
    
    /**
    * @description 
    * @author Dhruv Agrawal | 05-28-2021 
    **/
    @isTest
    public static void dqiAttributeTestData(){
        MDM_Data_Quality__c dataQuality = new MDM_Data_Quality__c(
            Name = 'Customer DOI or DOB',
            //MDM_Field_Label__c = 'DOI_DOB',
            MDM_Field_API_Name__c = 'MDM_DOI_or_DOB__c',
            MDM_Object__c = 'MDM_Customer__c'
        );
        insert dataQuality;   
        MDM_Data_Quality__c dataQuality1 = new MDM_Data_Quality__c(
            Name = 'Contact Email Data Quality',
            //MDM_Field_Label__c = 'Email',
            MDM_Field_API_Name__c = 'MDM_Email__c',
            MDM_Object__c = 'MDM_Contact__c'
        );
        insert dataQuality1;   
        
       
        
        MDM_Data_Quality__c dataQuality2 = new MDM_Data_Quality__c(
            Name = 'Address City Data Quality',
            // MDM_Field_Label__c = 'City',
            MDM_Field_API_Name__c = 'MDM_City__c',
            MDM_Object__c = 'MDM_Address__c'
        );
        insert dataQuality2;
        
        MDM_Data_Quality__c dataQuality4 = new MDM_Data_Quality__c(
            Name = 'Address Address1 Data Quality',
            MDM_Field_API_Name__c = 'MDM_Country__c',
            MDM_Object__c = 'MDM_Address__c'
        );
        insert dataQuality4;
        
        MDM_Data_Quality__c dataQuality3 = new MDM_Data_Quality__c(
            Name = 'Customer Email Data Quality',
            MDM_Field_API_Name__c = 'MDM_Email__c',
            MDM_Object__c = 'MDM_Customer__c'
        );
        insert dataQuality3;
        
        MDM_DQI_Attribute__c dqi1 = new MDM_DQI_Attribute__c(
            Name = 'DQI Customer DOI or DOB',
            MDM_Percentage__c = 10,
            MDM_Data_Quality__c = dataQuality.Id,
            MDM_Is_Active__c = true
        );
        insert dqi1;
        
        MDM_DQI_Attribute__c dqi2 = new MDM_DQI_Attribute__c(
            Name = 'DQI Contact Email',
            MDM_Data_Quality__c = dataQuality1.Id ,
            MDM_Is_Active__c = true,
            MDM_Percentage__c = 10
        );
        insert dqi2;
        MDM_DQI_Attribute__c dqi3 = new MDM_DQI_Attribute__c(
            Name = 'DQI Address City',
            MDM_Data_Quality__c = dataQuality2.Id ,
            MDM_Is_Active__c = true,
            MDM_Percentage__c = 30
        );
        insert dqi3;
        MDM_DQI_Attribute__c dqi4 = new MDM_DQI_Attribute__c(
            Name = 'Customer Email',
            MDM_Percentage__c = 11,
            MDM_Data_Quality__c = dataQuality3.id,
            MDM_Is_Active__c = true
        );
        insert dqi4;
        MDM_DQI_Attribute__c dqi5 = new MDM_DQI_Attribute__c(
            Name = 'DQI Address Country',
            MDM_Percentage__c = 10,
            MDM_Data_Quality__c = dataQuality4.Id,
            MDM_Is_Active__c = true
        );
        insert dqi5;
        
        MDM_Data_Transformation__c dataTransformation = new MDM_Data_Transformation__c(
            Name = 'Customer Name Transformation'
        );
        insert dataTransformation;
         MDM_Attribute_Transformation_Item__c attributeItem = new MDM_Attribute_Transformation_Item__c(
            MDM_Data_Transformation__c = dataTransformation.ID,
            MDM_New_Value__c = 'CORP',
            MDM_Old_Value__c = 'corp.',
            MDM_Type__c = 'Word',
             MDM_Case_Sensitive__c = false
        );
        insert attributeItem;
        system.assert(attributeItem.Id != null, 'attributeItem.id is not NULL');
        MDM_Attribute_Transformation_Item__c attributeItem1 = new MDM_Attribute_Transformation_Item__c(
            MDM_Data_Transformation__c = dataTransformation.ID,
            MDM_New_Value__c = 'CORP',
            MDM_Old_Value__c = 'corp.',
            MDM_Type__c = 'Anywhere',
            MDM_Case_Sensitive__c = false
        );
        insert attributeItem1;
        
        MDM_Attribute_Transformation_Item__c attributeItem2 = new MDM_Attribute_Transformation_Item__c(
            MDM_Data_Transformation__c = dataTransformation.ID,
            MDM_New_Value__c = 'CORP',
            MDM_Old_Value__c = 'corp.',
            MDM_Type__c = 'Word',
            MDM_Case_Sensitive__c = true
        );
        insert attributeItem2;
        
        MDM_Attribute_Transformation_Item__c attributeItem3 = new MDM_Attribute_Transformation_Item__c(
            MDM_Data_Transformation__c = dataTransformation.ID,
            MDM_New_Value__c = 'CORP',
            MDM_Old_Value__c = 'corp.',
            MDM_Type__c = 'Anywhere',
            MDM_Case_Sensitive__c = true
        );
        insert attributeItem3;
        
        
         MDM_Data_Transformation_Rule__c dataTransformationRule = new MDM_Data_Transformation_Rule__c(
            Name = 'Customer Name Transformation',
            MDM_Is_Title_Case__c = true,
            MDM_Data_Quality__c = dataQuality.ID,
            MDM_Data_Transformation__c = dataTransformation.ID
        );
        insert dataTransformationRule;
        
        
        try{
            insert Dqi4;
        }
        catch(Exception E){
            system.debug(LoggingLevel.ERROR, 'Exception: ' + e.getMessage());
        }
    }
    /**
    * @description 
    * @author Dhruv Agrawal | 05-28-2021 
    **/
    public static void createAddress() {
        MDM_Address__c address = new MDM_Address__c();
        address.MDM_Address_1__c = 'California';
        address.MDM_Country__c = 'USA';
        address.MDM_Email__c = 'test@cree.com';
        address.MDM_City__c ='Nagpur';
        insert address;
    }
    /**
    * @description 
    * @author Dhruv Agrawal | 05-28-2021 
    **/
    public static void customerComponentHelperTestData() {
        String contactJSON1 = '[{"contatName":"odi","suffix":"Jr.","title":"Customer Success Manager","status":"status",'+
            '"phone":"1234567890 - x578","fax":"1234567890","email":"abc@def.com","addresses":[{"address1":"address1",'+
            '"address2":"address2","address3":"address3","addressType":"Contact","city":"city","country":"country",'+
            '"state":"state","countryCode":"countryCode","zipcode":"zipcode","phone":"1234567890 - x578","extension":"extension",'+
            '"fax":"1234567890","email":"abc@def.com","description":"description"}]},{"contactName":"John","suffix":"Jr.",'+
            '"title":"Customer Success Manager","status":"status","phone":"1234567890 - x578","fax":"1234567890",'+
            '"email":"abc@def.com"},{"addresses":[{"address1":"address1","address2":"address2","address3":"address3",'+
            '"addressType":"Billing","city":"city","country":"country","state":"state","countryCode":"countryCode","zipcode":"zipcode",'+
            '"phone":"1234567890 - x578","extension":"extension","fax":"1234567890","email":"abc@def.com","description":"description"}]}]';
        MDM_Customer_Landing__c custLanding = new MDM_Customer_Landing__c( 
            MDM_Source_System__c = 'System',
            MDM_Customer_Name__c = 'Nestle',
            MDM_Account_Type__c = 'Individual Account',
            MDM_Processing_Status__c = 'New', 
            MDM_Description__c = 'Test 567',
            MDM_Source_System_ID__c='123',
            MDM_Contact_JSON__c = contactJSON1
        );
        insert custLanding;
        MDM_Customer_Landing__c custLanding1 = new MDM_Customer_Landing__c( 
            MDM_Source_System__c = 'System',
            MDM_Customer_Name__c = 'Test1',
            MDM_Account_Type__c = 'Individual Account',
            MDM_Processing_Status__c = 'New', 
            MDM_Description__c = 'Test 567',
            MDM_Source_System_ID__c='123',
            MDM_Contact_JSON__c = contactJSON1
        );
        insert custLanding1;

 

        MDM_Customer_Landing__c custLanding2 = new MDM_Customer_Landing__c( 
            MDM_Customer_Name__c = 'Test2',
            MDM_Source_System__c = 'Bridge',
            MDM_Source_System_ID__c='123',
            MDM_Processing_Status__c = 'New', 
            MDM_Description__c = 'Test 567',
            MDM_Contact_JSON__c = contactJSON1
        );
        insert custLanding2;
        
        MDM_Customer_Landing__c custLanding3 = new MDM_Customer_Landing__c( 
            MDM_Customer_Name__c = 'Test3',
            MDM_Source_System__c = 'Bridge',
            MDM_Source_System_ID__c='123',
            MDM_Processing_Status__c = 'New', 
            MDM_Description__c = 'Test 567',
            MDM_Contact_JSON__c = contactJSON1
        );
        insert custLanding3;
        
          MDM_Customer_Landing__c custLanding4 = new MDM_Customer_Landing__c( 
            MDM_Source_System__c = 'System',
            MDM_Customer_Name__c = 'Test4',
            MDM_Account_Type__c = 'Individual Account',
            MDM_Processing_Status__c = 'New', 
            MDM_Description__c = 'Test 567',
            MDM_Source_System_ID__c='123'
        );
        insert custLanding4;
}
    
    /**
    * @description 
    * @author Dhruv Agrawal | 05-28-2021 
    **/
    public static void dataTransformation(){
        MDM_Data_Transformation__c dataTransformation = new MDM_Data_Transformation__c();
        dataTransformation.Name='Customer Name Transformation';
        insert dataTransformation;
    }
    
    /**
    * @description 
    * @author Dhruv Agrawal | 05-28-2021 
    **/
    public static void dataTransformationRule(){
        MDM_Data_Transformation_Rule__c dataTransformationRule = new MDM_Data_Transformation_Rule__c();
        MDM_Data_Quality__c dataQuality = new MDM_Data_Quality__c();
        MDM_Data_Transformation__c dataTransformation = new MDM_Data_Transformation__c();
        dataTransformationRule.MDM_Is_Title_Case__c = true;
        dataTransformationRule.MDM_Data_Quality__c = dataQuality.ID;
        dataTransformationRule.MDM_Data_Transformation__c = dataTransformation.ID;
        insert dataTransformationRule;
    }
    
    /**
    * @description 
    * @author Dhruv Agrawal | 05-28-2021 
    **/
    public static void createContact() {
        MDM_Contact__c contact = new MDM_Contact__c();
        contact.Name = 'CREE';
        contact.MDM_Email__c = 'test@cree.com';
        contact.MDM_Phone__c = '9763256807';
        insert contact;
    }
    
    
    /**
    * @description 
    * @author Dhruv Agrawal | 05-28-2021 
    * @return MDM_Data_Quality__c 
    **/
    public static MDM_Data_Quality__c createDataQuality(){
        MDM_Data_Quality__c dataQuality = new MDM_Data_Quality__c(
            Name = 'Name Data Quality',
            //MDM_Field_Label__c = 'DOI_DOB',
            MDM_Field_API_Name__c = 'Name',
            MDM_Object__c = 'MDM_Customer__c'
        );
        insert dataQuality;   
        return dataQuality;
    }
    
    
    
    
    /**
    * @description 
    * @author Dhruv Agrawal | 05-28-2021 
    **/
    public static void createTestApplicationConfig(){
        MDM_Application_Configuration__c appConfig = new MDM_Application_Configuration__c();
        appconfig.MDM_Allow_Auto_Merge__c = true;
        appconfig.MDM_Allow_Platform_Events__c = true;
        appconfig.MDM_Platfrom_Event_Batch_Size__c = '1';
        appconfig.Name = 'Test Config';
        insert appConfig;
    }
    
    /**
    * @description 
    * @author Dhruv Agrawal | 05-28-2021 
    **/
    public static void autoSearchHelperCreateTestData() {
        MDM_Data_Quality__c dataQuality1 = new MDM_Data_Quality__c(
            Name = 'Name Data Quality',
            MDM_Field_API_Name__c = 'Name',
            MDM_Object__c = 'MDM_Customer__c'
        );
        insert dataQuality1;
        
        MDM_Data_Quality__c dataQuality5 = new MDM_Data_Quality__c(
            Name = 'Email Data Quality',
            MDM_Field_API_Name__c = 'MDM_Email__c',
            MDM_Object__c = 'MDM_Customer__c'
        );
        insert dataQuality5;
        MDM_Data_Quality__c dataQuality6 = new MDM_Data_Quality__c(
            Name = 'Phone Data Quality',
            MDM_Field_API_Name__c = 'MDM_Phone__c',
            MDM_Object__c = 'MDM_Customer__c'
        );
        insert dataQuality6;
        MDM_Data_Quality__c dataQuality7 = new MDM_Data_Quality__c(
            Name = 'Source LastModified Data Quality',
            MDM_Field_API_Name__c = 'MDM_Source_LastModified__c',
            MDM_Object__c = 'MDM_Customer__c'
        );
        insert dataQuality7;
        
        MDM_Data_Quality__c dataQuality2 = new MDM_Data_Quality__c(
            Name = 'Email Data Quality',
            MDM_Field_API_Name__c = 'MDM_Email__c',
            MDM_Object__c = 'MDM_Contact__c'
        );
        insert dataQuality2;
        
        MDM_Data_Quality__c dataQuality3 = new MDM_Data_Quality__c(
            Name = 'City Data Quality',
            MDM_Field_API_Name__c = 'MDM_City__c',
            MDM_Object__c = 'MDM_Address__c'
        );
        insert dataQuality3;
        
        MDM_Data_Quality__c dataQuality4 = new MDM_Data_Quality__c(
            Name = 'Country Data Quality',
            MDM_Field_API_Name__c = 'MDM_Country__c',
            MDM_Object__c = 'MDM_Address__c'
        );
        insert dataQuality4;
        
    }
    
    /**
    * @description 
    * @author Dhruv Agrawal | 05-28-2021 
    **/
    public Static void autoMergeJobTestData(){
        MDM_Customer_Staging__c  custStaging = MDM_TestDataFactory.createCustomerStagingRecords();
        custstaging.MDM_Processing_Status__c = 'New'; 
        custstaging.MDM_is_AutoMerge__c = true;
        update custstaging;
        MDM_Address_Staging__c  addressStaging = new MDM_Address_Staging__c();
        addressStaging.MDM_Address_1__c ='California';
        addressStaging.MDM_Customer_Staging__c =custStaging.Id;
        insert addressStaging;
        
        MDM_Contact_Staging__c  contactStaging = new MDM_Contact_Staging__c();
        contactStaging.Name ='CREE';
        contactStaging.MDM_Email__c = 'test@cree.com';
        contactStaging.MDM_Customer_Staging__c =custStaging.Id;
        insert contactStaging;
        
        MDM_Customer__c customerRecord =new MDM_Customer__c();
        customerRecord.Name='Test Staging';
        customerRecord.MDM_Account_Type__c='Individual Account';
        customerRecord.MDM_Email__c ='test@cree.com';
        customerRecord.MDM_DOI_or_DOB__c = System.today();
        insert customerRecord;
        
        MDM_Address__c address = new MDM_Address__c();
        address.MDM_Address_1__c = 'California';
        address.MDM_Country__c = 'USA';
        address.MDM_Email__c = 'test@cree.com';
        address.MDM_City__c ='Nagpur';
        address.MDM_Customer__c = customerRecord.Id;
        insert address;
        
        MDM_Contact__c contact = new MDM_Contact__c();
        contact.Name = 'CREE';
        contact.MDM_Email__c = 'test@cree.com';
        contact.MDM_Phone__c = '9763256807';
        contact.MDM_Customer__c = customerRecord.Id;
        insert contact;
        
        
        MDM_Data_Quality__c dataQuality2 = new MDM_Data_Quality__c(
            Name = 'Address City Data Quality',
            MDM_Field_API_Name__c = 'MDM_City__c',
            MDM_Object__c = 'MDM_Address__c'
        );
        insert dataQuality2;   
        
        MDM_Data_Quality__c dataQuality1 = new MDM_Data_Quality__c(
            Name = 'Contact Email Data Quality',
            MDM_Field_API_Name__c = 'MDM_Email__c',
            MDM_Object__c = 'MDM_Contact__c'
        );
        insert dataQuality1;   
        
    }
    
    /**
    * @description 
    * @author Dhruv Agrawal | 05-28-2021 
    **/
    public static void apiHandlerTestData(){
        
        Map<String, ID> recordNameIDMap = new Map<String, ID>();
        List<RecordType> recordTypes = [SELECT ID, Name FROM RecordType WHERE SObjectType='MDM_Customer__c'];
        for(RecordType recordType: recordTypes) {
            recordNameIDMap.put(recordType.Name, recordType.ID);
        }
        
        MDM_Customer__c self = new MDM_Customer__c();
        self.Name = 'Coca-Cola';
        self.MDM_Description__c = 'Coke company';
        self.MDM_Customer_Status__c = 'Active';
        self.MDM_Account_Type__c = 'Individual Account';
        
        insert self;
        
        MDM_Customer__c self1 = new MDM_Customer__c();
        self1.Name = 'Coca-Cola1';
        self1.MDM_Description__c = 'Coke company';
        self1.MDM_Customer_Status__c = 'Active';
        self1.MDM_Account_Type__c = 'Individual Account';
        
        insert self1;
        
        MDM_Customer__c self2 = new MDM_Customer__c();
        self2.Name = 'Coca-Cola2';
        self2.MDM_Description__c = 'Coke company';
        self2.MDM_Customer_Status__c = 'Active';
        self2.MDM_Account_Type__c = 'Individual Account';
        
        insert self2;
        
        
        MDM_Source_Customer__c sourceCustomer = new MDM_Source_Customer__c();
        sourceCustomer.Name = 'Coca-Cola';
        sourceCustomer.MDM_Source_System__c = 'System';
        sourceCustomer.MDM_Source_System_ID__c = '5702';
        sourceCustomer.MDM_Account_Type__c = 'Individual Account';
        sourceCustomer.MDM_Customer__c = self.ID;
        
        MDM_Source_Customer__c sourceCustomer1 = new MDM_Source_Customer__c();
        sourceCustomer1.Name = 'Coca-Cola1';
        sourceCustomer1.MDM_Source_System__c = 'System';
        sourceCustomer1.MDM_Source_System_ID__c = '5709';
        sourceCustomer1.MDM_Account_Type__c = 'Individual Account';
        sourceCustomer1.MDM_Customer__c = self1.ID;
        
        insert new List<MDM_Source_Customer__c> {sourceCustomer, sourceCustomer1};
            
            MDM_Contact__c contact1 = new MDM_Contact__c();
        contact1.Name = 'John';
        contact1.MDM_Fax__c = '0123456789';
        contact1.MDM_Phone__c = '0123456789';
        contact1.MDM_Customer__c = self.ID;
        contact1.MDM_Status__c = 'Active';
        contact1.MDM_Email__c = 'abc@def.com';
        contact1.MDM_Name_Suffix__c = 'Jr.';
        contact1.MDM_Title__c = 'Customer Success Manager';
        contact1.MDM_Source_System_Contact_Id__c = 45901;
        
        MDM_Contact__c contact2 = new MDM_Contact__c();
        contact2.Name = 'John';
        contact2.MDM_Fax__c = '0123456789';
        contact2.MDM_Phone__c = '0123456789';
        contact2.MDM_Customer__c = self.ID;
        contact2.MDM_Status__c = 'Active';
        contact2.MDM_Email__c = 'abc@def.com';
        contact2.MDM_Name_Suffix__c = 'Jr.';
        contact2.MDM_Title__c = 'Customer Success Manager';
        contact2.MDM_Source_System_Contact_Id__c = 4590;
        
        MDM_Contact__c contact3 = new MDM_Contact__c();
        contact3.Name = 'John';
        contact3.MDM_Fax__c = '0123456789';
        contact3.MDM_Phone__c = '0123456789';
        contact3.MDM_Customer__c = self1.ID;
        contact3.MDM_Status__c = 'Active';
        contact3.MDM_Email__c = 'abc@def.com';
        contact3.MDM_Name_Suffix__c = 'Jr.';
        contact3.MDM_Title__c = 'Customer Success Manager';
        contact3.MDM_Source_System_Contact_Id__c = 45902;
        
        MDM_Contact__c contact4 = new MDM_Contact__c();
        contact4.Name = 'John';
        contact4.MDM_Fax__c = '0123456789';
        contact4.MDM_Phone__c = '0123456789';
        contact4.MDM_Customer__c = self2.ID;
        contact4.MDM_Status__c = 'Active';
        contact4.MDM_Email__c = 'abc@def.com';
        contact4.MDM_Name_Suffix__c = 'Jr.';
        contact4.MDM_Title__c = 'Customer Success Manager';
        contact4.MDM_Source_System_Contact_Id__c = 4590;
        
        MDM_Contact__c contact5 = new MDM_Contact__c();
        contact5.Name = 'John';
        contact5.MDM_Fax__c = '0123456789';
        contact5.MDM_Phone__c = '0123456789';
        contact5.MDM_Customer__c =self.ID;
        contact5.MDM_Status__c = 'Active';
        contact5.MDM_Email__c = 'abc@def.com';
        contact5.MDM_Name_Suffix__c = 'Jr.';
        contact5.MDM_Title__c = 'Customer Success Manager';
        contact5.MDM_Source_System_Contact_Id__c = 4594;
        
        insert new List<MDM_Contact__c> {contact1, contact2, contact3, contact4, contact5};
            MDM_Address__c address1 = new MDM_Address__c();
        address1.MDM_Contact__c = contact1.ID;
        address1.MDM_Customer__c = self.ID;
        address1.MDM_Address_1__c = 'address1';
        address1.MDM_Address_2__c = 'address2';
        address1.MDM_Address_3__c = 'address3';
        address1.MDM_Address_Type__c = 'Permanent';
        address1.MDM_Fax__c = '0123456789';
        address1.MDM_Phone__c = '0123456789';
        address1.MDM_City__c = 'city';
        address1.MDM_State__c = 'state';
        address1.MDM_Country__c = 'country';
        address1.MDM_Country_Code__c = 'countryCode';
        address1.MDM_Extension__c = '0235';
        address1.MDM_Description_Notes__c = 'extension';
        address1.MDM_Zip_Code__c = 'zipcode';
        address1.MDM_Status__c = 'Active';
        address1.MDM_Source_System_Primary__c = true;
        address1.MDM_Source_System_Address_Id__c = 67890;
        
        MDM_Address__c address2 = new MDM_Address__c();
        address2.MDM_Customer__c = self.ID;
        address2.MDM_Address_1__c = 'address1';
        address2.MDM_Address_2__c = 'address2';
        address2.MDM_Address_3__c = 'address3';
        address2.MDM_Address_Type__c = 'Permanent';
        address2.MDM_Fax__c = '0123456789';
        address2.MDM_Phone__c = '0123456789';
        address2.MDM_City__c = 'city';
        address2.MDM_State__c = 'state';
        address2.MDM_Country__c = 'country';
        address2.MDM_Country_Code__c = 'countryCode';
        address2.MDM_Extension__c = '0235';
        address2.MDM_Description_Notes__c = 'extension';
        address2.MDM_Zip_Code__c = 'zipcode';
        address2.MDM_Status__c = 'Active';
        address2.MDM_Source_System_Primary__c = true;
        address2.MDM_Source_System_Address_Id__c = 67891;
        
        MDM_Address__c address3 = new MDM_Address__c();
        address3.MDM_Customer__c = self.ID;
        address3.MDM_Contact__c = contact1.ID;
        address3.MDM_Address_1__c = 'address1';
        address3.MDM_Address_2__c = 'address2';
        address3.MDM_Address_3__c = 'address3';
        address3.MDM_Address_Type__c = 'Permanent';
        address3.MDM_Fax__c = '0123456789';
        address3.MDM_Phone__c = '0123456789';
        address3.MDM_City__c = 'city';
        address3.MDM_State__c = 'state';
        address3.MDM_Country__c = 'country';
        address3.MDM_Country_Code__c = 'countryCode';
        address3.MDM_Extension__c = '0235';
        address3.MDM_Description_Notes__c = 'extension';
        address3.MDM_Zip_Code__c = 'zipcode';
        address3.MDM_Status__c = 'Active';
        address3.MDM_Source_System_Primary__c = true;
        address3.MDM_Source_System_Address_Id__c = 67892;
        MDM_Address__c address4 = new MDM_Address__c();
        address4.MDM_Customer__c = self2.ID;
        address4.MDM_Contact__c = contact5.ID;
        address4.MDM_Address_1__c = 'address1';
        address4.MDM_Address_2__c = 'address2';
        address4.MDM_Address_3__c = 'address3';
        address4.MDM_Address_Type__c = 'Permanent';
        address4.MDM_Fax__c = '0123456789';
        address4.MDM_Phone__c = '0123456789';
        address4.MDM_City__c = 'city';
        address4.MDM_State__c = 'state';
        address4.MDM_Country__c = 'country';
        address4.MDM_Country_Code__c = 'countryCode';
        address4.MDM_Extension__c = '0235';
        address4.MDM_Description_Notes__c = 'extension';
        address4.MDM_Zip_Code__c = 'zipcode';
        address4.MDM_Status__c = 'Active';
        address4.MDM_Source_System_Primary__c = true;
        address4.MDM_Source_System_Address_Id__c = 67892;
        insert new List<MDM_Address__c> {address1, address2, address3, address4};
            
            }
    
    /**
    * @description 
    * @author Dhruv Agrawal | 05-28-2021 
    **/
    public static void tokenMatcherServiceTestData(){
        // Customer Setup
        // Admin Configurations
        List<MDM_Duplicate_Rule__c> duplicateRules = new List<MDM_Duplicate_Rule__c> ();
        List<MDM_Duplicate_Match_Rule__c> duplicateMatchRules = new List<MDM_Duplicate_Match_Rule__c> ();
        List<MDM_Matching_Rule__c> matchRules = new List<MDM_Matching_Rule__c> ();
        List<MDM_Field_Match_Configuration__c> fieldConfigs = new List<MDM_Field_Match_Configuration__c> ();
        
        // Insert Duplicate Rule.
        duplicateRules.add (new MDM_Duplicate_Rule__c (
            MDM_Rule_Name__c = 'Customer Duplicate Rule',
            MDM_Rule_Description__c = 'Test Decription',
            MDM_Object_Name__c = 'MDM_Customer__c'
        ));
        Insert duplicateRules;
        
        // Insert Matching Rules
        // Match Rule For Customer
        matchRules.add (new MDM_Matching_Rule__c (
            MDM_Rule_Name__c = 'Customer Rule',
            MDM_Rule_Description__c = 'Test Customer Rule Description',
            MDM_Object_Name__c = 'MDM_Customer__c'
        ));
        
        // Match Rule For Contact
        matchRules.add (new MDM_Matching_Rule__c (
            MDM_Rule_Name__c = 'Contact Rule',
            MDM_Rule_Description__c = 'Test Contact Rule Description',
            MDM_Object_Name__c = 'MDM_Contact__c'
        ));
        // Match Rule For Address
        matchRules.add (new MDM_Matching_Rule__c (
            MDM_Rule_Name__c = 'Address Rule',
            MDM_Rule_Description__c = 'Test Address Rule Description',
            MDM_Object_Name__c = 'MDM_Address__c'
        ));
        
        // Match Rule For Reference System
        matchRules.add (new MDM_Matching_Rule__c (
            MDM_Rule_Name__c = 'Reference System Id Rule',
            MDM_Rule_Description__c = 'Test Reference System Id Rule Description',
            MDM_Object_Name__c = 'MDM_Source_Customer__c'
        ));		
        Insert matchRules;
        
        // Insert Duplicate Match Rule Juction Object.
        for (MDM_Matching_Rule__c matchRule : matchRules) {
            duplicateMatchRules.add (new MDM_Duplicate_Match_Rule__c (
                MDM_Matching_Rule__c = matchRule.id,
                MDM_Duplicate_Rule__c = duplicateRules[0].id
            ));
        }
        Insert duplicateMatchRules;
        
        // Customer Field Configs
        fieldConfigs.add (new MDM_Field_Match_Configuration__c (
            MDM_Matching_Rule__c = matchRules[0].Id,
            MDM_Match_Field__c = 'Name',
            
            MDM_Match_Method__c = 'Fuzzy-0.5'
        ));
        fieldConfigs.add (new MDM_Field_Match_Configuration__c (
            MDM_Matching_Rule__c = matchRules[0].Id,
            MDM_Match_Field__c = 'MDM_Account_Type__c',
            
            MDM_Match_Method__c = 'Exact-100.0'
        ));
        
        // Contact Field Configs
        fieldConfigs.add (new MDM_Field_Match_Configuration__c (
            MDM_Matching_Rule__c = matchRules[1].Id,
            MDM_Match_Field__c = 'Name',
            
            MDM_Match_Method__c = 'Fuzzy-0.5'
        ));
        // Address Field Configs
        fieldConfigs.add (new MDM_Field_Match_Configuration__c (
            MDM_Matching_Rule__c = matchRules[2].Id,
            MDM_Match_Field__c = 'MDM_City__c',
            
            MDM_Match_Method__c = 'Fuzzy-0.5'
        ));
        fieldConfigs.add (new MDM_Field_Match_Configuration__c (
            MDM_Matching_Rule__c = matchRules[2].Id,
            MDM_Match_Field__c = 'MDM_State__c',
            
            MDM_Match_Method__c = 'Fuzzy-0.5'
        ));
        fieldConfigs.add (new MDM_Field_Match_Configuration__c (
            MDM_Matching_Rule__c = matchRules[2].Id,
            MDM_Match_Field__c = 'MDM_Country__c',
            
            MDM_Match_Method__c = 'Fuzzy-0.5'
        ));
        fieldConfigs.add (new MDM_Field_Match_Configuration__c (
            MDM_Matching_Rule__c = matchRules[2].Id,
            MDM_Match_Field__c = 'MDM_Country_Code__c',
            
            MDM_Match_Method__c = 'Fuzzy-0.5'
        ));
        
        //reference source system id field configuration
        fieldConfigs.add (new MDM_Field_Match_Configuration__c (
            MDM_Matching_Rule__c = matchRules[3].Id,
            MDM_Match_Field__c = 'MDM_Source_System__c',
            
            MDM_Match_Method__c = 'Exact-100.0'
        ));
        fieldConfigs.add (new MDM_Field_Match_Configuration__c (
            MDM_Matching_Rule__c = matchRules[3].Id,
            MDM_Match_Field__c = 'MDM_Source_System_Id__c',
            
            MDM_Match_Method__c = 'Exact-100.0'
        ));
        
        Insert fieldConfigs;
        
        // MDM Customer Data
        List<MDM_Customer__c> customers = new List<MDM_Customer__c> ();
        customers.add (new MDM_Customer__c (
            Name = 'Test 1 @ 2 Customer',
            MDM_Account_Type__c = 'Individual Account'
        ));
        customers.add (new MDM_Customer__c (
            Name = 'Customer',
            MDM_Account_Type__c = 'Individual Account'
        ));
        customers.add (new MDM_Customer__c (
            Name = '',
            MDM_Account_Type__c = 'Business Account'
        ));
        customers.add (new MDM_Customer__c (
            Name = '####',
            MDM_Account_Type__c = 'Business Account'
        ));
        customers.add (new MDM_Customer__c (
            Name = '?<=@)[^.]+(?=\\.',
            MDM_Account_Type__c = 'Business Account'
        ));
        Insert customers;
        
        
        List<MDM_Source_Customer__c> refSystems = new List<MDM_Source_Customer__c> ();
        refSystems.add (new MDM_Source_Customer__c (
            MDM_Source_System__c = 'System',
            MDM_Source_System_Id__c = '12312',
            MDM_Customer__c = customers[0].id
        ));
        insert refSystems;
        
    }
    /**
    * @description 
    * @author Dhruv Agrawal | 05-28-2021 
    **/
    public static void lightningComponentServiceTestData(){
        //data for customer validation service class (validation framework)
        MDM_Data_Quality__c quality=new MDM_Data_Quality__c(
            Name='test',
            MDM_Field_API_Name__c='MDM_Source_System__c',
            MDM_Object__c='MDM_Customer_Landing__c'
        ); 
        insert quality;
        MDM_Validation_Rule__c validationRule= new MDM_Validation_Rule__c(
            Name='test',
            MDM_Allowed_Values__c='Bridge\nBroadway\nPACE\nSTBS',
            MDM_Restrict_Picklist_Values__c=true,
            MDM_Max_Length__c=2,
            MDM_Regular_Expression__c='[hi]'
        );
        insert validationRule;
        MDM_Data_Validation_Rule__c junctionObject = new MDM_Data_Validation_Rule__c(
            MDM_Data_Quality__c=quality.id,
            MDM_Validation_Rule__c=validationRule.id
        );
        insert junctionObject;
        
        //test data for data transformation
        MDM_Data_Quality__c quality1= new MDM_Data_Quality__c(
            Name='test',
            MDM_Field_API_Name__c='Name',
            MDM_Object__c='MDM_Customer_Staging__c'
        ); 
        insert quality1;
        MDM_Data_Transformation__c dataTransform =new MDM_Data_Transformation__c(
            Name='test'
        );
        insert dataTransform;
        
        MDM_Data_Transformation_Rule__c datatransformRule =new MDM_Data_Transformation_Rule__c(
            Name='test',
            MDM_Data_Transformation__c=dataTransform.id,
            MDM_Is_Title_Case__c =true,
            MDM_Data_Quality__c=quality1.id
        );
        insert datatransformRule;
        
        MDM_Attribute_Transformation_Item__c attributeItem =new MDM_Attribute_Transformation_Item__c(
            MDM_Case_Sensitive__c=false,
            MDM_Data_Transformation__c =dataTransform.id,
            MDM_New_Value__c=' ',
            MDM_Old_Value__c='Street',
            MDM_Type__c ='Word'
        );
        insert attributeItem;
      
    }
    
    /**
    * @description 
    * @author Dhruv Agrawal | 05-28-2021 
    **/
    public static void createCustomerRegistration() {
        MDM_Customer_Registration__c newCustomerRegistration = new MDM_Customer_Registration__c(
            MDM_Account_Type__c='Individual Account',
            MDM_Processing_Status__c = 'Pending Approval',
            MDM_ContactAddress_JSON__c='[{"addresses":[{"MDM_Address_1__c":"add1","MDM_City__c":"City"}], "contact":{"Name":"odz"}}]'
        );        
        insert newCustomerRegistration;
    }
}