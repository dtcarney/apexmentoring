@RestResource(UrlMapping='/Trainings/*')
global with sharing class TrainingRestService {

    @HttpGet
    global static void getTraining() {
        RestResponse res = RestContext.response;
        RestRequest req = RestContext.request;
        System.debug('get request: '+ req);
        Map<String, String> parameters = req.params;
        Id salesforceId = parameters.get('salesforceId');

        if(salesforceId == null){
            res.statusCode = 400;
            res.responseBody = Blob.valueOf('{"error": "salesforceId parameter is missing"}');
            return;
        } 

        Training__c training = [SELECT Id, Training_Length_Days__c, Status__c, Trainer_Contact__r.Name,
                                            Start_Date__c, End_Date__c, Number_of_Participants__c
                                            FROM Training__c
                                            WHERE Id = :salesforceId];
        res.responseBody = Blob.valueOf(JSON.serialize(training));
        res.statusCode = 200;
    }

    @HttpPost
    global static void insertTraining() {
        RestResponse res = RestContext.response;
        try {
            RestRequest req = RestContext.request;
            System.debug('insert request: '+ req);
            Map<String, String> parameters = req.params;

            String trainingName = parameters.get('trainingName');
            Date startDate = Date.valueOf(parameters.get('startDate'));
            Date endDate = Date.valueOf(parameters.get('endDate'));
            Id trainerId = parameters.get('trainerId');
            Id restaurantId = parameters.get('restaurantId');
            Id courseId = parameters.get('courseId');

            Training__c newTraining = new Training__c(
                Name = trainingName,
                Start_Date__c = startDate,
                End_Date__c = endDate,
                Trainer_Contact__c = trainerId,
                Restaurant__c = restaurantId,
                Training_Course__c = courseId
            );
            
            insert newTraining;
            res.responseBody = Blob.valueOf(JSON.serialize(newTraining));
            res.statusCode = 201; // Created
        } catch (Exception e) {
            res.statusCode = 500; // Internal Server Error
            res.responseBody = Blob.valueOf('{"error": "' + e.getMessage() + '"}');
        }
    }
}
