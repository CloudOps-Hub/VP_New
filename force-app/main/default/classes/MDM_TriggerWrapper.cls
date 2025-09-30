/**
 * @description       : 
 * @author            : Anish Samant
 * @group             : 
 * @last modified on  : 03-18-2021
 * @last modified by  : Anish Samant
 * Modifications Log 
 * Ver   Date         Author         Modification
 * 1.0   03-18-2021   Anish Samant   Initial Version
**/

public with sharing class MDM_TriggerWrapper {
    public Boolean isBefore;
    public Boolean isAfter;
    public Boolean isInsert;
    public Boolean isUpdate;
    public Boolean isDelete;
    public List<sObject> newSObjectList;
    public List<sObject> oldSObjectList;
    public Map<Id,sObject> newSObjectMap;
    public Map<Id,sObject> oldSObjectMap;
    
    /**  
     *  @description Validation Method for any Object.
     *  @param isBefore
     *  @param isAfter
     *  @param isInsert
     *  @param isUpdate
     *  @param isDelete
     *  @param newSObjectList
     *  @param oldSObjectList
     *  @param newSObjectMap
     *  @param oldSObjectMap
     */
    @SuppressWarnings('PMD.excessiveparameterlist')
    public MDM_TriggerWrapper(Boolean isBefore,
                              Boolean isAfter,
                              Boolean isInsert,
                              Boolean isUpdate,
                              Boolean isDelete,
                              List<sObject> newSObjectList,
                              List<sObject> oldSObjectList,
                              Map<Id,sObject> newSObjectMap,
                              Map<Id,sObject> oldSObjectMap){
        this.isBefore = isBefore;
        this.isAfter = isAfter;
        this.isInsert = isInsert;
        this.isUpdate = isUpdate;
        this.isDelete = isDelete;
        this.newSObjectList = newSObjectList;
        this.oldSObjectList = oldSObjectList;
        this.newSObjectMap = newSObjectMap;
        this.oldSObjectMap = oldSObjectMap;
    }
}