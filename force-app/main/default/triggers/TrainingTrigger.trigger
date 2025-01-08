trigger TrainingTrigger on Training__c (before insert, after update) {
    
    if(Trigger.isBefore && Trigger.isInsert){
        TrainingTriggerHandler.beforeInsert(Trigger.New);
    }
    

    if(Trigger.isAfter && Trigger.isUpdate){
        TrainingTriggerHandler.afterUpdate(Trigger.Old, Trigger.New, Trigger.oldMap, Trigger.newMap);
    }


    
}
