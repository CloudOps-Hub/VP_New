/**
 * @description       : Contains functions for data standardization.
 * @author            : Priya Sharma
 * @group             : 
 * @last modified on  : 05-28-2021
 * @last modified by  : Komal Sonsale
 * Modifications Log 
 * Ver   Date         Author         Modification
 * 1.0   03-23-2021   Priya Sharma   Initial Version
**/

public with sharing class MDM_DataTransformationService {

    /**
    * @description 
    * @author Komal Sonsale | 04-05-2021 
    * @param contactAddress 
    * @param sourceSystem 
    * @param sourceSystemId 
    * @return MDM_LightningComponentService.ContactAddressWrapper 
    **/
    static MDM_LightningComponentService.ContactAddressWrapper setupContact(
        MDM_CustomerAPIWrapper.MDM_ContactAddress contactAddress,
        String sourceSystem,
        String sourceSystemId
    ) {
        MDM_LightningComponentService.ContactAddressWrapper newStagingContact = new MDM_LightningComponentService.ContactAddressWrapper();
        newStagingContact.contact = new MDM_Contact_Staging__c();
        newStagingContact.contact.name = contactAddress.contactName;
     
        newStagingContact.contact.MDM_Name_Suffix__c = contactAddress.suffix;
        newStagingContact.contact.MDM_Fax__c = contactAddress.fax;
        newStagingContact.contact.MDM_Phone__c = contactAddress.phone;
        newStagingContact.contact.MDM_Email__c = contactAddress.email;
        newStagingContact.contact.MDM_Status__c = contactAddress.status;
        newStagingContact.contact.MDM_External_System_Name__c = sourceSystem;
        newStagingContact.contact.MDM_Source_System_Id__c = sourceSystemId;
        try {
            newStagingContact.contact.MDM_Source_System_Contact_Id__c = contactAddress.contactSourceSystemId != NULL ?
                Integer.valueOf(contactAddress.contactSourceSystemId) : NULL;
        } catch(Exception e) {
            MDM_HandleCustomException.logException(e);
        }
        newStagingContact.addresses= new list<MDM_Address_Staging__c>();
        return newStagingContact;
    }

    /**
    * @description 
    * @author Komal Sonsale | 04-05-2021 
    * @param contactAddressItem 
    * @param sourceSystem 
    * @param sourceSystemId 
    * @return MDM_Address_Staging__c 
    **/
    static MDM_Address_Staging__c setupAddress(
        MDM_CustomerAPIWrapper.MDM_Address contactAddressItem,
        String sourceSystem,
        String sourceSystemId
    ) {
        MDM_Address_Staging__c address = new MDM_Address_Staging__c();
        address.MDM_Address_1__c = contactAddressItem.address1;
        address.MDM_Address_2__c = contactAddressItem.address2;
        address.MDM_Address_3__c = contactAddressItem.address3;
        address.MDM_Address_Type__c = contactAddressItem.addressType;
        address.MDM_City__c = contactAddressItem.city;
        address.MDM_Country__c = contactAddressItem.country;
        address.MDM_Country_Code__c = contactAddressItem.countryCode;
        address.MDM_State__c = contactAddressItem.state;
        address.MDM_Zip_Code__c = contactAddressItem.zipcode;
        address.MDM_Extension__c = contactAddressItem.extension;
        address.MDM_Fax__c = contactAddressItem.fax;
        address.MDM_Email__c = contactAddressItem.email;
        address.MDM_Phone__c = contactAddressItem.phone;
        address.MDM_Description_Notes__c = contactAddressItem.description; 
        address.MDM_External_System_Name__c = sourceSystem;
        address.MDM_Source_System_Id__c = sourceSystemId;
        if(contactAddressItem.verifiedAddress != null) { 
            address.MDM_Source_System_Verified__c = Boolean.valueOf(contactAddressItem.verifiedAddress); 
        }
        try { 
            address.MDM_Source_System_Address_Id__c = contactAddressItem.addressSourceSystemId != NULL ?
                Integer.valueOf(contactAddressItem.addressSourceSystemId) : NULL;
        } catch(Exception e) {
            MDM_HandleCustomException.logException(e);
         }
        
        address.MDM_Status__c = contactADdressItem.addressStatus;
        if(contactAddressItem.addressSourceSystemPrimary != null){
            address.MDM_Source_System_Primary__c = Boolean.valueOf(contactAddressItem.addressSourceSystemPrimary);
        }
        return address;
    }

    /**
    * @description 
    * @author Komal Sonsale | 04-05-2021 
    * @param stagingContactAddresses 
    * @param sourceSystem 
    * @param sourceSystemId 
    * @return List<MDM_LightningComponentService.ContactAddressWrapper> 
    **/
    static List<MDM_LightningComponentService.ContactAddressWrapper> setupContactAddressList(
        List<MDM_CustomerAPIWrapper.MDM_ContactAddress> stagingContactAddresses,
        String sourceSystem,
        String sourceSystemId
    ) {
        List<MDM_LightningComponentService.ContactAddressWrapper> stagingContacts = new List<MDM_LightningComponentService.ContactAddressWrapper>();
        for(MDM_CustomerAPIWrapper.MDM_ContactAddress contactAddress :stagingContactAddresses){
            MDM_LightningComponentService.ContactAddressWrapper newStagingContact = setupContact(contactAddress, sourceSystem, sourceSystemId);
            if(contactAddress.addresses != null){
                for(
                    MDM_CustomerAPIWrapper.MDM_Address contactAddressItem : contactAddress.addresses){
                    newStagingContact.addresses.add(setupAddress(contactAddressItem, sourceSystem, sourceSystemId));
                }
            }
            stagingContacts.add(newStagingContact);
        }
        return stagingContacts;
    }

    /**
     * @description converts Contact JSON string to Contact class Object.
     * @param contactJSON - JSON string for contacts
     * @param sourceSystem
     * @param sourceSystemId
     * @return List<MDM_LightningComponentService.contactAddressWrapper>
	 */
    public static List<MDM_LightningComponentService.ContactAddressWrapper> changeContactAddressFormat(String contactJSON, String sourceSystem, String sourceSystemId) {
        if(contactJSON == NULL) { return NULL; }
        List<MDM_CustomerAPIWrapper.MDM_ContactAddress> stagingContactAddresses = (list<MDM_CustomerAPIWrapper.MDM_ContactAddress>)
            JSON.deserialize(contactJSON, list<MDM_CustomerAPIWrapper.MDM_ContactAddress>.class);
        if(stagingContactAddresses == NULL) { return NULL; }
        return setupContactAddressList(stagingContactAddresses, sourceSystem, sourceSystemId);
    }
    
    /** 
     * @description - Capitalizes the words of the input string.
     * @param input
     * @param excludedWords
     * @param capitalizeWordsAfter
     * @return string of Capitalized words
	*/
    public static String titleCase(String input, String excludedWords, String capitalizeWordsAfter) {
        if(input == NULL) { return NULL; }
        List<String> excludedWordList = excludedWords!=null ? excludedWords.split(',') : new list<String>();
        List<String> capitalizeWordsAfterList = capitalizeWordsAfter!=null ? capitalizeWordsAfter.split(',') : new list<String>();
        Boolean capitalizeNextWord = false;
        List<String> inputs = input.split(' '); 
        for(Integer i=0; i<inputs.size(); i++) {     
            //check if current word needs to be capitalized or not.
            Boolean uncapitalize = (i!=0 && excludedWordList.contains(inputs[i].toLowerCase()) && !capitalizeNextWord && i!=(inputs.size()-1)); 
            inputs[i] = uncapitalize ? inputs[i].toLowerCase() : inputs[i].capitalize();
            capitalizeNextWord = false;
            //check if next word needs to be capitalized.
            if(inputs[i].length() > 0 && capitalizeWordsAfterList.contains(inputs[i].right(1))) { capitalizeNextWord = true; }
        }
        return String.join(inputs, ' ');
    }

    /**
    * @description 
    * @author Komal Sonsale | 04-05-2021 
    * @param objectType 
    * @param apiNames 
    * @param fieldDescriptorMap 
    **/
    static void retrieveFieldList(String objectType, List<String> apiNames, Map<String, MDM_SchemaService.FieldDescriptor> fieldDescriptorMap) {
        MDM_GeneraliseResult returnedFields = MDM_SchemaService.getFields(objectType);
        for(MDM_SchemaService.FieldDescriptor field : (list<MDM_SchemaService.FieldDescriptor>)returnedFields.result){
            apiNames.add(field.fieldName);
            fieldDescriptorMap.put(field.fieldName, field); 
        }
    }

    /** 
     * @description - dataTransformation.
     * @param data
	*/
    public static void dataTransformation(List<sObject> data){
        String objectType = string.valueOf(data.getSObjectType());
        List<String> apiNames = new list<string>();
        MDM_DataTransformationServiceHelper.fieldDescriptorMap = new Map<String, MDM_SchemaService.FieldDescriptor>();
        //retrieve fields of an object
        retrieveFieldList(objectType, apiNames, MDM_DataTransformationServiceHelper.fieldDescriptorMap);
        //retrieve data transformation rules
        List<MDM_Data_Transformation_Rule__c> dataTransormationRuleList = new List<MDM_Data_Transformation_Rule__c>();
        try{
            if(Schema.sObjectType.MDM_Data_Transformation_Rule__c.isAccessible()) {
                dataTransormationRuleList = [
                    SELECT Id, Name, MDM_Is_Title_Case__c, MDM_Is_Capitalized__c, MDM_Excluded_Capitalization_Words__c, MDM_Data_Transformation__c,
                    MDM_Data_Quality__r.MDM_Field_Label__c, MDM_Data_Quality__r.MDM_Field_Api_Name__c, MDM_Capitalize_Words_After__c 
                    FROM MDM_Data_Transformation_Rule__c WHERE MDM_Data_Quality__r.MDM_Object__c = :objectType 
                    AND MDM_Data_Quality__r.MDM_Field_Api_Name__c IN :apiNames AND MDM_Data_Transformation__c !=null WITH SECURITY_ENFORCED
                ];
            }
        }
        catch(Exception e){
          	 MDM_HandleCustomException.logException(e);
            return;
        }
    
        //retrieve data transformation Ids from data transformation rules
        Set<Id> dataTransformationIds = new Set<Id>();
        for(MDM_Data_Transformation_Rule__c dataTransormationRule : dataTransormationRuleList) {
            dataTransformationIds.add(dataTransormationRule.MDM_Data_Transformation__c);
        }

        //create a map of data transformation Id and attribute transformation items
        Map<Id, List<MDM_Attribute_Transformation_Item__c>> dataTransformationAttributeTransformationsMap = new map<Id, List<MDM_Attribute_Transformation_Item__c>>();
        try{
            if(Schema.sObjectType.MDM_Attribute_Transformation_Item__c.isAccessible()) {
                for(MDM_Attribute_Transformation_Item__c attTransformationItem : [
                SELECT MDM_Case_Sensitive__c, MDM_Data_Transformation__c, MDM_New_Value__c, MDM_Old_Value__c, MDM_Type__c
                FROM MDM_Attribute_Transformation_Item__c 
                WHERE MDM_Data_Transformation__c IN :dataTransformationIds WITH SECURITY_ENFORCED
                ]) {
                    if(dataTransformationAttributeTransformationsMap.get(attTransformationItem.MDM_Data_Transformation__c) == NULL) {
                        dataTransformationAttributeTransformationsMap.put(attTransformationItem.MDM_Data_Transformation__c, new List<MDM_Attribute_Transformation_Item__c> { attTransformationItem });
                    } else {
                        dataTransformationAttributeTransformationsMap.get(attTransformationItem.MDM_Data_Transformation__c).add(attTransformationItem);
                    }
                }
            }
        } catch(Exception e){
          	 MDM_HandleCustomException.logException(e);
            return;
        }
        
        //iterate over each data transformation rules and transform the data
        for(MDM_Data_Transformation_Rule__c dataTransormationRule : dataTransormationRuleList) {
            for(sObject obj : data) {
                if(dataTransormationRule.MDM_Is_Title_Case__c) {
                    obj.put(dataTransormationRule.MDM_Data_Quality__r.MDM_Field_Api_Name__c, titleCase(String.valueOf(obj.get(dataTransormationRule.MDM_Data_Quality__r.MDM_Field_Api_Name__c)), dataTransormationRule.MDM_Excluded_Capitalization_Words__c, dataTransormationRule.MDM_Capitalize_Words_After__c));
                }
                if(dataTransormationRule.MDM_Is_Capitalized__c) {
                    String fieldValue = (String) obj.get(dataTransormationRule.MDM_Data_Quality__r.MDM_Field_Api_Name__c);
                    obj.put(dataTransormationRule.MDM_Data_Quality__r.MDM_Field_Api_Name__c, fieldValue?.toUpperCase());
                }
                MDM_DataTransformationServiceHelper.transform(
                    obj, 
                    dataTransormationRule,
                    dataTransformationAttributeTransformationsMap.get(dataTransormationRule.MDM_Data_Transformation__c)
                );
            }
        }
    }
}