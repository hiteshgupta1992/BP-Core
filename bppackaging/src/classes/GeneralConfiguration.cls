/**
 * Author: Prakhar Agrawal
 * Since: Jun 14 2016
 * Name: GeneralConfiguration
 * Description: Apex class to return all the custom fields of General Configurations
**/
public with sharing class GeneralConfiguration {
    
     /**
     * Name: getHomeSearchGridPageSize
     * Desc: To get Home Search Grid Page Size
     * @param: 
     * @return: Decimal
    **/
    public static Decimal getHomeSearchGridPageSize() {
        if(AccessControl.ifObjectFieldIsAccessible('General_Configurations__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
        return General_Configurations__c.getInstance().Home_Search_Grid_Page_Size__c  ;
    }
    
    /**
     * Name: getRelatedListPageSize
     * Desc: To get Related List Page Size
     * @param: 
     * @return: Decimal
    **/
    public static Decimal getRelatedListPageSize() {
        if(AccessControl.ifObjectFieldIsAccessible('General_Configurations__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
        return General_Configurations__c.getInstance().Related_List_Page_Size__c  ;
    }
    
     /**
     * Name: isWidgetRemoveable
     * Desc: To check Widget Removeable 
     * @param: 
     * @return: Decimal
    **/
    
    public static boolean isWidgetRemoveable()    {
        if(AccessControl.ifObjectFieldIsAccessible('General_Configurations__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
        return General_Configurations__c.getInstance().Is_Widget_Removeable__c  ;
    }
    
     /**
     * Name: isLoadNewCustomerOrder
     * Desc: To check Load New Customer Order 
     * @param: 
     * @return: boolean
    **/
    
    public static boolean isLoadNewCustomerOrder()    {
        if(AccessControl.ifObjectFieldIsAccessible('General_Configurations__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
        return General_Configurations__c.getInstance().Load_New_Customer_Order__c  ;
    }
    
     /**
     * Name: isLoadNewUI
     * Desc: To check Load New UI
     * @param: 
     * @return: boolean
    **/
    
    public static boolean isLoadNewUI()    {
        if(AccessControl.ifObjectFieldIsAccessible('General_Configurations__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
        return General_Configurations__c.getInstance().Load_New_UI__c  ;
    }
      
       /**
     * Name: isLoadNewViewCustomer
     * Desc: To check Load New View Customer
     * @param: 
     * @return: boolean
    **/  
       
    public static boolean isLoadNewViewCustomer(){
    	if(AccessControl.ifObjectFieldIsAccessible('General_Configurations__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
        return General_Configurations__c.getInstance().Load_New_View_Customer__c  ;
    }
    
           /**
     * Name: getNamespace
     * Desc: To get Namespace
     * @param: 
     * @return: String
    **/ 
    
    public static String getNamespace()    {
    	if(ConfigurationScript.isPostInstallRunning) {return PostInstallClass.NAMESPACE;}
    	
        if(AccessControl.ifObjectFieldIsAccessible('General_Configurations__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
        if(AccessControl.ifObjectFieldIsAccessible('ApexClass') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
        String nameSpace = General_Configurations__c.getInstance().Namespace__c;
        if(String.isBlank(nameSpace)) {
        	nameSpace = [Select NamespacePrefix, Name, Id From ApexClass where Name = 'Constants'].NamespacePrefix;
        	if(!String.isBlank(nameSpace)){
              	nameSpace += '__';
         	}
        }
        return (nameSpace == null) ? '' : nameSpace;
    }    
    
    /**
     * Name: getHomeSearchGridPageSize
     * Desc: To get Home Search Grid Page Size
     * @param: 
     * @return: Decimal
    **/
    public static Decimal getAustralianMarketSalesTaxRate() {
    	if(AccessControl.ifObjectFieldIsAccessible('Australian_Market__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
        return Australian_Market__c.getInstance().Sales_Tax_Rate__c ;
    }
}