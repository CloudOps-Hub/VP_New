/**
 * @description       : Contains the Generic Methods for MDM Search functionality using duplicate and matching rule records.
 * @author            : Komal Sonsale
 * @group             : 
 * @last modified on  : 04-05-2021
 * @last modified by  : Komal Sonsale
 * Modifications Log 
 * Ver   Date         Author          Modification
 * 1.0   03-30-2021   Komal Sonsale   Initial Version
**/

public with sharing class MDM_TokenMatcherServiceHelper {
    /**
     * @author Roshan Kshirsagar
     * @description Function for prepare SOQL Query. Include Fields and inner queries.
     * @param masterObjectName will hold sObject API Name.
     * @param sObjectSequence is List by which inner queries will formed.
     * @param modalDisplayFields map will give list for field to fetched.
     * @return List<String>
     */
    public static List<String> prepareModalFetchContent (String masterObjectName, List<String> sObjectSequence,
                                                        Map<String, List<String>> modalDisplayFields
    ) {
        List<String> fetchContents = new List<String> ();
        Integer childFilterCount = 1;
        for (String objName : sObjectSequence) {
            if (objName == masterObjectName) { fetchContents.addAll (modalDisplayFields.get (objName)); } 
            else {
                fetchContents.add ('(SELECT ' + String.join (modalDisplayFields.get (
                    objName), ',') + ' FROM ' + MDM_TokenMatcherService.sObjectToChildRelationName.get (
                        objName) + ' {' + childFilterCount + '} LIMIT 200)');
                childFilterCount += 1;
            }
        }
        return fetchContents;
    }

    /**
     * @description : Used to calculate max threshold using JW algorithm
     * @param relatedSObjects
     * @param recWeight
     * @return maxThreshold
     */
    public static Decimal getMaxThreshold(
        List<sObject> relatedSObjects, MDM_TokenMatcherWrapper.PrepareRecordWeight recWeight){
        Decimal maxThreshold = 0.0;
        for (sObject childsObj : relatedSObjects) {
            String masterValue = String.valueOf (childsObj.get (recWeight.fieldName));
            if (!String.isBlank (masterValue)) {
                Decimal threshold = MDM_StringSimilarityService.computeJW (recWeight.stagingValue, masterValue);
                if (maxThreshold < threshold) {
                    maxThreshold = threshold;
                }
            } else { recWeight.totalFieldCount -= 1; }
        }
        return maxThreshold;
    }

    /**
     * @description : Used to set threshold sum
     * @param recWeight
     */
    public static void setTresholdSum(MDM_TokenMatcherWrapper.PrepareRecordWeight recWeight){
        if (MDM_TokenMatcherService.customerChildSObjects.contains (recWeight.sObjName)) {
            List<sObject> relatedSObjects = recWeight.sObj.getSObjects(
                MDM_TokenMatcherService.sObjectToChildRelationName.get(recWeight.sObjName));
            if ((relatedSObjects != null && relatedSObjects.size () > 0)) {
                recWeight.thresholdSum += getMaxThreshold(relatedSObjects, recWeight);
            }
        } else {
            String masterValue = String.valueOf (recWeight.sObj.get (recWeight.fieldName));
            if (!String.isBlank (masterValue)) {
                String masterUpperValue = masterValue.toUpperCase ();
                String stagingUpperValue = recWeight.stagingValue.toUpperCase ();
                recWeight.thresholdSum += MDM_StringSimilarityService.computeJW (stagingUpperValue, masterUpperValue);
            } else { recWeight.totalFieldCount -= 1; }
        }
    }

    /**
     * @description : Used to set threshold sum
     * @param findGolden will hold fethced golden records.
     * @param recWeight wrapper
     */
    public static void setStagingValue(MDM_TokenMatcherWrapper.FindGoldenMatchWrapper findGolden,
    MDM_TokenMatcherWrapper.PrepareRecordWeight recWeight)
    {
        if (findGolden.sfObject == MDM_TokenizerService.salesforceMDMObjects.MDM_Customer) {
            recWeight.sObj = (sObject) recWeight.obj;
            sObject tempSObject = MDM_CustomerTokenMatcher.getCustomerStageValue (findGolden.dataModalJSON, recWeight.sObjName);
            if (tempSObject != NULL) {
                recWeight.stagingValue = String.valueOf (tempSObject.get (recWeight.fieldName));
            }
        } /*else if (findGolden.sfObject == MDM_TokenizerService.salesforceMDMObjects.MDM_Title) {
            MDM_TokenMatcherWrapper.TitleReturnDataModal titleReturnModal = 
                (MDM_TokenMatcherWrapper.TitleReturnDataModal) recWeight.obj;
            recWeight.sObj = titleReturnModal.sObj;
            sObject tempSObject = MDM_TitleTokenMatcher.getTitleStageValue (findGolden.dataModalJSON, recWeight.sObjName);
            if (tempSObject != NULL) {
                recWeight.stagingValue = String.valueOf (tempSObject.get (recWeight.fieldName));
            }
        }*/
        if (!String.isBlank (recWeight.stagingValue)) {
            setTresholdSum(recWeight);
        } else { recWeight.totalFieldCount -= 1; }
    }

    /**
     * @description Function for prepare weight map on fetched Customer golden records.
     * @param findGolden :wrapper which contains dataModalJSON, sfObject, fileterResultList
     * @param sObjectSequence :sequence to evaluate sObject 
     * @return Map<Decimal, List<sObject>>
     */
    public static Map<Decimal, List<Object>> prepareRecordWeightMap (
        MDM_TokenMatcherWrapper.FindGoldenMatchWrapper findGolden, List<String> sObjectSequence) 
    {
        Map<Decimal, List<Object>> matchPercentSObjectsMap = new Map<Decimal, List<Object>> ();
        MDM_TokenMatcherWrapper.PrepareRecordWeight recWeight = new MDM_TokenMatcherWrapper.PrepareRecordWeight();
        for (Object obj : findGolden.fileterResultList) {
            recWeight.obj = obj;
            recWeight.thresholdSum = 0.0;
            recWeight.totalFieldCount = 0.0;
            for (String sObjName : sObjectSequence) {
                recWeight.sObjName = sObjName;
                Set<String> fieldList = MDM_TokenizerService.getConfiguredTokenFields (recWeight.sObjName).KeySet ();
                recWeight.totalFieldCount += fieldList.size ();
                for (String fieldName : fieldList) {
                    recWeight.fieldName = fieldName;
                    recWeight.stagingValue = '';
                    setStagingValue(findGolden, recWeight);
                }
            }
            Decimal avgThreshold = recWeight.thresholdSum;
            if (recWeight.totalFieldCount > 0) {
                avgThreshold = (recWeight.thresholdSum / recWeight.totalFieldCount).setScale (4);
            }
            if (!matchPercentSObjectsMap.containsKey (avgThreshold)) {
                matchPercentSObjectsMap.put (avgThreshold, new List<Object> ());
            }
            matchPercentSObjectsMap.get (avgThreshold).add (recWeight.obj);
        }
        return matchPercentSObjectsMap;
    }

        /**
     * @description Function for prepare SOQL WHERE clause and fetching Title golden records.
     * @param findCustGolden sobject wrapper
     * @param fieldFilterTokens records to be excluded
     * @return newFilteredResultList
     */
    public static List<String> setCustFieldFilterTokens(
        MDM_TokenMatcherWrapper.CustGoldenMatchWrapper findCustGolden, List<String> fieldFilterTokens)
    {
        if (findCustGolden.fieldThreshold.get (findCustGolden.field) == 100.0) {
            fieldFilterTokens.add ('' + findCustGolden.fieldValue + '');
        }
        else if (findCustGolden.fieldThreshold.get (findCustGolden.field) == 1.0) {
            fieldFilterTokens.add ('%' + findCustGolden.fieldValue + '%');
        } else {
            Integer tokenCount = Integer.valueOf(
                findCustGolden.fieldThreshold.get(findCustGolden.field) * findCustGolden.fieldValue.length());
            List<String> fieldTokens = findCustGolden.fieldValue.split ('');
            Integer maxLoopSize = fieldTokens.size () - tokenCount;
            for (Integer i = 0; i <= maxLoopSize; i++) {
                List<String> tokens = new List<String> ();
                for (Integer j = i; j < (i + tokenCount); j++) {
                    tokens.add (fieldTokens[j]);
                }
                fieldFilterTokens.add ('%' + String.join (tokens, '') + '%');
            }
        }
        return fieldFilterTokens;
    }
}