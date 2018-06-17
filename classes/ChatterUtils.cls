/**************************************
Author             : Danny Robles
Purpose            : Allows the user to post chatter feeds normal and in bulk.      
Req/Ticket 		   : Req-09818
TestClass		   : ChatterUtils_Test
Examples           : ChatterUtils.postFeed(TARGETID, 'posting a chatter feed @[USERID] with mentions', true, false);
**************************************/
global class ChatterUtils {
    //static string mentionRegex = '@\\[\\w{15,18}\\]';
    static string mentionRegex = '@\\[\\w{15,18}\\:{0,1}\\w*\\]';
    
    static string urlRegex = '\\(\\w*\\)\\[(https?:\\/\\/(?:www\\.|(?!www))[^\\s\\.]+\\.[^\\s]{2,}|www\\.[^\\s]+\\.[^\\s]{2,})\\]';
    static string hashtagRegex = '\\#\\[\\w+\\]';
    static string CommunityId{get{
        return Network.getNetworkId();
    }}
    static boolean filterMentions = false;
       
    
    /**
    * Post chatter feeds in bulk
    *
    * @param allFeeds 			: list of posts targeted in a map (the id of the map will be the subjectId of the post).
    * @param send 	  			: specifies if the posts should be send right away.
    * @param internalUsersOnly 	: FALSE if all the posts are for all users or TRUE if they're for internal users only    
    * @returns					: Returns the constructed ConnectApi.BatchInput[] ( doesn't matter if it has been sent previously or not )
    */
    global static List<ConnectApi.BatchInput> postFeedInBulk(list<map<Id, string>> allFeeds, boolean send, boolean internalUsersOnly){        
        list<ConnectAPI.FeedItemInput> feeds = new list<ConnectAPI.FeedItemInput>();
        for(map<id,string> item : allFeeds){
            for (string targetId : item.keySet()){
                feeds.add( postFeed( targetId , item.get(targetId), false, internalUsersOnly) );
            }
        }        
        return postFeedInBulk(feeds, send);
    }  
    
    /**
    * Post chatter feeds in bulk
    *
    * @param allFeeds 			: list of ConnectAPI.FeedItemInput posts targeted
    * @param send 	  			: specifies if the posts should be send right away.    
    * @returns					: Returns the constructed ConnectApi.BatchInput[] ( doesn't matter if it has been sent previously or not )
    */
	global static List<ConnectApi.BatchInput> postFeedInBulk(list<ConnectAPI.FeedItemInput> allFeeds, boolean send){
        List<ConnectApi.BatchInput> batchInputs = new List<ConnectApi.BatchInput>();
        for(ConnectAPI.FeedItemInput item : allFeeds){            
            batchInputs.add( new ConnectApi.BatchInput( item )  );
        }        
        if ( send ){            
            if(batchInputs.size() >= 500) {                
                list<ConnectApi.BatchInput> parts = new list<ConnectApi.BatchInput>();                
                boolean isLast = false;
                for (integer i =0; i<batchInputs.size(); i++){
                    isLast = i == (batchInputs.size() -1);
                    ConnectApi.BatchInput item = batchInputs[i];
                    parts.add(item);
                    if ( (parts.size() == 450) || isLast ) {                        
                        if(!Test.isRunningTest())ConnectApi.ChatterFeeds.postFeedElementBatch(CommunityId, parts);
                        parts = new list<ConnectApi.BatchInput>();
                    }  
                }
                
            }else if(batchInputs.size() > 0){
                if(!Test.isRunningTest()) ConnectApi.ChatterFeeds.postFeedElementBatch( CommunityId , batchInputs);        
                return batchInputs;
            }
        }        
        return batchInputs;
    }
    
	/**
    * Post chatter feed
    *
    * @param targetId 			: list of ConnectAPI.FeedItemInput posts targeted
    * @param msg				: Chatter post message, to add @mentions just add the users/public groups in this format "@[Id of the user or group]"
    * @param send 	  			: specifies if the posts should be send right away. 
    * @param internalOnly		: TRUE if the post must be directed to internalUsers only, FALSE if it's directed to ALL users.  
    * @returns					: Returns the constructed ConnectApi.FeedItemInput ( doesn't matter if it has been sent previously or not )
    */    
    global static ConnectApi.FeedItemInput postFeed(id targetId, string msg, boolean send, boolean internalOnly){
        string[] msgArr = convertToFeedMsgArray(msg);
        
        
        ConnectApi.FeedItemInput feedItemInput = new ConnectApi.FeedItemInput();
        ConnectApi.MentionSegmentInput mentionSegmentInput = new ConnectApi.MentionSegmentInput();
        ConnectApi.MessageBodyInput messageBodyInput = new ConnectApi.MessageBodyInput();
        ConnectApi.TextSegmentInput textSegmentInput = new ConnectApi.TextSegmentInput();        
        messageBodyInput.messageSegments = new List<ConnectApi.MessageSegmentInput>();
        
        feedItemInput.visibility = (internalOnly == true)? ConnectApi.FeedItemVisibilityType.InternalUsers : ConnectApi.FeedItemVisibilityType.AllUsers;
        
        system.debug('VISIBILITY??? ' + feedItemInput.visibility);
        system.debug('COMMUNITY ID??? ' + CommunityId);
        
        Pattern regexForMentions = Pattern.compile('^'+mentionRegex+'$');
        //Pattern regexForUrls = Pattern.compile('^'+urlRegex+'$');
        Pattern regexForHashtags = Pattern.compile('^' + hashtagRegex + '$');
        
        for(string m : msgArr){
            if ( regexForMentions.matcher(m).matches() )
            {                
                String strValue =  Id.valueOf( m.substring(2, m.length() - 1 ) );
                
                if(string.isNotBlank(strValue))
                {
                    if ( string.isNotBlank(strValue) && strValue.startsWith('005') )
                    {                        
                        mentionSegmentInput = new ConnectApi.MentionSegmentInput();
                        mentionSegmentInput.Id = (Id)strValue;
                        messageBodyInput.messageSegments.add( mentionSegmentInput );   
                    }
                    else if( strValue.toLowerCase().startsWith('00g') )
                    {
                        list<string> strArray = strValue.split(':');
                        Id actualId = (Id)strArray[0];
                        list<id> qmembers = getQueueMembers(actualId);
                        for (integer i=0; i < qmembers.size(); i++ )
                        {                            
                            mentionSegmentInput = new ConnectApi.MentionSegmentInput();
                            mentionSegmentInput.Id = qmembers.get(i);
                            messageBodyInput.messageSegments.add( mentionSegmentInput );
                            
                            if (i != (qmembers.size() - 1) )
                            {
                                textSegmentInput = new ConnectApi.TextSegmentInput();
                                textSegmentInput.text = ', ';
                                messageBodyInput.messageSegments.add( textSegmentInput );
                            }
                        }
                    }
                }
            }
            else
            {                
                textSegmentInput = new ConnectApi.TextSegmentInput();
                textSegmentInput.text = m;                
                messageBodyInput.messageSegments.add( textSegmentInput );
            }
        }
        feedItemInput.body = messageBodyInput;
        feedItemInput.feedElementType = ConnectApi.FeedElementType.FeedItem;
        feedItemInput.subjectId = targetId;
        
        if (send && !Test.isRunningTest()) {             
            List<ConnectApi.BatchInput> batchInputs = new List<ConnectApi.BatchInput>();
            batchInputs.add( new ConnectApi.BatchInput(feedItemInput) );
            system.debug('Just Before posting...... batchInputs==> ' + batchInputs);
            ConnectApi.ChatterFeeds.postFeedElementBatch( CommunityId , batchinputs);       
        }   
        
        return feedItemInput;
    }
    
    /**
    * Separate a string into a string array based on matches in a specified regex
    *    
    * @param msg				: Chatter post message, to add @mentions just add the users/public groups in this format "@[Id of the user or group]"    
    * @param regex				: regex that will indicate where to separate the string
    * @returns					: List of strings separated by the regex match
    */  
    global static list<string> separateBaseOfRegex(string msg, string regex){
        ChatterUtils.MatchItem[] lst = ChatterUtils.findMatches(msg, regex);
        integer lastIdx = msg.length();
        list<string> parts = new list<string>();
        if (lst.size() > 0){
            for( integer i =0; i<lst.size();i++){
                integer last = (lst.size() - 1);
                if(i==0 &&  lst[0].startIndex > 0){
                    parts.add( msg.substring(0, lst[0].startIndex) );  
                }
                parts.add( msg.substring( lst[i].startIndex, lst[i].endIndex ) );
                if (i < last){
                    parts.add( msg.substring( lst[i].endIndex , lst[i + 1].startIndex ) );  
                }else if (i == last){
                    parts.add( msg.substring( lst[i].endIndex , lastIdx ) );  
                }
            }
        }else{
            parts.add(msg);
        }
        return parts;
    }
    
    
    /**
    * Converts a string into separated strings for later been used by the PostFeed method
    *    
    * @param msg	: Chatter post message ( to add @mentions just add the users/public groups in this format "@[Id of the user or group]"  )
    * @returns		: List of strings that are ok to be processed in the postFeed method 
    */  
    global static list<string> convertToFeedMsgArray(string msg){
        list<string> mentions =  separateBaseOfRegex(msg, mentionRegex);
        map<integer, string> mentionsMap = new map<integer, string>();
        map<integer, list<string>> hashtagMap = new map<integer, list<string>>();
        for(integer i =0; i<mentions.size(); i++){
            mentionsMap.put(i, mentions[i]);
            hashtagMap.put(i, separateBaseOfRegex(mentions[i], hashtagRegex) );
        }
        list<string> result = new list<string>();
        for(integer order : mentionsMap.keySet()){
            if (hashtagMap.containsKey(order)){
                result.addAll( hashtagMap.get(order) );
            }else{
                result.add( mentionsMap.get(order) );
            }
        }
        return result;
    }
    
    
    /**
    * Wrapper class used in the findMatches method to process matches in a string
    */  
    global class MatchItem{
        global integer MatchNumber{get;set;}
        global integer startIndex{get;set;}
        global integer endIndex{get;set;}
        public string groupValue{get;set;}
        
        public MatchItem( Matcher match, integer num){
            groupValue = match.group();
            startIndex = match.start();
            endIndex = match.end();
            matchNumber = num;
        }
    }
    
    /**
    * Find Matches in a string based on a regex, for later process
    *    
    * @param source	: string to find the matches into
    * @param regex	: regex that will be evaluated against the source param
    * @returns		: List of Matches found in the source param 
    */  
    global static List<MatchItem> findMatches(string source, string regex){
        list<matchitem> items = new list<matchitem>();
        Pattern p = Pattern.compile(regex);
        string s = source;
        Matcher m = p.matcher(s);        
        system.debug('s=> ' + s);
        integer count = 0;
        while(m.find()) {
            count++;
            items.add( new matchitem(m, count ) );
        }
        return items;
    }
    
    
    /**
    * Gets the list of User Id of the queue
    *    
    * @param queueId			: id of the queue to get the members from
    * @param includeSubMembers	: wether or not to include the submembers
    * @returns					: list of user Ids that are in the queue
    */      
    global static list<ID> getQueueMembers(Id queueId, boolean includeSubMembers){
        list<ID> result = new list<ID>();    
        for (GroupMember gm :[select UserOrGroupId from GroupMember where GroupId=:queueId]){
            if (string.valueOf(gm.UserOrGroupId).startsWith('005')){
                result.add(gm.UserOrGroupId);
            }else if(includeSubMembers){
                result.addAll( getQueueMembers(gm.UserOrGroupId, true));
            }
        }
        return result;
    }
    
    static map<id,list<id>> QueueMembersMap = new map<id,list<id>>();
    
    global static list<ID> getQueueMembers(Id queueId)
    {        
        if (QueueMembersMap.containsKey(queueId))
        {
            return QueueMembersMap.get(queueId);
        }
        else
        {
            list<ID> result = new list<ID>();   
            for (GroupMember gm :[select UserOrGroupId from GroupMember where GroupId=:queueId])
            {
                if (string.valueOf(gm.UserOrGroupId).startsWith('005'))
                {
                    result.add(gm.UserOrGroupId);
                }
                else if( string.valueOf(gm.UserOrGroupId).toLowerCase().startsWith('00g') )
                {
                    result.addAll( getQueueMembers(gm.UserOrGroupId));
                }
            }
            QueueMembersMap.put(queueId, result);
        }
        return QueueMembersMap.get(queueId);
    }
    
    
    /**
    * Gets the string that could be used to @mention queue members from a queue
    *    
    * @param queueId			: id of the queue to get the members from
    * @param includeSubMembers	: wether or not to include the submembers
    * @separationText			: separation string to separete the queue member parts ( example: ',' or ' and ', etc..)
    * @returns					: @mention part that references all queue members of a queue. 
    */  
    global static string getAtMentionQueueMembers(Id queueId, boolean includeSubMembers, string separationText){
        string result = '';
        set<string> mentions = new set<string>();
        string temp;
        for (Id memberId : getQueueMembers(queueId, includeSubMembers)){
            temp = '@[' + memberId + ']';
            if (!mentions.contains(temp)) mentions.add( temp );
        }
        return string.join(new list<string>(mentions), separationText);
    }   
    
    
    /**
    * Replaces values in string based on a map, where a key is found, is then replaced by it's value in the source param.
    *    
    * @param source		: string in which the values in the map will be replacing against
    * @param strVars	: Values that will be replaced, if a key is found in the source, it'll be replace with it's value
    * @returns			: resulting string after the replacing
    */  
    global static string replace(string source, map<string,string> strVars){
        string result = source;
        if (!string.IsEmpty(source) && strVars.size() > 0){
            for(string key : strVars.keySet())
                result = result.replace(key, strVars.get(key));
        }
        return result;
    }
}