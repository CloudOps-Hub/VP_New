/**
 * @description       : 
 * @author            : Dhruv Agrawal
 * @group             : 
 * @last modified on  : 05-27-2021
 * @last modified by  : Komal Sonsale
 * Modifications Log 
 * Ver   Date         Author          Modification
 * 1.0   05-13-2021   Dhruv Agrawal   Initial Version
**/

@isTest(seeAllData=False)
public class MDM_CustomerAPI_HandlerTest {
    /* 
     * @description : Setup data for test scenarios.
     * @param : None
     * @return : None
    */
    @testSetup static void setup() {
		MDM_TestDataFactory.apiHandlerTestData();
    }
    
    static void searchCustomerSetup(RestRequest req, RestResponse res) {
        req.requestURI = '/services/apexrest/v1/customers/search';
        req.httpMethod = 'GET';
        req.addHeader('Content-Type', 'application/json');
        
        RestContext.request = req;
        RestContext.response = res;        
    }
    
    static testmethod void searchCustomersTestCase1() {
        Test.startTest();
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        searchCustomerSetup(req, res);
        MDM_SearchCustomersService.get();
        system.assertNotEquals(500, RestContext.response.statusCode, 'No 500 server error!');
        system.assertNotEquals(400, RestContext.response.statusCode, 'No 400 Bad request error!');
        Test.stopTest();
    }
    
    static testmethod void searchCustomersTestCase2() {
        Test.startTest();
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        searchCustomerSetup(req, res);
        
        req.params.put('lastModifiedDateFrom','2019-12-23');
        RestContext.request = req;
        RestContext.response = res;
        MDM_SearchCustomersService.get();
        system.assertNotEquals(500, RestContext.response.statusCode, 'No 500 server error!');
        system.assertNotEquals(400, RestContext.response.statusCode, 'No 400 Bad request error!');
        Test.stopTest();
    }
    
    static testmethod void searchCustomersTestCase3() {
        Test.startTest();
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        searchCustomerSetup(req, res);
        
        req.params.put('query','coca-cola');
        req.params.put('limit','5');
        RestContext.request = req;
        RestContext.response = res;
        MDM_SearchCustomersService.get();
        system.assertNotEquals(500, RestContext.response.statusCode, 'No 500 server error!');
        system.assertNotEquals(400, RestContext.response.statusCode, 'No 400 Bad request error!');
        Test.stopTest();
    }
    
    static testmethod void searchCustomersTestCase4() {
        Test.startTest();
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        searchCustomerSetup(req, res);
        MDM_Customer__c cust = [Select Id, MDM_Id__c,Name from MDM_Customer__c where Name = 'Coca-Cola'];
        MDM_Customer__c cust1 = [Select Id, MDM_Id__c,Name from MDM_Customer__c where Name = 'Coca-Cola1'];
        MDM_Customer__c cust2 = [Select Id, MDM_Id__c,Name from MDM_Customer__c where Name = 'Coca-Cola2'];
        String mdmId = cust.MDM_Id__c + ',' + cust1.MDM_Id__c + ',' +cust2.MDM_Id__c;
        req.params.put('mdmIds', mdmId);
        RestContext.request = req;
        RestContext.response = res;
        MDM_SearchCustomersService.get();
        system.assertNotEquals(500, RestContext.response.statusCode, 'No 500 server error!');
        system.assertNotEquals(400, RestContext.response.statusCode, 'No 400 Bad request error!');
        Test.stopTest();
    }
    
