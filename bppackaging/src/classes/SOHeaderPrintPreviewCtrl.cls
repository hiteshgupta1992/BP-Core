/**
* Author: Tarun Khandelwal
* Since: Jan 13, 2016
* Name: SOHeaderPrintPreviewCtrl
* Description: Apex class which gives SO Header Info used in Print Preview Page
**/
global with sharing class SOHeaderPrintPreviewCtrl {
	
	/**
    * Name: getPrinitngInfo
    * Desc: Method to get json string related to Prinitng Info of Service Header Order
    * @param:  (1) soHeaderId - String - Id of SO Header Record
    * @return: String - JSON String of SO Header Detail Record
    **/
    @RemoteAction 
    global static String getPrinitngInfo(String soHeaderId){
    	soHeaderId = BPUtility.getDecodedString(soHeaderId);
    	List<CO_Header__c> coHeaderRecs = new List<CO_Header__c>();
    	List<Customer_Owned_Unit__c> couRecords = new List<Customer_Owned_Unit__c>();
    	List<Account> customerList = new List<Account>();
    	List<Service_Order_Kit_Header__c> soKitHeaderList = new List<Service_Order_Kit_Header__c>();
    	
    	List<Service_Order_Header__c> soHeaderRecList = SOQLUtil.getSODetailsByFieldName(new Map<String, String>{'Id' => soHeaderId});
    	if(soHeaderRecList.size() == 0) {
    		return BPUtility.getEncodedString('{}');
    	}
    	
    	soKitHeaderList = SOQLUtil.getSOKitHeaderByFieldName(new Map<String, String>{'Service_Order_Header__c' => soHeaderId});
    	Service_Order_Header__c soHeaderRec = soHeaderRecList[0];
    	coHeaderRecs = SOQLUtil.getCOHeaderDetails(soHeaderRec.CO_Header__c);
    	
    	
    	if(coHeaderRecs.size() > 0 && coHeaderRecs[0].Customer__c != null) {
            couRecords = (soHeaderRec.Customer_Owned_Unit__c != null) ? SOQLUtil.getCOUListByFieldName('Id', soHeaderRec.Customer_Owned_Unit__c) : new List<Customer_Owned_Unit__c>();
            customerList = SOQLUtil.getCustomer(coHeaderRecs[0].Customer__c, null);
        }
        PrintingInfo printingInfoObj = new PrintingInfo(customerList, couRecords, coHeaderRecs, soHeaderRec, soKitHeaderList);
        
        return BPUtility.getEncodedString(System.JSON.serialize(printingInfoObj));  
    }
	
	
	public class PrintingInfo {
		
		public Customer CustomerInfo;
		public CustomerOwnedUnit COUInfo;
		public COHeader COHeaderInfo;
		public SOHeaderWrapper.SOHeader SOHeaderInfo;
		public SOHeaderWrapper.SOReview SOReviewInfo;
		public List<SOHeaderWrapper.SOGrid> SOGridItems;
		public Decimal Total_Part;
		public Decimal Total_Laobur;
		public Decimal Total_Sublet;
		public Decimal Total_Other;
		public Decimal Total;
		
		
		public PrintingInfo(List<Account> customerList, List<Customer_Owned_Unit__c> couList, List<CO_Header__c> coHeaderList, Service_Order_Header__c soHeaderRec, 
								List<Service_Order_Kit_Header__c> soKitHeaderList) {
			this.SOGridItems = new List<SOHeaderWrapper.SOGrid>();
			
			this.CustomerInfo = (customerList.size() > 0) ? new Customer(customerList[0]) : new Customer(new Account());
			this.COUInfo = (couList.size() > 0) ? new CustomerOwnedUnit(couList[0]) : new CustomerOwnedUnit(new Customer_Owned_Unit__c());
			this.COHeaderInfo = (coHeaderList.size() > 0) ? new COHeader(coHeaderList[0]) : new COHeader(new CO_Header__c());
			this.SOHeaderInfo = new SOHeaderWrapper.SOHeader(soHeaderRec);
			this.SOReviewInfo = new SOHeaderWrapper.SOReview(soHeaderRec);
			
			this.Total_Part = 0;
			this.Total_Laobur = 0;
			this.Total_Sublet = 0;
			this.Total_Other = 0;
			this.Total = 0;
			
			Set<Id> soliIdSet = new Set<Id>();
			for(Service_Order_Kit_Header__c soKHRec : soKitHeaderList) {
				this.SOGridItems.add(new SOHeaderWrapper.SOGrid(soKHRec, soKHRec.Service_Order_Line_Items__r, true));
            	for(Service_Order_Line_Item__c soliRec : sokhRec.Service_Order_Line_Items__r) {
            		soliIdSet.add(soliRec.Id);
            		if(soliRec.Labour_Code__c != null && soliRec.Part__c == null) {
            			this.Total_Laobur += (soliRec.Total__c != null) ? soliRec.Total__c : 0;
            		} else if(soliRec.Labour_Code__c == null && soliRec.Part__c != null) {
            			this.Total_Part += (soliRec.Total__c != null) ? soliRec.Total__c : 0;
            		} else if(soliRec.Fee__c != null) {
            			this.Total_Other += (soliRec.Total__c != null) ? soliRec.Total__c : 0;
            		}
            	} 
			}
			
			for(Service_Order_Line_Item__c soliRec : soHeaderRec.Service_Order_Line_Items__r) {
        		if(!soliIdSet.contains(soliRec.Id)) {
    				this.SOGridItems.add(new SOHeaderWrapper.SOGrid(new Service_Order_Kit_Header__c(), new List<Service_Order_Line_Item__c>{soliRec}, false));
    				if(soliRec.Labour_Code__c != null && soliRec.Part__c == null) {
            			this.Total_Laobur += (soliRec.Total__c != null) ? soliRec.Total__c : 0;
            		} else if(soliRec.Labour_Code__c == null && soliRec.Part__c != null) {
            			this.Total_Part += (soliRec.Total__c != null) ? soliRec.Total__c : 0;
            		} else if(soliRec.Fee__c != null) {
            			this.Total_Other += (soliRec.Total__c != null) ? soliRec.Total__c : 0;
            		}
        		}
        	}
        	this.Total = this.Total_Part + this.Total_Laobur + this.Total_Sublet + this.Total_Other;
		}
	}
	
	public class Customer {
		
		public String FirstName;
		public String LastName;
		public String BusinessName;
		public String NickName;
		public String Type;
		public Boolean Active;
	    public String FacebookLink;
	    public String TwitterLink;
	    public String LinkedInLink;
		
		public Customer(Account customerRec) {
			this.BusinessName = customerRec.Name;
			this.FirstName = customerRec.FirstName__c;
    		this.LastName = customerRec.LastName__c;
    		this.Nickname = (customerRec.Nickname__c == null) ? '' : customerRec.Nickname__c;
    		this.Type = customerRec.Type__c;
    		this.Active = customerRec.Active__c;
    		this.FacebookLink = (customerRec.Facebook__c == null) ? '' : customerRec.Facebook__c;
	    	this.TwitterLink = (customerRec.Twitter__c == null) ? '' : customerRec.Twitter__c;
	    	this.LinkedInLink = (customerRec.LinkedIn__c == null) ? '' : customerRec.LinkedIn__c;
		}
	}
	
	public class COHeader {
		public String COHeaderName;
		
		public COHeader(CO_Header__c coHeaderRec) {
			this.COHeaderName = coHeaderRec.Name;
		}
	}
}