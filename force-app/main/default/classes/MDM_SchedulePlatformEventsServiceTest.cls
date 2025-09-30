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
public class MDM_SchedulePlatformEventsServiceTest {
    @testSetup static void setup() {
         MDM_TestDataFactory.createTestApplicationConfig(); 
    }
    /**
    * @description 
    * @author Komal Sonsale | 05-27-2021 
    **/
    public static testMethod void testschedule() {
        Test.StartTest();
        MDM_SchedulePlatformEventsService sh1 = new MDM_SchedulePlatformEventsService();
        String sch = '0 0 23 * * ?'; 
        String jobId = system.schedule('Test Auto Merge Job Check', sch, sh1); 
        CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime
                            FROM CronTrigger WHERE id = :jobId];
        System.assertEquals(sch,ct.CronExpression,'Job is running');
        Test.stopTest(); 
    } 
    
}