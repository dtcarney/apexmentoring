public with sharing class CaseController {

    @AuraEnabled(cacheable =true)
    public static List<Case> getCases(){
        try {
            System.debug('no error');
            return [SELECT Id, CaseNumber, Priority, Subject, Status FROM Case];
        } catch (Exception e) {
            System.debug('there was an error');
            throw new AuraHandledException(e.getMessage());
        }
    }

}