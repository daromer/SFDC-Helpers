@IsTest
public class PicklistHelper_Test {
    public static testmethod void testAllMethods(){
        string sobjectName = 'Account';
        string fieldName = 'AccountSource';
        string recordtypeName = [Select DeveloperName from Recordtype where sobjecttype=:sobjectName limit 1].DeveloperName;
        PicklistHelper.GetPicklistValues(sobjectName, fieldName);
        PicklistHelper.getPicklistValuesByRecordType(SObjectName, fieldName, recordtypeName);
        PicklistHelper.getDependentOptionsMap(sobjectName, fieldName, 'Engagement_Level__c');
    }
}