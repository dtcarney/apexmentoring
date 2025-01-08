trigger ParticipantTrigger on Participant__c (before insert, after update, after insert, after delete) {


    if(Trigger.isBefore && Trigger.isInsert){
        ParticipantTriggerHandler.beforeInsert(Trigger.New);
    }
    
    //after insert
    if(Trigger.isAfter && Trigger.isInsert){
        ParticipantTriggerHandler.afterInsert(Trigger.New, Trigger.newMap);
    }

    //after update
    if(Trigger.isAfter && Trigger.isUpdate){
        ParticipantTriggerHandler.afterUpdate(Trigger.Old,Trigger.New,Trigger.oldMap, Trigger.newMap);
    }

    // after delete
    if(Trigger.isAfter && Trigger.isDelete){
        ParticipantTriggerHandler.afterDelete(Trigger.Old, Trigger.oldMap);
    }

}