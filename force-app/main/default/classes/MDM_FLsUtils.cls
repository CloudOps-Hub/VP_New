/**
 * @description       : 
 * @author            : Dhruv Agrawal
 * @group             : 
 * @last modified on  : 05-20-2021
 * @last modified by  : Komal Sonsale
 * Modifications Log 
 * Ver   Date         Author          Modification
 * 1.0   03-22-2021   Dhruv Agrawal   Initial Version
**/

public with sharing class MDM_FLsUtils {

    private static String prefix = '';
	private static  ApexClass ac = [SELECT NameSpacePrefix FROM ApexClass WHERE Name = 'MDM_FLsUtils' WITH SECURITY_ENFORCED];  
  
    /**
    * @description 
    * @author Komal Sonsale | 05-20-2021 
    * @param sobjectName 
    * @param fields 
    * @return Boolean 
    **/
    public static Boolean isAccessible( sObject sobjectName, Set<String> fields ) {
      setNameSpacePrefix();
      Schema.DescribeSObjectResult dResult = sobjectName.getSObjectType().getDescribe();
      if ( dResult.isAccessible() ) {
        Map<String,Schema.SObjectField> fieldMap = dResult.fields.getMap();
        for ( String fieldToCheck : fields ) {
            if ( !fieldMap.get( applyPrefixToField( dResult, fieldToCheck.toLowerCase() ) ).getDescribe().isAccessible()) {
                return false;
            }
        }
        return true;
      } else {
          return false;
      }
    } 
  
    /**
    * @description 
    * @author Komal Sonsale | 05-20-2021 
    * @param sObj 
    * @param fields 
    * @return Boolean 
    **/
    public static Boolean isCreateable( sObject sObj, Set<String> fields ) {
      setNameSpacePrefix();
      Schema.DescribeSObjectResult describeResult = sObj.getSObjectType().getDescribe();
      if ( describeResult.isCreateable() ) {
        Map<String,Schema.SObjectField> fieldMap = describeResult.fields.getMap();
        for ( String fieldToCheck : fields ) {   
            String fieldName = applyPrefixToField( describeResult, fieldToCheck.toLowerCase() );
            Schema.SObjectField field = fieldMap.get( fieldName );
            if (!field.getDescribe().isCalculated() && !field.getDescribe().isCreateable()) {
                return false;
            } 
        }
        return true;
      } else {
        return false;
      }
    }
  
  
    /**
    * @description 
    * @author Komal Sonsale | 05-20-2021 
    * @param sObj 
    * @param fields 
    * @return Boolean 
    **/
    public static Boolean isUpdateable( sObject sObj, Set<String> fields ) {
      setNameSpacePrefix();
      Schema.DescribeSObjectResult describeResult = sObj.getSObjectType().getDescribe();
      if ( describeResult.isUpdateable() ) {          
        Map<String,Schema.SObjectField> fieldMap = describeResult.fields.getMap();
        for ( String fieldToCheck : fields ) {   
            String fieldName = applyPrefixToField( describeResult, fieldToCheck.toLowerCase() );
            Schema.SObjectField field = fieldMap.get( fieldName );
            if (!field.getDescribe().isCalculated() && !field.getDescribe().isUpdateable()) {
                return false;
            } 
        }
        return true;
      } else {
        return false;
      }
    }
  
  
    /**
    * @description 
    * @author Komal Sonsale | 05-20-2021 
    * @param sObj 
    * @return Boolean 
    **/
    public static Boolean isDeletable( sObject sObj ) {
      setNameSpacePrefix();
      Schema.DescribeSObjectResult describeResult = sObj.getSObjectType().getDescribe();
      if (describeResult.isDeletable()) {
        return true;
      } else {
        return false;
      }
    }
  
  
    /**
    * @description 
    * @author Komal Sonsale | 05-20-2021 
    **/
    private static void setNameSpacePrefix() {
        //System.debug('Select Namespaceprefix');
  		prefix = ac.NameSpacePrefix == NULL ? '' : ac.NameSpacePrefix + '__';     
    }
  
    /**
    * @description 
    * @author Komal Sonsale | 05-20-2021 
    * @param sObjectDescribe 
    * @param fieldName 
    * @return String 
    **/
    private static String applyPrefixToField( DescribeSObjectResult sObjectDescribe, String fieldName ) {
      setNameSpacePrefix();
      Map<String,Schema.SObjectField> fieldMap = sObjectDescribe.fields.getMap();
      Set<String> standardFieldSet = new Set<String> ();
      for ( String field : fieldMap.keySet() ) {
        DescribeFieldResult dField = fieldMap.get( field ).getDescribe();
        if ( dField.getName().equals( dField.getLocalName() )) {
          standardFieldSet.add( dField.getName().toLowerCase() );
        }
      }
      String result = standardFieldSet.contains(fieldName)  ? fieldName : prefix + fieldName;

      return result;
    }
    
    /**
    * @description 
    * @author Komal Sonsale | 05-20-2021 
    * @param sObj 
    * @param actionName 
    * @return Boolean 
    **/
    public static Boolean flsCheck(sObject sObj,String actionName){
        //System.debug('fls Check');
        Set<String> customFields = new Set<String>();
        Set<String> fieldsSet = sObj.getSObjectType().getDescribe().fields.getMap().keySet();
        
        for (String field : fieldsSet) {
            if (field.endsWith('__c')) {
                customFields.add(field);
            }
        }
        
        Boolean fslStatus = false;
        if(actionName == 'create'){
            fslStatus = isCreateable(sObj, customFields);
        }else if(actionName == 'update'){
            fslStatus = isUpdateable(sObj, customFields);
        }else if(actionName == 'read'){
          fslStatus = isAccessible(sObj, customFields);
        }
        
        if(fslStatus) {
            return true;
        } else {
            return false;
        }
    }
}