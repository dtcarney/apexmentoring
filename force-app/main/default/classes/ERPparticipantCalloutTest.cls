@isTest
public with sharing class ERPparticipantCalloutTest {
    @isTest
    public static void getERPidTest() {

        Restaurant__c restaurant = new Restaurant__c(
            Name = 'Test Restaurant',
            AverageMealCost__c = 0,
            CommissionRate__c = 10
        );
        Insert restaurant;

        Training_Course__c trainingCourse = new Training_Course__c(Name = 'Test Training Course');

		Insert trainingCourse;

        Contact trainerContact = new Contact(
            FirstName = 'John',
            LastName = 'Doe', 
            Email ='jdoe@test.net');
        Insert trainerContact;

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

        Contact con = new Contact(FirstName = 'success', LastName = 'Carney', Email = 'dtcarney08@gmail.com');

        insert con;

        Participant__c participant = new Participant__c(Training__c = training.id, Contact_Name__c = con.id);

        Insert participant;

        List<Id> participantIds = new List<ID>();
        participantIds.add(participant.id);


        Test.setMock(HttpCalloutMock.class, new MockERPResponseGenerator());
        RegistrationConfirmationQueueable.bypassPaymentLinkCallout = TRUE;
        Test.startTest();
        ERPparticipantCallout.getERPid(participantIds);
        Test.stopTest();

        Participant__c updatedParticipant = [SELECT Id, erpId__c FROM Participant__c WHERE Id =: participant.id LIMIT 1];
        System.debug('updatedParticipant: '+ updatedParticipant);
        Assert.areEqual('9174', updatedParticipant.erpId__c);

    }

    @isTest
    public static void createParticipantinERPTest() {

        Restaurant__c restaurant = new Restaurant__c(
            Name = 'Test Restaurant',
            AverageMealCost__c = 0,
            CommissionRate__c = 10
        );
        Insert restaurant;

        Training_Course__c trainingCourse = new Training_Course__c(Name = 'Test Training Course');

		Insert trainingCourse;

        Contact trainerContact = new Contact(
            FirstName = 'John',
            LastName = 'Doe', 
            Email ='jdoe@test.net');
        Insert trainerContact;

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

        Contact con = new Contact(FirstName = 'success', LastName = 'Carney', Email = 'dtcarney08@gmail.com');

        insert con;

        Participant__c participant = new Participant__c(Training__c = training.id, Contact_Name__c = con.id);

        Insert participant;
        participant = [
            SELECT Id, Contact_Name__r.Email,Contact_Name__r.Name, Training__r.Name, Status__c, ErpId__c
            FROM Participant__c 
            WHERE Id =: participant.Id
        ];


        Test.setMock(HttpCalloutMock.class, new MockERPResponseGenerator());
        RegistrationConfirmationQueueable.bypassPaymentLinkCallout = TRUE;
        Test.startTest();
        participant = ERPparticipantCallout.createParticipantinERP(participant);
        System.debug('participant debug after callout: ' + participant);
        update participant;
        Test.stopTest();

        Participant__c updatedParticipant = [SELECT Id, erpId__c FROM Participant__c WHERE Id =: participant.id LIMIT 1];
        System.debug('updatedParticipant: '+ updatedParticipant);
        Assert.areEqual('9174', updatedParticipant.erpId__c);

    }

    @isTest
    public static void syncParticipantWithERPTest() {

        Restaurant__c restaurant = new Restaurant__c(
            Name = 'Test Restaurant',
            AverageMealCost__c = 0,
            CommissionRate__c = 10
        );
        Insert restaurant;

        Training_Course__c trainingCourse = new Training_Course__c(Name = 'Test Training Course');

		Insert trainingCourse;

        Contact trainerContact = new Contact(
            FirstName = 'John',
            LastName = 'Doe', 
            Email ='jdoe@test.net');
        Insert trainerContact;

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

        Contact con = new Contact(FirstName = 'success', LastName = 'Carney', Email = 'dtcarney08@gmail.com');

        insert con;

        Participant__c participant = new Participant__c(Training__c = training.id, Contact_Name__c = con.id, ErpId__c = '1');

        Insert participant;
        participant = [
            SELECT Id, Contact_Name__r.Email,Contact_Name__r.Name, Training__r.Name, Status__c, ErpId__c
            FROM Participant__c 
            WHERE Id =: participant.Id
        ];


        Test.setMock(HttpCalloutMock.class, new MockERPResponseGenerator());
        RegistrationConfirmationQueueable.bypassPaymentLinkCallout = TRUE;
        Test.startTest();
        ERPparticipantCallout.syncParticipantWithERP(participant);
        System.debug('participant debug after callout: ' + participant);
        Test.stopTest();

    }



}