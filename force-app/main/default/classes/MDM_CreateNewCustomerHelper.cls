/**
 * @description       : 
 * @author            : Dhruv Agrawal
 * @group             : 
 * @last modified on  : 05-27-2021
 * @last modified by  : Komal Sonsale
 * Modifications Log 
 * Ver   Date         Author          Modification
 * 1.0   03-26-2021   Dhruv Agrawal   Initial Version
**/

public with sharing class MDM_CreateNewCustomerHelper {
     private static final String INSUFFICIENT_PRIVILEGE_ERROR = 'INSUFFICIENT_ACCESS_OR_READONLY';

    /** 
    * @description : CustomerModelWrapper class will contain wrapper of staging,source,customer record 
    *				 and List of contactIDs,addressIds
    */
    public class CustomerModelWrapper{
        public MDM_Customer_Staging__c stagingRecord;
        public MDM_Source_Customer_Staging__c sourceRecord;
        public MDM_Customer__c customerRecord;
        public list<string> contactIDs;
        public list<string> addressIDs; 
    }
    /**
    *  @description : insert records passed in customerModelWrapperJSON
    *  @param customerModelWrapperJSON
    *  @return MDM_GeneraliseResult
    */
    @AuraEnabled
    public static MDM_GeneraliseResult insertInCustomer(String customerModelWrapperJSON){
        MDM_GeneraliseResult finalResult=new MDM_GeneraliseResult();
        CustomerModelWrapper customerModelWrapper=(CustomerModelWrapper)JSON.deserialize(customerModelWrapperJSON,CustomerModelWrapper.class);
        sObject stagingRecord = customerModelWrapper.stagingRecord;
        sObject goldenRecord = (customerModelWrapper.customerRecord == null) ? (new MDM_Customer__c()) : customerModelWrapper.customerRecord;
        map<string,string> customerStagingFieldMap=new map<string,string>{
            'Name'=>'Name',
            'MDM_Account_Type__c'=>'MDM_Account_Type__c',
            'MDM_Description__c'=>'MDM_Description__c',
            'MDM_Customer_Status__c'=>'MDM_Customer_Status__c',
            'MDM_Source_LastModified__c' =>'MDM_Source_LastModified__c',
            'MDM_Record_Status__c' => 'MDM_Record_Status__c', 
            'MDM_Industry_Type__c' => 'MDM_Industry_Type__c',
            'MDM_DOI_or_DOB__c' => 'MDM_DOI_or_DOB__c',
            'MDM_Customer_Id__c' => 'MDM_Customer_Id__c',
            'MDM_Customer_Type__c' => 'MDM_Customer_Type__c',
            'MDM_Phone__c' => 'MDM_Phone__c',
            'MDM_Email__c' => 'MDM_Email__c'
         };
        
        Map<String,String> sourceSystemIdNameMap = new Map<String,String>();
        if(customerModelWrapper.customerRecord == null) {           
            for(string field: customerStagingFieldMap.keySet()){
                goldenRecord.put(field,stagingRecord.get(customerStagingFieldMap.get(field)));
            }            
            string recordType=string.valueOf(stagingRecord.get('MDM_Account_Type__c'));
            if(!string.isBlank(recordType)){
                goldenrecord.put('recordTypeId',
                                  string.valueOf(MDM_SalesforceUitility.getObjectRecordTypeId('MDM_Customer__c', recordType).result));
            }
        }else{
            //add existing sourceCustomers to map.
            stagingRecord = new MDM_Customer_Staging__c(Id = stagingRecord.Id);
            for(MDM_Source_Customer__c sourceCustomer : [SELECT Id,MDM_Source_System__c, MDM_Source_System_Id__c 
                                                        FROM MDM_Source_Customer__c 
                                                        WHERE MDM_Customer__c = :goldenRecord.Id WITH SECURITY_ENFORCED]){
                sourceSystemIdNameMap.put(sourceCustomer.MDM_Source_System_Id__c+sourceCustomer.MDM_Source_System__c, sourceCustomer.Id);
            }
        }        
        //used so this entire function works as one transaction.
        Savepoint transactionStart=Database.setSavepoint();
        try{
            if(Schema.sObjectType.MDM_Customer__c.isCreateable() && Schema.sObjectType.MDM_Customer__c.isUpdateable()){
                upsert (MDM_Customer__c)goldenRecord; 
    
            } else {
                finalResult.isSuccess=false;
            	finalResult.result='Insufficient Priviledge to update record';
                return finalResult;
            }           
            String goldenRecordId=goldenRecord.id;
            stagingRecord.put('MDM_Customer_Golden__c', goldenRecordId);
            stagingRecord.put('MDM_Processing_Status__c', 'Processed');
            MDM_Customer_Staging__c custStaging = [
                    SELECT id,MDM_Processing_Status__c,(
                        SELECT id,Name,MDM_Source_System__c,MDM_Source_System_ID__c,MDM_Source_LastModified__c,MDM_Customer_Status__c,MDM_Account_Type__c
                        FROM Source_Customer_Stagings__r
                    ),(
                        SELECT id,name,MDM_Address_1__c,MDM_Address_2__c,MDM_Address_3__c,MDM_City__c,MDM_State__c,
                        MDM_Country__c,MDM_Address_Type__c,MDM_Email__c,MDM_Phone__c,MDM_Contact_Staging__c,
                        MDM_Country_Code__c,MDM_Description_Notes__c,MDM_Zip_Code__c,MDM_Source_System_Id__c,
                        MDM_Extension__c,MDM_Fax__c,MDM_Contact_Staging__r.Name, MDM_Status__c,MDM_External_System_Name__c,
                        MDM_Source_System_Primary__c,MDM_Source_System_Address_Id__c,MDM_Source_LastModified__c,
                        MDM_Source_System_Verified__c 
                        FROM Address_Stagings__r WHERE id in: customerModelWrapper.addressIDs
                    ),(
                        SELECT id, Name, MDM_Phone__c, MDM_Email__c, MDM_Extension__c,MDM_Name_Suffix__c,MDM_Source_System_Id__c,
                        MDM_Status__c, MDM_Title__c, MDM_Fax__c, MDM_Source_System_Contact_Id__c, MDM_External_System_Name__c,
                        MDM_Source_LastModified__c 
                        FROM Contact_Stagings__r WHERE id in: customerModelWrapper.contactIDs
                    )
                    FROM MDM_Customer_Staging__c WHERE id=:stagingRecord.id WITH SECURITY_ENFORCED limit 1
                ];
            upsertSourceCustomer(custStaging.Source_Customer_Stagings__r, sourceSystemIdNameMap, goldenRecord);
            insertAddresses(custStaging, insertContact(custStaging.Contact_Stagings__r, goldenRecord), goldenRecord);                
            if(Schema.sObjectType.MDM_Customer_Staging__c.isCreateable()){
                update (MDM_Customer_Staging__c)stagingRecord;
            }            
            finalResult.result=goldenRecordId;
            finalResult.isSuccess=true;
        }catch(Exception e){
            Database.rollback(transactionStart);
            finalResult.isSuccess=false;
            if(e.getMessage().contains(INSUFFICIENT_PRIVILEGE_ERROR)) {
                finalResult.result = 'Insufficient Field Access';
            } else {
                finalResult.result=e.getMessage();
            }
            
        }
        return finalResult;
    } 
    /**
     * @description : This method will insert/update source customer records
     * @param srcCustStaging
     * @param sourceSystemIdNameMap
     * @param goldenRecordId
    */
    static void upsertSourceCustomer(List<MDM_Source_Customer_Staging__c> srcCustStaging, Map<String,String> sourceSystemIdNameMap,
                                    sObject goldenRecordId){  
        map<string,string> sourceCustomerFieldMap=new map<string,string>{
            'Name'=>'Name',
            'MDM_Source_System_Id__c'=>'MDM_Source_System_Id__c',
            'MDM_Source_LastModified__c' =>'MDM_Source_LastModified__c',
            'MDM_Customer_Status__c' => 'MDM_Customer_Status__c',
            'MDM_Source_System__c' => 'MDM_Source_System__c',
            'MDM_Account_Type__c' => 'MDM_Account_Type__c'
         };
        List<sObject> sourceCustomerList =new list<MDM_Source_Customer__c>();
        for(MDM_Source_Customer_Staging__c sourceRecord : srcCustStaging){
            sObject sourceCustomer = new MDM_Source_Customer__c();
            if(sourceSystemIdNameMap.containsKey(sourceRecord.MDM_Source_System_Id__c+sourceRecord.MDM_Source_System__c)){
                sourceCustomer.Id=sourceSystemIdNameMap.get(sourceRecord.MDM_Source_System_Id__c+sourceRecord.MDM_Source_System__c);
                sourceSystemIdNameMap.remove(sourceRecord.MDM_Source_System_Id__c+sourceRecord.MDM_Source_System__c);
            }
            for(string field: sourceCustomerFieldMap.keySet()){
                sourceCustomer.put(field,sourceRecord.get(sourceCustomerFieldMap.get(field)));
            }
            
            sourceCustomer.put('MDM_Customer__c',goldenRecordId.Id);
            sourceCustomerList.add(sourceCustomer);
        }
        
        if(sourceCustomerList.size() > 0 && Schema.sObjectType.MDM_Source_Customer__c.isCreateable() && 
            Schema.sObjectType.MDM_Source_Customer__c.isUpdateable()){
            upsert (List<MDM_Source_Customer__c>) sourceCustomerList;
       }
    }

   
    /**
     * @description : this method will insert contact records
     * @param conCustStaging
     * @param goldenRecordId
     * @return List<MDM_Contact__c>
    */
    static List<MDM_Contact__c> insertContact(List<MDM_Contact_Staging__c> conCustStaging, sObject goldenRecordId){
        list<sObject> contactList= new list<MDM_Contact__c>();
        map<string,string> contactFieldMap=new map<string,string>
        {
            'Name'=>'Name',
            'MDM_Email__c'=>'MDM_Email__c',
            'MDM_Extension__c'=>'MDM_Extension__c',
            'MDM_Fax__c'=>'MDM_Fax__c',
            'MDM_Name_Suffix__c'=>'MDM_Name_Suffix__c',
            'MDM_Phone__c'=>'MDM_Phone__c',
            'MDM_Status__c'=>'MDM_Status__c',
            'MDM_Title__c'=>'MDM_Title__c',
            'MDM_External_System_Name__c'=>'MDM_External_System_Name__c',
            'MDM_Source_System_Contact_Id__c'=>'MDM_Source_System_Contact_Id__c',
            'MDM_Source_LastModified__c' =>'MDM_Source_LastModified__c',
            'MDM_Source_System_Id__c' => 'MDM_Source_System_Id__c' 
         };
        for(MDM_Contact_Staging__c contact : conCustStaging){
            sObject newContact= new MDM_Contact__c();
            for(string field: contactFieldMap.keySet()){
                newContact.put(field,contact.get(contactFieldMap.get(field)));
            }
            newContact.put('MDM_Customer__c',goldenRecordId.Id);
            contactList.add(newContact);
        }
        if(contactList.size() > 0  && Schema.sObjectType.MDM_Contact__c.isCreateable()){
            insert (List<MDM_Contact__c>)contactList;
        } 
        return contactList;
    }
    
    /**
     * @description : This method will insert address records
     * @param custStaging
     * @param contactList
     * @param goldenRecordId
     */
    static void insertAddresses(MDM_Customer_Staging__c custStaging, List<MDM_Contact__c> contactList,sObject goldenRecordId){
        map<string,string> addressFieldMap=new map<string,string>{
            'MDM_Address_1__c'=>'MDM_Address_1__c',
            'MDM_Address_2__c'=>'MDM_Address_2__c',
            'MDM_Address_3__c'=>'MDM_Address_3__c',
            'MDM_Address_Type__c'=>'MDM_Address_Type__c',
            'MDM_City__c'=>'MDM_City__c',
            'MDM_Country__c'=>'MDM_Country__c',
            'MDM_Country_Code__c'=>'MDM_Country_Code__c', 
            'MDM_Email__c'=>'MDM_Email__c',
            'MDM_Extension__c'=>'MDM_Extension__c',
            'MDM_Fax__c'=>'MDM_Fax__c',
            'MDM_Phone__c'=>'MDM_Phone__c',
            'MDM_Description_Notes__c'=>'MDM_Description_Notes__c',
            'MDM_State__c'=>'MDM_State__c',
            'MDM_Zip_Code__c'=>'MDM_Zip_Code__c',
            'MDM_Status__c' => 'MDM_Status__c',
            'MDM_External_System_Name__c' => 'MDM_External_System_Name__c',
            'MDM_Source_System_Primary__c' => 'MDM_Source_System_Primary__c',
            'MDM_Source_System_Address_Id__c' => 'MDM_Source_System_Address_Id__c',
            'MDM_Source_LastModified__c' =>'MDM_Source_LastModified__c',
            'MDM_Source_System_Verified__c' => 'MDM_Source_System_Verified__c', 
            'MDM_Source_System_Id__c' => 'MDM_Source_System_Id__c' 
        };
        list<sObject> addressList= new list<MDM_Address__c>();
        map<string,string> contactIDMap =new map<string,string>();
        for(Integer i=0;i<contactList.size();i++){
            contactIDMap.put(custStaging.Contact_Stagings__r[i].id,contactList[i].id);
        }
        for(MDM_Address_Staging__c address : custStaging.Address_Stagings__r){
            sObject newAddress= new MDM_Address__c();
            for(string field: addressFieldMap.keySet()){
                newAddress.put(field,address.get(addressFieldMap.get(field)));
            }
            newAddress.put('MDM_Customer__c',goldenRecordId.Id);
            if(contactIDMap.containsKey(address.MDM_Contact_Staging__c)){
                newAddress.put('MDM_Contact__c',contactIDMap.get(address.MDM_Contact_Staging__c));
            }
            addressList.add(newAddress);
        }

        if(addressList.size() > 0 && Schema.sObjectType.MDM_Address__c.isCreateable()){
            insert (List<MDM_Address__c>)addressList;
        }
    }
}