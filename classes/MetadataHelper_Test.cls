@IsTest
public class MetadataHelper_Test {            
    public static testmethod void testMainMethod(){
        Recordtype[] rtypes = [Select DeveloperName from RecordType where SObjectType='Account'];        
        MetadataHelper.getFieldsMetadataMap('Account', new string[]{'Engagement_Level__c'}, true, rtypes[0].DeveloperName);
		MetadataHelper.SObjectInfo soInfo = MetadataHelper.getSObjectInfosMap( new set<string>(new String[]{'Account'})).get('Account');
        
        
        RecordType rt = [Select Id, DeveloperName from RecordType where SobjectType='Account' limit 1];
        
        MetadataHelper.FieldInfo fi = MetadataHelper.getFieldInfos('Account', new string[]{'Engagement_Level__c'}, true, rt.DeveloperName).get('Engagement_Level__c');
    }
}