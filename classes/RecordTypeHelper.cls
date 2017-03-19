public class RecordTypeHelper {
    public static ID getIdByName(string sobjectname, string recordtypename){
        ID result = null;
        list<Schema.DescribeSObjectResult> doResults = Schema.describeSObjects(new List<String>{sobjectname});
        for(Schema.DescribeSObjectResult d : doResults){
            map<string,Schema.RecordTypeInfo> rtypes = d.getRecordTypeInfosByName();
            if (rtypes.containsKey(recordtypename)){
                result = rtypes.get(recordtypename).getRecordTypeId();
            }
        }
        return result;
    }
}