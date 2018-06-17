global without sharing class MetadataHelper {
    
    // *****************BEGIN EXPERIMENTS*********************
    global class FieldInfo {
        @AuraEnabled global string Name{get;set;}
        @AuraEnabled global string ReferenceTargetField{get;set;}
        @AuraEnabled global string[] ReferenceTo{get;set;}
        @AuraEnabled global string Label{get;set;}
        @AuraEnabled global string HelpText{get;set;}
        @AuraEnabled global string DefaultValue{get;set;}
        @AuraEnabled global string Controller{get;set;}        
        @AuraEnabled global string Type{get;set;}

        @AuraEnabled global integer Digits{get;set;}
        @AuraEnabled global integer Length{get;set;}
        @AuraEnabled global integer Precision{get;set;}


        @AuraEnabled global boolean isDependentPicklist {get;set;}
        @AuraEnabled global boolean isNamePointing {get;set;}
        @AuraEnabled global boolean isAccessible {get;set;}
        @AuraEnabled global boolean isUpdateable {get;set;}
        @AuraEnabled global boolean isCreateable {get;set;}
        @AuraEnabled global boolean isCaseSensitive {get;set;}
        @AuraEnabled global boolean isCascadeDelete {get;set;}
        @AuraEnabled global boolean isDefaultedOnCreate {get;set;}
        @AuraEnabled global boolean isGroupable {get;set;}
        @AuraEnabled global boolean isHtmlFormatted {get;set;}
        @AuraEnabled global boolean isPermissionable {get;set;}
        @AuraEnabled global boolean isRestrictedDelete {get;set;}
        @AuraEnabled global boolean isRestrictedPicklist {get;set;}
        @AuraEnabled global boolean isSortable {get;set;}
        @AuraEnabled global boolean isUnique {get;set;}
        @AuraEnabled global boolean isWriteRequiresMasterRead {get;set;}
        @AuraEnabled global boolean isAutoNumber {get;set;}
        @AuraEnabled global boolean isCalculated {get;set;}
        @AuraEnabled global boolean isCustom {get;set;}
        @AuraEnabled global boolean isIdLookup {get;set;}
        @AuraEnabled global boolean isNameField {get;set;}
        @AuraEnabled global boolean isNillable {get;set;}
        
        @AuraEnabled global list<string> PicklistValues{get;set;}
        @AuraEnabled global list<map<string,string>> PicklistOptions{get;set;}
        
        @AuraEnabled global map<string, string[]> DependencyMap{get;set;}
		@AuraEnabled global map<string, map<string,string>> DependencyMapOptions{get;set;}

        public FieldInfo(Schema.DescribeFieldResult init, string sobjectName, boolean sortPicklistValues, string recordTypeApiName){
            this.Name= init.getName();
            this.ReferenceTargetField= init.getReferenceTargetField();
            
            this.ReferenceTo = new list<string>();
            for (Schema.SObjectType sot : init.getReferenceTo() ) this.ReferenceTo.add(sot.getDescribe().getName());
            
            this.Label= init.getLabel();
            this.HelpText= init.getInlineHelpText();
            this.DefaultValue= string.valueOf(init.getDefaultValue());
            this.Controller = (init.getController() != null)?init.getController().getDescribe().getName() : '';
            this.Type= string.valueOf(init.getType());
            
            this.Digits = init.getDigits();
            this.Length = init.getLength();
            this.Precision = init.getPrecision();
            
            this.isDependentPicklist = init.isDependentPicklist();
            this.isNamePointing = init.isNamePointing();
            this.isAccessible = init.isAccessible();
            this.isUpdateable = init.isUpdateable();
            this.isCreateable = init.isCreateable();
            this.isCaseSensitive = init.isCaseSensitive();
            this.isCascadeDelete = init.isCascadeDelete();
            this.isDefaultedOnCreate = init.isDefaultedOnCreate();
            this.isGroupable = init.isGroupable();
            this.isHtmlFormatted = init.isHtmlFormatted();
            this.isPermissionable = init.isPermissionable();
            this.isRestrictedDelete = init.isRestrictedDelete();
            this.isRestrictedPicklist = init.isRestrictedPicklist();
            this.isSortable = init.isSortable();
            this.isUnique = init.isUnique();
            this.isWriteRequiresMasterRead = init.isWriteRequiresMasterRead();
            this.isAutoNumber = init.isAutoNumber();
            this.isCalculated = init.isCalculated();
            this.isCustom = init.isCustom();
            this.isIdLookup = init.isIdLookup();
            this.isNameField = init.isNameField();
            this.isNillable = init.isNillable();
            
            
            set<string> picklistValuesByRecordType = null; 
            
            if (recordTypeApiName != null && init.getController() != null){
                
                picklistValuesByRecordType = new set<string>( PicklistHelper.getPicklistValuesByRecordType(init.getSobjectField().getDescribe().getName(), init.getController().getDescribe().getName(), recordTypeApiName) );            
            }
            
            system.debug('picklistValuesByRecordType==> ' + JSON.serialize(picklistValuesByRecordType));
            
            this.PicklistValues = new list<string>();
            this.PicklistOptions = new list<map<string,string>>();
            for (Schema.PicklistEntry pe : init.getPicklistValues()){
                if (pe.isActive()){ 
                    if (picklistValuesByRecordType != null){
                        if (picklistValuesByRecordType.contains( pe.getValue() ) || picklistValuesByRecordType.contains( pe.getLabel() )){
                        	this.PicklistValues.add(pe.getValue());  
                            this.PicklistOptions.add(new Map<string,string>{ 'value'=>pe.getValue(), 'label'=>pe.getLabel() });
                        }
                    }else{
                        this.PicklistValues.add(pe.getValue());
                        this.PicklistOptions.add(new Map<string,string>{ 'value'=>pe.getValue(), 'label'=>pe.getLabel() });
                    }
				}
            }
            
            this.DependencyMap = new map<string, string[]>();
            if (init.isDependentPicklist() )
            {                
                string controllerName = init.getController().getDescribe().getName();
                string dependentName = init.getName();
                system.debug('===|=== sobjectName: ' + sobjectName);
                system.debug('===|=== controllerName: ' + controllerName);
                system.debug('===|=== dependentName: ' + dependentName);
            	map<string, string[]> mapDependency = PicklistHelper.getDependentOptionsMap(sobjectName,controllerName,dependentName);
                Map<String,map<string,string>> mapDependencyMap = DependentPicklistValuesCalculator.GetDependentOptionsMap(sobjectName,controllerName,dependentName);
                
                if (mapDependency!= null) this.DependencyMap = mapDependency;
                if (mapDependencyMap!= null) this.DependencyMapOptions = mapDependencyMap;
            }
            
            //Sort Values
            if (sortPicklistValues) 
            {                 
                if (this.PicklistValues.size() > 0) this.PicklistValues.sort();
                if ( this.DependencyMap.size() > 0) for(string key : this.DependencyMap.keyset()) this.DependencyMap.get(key).sort();
            }
        }
    }
    
    global class RecordTypeInfo {
        @AuraEnabled global string Name {get;set;}
        @AuraEnabled global Id RecordTypeId {get;set;}
        @AuraEnabled global boolean isAvailable {get;set;}
        @AuraEnabled global boolean isDefaultRecordTypeMapping {get;set;}
        @AuraEnabled global boolean isMaster {get;set;}
        
        public RecordTypeInfo(Schema.RecordTypeInfo init){
            this.Name = init.getName();
            this.RecordTypeId = init.getRecordTypeId();
            this.isAvailable = init.isAvailable();
            this.isDefaultRecordTypeMapping = init.isDefaultRecordTypeMapping();
            this.isMaster = init.isMaster();
        }
    }
    
    global class SObjectInfo{
        @AuraEnabled global boolean HasSubtypes {get;set;}
        @AuraEnabled global string KeyPrefix {get;set;}
        @AuraEnabled global string Label {get;set;}
        @AuraEnabled global string LabelPlural {get;set;}
        @AuraEnabled global string LocalName {get;set;}
        @AuraEnabled global string Name {get;set;}
        
        @AuraEnabled global RecordTypeInfo[] RecordTypeInfos {get;set;}
        @AuraEnabled global map<Id, RecordTypeInfo> RecordTypeInfosById {get;set;}
        @AuraEnabled global map<string, RecordTypeInfo> RecordTypeInfosByName {get;set;}
        
        @AuraEnabled global boolean isAccessible {get;set;}
        @AuraEnabled global boolean isCreateable {get;set;}
        @AuraEnabled global boolean isCustom {get;set;}
        @AuraEnabled global boolean isCustomSetting {get;set;}
        @AuraEnabled global boolean isDeletable {get;set;}
        @AuraEnabled global boolean isDeprecatedAndHidden {get;set;}
        @AuraEnabled global boolean isFeedEnabled {get;set;}
        @AuraEnabled global boolean isMergeable {get;set;}
        @AuraEnabled global boolean isMruEnabled {get;set;}
        @AuraEnabled global boolean isQueryable {get;set;}
        @AuraEnabled global boolean isSearchable {get;set;}
        @AuraEnabled global boolean isUndeletable {get;set;}
        @AuraEnabled global boolean isUpdateable {get;set;}
        
        
        @AuraEnabled global map<string, Schema.SObjectField> fieldsMap {get;set;}
        
        
        public SObjectInfo(){}
        public SObjectInfo(Schema.DescribeSObjectResult init){
            this.HasSubtypes = init.getHasSubtypes();
            this.KeyPrefix = init.getKeyPrefix();
            this.Label = init.getLabel();
            this.LabelPlural = init.getLabelPlural();
            this.LocalName = init.getLocalName();
            this.Name = init.getName();
            
            this.isAccessible = init.isAccessible();
            this.isCreateable = init.isCreateable();
            this.isCustom = init.isCustom();
            this.isCustomSetting = init.isCustomSetting();
            this.isDeletable = init.isDeletable();
            this.isDeprecatedAndHidden = init.isDeprecatedAndHidden();
            this.isFeedEnabled = init.isFeedEnabled();
            this.isMergeable = init.isMergeable();
            this.isMruEnabled = init.isMruEnabled();
            this.isQueryable = init.isQueryable();
            this.isSearchable = init.isSearchable();
            this.isUndeletable = init.isUndeletable();
            this.isUpdateable = init.isUpdateable();
            
            this.RecordTypeInfos = new list<RecordTypeInfo>();
            this.RecordTypeInfosById = new map<Id, RecordTypeInfo>();
            this.RecordTypeInfosByName = new map<string, RecordTypeInfo>();
            
            
            map<id, schema.RecordTypeInfo> rtbyIdMap = init.getRecordTypeInfosById();
            map<string, schema.RecordTypeInfo> rtByNameMap = init.getRecordTypeInfosByName();
            
            for(Schema.RecordTypeInfo rti : init.getRecordTypeInfos()){ 
                this.RecordTypeInfos.add(new RecordTypeInfo(rti)); 
            }
            if (rtbyIdMap.size() > 0) {
                for(Id rtId : rtbyIdMap.keyset()) { 
                    this.RecordTypeInfosById.put(rtId, new RecordTypeInfo(rtbyIdMap.get(rtId))); 
                }
            }
            if (rtByNameMap.size() > 0){
                for(String rtName : rtByNameMap.keyset()) {
                    this.RecordTypeInfosByName.put(rtName, new RecordTypeInfo(rtByNameMap.get(rtName))); 
                }
            }
            
            this.fieldsMap = init.fields.getMap();
        }
    }
    
    static map<string, SObjectInfo> getSobjectInfoCache{get;set;}
    global static SObjectInfo getSobjectInfo(string sobjectName){
        if (getSobjectInfoCache == null){
            getSobjectInfoCache = new map<string,sobjectinfo>();
        }
        if (!getSobjectInfoCache.containsKey(sobjectName)){
			getSobjectInfoCache.put(sobjectName, new sobjectinfo( Schema.getGlobalDescribe().get(sobjectName).getDescribe()));
        }        
        return getSobjectInfoCache.get(sobjectName);
    }
    
    static map<string, map<string,FieldInfo>> getFieldInfosCache{get;set;}
    global static map<string, FieldInfo> getFieldInfos(string sobjectName, string[] fieldNames, boolean sortPicklistValues, string recordTypeApiName){
        if (getFieldInfosCache == null) getFieldInfosCache = new map<string,map<string,FieldInfo>>();
        string keyName = 
            sobjectName + ';;;' +
            string.valueOf(fieldNames)+';;;'+ 
            sortPicklistValues + ';;;' +
            ((fieldNames!=null)?string.join(fieldNames,','):'') + ';;;' +
			string.valueOf(sortPicklistValues);
        
        if (!getFieldInfosCache.containsKey(keyName)){
            map<string, FieldInfo> result = new  map<string, FieldInfo>();
            if (Schema.getGlobalDescribe().containsKey(sobjectName)){
                Schema.DescribeSObjectResult dor = Schema.getGlobalDescribe().get(sobjectName).getDescribe();
                map<string, Schema.SObjectField> fieldMap = dor.fields.getMap();
                
                string[] fieldsToLookFor = (fieldNames==null)?new list<string>(fieldMap.keyset()):fieldNames;
                
                for(string fieldName : fieldsToLookFor){
                    Schema.DescribeFieldResult field = fieldMap.get(fieldName).getDescribe();
                    result.put(field.getName(), new FieldInfo(field, sobjectName, true, null) );
                }
            }
            getFieldInfosCache.put(keyName, result);
        }
        return getFieldInfosCache.get(keyName);
    }
    // *****************END EXPERIMENTS*********************
    
    
    global static map<string, map<string, map<string,object>>> ObjectCachedMetadata{get;set;}
    global static map<string, map<string,object>> getFieldsMetadataMap(string objectName, string[] fieldNames, boolean sortPicklistValues, string recordTypeApiName){                        
        map<string, map<string,object>> result = new map<string, map<string,object>>();
        Map<String,Schema.SObjectType> objGlobalMap = Schema.getGlobalDescribe();
        list<string> statusPicklist=new string[]{'Cancelled','Closed (Closed)','Complete','In Progress','New','On Hold','SA Review','Submitted'}; 
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
                        result.get( fieldNameCaseSensitive).put('ReferenceTo', string.join(referenceToResult,','));
                        result.get( fieldNameCaseSensitive).put('Label', field.getLabel());
                        result.get( fieldNameCaseSensitive).put('HelpText', field.getInlineHelpText()); 					
                        result.get(fieldNameCaseSensitive ).put('DefaultValue', defaultValue );                                            
                        result.get(fieldNameCaseSensitive ).put('Controller', (field.getController()!=null)? field.getController().getDescribe().getName():'' );                        
                        result.get(fieldNameCaseSensitive ).put('Digits', field.getDigits());
                        result.get(fieldNameCaseSensitive ).put('Length', field.getLength());
                        result.get(fieldNameCaseSensitive ).put('Precision', field.getPrecision());
                        result.get(fieldNameCaseSensitive ).put('Type', field.getType());
                        
                        result.get(fieldNameCaseSensitive ).put('isDependentPicklist', boolean.valueOf(field.isDependentPicklist()));
                        result.get( fieldNameCaseSensitive).put('isNamePointing', isNamePointing);                                                
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
                            //system.debug('fieldNameval::'+field.getName());
                            
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
                        if(objectName=='Case'&&fieldName=='Status'){
                          result.get(fieldNameCaseSensitive ).put('PicklistValues',statusPicklist);
                        }
                    }               
                }
            }
            ObjectCachedMetadata.put(keyName, result);
        }
        
        return ObjectCachedMetadata.get(keyName);
    }
    
    
    
    
    static map<string, map<string, FieldInfo>> FieldsMetadataMapInfosCache{get;set;}
    global static map<string, FieldInfo> getFieldsMetadataMapInfos(string objectName, set<string> fieldNames, boolean sortPicklistValues, string recordTypeApiName){
        string keyName = objectName+';;;'+string.valueOf(fieldNames)+';;;'+string.valueOf(sortPicklistValues);
        if (FieldsMetadataMapInfosCache == null) FieldsMetadataMapInfosCache = new map<string, map<string, FieldInfo>>();
        
        if (!FieldsMetadataMapInfosCache.containsKey(keyName)){
            map<string, FieldInfo> results = new map<string, FieldInfo>();
            Schema.DescribeSObjectResult dor = Schema.getGlobalDescribe().get(objectName).getDescribe();
            map<string, Schema.SObjectField> fieldMap = dor.fields.getMap();
            
            set<string> fieldNamesSet = new set<String>();
            if (fieldNames != null){
                for (string fn : fieldNames) {
                    fieldNamesSet.add(fn.toLowerCase());
                }
            }else{
                fieldNamesSet.addAll(fieldMap.keyset());
            }
            
            for (String fieldName : fieldMap.keySet() ){
                if (fieldNamesSet.contains(fieldName)){
                    Schema.DescribeFieldResult dfr = fieldMap.get(fieldName).getDescribe();
                    results.put(dfr.getName(), new FieldInfo(dfr, objectName, sortPicklistValues, recordTypeApiName) );
                }                
            }
            FieldsMetadataMapInfosCache.put(keyName, results);
        }        
        return FieldsMetadataMapInfosCache.get(keyName);
    }
    
    
    
}