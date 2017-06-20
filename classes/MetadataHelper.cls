global class MetadataHelper {
    global static map<string, map<string, map<string,object>>> ObjectCachedMetadata{get;set;}
    
    global static map<string, map<string,object>> getFieldsMetadataMap(string objectName, string[] fieldNames, boolean sortPicklistValues, string recordTypeApiName){                
        map<string, map<string,object>> result = new map<string, map<string,object>>();
        Map<String,Schema.SObjectType> objGlobalMap = Schema.getGlobalDescribe();                
        
        string keyName = objectName+';;;'+string.valueOf(fieldNames)+';;;'+string.valueOf(sortPicklistValues);
		
        if (ObjectCachedMetadata == null) ObjectCachedMetadata = new   map<string, map<string, map<string,object>>>();
        
        
        if (!ObjectCachedMetadata.containsKey(keyName)){
            if (Schema.getGlobalDescribe().containsKey(objectName)){
                Schema.DescribeSObjectResult obj =  Schema.getGlobalDescribe().get(objectName).getDescribe();
                SObject newObject = obj.getSobjectType().newSObject(null, true);
                map<string,string> fieldNamesMap = new map<string,string>();
                if (fieldNames != null){
                    for (string s : fieldNames) {
                        fieldNamesMap.put( s.toLowerCase(), s );
                    }
                }            
                for (string fieldName : obj.fields.getMap().keySet()){                
                    if (fieldNames == null || fieldNamesMap.containsKey(fieldName) ){
                        Schema.DescribeFieldResult field =  obj.fields.getMap().get( fieldName ).getDescribe(); 
                        string fieldNameCaseSensitive = string.valueOf(obj.fields.getMap().get( fieldName ));
                        object defaultValue = newObject.get(fieldName);
                        result.put( fieldNameCaseSensitive , new map<string,object>() );
                        result.get( fieldNameCaseSensitive).put('Label', field.getLabel());
                        result.get( fieldNameCaseSensitive).put('HelpText', field.getInlineHelpText()); 					
                        result.get(fieldNameCaseSensitive ).put('DefaultValue', defaultValue );                    
                        result.get(fieldNameCaseSensitive ).put('isDependentPicklist', boolean.valueOf(field.isDependentPicklist()));
                        result.get(fieldNameCaseSensitive ).put('Controller', (field.getController()!=null)? field.getController().getDescribe().getName():'' );
                        result.get(fieldNameCaseSensitive ).put('Digits', field.getDigits());
                        result.get(fieldNameCaseSensitive ).put('Length', field.getLength());
                        result.get(fieldNameCaseSensitive ).put('Precision', field.getPrecision());
                        result.get(fieldNameCaseSensitive ).put('Type', field.getType());
                        result.get(fieldNameCaseSensitive ).put('isAccessible', field.isAccessible());
                        result.get(fieldNameCaseSensitive ).put('isUpdateable', field.isUpdateable());
                        result.get(fieldNameCaseSensitive ).put('isAutoNumber', field.isAutoNumber());
                        result.get(fieldNameCaseSensitive ).put('isCalculated', field.isCalculated());
                        result.get(fieldNameCaseSensitive ).put('isCustom', field.isCustom());
                        result.get(fieldNameCaseSensitive ).put('isIdLookup', field.isIdLookup());
                        result.get(fieldNameCaseSensitive ).put('isNameField', field.isNameField());
                        result.get(fieldNameCaseSensitive ).put('isNamePointing', field.isNamePointing());
                        result.get(fieldNameCaseSensitive ).put('isNillable', field.isNillable());                    
                        
                        set<string> picklistValuesByRecordType = null;
                        
                        if (recordTypeApiName != null){
                            picklistValuesByRecordType = new set<string>( PicklistHelper.getPicklistValuesByRecordType(objectName, field.getName(), recordTypeApiName) );
                        }
                        
                        //Sort Picklist Values
                        list<string> picklistValues = new list<string>();
                        for (Schema.PicklistEntry pe : field.getPicklistValues()){
                            if (pe.isActive()) {
                                if (picklistValuesByRecordType !=null){
                                    if (picklistValuesByRecordType.contains(pe.getValue())){
										picklistValues.add(pe.getValue());                                         
                                    }
                                }else{
                                    picklistValues.add(pe.getValue());                                         
                                }                               
                            }
                        }
                        
                        if (field.isDependentPicklist()){
                            map<string,list<string>> dependencyMap = PicklistHelper.getDependentOptionsMap(objectName, field.getController().getDescribe().getName(), field.getName());
                            if (picklistValuesByRecordType != null){
                                for (string key : dependencyMap.keySet()){
									string[] matchedValues = new list<string>();
                                    for (string val : dependencyMap.get(key)){
                                        if (picklistValuesByRecordType.contains(val)){
                                            matchedValues.add(val);
                                        }
                                    }
                                    dependencyMap.put(key,matchedValues);
                                }
                            }
                            result.get(fieldNameCaseSensitive ).put('DependencyMap',  dependencyMap);
                        }
                        
                        if (sortPicklistValues)
                            picklistValues.sort();
                        
                        result.get(fieldNameCaseSensitive ).put('PicklistValues', picklistValues );
                    }               
                }
            }
            ObjectCachedMetadata.put(keyName, result);
        }
        
        return ObjectCachedMetadata.get(keyName);
    }    
}