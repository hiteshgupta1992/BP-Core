/**
 * Author: Ashish Garg
 * Since: Feb 18, 2016
 * Name: COKH_Recalcualtion
 * Description: Apex class to handle Customer Order Kit Header 
**/
public with sharing class COKH_Recalcualtion {

	 /**
     * Name: AddCustomerCoForKititemUpdate
     * Desc: updating kit item
     * @param:  (1) CustomerId - String - Customer Id
     *			(2) CoheaderId - String - Customer Header Id
     * @return: void
    **/
    public static void AddCustomerCoForKititemUpdate(string  CustomerId ,string CoheaderId  ){
   		 COKHPriceLevelCalculationByMerchandise(null,CustomerId,CoheaderId);
    }
    
    
     /**
     * Name: COKHPriceLevelCalculationByMerchandise
     * Desc: calculate price by merchandise
     * @param:  (1) listkitheaderId - List<Id> - List of kit header id
     			(2) CustomerId - String - Customer Id
     *			(3) CoheaderId - String - Customer Header Id
     * @return: String success or not
    **/
    public static String COKHPriceLevelCalculationByMerchandise( List<Id> listkitheaderId,string CustomerId ,string CoheaderId ){
        if(AccessControl.ifObjectFieldIsCreateable('Price_Level__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_CREATEABLE); }
        if(AccessControl.ifObjectFieldIsCreateable('Sales_Tax__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_CREATEABLE); }
        if(AccessControl.ifObjectFieldIsUpdateable('CO_Kit_Header__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_UPDATEABLE); }
        if(AccessControl.ifObjectFieldIsAccessible('Sales_Tax__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
        if(AccessControl.ifObjectFieldIsAccessible('CO_Kit_Header__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
        Price_Level__c priceLevel = new Price_Level__c();
        Sales_Tax__c salesTax = new Sales_Tax__c();
        CustomerId = BPUtility.escapeSingleQuotes(CustomerId);
        CoheaderId = BPUtility.escapeSingleQuotes(CoheaderId);
        if(CustomerId !=null){  
        	if(AccessControl.ifObjectFieldIsAccessible('Account') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
        	if(AccessControl.ifObjectFieldIsAccessible('Price_Level__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
        	
            Account  customer=[SELECT   Id, 
                                Price_Level__c,   
                                Price_Level__r.Active__c, 
                                Price_Level__r.Discount_Markup__c,   
                                Price_Level__r.Labour_Rate__c ,
                                Sales_Tax__c
                                FROM Account
                                WHERE Id =: customerId
          
                            ];
                             
                priceLevel = new Price_Level__c(    Active__c = customer.Price_Level__r.Active__c,
                                                        Discount_Markup__c = (customer.Price_Level__r.Discount_Markup__c != null) ? customer.Price_Level__r.Discount_Markup__c : 0,
                                                        Labour_Rate__c = customer.Price_Level__r.Labour_Rate__c
                                                    );
                 salesTax =new Sales_Tax__c( Id = customer.Sales_Tax__c);                               
        }
        else{
        		if(AccessControl.ifObjectFieldIsAccessible('CO_Header__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
        		if(AccessControl.ifObjectFieldIsAccessible('Account') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
        		
               			 CO_Header__c Coheader = [Select Part_Price_Base_From_Price_Level__c, Discount_Markup_From_Prive_Level__c,Customer__r.Sales_Tax__c 
                                        From CO_Header__c  where Id =: CoheaderId ];
                       
                       		if(Coheader.Customer__r.Sales_Tax__c !=null ){
                       				 salesTax =new Sales_Tax__c( Id = Coheader.Customer__r.Sales_Tax__c);   
                       		}
                       		else{
                       				List<Sales_Tax__c> listDefaultSalesTax = [select Id from Sales_Tax__c where default__c = true];
                       				salesTax = new Sales_Tax__c( Id = listDefaultSalesTax[0].Id);   
                       		}
                       		
                       		//                
            
                         priceLevel = new Price_Level__c(   
                                                        Discount_Markup__c = Coheader.Discount_Markup_From_Prive_Level__c 
                                                        
                                                    );
       		 }
        	if( listkitheaderId == null || listkitheaderId.size() < 0){
        		 Map<Id,CO_Kit_Header__c>  IdToCokhMap = new  Map<Id,CO_Kit_Header__c> ([Select Id From CO_Kit_Header__c  where CO_Header__c =:CoheaderId ]);
        		 listkitheaderId =new List<Id>(IdToCokhMap.KeySet());
        	}
        	
        	
        	
        	if(AccessControl.ifObjectFieldIsAccessible('CO_Kit_Header__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
        	if(AccessControl.ifObjectFieldIsUpdateable('CO_Line_Item__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
            List<CO_Kit_Header__c> CoKitHeaderList = [Select Id,Price__c,Fixed_Price_Flag__c,   (Select Price__c,Part__c,Fixed_Price__c,Qty__c,Tax__c From CO_Line_Items__r) 
                                                        From CO_Kit_Header__c where CO_Kit_Header__c.Id IN : listkitheaderId];
            
            if(AccessControl.ifObjectFieldIsUpdateable('CO_Line_Item__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
            List<CO_Line_Item__c> ColiToUpdate = new List<CO_Line_Item__c>(); 
            
          
           Set<Id> partIdSet = new Set<Id>(); 
          
           // Create Set for Part Ids 
           for(CO_Kit_Header__c CoKitHeaderRec : CoKitHeaderList ){
           		if(CoKitHeaderRec.CO_Line_Items__r != null &&   CoKitHeaderRec.CO_Line_Items__r .size() > 0 && !CoKitHeaderRec.Fixed_Price_Flag__c){
           			for(CO_Line_Item__c coliRec : CoKitHeaderRec.CO_Line_Items__r){
           				if(coliRec.Part__c !=null){
           					partIdSet.add(coliRec.Part__c);
           				}
           			}
           		}
           }
              
           if(AccessControl.ifObjectFieldIsAccessible('Part__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
           if(AccessControl.ifObjectFieldIsAccessible('Part_Tax__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
           
           list<Part__c>  listPartSalesTax= new list<Part__c> ([Select Id, (Select Id , Sales_Tax_Item__r.Tax_Parts__c,Sales_Tax_Item__r.Rate__c From Part_Taxes__r) From Part__c  where Id IN:partIdSet ]); 
           Map<Id,Decimal> partIdToPartRateMap = new  Map<Id,Decimal>();
           for(Part__c  partRec : listPartSalesTax){
           			for(Part_Tax__c PartTaxItemRec : partRec.Part_Taxes__r){  
           					if( PartTaxItemRec.Sales_Tax_Item__r.Tax_Parts__c){
           							Decimal Rate = partIdToPartRateMap.get(partRec.Id) ==null ? 0 :  partIdToPartRateMap.get(partRec.Id) ;
           							Rate = Rate + PartTaxItemRec.Sales_Tax_Item__r.Rate__c;
           							partIdToPartRateMap.put(partRec.Id,Rate);
           				}
           		}		
           }
          
          if(AccessControl.ifObjectFieldIsAccessible('Sales_Tax__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
          if(AccessControl.ifObjectFieldIsAccessible('Applicable_Taxes__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
          
          List<Sales_Tax__c>  salesTaxList   =new list<Sales_Tax__c>([Select Id,(Select Id, Name, Sales_Tax_Item__r.Tax_Parts__c,Sales_Tax_Item__r.Rate__c  From Applicable_Taxes__r) From Sales_Tax__c  where  Id =: salesTax.Id]);
          Decimal SalesTaxRate =0.00;
          for(Sales_Tax__c  saleTaxRec : salesTaxList){
           			for(Applicable_Taxes__c PartTaxItemRec : saleTaxRec.Applicable_Taxes__r){  
           					if( PartTaxItemRec.Sales_Tax_Item__r.Tax_Parts__c){
           							SalesTaxRate = SalesTaxRate + PartTaxItemRec.Sales_Tax_Item__r.Rate__c;
           							
           				}
           		}		
           }
          
              
            for(CO_Kit_Header__c CoKitHeaderRec : CoKitHeaderList ){
                if(CoKitHeaderRec.CO_Line_Items__r != null &&   CoKitHeaderRec.CO_Line_Items__r .size() > 0 && !CoKitHeaderRec.Fixed_Price_Flag__c ){
                     List<CO_Line_Item__c> coliList  =  applyPriceLevel(CoKitHeaderRec,priceLevel,SalesTaxRate,partIdToPartRateMap); 
                     ColiToUpdate.addAll(coliList);  
                } 
                  
            } 
           // System.assert(false,ColiToUpdate +'\n\n\n'+ CoKitHeaderList);
            
            if(ColiToUpdate.size()>0){
                update ColiToUpdate;
                update CoKitHeaderList;
            }  
            return 'Success'; 
        
    }     
    
    /**
     * Name: CoKitInsert
     * Desc: Customer kit insert
     * @param:  (1) kitheaderId - String - Kit Header Record Id
     *			(2) CoheaderId - String - Customer Header Id
     * @return: String success or not
    **/
   	 public static String CoKitInsert(String kitheaderId, String CoheaderId) {
    	List<Id> listkitheaderId = new List<Id>();
    	listkitheaderId.add(kitheaderId);
   		String Result = COKHPriceLevelCalculationByMerchandise(listkitheaderId,null,CoheaderId);
   		 
 	 	return 'Success'; 
    } 
    
    /**
     * Name: applyPriceLevel
     * Desc:  Apply Price Level
     * @param:  (1) CoKitHeaderRec - CO_Kit_Header__c - Kit Header Record Id
     *			(2) PriceLevel - Price_Level__c - Price Level
     *			(3) SalesTaxRate - Decimal - Sales Tax
     *			(4) partIdToPartRateMap - Map<Id,Decimal> - part Rate mapping with its id
     * @return: List<CO_Line_Item__c>  - List of Line Items
    **/
    public static List<CO_Line_Item__c> applyPriceLevel(CO_Kit_Header__c CoKitHeaderRec,Price_Level__c PriceLevel, Decimal SalesTaxRate, Map<Id,Decimal> partIdToPartRateMap){
            Decimal KitHeaderTotal = 0.00;
            Decimal PartRate = 0.00;
            Decimal taxAmount = 0;
            for(CO_Line_Item__c  ColiRec : CoKitHeaderRec.CO_Line_Items__r ) {
                if(!ColiRec.Fixed_Price__c && ColiRec.Part__c !=null){ 
                    ColiRec.Price__c =  ColiRec.Price__c + (ColiRec.Price__c * priceLevel.Discount_Markup__c / 100);
                }
                
                PartRate =  partIdToPartRateMap.get(ColiRec.Part__c) ==null ? 0 :  partIdToPartRateMap.get(ColiRec.Part__c) ;
                ColiRec.Tax__c = ((SalesTaxRate - PartRate) <  0 ? 0 :  (SalesTaxRate - PartRate));
                KitHeaderTotal += (ColiRec.Qty__c * ColiRec.Price__c);
                if(ColiRec.Tax__c != null) {
            		taxAmount +=  (ColiRec.Qty__c * ColiRec.Price__c * ColiRec.Tax__c) / 100;
                }
            }  
            if(!CoKitHeaderRec.Fixed_Price_Flag__c){
                CoKitHeaderRec.Price__c = KitHeaderTotal;
                CoKitHeaderRec.Tax_Amount__c = taxAmount;
            }
            
            //system.assert(false,CoKitHeaderRec +'/n/n/n/n'+  CoKitHeaderRec.CO_Line_Items__r);
            return  CoKitHeaderRec.CO_Line_Items__r;
    }
    
    
     /**
     * Name: UpdateKitHeader
     * Desc:  Update Kit Header
     * @param:  (1) CoKitObj - COHeaderWrapper.COKitHeader - Kit Header Record
     * @return: String - Success or Error
    **/
    public static String UpdateKitHeader(COHeaderWrapper.COKitHeader CoKitObj){
    	if(AccessControl.ifObjectFieldIsUpdateable('CO_Kit_Header__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_UPDATEABLE); }
    	if(AccessControl.ifObjectFieldIsUpdateable('CO_Line_Item__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_UPDATEABLE); }
		         	Decimal KitHeaderTotal = 0.00;
		            Decimal FixedTotal =0.00;
		            Decimal UnFixedTotal =0.00;
		            Decimal DesiredTotal=0.00;
		            Decimal Adjustment =0.00;
		            Decimal counter = 0; 
		         	
		         	if(AccessControl.ifObjectFieldIsAccessible('CO_Kit_Header__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
		            CO_Kit_Header__c CheckToUpdatedHeader =[select Id,Price__c from CO_Kit_Header__c where Id =:CoKitObj.Id  ];
		            
		            	
		            if(CheckToUpdatedHeader.Price__c == CoKitObj.Price){
		            		return 'Success';
		            } 
		            
		            List<COLineItem> ColiList = CoKitObj.COLIList;               
         			for(COLineItem ColirecItem : ColiList ){
                            if(!(ColirecItem.IsFixedPriceForCO ||  ColirecItem.IsFixedPrice))   {
                                UnFixedTotal  += (ColirecItem.Qty * ColirecItem.Price);
                            }
                            else{
                                FixedTotal +=(ColirecItem.Qty * ColirecItem.Price) ;
                            }
                        }
                        if(CoKitObj.Price < FixedTotal){
                            return 'Kit Header Total cannot Less than Line Item Total';
                        }
                        else if(UnFixedTotal < 0){
                        	return 'Incorrect item inserted';
                        }
                        else{
                            UnFixedTotal = UnFixedTotal==0 ? 1 :UnFixedTotal; 
                            Adjustment = (CoKitObj.Price - FixedTotal)/UnFixedTotal;
                            //Adjustment = Adjustment.setScale(2);
                            for(COLineItem ColirecItem : ColiList ){
                                if(!(ColirecItem.IsFixedPriceForCO ||  ColirecItem.IsFixedPrice )){
                                      ColirecItem.Price = (Adjustment *  ColirecItem.Price);
                                      counter = counter + 1;
                                }
                            }
                        
                        }
                        
		        
		        
		        CO_Kit_Header__c CoKitHeaderListToUpdate =new CO_Kit_Header__c();
		        List<CO_Line_Item__c> ColiToUpdate  =new List<CO_Line_Item__c>(); 
		        
		          //  
		        
		        for(COLineItem ColirecItem : ColiList ){
		                CO_Line_Item__c ObjeToadd= new CO_Line_Item__c();
		                ObjeToadd.Id=ColirecItem.CoLineItemId;
		                //ObjeToadd.CO_Fixed_KitLineItem__c = ColirecItem.IsFixedPriceForCO;
		                ObjeToadd.Price__c = ColirecItem.Price.setScale(2);
		                ColiToUpdate.add(ObjeToadd);
		        }
		        
		        if(ColiToUpdate.size() > 0  &&  counter > 0){
		         		update ColiToUpdate;
		         		CoKitHeaderListToUpdate.Id= CoKitObj.Id;
		        		CoKitHeaderListToUpdate.Price__c = CoKitObj.Price.setScale(2);
		        		CoKitHeaderListToUpdate.CO_Fixed_KitHeader__c =true;
		        	 	update CoKitHeaderListToUpdate;
		        }
		       
		        if( counter ==  0){
		        	 return 'Error';
		        }
        
        
        return 'Success';
    }
    
    
     
     /**
     * Name: UpdateKitLineItem
     * Desc:  Update Kit Header
     * @param:  (1) CoKitObj - COHeaderWrapper.COKitHeader - Kit Header Record
     *			(2) ColiRec -  COLineItem - Line Item Record
     *			(3) CoheaderId- String  - Header Record
     * @return: String - Success or Error
     **/
    public static String UpdateKitLineItem(COHeaderWrapper.COKitHeader CoKitObj,COLineItem ColiRec,String CoheaderId ){
            if(AccessControl.ifObjectFieldIsAccessible('CO_Line_Item__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
            if(AccessControl.ifObjectFieldIsAccessible('CO_Header__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
            if(AccessControl.ifObjectFieldIsUpdateable('CO_Kit_Header__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_UPDATEABLE); }
        	if(AccessControl.ifObjectFieldIsUpdateable('CO_Line_Item__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_UPDATEABLE); }
            CoheaderId = BPUtility.escapeSingleQuotes(CoheaderId);
            CO_Line_Item__c  ColiChecktoUpdate  = [select Id,price__c  from CO_Line_Item__c where Id =:ColiRec.CoLineItemId ];
            if( ColiChecktoUpdate.price__c == ColiRec.price){
            	return 'Success';
            }
            CO_Header__c Coheader = [Select Part_Price_Base_From_Price_Level__c, Discount_Markup_From_Prive_Level__c 
                                        From CO_Header__c  where Id =: CoheaderId ];
                                        
            List<COLineItem> ColiList = CoKitObj.COLIList;                  
            Decimal KitHeaderTotal = 0.00;
            Decimal FixedTotal =0.00;
            Decimal UnFixedTotal =0.00;
            Decimal DesiredTotal=0.00;
            Decimal Adjustment =0.00;
            
            if(CoKitObj.IsFixedPrice  || CoKitObj.IsFixedKitHeaderCO){  
                        for(COLineItem ColirecItem : ColiList ){
                            if(!(ColirecItem.IsFixedPriceForCO ||  ColirecItem.IsFixedPrice || ColirecItem.CoLineItemId== ColiRec.CoLineItemId ))   {
                                UnFixedTotal  += (ColirecItem.Qty * ColirecItem.Price);
                            }
                            else{
                                FixedTotal +=(ColirecItem.Qty * ColirecItem.Price) ;
                            }
                        }
                        if(CoKitObj.Price < FixedTotal){
                            return 'Kit Header Total cannot Less than Line Item Total';
                        }
                        else if(UnFixedTotal < 0){
                        	return 'Inccorect item inserted';
                        }
                        else{
                            UnFixedTotal = UnFixedTotal==0 ? 1 :UnFixedTotal; 
                            Adjustment = (CoKitObj.Price - FixedTotal)/UnFixedTotal;
                            //Adjustment = Adjustment.setScale(2);
                            for(COLineItem ColirecItem : ColiList ){
                                if(!(ColirecItem.IsFixedPriceForCO ||  ColirecItem.IsFixedPrice || ColirecItem.CoLineItemId== ColiRec.CoLineItemId )){
                                      ColirecItem.Price = (Adjustment *  ColirecItem.Price);
                                }else if(ColirecItem.CoLineItemId== ColiRec.CoLineItemId){
                                
                                    ColirecItem.IsFixedPriceForCO =true;
                                }
                            }
                        
                        }
            }
            else{
                    for(COLineItem ColirecItem : ColiList ){
                            if(!(ColirecItem.IsFixedPriceForCO ||  ColirecItem.IsFixedPrice || ColirecItem.CoLineItemId== ColiRec.CoLineItemId ))   {
                                ColirecItem.Price =  ColiRec.ActualKitPrice + (ColiRec.ActualKitPrice * Coheader.Discount_Markup_From_Prive_Level__c / 100);
                            }
                            else if(ColirecItem.CoLineItemId== ColiRec.CoLineItemId ){
                           		  ColirecItem.IsFixedPriceForCO =true;
                            }
                            KitHeaderTotal += (ColirecItem.Qty * ColirecItem.Price);
                        }
                    CoKitObj.Price = KitHeaderTotal;
            }
        

        
        CO_Kit_Header__c CoKitHeaderListToUpdate =new CO_Kit_Header__c();
        List<CO_Line_Item__c> ColiToUpdate  =new List<CO_Line_Item__c>(); 
        
        for(COLineItem ColirecItem : ColiList ){
                CO_Line_Item__c ObjeToadd= new CO_Line_Item__c();
                ObjeToadd.Id=ColirecItem.CoLineItemId;
                ObjeToadd.CO_Fixed_KitLineItem__c = ColirecItem.IsFixedPriceForCO;
                ObjeToadd.Price__c = ColirecItem.Price.setScale(2);
                ColiToUpdate.add(ObjeToadd);
        }
        
        CoKitHeaderListToUpdate.Id= CoKitObj.Id;
        CoKitHeaderListToUpdate.Price__c = CoKitObj.Price.setScale(2);
        
        if(ColiToUpdate.size() > 0 ){
         update ColiToUpdate;
         update CoKitHeaderListToUpdate;
        }
    
        return 'Success'; 
    }
    
    
    


}