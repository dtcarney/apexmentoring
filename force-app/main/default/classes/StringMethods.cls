public with sharing class StringMethods {
    public StringMethods() {

    }
    public String exceptFirstTwo(String str){
        Integer length = str.length();
        String result = str.substring(1,length);
        result.deleteWhitespace();
        return result;

    }
}