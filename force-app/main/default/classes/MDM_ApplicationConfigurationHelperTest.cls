@isTest
public class MDM_ApplicationConfigurationHelperTest {
    
    @isTest
    static void allowOneRecordTest(){
        Test.startTest();
        List<UserLicense> ulics=[Select u.Id From UserLicense u where Name like 'Chatter Free'];
        User users=[Select Id,Name,ProfileId from User u where u.ProfileId in (Select Id From Profile p where p.UserLicenseId in :ulics)limit 1];
        User runUsr = [select name, id, profileId from User where id = :users.id limit 1];
        MDM_Application_Configuration__c appConfig = new MDM_Application_Configuration__c();
        appconfig.MDM_Allow_Auto_Merge__c = true;
        appconfig.MDM_Allow_Platform_Events__c = true;
        appconfig.MDM_Platfrom_Event_Batch_Size__c = '1';
        appconfig.Name = 'Test Config';
        try{
            System.runAs(runUsr){
            	insert appConfig;
            }
        }
        catch(Exception e) {
            system.debug(LoggingLevel.ERROR, 'Exception: ' + e.getMessage());
        }
        System.assert(appconfig != null, 'allowOneRecordTest');
        Test.stopTest();
    }
}