/**
 * @description       : Contains the Generic Methods for Computing String Similarities
 * @author            : Komal Sonsale
 * @group             : 
 * @last modified on  : 05-28-2021
 * @last modified by  : Dhruv Agrawal
 * Modifications Log 
 * Ver   Date         Author          Modification
 * 1.0   03-30-2021   Komal Sonsale   Initial Version
**/
public with sharing class MDM_StringSimilarityService {

    static Double score;
    static String s1;
    static String s2;
    static Decimal prefixMatch;
    static Decimal matches;
    static Decimal transpositions;
    static Decimal s1Length;
    static Decimal s2Length;
    static Decimal maxLength;
    static Integer maxMatchDistance;
    static String shorter;
    static String longer;
    static List<String> longerStrList;
    static String shortMatchString;
    static String longMatchString;

  
   
    /**
    * @description 
    * @author Dhruv Agrawal | 05-28-2021 
    * @param str1 
    * @param str2 
    * @return Double 
    **/
    static Double checkInput(final String str1, final String str2) {
        // lowest score on empty strings
        if (str1 == null || str2 == null || String.isEmpty(str1) || String.isEmpty(str2)) { return 0; }
        // highest score on equal strings
        if (str1.equals(str2)) { return 1; }
        return NULL;
    }


    /**
    * @description 
    * @author Dhruv Agrawal | 05-28-2021 
    * @param str1
    * @param str2 
    **/
    static void initialize(final String str1, final String str2) {
        String s1 = str1.replaceAll('\\s+', '');
        String s2 = str2.replaceAll('\\s+', '');
        // some score on different strings
        prefixMatch = 0.0;                          // exact prefix matches
        matches = 0.0;                              // matches (including prefix and ones requiring transpostion)
        transpositions = 0.0;                       // matching characters that are not aligned but close together
        s1Length = s1.length();
        s2Length = s2.length();
        maxLength = Math.max(s1Length, s2Length);
        maxMatchDistance = Integer.valueOf((Math.max((maxLength / 2), 0))); // look-ahead/-behind to limit transposed matches
        shorter = (s1Length < s2Length ? s1 : s2);
        longer = (s1Length >= s2Length ? s1 : s2);
        s1Length = shorter.length();
        s2Length = longer.length();
        longerStrList = new List<String>(longer.split(''));
        // Find Matching String.
        shortMatchString = '';
        longMatchString = '';
    }

    /**
    * @description 
    * @author Anish Samant | 04-05-2021 
    **/
    static void setShortMatchString() {
        for (Integer i = 0; i < s1Length; i++) {
            // check for transposed matches
            String shortChar = shorter.substring(i, i+1);
            for (Integer j = Math.max(i - maxMatchDistance, 0); j < Math.min(i + maxMatchDistance, s2Length); j++) {                
                String longChar = longer.substring(j, j+1);
                if ( shortChar.equals(longChar) ) {
                    matches++;
                    if( i == j ) { prefixMatch++; }
                    shortMatchString += String.valueOf(shortChar);
                    break;
                }
            }
        }
    }

    /**
    * @description 
    * @author Anish Samant | 04-05-2021 
    * @param i 
    * @param j 
    * @param longChar 
    * @return Boolean 
    **/
    static Boolean appendLongMatchString(Integer i, Integer j, String longChar) {
        String shortChar = shorter.substring(j, j+1);
        if ( shortChar.equals(longChar) ) {
            if( shortMatchString.length() == 0 ) { matches++; }
            longMatchString += String.valueOf(longerStrList[(integer)i]);
            return true;
        }
        return false;
    }

    /**
    * @description 
    * @author Anish Samant | 04-05-2021 
    **/
    static void setLongMatchString() {
        for (Integer i = 0; i < s2Length; i++) {
            // check for transposed matches
            String longChar = longer.substring(i, i+1);
            for (Integer j = Math.max(i - maxMatchDistance, 0); j < Math.min(i + maxMatchDistance, s1Length); j++) {
                if( j < s1Length) {
                    Boolean skipNext = appendLongMatchString(i, j, longChar);
                    if(skipNext) { break; }
                }
            }
        }
    }

    /**
     * @description Applies the Jaro-Winkler distance algorithm to the given strings, providing information about the similarity of them.
     * @param str1 The first string that gets compared.
     * @param str2 The second string that gets compared.
     * @return double The Jaro-Winkler score (between 0.0 and 1.0), with a higher value indicating larger similarity.
	 */  
    public static double computeJW(final String str1, final String str2) {
        score = checkInput(str1, str2);

        if(score != NULL) { return score; }

        initialize(str1, str2);
        setShortMatchString();
        setLongMatchString();
        
        Decimal distance = shortMatchString.getLevenshteinDistance(longMatchString);
        transpositions = (distance/2.0);
        if( matches == 0.0) { matches = 1.0; }
        // Calculate Jaro Distance.
        score = (0.3333*((matches/s1Length)+(matches/s2Length)+((matches-transpositions)/matches)));
        if (score < 0 || score > 1) { return 0; }
        // check 0.7 constant
        if (score < 0.7) { return score; }
        return score;
    }
}