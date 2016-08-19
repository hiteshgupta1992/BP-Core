/**
 * Author: Hitesh Gupta
 * Since: Dec. 23, 2015
 * Name: ServiceOrderLineItemTriggerHelper
 * Description: Helper class for triggers on SOLI.
**/
public class ServiceOrderLineItemTriggerHelper {
	
	// List to store trigger new list
    public static List<Service_Order_Line_Item__c> soliNewList = new List<Service_Order_Line_Item__c>();
    
    // List to store trigger old list
    public static List<Service_Order_Line_Item__c> soliOldList = new List<Service_Order_Line_Item__c>();
    
    // Map to store new Trigger Map
    public static Map<Id, Service_Order_Line_Item__c> soliNewMap = new Map<Id, Service_Order_Line_Item__c>();
    
    // Map to store Old Trigger Map
    public static Map<Id, Service_Order_Line_Item__c> soliOldMap = new Map<Id, Service_Order_Line_Item__c>();
    
    // Boolean to stop trigger
    public static Boolean isTriggerExecuted = false;
    
    
    /**
     * Name: afterInsertCalculation
     * Desc: before update operations
     * @param: 
     * @return: 
    **/
    public static void afterInsertCalculation() {
    	if(!isTriggerExecuted) {
    		insertCOLIs();
    	}
    }
    
