/**
 * Author: Ashish Garg
 * Since: Sept. 24, 2014
 * Name: BlackPurlHeaderCtrl
 * Description: Conroller class for BlackPurlHeader page (Used in Kendo).
**/
global with sharing class BlackPurlHeaderCtrl {
	// Variables related to page parameters:
	public String pageParameterName {public get{return Constants.pageParameterName;} private set;}
	public String settingsPageParameterName {public get{return Constants.settingsPageParameterName;} private set;}
	public String customerMgmtPageParameterName {public get{return Constants.customerMgmtPageParameterName;} private set;}
	public String partsMgmtPageParameterName {public get{return Constants.partsMgmtPageParameterName;} private set;}
	public String categoryMgmtPageParameterName {public get{return Constants.categoryMgmtPageParameterName;} private set;}
	public String vendorMgmtPageParameterName {public get{return Constants.vendorMgmtPageParameterName;} private set;}
	public String makeMgmtPageParameterName {public get{return Constants.makeMgmtPageParameterName;} private set;}
}