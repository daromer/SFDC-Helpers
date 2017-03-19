@IsTest
public class RandomHelper_Test {
    public static testmethod void testAll(){
        system.assertNotEquals(RandomHelper.rndId(), RandomHelper.rndId(), 'Should NOT return the same random Id') ;
        
        system.assertNotEquals(RandomHelper.rndAlpha(20), RandomHelper.rndAlpha(20), 'Should NOT return the same random alphanumeric text') ;
    }
}