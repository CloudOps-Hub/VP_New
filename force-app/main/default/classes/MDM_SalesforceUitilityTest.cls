/**
 * @description       : 
 * @author            : Priya Sharma
 * @group             : 
 * @last modified on  : 05-19-2021
 * @last modified by  : Komal Sonsale
 * Modifications Log 
 * Ver   Date         Author         Modification
 * 1.0   04-12-2021   Priya Sharma   Initial Version
**/


@isTest
public class MDM_SalesforceUitilityTest {
    @isTest static void apexGeneralisedMethodTest() {
        Test.startTest();
        Account acc1 = new Account(
            Name = 'Test Account'
        );
        List<Account> accountList = new List<Account>();
        accountList.add(acc1);
        MDM_SalesforceUitility.apexDMLHandler(accountList, 'Account', 'insert');
        MDM_SalesforceUitility.apexDMLHandler(accountList, 'Account', 'update');
        MDM_SalesforceUitility.apexDMLHandler(accountList, 'Account', 'upsert');
        MDM_SalesforceUitility.apexDMLHandler(accountList, 'Account', 'delete');
        MDM_SalesforceUitility.apexDMLHandler(accountList, 'Account', 'undelete');
        Account acc2 = new Account(
            Name = ''
        );
        List<Account> accountList1 = new List<Account>();
        accountList1.add(acc2);
        MDM_SalesforceUitility.apexDMLHandler(accountList1, 'Account', 'insert');
        // Provide Wrong Object Name
        MDM_SalesforceUitility.apexDMLHandler(accountList1, 'Accounty', 'insert');
       
        // test Record Type Method.
        MDM_GeneraliseResult result = MDM_SalesforceUitility.getObjectRecordTypeId('MDM_Customer__c', 'Individual Account');
        System.assert(String.isNotBlank(String.valueOf(result.result)),'Record Type is NOT NULL');
       
        try {
            // test Record Type Method with wrong input.
            result = MDM_SalesforceUitility.getObjectRecordTypeId('MDM_Customer__c', 'Account');
            //System.assert(String.isBlank(String.valueOf(result.result)),'Invalid Customer Record Type');
        } catch( MDM_SalesforceUitility.RecordTypeException exp) {
            System.assertEquals('Record type "Account" does not exist.', exp.getMessage(),'Invalid Customer Record Type');
        }
        Test.stopTest();
    }
   
    @isTest static void apexGeneralisedResultTest() {
        Test.startTest();
        MDM_GeneraliseResult result = new MDM_GeneraliseResult();
        System.assert(result.result == NULL, 'Generalized Result');
        Test.stopTest();
    }
}