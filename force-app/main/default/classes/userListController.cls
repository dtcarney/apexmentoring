public with sharing class userListController {

    @AuraEnabled
    public static List<User> getActiveUsers() {
        return [SELECT Id, Name, Username, Title, Phone, Department FROM User WHERE IsActive = true];
    }
    
}