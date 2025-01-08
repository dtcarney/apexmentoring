public with sharing class LWCInlineCtrl {
    @AuraEnabled(Cacheable = true)
    public static List<Contact> getContacts() {
        return [SELECT Id, Name, FirstName, LastName, Phone, Email,GenderIdentity ,DoNotCall
                FROM Contact 
                WHERE Email != null
                AND Phone != null
                ORDER BY CreatedDate limit 5];
    }
}