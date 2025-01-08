@isTest
public with sharing class TrainingRestServiceTest {

    @isTest
    public static void getTrainingSuccess(){

		Training_Course__c trainingCourse = new Training_Course__c(Name = 'Test Training Course');
		Insert trainingCourse;

        Account trainerAccount = new Account(Name = 'Trainer Account');
		Insert trainerAccount;

		Contact trainerContact = new Contact(FirstName = 'John',LastName = 'Doe',AccountId = trainerAccount.id);
        Insert trainerContact;
		
		Restaurant__c restaurant = new Restaurant__c(
            Name = 'Test Restaurant',
            AverageMealCost__c = 25,
            CommissionRate__c = 10
        );

        Insert restaurant;

        Training__c training = new Training__c(
            Name = 'Test Training',
            Restaurant__c = restaurant.Id,
			Start_Date__c = Date.Today(),
			End_Date__c = Date.Today().addDays(2),
            Number_of_Participants__c = 5,
			Training_Course__c = trainingCourse.id,
			Trainer_Contact__c = trainerContact.id
        );

        insert training;
        String trainingId = training.Id;

        RestRequest req = new RestRequest();
        req.addParameter('salesforceId', trainingId);
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/Trainings';
        req.httpMethod = 'GET';

        RestContext.request = req;
        RestContext.response= res;

        Test.startTest();
        TrainingRestService.getTraining();
        Test.stopTest();
        System.debug(res);
        Assert.areEqual(200, res.statusCode,'Response should be 200');


    }

    @isTest
    public static void getTrainingErrorTrainingNotFound(){

		Training_Course__c trainingCourse = new Training_Course__c(Name = 'Test Training Course');
		Insert trainingCourse;

        Account trainerAccount = new Account(Name = 'Trainer Account');
		Insert trainerAccount;

		Contact trainerContact = new Contact(FirstName = 'John',LastName = 'Doe',AccountId = trainerAccount.id);
        Insert trainerContact;
		
		Restaurant__c restaurant = new Restaurant__c(
            Name = 'Test Restaurant',
            AverageMealCost__c = 25,
            CommissionRate__c = 10
        );

        Insert restaurant;

        Training__c training = new Training__c(
            Name = 'Test Training',
            Restaurant__c = restaurant.Id,
			Start_Date__c = Date.Today(),
			End_Date__c = Date.Today().addDays(2),
            Number_of_Participants__c = 5,
			Training_Course__c = trainingCourse.id,
			Trainer_Contact__c = trainerContact.id
        );

        insert training;
        Training__c insertedTraining = [SELECT Id FROM Training__c LIMIT 1];
        String trainingId = insertedTraining.Id;
        delete training;

        RestRequest req = new RestRequest();
        req.addParameter('salesforceId', trainingId);
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/Trainings';
        req.httpMethod = 'GET';

        RestContext.request = req;
        RestContext.response= res;

        Test.startTest();
        TrainingRestService.getTraining();
        Test.stopTest();
        System.debug(res);
        Assert.areEqual(500, res.statusCode,'Response should be 500');

    }

    @isTest
    public static void getTrainingErrorMissingSalesforceId(){

        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/Trainings';
        req.httpMethod = 'GET';

        RestContext.request = req;
        RestContext.response= res;

        Test.startTest();
        TrainingRestService.getTraining();
        Test.stopTest();
        System.debug(res);
        Assert.areEqual(400, res.statusCode,'Response should be 400');
    }

    @isTest
    public static void insertTrainings(){

		Training_Course__c trainingCourse = new Training_Course__c(Name = 'Test Training Course');
		Insert trainingCourse;

        Account trainerAccount = new Account(Name = 'Trainer Account');
		Insert trainerAccount;

		Contact trainerContact = new Contact(FirstName = 'John',LastName = 'Doe',AccountId = trainerAccount.id);
        Insert trainerContact;
		
		Restaurant__c restaurant = new Restaurant__c(
            Name = 'Test Restaurant',
            AverageMealCost__c = 25,
            CommissionRate__c = 10
        );

        Insert restaurant;

        DateTime startDateTime = DateTime.now();
        String startDate = startDateTime.format('yyyy-MM-dd HH:mm:ss');
        DateTime endDateTime = DateTime.now();
        String endDate = startDateTime.format('yyyy-MM-dd HH:mm:ss');


        RestRequest req = new RestRequest();
        req.addParameter('trainingName', 'TestTraining');
        req.addParameter('trainerId', trainerContact.Id);
        req.addParameter('courseId', trainingCourse.Id);
        req.addParameter('restaurantId', restaurant.Id);
        req.addParameter('startDate', startDate);
        req.addParameter('endDate', endDate);

        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/Trainings';
        req.httpMethod = 'POST';

        System.debug('Request: '+ req);
        RestContext.request = req;
        RestContext.response= res;

        Test.startTest();
        TrainingRestService.insertTraining();
        Test.stopTest();
        System.debug(res);
        Training__c insertedTraining = [SELECT Name, Start_Date__c, End_Date__c, Trainer_Contact__c, Restaurant__c, Training_Course__c FROM Training__c LIMIT 1];
        System.Assert.areEqual(Date.today(), insertedTraining.Start_Date__c);


    }








}