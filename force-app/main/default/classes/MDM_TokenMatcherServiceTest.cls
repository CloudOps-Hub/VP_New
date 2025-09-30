/**
 * @description       : 
 * @author            : Priya Sharma
 * @group             : 
 * @last modified on  : 04-22-2021
 * @last modified by  : Sourabh
 * Modifications Log 
 * Ver   Date         Author         Modification
 * 1.0   04-12-2021   Priya Sharma   Initial Version
**/

@isTest
public class MDM_TokenMatcherServiceTest {
    @SuppressWarnings('PMD.NcssMethodCount') 
    @testSetup static void setup () {
		MDM_TestDataFactory.tokenMatcherServiceTestData();
    }

    @isTest static void findCustomerGoldenMatchesTest() {
        MDM_TokenMatcherWrapper.customerDataModal customerModal1 = new MDM_TokenMatcherWrapper.customerDataModal ();
        customerModal1.MDM_Customer = new MDM_Customer__c (Name = 'Customer', MDM_Account_Type__c = 'Individual Account');
        
        MDM_LightningComponentService.MDM_FindGoldenMatchesWrapper goldenMatchWrapper = 
            new MDM_LightningComponentService.MDM_FindGoldenMatchesWrapper();
        goldenMatchWrapper.dataModalJSON = JSON.serialize (customerModal1);
        goldenMatchWrapper.performWordBasedSearch = true;
        goldenMatchWrapper.wordBasedMatchingRuleJSON = 
            '{"MDM_Customer__c":{"Name":{"threshold":0.7,"wordConfigs":[{"word":"Sir",'+
            '"isStartWith":true},{"word":"Speedy","isStartWith":false}]}}}';
        goldenMatchWrapper.parentObjectId = '';
        goldenMatchWrapper.sObjectType = 'MDM_Customer__c';
        MDM_LightningComponentService.findGoldenMatches(JSON.serialize(goldenMatchWrapper));
        
        MDM_TokenMatcherWrapper.customerDataModal customerModal2 = new MDM_TokenMatcherWrapper.customerDataModal ();
        customerModal2.MDM_Customer = new MDM_Customer__c (Name = 'Customer', MDM_Account_Type__c = 'Individual Account');
       // customerModal2.MDM_Advertiser_Brand = new MDM_Advertiser_Brand__c (Name = 'Brand');
        customerModal2.MDM_Contact = new MDM_Contact__c (Name = 'Contact');
        customerModal2.MDM_Address = new MDM_Address__c (MDM_City__c = 'City', MDM_State__c = 'CA',
                                                         MDM_Country__c = 'USA', MDM_Country_Code__c = 'USA');
        
       	MDM_LightningComponentService.MDM_FindGoldenMatchesWrapper goldenMatchWrapper1 =
            new MDM_LightningComponentService.MDM_FindGoldenMatchesWrapper();
        goldenMatchWrapper1.dataModalJSON = JSON.serialize (customerModal2);
        goldenMatchWrapper1.performWordBasedSearch = true;
        goldenMatchWrapper1.wordBasedMatchingRuleJSON = 
            '{"MDM_Customer__c":{"Name":{"threshold":0.7,"wordConfigs":[{"word":"Sir",'+
            '"isStartWith":true},{"word":"Speedy","isStartWith":false}]}}}';
        goldenMatchWrapper1.parentObjectId = '';
        goldenMatchWrapper1.sObjectType = 'MDM_Customer__c';
        MDM_LightningComponentService.findGoldenMatches(JSON.serialize(goldenMatchWrapper1));
        	
        MDM_TokenMatcherWrapper.customerDataModal customerModal3 = new MDM_TokenMatcherWrapper.customerDataModal ();
        customerModal3.MDM_Customer = new MDM_Customer__c (Name = 'Customer', MDM_Account_Type__c = 'Individual Account');
        customerModal3.MDM_Contact = new MDM_Contact__c (Name = 'Contact');
        customerModal3.MDM_Address = new MDM_Address__c(MDM_City__c = 'City');
        
        MDM_LightningComponentService.MDM_FindGoldenMatchesWrapper goldenMatchWrapper2 = 
            new MDM_LightningComponentService.MDM_FindGoldenMatchesWrapper();
        goldenMatchWrapper2.dataModalJSON = JSON.serialize (customerModal3);
        goldenMatchWrapper2.performWordBasedSearch = true;
        goldenMatchWrapper2.wordBasedMatchingRuleJSON = 
            '{"MDM_Customer__c":{"Name":{"threshold":0.7,"wordConfigs":[{"word":"Sir",'+
            '"isStartWith":true},{"word":"Speedy","isStartWith":false}]}}}';
        goldenMatchWrapper2.parentObjectId = '';
        goldenMatchWrapper2.sObjectType = 'MDM_Customer__c';
        MDM_LightningComponentService.findGoldenMatches(JSON.serialize(goldenMatchWrapper2));
        
        //for given source customer but no match
        MDM_TokenMatcherWrapper.customerDataModal customerModal4 = new MDM_TokenMatcherWrapper.customerDataModal ();
        customerModal4.MDM_Customer = new MDM_Customer__c (Name = 'Customer');
        
        MDM_LightningComponentService.MDM_FindGoldenMatchesWrapper goldenMatchWrapper3 =
            new MDM_LightningComponentService.MDM_FindGoldenMatchesWrapper();
        goldenMatchWrapper3.dataModalJSON = JSON.serialize (customerModal4);
        goldenMatchWrapper3.performWordBasedSearch = false;
        goldenMatchWrapper3.wordBasedMatchingRuleJSON = '{}';
        goldenMatchWrapper3.parentObjectId = '';
        goldenMatchWrapper3.sObjectType = 'MDM_Customer__c';
        MDM_LightningComponentService.findGoldenMatches(JSON.serialize(goldenMatchWrapper3));
                
        MDM_TokenMatcherWrapper.customerDataModal customerModalr15 = new MDM_TokenMatcherWrapper.customerDataModal ();
        customerModalr15.MDM_Contact = new MDM_Contact__c (Name = 'Contact');
        customerModalr15.MDM_Address = new MDM_Address__c(MDM_City__c = 'City');
        customerModalr15.MDM_Source_Customer = new MDM_Source_Customer__c (MDM_Source_System__c = 'System',
                                                                           MDM_Source_System_Id__c = '12312');
        MDM_LightningComponentService.MDM_FindGoldenMatchesWrapper goldenMatchWrapper4 = 
            new MDM_LightningComponentService.MDM_FindGoldenMatchesWrapper();
        goldenMatchWrapper4.dataModalJSON = JSON.serialize (customerModalr15);
        goldenMatchWrapper4.performWordBasedSearch = false;
        goldenMatchWrapper4.wordBasedMatchingRuleJSON = '{}';
        goldenMatchWrapper4.parentObjectId = '';
        goldenMatchWrapper4.sObjectType = 'MDM_Customer__c';
        MDM_LightningComponentService.findGoldenMatches(JSON.serialize(goldenMatchWrapper4));
        
        MDM_TokenMatcherWrapper.customerDataModal customerModalr16 = new MDM_TokenMatcherWrapper.customerDataModal ();
        customerModalr16.MDM_Customer = new MDM_Customer__c (Name = 'Customer');
        customerModalr16.MDM_Source_Customer = new MDM_Source_Customer__c (MDM_Source_System__c = 'System',
                                                                           MDM_Source_System_Id__c = '12312');
        MDM_LightningComponentService.MDM_FindGoldenMatchesWrapper goldenMatchWrapper5 =
            new MDM_LightningComponentService.MDM_FindGoldenMatchesWrapper();
        goldenMatchWrapper5.dataModalJSON = JSON.serialize (customerModalr16);
        goldenMatchWrapper5.performWordBasedSearch = false;
        goldenMatchWrapper5.wordBasedMatchingRuleJSON = '{}';
        goldenMatchWrapper5.parentObjectId = '';
        goldenMatchWrapper5.sObjectType = 'MDM_Customer__c';
        MDM_LightningComponentService.findGoldenMatches(JSON.serialize(goldenMatchWrapper5));
        
        MDM_TokenMatcherWrapper.customerDataModal customerModalr17 = new MDM_TokenMatcherWrapper.customerDataModal ();
        customerModalr17.MDM_Customer = new MDM_Customer__c (Name = 'Customer');
        customerModalr17.MDM_Contact = new MDM_Contact__c (Name = 'Contact');
        customerModalr17.MDM_Source_Customer = new MDM_Source_Customer__c (MDM_Source_System__c = 'System',
                                                                           MDM_Source_System_Id__c = '12312');
        MDM_LightningComponentService.MDM_FindGoldenMatchesWrapper goldenMatchWrapper6 = 
            new MDM_LightningComponentService.MDM_FindGoldenMatchesWrapper();
        goldenMatchWrapper6.dataModalJSON = JSON.serialize (customerModalr17);
        goldenMatchWrapper6.performWordBasedSearch = false;
        goldenMatchWrapper6.wordBasedMatchingRuleJSON = '{}';
        goldenMatchWrapper6.parentObjectId = '';
        goldenMatchWrapper6.sObjectType = 'MDM_Customer__c';
        MDM_LightningComponentService.findGoldenMatches(JSON.serialize(goldenMatchWrapper6));
        
        MDM_TokenMatcherWrapper.customerDataModal customerModal5 = new MDM_TokenMatcherWrapper.customerDataModal ();
        customerModal5.MDM_Customer = new MDM_Customer__c (Name = 'Customer');
        customerModal5.MDM_Address = new MDM_Address__c (MDM_City__c = 'City');        
        MDM_LightningComponentService.MDM_FindGoldenMatchesWrapper goldenMatchWrapper7 =
            new MDM_LightningComponentService.MDM_FindGoldenMatchesWrapper();
        goldenMatchWrapper7.dataModalJSON = JSON.serialize (customerModal5);
        goldenMatchWrapper7.performWordBasedSearch = false;
        goldenMatchWrapper7.wordBasedMatchingRuleJSON = '{}';
        goldenMatchWrapper7.parentObjectId = '';
        goldenMatchWrapper7.sObjectType = 'MDM_Customer__c';
        MDM_LightningComponentService.findGoldenMatches(JSON.serialize(goldenMatchWrapper7));
        
        //for source customer
        MDM_TokenMatcherWrapper.customerDataModal customerModal7 = new MDM_TokenMatcherWrapper.customerDataModal ();
        customerModal7.MDM_Customer = new MDM_Customer__c (Name = 'Customer');        
        MDM_LightningComponentService.MDM_FindGoldenMatchesWrapper goldenMatchWrapper8 =
            new MDM_LightningComponentService.MDM_FindGoldenMatchesWrapper();
        goldenMatchWrapper8.dataModalJSON = JSON.serialize (customerModal7);
        goldenMatchWrapper8.performWordBasedSearch = false;
        goldenMatchWrapper8.wordBasedMatchingRuleJSON = '{}';
        goldenMatchWrapper8.parentObjectId = '';
        goldenMatchWrapper8.sObjectType = 'MDM_Customer__c';
        MDM_LightningComponentService.findGoldenMatches(JSON.serialize(goldenMatchWrapper8));
        
        //for given source customer but no match
        MDM_TokenMatcherWrapper.customerDataModal customerModal8 = new MDM_TokenMatcherWrapper.customerDataModal ();
        customerModal8.MDM_Customer = new MDM_Customer__c (Name = 'Customer');        
        MDM_LightningComponentService.MDM_FindGoldenMatchesWrapper goldenMatchWrapper9 = 
            new MDM_LightningComponentService.MDM_FindGoldenMatchesWrapper();
        goldenMatchWrapper9.dataModalJSON = JSON.serialize (customerModal8);
        goldenMatchWrapper9.performWordBasedSearch = false;
        goldenMatchWrapper9.wordBasedMatchingRuleJSON = '{}';
        goldenMatchWrapper9.parentObjectId = '';
        goldenMatchWrapper9.sObjectType = 'MDM_Customer__c';
        MDM_LightningComponentService.findGoldenMatches(JSON.serialize(goldenMatchWrapper9));
        		
        MDM_TokenMatcherWrapper.customerDataModal customerModal16 = new MDM_TokenMatcherWrapper.customerDataModal ();
        customerModal16.MDM_Customer = new MDM_Customer__c (Name = 'Customer', MDM_Account_Type__c = 'Individual Account');
        customerModal16.MDM_Contact = new MDM_Contact__c (Name = 'Contact');
        customerModal16.MDM_Address = new MDM_Address__c (MDM_City__c = 'City', MDM_State__c = 'CA',
                                                          MDM_Country__c = 'USA', MDM_Country_Code__c = 'USA');        
        MDM_LightningComponentService.MDM_FindGoldenMatchesWrapper goldenMatchWrapper10 = 
            new MDM_LightningComponentService.MDM_FindGoldenMatchesWrapper();
        goldenMatchWrapper10.dataModalJSON = JSON.serialize (customerModal16);
        goldenMatchWrapper10.performWordBasedSearch = true;
        goldenMatchWrapper10.wordBasedMatchingRuleJSON = '{"MDM_Customer__c":{"Name":{"threshold":0.7,'+
            '"wordConfigs":[{"word":"Sir","isStartWith":true},{"word":"Speedy","isStartWith":false}]}}}';
        goldenMatchWrapper10.parentObjectId = '';
        goldenMatchWrapper10.sObjectType = 'MDM_Customer__c';
        MDM_LightningComponentService.findGoldenMatches(JSON.serialize(goldenMatchWrapper10));
        
        // Cover MDM_StringSimilarityService class.
        system.assertEquals(MDM_StringSimilarityService.computeJW('TestString', 'TestString1'), 0.9696,'String Equals');
    
}


 
}