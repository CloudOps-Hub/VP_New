/**
* @description       : 
* @author            : Sourabh
* @group             : 
* @last modified on  : 05-28-2021
* @last modified by  : Komal Sonsale
* Modifications Log 
* Ver   Date         Author    Modification
* 1.0   03-22-2021   Sourabh   Initial Version
**/

@SuppressWarnings('PMD.ExcessivePublicCount,PMD.CyclomaticComplexity,PMD.CognitiveComplexity')
public with sharing class MDM_LightningComponentService {
	/**
	 * @description : Returns schema of sObjects. 
	 * @return MDM_SchemaService.getSObjects(); 
	 */  
	@AuraEnabled
	public static MDM_GeneraliseResult getSObjects(){
			return MDM_SchemaService.getSObjects();
	}

	/**
	 *  @description : This Wrapper contains parameter for searched result of golden matches.
	 */
	public class MDM_FindGoldenMatchesWrapper{
		public String dataModalJSON;
		public Boolean performWordBasedSearch;
		public String wordBasedMatchingRuleJSON;
		public String parentObjectId;
		public String sObjectType;
	}

	/**
	 *  @description : Returns the searched result of golden matches.
	 *  @param findGoldenMatchesJSON
	 *  @return MDM_GeneraliseResult 
	 */
	@AuraEnabled
	public static MDM_GeneraliseResult findGoldenMatches(String findGoldenMatchesJSON) 
	{                                       
		MDM_FindGoldenMatchesWrapper goldenWrap = (MDM_FindGoldenMatchesWrapper) JSON.deserialize(findGoldenMatchesJSON, MDM_FindGoldenMatchesWrapper.class); 
		MDM_GeneraliseResult finalResult = new MDM_GeneraliseResult();
		List<Object> finalResults = new List<Object>();
		List<Object> results = new List<Object>();
		results = MDM_TokenMatcherService.getGoldenMatches(goldenWrap);
		for( Object result : results ) {
			Map<Decimal, List<Object>> matchPercentIdMap = (Map<Decimal, List<Object>>) result;
			Map<Decimal, List<Object>> sortedMatchPercentIdMap = new Map<Decimal, List<Object>>();
			List<Decimal> sortedDecimal = new List<Decimal>(matchPercentIdMap.KeySet());
			sortedDecimal.sort();
			for( Integer index = (sortedDecimal.size()-1); index >= 0; index-- ) {
				List<Object> sObjs = matchPercentIdMap.get( sortedDecimal[index] );
				for(Object sobj : sObjs) {
					if( !sortedMatchPercentIdMap.containsKey(sortedDecimal[index]) ) {
						sortedMatchPercentIdMap.put(sortedDecimal[index], new List<Object>());
					}
					sortedMatchPercentIdMap.get(sortedDecimal[index]).add(sobj);
				}
			}
			finalResults.add(sortedMatchPercentIdMap);
		}
		finalResult.result = finalResults;
		finalResult.isSuccess = true;
		finalResult.displayMessage = '';
		return finalResult;
	}    

	/** 
	 * @description : Returns the query result based on sobject name ,filter fields, field token
	 * @param customerJSON
	 * @return MDM_GeneraliseResult 
	 */
	@auraEnabled
	Public static MDM_GeneraliseResult getCustomers(String customerJSON) 
	{
		return MDM_CustomerComponentHelper.getCustomers(customerJSON);
	}    

	/** 
	 * @description : will return Map of all sobjectName,sobjectFields provided in JSON.
	 * @param jsonFields
	 * @return MDM_GeneraliseResult 
	 */
	@AuraEnabled
	public static MDM_GeneraliseResult getCustomerField(String jsonFields){
		return MDM_CustomerComponentHelper.getCustomerField(jsonFields);
	}

	/** 
	 * @description : will return Id of listview based on sobjectType and Listview Name.    
	 * @param sobjectType
	 * @param listViewName
	 * @return MDM_GeneraliseResult 
	 */
	@AuraEnabled
	public static MDM_GeneraliseResult getListViewID(String sobjectType, String listViewName) {
		MDM_GeneraliseResult finalResult = new MDM_GeneraliseResult();
		List<ListView> listviews = new List<ListView>();
		if(Schema.sObjectType.ListView.isAccessible()) {
			listviews = [
				SELECT Id, Name FROM ListView 
				WHERE SobjectType = : sobjectType
				AND Name LIKE : listViewName
			];
		}
		if(!listviews.isEmpty()){
			finalResult.result = listviews[0].Id;
			finalResult.isSuccess = true;
			
		}else{
			finalResult.displayMessage = 'List View Not found for selected Record Type.';
		}
		return finalResult;
	}

	/**
	 * @description : getFields() will return the schema of sobjectfields.    
	 * @param sObjectType
	 * @return MDM_GeneraliseResult 
	 */
	@AuraEnabled
	public static MDM_GeneraliseResult getFields(String sObjectType) {
		return MDM_SchemaService.getFields(sObjectType);
	}

	/** 
	 * @description contactAddressWrapper will have contact and address of staging record 
	 */
	public class ContactAddressWrapper {
		@AuraEnabled public MDM_Contact_Staging__c contact; 
		@AuraEnabled public List<MDM_Address_Staging__c> addresses;
	}


	/** 
	 * @description : Will return the user details. 
	 * @param userId
	 * @return MDM_GeneraliseResult 
	 */
	@AuraEnabled
	public static MDM_GeneraliseResult getUser(String userId) {
		MDM_GeneraliseResult finalResult = new MDM_GeneraliseResult();
		finalResult.result = [SELECT id,Name,TimeZoneSidKey,Username,Profile.Name,Alias,Country,Email,FirstName,LastName
								FROM User 
								WHERE id =: userId];
		return finalResult;
	}

	/** 
	 * @description : Will migrate/create landing data into staging.
	 * @param customerLandings
	 */
	@AuraEnabled
	public static void migrateLandingToStaging(List<MDM_Customer_Landing__c> customerLandings) {
		try{
			MDM_CustomerMigrationHelper.migrateLandingToStaging(customerLandings);
		} catch (Exception e) {
			MDM_HandleCustomException.logException(e);
		}
	}

	/** 
	 * @description : method for getting related results of customer Staging Record from its recordID.
	 * @param recordID
	 * @return list<object>
	 */
	@AuraEnabled
	public static list<object> getRelatedLists(String recordID) {
		return MDM_CustomerComponentHelper.getRelatedLists(recordID);
	}

	/** 
	 * @description : CustomerModelWrapper class will contain wrapper of staging,source,customer record 
	 *                and List of brandIds,contactIDs,addressIds
	 */
	public class CustomerModelWrapper{
		public MDM_Customer_Staging__c stagingRecord;
		public MDM_Source_Customer_Staging__c sourceRecord;
		public MDM_Customer__c customerRecord;
		
		public list<string> contactIDs;
		public list<string> addressIDs; 
	}

	/** 
	 * @description : insert records passed in customerModelWrapperJSON
	 * @param customerModelWrapperJSON
	 * @return MDM_GeneraliseResult
	 */
	@AuraEnabled
	public static MDM_GeneraliseResult insertInCustomer(String customerModelWrapperJSON){
		return MDM_CreateNewCustomerHelper.insertInCustomer(customerModelWrapperJSON);
	} 

	/** 
	 * @description : This Function will parse contactAddressJSON,brandJSON and check for validation 
	 *                before submitting the customer registartion record
	 * @param customerRegistrationID
	 * @param contactAddressJSON
	 */
	@AuraEnabled
	public static void parseCustomerRegistrationJSON(String customerRegistrationID, String contactAddressJSON) {
		MDM_CustomerRegistrationJSONParser.parseCustomerRegistrationJSON(customerRegistrationID, contactAddressJSON);
	}

	/** 
	 * @description : This Function will fetch ContactAddressJSON for customer registartion
	 * @param customerRegistrationID
	 * @return String
	 */
	@AuraEnabled
	public static String getCustomerRegistrationContactAddressJSON(String customerRegistrationID) {
		return MDM_CustomerRegistrationJSONParser.getContactAddressJSON(customerRegistrationID);
	}


	/**
	 * @description : Get staging record Id
	 * @param id
	 * @return MDM_Customer_Staging__c
	 */
	@AuraEnabled
	public static MDM_Customer_Staging__c getStagingRecord(String id) {
		if(String.isEmpty(id)) { return NULL; }
		try {
			if (Schema.sObjectType.MDM_Customer_Staging__c.isAccessible()) {
				return [
					SELECT Id, Name,(
						SELECT id,name,MDM_Address_1__c,MDM_Address_2__c,MDM_Address_3__c,MDM_City__c,MDM_State__c,
						MDM_Country__c, MDM_Address_Type__c,MDM_Email__c,MDM_Phone__c,MDM_Contact_Staging__c,
						MDM_Contact_Staging__r.Name,MDM_Status__c,MDM_External_System_Name__c,MDM_Source_System_Primary__c
						FROM Address_Stagings__r
					),(
						SELECT id, Name,MDM_Phone__c,MDM_Email__c,MDM_Status__c,MDM_Title__c,MDM_Name_Suffix__c 
						FROM Contact_Stagings__r
					),(
						SELECT Id, MDM_Source_System__c, MDM_Source_System_Id__c FROM Source_Customer_Stagings__r
					) FROM MDM_Customer_Staging__c WHERE Id =: id WITH SECURITY_ENFORCED
				];
			}  else {
				return NULL;
			}
		}
		catch(Exception e) { 
			MDM_HandleCustomException.logException(e);
			return Null;
		}
	}
	
	/** 
	 * @description : Will call the  MDM_DataTransformationService.dataTransformation function to transform data.
	 * @param data
	 */
	@AuraEnabled
	public static void transformCustomerLanding(MDM_Customer_Landing__c data) {   	 	
		MDM_DataTransformationService.dataTransformation(new List<MDM_Customer_Landing__c> {data});
		update data;
	}

	/**
	 * @description 
	 * @author Komal Sonsale | 04-15-2021 
	 * @param permissionSetName 
	 * @return List<PermissionSetAssignment> 
	 **/
	@AuraEnabled
	public static List<PermissionSetAssignment> getPermissionSetName(List<String> permissionSetName) {
		List<PermissionSetAssignment> permissionSetAssign = new List<PermissionSetAssignment>();
		
		try{
			permissionSetAssign = [SELECT PermissionSetId , PermissionSet.Name
			FROM PermissionSetAssignment WHERE AssigneeId= :UserInfo.getUserId() 
			AND PermissionSet.Name in : permissionSetName WITH SECURITY_ENFORCED];  
		}
		catch(Exception e){
			MDM_HandleCustomException.logException(e);
		}
		return permissionSetAssign;
	}

	/** @owner : Jordan
     *  @description : Used to return List of Object API names
     *  @createdDate : 10/18/2021
     *  @return result
     */
    @AuraEnabled
    public static MDM_GeneraliseResult getSObjectList() {
        return MDM_CreateAutoUpdateMatchingRuleService.getSObjectList();
    }
    
    /** @owner : Jordan
     *  @description : Used to return Fields API names of the given Object name
     *  @param objectName : Object Name
     *  @createdDate : 10/18/2021
     *  @return result
     */
    @AuraEnabled
    public static MDM_GeneraliseResult getSObjectFieldMap(String objectName) {
        return MDM_CreateAutoUpdateMatchingRuleService.getSObjectFieldMap(objectName);
    }
    
    /** @owner : Jordan
     *  @description : Used to return Auto Update Matching Rule record
     *  @param recordId
     *  @createdDate : 10/19/2021
     *  @return result
     */
    @AuraEnabled
    public static MDM_GeneraliseResult getRecord(String recordId) {
        return MDM_CreateAutoUpdateMatchingRuleService.getRecord(recordId);
    }
    
    /** @owner : Jordan
     *  @description : Used to save auto update rule record
     *  @param autoUpdateRule
     *  @createdDate : 10/18/2021
     *  @return result
     */
    @AuraEnabled
    public static MDM_GeneraliseResult saveRecord(MDM_Auto_Update_Matching_Rule__c autoUpdateRule) {
        return MDM_CreateAutoUpdateMatchingRuleService.saveRecord(autoUpdateRule);
    }
}