public with sharing class StudentCertificateController {

    /*
    * Training Name
    * End Date
    * Topic
    * Trainer's Name and signature
    */  
    public String trainingName {get;set;}
    public DateTime endDate {get;set;}
    public String trainerName {get;set;}
    public String participantName {get;set;}
    

    public StudentCertificateController() {
        Id participantId = ApexPages.currentPage().getParameters().get('id');
        Participant__c participant = [SELECT Id, Training__r.Name,Contact_Name__r.Name, Training__r.End_Date__c,
                                     Training__r.Trainer_Contact__r.Name
                                    FROM Participant__c
                                    WHERE Id =:participantId];
        trainingName = participant.Training__r.Name;
        endDate = participant.Training__r.End_Date__c;
        trainerName = participant.Training__r.Trainer_Contact__r.Name;
        participantName = participant.Contact_Name__r.Name;
    }
}