    static testmethod void searchCustomersTestCase5() {
        Test.startTest();
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        searchCustomerSetup(req, res);
      	MDM_Customer__c cust = [Select Id, MDM_Id__c,Name from MDM_Customer__c where Name = 'Coca-Cola'];
        MDM_Customer__c cust1 = [Select Id, MDM_Id__c,Name from MDM_Customer__c where Name = 'Coca-Cola1'];
        MDM_Customer__c cust2 = [Select Id, MDM_Id__c,Name from MDM_Customer__c where Name = 'Coca-Cola2'];
        String mdmId = cust.MDM_Id__c + ',' + cust1.MDM_Id__c + ',' +cust2.MDM_Id__c;
        req.params.put('mdmIds', mdmId);
        RestContext.request = req;
        RestContext.response = res;
        MDM_SearchCustomersService.get();
        system.assertNotEquals(500, RestContext.response.statusCode, 'No 500 server error!');
        system.assertNotEquals(400, RestContext.response.statusCode, 'No 400 Bad request error!');
        Test.stopTest();
    }
    
    static testmethod void searchCustomersTestCase6() {
        Test.startTest();
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        searchCustomerSetup(req, res);
        
        req.params.put('externalSystemIDs','5709,5209');
        RestContext.request = req;
        RestContext.response = res;
        MDM_SearchCustomersService.get();
        system.assertNotEquals(500, RestContext.response.statusCode, 'No 500 server error!');
        system.assertNotEquals(400, RestContext.response.statusCode, 'No 400 Bad request error!');
        Test.stopTest();
    }
    
    static testmethod void searchCustomersTestCase7() {
        Test.startTest();
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        searchCustomerSetup(req, res);
        
        req.params.put('externalSystemIDs','5709,5209');
        req.params.put('customerType','Individual Account');
        RestContext.request = req;
        RestContext.response = res;
        MDM_SearchCustomersService.get();
        system.assertNotEquals(500, RestContext.response.statusCode, 'No 500 server error!');
        system.assertNotEquals(400, RestContext.response.statusCode, 'No 400 Bad request error!');
        Test.stopTest();
    }
    
    static testmethod void searchCustomersTestCase8() {
        Test.startTest();
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        searchCustomerSetup(req, res);
        
        req.params.put('externalSystemIDs','5702,5209');
        req.params.put('customerType','Individual Account');
        RestContext.request = req;
        RestContext.response = res;
        MDM_SearchCustomersService.get();
        system.assertNotEquals(500, RestContext.response.statusCode, 'No 500 server error!');
        system.assertNotEquals(400, RestContext.response.statusCode, 'No 400 Bad request error!');
        Test.stopTest();
    }
    
    static testmethod void searchCustomersTestCase9() {
        Test.startTest();
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        searchCustomerSetup(req, res);
        
        req.params.put('externalSystemIDs','5709,5209');
        req.params.put('customerType','');
        req.params.put('sourceSystems','PACE');
        req.params.put('mdmIds', '');
        RestContext.request = req;
        RestContext.response = res;
        MDM_SearchCustomersService.get();
        system.assertNotEquals(500, RestContext.response.statusCode, 'No 500 server error!');
        system.assertNotEquals(400, RestContext.response.statusCode, 'No 400 Bad request error!');
        Test.stopTest();
    }
    
    static testmethod void searchCustomersTestCase10() {
        Test.startTest();
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        searchCustomerSetup(req, res);
        MDM_Customer__c cust = [Select Id, MDM_Id__c,Name from MDM_Customer__c where Name = 'Coca-Cola'];
        req.params.put('externalSystemIDs','5709,5209');
        req.params.put('sourceSystems','');
        req.params.put('mdmIds', cust.MDM_ID__c);
        req.params.put('lastModifiedDateTo','');
        RestContext.request = req;
        RestContext.response = res;
        MDM_SearchCustomersService.get();
        system.assertNotEquals(500, RestContext.response.statusCode, 'No 500 server error!');
        system.assertNotEquals(400, RestContext.response.statusCode, 'No 400 Bad request error!');
        Test.stopTest();
    }
    
