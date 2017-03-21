@IsTest
public class DataQueuebleDmlHelper_Test {
    public static testmethod void testInsert(){        
        Case c = new Case( Subject = RandomHelper.rndId() );        
        Test.startTest();
        DataQueuebleDmlHelper.processInsert(new list<SObject>{c});
        Test.stopTest();
        
        system.assert( [Select Id, Subject from Case where Subject=:c.Subject limit 1].size() > 0 );
    }
    
    public static testmethod void testUpdate(){
        string val = RandomHelper.rndId();
        Case c = new Case( Subject =  val ); 
        insert c;
        c.Subject = 'THIS IS THE NEW VALUE OF THE SUBJECT 001';
        Test.startTest();
        DataQueuebleDmlHelper.processUpdate(new list<SObject>{c});
        Test.stopTest();  
        
        Case found = [Select Subject from Case where Id=:c.Id limit 1];
        
        system.assertNotEquals( found.Subject, val );
    }
    
    public static testmethod void testDelete(){
        Case c = new Case();
        insert c;       
        Id cId = c.Id;
        Test.startTest();
        DataQueuebleDmlHelper.processDelete(new list<SObject>{c});
        Test.stopTest();
        
        system.assert( [select id from Case where id=:cId].size() == 0 );
    }
}