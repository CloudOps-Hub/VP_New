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

public with sharing class MDM_ContactRegistrationJSONParser {
    public static map<Integer,String> contactIDMap =new map<Integer,String>();
    public static Map<Integer,List<MDM_Address_Registration__c>> contactIndexAddresses = new Map<Integer,List<MDM_Address_Registration__c>>();
    public static List<MDM_Address_Registration__c> addresses = new List<MDM_Address_Registration__c>();
    public static Integer contactIndex = 0;
    public static map<Integer,String> registrationIDMap =new map <integer,String>();
    static List<contactAddressWrapper> contactAddress;
    static List<MDM_Contact_Registration__c> contacts;
    static Set<String> fieldSet;

    /**
     * @description : Wrapper class for Contact and Address JSON
     */
    public class ContactAddressWrapper {
        @AuraEnabled public MDM_Contact_Registration__c contact; 
        @AuraEnabled public List<MDM_Address_Registration__c> addresses;
        /**
         * @description : Constructor
         * @param contact 
         * @param addresses
         */
        public contactAddressWrapper(MDM_Contact_Registration__c contact, List<MDM_Address_Registration__c> addresses){
            this.contact = contact;
            this.addresses = addresses;
        }
    }

    static void transformContact(contactAddressWrapper contactAddressItem) {
        contactAddressItem.contact.ID=null;
        contacts.add(contactAddressItem.contact); 
        contactIndex+=1;
    }

    static Boolean isAddressEmpty(MDM_Address_Registration__c address) {
        Boolean isEmptyAddress = true;
        for(String field: fieldSet) {
            if(address.get(field)!=NULL && field!='MDM_Address_Type__c') {
                isEmptyAddress = false;
                break;
            }
        }
        return isEmptyAddress;
    }

    static void transformAddressesWithContact(contactAddressWrapper contactAddressItem, String customerRegistrationID) {
        for(MDM_Address_Registration__c address: contactAddressItem.addresses) {
            if(!isAddressEmpty(address)) {
                if(contactIndexAddresses.get(contactIndex) != NULL) {
                    List<MDM_Address_Registration__c> addresses = contactIndexAddresses.get(contactIndex);
                    addresses.add(address);
                    contactIndexAddresses.put(contactIndex, addresses);
                }
                else { contactIndexAddresses.put(contactIndex, new List<MDM_Address_Registration__c>{address}); }
            }
        }
        registrationIDMap.put(contactIndex,customerRegistrationID);
    }

    static void transformAddressesWithoutContact(contactAddressWrapper contactAddressItem, String customerRegistrationID) {
        for(MDM_Address_Registration__c address:contactAddressItem.addresses){
            Boolean isEmptyAddress = true;
            for(String field: fieldSet) {
                if(address.get(field)!=NULL && field!='MDM_Address_Type__c') {
                    isEmptyAddress = false;
                    break;
                }
            }
            if(!isEmptyAddress) {
                address.MDM_Customer_Registration__c=customerRegistrationID;
                address.ID=null;
                addresses.add(address);
            }
        }
    }

    static void transformContactAddress(contactAddressWrapper contactAddressItem, String customerRegistrationID) {
        if(contactAddressItem.contact!=null && JSON.serialize(contactAddressItem.contact)!=
           '{"attributes":{"type":"MDM_Contact_Registration__c"}}'){
            transformContact(contactAddressItem);
        }
        if(contactAddressItem.contact!=null && contactAddressItem.addresses!=null){
            if(contactAddressItem.addresses.size()!=0 && JSON.serialize(contactAddressItem.contact)!=
               '{"attributes":{"type":"MDM_Contact_Registration__c"}}'){
                transformAddressesWithContact(contactAddressItem, customerRegistrationID);
            } else if(contactAddressItem.addresses.size()!=0){
                transformAddressesWithoutContact(contactAddressItem, customerRegistrationID);
            }
        }
    }
    
    /** 
     * @description : Create contact registration objects from customer registration objects
     * @param customerRegistrationID - ID of Customer registration to which Contacts will be associated, 
     * @param contactAddressJSON - JSON string for contactAddressses
     * @return contacts :list<MDM_Contact_Registration__c>
	 */
    public static list<MDM_Contact_Registration__c> createContactsFromJSON(String customerRegistrationID, String contactAddressJSON){
        contactAddress = new List<contactAddressWrapper>();
        contacts = new List<MDM_Contact_Registration__c>();
        fieldSet = MDM_Address_Registration__c.sObjectType.getDescribe().fields.getMap().keySet();
        try{
            contactAddress = (List<contactAddressWrapper>) JSON.deserialize(contactaddressJSON, List<contactAddressWrapper>.class);
            for(contactAddressWrapper contactAddressItem : contactAddress){
                transformContactAddress(contactAddressItem, customerRegistrationID);
            }
        }
        catch(exception e){
            MDM_HandleCustomException.logException(e);
        }
        if(!contacts.isEmpty()){
            for(MDM_Contact_Registration__c contact : contacts){
                contact.MDM_Customer_Registration__c = customerRegistrationID;
            } 
        }
        return contacts;
    }

    /** 
     * @description : Insert addresses in List(addresses)
	*/
    public static void createAddress(){
        for(Integer  key: contactIndexAddresses.keySet()){
            for(MDM_Address_Registration__c address : contactIndexAddresses.get(key)){
                address.MDM_Customer_Registration__c = registrationIDMap.get(key);	
                address.MDM_Contact_Registration__c = contactIdMap.get(key);
                address.ID=null;
                addresses.add(address);
            }
        }  
    }

    /**
     * @description : Returns contact and address JSON for a given Customer Registration ID
     * @param customerRegistrationID - ID of customer registration record
     * @return string
	*/
    public static String getContactAddressJSON(String customerRegistrationID) {
        List<contactAddressWrapper> contactAddressList = new List<contactAddressWrapper>();
        String query;
       if(Schema.sObjectType.MDM_Contact_Registration__c.isAccessible()){
    
        	 query = 'SELECT id, ownerid, isdeleted, name, createddate, createdbyid, lastmodifieddate, lastmodifiedbyid, systemmodstamp, lastactivitydate,'+
            'mdm_contact_registration_name__c, mdm_customer_registration__c, mdm_email__c, mdm_extension__c, mdm_fax__c,'+
            'mdm_is_deleted__c, mdm_name_suffix__c, mdm_phone__c, mdm_status__c, mdm_title__c'+
            ', (SELECT id,name,MDM_Address_1__c,MDM_Address_2__c,MDM_Address_3__c,MDM_City__c,MDM_State__c, ' +
            'MDM_Country__c,MDM_Address_Type__c,MDM_Email__c,MDM_Phone__c,MDM_Contact_Registration__c, MDM_Country_Code__c,' +
            'MDM_Description_Notes__c,MDM_Zip_Code__c, MDM_Extension__c,MDM_Fax__c,MDM_Status__c from Address_Registrations__r)'+
            ' FROM MDM_Contact_Registration__c where MDM_Customer_Registration__c = :customerRegistrationID  WITH SECURITY_ENFORCED' ;        
        }

        List<MDM_Contact_Registration__c> contacts = new List<MDM_Contact_Registration__c>();
        try{
            contacts = Database.query(String.escapeSingleQuotes(query)); 
        } catch(Exception e){
            System.debug('Insufficient field access: '+e.getStackTraceString());
        }
         
        for(MDM_Contact_Registration__c contact: contacts) {
            List<MDM_Address_Registration__c> addressesLocal = contact.Address_Registrations__r;
            contactAddressWrapper contactAddress = new contactAddressWrapper(contact, addressesLocal);
            contactAddressList.add(contactAddress);
        }
        
        if(Schema.sObjectType.MDM_Address_Registration__c.isAccessible()){
            query =  'SELECT id, ownerid, isdeleted, name, createddate, createdbyid, lastmodifieddate, lastmodifiedbyid, systemmodstamp, lastactivitydate, '+
            'mdm_address_1__c, mdm_address_2__c, mdm_address_3__c, mdm_address_type__c, '+
            'mdm_business_group__c, mdm_city__c, mdm_contact_registration__c, mdm_country_code__c, mdm_country__c, '+
            'mdm_customer_registration__c, mdm_description_notes__c, mdm_email__c, mdm_extension__c, '+
            'mdm_fax__c, mdm_phone__c, mdm_primary__c, mdm_state__c, mdm_status__c, mdm_zip_code__c '+
            ' FROM MDM_Address_Registration__c where MDM_Contact_Registration__c = NULL ' +
            'AND MDM_Customer_Registration__c = :customerRegistrationID WITH SECURITY_ENFORCED';

            List<MDM_Address_Registration__c> addresses = new List<MDM_Address_Registration__c>();
            try{
                addresses = Database.query(string.escapeSingleQuotes(query));
            } catch(Exception ex){
                System.debug('Insufficient field access: '+ex.getStackTraceString());
            }
            
            if(!addresses.isEmpty()) { contactAddressList.add(new contactAddressWrapper(NULL, addresses)); }
        } 
        return JSON.serialize(contactAddressList).replace('"contact":null','"contact":{}');
    }
}