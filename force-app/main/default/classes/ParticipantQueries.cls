public with sharing class ParticipantQueries {
    public static List<Participant__c> queryParticipantsByIdAndStatus(Id trainingId, String status) {
        return [
            SELECT Id, Training__c,Training__r.Name, Status__c,Contact_Name__r.Email,Contact_Name__r.Name, CreatedDate
            FROM Participant__c
            WHERE Training__c =:trainingId AND Status__c =: status 
            ORDER BY CreatedDate
        ];
    }

    public static List<Participant__c> queryParticipantsByIds(Set<Id> participantIds){
        return [
            SELECT Id,PaymentLink__c, Training__c, Training__r.Name, Status__c,Contact_Name__r.Email,Contact_Name__r.Name, CreatedDate
            FROM Participant__c
            WHERE Id IN: participantIds
        ];
    }

    public static  List<Participant__c> queryParticipantContactData(Set<Id> participantIds) {
        return [
            SELECT CreatedDate,erpId__c, Contact_Name__r.Name, Contact_Name__r.Email,
            Id, Status__c, Contact_Name__c
            FROM Participant__c
            WHERE Id IN: participantIds
        ];
    }
}