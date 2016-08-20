public with sharing class AccountingPartFIFOWrapper {
    public static String FIFOBucketId;
	public static String UniqueId;
	public static String CreatedDate;
	public static String PartId;
	public static String PartName;
	public static String Gst;
	public static String Inclusive;
	public static String Category;
	public static String IsCredit;
	public static Decimal Amount;
	public static String TaxCode;
	public static String AllocationMemo; 
	public static String SourceName;
	//public final static String StockAdjustmentValue = '2-1530';
	
	
	//public List<PartFIFOActivityLineItem> PartFIFOActivityLineItemList = new List<PartFIFOActivityLineItem>();
	
	public static string  AccountingPartFIFOWrapperRec(Part_FIFO_Bucket__c partFifoBucketRec, String StockAdjustmentValue){
		
		UniqueId = partFifoBucketRec.Unique_Id__c;
		CreatedDate = partFifoBucketRec.CreatedDate!= null ? partFifoBucketRec.CreatedDate.format(DataExportService.dateFormat) : System.now().format(DataExportService.dateFormat) ;
		FIFOBucketId =  partFifoBucketRec.Id;
		SourceName = partFifoBucketRec.Source_Name__c;
		
			
		Gst = 'P';
		Inclusive = 'X';
		Category = (partFifoBucketRec.Part__r.Category__r != null && partFifoBucketRec.Part__r.Category__r.Inventory_GL__c != null) ? partFifoBucketRec.Part__r.Category__r.Inventory_GL__c : ''; 
		IsCredit = 'N';
		PartId = partFifoBucketRec.Part__r.Part_ID__c+ ';' + 'Count Adjustment';
		Amount = ((partFifoBucketRec.Qty_In__c == null? 0 :partFifoBucketRec.Qty_In__c) * (partFifoBucketRec.Cost__c == null ? 0 : partFifoBucketRec.Cost__c)).setScale(2);
		AllocationMemo = partFifoBucketRec.Part__r.Part_ID__c + ' - increased by ' + (partFifoBucketRec.Qty_In__c==null? 0: partFifoBucketRec.Qty_In__c).setScale(2)  + '@$'+ (partFifoBucketRec.cost__c == null ?0:partFifoBucketRec.cost__c).setScale(2);
		TaxCode = 'N-T';	
		 
		String value =  UniqueId + '\t' + CreatedDate + '\t'+ partId+ '\t'+Gst+'\t'+ Inclusive+'\t'+Category+'\t' + IsCredit+'\t'+ '$'+Amount+'\t'+ TaxCode+'\t'+AllocationMemo+'\n';
		value  += UniqueId + '\t' + CreatedDate + '\t'+ partId+ '\t'+Gst+'\t'+ Inclusive+'\t'+StockAdjustmentValue+'\tY\t'+ '$'+Amount+'\t'+ TaxCode+'\t'+AllocationMemo;
		//System.assert(false,value);
		return value;
		
	}
	
	

	public static string PartFIFOActivityLineItemRec(Part_FIFO_Bucket_Activity_Line_Item__c partFifoActivityLineItemRec, Part_FIFO_Bucket__c partFifoBucketRec, String StockAdjustmentValue ){
		UniqueId = partFifoActivityLineItemRec.Unique_Id__c ==  NULL ? partFifoBucketRec.Unique_Id__c: partFifoActivityLineItemRec.Unique_Id__c ;
		CreatedDate = partFifoActivityLineItemRec.CreatedDate!= null ? partFifoActivityLineItemRec.CreatedDate.format(DataExportService.dateFormat) : System.now().format(DataExportService.dateFormat) ;
		FIFOBucketId =  partFifoActivityLineItemRec.Id;
		SourceName = partFifoBucketRec.Source_Name__c;
		
			
		Gst = 'P';
		Inclusive = 'X';
		Category = (partFifoBucketRec.Part__r.Category__r != null && partFifoBucketRec.Part__r.Category__r.Inventory_GL__c != null) ? partFifoBucketRec.Part__r.Category__r.Inventory_GL__c : ''; 
		IsCredit = 'Y';
		PartId = partFifoBucketRec.Part__r.Part_ID__c+ ';' + 'Count Adjustment';
		Amount = ((partFifoActivityLineItemRec.Qty_Out__c == null? 0 :partFifoActivityLineItemRec.Qty_Out__c) * (partFifoBucketRec.Cost__c == null ? 0 : partFifoBucketRec.Cost__c)).setScale(2);
		AllocationMemo = partFifoBucketRec.Part__r.Part_ID__c + ' - reduced by ' + (partFifoActivityLineItemRec.Qty_Out__c == null? 0 :partFifoActivityLineItemRec.Qty_Out__c).setScale(2)  + '@$'+ (partFifoBucketRec.cost__c == null ?0:partFifoBucketRec.cost__c).setScale(2);
		TaxCode = 'N-T';	
		 
		String value =  UniqueId + '\t' + CreatedDate + '\t'+ partId+ '\t'+Gst+'\t'+ Inclusive+'\t'+Category+'\t' + IsCredit+'\t'+'$'+ Amount+'\t'+ TaxCode+'\t'+AllocationMemo+'\n';
		value += UniqueId + '\t' + CreatedDate + '\t'+ partId+ '\t'+Gst+'\t'+ Inclusive+'\t'+StockAdjustmentValue+'\tN\t'+'$'+ Amount+'\t'+ TaxCode+'\t'+AllocationMemo;
		return value;
	}
		
		
		
	public static string  AccountingPartFIFOWrapperCostRec(Part_FIFO_Bucket__c partFifoBucketRec, String StockAdjustmentValue){
		
		UniqueId = partFifoBucketRec.Unique_Id__c;
		CreatedDate = partFifoBucketRec.CreatedDate!= null ? partFifoBucketRec.CreatedDate.format(DataExportService.dateFormat) : System.now().format(DataExportService.dateFormat) ;
		FIFOBucketId =  partFifoBucketRec.Id;
		SourceName = partFifoBucketRec.Source_Name__c;
		Gst = 'P';
		Inclusive = 'X';
		Category = (partFifoBucketRec.Part__r.Category__r != null && partFifoBucketRec.Part__r.Category__r.Inventory_GL__c != null) ? partFifoBucketRec.Part__r.Category__r.Inventory_GL__c : ''; 
		IsCredit = 'N';
		PartId = partFifoBucketRec.Part__r.Part_ID__c+ ';' + 'Cost Adjustment';
		Amount = ((partFifoBucketRec.Qty_In__c == null? 0 :partFifoBucketRec.Qty_In__c) * (partFifoBucketRec.Cost__c == null ? 0 : partFifoBucketRec.Cost__c)).setScale(2);
		AllocationMemo = partFifoBucketRec.Part__r.Part_ID__c + ' - increased by ' + (partFifoBucketRec.Qty_In__c==null? 0: partFifoBucketRec.Qty_In__c).setScale(2)  + '@$'+ (partFifoBucketRec.cost__c == null ?0:partFifoBucketRec.cost__c).setScale(2);
		TaxCode = 'N-T';	
	 
		String value =  UniqueId + '\t' + CreatedDate + '\t'+ partId+ '\t'+Gst+'\t'+ Inclusive+'\t'+Category+'\t' + IsCredit+'\t'+'$'+ Amount+'\t'+ TaxCode+'\t'+AllocationMemo+'\n';
		value  += UniqueId + '\t' + CreatedDate + '\t'+ partId+ '\t'+Gst+'\t'+ Inclusive+'\t'+StockAdjustmentValue+'\tY\t'+'$'+ Amount+'\t'+ TaxCode+'\t'+AllocationMemo;
		//System.assert(false,value);
		return value;
		
	}
	
	

	public static string PartFIFOActivityCostLineItemRec(Part_FIFO_Bucket_Activity_Line_Item__c partFifoActivityLineItemRec, Part_FIFO_Bucket__c partFifoBucketRec, String StockAdjustmentValue ){
		UniqueId = partFifoActivityLineItemRec.Unique_Id__c ==  NULL ? partFifoBucketRec.Unique_Id__c: partFifoActivityLineItemRec.Unique_Id__c ;
		CreatedDate = partFifoActivityLineItemRec.CreatedDate!= null ? partFifoActivityLineItemRec.CreatedDate.format(DataExportService.dateFormat) : System.now().format(DataExportService.dateFormat) ;
		FIFOBucketId =  partFifoBucketRec.Id;
		SourceName = partFifoBucketRec.Source_Name__c;
		
			
		Gst = 'P';
		Inclusive = 'X';
		Category = (partFifoBucketRec.Part__r.Category__r != null && partFifoBucketRec.Part__r.Category__r.Inventory_GL__c != null) ? partFifoBucketRec.Part__r.Category__r.Inventory_GL__c : ''; 
		IsCredit = 'Y';
		PartId = partFifoBucketRec.Part__r.Part_ID__c+ ';' + 'Cost Adjustment';
		Amount = ((partFifoActivityLineItemRec.Qty_Out__c == null? 0 :partFifoActivityLineItemRec.Qty_Out__c) * (partFifoBucketRec.Cost__c == null ? 0 : partFifoBucketRec.Cost__c)).setScale(2);
		AllocationMemo = partFifoBucketRec.Part__r.Part_ID__c + ' - reduced by ' + (partFifoBucketRec.Qty_Out__c == null? 0 :partFifoBucketRec.Qty_Out__c).setScale(2)  + '@$'+ (partFifoBucketRec.cost__c == null ?0:partFifoBucketRec.cost__c).setScale(2);
		TaxCode = 'N-T';	
		 
		String value =  UniqueId + '\t' + CreatedDate + '\t'+ partId+ '\t'+Gst+'\t'+ Inclusive+'\t'+Category+'\t' + IsCredit+'\t'+'$'+ Amount+'\t'+ TaxCode+'\t'+AllocationMemo+'\n';
		value += UniqueId + '\t' + CreatedDate + '\t'+ partId+ '\t'+Gst+'\t'+ Inclusive+'\t'+StockAdjustmentValue+'\tN\t'+'$'+ Amount+'\t'+ TaxCode+'\t'+AllocationMemo;
		return value;
	}
	
	
	
	public static string PartFIFOActivityCostAdjustItemRec(Part_FIFO_Bucket_Activity_Line_Item__c partFifoActivityLineItemRec, String StockAdjustmentValue ){
		UniqueId = partFifoActivityLineItemRec.Unique_Id__c == null ? partFifoActivityLineItemRec.Part_Adjustment__r.Unique_Id__c :partFifoActivityLineItemRec.Unique_Id__c  ;
		CreatedDate = partFifoActivityLineItemRec.CreatedDate!= null ? partFifoActivityLineItemRec.CreatedDate.format(DataExportService.dateFormat) : System.now().format(DataExportService.dateFormat) ;
		FIFOBucketId =  partFifoActivityLineItemRec.Id;
		//SourceName = partFifoBucketRec.Source_Name__c;
		
			
		Gst = 'P';
		Inclusive = 'X';
		Category = (partFifoActivityLineItemRec.Part_FIFO_Bucket__r.Part__r.Category__r != null && partFifoActivityLineItemRec.Part_FIFO_Bucket__r.Part__r.Category__r.Inventory_GL__c != null) ? partFifoActivityLineItemRec.Part_FIFO_Bucket__r.Part__r.Category__r.Inventory_GL__c : ''; 
		IsCredit = 'Y';
		PartId = partFifoActivityLineItemRec.Part_FIFO_Bucket__r.Part__r.Part_ID__c+ ';' + 'Cost Adjustment';
		Amount = ((partFifoActivityLineItemRec.Qty_Out__c == null? 0 :partFifoActivityLineItemRec.Qty_Out__c) * (partFifoActivityLineItemRec.Part_FIFO_Bucket__r.Cost__c == null ? 0 : partFifoActivityLineItemRec.Part_FIFO_Bucket__r.Cost__c)).setScale(2);
		AllocationMemo = partFifoActivityLineItemRec.Part_FIFO_Bucket__r.Part__r.Part_Id__c + ' - reduced by ' + (partFifoActivityLineItemRec.Qty_Out__c == null? 0 :partFifoActivityLineItemRec.Qty_Out__c).setScale(2)  + '@$'+ (partFifoActivityLineItemRec.Part_FIFO_Bucket__r.cost__c == null ?0:partFifoActivityLineItemRec.Part_FIFO_Bucket__r.cost__c).setScale(2);
		TaxCode = 'N-T';	
		 
		String value =  UniqueId + '\t' + CreatedDate + '\t'+ partId+ '\t'+Gst+'\t'+ Inclusive+'\t'+Category+'\t' + IsCredit+'\t'+'$'+ Amount+'\t'+ TaxCode+'\t'+AllocationMemo+'\n';
		value += UniqueId + '\t' + CreatedDate + '\t'+ partId+ '\t'+Gst+'\t'+ Inclusive+'\t'+StockAdjustmentValue+'\tN\t'+'$'+ Amount+'\t'+ TaxCode+'\t'+AllocationMemo;
		return value;
	}
	
	
	public static string PartFIFOActivityCountAdjustItemRec(Part_FIFO_Bucket_Activity_Line_Item__c partFifoActivityLineItemRec, String StockAdjustmentValue ){
		UniqueId = partFifoActivityLineItemRec.Unique_Id__c == null ? partFifoActivityLineItemRec.Part_Adjustment__r.Unique_Id__c :partFifoActivityLineItemRec.Unique_Id__c  ;
		CreatedDate = partFifoActivityLineItemRec.CreatedDate!= null ? partFifoActivityLineItemRec.CreatedDate.format(DataExportService.dateFormat) : System.now().format(DataExportService.dateFormat) ;
		FIFOBucketId =  partFifoActivityLineItemRec.Id;
		//SourceName = partFifoBucketRec.Source_Name__c;
		
			
		Gst = 'P';
		Inclusive = 'X';
		Category = (partFifoActivityLineItemRec.Part_FIFO_Bucket__r.Part__r.Category__r != null && partFifoActivityLineItemRec.Part_FIFO_Bucket__r.Part__r.Category__r.Inventory_GL__c != null) ? partFifoActivityLineItemRec.Part_FIFO_Bucket__r.Part__r.Category__r.Inventory_GL__c : ''; 
		IsCredit = 'Y';
		PartId = partFifoActivityLineItemRec.Part_FIFO_Bucket__r.Part__r.Part_ID__c+ ';' + 'Count Adjustment';
		Amount = ((partFifoActivityLineItemRec.Qty_Out__c == null? 0 :partFifoActivityLineItemRec.Qty_Out__c) * (partFifoActivityLineItemRec.Part_FIFO_Bucket__r.Cost__c == null ? 0 : partFifoActivityLineItemRec.Part_FIFO_Bucket__r.Cost__c)).setScale(2);
		AllocationMemo = partFifoActivityLineItemRec.Part_FIFO_Bucket__r.Part__r.Part_Id__c + ' - reduced by ' + (partFifoActivityLineItemRec.Qty_Out__c == null? 0 :partFifoActivityLineItemRec.Qty_Out__c).setScale(2)  + '@$'+ (partFifoActivityLineItemRec.Part_FIFO_Bucket__r.cost__c == null ?0:partFifoActivityLineItemRec.Part_FIFO_Bucket__r.cost__c).setScale(2);
		TaxCode = 'N-T';	
		 
		String value =  UniqueId + '\t' + CreatedDate + '\t'+ partId+ '\t'+Gst+'\t'+ Inclusive+'\t'+Category+'\t' + IsCredit+'\t'+'$'+ Amount+'\t'+ TaxCode+'\t'+AllocationMemo+'\n';
		value += UniqueId + '\t' + CreatedDate + '\t'+ partId+ '\t'+Gst+'\t'+ Inclusive+'\t'+StockAdjustmentValue+'\tN\t'+'$'+Amount+'\t'+ TaxCode+'\t'+AllocationMemo;
		return value;
	}
}