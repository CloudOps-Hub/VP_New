/**
 * @description       : Moving Data from Registration and related lists to Customer Staging and its related lists
 * @author            : Komal Sonsale
 * @group             : 
 * @last modified on  : 06-10-2021
 * @last modified by  : Komal Sonsale
 * Modifications Log 
 * Ver   Date         Author          Modification
 * 1.0   04-08-2021   Komal Sonsale   Initial Version
**/

public with sharing class MDM_RegistrationToStagingProcessHelper {
    
    static List<String> contactAddressRecordTypeList = new List<String>{'Individual Account','Business Account'};
    static map<string,string> registrationToStagingMap =new map<string,string>{
        'Name'								=>	'MDM_Customer_Name__c',
        'MDM_Description__c'				=>	'MDM_Description__c',
        'MDM_Industry_Type__c'				=>	'MDM_Industry_Type__c',
        'MDM_Account_Type__c'				=>	'MDM_Account_Type__c',
        'MDM_DOI_or_DOB__c'					=>	'MDM_DOI_or_DOB__c',
        'MDM_Customer_Id__c'				=>	'MDM_Customer_Id__c',
        'MDM_Customer_Type__c'				=>	'MDM_Customer_Type__c',
        'MDM_Email__c'				        =>	'MDM_Email__c',
        'MDM_Phone__c'				        =>	'MDM_Phone__c'
    };
    
    static map<string,string> contactFieldMap=new map<string,string>{
        'Name'				=>	'MDM_Contact_Registration_Name__c',
        'MDM_Email__c'		=>	'MDM_Email__c',
        'MDM_Extension__c'	=>	'MDM_Extension__c',
        'MDM_Fax__c'		=>	'MDM_Fax__c',
        'MDM_Name_Suffix__c'=>	'MDM_Name_Suffix__c',
        'MDM_Phone__c'		=>	'MDM_Phone__c',
        'MDM_Title__c'		=>	'MDM_Title__c'
    };
    static map<string,string> addressFieldMap=new map<string,string>{
        'MDM_Address_1__c'		    =>'MDM_Address_1__c',
        'MDM_Address_2__c'		    =>'MDM_Address_2__c',
        'MDM_Address_3__c'		    =>'MDM_Address_3__c',
        'MDM_Address_Type__c'	    =>'MDM_Address_Type__c',
        'MDM_City__c'			    =>'MDM_City__c',
        'MDM_Country__c'		    =>'MDM_Country__c',
        'MDM_Country_Code__c'	    =>'MDM_Country_Code__c', 
        'MDM_Email__c'			    =>'MDM_Email__c',
        'MDM_Extension__c'		    =>'MDM_Extension__c',
        'MDM_Fax__c'			    =>'MDM_Fax__c',
        'MDM_Phone__c'			    =>'MDM_Phone__c',
        'MDM_Description_Notes__c'  =>'MDM_Description_Notes__c',
        'MDM_State__c'			    =>'MDM_State__c',
        'MDM_Zip_Code__c'		    =>'MDM_Zip_Code__c',
        'MDM_Status__c' 		    =>'MDM_Status__c'
    };

    static list<MDM_Customer_Registration__c> retrieveCustomerRegistration(List<String> regIds) {
        Set<String> fieldSet = MDM_Customer_Registration__c.sObjectType.getDescribe().fields.getMap().keySet();
        String fields = String.join(new List<String> (fieldSet), ', ');
        String query = 'SELECT ' + fields + 
            ', (SELECT id,name,MDM_Address_1__c,MDM_Address_2__c,MDM_Address_3__c,MDM_City__c,MDM_State__c,' +
            ' MDM_Country__c,MDM_Address_Type__c,MDM_Email__c,MDM_Phone__c,MDM_Contact_Registration__c,' +
            ' MDM_Country_Code__c,MDM_Description_Notes__c,MDM_Zip_Code__c, MDM_Extension__c,MDM_Fax__c,MDM_Status__c' +
            ' from Address_Registrations__r),'+
            ' (SELECT id, MDM_Contact_Registration_Name__c,MDM_Phone__c,MDM_Email__c,MDM_Extension__c,MDM_Name_Suffix__c,' +
            ' MDM_Title__c,MDM_Fax__c from Contact_Registrations__r)'+
            ' FROM MDM_Customer_Registration__c where id in :regIds WITH SECURITY_ENFORCED';
        
        list<MDM_Customer_Registration__c> rawData = Database.query(String.escapeSingleQuotes(query));
        return rawData;
    }

    static void createCustomerStagingList(
        list<sObject> customerStagingList,
        list<string> customerStagingIDList,
        list<MDM_Customer_Registration__c> rawData
    ) {
        for(MDM_Customer_Registration__c registrationCustomer : rawData){
            sObject customerStaging = new MDM_Customer_Staging__c();
            for(string field : registrationToStagingMap.keySet()){
                customerStaging.put(field,registrationCustomer.get(registrationToStagingMap.get(field)));
            }
            customerStagingList.add(customerStaging);
            customerStagingIDList.add(registrationCustomer.id);
        }
        // insert customer staging 
        try {
            if(Schema.sObjectType.MDM_Customer_Staging__c.isCreateable()){
                insert (List<MDM_Customer_Staging__c>)customerStagingList;
            }
        } catch (Exception e) {
            MDM_HandleCustomException.logException(e);
        }
    }

    static list<sObject> createContactStagingList(
        MDM_Customer_Registration__c registrationCustomer,
        list<string> contactStagingIDList,
        map<string,string> customerIDMap
    ) {
        list<sObject> contactStagingList = new list<MDM_Contact_Staging__c>();
        if(registrationCustomer.MDM_Account_Type__c != Null && contactAddressRecordTypeList.contains(registrationCustomer.MDM_Account_Type__c)){
            for(MDM_Contact_Registration__c contact : registrationCustomer.Contact_Registrations__r){
                sObject newContact = new MDM_Contact_Staging__c();
                for(string field : contactFieldMap.keySet()){
                    newContact.put(field, contact.get(contactFieldMap.get(field)));
                }
                newContact.put('MDM_Customer_Staging__c',customerIDMap.get(registrationCustomer.id));
                contactStagingList.add(newContact);
                contactStagingIDList.add(contact.id);
            }
        }
        return contactStagingList;
    }

    static list<sObject> createAddressStagingList(
        MDM_Customer_Registration__c registrationCustomer,
        map<string,string> contactIDMap,
        map<string,string> customerIDMap
    ) {
        list<sObject> addressStagingList = new list<MDM_Address_Staging__c>();
        if(registrationCustomer.MDM_Account_Type__c!= Null && contactAddressRecordTypeList.contains(registrationCustomer.MDM_Account_Type__c)){
            for(MDM_Address_Registration__c address:registrationCustomer.Address_Registrations__r){
                sObject newAddress= new MDM_Address_Staging__c();
                for(string field: addressFieldMap.keySet()){
                    newAddress.put(field,address.get(addressFieldMap.get(field)));
                }
                newAddress.put('MDM_Customer_Staging__c',customerIDMap.get(registrationCustomer.id));
                if(contactIDMap.containsKey(address.MDM_Contact_Registration__c)){
                    newAddress.put('MDM_Contact_Staging__c',contactIDMap.get(address.MDM_Contact_Registration__c));
                }
                addressStagingList.add(newAddress);
            }
        }
        return addressStagingList;
    }

    /**
    * @description 
    * @author Komal Sonsale | 06-10-2021 
    * @param regIds 
    **/
	@InvocableMethod
    public static void createCustomerStagings (List<String> regIds){
        list<sObject> customerStagingList = new list<MDM_Customer_Staging__c>();
        list<sObject> contactStagingList = new list<MDM_Contact_Staging__c>();
        list<sObject> addressStagingList = new list<MDM_Address_Staging__c>();
        list<string> customerStagingIDList = new list<String>();
        map<string,string> customerIDMap = new map<string,string>();
        list<string> contactStagingIDList = new list<String>();
        map<string,string> contactIDMap = new map<string,string>();
        
        list<MDM_Customer_Registration__c> rawData = retrieveCustomerRegistration(regIds);
        
        createCustomerStagingList(customerStagingList, customerStagingIDList, rawData);

        //map the customer staging ids with the customer processed id
        for(integer i=0;i<customerStagingList.size();i++){
            customerIDMap.put(customerStagingIDList[i],customerStagingList[i].id);
        }
        
        //for source customer contacts
        for(MDM_Customer_Registration__c registrationCustomer : rawData){
        	registrationCustomer.put('MDM_Customer_Staging__c',customerIDMap.get(registrationCustomer.id));
            registrationCustomer.put('MDM_Processing_Status__c','Approved');
            contactStagingList = createContactStagingList(registrationCustomer, contactStagingIDList, customerIDMap);
        }
        try {
            if(Schema.sObjectType.MDM_Contact_Staging__c.isCreateable()){
                insert (list<MDM_Contact_Staging__c>) contactStagingList;
            }
        } catch (Exception e) {
            MDM_HandleCustomException.logException(e);
        }
        for(integer i=0;i<contactStagingList.size();i++){
		    contactIDMAp.put(contactStagingIDList[i],contactStagingList[i].id);
        }
        //adding addresses
        for(MDM_Customer_Registration__c registrationCustomer : rawData){
            addressStagingList = createAddressStagingList(registrationCustomer, contactIDMap, customerIDMap);
        }
        try {
            if(Schema.sObjectType.MDM_Customer_Registration__c.isUpdateable() 
               && Schema.sObjectType.MDM_Address_Staging__c.isCreateable()) {
                   update (List<MDM_Customer_Registration__c>)rawData;
                   insert (List<MDM_Address_Staging__c>)addressStagingList;
               }
        } catch (Exception e) {
            MDM_HandleCustomException.logException(e);
        }
    }
}