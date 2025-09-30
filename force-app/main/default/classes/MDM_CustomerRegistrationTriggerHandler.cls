/**
 * @description       : 
 * @author            : Dhruv Agrawal
 * @group             : 
 * @last modified on  : 05-28-2021
 * @last modified by  : Dhruv Agrawal
 * Modifications Log 
 * Ver   Date         Author          Modification
 * 1.0   05-28-2021   Dhruv Agrawal   Initial Version
**/
public class MDM_CustomerRegistrationTriggerHandler {
    
   
    /**
    * @description 
    * @author Dhruv Agrawal | 05-28-2021 
    * @param triggerWrapper 
    **/
    public static void triggerConditionForTriggerHelperInvoke(MDM_TriggerWrapper triggerWrapper){
        MDM_Customer_Registration__c oldCustReg = new MDM_Customer_Registration__c();
        MDM_Customer_Registration__c newCustReg = new MDM_Customer_Registration__c();
        List<String> regId = new List<String>();
        if(triggerWrapper.isAfter && triggerWrapper.isUpdate) {
            for(sObject customerRegistration : triggerWrapper.newSObjectList) {
                newCustReg = (MDM_Customer_Registration__c)customerRegistration;
                if(newCustReg.MDM_Mass_Approval_Status__c == 'Approved') {
                    oldCustReg = (MDM_Customer_Registration__c)triggerWrapper.oldSObjectMap.get(newCustReg.Id);
                    if(oldCustReg.MDM_Mass_Approval_Status__c != newCustReg.MDM_Mass_Approval_Status__c) {
                        regId.add(String.valueOf(newCustReg.Id));
                    }
                }
            }
            if(regId.size()>0) { 
                MDM_RegistrationToStagingProcessHelper.createCustomerStagings(regId); 
            }
        }   
    }  
}