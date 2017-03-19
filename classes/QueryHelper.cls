global class QueryHelper {
    global static string getSelectAll(string objectName, string[] aditionalFields){
        string result = '';
        
        if (Schema.getGlobalDescribe().containsKey(objectName)){
            Map<String,Schema.SObjectField> fields = Schema.getGlobalDescribe().get(objectName).getDescribe().fields.getMap();
            string[] listFields = new list<string>(fields.keySet());
            if (aditionalFields != null) listFields.addAll(aditionalFields);
            result = 'Select ' + string.join(listFields,',') + ' from ' + objectName;
        }
        
        return result;
    }
    
    
    public static string getLogicStatements(string[] statements, string logic){        
        return (statements != null && statements.size() > 0)? (' ' + string.join(statements, logic ) + ' ') : '';
    }
}