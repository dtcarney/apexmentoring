public with sharing class TrainingReminderScheduled implements Schedulable {
    public void execute(SchedulableContext sc){

        List<Training__c> trainings = [
            SELECT Id, Name, Start_Date__c, End_Date__c,
            Trainer_Contact__c, Trainer_Contact__r.FirstName, Number_of_Participants__c
            FROM Training__c
            WHERE Start_Date__c >= :Date.today().addDays(3) AND Start_Date__c < :Date.today().addDays(4)
        ];
        System.debug('trainings found: '+ trainings);

        List<Participant__c> activeParticipants = [
            SELECT Id, Name, Contact_Name__c,Contact_Name__r.Email, Training__c, Training__r.Name,
            Training__r.Start_Date__c, Training__r.End_Date__c
            FROM Participant__c
            WHERE Status__c = :TrainingService.ACTIVE_STATUS and Contact_Name__r.Email != null
            AND Training__c in :trainings
        ];
        System.debug('participants found: '+ activeParticipants);
        

        EmailService.notifyTrainerAboutTrainingStart(trainings);

        EmailService.notifyParticipantsAboutTrainingStart(activeParticipants);


    }



    public static List<Participant__c> participantsInTraining(Training__c training){
        List<Participant__c> participants = [
            SELECT Contact_Name__c,Contact_Name__r.Name
            FROM Participant__c
            WHERE Training__c = :training.Id AND Status__c = :TrainingService.ACTIVE_STATUS
        ];
        return participants;
    }



}


