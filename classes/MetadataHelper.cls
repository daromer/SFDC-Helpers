/**************************************
Author             : Danny Robles (dyroblesmercedes@gmail.com)
Purpose            : Helps get the metadata of an SObject and the fields ( uses the picklistvalues to get the picklist values of the fields and also filters by recordtype id).
Reviewed By        : 
Last Modified By   : 
Example            : map<string, map<string,object>> opportunityMetadata = MetadataHelper.getFieldsMetadataMap('Opportunity', new string[]{'StageName'},false,null);
**************************************/

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
                        boolean isNamePointing = field.isNamePointing();
                        list<Schema.sObjectType> referenceToList = field.getReferenceTo();                        
                        string[] referenceToResult = new list<string>();
                        if (referenceToList!= null && referenceToList.size() >0){
                            for(Schema.sObjectType t : referenceToList){
                               referenceToResult.add(string.valueOf(t.getDescribe().getName()));
                            }
                        }
                            
                        result.put( fieldNameCaseSensitive , new map<string,object>() );
                        result.get( fieldNameCaseSensitive).put('Name', field.getName());
                        result.get( fieldNameCaseSensitive).put('ReferenceTargetField', field.getReferenceTargetField());
                        result.get( fieldNameCaseSensitive).put('isNamePointing', isNamePointing);                        
                        result.get( fieldNameCaseSensitive).put('ReferenceTo', string.join(referenceToResult,','));
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
                        result.get(fieldNameCaseSensitive ).put('isCreateable', field.isCreateable());
                        result.get(fieldNameCaseSensitive ).put('isCaseSensitive', field.isCaseSensitive());
                        result.get(fieldNameCaseSensitive ).put('isCascadeDelete', field.isCascadeDelete());
                        result.get(fieldNameCaseSensitive ).put('isDefaultedOnCreate', field.isDefaultedOnCreate());
                        result.get(fieldNameCaseSensitive ).put('isGroupable', field.isGroupable());
                        result.get(fieldNameCaseSensitive ).put('isHtmlFormatted', field.isHtmlFormatted());
                        result.get(fieldNameCaseSensitive ).put('isPermissionable', field.isPermissionable());
                        result.get(fieldNameCaseSensitive ).put('isRestrictedDelete', field.isRestrictedDelete());
                        result.get(fieldNameCaseSensitive ).put('isRestrictedPicklist', field.isRestrictedPicklist());                        
                        result.get(fieldNameCaseSensitive ).put('isSortable', field.isSortable());
                        result.get(fieldNameCaseSensitive ).put('isUnique', field.isUnique());
                        result.get(fieldNameCaseSensitive ).put('isWriteRequiresMasterRead', field.isWriteRequiresMasterRead());
                        result.get(fieldNameCaseSensitive ).put('isAutoNumber', field.isAutoNumber());
                        result.get(fieldNameCaseSensitive ).put('isCalculated', field.isCalculated());
                        result.get(fieldNameCaseSensitive ).put('isCustom', field.isCustom());
                        result.get(fieldNameCaseSensitive ).put('isIdLookup', field.isIdLookup());
                        result.get(fieldNameCaseSensitive ).put('isNameField', field.isNameField());
                        result.get(fieldNameCaseSensitive ).put('isNamePointing', field.isNamePointing());
                        result.get(fieldNameCaseSensitive ).put('isNillable', field.isNillable());                    
                        
                        set<string> picklistValuesByRecordType = null;
                        
                        if (recordTypeApiName != null){
                            system.debug('fieldNameval::'+field.getName());
                            
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
    
    
    global static map<string, map<string,object>> getObjectsMetadataMap( string[] objectNames ){
        map<string, map<string,object>> result = new map<string, map<string,object>>();
        Map<String,Schema.SObjectType> objGlobalMap = Schema.getGlobalDescribe();
        for (string objectName : objectNames){
            if (objGlobalMap.containsKey(objectName)){
                Schema.DescribeSObjectResult dor = objGlobalMap.get(objectName).getDescribe();              
                result.put(objectName, new map<string,object>());
                //result.get(objectName).put('ChildRelationships', dor.getChildRelationships() );
                result.get(objectName).put('HasSubtypes', dor.getHasSubtypes() );
                result.get(objectName).put('KeyPrefix', dor.getKeyPrefix() );
                result.get(objectName).put('Label', dor.getLabel() );
                result.get(objectName).put('LabelPlural', dor.getLabelPlural() );
                result.get(objectName).put('LocalName', dor.getLocalName() );
                result.get(objectName).put('Name', dor.getName() );
                //result.get(objectName).put('RecordTypeInfos', dor.getRecordTypeInfos() );
                //result.get(objectName).put('RecordTypeInfosById', dor.getRecordTypeInfosById() );
                //result.get(objectName).put('RecordTypeInfosByName', dor.getRecordTypeInfosByName() );
                //result.get(objectName).put('SobjectType', dor.getSobjectType() );
                result.get(objectName).put('isAccessible', dor.isAccessible() );
                result.get(objectName).put('isCreateable', dor.isCreateable() );
                result.get(objectName).put('isCustom', dor.isCustom() );
                result.get(objectName).put('isCustomSetting', dor.isCustomSetting() );
                result.get(objectName).put('isDeletable', dor.isDeletable() );
                result.get(objectName).put('isDeprecatedAndHidden', dor.isDeprecatedAndHidden() );
                result.get(objectName).put('isFeedEnabled', dor.isFeedEnabled() );
                result.get(objectName).put('isMergeable', dor.isMergeable() );
                result.get(objectName).put('isMruEnabled', dor.isMruEnabled() );
                result.get(objectName).put('isQueryable', dor.isQueryable() );
                result.get(objectName).put('isSearchable', dor.isSearchable() );
                result.get(objectName).put('isUndeletable', dor.isUndeletable() );
                result.get(objectName).put('isUpdateable', dor.isUpdateable() );
            }
        }
        return result;
    }
}