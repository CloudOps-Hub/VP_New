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

public with sharing class MDM_CustomerContactAddressTriggerHelper {
    static List<String> fieldList = new List<String> {
        'MDM_Country__c', 'MDM_Country_Code__c', 'MDM_State__c', 'MDM_Zip_Code__c', 'MDM_Phone__c', 
        'MDM_Fax__c', 'MDM_Address_1__c', 'MDM_Address_2__c', 'MDM_Address_3__c', 'MDM_Source_System_Address_Id__c', 
        'MDM_Address_Type__c', 'MDM_External_System_Name__c','MDM_Is_Deleted__c'
    };
    static List<String> validSourceSystems = new List<String> {'PACE', 'STBS'};
    static List<String> validAddressTypes = new List<String> {'Billing', 'Buying'};
    static List<sObject> eligibleAddresses;

    /**
   
    *  @description Prevent Creating & Updating & Deleting Address/Contact object if isDelete Flag is Checked on Customer.
    *  @param triggerWrapper (trigger)
    *  @param isDelete (boolean)
    */
    public static void preventUpdatingDeletedCustomer(MDM_TriggerWrapper triggerWrapper, Boolean isDelete){        
        Set<String> customerIds = new Set<String>();        
        for(SObject obj : isDelete ? triggerWrapper.oldSObjectList : triggerWrapper.newSObjectList){
            if(obj.get('MDM_Customer__c') != NULL ) { customerIds.add((String)obj.get('MDM_Customer__c')); }
        }  
        for(MDM_Customer__c customer: [
            SELECT Id FROM MDM_Customer__c WHERE MDM_is_Deleted__c != true
            AND Id IN : customerIds
        ]){
            customerIds.remove(customer.Id);
        }
        Boolean isSysAdmin = MDM_CustomerTriggerHelper.checkSysAdminProfile();
        
        for(SObject obj : isDelete ? triggerWrapper.oldSObjectList : triggerWrapper.newSObjectList ) {
            if(customerIds.contains((String)obj.get('MDM_Customer__c'))&& (!isSysAdmin) ) {
                //obj.addError('Customer is marked as deleted. Cannot Create/Update the record.');
              system.debug('Customer is marked as deleted. Cannot Create/Update the record.');
            }
        }
    
    }
   
}