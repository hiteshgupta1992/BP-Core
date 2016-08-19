/**
 * Author: Tarun Khandelwal
 * Since: July 07, 2015
 * Name: VendorDetail
 * Description: Apex class to handle JSON related oprations of Vendor Detail Page.
**/
public with sharing class VendorDetail {
	
	// Vendor Info
	public Vendor VendorDetailRec;
	
	// Vendor related Info
	public VendorRelatedLists VendorRelatedInfo;
	
	// Constructor
    public VendorDetail(Account vendorRec) {
    	this.VendorDetailRec = new Vendor(vendorRec);
    	this.VendorRelatedInfo = new VendorRelatedLists(vendorRec.Id);
    }
    
    /**
     * Name: parse
     * Desc: Method to Parse JSON String to class instance
     * @param:  (1) JSONString - String - JSON String 
     * @return: VendorDetail - Class Object
    **/
    public static VendorDetail parse(String json) {
        return (VendorDetail) System.JSON.deserialize(json, VendorDetail.class);
    }
    
    // Wrapper class for vendor related info lists
    public class VendorRelatedLists {
    	// List for Active Orders
    	public List<ActiveOrder> ActiveOrders;
    	
    	// Total count for Active Orders
    	public Integer TotalActiveOrders;
    	
    	// List for Purchase Order types
    	public List<POType> POTypes;
    	
    	// Total count for Purchase Order types
    	public Integer TotalPOTypes;
    	
    	// Contacts for vendor
    	public List<VendorContact> Contacts;
    	
    	// Total count for Vendor contact records
    	public Integer TotalContacts;
    	
    	// Products for vendor
    	public List<VendorProduct> Products;
    	
    	// Total count for Vendor Product records
    	public Integer TotalProducts;
    	
    	// Constructor
    	public VendorRelatedLists(Id vendorId) {
    		// Active Orders
    		this.ActiveOrders		= ActiveOrder.getAllActiveOrdersForVendor(vendorId, System.JSON.serialize(new ActiveOrder.RelatedListPaginationSorting()) );
    		this.TotalActiveOrders	= ActiveOrder.getTotalActiveOrdersForVendor(vendorId);
    		
    		// Purchase Order types
    		this.POTypes		= POType.getAllPOTypesForVendor( vendorId, System.JSON.serialize(new POType.RelatedListPaginationSorting()) );
    		this.TotalPOTypes	= POType.getTotalPOTypesForVendor(vendorId);
    		
    		// Vendor Contacts
    		this.Contacts		= VendorContact.getAllContactsForVendor( vendorId, System.JSON.serialize(new VendorContact.RelatedListPaginationSorting()) );
    		this.TotalContacts	= VendorContact.getTotalContactsForVendor(vendorId);
    		
    		// Vendor Products
    		this.Products		= VendorProduct.getAllProductsForVendor( vendorId, System.JSON.serialize(new VendorProduct.RelatedListPaginationSorting()) );
    		this.TotalProducts	= VendorProduct.getTotalProductsForVendor(vendorId);
    	}
    }
}