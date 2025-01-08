@isTest
public with sharing class PaymentLinkCalloutTest {
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
                AccountId = account.Id
            );
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

		Restaurant__c restaurant = new Restaurant__c(
            Name = 'Test Restaurant',
            AverageMealCost__c = 0,
            CommissionRate__c = 10
        );

        Insert restaurant;
		
        Training_Course__c trainingCourse = new Training_Course__c(Name = 'Test Training Course');
		Insert trainingCourse;
    }

    @isTest
    static void PaymentLinkCalloutTest() {
        
        
		Training_Course__c trainingCourse = [SELECT Id,Name 
        FROM Training_Course__c
        WHERE Name = 'Test Training Course'
        LIMIT 1];


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
        
        Test.setMock(HttpCalloutMock.class, new PaymentLinkCalloutMock());
        Test.startTest();
        insert participants;
        Test.stopTest();

        List<Participant__c> updatedParticipants = [
            SELECT Id, Name, PaymentLink__c
            FROM Participant__c
            WHERE Id in: participants
        ];

        Integer countForHavinglink = 0;
        Integer countForNotHavingLink = 0;
        for(Participant__c part: updatedParticipants) {
            if(part.PaymentLink__c != null) {
                countForHavinglink++;

                Assert.areEqual(PaymentLinkCalloutMock.PAYMENT_LINK, part.PaymentLink__c);
            } else {
                countForNotHavingLink++;
            }
        }

        Assert.areEqual(2, countForHavinglink);
        Assert.areEqual(1, countForNotHavingLink);
    }

    @isTest
    static void PaymentLinkCalloutTestNoParticipants() {
        

    }
}