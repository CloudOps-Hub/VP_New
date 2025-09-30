/**
 * @description       : 
 * @author            : Sourabh
 * @group             : 
 * @last modified on  : 03-22-2021
 * @last modified by  : Anish Samant
 * Modifications Log 
 * Ver   Date         Author    Modification
 * 1.0   03-19-2021   Sourabh   Initial Version
**/

public with sharing class MDM_GeneraliseResult {
    /**
     * @description to return success if the transaction was successful
     * @author sourabh
     */ 
    @AuraEnabled
    public boolean isSuccess{ 
        get { if(isSuccess == null) { isSuccess = false; } return isSuccess; }
        set; 
    }

    /**
     * @description to return success or error message
     * @author sourabh
     */ 
    @AuraEnabled public string displayMessage {
        get { if(displayMessage == null) { displayMessage = ''; } return displayMessage; }
        set; 
    }
    
    /**
     * @description to return the actual result from apex to aura
     * @author sourabh
     */ 
    @AuraEnabled public Object result { 
        get { if(result == null) { result = null; } return result; }
        set; 
    }    
}