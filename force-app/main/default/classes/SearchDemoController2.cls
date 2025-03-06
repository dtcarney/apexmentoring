public with sharing class SearchDemoController2 {

    @RemoteAction
    public static String search(String trainingId){
        return [SELECT Id, Name
                FROM Training__c WHERE
                Id =:trainingId].Name;
    }
}