public with sharing class ErrorLogCleanUpBatch implements  Database.Batchable<sObject> {

    public Database.QueryLocator start(Database.BatchableContext BC) {
        
        System_Settings__mdt errorLogSettings = [
            SELECT DeveloperName, Error_Log_Retention_Days__c
            FROM System_Settings__mdt 
            WHERE DeveloperName = 'Error_Log_Settings' 
            LIMIT 1 
        ];

        String query = 'SELECT Id, is_important__c, CreatedDate FROM Error_Log__c WHERE is_important__c = FALSE AND CreatedDate < LAST_N_DAYS:'+ String.valueOf(errorLogSettings.Error_Log_Retention_Days__c);
        System.debug('query: '+ query);
        return Database.getQueryLocator(query);
    }

    public void execute(Database.BatchableContext BC, List<Error_Log__c> errors) {
        delete errors;
    }

    public void finish(Database.BatchableContext BC) {}
}