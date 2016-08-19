/**
 * Author: Tarun Khandelwal
 * Since: June 05, 2015
 * Name: CustomerDetail
 * Description: Apex class to handle JSON related oprations of Customer Detail Page.
**/
public with sharing class CustomerDetail {
	
    public Customer CustomerInfo;
    
    // open orders
    public Decimal OpenOrders;
    
    // Average Life Time
    public Decimal OrdersLifetime;
    
    // Average Spend per Hours
    public Decimal AverageSpendPerHour;
    
    // Last Visited Order Time
    public String LastVisit;
    
    // Related Customer
    public Integer TotalCustomerRecords;
    public List<RelatedCustomer> RelatedCustomerList;
    
    // COU list
    public Integer TotalCOURecords;
    public List<CustomerOwnedUnit> CustomerOwnedUnitList;
    
    // Contacts List
    public Integer TotalContactRecords;
    public List<CustomerContact> ContactList;
    
    // Active Orders
    public Integer TotalActiveOrderRecords;
    public List<ActiveOrder> ActiveOrderList;
    
    // Active Sales Order (Customer Header)
    public Integer TotalActiveSalesOrderRecords;
    public List<ActiveSalesOrder> ActiveSalesOrderList;
    
    
    // Constructor
    public CustomerDetail(Account customerRec, List<Account> relatedCustomersList, Map<String, String> accountIdToRelationMap, List<Customer_Owned_Unit__c> couList, 
    						List<CO_Header__c> ActiveSalesOrdersList, List<Contact> customerContactList, String lastVisitedValue) {
    	this.customerInfo = new Customer(customerRec);
    	this.RelatedCustomerList = new List<RelatedCustomer>();
    	this.CustomerOwnedUnitList = new List<CustomerOwnedUnit>();
    	this.ContactList = new List<CustomerContact>();
    	this.ActiveOrderList = new List<ActiveOrder>();
    	this.ActiveSalesOrderList = new List<ActiveSalesOrder>();
    	
    	this.OpenOrders = customerRec.Open_Orders__c;
    	this.OrdersLifetime = customerRec.Orders_Lifetime__c;
    	this.AverageSpendPerHour = customerRec.Average_Spend_per_Order__c;
    	this.LastVisit = lastVisitedValue; 
    	
    	for(Account relatedCustomerRec : relatedCustomersList) {
    		this.RelatedCustomerList.add(new RelatedCustomer(relatedCustomerRec, accountIdToRelationMap));
    	}
    	
    	for(Customer_Owned_Unit__c couRec : couList) {
    		this.CustomerOwnedUnitList.add(new CustomerOwnedUnit(couRec));
    	}
    	
    	for(CO_Header__c coh : ActiveSalesOrdersList) {
    		this.ActiveSalesOrderList.add(new ActiveSalesOrder(coh));
    	}
    	
    	for(Contact contactRec : customerContactList) {
    		this.ContactList.add(new CustomerContact(contactRec));
    	}
    	
    	
    	ActiveOrder.RelatedListPaginationSorting pageSort = new ActiveOrder.RelatedListPaginationSorting();
		pageSort.activeOrdersCurrentPage = 1;
		pageSort.activeOrdersPageSize = 1;

    	this.ActiveOrderList = ActiveOrder.getAllActiveOrdersForCustomer(customerRec.Id, system.JSON.serialize(pageSort));  
    	
    }
    
    /**
     * Name: parse
     * Desc: Method to Parse JSON String to class instance
     * @param:  (1) JSONString - String - JSON String 
     * @return: CustomerDetail - Class Object
    **/
    public static CustomerDetail parse(String json) {
        return (CustomerDetail) System.JSON.deserialize(json, CustomerDetail.class);
    }
    
}