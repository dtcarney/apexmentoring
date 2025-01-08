@isTest
public with sharing class ErrorLogCleanUpBatchTest {
    
    @IsTest
    public static void deleteOldUnimportantLogs(){

        System_Settings__mdt errorLogSettings = System_Settings__mdt.getInstance('Error_Log_Settings');

        Integer daysAgoDeleteLogs = Integer.valueOf((errorLogSettings.Error_Log_Retention_Days__c + 1)) * -1;

        List<Error_Log__c> oldLogs = new List<Error_Log__c>();
        for (Integer i = 0; i < 10; i++) {
            oldLogs.add(
                new Error_Log__c(Class_Name__c = 'Class' + i, is_important__c = false)
            );
        }
    

        insert oldLogs;
        
        List<Error_Log__c> insertedLogs = [SELECT Id, CreatedDate FROM Error_Log__c];

        for (Error_Log__c log : insertedLogs){
            Test.setCreatedDate(log.Id, Date.today().addDays(daysAgoDeleteLogs));
            System.debug(log.CreatedDate);
        }

        Test.startTest();
        ErrorLogCleanUpBatch batch = new ErrorLogCleanUpBatch();
        Database.executeBatch(batch);
        Test.stopTest();

        List<Error_Log__c> LogsPostDelete = [SELECT Id FROM Error_Log__c];

        
        Assert.areEqual(0, LogsPostDelete.size() );

    }

    @IsTest
    public static void retainOldImportantLogs(){

        System_Settings__mdt errorLogSettings = System_Settings__mdt.getInstance('Error_Log_Settings');

        Integer daysAgoDeleteLogs = Integer.valueOf((errorLogSettings.Error_Log_Retention_Days__c + 1)) * -1;


        List<Error_Log__c> oldLogs = new List<Error_Log__c>();
            for (Integer i = 0; i < 10; i++) {
                oldLogs.add(new Error_Log__c(
                    Class_Name__c = 'Class' + i, is_important__c = true));
            }
    

        insert oldLogs;
        
        List<Error_Log__c> insertedLogs = [SELECT Id FROM Error_Log__c];

        for (Error_Log__c log : insertedLogs){
            Test.setCreatedDate(log.Id, Date.today().addDays(daysAgoDeleteLogs));
        }

        Test.startTest();
        ErrorLogCleanUpBatch batch = new ErrorLogCleanUpBatch();
        Database.executeBatch(batch);
        Test.stopTest();

        Assert.areEqual(10, insertedLogs.size() );

    }

    @IsTest
    public static void retainRecentLogs(){

        System_Settings__mdt errorLogSettings = System_Settings__mdt.getInstance('Error_Log_Settings');

        Integer daysAgoDeleteLogs = Integer.valueOf((errorLogSettings.Error_Log_Retention_Days__c - 1)) * -1;


        List<Error_Log__c> oldLogs = new List<Error_Log__c>();
            for (Integer i = 0; i < 10; i++) {
                oldLogs.add(new Error_Log__c(
                    Class_Name__c = 'Class' + i, is_important__c = true));
            }
    

        insert oldLogs;
        
        List<Error_Log__c> insertedLogs = [SELECT Id FROM Error_Log__c];

        for (Error_Log__c log : insertedLogs){
            Test.setCreatedDate(log.Id, Date.today().addDays(daysAgoDeleteLogs));
        }

        Test.startTest();
        ErrorLogCleanUpBatch batch = new ErrorLogCleanUpBatch();
        Database.executeBatch(batch);
        Test.stopTest();

        Assert.areEqual(10, insertedLogs.size() );

    }






        
}