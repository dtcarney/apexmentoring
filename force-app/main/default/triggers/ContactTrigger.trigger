trigger ContactTrigger on Contact (before insert, before update, after insert, after delete, after update ) {

    if(Trigger.isBefore && (Trigger.isInsert || Trigger.isUpdate)){
        for(Contact contact : Trigger.New){
            if(contact.MailingStreet == null ||
               contact.MailingCity == '' ||
               contact.MailingPostalCode ==''
            ){
                contact.AddError('Please enter Street, City, Postal Code.');
            }
        }
    }

    if(Trigger.isAfter && Trigger.isInsert){
        List<Task> tasks = new List<Task>();

        for (Contact con : Trigger.New){
            if(con.email == ''){
                Task task = new Task();
                task.Subject = 'Get Email Address';
                task.Description = 'Email address is missing';
                task.OwnerId = con.OwnerId;
                task.WhoId = con.Id;
                task.ActivityDate = System.today() + 7;
                task.Status = 'Not Started';

                tasks.add(task);
            }   
        }

        insert tasks;
    }

    if(Trigger.isAfter && Trigger.isInsert){
        Map <Id,Integer> accountContactsCountMap = new Map<Id,Integer>();
        
        for(Contact contact : Trigger.New){
            Id accountId = contact.AccountId;

            if(accountContactsCountMap.containsKey(accountId) ){
                Integer count = accountContactsCountMap.get(accountId);
                accountContactsCountMap.put(accountId, count + 1);
            } else {
                accountContactsCountMap.put(accountId, 1);
            }
        }

        List<Account> accounts = [
            SELECT Id, Number_of_Contacts__c 
            FROM Account 
            WHERE Id IN :accountContactsCountMap.keySet()
        ];

        for(Account account : accounts){
            if(account.Number_of_Contacts__c != null){
                account.Number_of_Contacts__c = account.Number_of_Contacts__c + accountContactsCountMap.get(account.Id);
            }
        }

        update accounts;
    }
}