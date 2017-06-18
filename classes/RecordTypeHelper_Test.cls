@IsTest
public class RecordTypeHelper_Test {
    public static testmethod void testMainMethods(){
        RecordType rt = [Select Id, DeveloperName, Name from RecordType where SobjectType = 'Account' limit 1];
        system.assertEquals(rt.Id, RecordTypeHelper.getIdByName('Account', rt.Name), 'Should have return the same Id');
    }
}