/**
 * @description       : 
 * @author            : Anish Samant
 * @group             : 
 * @last modified on  : 06-15-2021
 * @last modified by  : Komal Sonsale
 * Modifications Log 
 * Ver   Date         Author         Modification
 * 1.0   03-22-2021   Anish Samant   Initial Version
**/

public with sharing class MDM_ValidationService {
     /**
    * @description 
    * @author Anish Samant | 03-22-2021 
    **/ 
    public class MDM_ValidationWrapper {
        public sObject objectRecord;
        public String fieldApiName;
        public String fieldLabel;
        public String rejectionCode;
        public String regularExp;
        public String rejectionMsg;
        public Boolean required;
        public Decimal minLength;
        public Decimal maxLength;
        public Boolean restrictPicklistValues;
        public String acceptedValues;
    }

    /**
    * @description 
    * @author Anish Samant | 03-22-2021 
    * @param vw 
    **/
    static void validateRequired(MDM_ValidationWrapper vw) {
        if(vw.required && String.isBlank(String.valueOf(vw.objectRecord.get(vw.fieldApiName)))) {
             vw.rejectionCode = vw.fieldLabel+' '+vw.rejectionMsg;
        }
    }

    /**
    * @description 
    * @author Anish Samant | 03-22-2021 
    * @param vw 
    **/
    static void validatePattern(MDM_ValidationWrapper vw) {
        Pattern myPattern = Pattern.compile(vw.regularExp);
        Matcher myMatcher = myPattern.matcher(String.valueOf(vw.objectRecord.get(vw.fieldApiName)));
        Boolean result = myMatcher.matches();
        if(!result) {
            vw.rejectionCode = vw.fieldLabel+' '+vw.rejectionMsg;
        }
    }

    /**
    * @description 
    * @author Anish Samant | 03-22-2021 
    * @param vw 
    **/
    static void validateMinLength(MDM_ValidationWrapper vw) {
        String fieldValueMin = String.valueOf(vw.objectRecord.get(vw.fieldApiName));
        if(fieldValueMin.length() < vw.minLength.intValue()) {
            vw.rejectionCode = vw.fieldLabel+' '+vw.rejectionMsg;
        }
    }

    /**
    * @description 
    * @author Anish Samant | 03-22-2021 
    * @param vw 
    **/
    static void validateMaxLength(MDM_ValidationWrapper vw) {
        String fieldValueMax = String.valueOf(vw.objectRecord.get(vw.fieldApiName));
        if(fieldValueMax.length() > vw.maxLength.intValue()) {
            vw.rejectionCode = vw.fieldLabel+' '+vw.rejectionMsg;
        }
    }

    /**
    * @description 
    * @author Anish Samant | 03-22-2021 
    * @param vw 
    **/
    static void validatePicklistValues(MDM_ValidationWrapper vw) {
        list<String> acceptedValueList=new list<String>();
        for(String accVal : vw.acceptedValues.split('\\n')) {
            acceptedValueList.add(accVal.trim());
        }
        if(!acceptedValueList.contains(String.valueOf(vw.objectRecord.get(vw.fieldApiName)))) {
            vw.rejectionCode = vw.fieldLabel+' '+vw.rejectionMsg;
        }
    }

    
    /**
    * @description 
    * @author Anish Samant | 03-22-2021 
    * @param vw 
    * @return String 
    **/
    public static String validate(MDM_ValidationWrapper vw) {
        vw.rejectionCode = '';              
        validateRequired(vw);
        if(String.isNotBlank(vw.regularExp) && String.isNotBlank(String.valueOf(vw.objectRecord.get(vw.fieldApiName)))) {
            validatePattern(vw);
        }
        if(vw.minLength != null && vw.minLength.intValue() > 0 && 
           String.isNotBlank(String.valueOf(vw.objectRecord.get(vw.fieldApiName)))) {
            validateMinLength(vw);
        }
        if(vw.maxLength != null && vw.maxLength.intValue() > 0 && 
           String.isNotBlank(String.valueOf(vw.objectRecord.get(vw.fieldApiName)))) {
            validateMaxLength(vw);
        }  
        if(vw.restrictPicklistValues && String.valueOf(vw.objectRecord.get(vw.fieldApiName))!=null) {
            validatePicklistValues(vw);
        }    
        return vw.rejectionCode;
    }

}