@isTest
public with sharing class ErrorLogCleanUpScheduableTest {
    @isTest
    static void testExecute() {
        Integer expected = 1;
        ErrorLogCleanUpSchedulable scheduledJob = new ErrorLogCleanUpSchedulable();

        Test.startTest();
        scheduledJob.execute(null);
        Test.stopTest();
        
        Integer batchJobCount = [
            SELECT COUNT() 
            FROM AsyncApexJob 
            WHERE JobType = 'BatchApex' AND Status = 'Completed' AND CreatedById = :UserInfo.getUserId()
        ];
        
        Assert.areEqual(expected, batchJobCount, 'The batch job should have executed once.');
    }

}