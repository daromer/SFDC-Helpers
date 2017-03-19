global class MetadataHelper {
    
    @remoteaction
    @auraenabled
    global static map<string, map<string,object>> getFieldsMetadataMap(string objectName, string[] fieldNames){
        system.debug('*** objectName ***=>'+ objectName);
        system.debug('*** fieldNames ***=>'+ fieldNames);
        map<string, map<string,object>> result = new map<string, map<string,object>>();
        Map<String,Schema.SObjectType> objGlobalMap = Schema.getGlobalDescribe();        
        if (Schema.getGlobalDescribe().containsKey(objectName)){
            Schema.DescribeSObjectResult obj =  Schema.getGlobalDescribe().get(objectName).getDescribe();            
            map<string,string> fieldNamesMap = new map<string,string>();
            if (fieldNames != null){
                for (string s : fieldNames) {
                    fieldNamesMap.put( s.toLowerCase(), s );
                }
            }
            system.debug('**** fieldNamesMap ***=>'+fieldNamesMap);
            system.debug('**** fieldNames ***=>'+fieldNames);
            system.debug('**** obj.fields.getMap().keySet() ***=>'+obj.fields.getMap().keySet());
            
            for (string fieldName : obj.fields.getMap().keySet()){                
                if (fieldNames == null || fieldNamesMap.containsKey(fieldName) ){
                    Schema.DescribeFieldResult field =  obj.fields.getMap().get( fieldName ).getDescribe(); 
					string fieldNameCaseSensitive = string.valueOf(obj.fields.getMap().get( fieldName ));
                    object defaultValue = field.getDefaultValue()!=null? field.getDefaultValue(): ( field.getDefaultValueFormula()!=null? field.getDefaultValueFormula():null );
					result.put( fieldNameCaseSensitive , new map<string,object>() );
                    result.get( fieldNameCaseSensitive ).put('Label', field.getLabel());
                    result.get( fieldNameCaseSensitive ).put('HelpText', field.getInlineHelpText()); 					
                    result.get(fieldNameCaseSensitive ).put('DefaultValue', defaultValue );
                }               
            }
        }
        return result;
    }
}