    static testmethod void searchCustomersTestCase11() {
        Test.startTest();
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        searchCustomerSetup(req, res);
        MDM_Customer__c cust = [Select Id, MDM_Id__c,Name from MDM_Customer__c where Name = 'Coca-Cola'];
        req.params.put('externalSystemIDs','5702,5209');
        req.params.put('sourceSystems','PACE,STB');
        req.params.put('mdmIds', cust.MDM_ID__c);
        RestContext.request = req;
        RestContext.response = res;
        MDM_SearchCustomersService.get();
        system.assertNotEquals(500, RestContext.response.statusCode, 'No 500 server error!');
        system.assertNotEquals(400, RestContext.response.statusCode, 'No 400 Bad request error!');
        Test.stopTest();
    }
    
    static testmethod void searchCustomersTestCase12() {
        Test.startTest();
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        searchCustomerSetup(req, res);
        
        req.params.put('externalSystemIDs','5709,5209');
        req.params.put('sourceSystems','');
        req.params.put('mdmIds', '');
        req.params.put('statusFilter', 'Actives');
        RestContext.request = req;
        RestContext.response = res;
        MDM_SearchCustomersService.get();
        system.assertNotEquals(500, RestContext.response.statusCode, 'No 500 server error!');
        system.assertNotEquals(400, RestContext.response.statusCode, 'No 400 Bad request error!');
        Test.stopTest();
    }
    
    static testmethod void searchCustomersTestCase13() {
        Test.startTest();
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        searchCustomerSetup(req, res);
        
        req.params.put('externalSystemIDs','5709,5209');
        req.params.put('statusFilter', 'Active');
        req.params.put('limit','5s');
        RestContext.request = req;
        RestContext.response = res;
        MDM_SearchCustomersService.get();
        system.assertNotEquals(500, RestContext.response.statusCode, 'No 500 server error!');
        system.assertNotEquals(400, RestContext.response.statusCode, 'No 400 Bad request error!');
        Test.stopTest();
    }
    
    static testmethod void searchCustomersTestCase14() {
        Test.startTest();
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        searchCustomerSetup(req, res);
        
        req.params.put('externalSystemIDs','5702,5209');
        req.params.put('customerType','Individual Account');
        RestContext.request = req;
        RestContext.response = res;
        MDM_SearchCustomersService.get();
        system.assertNotEquals(500, RestContext.response.statusCode, 'No 500 server error!');
        system.assertNotEquals(400, RestContext.response.statusCode, 'No 400 Bad request error!');
        Test.stopTest();
    }
    
    static testmethod void searchCustomersTestCase15() {
        Test.startTest();
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        searchCustomerSetup(req, res);
        
        req.params.put('externalSystemIDs','5702,5209');
        req.params.put('customerType','Individual Account');
        req.params.put('lastModifiedDateFrom','abcd');
        RestContext.request = req;
        RestContext.response = res;
        MDM_SearchCustomersService.get();
        system.assertNotEquals(500, RestContext.response.statusCode, 'No 500 server error!');
        system.assertNotEquals(400, RestContext.response.statusCode, 'No 400 Bad request error!');
        Test.stopTest();
    }
    
    static testmethod void searchCustomersTestCase16() {
        Test.startTest();
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        searchCustomerSetup(req, res);
        
        req.params.put('externalSystemIDs','5702,5209');
        req.params.put('customerType','Individual Account');
        req.params.put('lastModifiedDateFrom','');
        req.params.put('lastModifiedDateTo','adcb');
        RestContext.request = req;
        RestContext.response = res;
        MDM_SearchCustomersService.get();
        system.assertNotEquals(500, RestContext.response.statusCode, 'No 500 server error!');
        system.assertNotEquals(400, RestContext.response.statusCode, 'No 400 Bad request error!');
        Test.stopTest();
    }
    
    static testmethod void searchCustomersTestCase17() {
        Test.startTest();
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        searchCustomerSetup(req, res);
        
        req.params.put('externalSystemIDs','5702,5209');
        req.params.put('customerType','Individual Account');
        req.params.put('lastModifiedDateFrom','2019-11-02');
        req.params.put('lastModifiedDateTo','2019-11-20');
        RestContext.request = req;
        RestContext.response = res;
        MDM_SearchCustomersService.get();
        system.assertNotEquals(500, RestContext.response.statusCode, 'No 500 server error!');
        system.assertNotEquals(400, RestContext.response.statusCode, 'No 400 Bad request error!');
        Test.stopTest();
    }
    
