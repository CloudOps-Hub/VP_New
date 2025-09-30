/**
 * @description       : 
 * @author            : Priya Sharma
 * @group             : 
 * @last modified on  : 04-19-2021
 * @last modified by  : Priya Sharma
 * Modifications Log 
 * Ver   Date         Author         Modification
 * 1.0   04-19-2021   Priya Sharma   Initial Version
**/


@RestResource(urlMapping='/v1/customers')
global class MDM_GetCustomersService {
    /**
     * @description calls get() method of MDM_CustomerAPI_Handler class when the URL is <serverurl>/v1/customers?<parameters>
     */
	@HttpGet global static void get() {
        MDM_CustomerAPI_Handler.get();
    }
}