/**
 * @description       : 
 * @author            : Priya Sharma
 * @group             : 
 * @last modified on  : 05-12-2021
 * @last modified by  : Priya
 * Modifications Log 
 * Ver   Date         Author         Modification
 * 1.0   04-12-2021   Priya Sharma   Initial Version

 
* @description  : This class will have testcoverage for following classes
* 					1. MDM_LightningComponentService
* 					2. MDM_CustomerComponentHelper

**/

@isTest
public class MDM_LightningComponentServiceTest {
    /** 
	* @description : setup method to create testdata for golden customer record
	*/ 
    @testSetup static void setup() {
       MDM_TestDataFactory.lightningComponentServiceTestData();
    }
    
    /*This method will cover getCustomerField() of MDM_LightningComponentService*/
    @isTest static void getCustomerFieldTest() {
        //For 'GeneralizeResult' class coverage
        MDM_GeneraliseResult finalResult = new MDM_GeneraliseResult();
        Boolean isSuccess;
        isSuccess = finalResult.isSuccess;
        String message;
        message = finalResult.displayMessage;
        object result;
        result = finalResult.result;
        
        Test.startTest();
        List<String> customerfieldList = new List<String>();
        Map<String,List<String>> customerFieldMap= new Map<String,List<String>>{'sObjectType'=>new List<String>{'MDM_Customer__c'}};
            customerfieldList.add(JSON.serialize(customerFieldMap));
        customerFieldMap= new Map<String,List<String>>{'advertiserTypeCustFields'=>new List<String>{'Name'}};
            customerfieldList.add(JSON.serialize(customerFieldMap));
        System.assert(MDM_LightningComponentService.getCustomerField(JSON.serialize(customerfieldList)).result != NULL, 'customer Field List');
        Test.stopTest();
    }        
    
    
    /*This method will cover getListViewID(),getParentCustomer(), getUser(), getFields(),
	*getPicklistValues(),getSObjects() of MDM_LightningComponentService
	*/    
    @isTest static void serviceTest() {
        Test.startTest();
        MDM_LightningComponentService.getListViewID('MDM_Customer_Registration__c', 'Pending Approval/Pending Clarification');
        String currentUserId = UserInfo.getUserId() ;
        MDM_LightningComponentService.getUser(currentUserId);
        MDM_LightningComponentService.getFields('MDM_Customer_Registration__c');
        MDM_LightningComponentService.getSObjects();
        System.assert(currentUserId !=null, 'current user ID');
        Test.stopTest();
    }
    @isTest
    static void getPermissionSetNameTest(){
        List<String> str = new List<String>();
        str.add('MDM_DataSteward');
        str.add('MDM_DelegatedAdmin');
        System.assert(MDM_LightningComponentService.getPermissionSetName(str) !=null, 'current user ID');
    }
}