@IsTest
public class QueryHelper_Test {    
    
    public static testmethod void TestSimpleQuery(){
        string targetId = userinfo.getUserId();
        SObject[] queryResult = database.query(QueryHelper.getSelectAll('User') + ' Where Id=:targetId');
        system.assert(queryResult.size() > 0, 'Should return something');
        system.assertEquals(userinfo.getUserName(), string.valueof(queryResult[0].get('username')),   'Shoud have returned the same value field' );
    }
    
    public static testmethod void TestComplexQuery(){
        User target = [select id, Manager.Name from user where ManagerId != null limit 1];
        string targetId = target.id;
        string[] aditionalFields = new string[]{'Manager.Name', 'Manager.Username'};
        SObject[] queryResult = database.query( QueryHelper.getSelectAll('User', null, aditionalFields, null) + ' Where Id=:targetId' );
        User u = (User)queryResult[0];
        
        system.assert(queryResult.size() > 0, 'Should return something');         
        system.assertEquals(target.Manager.Name, u.Manager.Name , 'Should return the same Manager Name'); 
    }
    
    public static testmethod void TestSubQuery(){        
        //Generate Cases for testing subquery
        //PartnerQBRController_Test.generateAllData();
        Case c1 = new Case();
        insert c1;
        Case c2 = new Case(ParentId = c1.Id);
        insert c2;
        
        string targetId = c1.Id;
        string subQueryPart = QueryHelper.getSelectAll('Case', 'Cases',null,null);                
        string endQuery =  QueryHelper.getSelectAll('Case', null, null, new string[]{ subQueryPart }) + ' Where Id=:targetId';
        system.debug('END QUERY===> ' + endQuery);
		SObject[] queryResult = database.query(endquery);
        
        Case result = (Case)queryResult[0];
        
        system.assert(queryResult.size() > 0, 'Should return something');        
        system.assertEquals(1, result.Cases.size(), 'Should have returned the subquery results');
    }
}