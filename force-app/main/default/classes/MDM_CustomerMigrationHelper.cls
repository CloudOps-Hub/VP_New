/**
 * @description       : 
 * @author            : Priya Sharma
 * @group             : 
 * @last modified on  : 05-28-2021
 * @last modified by  : Komal Sonsale
 * Modifications Log 
 * Ver   Date         Author         Modification
 * 1.0   03-22-2021   Priya Sharma   Initial Version
**/

@SuppressWarnings('PMD.ExcessivePublicCount,PMD.CyclomaticComplexity,PMD.CognitiveComplexity')
public with sharing class MDM_CustomerMigrationHelper {
    /**
     * @description : this wrapper class will have create address details.
     */
    public class MDM_CreateAddressWrapper{
        Datetime srcTimestamp;
        String parentId;
        List<MDM_LightningComponentService.ContactAddressWrapper> contactAddressList;
        List<MDM_Contact_Staging__c> contactList;
        List<MDM_Address_Staging__c> addressList;
        Integer index;
    }
    
    /**
     * @description : this contains landing JSON wrapper
     */
    public class MDM_LandingJSONWrapper{
        List<MDM_Contact_Staging__c> contactStagingList;
        List<MDM_Customer_Staging__c> customerStagingList;
        Integer index;
        MDM_Customer_Landing__c customerLanding;
    }

        /**
     * @description This wrapper class will have create contact details
     */
    public class MDM_CreateContactWrapper{
        Datetime srcTimestamp;
        String parentId; 
        List<MDM_LightningComponentService.ContactAddressWrapper> contactAddressList;
        List<MDM_Contact_Staging__c> contactList;
    }

    /**
    * @description : Will migrate/create ladning data into staging.
    * @param customerLandingList
    */
    @AuraEnabled
    public static void migrateLandingToStaging(List<MDM_Customer_Landing__c> customerLandingList) {
        List<MDM_Contact_Staging__c> contactStagingList = new List<MDM_Contact_Staging__c>();
        List<MDM_Address_Staging__c> addressStagingList = new List<MDM_Address_Staging__c>();
    
        List<String> contactAddressRecordTypeList = new List<String>{'Individual Account','Business Account'}; 
        List<MDM_Customer_Landing__c> customerLandingListToUpdate = new List<MDM_Customer_Landing__c>();
        List<MDM_Customer_Staging__c> customerStagingList = insertCustStaging(customerLandingList);
                    
        //create contacts using respective JSON from landing records
        Integer index = 0;
        for(MDM_Customer_Landing__c customerLanding: customerLandingList) {
          
            if(customerLanding.MDM_Account_Type__c != Null && contactAddressRecordTypeList.contains(customerLanding.MDM_Account_Type__c)) {
                MDM_LandingJSONWrapper jsonWrap = new MDM_LandingJSONWrapper();
                jsonWrap.customerLanding = customerLanding;
                jsonWrap.customerStagingList = customerStagingList;
             
                jsonWrap.contactStagingList = contactStagingList;
                jsonWrap.index = index;
             
                createContactfromLandingJSON(jsonWrap);
            }
            index++;
        }
        
        //-- CRUD & FLS check on Contact Staging --
        if(MDM_FLsUtils.flsCheck(new MDM_Contact_Staging__c(),'create')) {
        Database.insert(contactStagingList, false);
        } else {
            System.debug('User does not have create access or Field level on Contact Staging object.');
        }
        
        index = 0;
        Integer contactIndex = 0;
        //create addresses using respective JSON from landing records
        //Mark landing records as processed and set the lookup to point corresponding staging record
       
        for(MDM_Customer_Landing__c customerLanding: customerLandingList) {

            //Modified if Condition
            Boolean isValid = customerLanding.MDM_Account_Type__c != Null && contactAddressRecordTypeList.contains(customerLanding.MDM_Account_Type__c);
                if(isValid && customerLanding.MDM_Contact_JSON__c != NULL) {
                    MDM_CreateAddressWrapper addressWrapper = new MDM_CreateAddressWrapper();
                    addressWrapper.srcTimestamp = customerStagingList[index].MDM_Source_LastModified__c;
                    addressWrapper.parentId = customerStagingList[index].ID;
                    // Added @Param sourceSystemId in changeContactAddressFormat()
                    addressWrapper.contactAddressList = MDM_DataTransformationService.changeContactAddressFormat(
                                                        customerLanding.MDM_Contact_JSON__c, 
                                                        customerLanding.MDM_Source_System__c,
                                                        customerLanding.MDM_Source_System_Id__c);
                    addressWrapper.contactList = contactStagingList;
                    addressWrapper.addressList = addressStagingList;
                    addressWrapper.index = contactIndex;
                    contactIndex = createAddressList(addressWrapper);
                }
            
                MDM_Customer_Landing__c customerLandingV1 = new MDM_Customer_Landing__c();
                customerLandingV1 = (MDM_Customer_Landing__c)JSON.deserialize(JSON.serialize(customerLanding), MDM_Customer_Landing__c.class);
                if (Schema.sObjectType.MDM_Customer_Landing__c.fields.MDM_Processing_Status__c.isUpdateable() &&
                Schema.sObjectType.MDM_Customer_Landing__c.fields.MDM_Customer_Staging__c.isUpdateable()){
                    customerLandingV1.MDM_Processing_Status__c = 'Processed';
                    customerLandingV1.MDM_Customer_Staging__c = customerStagingList[index].ID;
                }
                customerLandingListToUpdate.add(customerLandingV1);
                index++;
            
        }

        if(MDM_FLsUtils.flsCheck(new MDM_Address_Staging__c(),'create')) {
        Database.insert(addressStagingList, false);
        } else {
            System.debug('User does not have create access or Field level on Address Staging object.');
        }

        //try catch added in parent class - MDM_LightningComponentService
        if(customerLandingListToUpdate.size() > 0 &&  
        MDM_FLsUtils.flsCheck(new MDM_Customer_Landing__c(),'update')) {
                update customerLandingListToUpdate;       
        } 
        insert MDM_CustomerTransformationService.createSourceCustomers(customerLandingListToUpdate);
    }

    /**
     * @description : create contcat from landing json
     * @param jsonWrap
     */
    static void createContactfromLandingJSON(MDM_LandingJSONWrapper jsonWrap){
        if(jsonWrap.customerLanding.MDM_Contact_JSON__c != NULL) {
            MDM_CreateContactWrapper conWrapper = new MDM_CreateContactWrapper();
            conWrapper.srcTimestamp = jsonWrap.customerStagingList[jsonWrap.index].MDM_Source_LastModified__c;
            conWrapper.parentId = jsonWrap.customerStagingList[jsonWrap.index].ID;
            // Added @Param sourceSystemId in changeContactAddressFormat()
            conWrapper.contactAddressList = MDM_DataTransformationService.changeContactAddressFormat(
                                                jsonWrap.customerLanding.MDM_Contact_JSON__c,
                                                jsonWrap.customerLanding.MDM_Source_System__c,
                                                jsonWrap.customerLanding.MDM_Source_System_Id__c);
            conWrapper.contactList = jsonWrap.contactStagingList;
            createContactList(conWrapper);
        }                  
    }
    /**
     * @description : this method will insert customer staging record.
     * @param customerLandingList
     * @return List<MDM_Customer_Staging__c>
     */
    static List<MDM_Customer_Staging__c> insertCustStaging(List<MDM_Customer_Landing__c> customerLandingList){
        List<MDM_Customer_Staging__c> customerStagingList = new List<MDM_Customer_Staging__c>();
        //create customer staging records and mark them as new

        if(!MDM_FLsUtils.flsCheck(new MDM_Customer_Landing__c(),'read') && !MDM_FLsUtils.flsCheck(new MDM_Customer_Staging__c(),'create')) { 
            return null;
        }

        for(MDM_Customer_Landing__c customerLanding: customerLandingList) {
            MDM_Customer_Staging__c customerStaging = new MDM_Customer_Staging__c();
            customerStaging = MDM_CustomerTransformationService.mapData(customerLanding);
            customerStaging.MDM_Processing_Status__c = 'New';
            customerStagingList.add(customerStaging);
        }
        
        try{
            if(customerStagingList.size() > 0 && Schema.sObjectType.MDM_Customer_Staging__c.isCreateable()) {
                insert customerStagingList;
            }
        } catch (Exception e) {
            MDM_HandleCustomException.logException(e);
        }
         
        return customerStagingList;
    }

    /**
    * @description : create address records into staging based on landing records
    * @param addressWrapper
    * @return Integer - next index of contact 
    */
    
    static Integer createAddressList(MDM_CreateAddressWrapper addressWrapper) {
        for(MDM_LightningComponentService.ContactAddressWrapper contactAddress : addressWrapper.contactAddressList) {
            String contactId = NULL;
            if(contactAddress.contact != null && contactAddress.contact.Name != null){
                contactId = addressWrapper.contactList[addressWrapper.index].Id;
                addressWrapper.index += 1;
            }
            for(MDM_Address_Staging__c address : contactAddress.addresses) {
                address.MDM_Contact_Staging__c = contactId;
                address.MDM_Customer_Staging__c = addressWrapper.parentId;
                address.MDM_Source_LastModified__c = addressWrapper.srcTimestamp;
                addressWrapper.addressList.add(address);
            }
        }
        return addressWrapper.index;
    }
    
    
   
    
    
    /**
    * @description : create contact records into staging based on landing records
    * @param conWrapper
    */
     static void createContactList(MDM_CreateContactWrapper conWrapper) {
         for(MDM_LightningComponentService.ContactAddressWrapper contactAddress : conWrapper.contactAddressList) {
            if(contactAddress.contact != null && contactAddress.contact.Name != null) {
                contactAddress.contact.Name = MDM_DataTransformationService.titleCase(contactAddress.contact.Name, '', '');
                contactAddress.contact.MDM_Customer_Staging__c = conWrapper.parentId;
                contactAddress.contact.MDM_Source_LastModified__c = conWrapper.srcTimestamp;
                conWrapper.contactList.add(contactAddress.contact);   
            }
            
        }
    } 

}