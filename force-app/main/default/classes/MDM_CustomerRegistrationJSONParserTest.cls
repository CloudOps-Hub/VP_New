/**
 * @description       : 
 * @author            : Dhruv Agrawal
 * @group             : 
 * @last modified on  : 05-27-2021
 * @last modified by  : Dhruv Agrawal
 * Modifications Log 
 * Ver   Date         Author          Modification
 * 1.0   04-12-2021   Dhruv Agrawal   Initial Version
**/

@isTest(SeeAllData=False)
public class MDM_CustomerRegistrationJSONParserTest {
    
    @testSetup static void setup() {  
    	MDM_TestDataFactory.createCustomerRegistration();
    }
    
    /** 
     * @description Covers all functions in MDM_CustomerRegistrationJSONParser class.
	*/
	@isTest
    static void customerRegistrationJSONParserTest() {
        MDM_Customer_Registration__c customerRegistration = [SELECT ID, Name, MDM_Account_Type__c FROM MDM_Customer_Registration__c];
        String contactAddressJSON = '[{"addresses":[{"MDM_Address_Type__c":"","MDM_Address_1__c":"nd.asn","MDM_City__c":"kdsanlk"}],'+
            '"contact":{"MDM_Contact_Registration_Name__c":"nasld","MDM_Title__c":"kansfl"}},{"contact":{},'+
            '"addresses":[{"MDM_Address_Type__c":"","MDM_Address_1__c":"knsaln","MDM_City__c":"kdnasl"}]}]';
        Test.startTest();
        MDM_LightningComponentService.parseCustomerRegistrationJSON(customerRegistration.ID, contactAddressJSON);
        String contactAddress = MDM_LightningComponentService.getCustomerRegistrationContactAddressJSON(customerRegistration.ID);
        Boolean isContactAddress = String.isBlank(contactAddress);
        System.assertEquals(false, isContactAddress,'isContactAdress is false');
        Test.stopTest();
    }
}