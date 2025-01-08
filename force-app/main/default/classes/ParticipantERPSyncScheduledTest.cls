@isTest
public with sharing class ParticipantERPSyncScheduledTest {
    @testSetup
    static void setup() {
        RegistrationConfirmationQueueable.bypassPaymentLinkCallout = TRUE;
        ParticipantService.bypassRegistrationQueueable = TRUE;

		List<Account> accountsToInsert = new List<Account>();
        List<Contact> contactsToInsert = new List<Contact>();
        
        RestaurantCommissionMetadata__mdt restaurantCommission =
            RestaurantCommissionMetadata__mdt.getInstance('Default_Commission');

        for (Integer i = 0; i < 3; i++) {
            String accountName = 'Participant Account ' + i;
            String contactName = 'Participant ' + i;
            Account participantAccount = new Account(Name = accountName);
            accountsToInsert.add(participantAccount);
        }

        for(Account account : accountsToInsert) {
            Contact participantContact = new Contact(
                FirstName = account.Name.left(8),
                LastName = 'Participant', 
                Email = account.Name.left(8) + '@test.net',
                AccountId = account.Id);
            contactsToInsert.add(participantContact);
        }

		Account trainerAccount = new Account(Name = 'Trainer Account');
		accountsToInsert.add(trainerAccount);

		Contact trainerContact = new Contact(
            FirstName = 'John',
            LastName = 'Doe', 
            Email ='jdoe@test.net',
            AccountId = trainerAccount.id);
        contactsToInsert.add(trainerContact);

        Insert accountsToInsert;
        Insert contactsToInsert;

		Training_Course__c trainingCourse = new Training_Course__c(Name = 'Test Training Course');
		Insert trainingCourse;

		Restaurant__c restaurant = new Restaurant__c(
            Name = 'Test Restaurant',
            AverageMealCost__c = 0,
            CommissionRate__c = 10
        );

        Insert restaurant;

        Training__c training = new Training__c(
            Name = 'Test Training',
            Restaurant__c = restaurant.id,
			Start_Date__c = Date.Today(),
			End_Date__c = Date.Today().addDays(2),
            Training_Course__c = trainingCourse.id,
			Trainer_Contact__c = trainerContact.id,
            Maximum_Participant_Capacity__c = 2
        );

        Insert training;

        List<Participant__c> participants = new List<Participant__c>();
        
        List<Contact> contacts = [SELECT Id, FirstName, LastName, AccountId
        FROM Contact
        WHERE LastName = 'Participant'
        LIMIT 3];

        for(Contact con: contacts) {
            Participant__c participant = new Participant__c();
            participant.Contact_Name__c = con.id;
            participant.Training__c = training.id;
            participants.add(participant);
        }

        Insert participants;
        Participant__c part = [SELECT Id, ErpId__c FROM Participant__c LIMIT 1];
        part.ErpId__c = '1';
        update part;


    }

    @isTest
    static void testExecute() {

            Test.startTest();
        
            ParticipantERPSyncScheduled scheduledJob = new ParticipantERPSyncScheduled();
            
            scheduledJob.execute(null);
            
            Test.stopTest();
            

            // Check for the completed batch job created by the current test context user
            Integer batchJobCount = [SELECT COUNT() 
                                     FROM AsyncApexJob 
                                     WHERE JobType = 'BatchApex' 
                                     AND Status = 'Completed' 
                                     AND CreatedById = :UserInfo.getUserId()];
            
            System.assertEquals(1, batchJobCount, 'The batch job should have executed once.');
        }

    
}