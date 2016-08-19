/**
 * Author: Tarun Khandelwal
 * Since: May 25, 2015
 * Name: State
 * Description: Apex class to handle JSON related oprations of State object.
**/
public with sharing class State {
		
	// State Name
	public String StateName;
	
	// Default
	public Boolean IsDefault;
	
	// Id
	public String Id;
	
	// Constructor
    public State(State__c stateRec) {
    	this.StateName = stateRec.Name__c;
    	this.IsDefault = stateRec.Default__c;
    	this.Id = stateRec.Id;
    }
		
	/**
     * Name: fieldsList
     * Desc: Method Which contains all the field list to be quried
     * @param:  
     * @return: List<String> - Fields List
    **/
    public static List<String> fieldsList(){
        List<String> stateFields = new List<String>{ 'Id',
                                                    'Name__c', 
                                                    'Default__c'
                                                };
        return stateFields;
    }	
		
		
	
}