global class ProfileHelper {
    static map<id, Profile> profileMap{get;set;}   
    
    static{
        string query = QueryHelper.getSelectAll('Profile', null);
        profileMap = new map<id, Profile>((Profile[])Database.query(query)); 
    }
    
    global static Profile CurrentUserProfile{get{
        return getById(userinfo.getProfileId());
    }}
    
    global static string CurrentUserProfileName{get{
        return CurrentUserProfile.Name;
    }}
	
    global static Profile[] getAll(){        
        return (profileMap != null)? profileMap.values() : null;        
    }
    
    global static Profile getById(string Id){
        return (profileMap != null && profileMap.containsKey(Id))? profileMap.get(id) : null;
    }
    
    global static Profile getByName(string profileName){
        if (profileMap != null ){
            for (Profile p : profileMap.values()){
                if (p.Name == profileName){
                    return p;
                }
            }
        }
        return null;
    }
    
}