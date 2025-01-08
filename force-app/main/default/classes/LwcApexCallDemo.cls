public with sharing class LwcApexCallDemo {
    @AuraEnabled
    public static List<Contact> queryContactById(){
        return [SELECT Id, FirstName, LastName, Email, Phone
                FROM Contact
                LIMIT 10 ];
    }
    @AuraEnabled
    public static List<Participant__c> queryParticipantsByContactId(Id recordId){
        return [SELECT Id, Name, Status__c, Training__r.Name
                FROM Participant__c WHERE
                Contact_Name__c =: recordId
                LIMIT 10 ];
    }




    
}