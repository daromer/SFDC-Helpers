/**************************************
Author             : Danny Robles (dyroblesmercedes@gmail.com)
Purpose            : Helps to generate random words, char or id
Reviewed By        : 
Last Modified By   : 
Example            : Id testId = RandomHelper.rndId();
**************************************/
global class RandomHelper {
    
    static string[] letters = new string[]{'a','b','c','d','e','f','g','h','i','j','k','l','m','n','o','p','q','r','s','t','u','v','w','x','y','z'};
    
    global static Integer rndNum(integer min, integer max) {
        return integer.valueOf(Math.random() * (max - min) + min);
    }
    
	global static string rndLetter(){        
        integer idx = rndNum(0, letters.size() - 1);
		return letters[ idx ];
    }
    
    global static string rndAlpha(integer charLength){
        string result = '';
        for (integer i = 0; i < charLength; i++){
            integer r = Math.mod( rndNum(1,9) , 2 );
            if (r==0){
                result += string.valueof( rndNum(0,9) );
            }else{
                if ( Math.mod( rndNum(1,9), 2) == 0 ){
					result += string.valueof( rndLetter() ).toLowerCase();
                }else{
                    result += string.valueof( rndLetter() ).toUpperCase();
                }                
            }
        }
        return result;
    }
    
    global static string rndId(){
        string result = '';
        for (integer i = 0; i < 15; i++){
            integer r = Math.mod( rndNum(1,9) , 2 );
            if (r==0){
                result += string.valueof( rndNum(1,9) );
            }else{
                if ( Math.mod( rndNum(1,9), 2) == 0 ){
					result += string.valueof( rndLetter() ).toLowerCase();
                }else{
                    result += string.valueof( rndLetter() ).toUpperCase();
                }                
            }
        }
        return result;
    }

}