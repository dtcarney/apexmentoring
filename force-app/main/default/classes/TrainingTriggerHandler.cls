public with sharing class TrainingTriggerHandler {
    
    public static void beforeInsert(List<Training__c> newList) {
        TrainingService service = new TrainingService();
        service.calculateInitialRestaurantCommissionForecast(newList);
    }

    public static void afterUpdate(List<Training__c> oldList, List<Training__c> newList, Map<Id,Training__c> oldMap, Map<Id,Training__c> newMap){
        TrainingService service = new TrainingService();
        service.registrationsDecreases(newList,oldMap);
        service.expandedTrainingCapacity(newList,oldMap);
        

    }


}