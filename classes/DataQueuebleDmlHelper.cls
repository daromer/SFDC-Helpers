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
        
        if(ToInsert != null && ToInsert.size() > 0) {
            try{
                srList.addAll(database.insert( toInsert, false));
            }catch(Exception e){
                errors +='\n'+e.getMessage() + ' - ' + e.getStackTraceString() + '; ';
            }
        }           
        

        if(ToUpdate != null && ToUpdate.size() > 0){          
            try{
               srList.addAll(database.update( toUpdate, false));                
            }catch(Exception e){
                errors +='\n'+e.getMessage() + ' - ' + e.getStackTraceString() + '; ';
            }
        }
        
        
        if(ToDelete != null && ToDelete.size() > 0){
            try{
                drList.addAll(database.delete( ToDelete, false));
            }catch(Exception e){
                errors +='\n'+e.getMessage() + ' - ' + e.getStackTraceString() + '; ';
            }
        }
            	
        
        for(Database.SaveResult sr: srList){
            if(!sr.isSuccess())
            {
                for(Database.Error err : sr.getErrors()) {
                    errors +='\n'+err.getMessage()+ ' - ' + err.getFields() + '; ';
                }
            }
        }
        
        for(Database.DeleteResult sr: drList){
            if(!sr.isSuccess())
            {
                for(Database.Error err : sr.getErrors()) {
                    errors +='\n'+err.getMessage() + ' - ' + err.getFields() + '; ';
                }
            }
        }
        
        if(errors != '') throw new DataQueuebleDmlHelperException(errors);
       
    }
    
    global class DataQueuebleDmlHelperException extends Exception {}
}