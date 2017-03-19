@IsTest
public class ProfileHelper_Test {
    public static testmethod void testAllMethods(){
        Profile currentProfile = [Select Id, Name from Profile where id=:userinfo.getProfileId() limit 1];        
        
        map<id, profile> all = new map<id,profile>([select id from Profile]);
        
        system.assertEquals( currentProfile.Name , ProfileHelper.CurrentUserProfileName, 'Should retrieve the same profile name as the current user');        
        
        system.assertEquals( currentProfile.Id, Profilehelper.CurrentUserProfile.Id, 'Should retrieve same profile id as current user user' );
        
        system.assertEquals( currentProfile.Id, Profilehelper.getByName(currentProfile.Name).Id, 'Should retrieve same profile Id as current user' );
        
        boolean found = true;
        set<id> profileIds = new set<id>();
        for(profile p : ProfileHelper.getAll()){
            if (!all.containsKey(p.Id)) found = false;
        }        
        
        system.assert(found, 'Should have had found all profiles in getAll method');        
        
        system.assertEquals( null, ProfileHelper.getByName('Some weird profile name that most likely do not exists'), 'Should have return null if it does not found a profile with that name' );
        system.assertEquals( null, ProfileHelper.getById( null ), 'Should have return null if it does not found a profile with that id' );
    }
}