    static testmethod void searchCustomersTestCase18() {
        Test.startTest();
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        searchCustomerSetup(req, res);
        
        req.params.put('externalSystemIDs','5709,5209');
        req.params.put('customerType','Individual Account');
        req.params.put('lastModifiedDateFrom','2019-11-02');
        req.params.put('lastModifiedDateTo','2019-11-20');
        RestContext.request = req;
        RestContext.response = res;
        MDM_SearchCustomersService.get();
        system.assertNotEquals(500, RestContext.response.statusCode, 'No 500 server error!');
        system.assertNotEquals(400, RestContext.response.statusCode, 'No 400 Bad request error!');
        Test.stopTest();
    }
    
    static void getCustomerSetup(RestRequest req, RestResponse res) {
        req.requestURI = '/services/apexrest/v1/customers/search';
        req.httpMethod = 'GET';
        req.addHeader('Content-Type', 'application/json');
        
        RestContext.request = req;
        RestContext.response = res;
    }
    
    static testmethod void getCustomersTestCase1() {
        Test.startTest();
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        getCustomerSetup(req, res); 
        MDM_Customer__c cust = [Select Id, MDM_Id__c,Name from MDM_Customer__c where Name = 'Coca-Cola'];
        req.params.put('mdmIds', cust.MDM_Id__c);
        RestContext.request = req;
        RestContext.response = res;
        MDM_GetCustomersService.get();
        system.assertNotEquals(500, RestContext.response.statusCode, 'No 500 server error!');
        system.assertNotEquals(400, RestContext.response.statusCode, 'No 400 Bad request error!');
        Test.stopTest();
    }
    
    static testmethod void getCustomersTestCase2() {
        Test.startTest();
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        getCustomerSetup(req, res);
        
        req.params.put('statusFilter', 'Active');
        req.params.put('customerType', 'Individual Account');
        RestContext.request = req;
        RestContext.response = res;
        MDM_GetCustomersService.get();
        system.assertNotEquals(500, RestContext.response.statusCode, 'No 500 server error!');
        system.assertNotEquals(400, RestContext.response.statusCode, 'No 400 Bad request error!');
        Test.stopTest();
    }
    
    static testmethod void getCustomersTestCase3() {
        Test.startTest();
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        getCustomerSetup(req, res);
        
        req.params.put('statusFilter', 'Active');
        req.params.put('customerType', 'Individual Account');
        RestContext.request = req;
        RestContext.response = res;
        MDM_GetCustomersService.get();
        system.assertNotEquals(500, RestContext.response.statusCode, 'No 500 server error!');
        system.assertNotEquals(400, RestContext.response.statusCode, 'No 400 Bad request error!');
        Test.stopTest();
    }
    
    static testmethod void getCustomersTestCase4() {
        Test.startTest();
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        getCustomerSetup(req, res);
        
        req.params.put('customerType', 'Individual Account');
        req.params.put('mdmIds', 'a,b,c,d,e,f,g,h,i,j,k,l,m,n,o,p,q,r,s,t,u,v,w,x,y,z,a1,a2,a3,a4,a5,a6,a7,a8,a9,a10');
        RestContext.request = req;
        RestContext.response = res;
        MDM_GetCustomersService.get();
        system.assertNotEquals(500, RestContext.response.statusCode, 'No 500 server error!');
        system.assertNotEquals(400, RestContext.response.statusCode, 'No 400 Bad request error!');
        Test.stopTest();
    }
    
