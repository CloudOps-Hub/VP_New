/**
 * @description       : Customer Landing Trigger Helper
 * @author            : Komal Sonsale
 * @group             : 
 * @last modified on  : 04-28-2021
 * @last modified by  : Komal Sonsale
 * Modifications Log 
 * Ver   Date         Author          Modification
 * 1.0   03-19-2021   Komal Sonsale   Initial Version
**/
@SuppressWarnings('PMD.ExcessivePublicCount,PMD.CyclomaticComplexity,PMD.CognitiveComplexity')
public with sharing class MDM_CustomerLandingTriggerHelper {
  
    /**
    * @description :based on the condition from trigger wrapper will perform different functions
    * @author Komal Sonsale | 03-19-2021 
    * @param triggerWrapper 
    **/
    public static void triggerConditionForMethodInvoke(MDM_TriggerWrapper triggerWrapper){
        if(triggerWrapper.isBefore) {
            if(triggerWrapper.isInsert) { beforeInsert(triggerWrapper); }
            else if(triggerWrapper.isUpdate) { beforeUpdate(triggerWrapper); }
            else if(triggerWrapper.isDelete) { deleteObjectRecord(triggerWrapper); }
        }
        if(triggerWrapper.isAfter) {
            if(triggerWrapper.isInsert) { afterInsert(triggerWrapper); }
            else if(triggerWrapper.isUpdate) { afterUpdate(triggerWrapper); }
        }
    }   
        
    static void beforeInsert(MDM_TriggerWrapper triggerWrapper) {
        //-- FSL check on Customer Landing --
        if(!MDM_FLsUtils.flsCheck(new MDM_Customer_Landing__c(),'create')) {
            for(sObject custLanding : triggerWrapper.newSObjectList) {
            	custLanding.addError('You dont have access to all Customer Landing fields');
        	}
        }
        for(sObject custLanding : triggerWrapper.newSObjectList) {
            custLanding.put('MDM_Processing_Status__c', 'New');
        }
        MDM_CustomerValidationService.performDataValidationRule(triggerWrapper.newSObjectList);
        //validateMdmIds(triggerWrapper);
    }

    static void beforeUpdate(MDM_TriggerWrapper triggerWrapper) {
        //-- FSL check on Customer Landing --
        if(!MDM_FLsUtils.flsCheck(new MDM_Customer_Landing__c(),'update')) { for(sObject custLanding : triggerWrapper.newSObjectList) { custLanding.addError('You dont have access to all Customer Landing fields');
        	}
        }
        
        List<sObject> filteredCustomerLandings = new List<MDM_Customer_Landing__c>();
        for(sObject custLanding : triggerWrapper.newSObjectList) {
            if(custLanding.get('MDM_Processing_Status__c') == 'Rejected') { 
                custLanding.put('MDM_Processing_Status__c', 'New'); 
            }
            if(custLanding.get('MDM_Processing_Status__c') != 'Processed') {
                custLanding.put('MDM_Rejection_codes__c', '');
                filteredCustomerLandings.add(custLanding);
            }
        }
        MDM_CustomerValidationService.performDataValidationRule(filteredCustomerLandings);
        //validateMdmIds(triggerWrapper);
    }
    
    /**
    * @description :called before delete; will not allow processed records to be deleted.
    * @author Dhruv Agrawal | 03-19-2021 
    * @param triggerWrapper 
    **/
    public static void deleteObjectRecord(MDM_TriggerWrapper triggerWrapper) {
		//-- FSL check on Customer Landing --
        if(!MDM_FLsUtils.flsCheck(new MDM_Customer_Landing__c(),'create')) { for(sObject custLanding : triggerWrapper.newSObjectList) {custLanding.addError('You dont have access to all Customer Landing fields');
        	}
        }
        for(SObject landingRecord : triggerWrapper.oldSObjectList) {
            if(landingRecord.get('MDM_Processing_Status__c')=='Processed') { landingRecord.addError('Processed Requests can not be deleted'); } 
        }
        
    } 

    /**
    * @description :called afetr Insert.
    * @author Dhruv Agrawal | 03-23-2021 
    * @param triggerWrapper 
    **/
    static void afterInsert(MDM_TriggerWrapper triggerWrapper) {
		//-- FSL check on Customer Staging --
        if(!MDM_FLsUtils.flsCheck(new MDM_Customer_Staging__c(),'create')) { for(sObject custLanding : triggerWrapper.newSObjectList) {custLanding.addError('You dont have access to all Customer Staging fields');
        	}
        }
        List<sObject> customersForStaging = new List<MDM_Customer_Landing__c>();
        for(sObject custLanding : triggerWrapper.newSObjectList) {
            if(custLanding.get('MDM_Processing_Status__c') == 'Validated') { customersForStaging.add(custLanding); }
        }
        	MDM_LightningComponentService.migrateLandingToStaging(customersForStaging);
    }

    /**
    * @description :called afetr Update.
    * @author Dhruv Agrawal | 03-23-2021 
    * @param triggerWrapper 
    **/
    static void afterUpdate(MDM_TriggerWrapper triggerWrapper) {

        //-- CRUD check on Customer Staging --
        if(!(Schema.sObjectType.MDM_Customer_Staging__c.isCreateable() &&
             Schema.sObjectType.MDM_Customer_Staging__c.isUpdateable())) { for(sObject custLanding : triggerWrapper.newSObjectList) {custLanding.addError('You dont have access to all Customer Staging object');
                }
        }

        //-- FSL check on Customer Staging --
        if(!(MDM_FLsUtils.flsCheck(new MDM_Customer_Staging__c(),'update') && 
             MDM_FLsUtils.flsCheck(new MDM_Customer_Staging__c(),'create'))) {  for(sObject custLanding : triggerWrapper.newSObjectList) { custLanding.addError('You dont have access to all Customer Staging fields');
        	}
        }
        List<sObject> customersForStaging = new List<MDM_Customer_Landing__c>();
        for(sObject custLanding : triggerWrapper.newSObjectList) {
            if( custLanding.get('MDM_Processing_Status__c') == 'Validated' && triggerWrapper.oldSObjectMap.get(custLanding.id).get('MDM_Processing_Status__c') != 'Validated'){ customersForStaging.add(custLanding); }
        }
        	MDM_LightningComponentService.migrateLandingToStaging(customersForStaging);
    }


}