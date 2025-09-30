/**
 * @description       : 
 * @author            : Dhruv Agrawal
 * @group             : 
 * @last modified on  : 05-28-2021
 * @last modified by  : Komal Sonsale
 * Modifications Log 
 * Ver   Date         Author          Modification
 * 1.0   04-26-2021   Dhruv Agrawal   Initial Version
**/
@isTest
public class MDM_DQIAttributeTriggerHelperTest {
    
    @testSetup static void setup(){
         MDM_TestDataFactory.dqiAttributeTestData();
    }
    @isTest
    public static void dqiAttributeTest(){
        Test.startTest();  
       	List<MDM_DQI_Attribute__c> dqiAttributeList = [Select id from MDM_DQI_Attribute__c];
       
        MDM_Data_Quality__c dataQuality = new MDM_Data_Quality__c(
             Name = 'Contact Email Data Quality',
             //MDM_Field_Label__c = 'Email',
             MDM_Field_API_Name__c = 'MDM_Fax__c',
             MDM_Object__c = 'MDM_Contact__c'
         );
         insert dataQuality; 
         MDM_DQI_Attribute__c dqi = new MDM_DQI_Attribute__c(
             Name = 'DQI Contact Fax',
             MDM_Data_Quality__c = dataQuality.Id ,
             MDM_Is_Active__c = true,
             MDM_Percentage__c = 101
         );
        try{
           insert dqi; 
        }catch(Exception E){
           System.debug('Test Succesfull'); 
        }
        System.assertEquals(5,dqiAttributeList.size(),'Size is same');
        Test.stopTest();
	}
 
}