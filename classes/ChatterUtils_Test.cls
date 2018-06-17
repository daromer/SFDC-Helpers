@IsTest(SeeAllData=true)
public class ChatterUtils_Test {
    static testmethod void testBulkChatterPost1(){
        list<map<Id, list<string>>> bulkChatter = new list<map<Id, list<string>>>();
        {
            map<id,string[]> feeds = new map<id,string[]>();
            string usrId = userinfo.getUserId();
            map<string,string> vars = new map<string,string>(); 
            vars.put('{{usr}}', usrId);
            string msg = 'Testing things... @[{{usr}}] @[{{usr}}] @[{{usr}}] @[{{usr}}] #[tets] #[test 2] some more tests';
            list<string> msgArr = ChatterUtils.convertToFeedMsgArray( ChatterUtils.replace(msg,vars) );
            feeds.put(usrId, msgArr);
            map<id, string[]> feed2 = new map<id,string[]>();
            feed2.put(usrId, ChatterUtils.convertToFeedMsgArray( 'just the text' ));
            bulkChatter.add( feeds );
            bulkChatter.add( feed2 );
        }
        ChatterUtils.postFeedInBulk(bulkChatter, true);
    }
    
    static testmethod void testBulkChatterPost2(){
        List<ConnectApi.FeedItemInput> feeds = new List<ConnectApi.FeedItemInput>();
        {
            string usrId = userinfo.getUserId();
            map<string,string> vars = new map<string,string>(); 
            vars.put('{{usr}}', usrId);
            string msg = 'Testing things... @[{{usr}}] @[{{usr}}] @[{{usr}}] @[{{usr}}] #[tets] #[test 2] some more tests';            
            
            feeds.add( ChatterUtils.postFeed(usrId, ChatterUtils.replace(msg,vars) , false, false) );
            feeds.add( ChatterUtils.postFeed(usrId, 'just the text' , false, true) );
           
        }
        ChatterUtils.postFeedInBulk(feeds, true);
    }
    
    /*
    static testmethod void MaximunPostsInBatchTest(){
        List<ConnectApi.FeedItemInput> feeds = new List<ConnectApi.FeedItemInput>();
        integer counter = 10000;
        while(counter >= 0){            
            string usrId = userinfo.getUserId();
            map<string,string> vars = new map<string,string>(); 
            vars.put('{{usr}}', usrId);
            string msg = 'Testing things... @[{{usr}}] @[{{usr}}] @[{{usr}}] @[{{usr}}] #[tets] #[test 2] some more tests';                        
            feeds.add( ChatterUtils.postFeed(usrId, ChatterUtils.replace(msg,vars) , false, false) );
            counter--;
        }
        ChatterUtils.postFeedInBulk(feeds, true);
    }
	*/
}