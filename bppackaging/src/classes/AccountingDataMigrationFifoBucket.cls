global with sharing class AccountingDataMigrationFifoBucket implements Database.batchable<sObject>,Database.Stateful {
	// Accounting synch data migration "General Journal Entries" object name
	public static final String ACCOUNTING_OBJECT_NAME = 'General Journal Entries';
	
	// Batch size
	private static final Integer BATCH_SIZE = 1000;
	
	// Data string for all exporatble Vendor Receiving data
	private String generalJournalEntriesData;
	
	// Query string
	private string query;
	
	
	private String value;
	
	
	private String costValue;
	
	// DateTime value for last synched
	private DateTime Last_Synched_Date;
	
	// Index value to maintain total records count
	private integer indexVal;
	
	// "Vendor Receiving card" record of Accounting Data Migration object
	private Accounting_Data_Migration__c dataMigration;
	
	// Boolean to show if to export all records data
	private boolean exportAllData = false;
	
	/**
     * Name: AccountingDataMigrationvendorReceiving
     * Desc: Constructor to start the batch for data export
    **/
	global AccountingDataMigrationFifoBucket(List<Id> recordIds,boolean exportAllData) {
		if(AccessControl.ifObjectFieldIsAccessible('Accounting_Data_Migration__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
		if(AccessControl.ifObjectFieldIsCreateable('Accounting_Data_Migration__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_CREATEABLE); }
		if(AccessControl.ifObjectFieldIsUpdateable('Accounting_Data_Migration__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_UPDATEABLE); }
		
		this.exportAllData = exportAllData;
		generalJournalEntriesData = '';
		indexVal = 1;
		
		// Get the "Vendor Receiving card" record from Accounting Data Migration object
    	try{
    		dataMigration = [Select Id, Last_Synched_Date__c from Accounting_Data_Migration__c where Object_Name__c =: ACCOUNTING_OBJECT_NAME];
    	} catch(QueryException e) {
    		dataMigration = new Accounting_Data_Migration__c(Object_Name__c = AccountingDataMigrationFifoBucket.ACCOUNTING_OBJECT_NAME);
    	}
    	//system.assert(false,dataMigration.Last_Synched_Date__c);
    	//Last synched date value by which we need to filter Accounts data
		// Set Last Synched date for migration record
		//Last_Synched_Date = dataMigration.Last_Synched_Date__c;
		//System.assert(false,Last_Synched_Date);
    	//dataMigration.Last_Synched_Date__c = Datetime.now();
    	
    	query = createQuery(recordIds);
	}
	
	/**
     * Name: executeDataMigrationBatch
     * Desc: Constructor to start the batch for data export
    **/
	public static Id executeDataMigrationBatch(Integer batchSize, List<Id> recordIds, boolean exportAllData) {
		Id batchId = Database.executeBatch(new AccountingDataMigrationFifoBucket(recordIds, exportAllData), batchSize);
		return batchId;
	}
	
	/**
     * Name: start
     * Desc: Batch start method - Create query and execute query locator
     * @param: 
     * @return: Database.QueryLocator
    **/
	global Database.QueryLocator start(Database.BatchableContext BC) {
		return Database.getQueryLocator(query);
	}
	
	/**
     * Name: execute
     * Desc: Batch execute method to process the exported data records
     * @param:	1. Database.BatchableContext BC
     * 			2. List<sObject> scope
     * @return:
    **/
	global void execute(Database.BatchableContext BC, List<sObject> scope) {
		if(AccessControl.ifObjectFieldIsUpdateable('Vendor_Receiving_Group__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_UPDATEABLE); }
		if(AccessControl.ifObjectFieldIsAccessible('GL_Account__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }

		value = '{} \n';
		value +=  'Journal Number\tDate\tMemo\tGST (BAS) Reporting\tInclusive\tAccount Number\tIs Credit\tAmount\tTax Code\tAllocation Memo\n\n';
		costValue = '{} \n';
		costValue +=  'Journal Number\tDate\tMemo\tGST (BAS) Reporting\tInclusive\tAccount Number\tIs Credit\tAmount\tTax Code\tAllocation Memo\n\n';
		List<Part_FIFO_Bucket__c> partFifoRecords = (List<Part_FIFO_Bucket__c>) scope;
		
		if(partFifoRecords.size() > 0){
	    	// Map of General Journal Entries records for all applicable saleforce customer records (a map of VR sf fields to equivalent values)
	    	List<AccountingPartFIFOWrapper> generalJournalEntryRecords = new List<AccountingPartFIFOWrapper>();
	    	
	    	// GL Accounts for deposit
	    	List<GL_Account__c> glAccounts = [Select Id, MYOB_Account_Name__c, MYOB_Account_Number__c, Type__c from GL_Account__c Where Type__c LIKE '%Inventory%'];
	    	Map<String, String> GLAccountMap = new Map<String, String>();
	    	for(GL_Account__c glAcc : glAccounts){
	    		GLAccountMap.put(glAcc.Type__c, glAcc.MYOB_Account_Number__c);
	    	}
	    	
	    	String StockAdjustmentValue = (GLAccountMap.containsKey('Received Inventory Accrual')) ? GLAccountMap.get('Received Inventory Accrual') : '';
	    	String costRecQuery = 'Select Name, Part_FIFO_Bucket__c, Qty_Out__c,CO_Line_Item__c,Part_Adjustment__r.Unique_Id__c,Type__c, Part_FIFO_Bucket__r.Part__r.Category__r.Inventory_GL__c, Part_FIFO_Bucket__r.Part__r.Part_ID__c, Part_FIFO_Bucket__r.Cost__c, Part_Adjustment__c,CreatedDate, Reference__c, Unique_Id__c,Part_FIFO_Bucket__r.Qty_In__c, CO_Invoice_Header__c, LastModifiedDate From Part_FIFO_Bucket_Activity_Line_Item__c where Reference__c = \'Cost Adjustment\' AND Part_FIFO_Bucket__r.Reference__c != \'Cost Adjustment\' ';
	    	String countRecQuery = 'Select Name, Part_FIFO_Bucket__c, Qty_Out__c,CO_Line_Item__c,Part_Adjustment__r.Unique_Id__c,Type__c, Part_FIFO_Bucket__r.Part__r.Category__r.Inventory_GL__c, Part_FIFO_Bucket__r.Part__r.Part_ID__c, Part_FIFO_Bucket__r.Cost__c, Part_Adjustment__c,CreatedDate, Reference__c, Unique_Id__c,Part_FIFO_Bucket__r.Qty_In__c, CO_Invoice_Header__c, LastModifiedDate From Part_FIFO_Bucket_Activity_Line_Item__c where Reference__c = \'Count Adjustment\' AND Part_FIFO_Bucket__r.Reference__c != \'Count Adjustment\'';
	    	
	    	if(Last_Synched_Date != null){
    		//system.assert(false,Last_Synched_Date );
    			costRecQuery += 'And LastModifiedDate >: Last_Synched_Date';
    			countRecQuery += 'And LastModifiedDate >: Last_Synched_Date';
    		}
	    	
			List<Part_FIFO_Bucket_Activity_Line_Item__c> costAdjustRec = Database.query(costRecQuery);
			List<Part_FIFO_Bucket_Activity_Line_Item__c> countAdjustRec = Database.query(countRecQuery);
		 
		
	    for(Part_FIFO_Bucket__c partFIFOBucketItem  :  partFifoRecords){
	    	if(partFIFOBucketItem.Reference__c.toLowerCase().indexOf('Count Adjustment'.toLowerCase()) != -1){
	        	 value += AccountingPartFIFOWrapper.AccountingPartFIFOWrapperRec(partFIFOBucketItem, StockAdjustmentValue);
	        	 value += '\n\n';
	        	for(Part_FIFO_Bucket_Activity_Line_Item__c  fifoActivityRec : partFIFOBucketItem.Part_FIFO_Bucket_Activity_Line_Items__r ){
	        		if(String.isNotBlank(fifoActivityRec.Reference__c)&& fifoActivityRec.Reference__c.toLowerCase().indexOf('Count Adjustment'.toLowerCase()) != -1){
		        		value += AccountingPartFIFOWrapper.PartFIFOActivityLineItemRec(fifoActivityRec, partFIFOBucketItem, StockAdjustmentValue);
		        		value += '\n\n';
	        		}
	        	}
	        		//value += '';
	        		//value += '\n';
		    	system.debug(value);
	    	} else if((partFIFOBucketItem.Reference__c.toLowerCase().indexOf('re'.toLowerCase()) != -1)||(partFIFOBucketItem.Reference__c.toLowerCase().indexOf('Cost Adjustment'.toLowerCase()) != -1)){
	    		costValue += AccountingPartFIFOWrapper.AccountingPartFIFOWrapperCostRec(partFIFOBucketItem, StockAdjustmentValue );
	        	 costValue += '\n\n';
	        	for(Part_FIFO_Bucket_Activity_Line_Item__c  activityRec : partFIFOBucketItem.Part_FIFO_Bucket_Activity_Line_Items__r ){
	        		if(String.isNotBlank(activityRec.Reference__c)&& ((activityRec.Reference__c.toLowerCase().indexOf('Cost Adjustment'.toLowerCase()) != -1) || (activityRec.Reference__c.toLowerCase().indexOf('Pre'.toLowerCase()) != -1))){
		        		costValue += AccountingPartFIFOWrapper.PartFIFOActivityCostLineItemRec(activityRec,partFIFOBucketItem, StockAdjustmentValue);
		        		costValue += '\n\n';
	        		}
	        	}
	    	}  
	    		
	    	}
	    	
	    	if(costAdjustRec.size()>0){
	    		for(Part_FIFO_Bucket_Activity_Line_Item__c  activityRec : costAdjustRec ){
	        		costValue += AccountingPartFIFOWrapper.PartFIFOActivityCostAdjustItemRec(activityRec, StockAdjustmentValue);
	        		costValue += '\n\n';
	        	}
	    	}
	    	
	    	if(countAdjustRec.size()>0){
	    		for(Part_FIFO_Bucket_Activity_Line_Item__c  countRec : countAdjustRec ){
	        		value += AccountingPartFIFOWrapper.PartFIFOActivityCountAdjustItemRec(countRec,StockAdjustmentValue );
	        		value += '\n\n';
	        	}
	    	}
		}
		//System.assert(false,value);
	    	// Now create a string for list of General Journal Entries records so as to convert in format of importable text file for accounting software
    		//generalJournalEntriesData += createImportableTextForGeneralJournalEntries(generalJournalEntryRecords);
    	}
	
	/**
     * Name: finish 
     * Desc: Batch finish method to insert a attachment for exported data in text file
     * @param:	1. Database.BatchableContext BC
     * @return:
    **/
	global void finish(Database.BatchableContext BC) {
		List<Attachment> attachmentsList = new List<Attachment>();
		
    	//upsert dataMigration;
    	
    	Attachment attachment = new Attachment();
		attachment.Body = Blob.valueOf(value);
    	attachment.Name = 'GENERAL_JOURNAL_COUNT_ADJUSTMENT' + DateTime.now().format(DataExportService.fileDateTimeFormat) + '.TXT';
    	attachment.ParentId = dataMigration.Id;  
    	attachment.ContentType = 'text/plain';
    	attachmentsList.add(attachment);
    	
    	attachment = new Attachment();
    	attachment.Body = Blob.valueOf(costValue);
    	attachment.Name = 'GENERAL_JOURNAL_COST_ADJUSTMENT' + DateTime.now().format(DataExportService.fileDateTimeFormat) + '.TXT';
    	attachment.ParentId = dataMigration.Id;  
    	attachment.ContentType = 'text/plain';
    	attachmentsList.add(attachment);
    	
    	if(attachmentsList.size() > 0){
    		insert attachmentsList;
    	}
    	
    	// Execute next batch
    	if(exportAllData){
    		AccountingDataMigrationVendorInvoice.executeDataMigrationBatch(200, null, exportAllData);
    	}
	}
	
	/**
     * Name: createQuery
     * Desc: Method to create a query string for customer orders
     * @param:
     * @return: String
    **/
	public String createQuery(List<Id> recordIds) {
		// Get all vr to be synched here
    	String vrsQuery = 'SELECT ';
    	
    	String standardFieldsQuery = 'Id, Name, CreatedDate ';
    	
    	String customFieldsQuery = ' , Vendor_Receiving_Header__c, Vendor_Invoicing_Header__c, Unique_Id__c, Total__c, Source_Name__c, Remaining_Qty__c, Reference__c,Part__r.Part_Number__c, Type__c, Qty_Out__c, Qty_In__c ,Customer_Return__c, Part__c, Part_Adjust_Number__c, Part__r.Part_ID__c, Is_FIFO_Bucket__c,Part__r.Category__r.Inventory_GL__c, Cost__c';
    	customFieldsQuery += ' ,  (Select Name, Part_FIFO_Bucket__c, Qty_Out__c,CO_Line_Item__c,Part_Adjustment__r.Unique_Id__c,Type__c, Part_Adjustment__c,CreatedDate, Reference__c, Unique_Id__c, CO_Invoice_Header__c From Part_FIFO_Bucket_Activity_Line_Items__r)'; 
    	//customFieldsQuery += '';
    	
    	
    	String whereCondition = 'WHERE (Reference__c = \'Count Adjustment\'  OR Reference__c Like  \'re%\' OR Reference__c = \'Cost Adjustment\' )' ;
    	
    	if(Last_Synched_Date != null){
    		//system.assert(false,Last_Synched_Date );
    		whereCondition += 'And LastModifiedDate >: Last_Synched_Date';
    	}
    	if(recordIds != null && recordIds.size() > 0){
    		whereCondition += ' AND Id IN ' + recordIds;
    	}
    	
    	vrsQuery += standardFieldsQuery + customFieldsQuery + ' FROM Part_FIFO_Bucket__c ' + whereCondition + ' ORDER BY Name';
    	//system.assert(false,vrsQuery);
    	return vrsQuery;
	}
    
    
    
    
    
}