    static testmethod void getCustomersTestCase5() {
        Test.startTest();
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        getCustomerSetup(req, res);
         MDM_Customer__c cust = [Select Id, MDM_Id__c,Name from MDM_Customer__c where Name = 'Coca-Cola2'];
        req.params.put('customerType', 'Individual Account');
        req.params.put('mdmIds', cust.MDM_Id__c);
        RestContext.request = req;
        RestContext.response = res;
        MDM_GetCustomersService.get();
        system.assertNotEquals(500, RestContext.response.statusCode, 'No 500 server error!');
        system.assertNotEquals(400, RestContext.response.statusCode, 'No 400 Bad request error!');
        Test.stopTest();
    }
    
    static testmethod void getCustomersTestCase6() {
        Test.startTest();
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        getCustomerSetup(req, res);
         MDM_Customer__c cust = [Select Id, MDM_Id__c,Name from MDM_Customer__c where Name = 'Coca-Cola'];
        req.params.put('statusFilter', 'Active');
        req.params.put('customerType', 'Individual Account');
        req.params.put('mdmIds', cust.MDM_Id__c);
        RestContext.request = req;
        RestContext.response = res;
        MDM_GetCustomersService.get();
        system.assertNotEquals(500, RestContext.response.statusCode, 'No 500 server error!');
        system.assertNotEquals(400, RestContext.response.statusCode, 'No 400 Bad request error!');
        Test.stopTest();
    }
    
    static testmethod void getCustomersTestCase7() {
        Test.startTest();
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        getCustomerSetup(req, res);
        MDM_Customer__c cust = [Select Id, MDM_Id__c,Name from MDM_Customer__c where Name = 'Coca-Cola'];
        req.params.put('statusFilter', 'Active');
        req.params.put('customerType', 'Individual Account');
      	req.params.put('mdmIds', cust.MDM_Id__c);
        RestContext.request = req;
        RestContext.response = res;
        MDM_GetCustomersService.get();
        system.assertNotEquals(500, RestContext.response.statusCode, 'No 500 server error!');
        system.assertNotEquals(400, RestContext.response.statusCode, 'No 400 Bad request error!');
        Test.stopTest();
    }
    
    static testmethod void getCustomersTestCase8() {
        Test.startTest();
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        getCustomerSetup(req, res);
        MDM_Customer__c cust = [Select Id, MDM_Id__c,Name from MDM_Customer__c where Name = 'Coca-Cola'];
        req.params.put('statusFilter', 'Active');
        req.params.put('part', 'externalIDs,child');
        req.params.put('mdmIds', cust.MDM_Id__c);
        RestContext.request = req;
        RestContext.response = res;
        MDM_GetCustomersService.get();
        system.assertNotEquals(500, RestContext.response.statusCode, 'No 500 server error!');
        system.assertNotEquals(400, RestContext.response.statusCode, 'No 400 Bad request error!');
        Test.stopTest();
    }
    
    static testmethod void getCustomersTestCase9() {
        Test.startTest();
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        getCustomerSetup(req, res);
        MDM_Customer__c cust = [Select Id, MDM_Id__c,Name from MDM_Customer__c where Name = 'Coca-Cola'];
        req.params.put('statusFilter', 'Active');
        req.params.put('part', 'child');
        req.params.put('mdmIds', cust.MDM_Id__c);
        RestContext.request = req;
        RestContext.response = res;
        MDM_GetCustomersService.get();
        system.assertNotEquals(500, RestContext.response.statusCode, 'No 500 server error!');
        system.assertNotEquals(400, RestContext.response.statusCode, 'No 400 Bad request error!');
        Test.stopTest();
    }
    
    static testmethod void getCustomersTestCase10() {
        Test.startTest();
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        getCustomerSetup(req, res);
        MDM_Customer__c cust = [Select Id, MDM_Id__c,Name from MDM_Customer__c where Name = 'Coca-Cola'];
        req.params.put('statusFilter', 'Actives');
        req.params.put('part', 'externalIDs,child');
         req.params.put('mdmIds', cust.MDM_Id__c);
        RestContext.request = req;
        RestContext.response = res;
        MDM_GetCustomersService.get();
        system.assertNotEquals(500, RestContext.response.statusCode, 'No 500 server error!');
        system.assertNotEquals(400, RestContext.response.statusCode, 'No 400 Bad request error!');
        Test.stopTest();
    }
    
