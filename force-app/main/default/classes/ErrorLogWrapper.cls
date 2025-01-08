public with sharing class ErrorLogWrapper {
    public static void insertLog(Exception e, Boolean isImportant) {
        insert generateLog(e, isImportant);
    }

    public static Error_Log__c generateLog(Exception e, Boolean isImportant) {
        Error_Log__c log = new Error_Log__c();
        String stackTrace = e.getStackTraceString().substringBefore('\n');
        String className = stackTrace.substringAfter('.').substringBefore('.');
        String methodName = stackTrace.substringBefore(':').substringAfter(className).substringAfter('.');
        log.Class_Name__c = className;
        log.Method_Name__c = methodName;
        log.Exception_Message__c = e.getMessage();
        log.Line_Number__c = e.getLineNumber();
        log.Stack_Trace__c = e.getStackTraceString();
        log.is_important__c = isImportant;

        return log;
    }
}