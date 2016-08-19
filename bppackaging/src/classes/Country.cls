/**
 * Author: Tarun Khandelwal
 * Since: May 25, 2015
 * Name: Country
 * Description: Apex class to handle JSON related oprations of Country object. (Used In Kendo)
**/
public with sharing class Country {
	
	// Country Name
	public String CountryName;
	
	// Default
	public Boolean IsDefault;
	
	// Id
	public String Id;
	
	// Constructor
    public Country(Country__c countryRec) {
    	this.CountryName = countryRec.Name__c;
    	this.IsDefault = countryRec.Default__c;
    	this.Id = countryRec.Id;
    }
    
    /**
     * Name: fieldsList
     * Desc: Method Which contains all the field list to be quried
     * @param:  
     * @return: List<String> - Fields List
    **/
    public static List<String> fieldsList(){
        List<String> countryFields = new List<String>{ 'Id',
                                                    'Name__c', 
                                                    'Default__c',
                                                    'Visible__c'
                                                };
        return countryFields;
    }
}