public with sharing class ParticipantTriggerHandler {



    public static void beforeInsert(List<Participant__c> newList){


        ParticipantService participantService = new participantService();
        participantService.setStatus(newList);
        //participantService.recalculateComissionNewRate(newList);
    }


    public static void afterInsert(List<Participant__c> newList, Map<Id,Participant__c> newMap){

        System.debug('hitting ParticipantTriggerHandler');
        ParticipantService participantService = new participantService();
        participantService.sendParticipantRegistrationEmail(newList);
        participantService.updateParticipantCountOnTrainings(newList);
        //participantService.sendQueuedRegistrantEmail(newList);
    }

    public static  void afterUpdate(List<Participant__c> oldList,List<Participant__c> newList, Map<Id,Participant__c> oldMap, Map<Id,Participant__c> newMap){
    
        ParticipantService participantService = new participantService();
        participantService.sendParticipantRegistrationEmail(newList,oldMap);
        participantService.updateParticipantCountOnTrainings(newList,oldMap);
    }
        //
    

    public static void afterDelete(List<Participant__c> oldList, Map<Id,Participant__c> oldMap){
        ParticipantService participantService = new participantService();
        participantService.deleteParticipantCountOnTrainings(oldList);
    }



}