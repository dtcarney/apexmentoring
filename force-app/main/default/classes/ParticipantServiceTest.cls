@isTest
public with sharing class ParticipantServiceTest {
    @TestSetup
    static void setup() {
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

    }

    @isTest
    static void testnewParticipants() {

        
		Training_Course__c trainingCourse = [
            SELECT Id, Name 
            FROM Training_Course__c 
            WHERE Name = 'Test Training Course' 
            LIMIT 1
        ];


		Contact trainerContact = [SELECT Id, FirstName, LastName, AccountId FROM Contact WHERE FirstName = 'John' AND LastName = 'Doe' LIMIT 1];

		Restaurant__c restaurant = [SELECT Id, Name, AverageMealCost__c, CommissionRate__c
        FROM Restaurant__c
        WHERE Name = 'Test Restaurant'
        LIMIT 1];

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

        List<Contact> contacts = [SELECT Id, FirstName, LastName, AccountId
        FROM Contact
        WHERE LastName = 'Participant'
        LIMIT 3];

        List<Participant__c> participants = new List<Participant__c>();

        for(Contact con: contacts) {
            Participant__c participant = new Participant__c();
            participant.Contact_Name__c = con.id;
            participant.Training__c = training.id;
            participants.add(participant);
        }


        Test.startTest();
        Insert participants;
        Test.stopTest();

        List<Participant__c> activeParticipants = [SELECT Id, Contact_Name__c, Training__c
        FROM Participant__c
        WHERE Contact_Name__c IN :contacts
        AND Training__c = :training.id AND Status__c =: TrainingService.ACTIVE_STATUS];

        List<Participant__c> queuedParticipants = [SELECT Id, Contact_Name__c, Training__c
        FROM Participant__c
        WHERE Contact_Name__c IN :contacts
        AND Training__c = :training.id AND Status__c =: TrainingService.IN_QUEUE_STATUS];

        System.debug('active parts ' + activeParticipants);
        System.debug('queued parts ' + queuedParticipants);

        //ApexClass apexClass = [SELECT Id, Name FROM ApexClass WHERE Name = 'RegistrationConfirmationQueueable'];
        List<AsyncApexJob> jobs = [SELECT Id, ApexClassID, MethodName, Status, JobType, CreatedDate
        FROM AsyncApexJob WHERE JobType = 'Queueable'];
        Integer jobSize = jobs.size();

        Assert.areEqual(2,activeParticipants.size(),'Number of Active participants should be 2');
        Assert.areEqual(1,queuedParticipants.size(),'Number of In queue participants should be 1');
        Assert.areEqual(1,jobSize,'There should be one RegistrationConfirmationQueueable job');


    }

    @isTest
    static void testdeleteActiveParticipant() {
                
		Training_Course__c trainingCourse = [SELECT Id, Name FROM Training_Course__c WHERE Name = 'Test Training Course' LIMIT 1];


		Contact trainerContact = [SELECT Id, FirstName, LastName, AccountId FROM Contact WHERE FirstName = 'John' AND LastName = 'Doe' LIMIT 1];

		Restaurant__c restaurant = [SELECT Id, Name, AverageMealCost__c, CommissionRate__c
        FROM Restaurant__c
        WHERE Name = 'Test Restaurant'
        LIMIT 1];

        Training__c training = new Training__c(
            Name = 'Test Training',
            Restaurant__c = restaurant.id,
			Start_Date__c = Date.Today(),
			End_Date__c = Date.Today().addDays(2),
            Training_Course__c = trainingCourse.id,
			Trainer_Contact__c = trainerContact.id,
            Number_of_Participants__c = 0,
            Maximum_Participant_Capacity__c = 3
        );

        Insert training;


        List<Contact> contacts = [SELECT Id, FirstName, LastName, AccountId
        FROM Contact
        WHERE LastName = 'Participant'
        LIMIT 3];

        List<Participant__c> participants = new List<Participant__c>();

        for(Contact con: contacts) {
            Participant__c participant = new Participant__c();
            participant.Contact_Name__c = con.id;
            participant.Training__c = training.id;
            participants.add(participant);
        }

        Insert participants;

        Test.startTest();
        delete participants[0];
        Test.stopTest();

        List<Participant__c> activeParticipants = [SELECT Id, Contact_Name__c, Training__c
        FROM Participant__c
        WHERE Contact_Name__c IN :contacts
        AND Training__c = :training.id AND Status__c =: TrainingService.ACTIVE_STATUS];

        List<Participant__c> queuedParticipants = [SELECT Id, Contact_Name__c, Training__c
        FROM Participant__c
        WHERE Contact_Name__c IN :contacts
        AND Training__c = :training.id AND Status__c =: TrainingService.IN_QUEUE_STATUS];

        System.debug('active parts ' + activeParticipants);
        System.debug('queued parts ' + queuedParticipants);



        Assert.areEqual(2,training.Number_of_Participants__c,'Number of participants on training should be 2');


    }
    
    @isTest
    static void testChangeParticipantToCancelled() {
                
		Training_Course__c trainingCourse = [SELECT Id, Name FROM Training_Course__c WHERE Name = 'Test Training Course' LIMIT 1];


		Contact trainerContact = [SELECT Id, FirstName, LastName, AccountId FROM Contact WHERE FirstName = 'John' AND LastName = 'Doe' LIMIT 1];

		Restaurant__c restaurant = [SELECT Id, Name, AverageMealCost__c, CommissionRate__c
        FROM Restaurant__c
        WHERE Name = 'Test Restaurant'
        LIMIT 1];

        Training__c training = new Training__c(
            Name = 'Test Training',
            Restaurant__c = restaurant.id,
			Start_Date__c = Date.Today(),
			End_Date__c = Date.Today().addDays(2),
            Training_Course__c = trainingCourse.id,
			Trainer_Contact__c = trainerContact.id,
            Number_of_Participants__c = 0,
            Maximum_Participant_Capacity__c = 3
        );

        Insert training;


        List<Contact> contacts = [SELECT Id, FirstName, LastName, AccountId
        FROM Contact
        WHERE LastName = 'Participant'
        LIMIT 3];

        List<Participant__c> participants = new List<Participant__c>();

        for(Contact con: contacts) {
            Participant__c participant = new Participant__c();
            participant.Contact_Name__c = con.id;
            participant.Training__c = training.id;
            participants.add(participant);
        }

        Insert participants;
        Participant__c cancelledPart = participants[0];

        Test.startTest();
        cancelledPart.Status__c = 'Cancelled';
        Test.stopTest();

        List<Participant__c> activeParticipants = [SELECT Id, Contact_Name__c, Training__c
        FROM Participant__c
        WHERE Contact_Name__c IN :contacts
        AND Training__c = :training.id AND Status__c =: TrainingService.ACTIVE_STATUS];


        System.debug('active parts ' + activeParticipants);


        Assert.areEqual(2,training.Number_of_Participants__c,'Number of Active participants should be 2');

    }
}