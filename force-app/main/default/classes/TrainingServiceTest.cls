@isTest
public class TrainingServiceTest {
    @TestSetup
    static void setup() {
		RestaurantCommissionMetadata__mdt restaurantCommission =
            RestaurantCommissionMetadata__mdt.getInstance('Default_Commission');

		Account trainerAccount = new Account(Name = 'Trainer Account');
		Insert trainerAccount;

		Contact trainerContact = new Contact(FirstName = 'John',LastName = 'Doe',AccountId = trainerAccount.id);
        Insert trainerContact;

		Training_Course__c trainingCourse = new Training_Course__c(Name = 'Test Training Course');
		Insert trainingCourse;
    }

    @isTest
    static void testCommissionForecastWithZeroAverageMealCost() {
		Training_Course__c trainingCourse = 
            [SELECT Id 
            FROM Training_Course__c 
            WHERE Name = 'Test Training Course' 
            LIMIT 1];

		Contact trainerContact = [SELECT Id FROM Contact WHERE FirstName = 'John' AND LastName = 'Doe' LIMIT 1];

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
			Trainer_Contact__c = trainerContact.id
        );

        Test.startTest();
        Insert training;
        Test.stopTest();

        Training__c updatedTraining = [
            SELECT Restaurant_Commission_Forecast__c
            FROM Training__c
            WHERE Id = :training.Id];
            
        System.assertEquals(
            0, updatedTraining.Restaurant_Commission_Forecast__c,
            'Commission forecast should be zero when average meal cost is zero');
    }

    @isTest
    static void testCommissionForecastWithNonZeroAverageMealCost() {
		Training_Course__c trainingCourse = 
            [SELECT Id
            FROM Training_Course__c 
            WHERE Name = 'Test Training Course' 
            LIMIT 1];

		Contact trainerContact = [SELECT Id FROM Contact WHERE FirstName = 'John' AND LastName = 'Doe' LIMIT 1];
		
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

        Test.startTest();
        Insert training;
        Test.stopTest();

        Training__c updatedTraining = 
            [SELECT Restaurant_Commission_Forecast__c 
            FROM Training__c 
            WHERE Id = :training.Id];

        System.assertEquals(
            5, updatedTraining.Restaurant_Commission_Forecast__c,
            'Commission forecast should be 5 when training is 2 days, 5 participants, average meal cost is 25, and using Default Restaurant Commission probability of purchasing a meal');
    }

    @isTest
    static void testCommissionForecastWithNullParticipants() {
		Training_Course__c trainingCourse = 
            [SELECT Id 
            FROM Training_Course__c 
            WHERE Name = 'Test Training Course' 
            LIMIT 1];

		Contact trainerContact = [SELECT Id FROM Contact WHERE FirstName = 'John' AND LastName = 'Doe' LIMIT 1];
		
		Restaurant__c restaurant = new Restaurant__c(
            Name = 'Test Restaurant',
            AverageMealCost__c = 25,
            CommissionRate__c = 10
        );

        Insert restaurant;
		
		Training__c training = new Training__c(
            Name = 'Test Training',
            Restaurant__c = restaurant.id,
			Start_Date__c = Date.Today(),
			End_Date__c = Date.Today().addDays(2),
            Number_of_Participants__c = null,
			Training_Course__c = trainingCourse.id,
			Trainer_Contact__c = trainerContact.id
        );

        Test.startTest();
        Insert training;
        Test.stopTest();

        Training__c updatedTraining = 
            [SELECT Restaurant_Commission_Forecast__c 
            FROM Training__c 
            WHERE Id = :training.Id];
            
        System.assertNotEquals(
            0, updatedTraining.Restaurant_Commission_Forecast__c,
            'Commission forecast should not be zero when participants is null');
    }
}