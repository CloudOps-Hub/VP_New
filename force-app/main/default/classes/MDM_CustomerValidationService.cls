/**
 * @description       : 
 * @author            : Dhruv Agrawal
 * @group             : 
 * @last modified on  : 05-12-2021
 * @last modified by  : Komal Sonsale
 * Modifications Log 
 * Ver   Date         Author          Modification
 * 1.0   03-19-2021   Dhruv Agrawal   Initial Version
**/

public with sharing class MDM_CustomerValidationService {
    static List<String> fieldAPINames = new list<string>();

    /**
    * @description 
    * @author Anish Samant | 03-22-2021 
    * @param sObjectType 
    **/
    static void populateFieldAPIName(String sObjectType) {
        MDM_GeneraliseResult returnedFields = MDM_SchemaService.getFields(sObjectType);        
        for(MDM_SchemaService.FieldDescriptor field : (list<MDM_SchemaService.FieldDescriptor>)returnedFields.result){
            fieldAPINames.add(field.fieldName);
        }
    }

    /**
    * @description 
    * @author Anish Samant | 03-22-2021 
    * @param customerLandingData 
    **/
    static void validateCustomerLandingRecords(List<MDM_Customer_Landing__c> customerLandingData) {
        String objectType='MDM_Customer_Landing__c';
        populateFieldAPIName(objectType);
        List<MDM_Data_Validation_Rule__c> dataRules  = new List<MDM_Data_Validation_Rule__c>();
        
        //--   FSL Check for Data Validation Rule ---
        try
        {
            if(Schema.sObjectType.MDM_Data_Validation_Rule__c.isAccessible()) {
            
                dataRules = [SELECT  Name,MDM_Validation_Rule__r.MDM_Min_Length__c, MDM_Validation_Rule__r.MDM_Max_Length__c, 
                            MDM_Data_Quality__r.MDM_Field_Label__c, MDM_Validation_Rule__r.Name, MDM_Validation_Rule__r.MDM_Regular_Expression__c, 
                            MDM_Validation_Rule__r.MDM_Rejection_Message__c, MDM_Validation_Rule__r.MDM_Required__c,
                            MDM_Data_Quality__r.MDM_Field_Api_Name__c, MDM_Validation_Rule__r.MDM_Restrict_Picklist_Values__c,
                            MDM_Validation_Rule__r.MDM_Allowed_Values__c
                            FROM MDM_Data_Validation_Rule__c 
                            WHERE MDM_Data_Quality__r.MDM_Field_Api_Name__c IN: fieldAPINames 
                            AND MDM_Data_Quality__r.MDM_Object__c = :objectType WITH SECURITY_ENFORCED
                            ];
            }
            
        } catch( System.QueryException qe) {            
            for(MDM_Customer_Landing__c objLanding : customerLandingData) {
                objLanding.addError('You dont have access to all Validation Rule fields');
            }
        }
        //-- call Validation Service Class. --
        	
        for(MDM_Data_Validation_Rule__c dataVal : dataRules ) {
            for(MDM_Customer_Landing__c objLanding : customerLandingData){
                MDM_ValidationService.MDM_ValidationWrapper vw = new MDM_ValidationService.MDM_ValidationWrapper();
                vw.objectRecord = objLanding;
                vw.fieldApiName = dataVal.MDM_Data_Quality__r.MDM_Field_Api_Name__c;
                vw.fieldLabel = dataVal.MDM_Data_Quality__r.MDM_Field_Label__c;
                vw.rejectionCode = dataVal.MDM_Validation_Rule__r.Name;
                vw.regularExp = dataVal.MDM_Validation_Rule__r.MDM_Regular_Expression__c;
                vw.rejectionMsg = dataVal.MDM_Validation_Rule__r.MDM_Rejection_Message__c;
                vw.required = dataVal.MDM_Validation_Rule__r.MDM_Required__c;
                vw.minLength = dataVal.MDM_Validation_Rule__r.MDM_Min_Length__c;
                vw.maxLength = dataVal.MDM_Validation_Rule__r.MDM_Max_Length__c;
                vw.restrictPicklistValues = dataVal.MDM_Validation_Rule__r.MDM_Restrict_Picklist_Values__c;
                vw.acceptedValues = dataVal.MDM_Validation_Rule__r.MDM_Allowed_Values__c;
                String validateResult = MDM_ValidationService.Validate(vw);
                if(validateResult.length() > 0) {

                    objLanding.MDM_Rejection_codes__c = String.isBlank(objLanding.MDM_Rejection_codes__c) ? 
                        validateResult : objLanding.MDM_Rejection_codes__c + '\n' + validateResult;
                    
                    objLanding.MDM_Processing_Status__c = 'Rejected';
                }
            } 
        }
    }

    /**
    * @description : Validation Method for Customer Landing gets called from the MDM_CustomerLandingTrigger
    * @param  customerLandingData - The list of customer Landing Records.
    */ 
    public static void performDataValidationRule(List<MDM_Customer_Landing__c> customerLandingData){
        validateCustomerLandingRecords(customerLandingData);

        for(MDM_Customer_Landing__c objLanding : customerLandingData){
            objLanding.MDM_Rejection_codes__c = objLanding.MDM_Rejection_codes__c == NULL ? '' : objLanding.MDM_Rejection_codes__c;
        }        
        for(MDM_Customer_Landing__c custLanding : customerLandingData) {
            if(custLanding.MDM_Processing_Status__c == 'New') { custLanding.MDM_Processing_Status__c = 'Validated'; }
        }
    }
}