    /**
     * Name: afterUpdateCalculation
     * Desc: before update operations
     * @param: 
     * @return: 
    **/
    public static void beforeUpdateCalculation() {
    	insertCOLIs();
    }
    
    
    public static void afterUpdateCalculation() {
    	updateTotalOnSOHeader(soliNewList);
    }
    
    
    private static void updateTotalOnSOHeader(List<Service_Order_Line_Item__c> soliList) {
    	Set<Id> soHeaderIdSet = new Set<Id>();
    	for(Service_Order_Line_Item__c soliRec : soliList) {
    		soHeaderIdSet.add(soliRec.Service_Order_Header__c);
    	}
    	
    	if(AccessControl.ifObjectFieldIsAccessible('Service_Order_Header__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
    	List<Service_Order_Header__c> soHeaderList = [select Total__c, Tax_Amount__c, (select Total__c, Tax__c from Service_Order_Line_Items__r) 
    																from Service_Order_Header__c
    																where Id IN : soHeaderIdSet];
    	
    	for(Service_Order_Header__c soHeaderRec : soHeaderList) {					 										
    		Decimal total = 0;
    		Decimal taxAmount = 0;
    		for(Service_Order_Line_Item__c soliRec : soHeaderRec.Service_Order_Line_Items__r) {
    			total += soliRec.Total__c;
    			taxAmount += (soliRec.Total__c * soliRec.Tax__c) / 100;
    		}
    		soHeaderRec.Total__c = total;
    		soHeaderRec.Tax_Amount__c = taxAmount;
    	}
    	
    	if(soHeaderList.size() > 0) {
    		if(AccessControl.ifObjectFieldIsUpdateable('Service_Order_Header__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_UPDATEABLE); }
    		update soHeaderList;
    	}
    }
    
    /**
     * Name: afterInsertCalculation
     * Desc: before update operations
     * @param: 
     * @return: 
    **/
    public static void beforeDeleteCalculation() {
    	if(isTriggerExecuted) {
    		return;
    	}
    	
    	if(AccessControl.ifObjectFieldIsAccessible('Service_Order_Line_Item__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
    	if(AccessControl.ifObjectIsDeletable('CO_Line_Item__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_DELETABLE); }
    	if(AccessControl.ifObjectFieldIsAccessible('CO_Line_Item__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
    	List<Service_Order_Line_Item__c> soliList = [select Id, (select Id from CO_Line_Items__r) from Service_Order_Line_Item__c where Id =: soliOldList];
    	List<CO_Line_Item__c> coliListToDelete = new List<CO_Line_Item__c>();
    	for(Service_Order_Line_Item__c soliRec : soliList) {
    		if(soliRec.CO_Line_Items__r != null && soliRec.CO_Line_Items__r.size() > 0) {
    			coliListToDelete.add(soliRec.CO_Line_Items__r[0]);
    		}
    	}
    	
    	if(coliListToDelete.size() > 0) {
    		if(AccessControl.ifObjectIsDeletable('CO_Line_Item__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_DELETABLE); }
    		delete coliListToDelete;
    	}
    }
    
    /**
     * Name: insertCOLIs
     * Desc: create Coli on create of Soli
     * @param: Set<Id> soliIds
     * @return: 
    **/
    public static void insertCOLIs() {
		if(AccessControl.ifObjectFieldIsCreateable('CO_Line_Item__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_CREATEABLE); }
		if(AccessControl.ifObjectFieldIsUpdateable('CO_Line_Item__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_UPDATEABLE); }
    	if(AccessControl.ifObjectFieldIsAccessible('Service_Order_Line_Item__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
    	Map<Id, Service_Order_Line_Item__c> soliMap = new Map<Id, Service_Order_Line_Item__c>([select Service_Order_Header__c, Service_Order_Kit_Header__c, Service_Order_Header__r.CO_Header__c from Service_Order_Line_Item__c where Id in: soliNewList]);
    	List<CO_Line_Item__c> coliList = new List<CO_Line_Item__c>();
    	CO_Line_Item__c coli;
    	
    	for(Service_Order_Line_Item__c soli : soliNewList) {
    		if(soli.Part__c != null) {
    			coli = new CO_Line_Item__c();
    			if(soli.CO_Line_Item__c != null) {
    				coli.Id = soli.CO_Line_Item__c;
    			}
				coli.Service_Order_Line_Item__c = soli.Id;
				coli.Part__c = soli.Part__c;
				coli.Qty__c = soli.Qty_Needed__c;
				if(soli.Qty_Needed__c > 0) {
					coli.Qty_Committed__c = soli.Qty_Committed__c;
				} 
					
				if(soliMap.get(soli.Id).Service_Order_Kit_Header__c != null) {
					coli.Price__c = soli.Kit_Price__c;
				}
				//coli.Retail__c = soli.Retail_Price__c;
 				coli.CO_Header__c =  (soliMap.get(soli.Id).Service_Order_Header__c != null && soliMap.get(soli.Id).Service_Order_Header__r.CO_Header__c != null) 
 										? soliMap.get(soli.Id).Service_Order_Header__r.CO_Header__c : null;
 				coliList.add(coli);
    		}
    	}
    	if(coliList.size() > 0) {
    		system.debug('%%%%%%%'+coliList);
    	
    		upsert coliList;
    		if(trigger.isInsert) {
    			populateSOLIsField();
    		} else if(trigger.IsUpdate) {
    			populateSOLIsFieldBeforeUpdate();
    		}
    	}
    	if(AccessControl.ifObjectFieldIsAccessible('Service_Order_Line_Item__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
    	List<Service_Order_Line_Item__c> soliList = [select Qty_To_Order__c, Service_Order_Header__c, Service_Order_Header__r.CO_Header__c from Service_Order_Line_Item__c where Id IN :trigger.New];
    	
    	List<Id> soHeaderIdList = new List<Id>();
    	List<Id> coHeaderIdList = new List<Id>();
    	
    	for(Service_Order_Line_Item__c soliRec : soliList) {
    		if(soliRec.Service_Order_Header__c != null) {
	    		soHeaderIdList.add(soliRec.Service_Order_Header__c);
	    		if(soliRec.Service_Order_Header__r.CO_Header__c != null) {
    				coHeaderIdList.add(soliRec.Service_Order_Header__r.CO_Header__c);
	    		}
    		}
    	}
    	
    	if(AccessControl.ifObjectFieldIsAccessible('Service_Order_Header__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
    	if(AccessControl.ifObjectFieldIsAccessible('CO_Invoice_Item__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
    	if(AccessControl.ifObjectFieldIsAccessible('CO_Invoice_Header__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
    	
    	List<Service_Order_Header__c> soHeaderList = [select Id, CO_Header__c, (select isActive__c, Is_Invoiceable__c from CO_Invoice_Items__r), 
    														(select Qty_To_Order__c, Tax__c, Total__c from Service_Order_Line_Items__r) 
    														from Service_Order_Header__c where Id IN : soHeaderIdList AND Transaction_Type__r.Type__c != 'Third-Party'];
    	List<CO_Invoice_Header__c> coInvoiceHeaderList = [select Id, Invoice_Status__c, CO_Header__c from CO_Invoice_Header__c where CO_Header__c IN :coHeaderIdList AND Invoice_Status__c = 'Active'];
    	
    	Map<Id, CO_Invoice_Header__c> coHeaderIdToCOInvoiceHeaderRecMap = new Map<Id, CO_Invoice_Header__c>();
        for(CO_Invoice_Header__c coInvoiceHeaderRec : coInvoiceHeaderList) {
            coHeaderIdToCOInvoiceHeaderRecMap.put(coInvoiceHeaderRec.CO_Header__c, coInvoiceHeaderRec);
        }
        
    	Map<Id, CO_Invoice_Item__c> coInvoiceItemMap = new Map<Id,CO_Invoice_Item__c>();
    	
    	for(Service_Order_Header__c soHeaderRec : soHeaderList) {
	    	Boolean IsInvoiceable = true;
	    	Decimal total = 0;
	    	Decimal taxAmount = 0;
	    	for(Service_Order_Line_Item__c soliRec : soHeaderRec.Service_Order_Line_Items__r) {
	    		if(soliRec.Qty_To_Order__c > 0) {
	    			IsInvoiceable = false;
	    		}
	    		total += soliRec.Total__c;
	    		taxAmount += (soliRec.Total__c * soliRec.Tax__c) / 100;
	    	}
	    	soHeaderRec.Total__c = total;
	    	soHeaderRec.Tax_Amount__c = taxAmount;
	    	CO_Invoice_Item__c coInvoiceItem = new CO_Invoice_Item__c();
	    	if(soHeaderRec.CO_Invoice_Items__r.size() == 1) {
    			coInvoiceItem.Id = soHeaderRec.CO_Invoice_Items__r[0].Id;
    			coInvoiceItem.Is_Invoiceable__c = IsInvoiceable;
    			//coInvoiceItem.Service_Order_Header__c = soHeaderRec.Id;
    		} else {
    			if(coHeaderIdToCOInvoiceHeaderRecMap.containsKey(soHeaderRec.CO_Header__c)) {
	                coInvoiceItem.CO_Invoice_Header__c = coHeaderIdToCOInvoiceHeaderRecMap.get(soHeaderRec.CO_Header__c).Id;
	            } else {
	                CO_Invoice_Header__c coInvoiceHeaderRec = COLineItemTriggerHelper.insertCOInvoiceHeader(soHeaderRec.CO_Header__c);
	                coInvoiceItem.CO_Invoice_Header__c = coInvoiceHeaderRec.Id;
	                coHeaderIdToCOInvoiceHeaderRecMap.put(coInvoiceHeaderRec.CO_Header__c, coInvoiceHeaderRec);
	            }
	            coInvoiceItem.isActive__c = true; 
    			coInvoiceItem.Is_Invoiceable__c = IsInvoiceable;
    			coInvoiceItem.Service_Order_Header__c = soHeaderRec.Id;
    			
    		}
	    	coInvoiceItemMap.put(coInvoiceItem.Id, coInvoiceItem);
    	}
    	
    	if(soHeaderList.size() > 0) {
    		if(AccessControl.ifObjectFieldIsUpdateable('Service_Order_Header__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_UPDATEABLE); }
    		update soHeaderList;
    	}
    	
    	if(coInvoiceItemMap.size() > 0 ) {
    		if(AccessControl.ifObjectFieldIsUpdateable('CO_Invoice_Item__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_UPDATEABLE); }
    		if(AccessControl.ifObjectFieldIsCreateable('CO_Invoice_Item__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_CREATEABLE); }
    		upsert coInvoiceItemMap.values();
    	} 
    }
    
    /**
     * Name: populateSOLIsFieldBeforeUpdate
     * Desc: update Soli based on Coli create operations
     * @param: Set<Id> soliIds
     * @return: 
    **/
    public static void populateSOLIsFieldBeforeUpdate() {
    	List<Service_Order_Line_Item__c> soliList = [select CO_Line_Item__c, Service_Order_Kit_Header__c, Kit_Price__c, (Select Id, Qty_Committed__c, Price__c from CO_Line_Items__r) from Service_Order_Line_Item__c where Id in: soliNewList];
    												
    	for(Service_Order_Line_Item__c soliRec : soliList) {
    		if(soliRec.CO_Line_Items__r != null && soliRec.CO_Line_Items__r.size() > 0) {
    			soliNewMap.get(soliRec.Id).CO_Line_Item__c = soliRec.CO_Line_Items__r[0].Id;
    			soliNewMap.get(soliRec.Id).Qty_Committed__c = soliRec.CO_Line_Items__r[0].Qty_Committed__c;
    			if(soliRec.Service_Order_Kit_Header__c == null) {
    				//soliNewMap.get(soliRec.Id).Kit_Price__c = soliRec.CO_Line_Items__r[0].Price__c;
    				//soliNewMap.get(soliRec.Id).Actual_Kit_Price__c = soliRec.CO_Line_Items__r[0].Price__c;
    			}
    			system.debug('$$$$$$$$$$'+soliNewMap);
    		}
    	}
    }
    
    /**
     * Name: populateSOLIsField
     * Desc: update Soli based on Coli create operations
     * @param: Set<Id> soliIds
     * @return: 
    **/
    public static void populateSOLIsField() {
    	List<Service_Order_Line_Item__c> soliList = [select CO_Line_Item__c, Kit_Price__c, Service_Order_Kit_Header__c, (Select Id, Qty_Committed__c, Price__c from CO_Line_Items__r) from Service_Order_Line_Item__c where Id in: soliNewList];
    												
    	for(Service_Order_Line_Item__c soliRec : soliList) {
    		if(soliRec.CO_Line_Items__r != null && soliRec.CO_Line_Items__r.size() > 0) {
    			soliRec.CO_Line_Item__c = soliRec.CO_Line_Items__r[0].Id;
    			soliRec.Qty_Committed__c = soliRec.CO_Line_Items__r[0].Qty_Committed__c;
    			if(soliRec.Service_Order_Kit_Header__c == null) {
	    			soliRec.Kit_Price__c = soliRec.CO_Line_Items__r[0].Price__c;
	    			soliRec.Actual_Kit_Price__c = soliRec.Kit_Price__c;
    			}
    		}
    	}
    	
    	if(soliList.size() > 0) {
    		isTriggerExecuted = true;
    		if(AccessControl.ifObjectFieldIsUpdateable('Service_Order_Line_Item__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_UPDATEABLE); }
    		update soliList;	
    	}
    }
    
    /**
     * Name: processCOInvoiceItem
     * Desc: update CO Invoice Item Accoring to SOLI
     * @param: 
     * @return: 
    **/ 
    public static void processCOInvoiceItem() {
    	if(AccessControl.ifObjectFieldIsUpdateable('CO_Invoice_Item__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_UPDATEABLE); }
    	if(AccessControl.ifObjectIsDeletable('CO_Invoice_Item__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_DELETABLE); }
    	if(AccessControl.ifObjectFieldIsAccessible('Service_Order_Line_Item__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
    	List<Service_Order_Line_Item__c> soliList = [select Qty_To_Order__c, Service_Order_Header__c, Service_Order_Header__r.CO_Header__c from Service_Order_Line_Item__c where Id IN :soliOldList];
    	
    	List<Id> soHeaderIdList = new List<Id>();
    	List<Id> coHeaderIdList = new List<Id>();
    	
    	for(Service_Order_Line_Item__c soliRec : soliList) {
    		if(soliRec.Service_Order_Header__c != null) {
	    		soHeaderIdList.add(soliRec.Service_Order_Header__c);
	    		if(soliRec.Service_Order_Header__r.CO_Header__c != null) {
    				coHeaderIdList.add(soliRec.Service_Order_Header__r.CO_Header__c);
	    		}
    		}
    	}
    	if(AccessControl.ifObjectFieldIsAccessible('Service_Order_Header__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
    	if(AccessControl.ifObjectFieldIsAccessible('CO_Invoice_Item__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
    	
    	List<Service_Order_Header__c> soHeaderList = [select Id, CO_Header__c, (select isActive__c, Is_Invoiceable__c from CO_Invoice_Items__r), 
    																(select Qty_To_Order__c from Service_Order_Line_Items__r where Id NOT IN: soliList) 
    																from Service_Order_Header__c where Id IN : soHeaderIdList];
    	
    	List<CO_Invoice_Item__c> coInvoiceItemList = new List<CO_Invoice_Item__c>();
    	List<CO_Invoice_Item__c> coInvoiceItemListToDel = new List<CO_Invoice_Item__c>();
    	
    	for(Service_Order_Header__c soHeaderRec : soHeaderList) {
	    	Boolean IsInvoiceable = true;
	    	for(Service_Order_Line_Item__c soliRec : soHeaderRec.Service_Order_Line_Items__r) {
	    		if(soliRec.Qty_To_Order__c > 0) {
	    			IsInvoiceable = false;
	    		}
	    	}
	    	CO_Invoice_Item__c coInvoiceItem = new CO_Invoice_Item__c();
	    	if(soHeaderRec.Service_Order_Line_Items__r.size() == 0 && soHeaderRec.CO_Invoice_Items__r.size() > 0) {
	    		coInvoiceItemListToDel.add(soHeaderRec.CO_Invoice_Items__r[0]);
	    	} else if(soHeaderRec.CO_Invoice_Items__r.size() == 1) {
    			coInvoiceItem.Id = soHeaderList[0].CO_Invoice_Items__r[0].Id;
    			coInvoiceItem.Is_Invoiceable__c = IsInvoiceable;
    			coInvoiceItem.Service_Order_Header__c = soHeaderRec.Id;
    			coInvoiceItemList.add(coInvoiceItem);
    		} 
    	}
    	
    	if(coInvoiceItemListToDel.size() > 0) {
    		
    		delete coInvoiceItemListToDel;
    	}
    	
    	if(coInvoiceItemList.size() > 0) {
    		
    		update coInvoiceItemList;
    	}
    	
    	// Update Total
    	updateTotalOnSOHeader(soliOldList);
    }
}