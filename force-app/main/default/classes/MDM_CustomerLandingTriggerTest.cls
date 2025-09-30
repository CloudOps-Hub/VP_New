/**
 * @description       : 
 * @author            : Dhruv Agrawal
 * @group             : 
 * @last modified on  : 05-28-2021
 * @last modified by  : Komal Sonsale
 * Modifications Log 
 * Ver   Date         Author          Modification
 * 1.0   04-12-2021   Dhruv Agrawal   Initial Version
**/

@isTest
public class MDM_CustomerLandingTriggerTest {
    @testSetup static void setup() {  
        MDM_TestDataFactory.createTestApplicationConfig();
    }
    
    @isTest
    public static void customerLandingTest(){
        MDM_Data_Quality__c dataQuality = new MDM_Data_Quality__c(
            Name = 'Customer Landing  Name',
           // MDM_Field_Label__c = 'Customer Name',
            MDM_Field_API_Name__c = 'MDM_Customer_Name__c',
            MDM_Object__c = 'MDM_Customer_Landing__c'
        );
        insert dataQuality;      
        system.assert(dataQuality.Id != null, 'dataQuality.id is not NULL');
        MDM_Validation_Rule__c validationRule= new MDM_Validation_Rule__c(
            Name='Required',
            MDM_Required__c = true
        );
        insert validationRule;
        system.assert(validationRule.Id != null, 'validationRule.id is not NULL');
        MDM_Data_Validation_Rule__c junctionObject = new MDM_Data_Validation_Rule__c(
            MDM_Data_Quality__c=dataQuality.id,
            MDM_Validation_Rule__c=validationRule.id
        );
        insert junctionObject;
        system.assert(junctionObject.Id != null, 'junctionObject.id is not NULL');  
        MDM_Data_Transformation__c dataTransformation = new MDM_Data_Transformation__c(
            Name = 'Customer Name Transformation'
        );
        insert dataTransformation;
        system.assert(dataTransformation.Id != null, 'dataTransformation.id is not NULL');
        MDM_Data_Transformation_Rule__c dataTransformationRule = new MDM_Data_Transformation_Rule__c(
            Name = 'Customer Name Transformation',
            MDM_Is_Title_Case__c = true,
            MDM_Data_Quality__c = dataQuality.ID,
            MDM_Data_Transformation__c = dataTransformation.ID
        );
        insert dataTransformationRule;
        system.assert(dataTransformationRule.Id != null, 'dataTransformationRule.id is not NULL');
        MDM_Attribute_Transformation_Item__c attributeItem = new MDM_Attribute_Transformation_Item__c(
            MDM_Data_Transformation__c = dataTransformation.ID,
            MDM_New_Value__c = 'CORP',
            MDM_Old_Value__c = 'corp.',
            MDM_Type__c = 'Word',
             MDM_Case_Sensitive__c = false
        );
        insert attributeItem;
        system.assert(attributeItem.Id != null, 'attributeItem.id is not NULL');
        MDM_Attribute_Transformation_Item__c attributeItem1 = new MDM_Attribute_Transformation_Item__c(
            MDM_Data_Transformation__c = dataTransformation.ID,
            MDM_New_Value__c = 'CORP',
            MDM_Old_Value__c = 'corp.',
            MDM_Type__c = 'Anywhere',
            MDM_Case_Sensitive__c = false
        );
        insert attributeItem1;
        
        MDM_Attribute_Transformation_Item__c attributeItem2 = new MDM_Attribute_Transformation_Item__c(
            MDM_Data_Transformation__c = dataTransformation.ID,
            MDM_New_Value__c = 'CORP',
            MDM_Old_Value__c = 'corp.',
            MDM_Type__c = 'Word',
            MDM_Case_Sensitive__c = true
        );
        insert attributeItem2;
        
        MDM_Attribute_Transformation_Item__c attributeItem3 = new MDM_Attribute_Transformation_Item__c(
            MDM_Data_Transformation__c = dataTransformation.ID,
            MDM_New_Value__c = 'CORP',
            MDM_Old_Value__c = 'corp.',
            MDM_Type__c = 'Anywhere',
            MDM_Case_Sensitive__c = true
        );
        insert attributeItem3;
        
        MDM_Customer_Landing__c custLanding = new MDM_Customer_Landing__c( 
            MDM_Customer_Name__c = 'NESTLE corp.',
            MDM_Contact_JSON__c= '[ { \"contactName\":\"John\", \"suffix\":\"Jr.\", \"title\":\"Customer Success Manager\",'+
            ' \"status\":\"status\", \"phone\":\"1234567890 - x578\", \"fax\":\"1234567890\", \"email\":\"abc@def.com\",'+
            ' \"addresses\":[ { \"address1\":\"address1\", \"address2\":\"address2\", \"address3\":\"address3\",'+
            ' \"addressType\":\"Buying\", \"city\":\"city\", \"country\":\"country\", \"state\":\"state\",'+
            ' \"countryCode\":\"countryCode\", \"zipcode\":\"zipcode\", \"phone\":\"1234567890 - x578\", \"extension\":\"extension\",'+
            ' \"fax\":\"1234567890\", \"email\":\"abc@def.com\", \"description\":\"description\" } ] }, { \"contactName\":\"John\",'+
            ' \"suffix\":\"Jr.\", \"title\":\"Customer Success Manager\", \"status\":\"status\", \"phone\":\"1234567890 - x578\",'+
            ' \"fax\":\"1234567890\", \"email\":\"abc@def.com\" }, { \"addresses\":[ { \"address1\":\"address1 ave str\",'+
            ' \"address2\":\"address2\", \"address3\":\"address3\", \"addressType\":\"Billing\", \"city\":\"city\",'+
            ' \"country\":\"country\", \"state\":\"state\", \"countryCode\":\"countryCode\", \"zipcode\":\"zipcode\",'+
            ' \"phone\":\"1234567890 - x578\", \"extension\":\"extension\", \"fax\":\"1234567890\", \"email\":\"abc@def.com\",'+
            ' \"description\":\"description\" } ] } ]',
            MDM_Source_System_Id__c= '8796',
            //MDM_Account_Type__c= 'Individual',
            MDM_Source_System__c= 'Bridge',
            MDM_Industry_Type__c = 'FINANCIAL',
            MDM_Customer_Status__c= 'Active'
        );
        MDM_DataTransformationService.dataTransformation(new List<MDM_Customer_Landing__c> {custLanding});
        insert custLanding;
        custLanding = new MDM_Customer_Landing__c( 
            MDM_Customer_Name__c= 'NESTLE',
            MDM_Contact_JSON__c= '[ { \"contactName\":\"John\", \"suffix\":\"Jr.\", \"title\":\"Customer Success Manager\",'+
            ' \"status\":\"status\", \"phone\":\"1234567890 - x578\", \"fax\":\"1234567890\", \"email\":\"abc@def.com\",'+
            ' \"addresses\":[ { \"address1\":\"address1\", \"address2\":\"address2\", \"address3\":\"address3\",'+
            ' \"addressType\":\"Buying\", \"city\":\"city\", \"country\":\"country\", \"state\":\"state\",'+
            ' \"countryCode\":\"countryCode\", \"zipcode\":\"zipcode\", \"phone\":\"1234567890 - x578\", \"extension\":\"extension\",'+
            ' \"fax\":\"1234567890\", \"email\":\"abc@def.com\", \"description\":\"description\" } ] }, { \"contactName\":\"John\",'+
            ' \"suffix\":\"Jr.\", \"title\":\"Customer Success Manager\", \"status\":\"status\", \"phone\":\"1234567890 - x578\",'+
            ' \"fax\":\"1234567890\", \"email\":\"abc@def.com\" }, { \"addresses\":[ { \"address1\":\"address1 ave str\",'+
            ' \"address2\":\"address2\", \"address3\":\"address3\", \"addressType\":\"Billing\", \"city\":\"city\",'+
            ' \"country\":\"country\", \"state\":\"state\", \"countryCode\":\"countryCode\", \"zipcode\":\"zipcode\",'+
            ' \"phone\":\"1234567890 - x578\", \"extension\":\"extension\", \"fax\":\"1234567890\", \"email\":\"abc@def.com\",'+
            ' \"description\":\"description\" } ] } ]',
            MDM_Source_System_Id__c= '8796',
            //MDM_Account_Type__c= 'Individual',
            MDM_Source_System__c= 'Bridge',
            MDM_Customer_Status__c= 'Active',
             MDM_Industry_Type__c = 'FINANCIAL',
            MDM_Source_LastModified__c= '2020-01-27T22:57:13'
        );
        insert custLanding;

        MDM_Customer_Landing__c custLanding1 = new MDM_Customer_Landing__c( 
            MDM_Customer_Name__c= 'NESTLE1',
            MDM_Contact_JSON__c= '[ { \"contactName\":\"John\", \"suffix\":\"Jr.\", \"title\":\"Customer Success Manager\",'+
            ' \"status\":\"status\", \"phone\":\"1234567890 - x578\", \"fax\":\"1234567890\", \"email\":\"abc@def.com\",'+
            ' \"addresses\":[ { \"address1\":\"address1\", \"address2\":\"address2\", \"address3\":\"address3\",'+
            ' \"addressType\":\"Buying\", \"city\":\"city\", \"country\":\"country\", \"state\":\"state\",'+
            ' \"countryCode\":\"countryCode\", \"zipcode\":\"zipcode\", \"phone\":\"1234567890 - x578\", \"extension\":\"extension\",'+
            ' \"fax\":\"1234567890\", \"email\":\"abc@def.com\", \"description\":\"description\" } ] }, { \"contactName\":\"John\",'+
            ' \"suffix\":\"Jr.\", \"title\":\"Customer Success Manager\", \"status\":\"status\", \"phone\":\"1234567890 - x578\",'+
            ' \"fax\":\"1234567890\", \"email\":\"abc@def.com\" }, { \"addresses\":[ { \"address1\":\"address1 ave str\",'+
            ' \"address2\":\"address2\", \"address3\":\"address3\", \"addressType\":\"Billing\", \"city\":\"city\",'+
            ' \"country\":\"country\", \"state\":\"state\", \"countryCode\":\"countryCode\", \"zipcode\":\"zipcode\",'+
            ' \"phone\":\"1234567890 - x578\", \"extension\":\"extension\", \"fax\":\"1234567890\", \"email\":\"abc@def.com\",'+
            ' \"description\":\"description\" } ] } ]',
            MDM_Source_System_Id__c= '8796',
           // MDM_Account_Type__c= 'Individual',
            MDM_Source_System__c= 'System',
             MDM_Industry_Type__c = 'FINANCIAL',
            MDM_Customer_Status__c= 'Inactive'
        );
        insert custLanding1;
        custLanding1.MDM_Processing_Status__c='Rejected';
        List<MDM_Customer_Landing__c> customerLandingList = new List<MDM_Customer_Landing__c>();
        customerLandingList.add(custLanding1);
        MDM_SalesforceUitility.apexDMLHandler(customerLandingList, 'MDM_Customer_Landing__c', 'update');
        MDM_SalesforceUitility.apexDMLHandler(customerLandingList, 'MDM_Customer_Landing__c', 'delete');
        MDM_Customer_Landing__c custLanding2 = new MDM_Customer_Landing__c( 
            MDM_Customer_Name__c= 'NESTLE2',
            MDM_Contact_JSON__c= '[ { \"contactName\":\"John\", \"suffix\":\"Jr.\", \"title\":\"Customer Success Manager\",'+
            ' \"status\":\"status\", \"phone\":\"1234567890 - x578\", \"fax\":\"1234567890\", \"email\":\"abc@def.com\",'+
            ' \"addresses\":[ { \"address1\":\"address1\", \"address2\":\"address2\", \"address3\":\"address3\",'+
            ' \"addressType\":\"Buying\", \"city\":\"city\", \"country\":\"country\", \"state\":\"state\", \"countryCode\":\"countryCode\",'+
            ' \"zipcode\":\"zipcode\", \"phone\":\"1234567890 - x578\", \"extension\":\"extension\", \"fax\":\"1234567890\",'+
            ' \"email\":\"abc@def.com\", \"description\":\"description\" } ] }, { \"contactName\":\"John\", \"suffix\":\"Jr.\",'+
            ' \"title\":\"Customer Success Manager\", \"status\":\"status\", \"phone\":\"1234567890 - x578\", \"fax\":\"1234567890\",'+
            ' \"email\":\"abc@def.com\" }, { \"addresses\":[ { \"address1\":\"address1 ave str\", \"address2\":\"address2\",'+
            ' \"address3\":\"address3\", \"addressType\":\"Billing\", \"city\":\"city\", \"country\":\"country\", \"state\":\"state\",'+
            ' \"countryCode\":\"countryCode\", \"zipcode\":\"zipcode\", \"phone\":\"1234567890 - x578\", \"extension\":\"extension\",'+
            ' \"fax\":\"1234567890\", \"email\":\"abc@def.com\", \"description\":\"description\" } ] } ]',
           // MDM_Account_Type__c= 'Individual',
            MDM_Source_System__c= 'Bridge',
            MDM_Source_System_ID__c='4846',
             MDM_Industry_Type__c = 'FINANCIAL',
            MDM_Source_LastModified__c= '2020-01-27T22:57:13'
        );
        insert custLanding2;
        
        MDM_Customer_Landing__c custLanding3 = new MDM_Customer_Landing__c( 
            MDM_Contact_JSON__c= '[ { \"contactName\":\"John\", \"suffix\":\"Jr.\", \"title\":\"Customer Success Manager\",'+
            ' \"status\":\"status\", \"phone\":\"1234567890 - x578\", \"fax\":\"1234567890\", \"email\":\"abc@def.com\",'+
            ' \"addresses\":[ { \"address1\":\"address1\", \"address2\":\"address2\", \"address3\":\"address3\",'+
            ' \"addressType\":\"Buying\", \"city\":\"city\", \"country\":\"country\", \"state\":\"state\", \"countryCode\":\"countryCode\",'+
            ' \"zipcode\":\"zipcode\", \"phone\":\"1234567890 - x578\", \"extension\":\"extension\", \"fax\":\"1234567890\",'+
            ' \"email\":\"abc@def.com\", \"description\":\"description\" } ] }, { \"contactName\":\"John\", \"suffix\":\"Jr.\",'+
            ' \"title\":\"Customer Success Manager\", \"status\":\"status\", \"phone\":\"1234567890 - x578\", \"fax\":\"1234567890\",'+
            ' \"email\":\"abc@def.com\" }, { \"addresses\":[ { \"address1\":\"address1 ave str\", \"address2\":\"address2\",'+
            ' \"address3\":\"address3\", \"addressType\":\"Billing\", \"city\":\"city\", \"country\":\"country\", \"state\":\"state\",'+
            ' \"countryCode\":\"countryCode\", \"zipcode\":\"zipcode\", \"phone\":\"1234567890 - x578\", \"extension\":\"extension\",'+
            ' \"fax\":\"1234567890\", \"email\":\"abc@def.com\", \"description\":\"description\" } ] } ]',
           // MDM_Account_Type__c= 'Individual',
            MDM_Source_System__c= 'Bridge',
             MDM_Industry_Type__c = 'FINANCIAL',
            MDM_Source_System_ID__c='4841'
        );
        insert custLanding3;
        MDM_CustomerTransformationService.mapData(custLanding); 
        MDM_CustomerTransformationService.mapData(custLanding2);
        MDM_CustomerTransformationService.createSourceCustomers(new List<MDM_Customer_Landing__c> {custLanding2});

        MDM_Customer__c customer = new MDM_Customer__c(
            Name = 'Test',
            MDM_Industry_Type__c = 'FINANCIAL'           
            // MDM_Account_Type__c = 'Individual'
        );
        insert customer;
        
        custLanding1 = new MDM_Customer_Landing__c( 
            MDM_Customer_Name__c= 'NESTLE',
            MDM_Contact_JSON__c= '[ { \"contactName\":\"John\", \"suffix\":\"Jr.\", \"title\":\"Customer Success Manager\",'+
            ' \"status\":\"status\", \"phone\":\"1234567890 - x578\", \"fax\":\"1234567890\", \"email\":\"abc@def.com\",'+
            ' \"addresses\":[ { \"address1\":\"address1\", \"address2\":\"address2\", \"address3\":\"address3\",'+
            ' \"addressType\":\"Buying\", \"city\":\"city\", \"country\":\"country\", \"state\":\"state\",'+
            ' \"countryCode\":\"countryCode\", \"zipcode\":\"zipcode\", \"phone\":\"1234567890 - x578\", \"extension\":\"extension\",'+
            ' \"fax\":\"1234567890\", \"email\":\"abc@def.com\", \"description\":\"description\" } ] }, { \"contactName\":\"John\",'+
            ' \"suffix\":\"Jr.\", \"title\":\"Customer Success Manager\", \"status\":\"status\", \"phone\":\"1234567890 - x578\",'+
            ' \"fax\":\"1234567890\", \"email\":\"abc@def.com\" }, { \"addresses\":[ { \"address1\":\"address1 ave str\",'+
            ' \"address2\":\"address2\", \"address3\":\"address3\", \"addressType\":\"Billing\", \"city\":\"city\",'+
            ' \"country\":\"country\", \"state\":\"state\", \"countryCode\":\"countryCode\", \"zipcode\":\"zipcode\",'+
            ' \"phone\":\"1234567890 - x578\", \"extension\":\"extension\", \"fax\":\"1234567890\", \"email\":\"abc@def.com\",'+
            ' \"description\":\"description\" } ] } ]',
            MDM_Source_System_Id__c= '8796',
           // MDM_Account_Type__c= 'Individual',
            MDM_Source_System__c= 'Bridge',
            MDM_Customer_Status__c= 'Inactive',
            MDM_Id__c = 'ADV0000009'
        );
        insert custLanding1;
        MDM_LightningComponentService.getStagingRecord([SELECT ID FROM MDM_Customer_Staging__c LIMIT 1].Id);
        custLanding1 = new MDM_Customer_Landing__c( 
            MDM_Customer_Name__c= 'NESTLE',
            MDM_Contact_JSON__c= '[ { \"contactName\":\"John\", \"suffix\":\"Jr.\", \"title\":\"Customer Success Manager\",'+
            ' \"status\":\"status\", \"phone\":\"1234567890 - x578\", \"fax\":\"1234567890\", \"email\":\"abc@def.com\",'+
            ' \"addresses\":[ { \"address1\":\"address1\", \"address2\":\"address2\", \"address3\":\"address3\",'+
            ' \"addressType\":\"Buying\", \"city\":\"city\", \"country\":\"country\", \"state\":\"state\",'+
            ' \"countryCode\":\"countryCode\", \"zipcode\":\"zipcode\", \"phone\":\"1234567890 - x578\", \"extension\":\"extension\",'+
            ' \"fax\":\"1234567890\", \"email\":\"abc@def.com\", \"description\":\"description\" } ] }, { \"contactName\":\"John\",'+
            ' \"suffix\":\"Jr.\", \"title\":\"Customer Success Manager\", \"status\":\"status\", \"phone\":\"1234567890 - x578\",'+
            ' \"fax\":\"1234567890\", \"email\":\"abc@def.com\" }, { \"addresses\":[ { \"address1\":\"address1 ave str\",'+
            ' \"address2\":\"address2\", \"address3\":\"address3\", \"addressType\":\"Billing\", \"city\":\"city\",'+
            ' \"country\":\"country\", \"state\":\"state\", \"countryCode\":\"countryCode\", \"zipcode\":\"zipcode\",'+
            ' \"phone\":\"1234567890 - x578\", \"extension\":\"extension\", \"fax\":\"1234567890\", \"email\":\"abc@def.com\",'+
            ' \"description\":\"description\" } ] } ]',
            MDM_Source_System_Id__c= '8736',
            MDM_Source_System__c= 'Bridge',
            MDM_Customer_Status__c= 'Inactive'
        );
           	custLanding2 = new MDM_Customer_Landing__c( 
            MDM_Customer_Name__c= 'NESTLE',
            MDM_Contact_JSON__c= '[ { \"contactName\":\"John\", \"suffix\":\"Jr.\", \"title\":\"Customer Success Manager\",'+
            ' \"status\":\"status\", \"phone\":\"1234567890 - x578\", \"fax\":\"1234567890\", \"email\":\"abc@def.com\",'+
            ' \"addresses\":[ { \"address1\":\"address1\", \"address2\":\"address2\", \"address3\":\"address3\",'+
            ' \"addressType\":\"Buying\", \"city\":\"city\", \"country\":\"country\", \"state\":\"state\",'+
            ' \"countryCode\":\"countryCode\", \"zipcode\":\"zipcode\", \"phone\":\"1234567890 - x578\", \"extension\":\"extension\",'+
            ' \"fax\":\"1234567890\", \"email\":\"abc@def.com\", \"description\":\"description\" } ] }, { \"contactName\":\"John\",'+
            ' \"suffix\":\"Jr.\", \"title\":\"Customer Success Manager\", \"status\":\"status\", \"phone\":\"1234567890 - x578\",'+
            ' \"fax\":\"1234567890\", \"email\":\"abc@def.com\" }, { \"addresses\":[ { \"address1\":\"address1 ave str\",'+
            ' \"address2\":\"address2\", \"address3\":\"address3\", \"addressType\":\"Billing\", \"city\":\"city\",'+
            ' \"country\":\"country\", \"state\":\"state\", \"countryCode\":\"countryCode\", \"zipcode\":\"zipcode\",'+
            ' \"phone\":\"1234567890 - x578\", \"extension\":\"extension\", \"fax\":\"1234567890\", \"email\":\"abc@def.com\",'+
            ' \"description\":\"description\" } ] } ]',
            MDM_Source_System_Id__c= '8796',
            MDM_Source_System__c= 'Bridge',
            MDM_Customer_Status__c= 'Active',
            MDM_Id__c = 'ADV00000011',
            MDM_Processing_Status__c = 'Rejected'
        );
       // insert custLanding2;
        List<UserLicense> ulics=[Select u.Id From UserLicense u where Name like 'Chatter Free'];
		User users=[Select Id,Name,ProfileId from User u where u.ProfileId in (Select Id From Profile p where p.UserLicenseId in :ulics)limit 1];
        User runUsr = [select name, id, profileId from User where id = :users.id limit 1];
        List<MDM_Customer_Landing__c> custLandingList = new List<MDM_Customer_Landing__c>();
        custLandingList.add(custLanding1);
        custLandingList.add(custLanding2);
        //custLandingList.add(custLanding3);
        try{
           	System.runAs(runUsr){
            insert custLandingList;	
            }
        }
      	catch(Exception e) {
            system.debug(LoggingLevel.ERROR, 'Exception: ' + e.getMessage());
        }
      
          insert custLandingList;
        try{
            System.runAs(runUsr){
            for(MDM_Customer_Landing__c custLand : custLandingList){
                    custLand.MDM_Processing_Status__c = 'New';
                    custLand.MDM_Account_Type__c = 'Business Account';
               }
             update custLandingList;
            }
        }
        catch(Exception e) {
            system.debug(LoggingLevel.ERROR, 'Exception: ' + e.getMessage());
        }

       try {
            System.runAs(runUsr){
            delete custLandingList;
            }
       } catch(Exception e) {
            system.debug(LoggingLevel.ERROR, 'Exception: ' + e.getMessage());
        }
    }
    
}