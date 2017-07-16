@IsTest
public class MetadataHelper_Test {            
    public static testmethod void testMainMethod(){
        Recordtype[] rtypes = [Select DeveloperName from RecordType where SObjectType='Account'];        
        MetadataHelper.getFieldsMetadataMap('Account', new string[]{'Engagement_Level__c'}, true, rtypes[0].DeveloperName);
        MetadataHelper.getObjectsMetadataMap( new String[]{'Opportunity'}); 
    }
}