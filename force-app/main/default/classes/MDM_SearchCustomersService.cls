/**
 * @description       : calls search() method of MDM_CustomerAPI_Handler class when the URL is <serverurl>/v1/customers/search?<parameters>
 * @author            : Komal Sonsale
 * @group             : 
 * @last modified on  : 04-19-2021
 * @last modified by  : Komal Sonsale
 * Modifications Log 
 * Ver   Date         Author          Modification
 * 1.0   04-19-2021   Komal Sonsale   Initial Version
**/

@RestResource(urlMapping='/v1/customers/search')
global with sharing class MDM_SearchCustomersService {
  
    /**
    * @description calls search() method of MDM_CustomerAPI_Handler class
    * @author Komal Sonsale | 04-19-2021 
    **/
    @HttpGet   
    global static void get() {
        MDM_CustomerAPI_Handler.search();
    }
}