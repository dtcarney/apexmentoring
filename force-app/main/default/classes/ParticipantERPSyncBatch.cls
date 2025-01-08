public with sharing class ParticipantERPSyncBatch implements Database.Batchable<sObject>, Database.AllowsCallouts {

    public Database.QueryLocator start(Database.BatchableContext BC) {
        String query = 'SELECT Id, Contact_Name__r.Email,Contact_Name__r.Name, Training__r.Name, Status__c, ErpId__c FROM Participant__c';
        return Database.getQueryLocator(query);

    }

    public void execute(Database.BatchableContext BC, List<Participant__c> participantsToSync) {
        List<Participant__c> participantsToUpdateInERP = new List<Participant__c>();
        List<Participant__c> participantsToCreateInERP = new List<Participant__c>();
        List<Error_Log__c> errors = new List<Error_Log__c>();

        
        for (Participant__c participant: participantsToSync){
            if(participant.ErpId__c != null){
                participantsToUpdateInERP.add(participant);
            } else {
                participantsToCreateInERP.add(participant);
            }
        }

        for (Participant__c participantToUpdate : participantsToUpdateInERP){

            try {
                ERPparticipantCallout.syncParticipantWithERP(participantToUpdate);
            } catch (Exception e) {
                Error_Log__c error = ErrorLogWrapper.generateLog(e, false);
                errors.add(error);
            }   

        }

        for (Participant__c participantToCreate :participantsToCreateInERP ){
            try {
                participantToCreate = ERPparticipantCallout.createParticipantinERP(participantToCreate);
            } catch (Exception e) {
                Error_Log__c error = ErrorLogWrapper.generateLog(e, false);
                errors.add(error);
            }
            
        }

        update participantsToCreateInERP; //updating ERP ID in salesforce
        insert errors;
    }

    public void finish (Database.BatchableContext bc){

    }

}