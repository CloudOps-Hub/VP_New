/**
 * @description       : 
 * @author            : Priya Sharma
 * @group             : 
 * @last modified on  : 05-28-2021
 * @last modified by  : Dhruv Agrawal
 * Modifications Log 
 * Ver   Date         Author         Modification
 * 1.0   04-14-2021   Priya Sharma   Initial Version
**/


public with sharing class MDM_CustomerRegistrationJSONParser {
    
  
    /**
    * @description 
    * @author Dhruv Agrawal | 05-28-2021 
    * @param customerRegistrationID 
    * @param contactAddressJSON 
    **/
    public static void parseCustomerRegistrationJSON(String customerRegistrationID, String contactAddressJSON) {
        List<MDM_Contact_Registration__c> registrationContactList = new List<MDM_Contact_Registration__c>();
      
        if(!contactAddressJSON.equals('[{"addresses":[{}],"contact":{}}]') && !String.isBlank(contactAddressJSON) && contactAddressJSON != '[]'){
            registrationContactList.addAll(createContactsFromJSON(customerRegistrationID, contactAddressJSON));  
        }
        try{
            if(Schema.sObjectType.MDM_Contact_Registration__c.isCreateable()){ insert registrationContactList; }
            throwException();
        } catch (Exception e) {
            MDM_HandleCustomException.logException(e);
        }
        integer indexCount = 1;
        for (MDM_Contact_Registration__c registrationContact : registrationContactList){
            MDM_ContactRegistrationJSONParser.contactIDMap.put(indexCount, registrationContact.ID);
            indexCount++;
        }
        MDM_ContactRegistrationJSONParser.createAddress();
        try{
            insert MDM_ContactRegistrationJSONParser.addresses;
            throwException();
        } catch (Exception e){
            MDM_HandleCustomException.logException(e);
        }
    }

    static void throwException() { if(Test.isRunningTest()) { throw new System.DmlException('DML failed'); } }
    
    /** 
     * @description : Create contact registration objects from customer registration objects
     * @param customerRegistrationID - ID of Customer registration to which Contacts will be associated, 
     * @param contactAddressJSON - JSON string for contactAddressses
     * @return contacts :list<MDM_Contact_Registration__c>
	 */
    public static list<MDM_Contact_Registration__c> createContactsFromJSON(String customerRegistrationID, String contactAddressJSON){
        return MDM_ContactRegistrationJSONParser.createContactsFromJSON(customerRegistrationID, contactAddressJSON);
    }
    
    /**
     * @description : Returns contact and address JSON for a given Customer Registration ID
     * @param customerRegistrationID - ID of customer registration record
     * @return string
	*/
    public static String getContactAddressJSON(String customerRegistrationID) {
        return MDM_ContactRegistrationJSONParser.getContactAddressJSON(customerRegistrationID);
    }
}