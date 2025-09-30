/**
 * @description       : Contains wrappers for JSON fields in Auto Update Matching Rule object
 * @author            : Rahul, Odion, Jordan, Dhruv
 * @group             : 
 * @last modified on  : 01/12/2021
 * @last modified by  : Rahul Nagpure
 * Modifications Log 
 * Ver   Date         Author          				Modification
 * 1.0   01/12/2021   Rahul, Odion, Jordan, Dhruv   Initial Version
 **/

public with sharing class MDM_AutoUpdateWrapper {

    /**
     * @description Wrapper class for MDM_Field_Action__c field in Auto Update Matching Rule object
     */
    public class FieldAction {
        public String action;
        public String field;
    }
    
    /**
     * @description Wrapper class for MDM_Matching_Key__c field in Auto Update Matching Rule object
     */
    public class MatchingKey {
        public String value;
        public String comparison;
        public String field;
    }

	/**
     * @description Wrapper class for MDM_Record_Action__c field in Auto Update Matching Rule object
     */    
    public class RecordAction {
        public Boolean create_new;
        public Boolean update_existing;
    }
    
}