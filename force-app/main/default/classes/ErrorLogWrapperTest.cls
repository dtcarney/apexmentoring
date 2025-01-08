@isTest
public with sharing class ErrorLogWrapperTest {
    
    @isTest
    public static void logErrorTest() {

        Integer result;

        Test.startTest();
        try {
            result = 10/0;
        } catch (Exception e) {
            ErrorLogWrapper.logError(e, false);
        }
        Test.stopTest();

        List<Error_Log__c> errorLogs = [SELECT Id FROM Error_Log__c];
        System.Assert.areEqual(1, errorLogs.size());
    }

    @isTest
    public static void generateLogTest() {

        Integer result;

        Test.startTest();
        try {
            result = 10/0;
        } catch (Exception e) {
            Error_Log__c log = ErrorLogWrapper.generateLog(e, false);
            insert log;
        }
        Test.stopTest();
        
        List<Error_Log__c> errorLogs = [SELECT Id FROM Error_Log__c];
        System.Assert.areEqual(1, errorLogs.size());
    }
}