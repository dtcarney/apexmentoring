public with sharing class ModifyStrings {
    public ModifyStrings() {

    }
    public String exceptFirstTwo(String str){
        String result = str.deleteWhitespace();
        Integer length = result.length();
        result = result.substring(2,length);
        return result;

    }
}