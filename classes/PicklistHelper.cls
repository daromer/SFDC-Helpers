/**************************************
Author             : Danny Robles
Purpose            : Calculates the dependency asociation values from a two fields (Controller and dependent field)					 
Reviewed By        : 
Last Modified By   : 
Example			   : Map<String,List<String>> valueAndListDependentValuesMap = PicklistHelper.getDependentOptionsMap( objectName , contrfieldName, depfieldName);
**************************************/
//source: http://mysalesforceescapade.blogspot.com/2015/03/getting-dependent-picklist-values-from.html
global class PicklistHelper {  
    
    public class BitSet{
        public Map<String,Integer> alphaNumCharCodes {get;set;}
        public Map<String, Integer> base64CharCodes {get;set;}
        
        public BitSet(){
            LoadCharCodes();
        }
        
        //Method loads the character codes for all letters
        private void LoadCharCodes(){
            alphaNumCharCodes = new Map<String,Integer>{
                'A'=>65,'B'=>66,'C'=>67,'D'=>68,'E'=>69,'F'=>70,'G'=>71,'H'=>72,'I'=>73,'J'=>74,
                    'K'=>75,'L'=>76,'M'=>77,'N'=>78,'O'=>79,'P'=>80,'Q'=>81,'R'=>82,'S'=>83,'T'=>84,
                    'U'=>85,'V'=> 86,'W'=>87,'X'=>88,'Y'=>89,'Z'=>90    
                    };		
                        
                        base64CharCodes = new Map<String, Integer>();
            //all lower cases
            Set<String> pUpperCase = alphaNumCharCodes.keySet();
            for(String pKey : pUpperCase){
                //the difference between upper case and lower case is 32
                alphaNumCharCodes.put(pKey.toLowerCase(),alphaNumCharCodes.get(pKey)+32);
                //Base 64 alpha starts from 0 (The ascii charcodes started from 65)
                base64CharCodes.put(pKey,alphaNumCharCodes.get(pKey) - 65);
                base64CharCodes.put(pKey.toLowerCase(),alphaNumCharCodes.get(pKey) - (65) + 26);
            }
            //numerics
            for (Integer i=0; i<=9; i++){
                alphaNumCharCodes.put(string.valueOf(i),i+48);
                //base 64 numeric starts from 52
                base64CharCodes.put(string.valueOf(i), i + 52);
            }
            
            AlphaNumCharCodes.put('+', 43);
            AlphaNumCharCodes.put('/', 47);
            Base64CharCodes.put('+', 62);
            Base64CharCodes.put('/', 63);
        }
        
        public List<Integer> testBits(String pValidFor,List<Integer> nList){
            List<Integer> results = new List<Integer>();
            List<Integer> pBytes = new List<Integer>();
            Integer bytesBeingUsed = (pValidFor.length() * 6)/8;
            Integer pFullValue = 0;
            if (bytesBeingUsed <= 1)
                return results;
            for(Integer i=0;i<pValidFor.length();i++){
                pBytes.Add((base64CharCodes.get((pValidFor.Substring(i, i+1)))));
            }   
            for (Integer i = 0; i < pBytes.size(); i++)
            {
                Integer pShiftAmount = (pBytes.size()-(i+1))*6;//used to shift by a factor 6 bits to get the value
                pFullValue = pFullValue + (pBytes[i] << (pShiftAmount));
            }
            
            Integer bit;
            Integer targetOctet;
            Integer shiftBits;
            Integer tBitVal;
            Integer n;
            Integer nListSize = nList.size();
            for(Integer i=0; i<nListSize; i++){
                n = nList[i];
                bit = 7 - (Math.mod(n,8)); 
                targetOctet = (bytesBeingUsed - 1) - (n >> bytesBeingUsed); 
                shiftBits = (targetOctet * 8) + bit;            
                tBitVal = ((Integer)(2 << (shiftBits-1)) & pFullValue) >> shiftBits;
                if (tBitVal==1)
                    results.add(n);
            }
            return results;
        }
    }
    
    global class PicklistEntryWrapper{
        public PicklistEntryWrapper(){}
        public String active {get;set;}
        public String defaultValue {get;set;}
        public String label {get;set;}
        public String value {get;set;}
        public String validFor {get;set;}
    }
    
    global static Map<String,List<String>> getDependentOptionsMap(String objName, String contrfieldName, String depfieldName){
        
        String objectName = objName.toLowerCase();
        String controllingField = contrfieldName.toLowerCase();
        String dependentField = depfieldName.toLowerCase();        
        
        Map<String,List<String>> objResults = new Map<String,List<String>>();
        //get the string to sobject global map
        Map<String,Schema.SObjectType> objGlobalMap = Schema.getGlobalDescribe();
        if (!Schema.getGlobalDescribe().containsKey(objectName)){
            System.debug('OBJNAME NOT FOUND --.> ' + objectName);
            return null;
        }
        
        Schema.SObjectType objType = Schema.getGlobalDescribe().get(objectName);
        if (objType==null){
            return objResults;
        }
        Bitset bitSetObj = new Bitset();
        Map<String, Schema.SObjectField> objFieldMap = objType.getDescribe().fields.getMap();
        //Check if picklist values exist
        if (!objFieldMap.containsKey(controllingField) || !objFieldMap.containsKey(dependentField)){
            System.debug('FIELD NOT FOUND --.> ' + controllingField + ' OR ' + dependentField);
            return objResults;     
        }
        List<Schema.PicklistEntry> contrEntries = objFieldMap.get(controllingField).getDescribe().getPicklistValues();
        List<Schema.PicklistEntry> depEntries = objFieldMap.get(dependentField).getDescribe().getPicklistValues();
        objFieldMap = null;
        List<Integer> controllingIndexes = new List<Integer>();
        for(Integer contrIndex=0; contrIndex<contrEntries.size(); contrIndex++){            
            Schema.PicklistEntry ctrlentry = contrEntries[contrIndex];
            String label = ctrlentry.getLabel();
            objResults.put(label,new List<String>());
            controllingIndexes.add(contrIndex);
        }
        List<Schema.PicklistEntry> objEntries = new List<Schema.PicklistEntry>();
        List<PicklistEntryWrapper> objJsonEntries = new List<PicklistEntryWrapper>();
        for(Integer dependentIndex=0; dependentIndex<depEntries.size(); dependentIndex++){            
            Schema.PicklistEntry depentry = depEntries[dependentIndex];
            objEntries.add(depentry);
        } 
        objJsonEntries = (List<PicklistEntryWrapper>)JSON.deserialize(JSON.serialize(objEntries), List<PicklistEntryWrapper>.class);
        List<Integer> indexes;
        for (PicklistEntryWrapper objJson : objJsonEntries){
            if (objJson.validFor==null || objJson.validFor==''){
                continue;
            }
            indexes = bitSetObj.testBits(objJson.validFor,controllingIndexes);
            for (Integer idx : indexes){                
                String contrLabel = contrEntries[idx].getLabel();
                objResults.get(contrLabel).add(objJson.label);
            }
        }
        objEntries = null;
        objJsonEntries = null;
        return objResults;
    }
    
    
    
    
    
    
    /****** Aditional Functions not Described in the source link *****/
    
    global static list<string> GetPicklistValues(string objectName, string fieldName){
        list<string> result = new list<string>();        
        SObjectType accountType = Schema.getGlobalDescribe().get(objectName);        
        Schema.DescribeFieldResult fieldResult = contact.Leadsource.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();        
        if (accountType != null){            
            Map<String,Schema.SObjectField> mfields = accountType.getDescribe().fields.getMap();
            for(string key : mfields.keyset()){
                Schema.SObjectField item = mfields.get(key);    
                Schema.DescribeFieldResult fieldDescribe = item.getDescribe();
                if (fieldDescribe.getName() == fieldName){
                    List<Schema.PicklistEntry> entries = fieldDescribe.getPicklistValues();                    
                    for (Schema.PicklistEntry pe : entries) {
                        if (pe.isActive())
                        result.add(pe.getValue());                                   
                    }
                    if (result.size()> 0) break;
                }
            }
        }         
        return result;
    }
    
    global static map<string, map<string,list<string>> > GetAlllPicklistDependencies( string objectName ){
        map<string, map<string,list<string>> > result = new map<string, map<string,list<string>> >();
        map<string, map<string,object>> fieldsMetadataOfObjectMap = MetadataHelper.getFieldsMetadataMap(objectName, null, true, null);
        for (string fieldName : fieldsMetadataOfObjectMap.keySet()){
            if( fieldsMetadataOfObjectMap.get(fieldName).containsKey('isDependentPicklist')){
                if ( Boolean.valueOf(fieldsMetadataOfObjectMap.get(fieldName).get('isDependentPicklist')  ) ){
                    string controllingField = string.valueOf(fieldsMetadataOfObjectMap.get(fieldName).get('Controller'));
                    result.put( controllingField + '___' + fieldName, getDependentOptionsMap(objectName, controllingField, fieldName) );
                }
            }
        }        
        return result;
    }
    
    public static string scape(string value){
        return (value!=null)? value.replace('%28', '(').replace('%29', ')').replace('%2','/') : null;
    }
    
    global static map<string, object > getPicklistValuesOfSObjectByRecordTypeCache{get; set;}
    global static map<string, set<string> > getPicklistValuesOfSObjectByRecordType(string sobjectName, string recordtypeApiName){
        string cacheKey = sobjectName + '.' + recordtypeApiName;
        
        if (getPicklistValuesOfSObjectByRecordTypeCache == null) getPicklistValuesOfSObjectByRecordTypeCache = new map<string, object >();
        
        if (!getPicklistValuesOfSObjectByRecordTypeCache.containsKey(cacheKey)){
            map<string,set<string>> result = new map<string,set<string>>();
            if (!test.isRunningTest()){
                MetadataService.MetadataPort service = new MetadataService.MetadataPort();
                service.SessionHeader = new MetadataService.SessionHeader_element(); 
                if(SessionId == null){
                    SessionId = Page.CurrentSessionId.getContent().toString().trim();
                }
                service.SessionHeader.sessionId = SessionId;
                
                string fullRecordtypeAPiName =  SObjectName+'.'+recordtypeApiName;
                
                
                MetadataService.RecordType recordType = (MetadataService.RecordType) service.readMetadata(
                    'RecordType', new String[] { fullRecordtypeAPiName }
                ).getRecords()[0];
                
                if (recordType != null && recordType.picklistValues != null){
                    for ( MetadataService.RecordTypePicklistValue rpk : recordType.picklistValues ) { 
                        if( !result.containsKey(rpk.picklist) )result.put(rpk.picklist, new set<string>());                                              
                        for ( MetadataService.PicklistValue pk : rpk.values ) {                    
                            result.get(rpk.picklist).add( scape(pk.fullName) );
                        }
                    }
                }
            }
            getPicklistValuesOfSObjectByRecordTypeCache.put(cacheKey, result);
        }
        return (map<string, set<string> >)getPicklistValuesOfSObjectByRecordTypeCache.get(cacheKey);
    }
    
    
    global static map<string, object> getPicklistValuesByRecordTypeCache{get; private set;}
    global static String SessionId{get;private set;}
    global static string[] getPicklistValuesByRecordType(string SObjectName, string picklistApiName, string recordtypeApiName){
        if (getPicklistValuesByRecordTypeCache == null) getPicklistValuesByRecordTypeCache = new map<string,object>();
        string cacheKey = SObjectName+';'+recordtypeApiName+';'+picklistApiName;
        if (!getPicklistValuesByRecordTypeCache.containsKey(cacheKey)){            
            list<string> rtPicklistValues = new list<string>();
            
            /*MetadataService.MetadataPort service = new MetadataService.MetadataPort();
            service.SessionHeader = new MetadataService.SessionHeader_element(); 
            if(SessionId == null){
                SessionId = Page.CurrentSessionId.getContent().toString().trim();
            }
            service.SessionHeader.sessionId = SessionId;
            
            string fullRecordtypeAPiName =  SObjectName+'.'+recordtypeApiName;
            
            system.debug('service.SessionHeader ====> ' + service.SessionHeader.sessionId);
            system.debug('service.fullRecordtypeAPiName ====> ' + fullRecordtypeAPiName);
            
            MetadataService.RecordType recordType = (MetadataService.RecordType) service.readMetadata(
                'RecordType', new String[] { fullRecordtypeAPiName }
            ).getRecords()[0];
            
            if (recordType != null && recordType.picklistValues != null){
                for ( MetadataService.RecordTypePicklistValue rpk : recordType.picklistValues ) {            
                    if (rpk.picklist == picklistAPIName){                                
                        for ( MetadataService.PicklistValue pk : rpk.values ) {                    
                            rtPicklistValues.add(pk.fullName);
                        }
                    }             
                }
            }*/
            
            map<string, set<string>> pvOfSOjbectByRecordtype = getPicklistValuesOfSObjectByRecordType(SObjectName, recordtypeApiName);
            string[] keys = new list<string>(pvOfSOjbectByRecordtype.keySet());
            
            //system.debug('pvOfSOjbectByRecordtype.keys..... ==> ' + pvOfSOjbectByRecordtype.keySet());
            //system.debug('pvOfSOjbectByRecordtype.values for '+keys[0]+'..... ==> ' + pvOfSOjbectByRecordtype.get(keys[0]) );
            
            if(pvOfSOjbectByRecordtype != null){
                if (pvOfSOjbectByRecordtype.containsKey(picklistApiName)){
                    rtPicklistValues.addAll(new list<string>( pvOfSOjbectByRecordtype.get(picklistApiName) ));
                }
            }
                
            getPicklistValuesByRecordTypeCache.put(cacheKey, rtPicklistValues);
        }        
        return (string[])getPicklistValuesByRecordTypeCache.get(cacheKey);
    }
}