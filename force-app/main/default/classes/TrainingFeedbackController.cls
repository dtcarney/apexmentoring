public with sharing class TrainingFeedbackController {
    
    public Feedback__c feedback {get; set;}
    
    public TrainingFeedbackController() {
        Id trainingId = ApexPages.currentPage().getParameters().get('id');
        feedback = new Feedback__c();
        feedback.Training__c = trainingId;
        feedback.Rating__c = 10;
    }
    
    public PageReference save() {
        insert feedback;
        return new PageReference('/'+feedback.Id);
    }

}