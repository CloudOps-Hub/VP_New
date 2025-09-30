/**
* @description       : 
* @author            : Dhruv Agrawal
* @group             : 
* @last modified on  : 05-28-2021
* @last modified by  : Komal Sonsale
* Modifications Log 
* Ver   Date         Author          Modification
* 1.0   03-24-2021   Dhruv Agrawal   Initial Version
**/
@isTest
public with sharing class MDM_HandleCustomExceptionTest {
    @isTest
    public static void createCustomer() {
        try {
            MDM_Customer_Landing__c m = new MDM_Customer_Landing__c();
            insert m;
            System.assert(m.id !=null, 'insert');  
            throw new System.DmlException('Insert Failed');
        } catch (Exception e) {
            MDM_HandleCustomException.logException(e);  
        } 
    } 
}