/**************************************
Author             : Danny Robles (dyroblesmercedes@gmail.com)
Purpose            : Allows to create queries that gets all fields of an object.      
TestClass		   : QueryHelper_Test
Examples           : QueryHelper.getSelectAll('Case', null,new string[]{'Parent.Name'}, new set<string>(new string[]{'CreatedById'}), null); 
**************************************/
global class QueryHelper {    
    public interface DataShare{ sobject[] query(string query); }
    global with sharing class WithShare implements DataShare{ public sobject[] query(string query){ return database.query(query);} }
    global without sharing class WithoutShare implements DataShare { public sobject[] query(string query){ return database.query(query);} }
    public static DataShare WithSharing(boolean WithDataShare){ if(WithDataShare)return new WithShare(); else return new WithoutShare(); }
    
    
    global static string getSelectAll(string objectName){
        return getSelectAll(objectName, null, null, null);
    }    
    
    global static string getSelectAll(string objectName, string relatedList, string[] aditionalFields, string[] subQueries){
        return getSelectAll(objectName, relatedList, aditionalFields, null, subQueries);
    }    
    
    global static string[] getAllParentFields(string sobjectParent, string sobjectParentPrefix){
        string[] fieldsFound = new string[]{};
        if (Schema.getGlobalDescribe().containsKey(sobjectParent)){            
            Map<String,Schema.SObjectField> fields = Schema.getGlobalDescribe().get(sobjectParent).getDescribe().fields.getMap();
            for(String fieldName : fields.keySet()){
                fieldsFound.add( sobjectParentPrefix + '.' + fieldName  );
            }
        }
        return fieldsFound;
    }
    
    global static string getSelectAll(string objectName, string relatedList, string[] aditionalFields, set<string> fieldsToAvoid, string[] subQueries){
        string result = '';
        
        if (Schema.getGlobalDescribe().containsKey(objectName)){
            Map<String,Schema.SObjectField> fields = Schema.getGlobalDescribe().get(objectName).getDescribe().fields.getMap();
            string[] listFields = new list<string>();
            
            for(String fieldName : fields.keySet()) 
                if ( (fieldsToAvoid == null || !fieldsToAvoid.contains(fieldName) ) ) listFields.add(fieldName);
            
            if (aditionalFields != null) listFields.addAll(aditionalFields);
            string[] subQueryParts = new list<string>();
            if (subQueries != null){
                for (string subpart : subQueries){
                    subQueryParts.add('( '+ subpart + ')');
                }
            }
            string subQueryPart = (subQueries!= null && subQueries.size() > 0)? ', ' + string.join(subQueryParts, ',') : '';
            string fromPart = (string.isEmpty(relatedList)?objectName: relatedList);
            result = 'SELECT ' + string.join(listFields,',') + subQueryPart + ' FROM ' + fromPart ;
        }
        
        return result;
    }
}