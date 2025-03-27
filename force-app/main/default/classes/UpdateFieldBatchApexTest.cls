@isTest
public with sharing class UpdateFieldBatchApexTest {
    
    @isTest
    public static void updateDescriptionFieldTest() {
        List<Account> accounts = new List<Account>();
        for (Integer i = 0; i < 200; i++) {
            accounts.add(new Account(Name = 'Account' + i,Industry = 'Banking'));
        }

        insert accounts;

        String query = 'SELECT Id, Industry FROM Account';
        String entity = 'Account';
        String field = 'Industry';
        String value = 'Biotechnology';

        Test.startTest();
        UpdateFieldBatchApex batch = new UpdateFieldBatchApex(query, entity, field, value);
        Database.executeBatch(batch);
        Test.stopTest();

        List<Account> updatedAccounts = [SELECT Id, Industry FROM Account WHERE Industry = 'Biotechnology'];
        System.assertEquals(200, updatedAccounts.size());
    }


}