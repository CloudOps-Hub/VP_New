/**
 * @description       : 
 * @author            : Dhruv Agrawal
 * @group             : 
 * @last modified on  : 05-28-2021
 * @last modified by  : Dhruv Agrawal
 * Modifications Log 
 * Ver   Date         Author          Modification
 * 1.0   03-24-2021   Dhruv Agrawal   Initial Version
**/
public with sharing class MDM_HandleCustomException extends Exception {
    /**
    * @description 
    * @author Komal Sonsale | 05-27-2021 
    * @param e 
    **/
    public static void logException(Exception e)
    {
        logException(e,'');
    }
    
    /**
    * @description : Log Exception in CustomException object.
    *                 relatedToId : Case/object for which this error in logged. 
    * @author Komal Sonsale | 05-27-2021 
    * @param e 
    * @param relatedToId
    **/
    public static void logException(Exception e,string relatedToId)
    {
        String stackTrace = e.getStackTraceString().substringBefore('\n');
        String className = stackTrace.substringAfter('.').substringBefore('.');	
        String methodName = stackTrace.substringBefore(':').substringAfter(className).substringAfter('.');
        
        //Governer Limit of executingQuery 
        String queryLimit = '1. SOQL Queries used / SOQL Queries allowed: ' + Limits.getQueries() + '/' + Limits.getLimitQueries();
        String dmLimit = '2. Number of records queried so far /  Number allowed: ' + Limits.getDmlRows() + '/' + Limits.getLimitDmlRows();
        String dmlStat = '3. Number of DML statements used so far / Number allowed: ' +  Limits.getDmlStatements() + '/' + Limits.getLimitDmlStatements();   
        String cpuT = '4. Amount of CPU time (in ms) used so far / CPU usage time (in ms) allowed: ' + Limits.getCpuTime() + '/' + Limits.getLimitCpuTime();
        
        if(!MDM_FLsUtils.flsCheck(new MDM_Exception_Log__c(),'create')) {
            System.debug('Customer Staging isCreatable() FSL check');            
        }
        //Log information in object
        
        MDM_Exception_Log__c objException = new MDM_Exception_Log__c();
        if(string.isNotEmpty(relatedToId)){
            objException.Related_To_Number__c=relatedToId;
        }
        
        objException.Govt_Limit_in_Executing_Code__c = String.format('{0}\n{1}\n{2}\n{3}',new List<String>{queryLimit,dmLimit,dmlStat,cpuT});
        objException.Exception_Message__c = e.getMessage();
        objException.Exception_Type__c = e.getTypeName();
        objException.Line_Number__c = e.getLineNumber();
        objException.StackTrace__c = e.getStackTraceString();
        objException.MethodName__c=methodName;
        objException.ClassName__c=className;
        		
        Database.insert(objException, false);
       }
}