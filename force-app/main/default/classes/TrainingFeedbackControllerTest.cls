@isTest
public with sharing class TrainingFeedbackControllerTest {
    @isTest
    public static void testSave(){

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

        Test.setCurrentPage(Page.trainingfeedback);
        ApexPages.currentPage().getParameters().put('id', training.id);
        
        Test.startTest();
        TrainingFeedbackController controller = new TrainingFeedbackController();
        Test.stopTest();
        Assert.areEqual(training.Id, controller.feedback.Training__c);

    }

    @isTest
    public static void testFeedback(){

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
        
        Test.setCurrentPage(Page.trainingfeedback);
        ApexPages.currentPage().getParameters().put('id', training.id);
        
        
        TrainingFeedbackController controller = new TrainingFeedbackController();

        Test.startTest();
        controller.save();
        Test.stopTest();
        List<Feedback__c> feedbacks = [SELECT Id, Training__c FROM Feedback__c];
        Assert.areEqual(1, feedbacks.size());
        Assert.areEqual(training.Id, feedbacks[0].Training__c);

    }

}    