    static testmethod void getCustomersTestCase11() {
        Test.startTest();
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        getCustomerSetup(req, res);
        MDM_Customer__c cust = [Select Id, MDM_Id__c,Name from MDM_Customer__c where Name = 'Coca-Cola'];
        req.params.put('statusFilter', 'Active');
        req.params.put('part', 'externalIDs,childs');
        req.params.put('mdmIds', cust.MDM_Id__c);
        RestContext.request = req;
        RestContext.response = res;
        MDM_GetCustomersService.get();
        system.assertNotEquals(500, RestContext.response.statusCode, 'No 500 server error!');
        system.assertNotEquals(400, RestContext.response.statusCode, 'No 400 Bad request error!');
        Test.stopTest();
    }
    
    static testmethod void getCustomersTestCase12() {
        Test.startTest();
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        getCustomerSetup(req, res);
        MDM_Customer__c cust = [Select Id, MDM_Id__c,Name from MDM_Customer__c where Name = 'Coca-Cola'];
        req.params.put('statusFilter', 'Active');
        req.params.put('part', 'child');
        req.params.put('field', 'description,status,isDeleted');
         req.params.put('mdmIds', cust.MDM_Id__c);
        RestContext.request = req;
        RestContext.response = res;
        MDM_GetCustomersService.get();
        system.assertNotEquals(500, RestContext.response.statusCode, 'No 500 server error!');
        system.assertNotEquals(400, RestContext.response.statusCode, 'No 400 Bad request error!');
        Test.stopTest();
    }
    
    static testmethod void getCustomersTestCase13() {
        Test.startTest();
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        getCustomerSetup(req, res);
        MDM_Customer__c cust = [Select Id, MDM_Id__c,Name from MDM_Customer__c where Name = 'Coca-Cola'];
        req.params.put('statusFilter', 'Active');
        req.params.put('field', 'name,mdmID,description,status,type,'+
                       'isDeleted,lastModifiedDate,createdDate');
         req.params.put('mdmIds', cust.MDM_Id__c);
        RestContext.request = req;
        RestContext.response = res;
        MDM_GetCustomersService.get();
        system.assertNotEquals(500, RestContext.response.statusCode, 'No 500 server error!');
        system.assertNotEquals(400, RestContext.response.statusCode, 'No 400 Bad request error!');
        Test.stopTest();
    }
    
    static testmethod void getCustomersTestCase14() {
        Test.startTest();
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        getCustomerSetup(req, res);
        MDM_Customer__c cust = [Select Id, MDM_Id__c,Name from MDM_Customer__c where Name = 'Coca-Cola'];
        req.params.put('statusFilter', 'Active');
        req.params.put('part', 'child');
        req.params.put('customerType', 'test');
         req.params.put('mdmIds', cust.MDM_Id__c);
        RestContext.request = req;
        RestContext.response = res;
        MDM_GetCustomersService.get();
        system.assertNotEquals(500, RestContext.response.statusCode, 'No 500 server error!');
        system.assertNotEquals(400, RestContext.response.statusCode, 'No 400 Bad request error!');
        Test.stopTest();
    }

    static testmethod void getCustomersTestCase15() {
        Test.startTest();
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        getCustomerSetup(req, res);
        MDM_Customer__c cust = [Select Id, MDM_Id__c,Name from MDM_Customer__c where Name = 'Coca-Cola2'];
        req.params.put('statusFilter', 'Active');
        req.params.put('mdmIds', cust.MDM_Id__c);
        RestContext.request = req;
        RestContext.response = res;
        MDM_GetCustomersService.get();
        system.assertNotEquals(500, RestContext.response.statusCode, 'No 500 server error!');
        system.assertNotEquals(400, RestContext.response.statusCode, 'No 400 Bad request error!');
        Test.stopTest();
    }
}