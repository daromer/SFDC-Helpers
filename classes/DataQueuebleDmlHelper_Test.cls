@IsTest
public class DataQueuebleDmlHelper_Test {
    public static testmethod void testInsert(){        
        Case c = new Case( Subject = RandomHelper.rndId() );        
        Test.startTest();
        DataQueuebleDmlHelper.processInsert(new list<SObject>{c});
        Test.stopTest();        
        system.assert( [Select Id, Subject from Case where Subject=:c.Subject limit 1].size() > 0 );
    }
    
    public static testmethod void testInsertWithErrors(){    
        boolean exceptionThrown = false;
        try{
            User u = new User( );        
            Test.startTest();
            DataQueuebleDmlHelper.processInsert(new list<SObject>{ u });
            Test.stopTest();        
        }catch(DataQueuebleDmlHelper.DataQueuebleDmlHelperException ex){
            exceptionThrown = true;
        }
        system.assert(exceptionThrown, 'Should have thrown an exception on insert');
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
    
    public static testmethod void testUpdateWithErrors(){
        boolean exceptionThrown = false;
        
        string val = RandomHelper.rndId();
        Case c = new Case( Subject =  val ); 
        insert c;
        c.Subject = 'THIS IS THE NEW VALUE OF THE SUBJECT 001';
        try{
            Test.startTest();
            c.Id = null;
            DataQueuebleDmlHelper.processUpdate(new list<SObject>{c});
            Test.stopTest();          
        }catch(DataQueuebleDmlHelper.DataQueuebleDmlHelperException ex){
            exceptionThrown = true;
        }
        system.assert(exceptionThrown, 'Should have thrown on update.');
    }
    
    public static testmethod void testDelete(){
        Case c = new Case(Subject = 'test Case');
        insert c;       
        Id cId = c.Id;
        Test.startTest();
        DataQueuebleDmlHelper.processDelete(new list<SObject>{c});
        Test.stopTest();
        
        system.assert( [select id from Case where id=:cId].size() == 0 );
    }
    
    public static testmethod void testDeleteWithErrors(){
        boolean exceptionThrown = false;
        try{
            Case c = new Case();        
            Test.startTest();
            DataQueuebleDmlHelper.processDelete(new list<SObject>{c});
            Test.stopTest();        
        }catch(DataQueuebleDmlHelper.DataQueuebleDmlHelperException ex){
            exceptionThrown = true;
        }
        system.assert(exceptionThrown, 'Exception should have thrown on delete.' );
    }
}