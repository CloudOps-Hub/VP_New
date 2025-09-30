/**
 * @description       : 
 * @author            : Dhruv Agrawal
 * @group             : 
 * @last modified on  : 05-27-2021
 * @last modified by  : Komal Sonsale
 * Modifications Log 
 * Ver   Date         Author          Modification
 * 1.0   03-22-2021   Dhruv Agrawal   Initial Version
**/
@isTest
public with sharing class MDM_FLsUtilsTest {
    @testSetup
  static void setupData() {
    MDM_Customer_Landing__c custLanding = new MDM_Customer_Landing__c(
      MDM_Customer_name__c = 'IKEA Furniture',
      MDM_Account_Type__c = 'Individual Account'
    );
    insert custLanding;
  }
  
  @isTest 
  static void testAccess() {
    MDM_Customer_Landing__c custLanding = [SELECT Id, MDM_Customer_name__c, MDM_Account_Type__c FROM MDM_Customer_Landing__c WHERE MDM_Customer_name__c = 'IKEA Furniture' WITH SECURITY_ENFORCED];
    System.assertEquals(true, MDM_FLsUtils.isAccessible(custLanding, new Set<String>{'MDM_Customer_name__c','MDM_Account_Type__c'}),'Fields are accessible');
    System.assertEquals(true, MDM_FLsUtils.isUpdateable(custLanding, new Set<String>{'MDM_Customer_name__c','MDM_Account_Type__c'}), 'Fields are updatable');
    System.assertNotEquals(true, MDM_FLsUtils.isUpdateable(custLanding, new Set<String>{'Name'}), 'Fields are not updatable');
    System.assertEquals(true, MDM_FLsUtils.isCreateable(custLanding, new Set<String>{'MDM_Customer_name__c','MDM_Account_Type__c'}), 'Fields are creatable');
    System.assertNotEquals(true, MDM_FLsUtils.isCreateable(custLanding, new Set<String>{'id'}), 'Fields are not creatable');
    System.assertEquals(true, MDM_FLsUtils.isDeletable(custLanding), 'fields are deletable');
    System.assertEquals(true, MDM_FLsUtils.flsCheck(custLanding,'create'), 'fields are creatable' );
    System.assertEquals(true, MDM_FLsUtils.flsCheck(custLanding,'update'), 'fields are updatable' );
  }
}