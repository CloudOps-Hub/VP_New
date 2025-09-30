/**
 * @description       : 
 * @author            : Dhruv Agrawal
 * @group             : 
 * @last modified on  : 05-28-2021
 * @last modified by  : Komal Sonsale
 * Modifications Log 
 * Ver   Date         Author          Modification
 * 1.0   03-23-2021   Dhruv Agrawal   Initial Version
**/

public with sharing class MDM_CustomerTransformationService {    
   
    /** 
     * @description : Copy Data from Customer Landing object to Customer Staging Object
     * @param customerLanding customer landing object used to create customer staging object
     * @return customerStaging
     */
    public static MDM_Customer_Staging__c mapData(MDM_Customer_Landing__c customerLanding){
        MDM_Customer_Staging__c customerStaging = new MDM_Customer_Staging__c();
            customerStaging.MDM_Description__c = customerLanding.MDM_Description__c;
            customerStaging.MDM_Id__c = customerLanding.MDM_Id__c;
            customerStaging.MDM_Customer_Status__c = customerLanding.MDM_Customer_Status__c;
            customerStaging.MDM_Account_Type__c = customerLanding.MDM_Account_Type__c;
            customerStaging.Name = customerLanding.MDM_Customer_Name__c;
            customerStaging.MDM_DOI_or_DOB__c = customerLanding.MDM_DOI_or_DOB__c;
            customerStaging.MDM_Industry_Type__c = customerLanding.MDM_Industry_Type__c;
            customerStaging.MDM_Source_System__c = customerLanding.MDM_Source_System__c;
            customerStaging.MDM_Customer_Id__c = customerLanding.MDM_Customer_Id__c;
            customerStaging.MDM_Customer_Type__c = customerLanding.MDM_Customer_Type__c;
            customerStaging.MDM_Phone__c = customerLanding.MDM_Phone__c;
            customerStaging.MDM_Email__c = customerLanding.MDM_Email__c;

        try{
            if (String.isNotBlank(customerLanding.MDM_Source_LastModified__c)) {
                String dateTimeString = customerLanding.MDM_Source_LastModified__c.replace('T',' ');
                customerStaging.MDM_Source_LastModified__c = DateTime.valueOf(dateTimeString);
            }
        } catch (Exception e) { 
            MDM_HandleCustomException.logException(e);
        }
        return customerStaging;
    }
   
    /** 
    * @description : Create source customer staging objects from customer landing objects
    * @param customerLandings customer landing objects used to create source customer staging objects
    * @return sourceCustomers
    */
    public static List<MDM_Source_Customer_Staging__c> createSourceCustomers(List<MDM_Customer_Landing__c> customerLandings) {
        system.debug(customerLandings.size());
        List<MDM_Source_Customer_Staging__c> sourceCustomers = new List<MDM_Source_Customer_Staging__c>();
        for(MDM_Customer_Landing__c customerLanding: customerLandings) {
            MDM_Source_Customer_Staging__c sourceCustomer = new MDM_Source_Customer_Staging__c();

            sourceCustomer.MDM_Account_Type__c = customerLanding.MDM_Account_Type__c;
            sourceCustomer.MDM_Source_System__c = customerLanding.MDM_Source_System__c;
            sourceCustomer.Name = customerLanding.MDM_Customer_Name__c;


                if(String.isNotBlank(customerLanding.MDM_Source_LastModified__c)){
                    String dateTimeString = customerLanding.MDM_Source_LastModified__c.replace('T',' ');
                    sourceCustomer.MDM_Source_LastModified__c = DateTime.valueOf(dateTimeString);}
          
           

            sourceCustomer.MDM_Source_System_Id__c = customerLanding.MDM_Source_System_Id__c; 
            sourceCustomer.MDM_Customer_Status__c=customerLanding.MDM_Customer_Status__c;
            sourceCustomer.MDM_Customer_Staging__c = customerLanding.MDM_Customer_Staging__c;
            sourceCustomers.add(sourceCustomer);
        }
        system.debug(sourceCustomers.size());
        return sourceCustomers;
    }
}