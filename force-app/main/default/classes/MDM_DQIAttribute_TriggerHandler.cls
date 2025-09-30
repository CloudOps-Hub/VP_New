/**
 * @description       : 
 * @author            : Dhruv Agrawal
 * @group             : 
 * @last modified on  : 04-26-2021
 * @last modified by  : Dhruv Agrawal
 * Modifications Log 
 * Ver   Date         Author          Modification
 * 1.0   04-26-2021   Dhruv Agrawal   Initial Version
**/

public with sharing class MDM_DQIAttribute_TriggerHandler {
/**
    * @description : To call Trigger helper class methods
    * @param triggerWrapper
    */
    public static void triggerConditionForTriggerHelperInvoke(MDM_TriggerWrapper triggerWrapper){
       	 MDM_DQIAttributeTriggerHelper.triggerConditionForMethodInvoke(triggerWrapper);  

        } 
}