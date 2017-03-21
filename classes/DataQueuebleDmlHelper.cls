global class DataQueuebleDmlHelper implements Queueable {   
    public List<SObject> ToInsert{get;set;}
    public List<SObject> ToDelete {get;set;}
    public List<SObject> ToUpdate {get;set;}    
    
    public static void processInsert(list<sobject> dataList){
		DataQueuebleDmlHelper enqueued = new DataQueuebleDmlHelper();
		enqueued.ToInsert = dataList;
        System.enqueueJob( enqueued );
    }
    
    public static void processUpdate(list<sobject> dataList){
		DataQueuebleDmlHelper enqueued = new DataQueuebleDmlHelper();
		enqueued.ToUpdate = dataList;
        System.enqueueJob( enqueued );
    }
    
    public static void processDelete(list<sobject> dataList){
		DataQueuebleDmlHelper enqueued = new DataQueuebleDmlHelper();
		enqueued.ToDelete = dataList;
        System.enqueueJob( enqueued );
    }
    
    public void execute(QueueableContext context){
        string errors = '';
        List<Database.SaveResult> srList = new List<Database.SaveResult>();
        List<Database.DeleteResult> drList = new List<Database.DeleteResult>();
        list<Database.UpsertResult> urList = new List<Database.UpsertResult>();        
        
        if(ToInsert != null && ToInsert.size() > 0)            
               srList.addAll(database.insert( toInsert, false));
        

        if(ToUpdate != null && ToUpdate.size() > 0)          
               srList.addAll(database.update( toUpdate, false));
        
        
        if(ToDelete != null && ToDelete.size() > 0)
                drList.addAll(database.delete( ToDelete, false));
            	
        
        for(Database.SaveResult sr: srList){
            if(!sr.isSuccess())
            {
                for(Database.Error err : sr.getErrors()) {
                    errors +='\n'+err.getMessage();
                }
            }
        }
        
        for(Database.DeleteResult sr: drList){
            if(!sr.isSuccess())
            {
                for(Database.Error err : sr.getErrors()) {
                    errors +='\n'+err.getMessage();
                }
            }
        }
        
        if(errors != '') throw new DataQueuebleDmlHelperException(errors);
       
    }
    
    class DataQueuebleDmlHelperException extends Exception {}
}