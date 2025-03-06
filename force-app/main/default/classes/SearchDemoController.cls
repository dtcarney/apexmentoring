public with sharing class SearchDemoController {
    public String trainingName {get; private set;}
    public String trainingId {get; set;}

    public SearchDemoController() {
        this.trainingName = '';
    }


    public void search(){
        this.trainingName =  [SELECT Id, Name FROM Training__c WHERE Id = : trainingId].Name;
    }
}