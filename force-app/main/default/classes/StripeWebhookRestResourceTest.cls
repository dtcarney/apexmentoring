@isTest
public with sharing class StripeWebhookRestResourceTest {
    @isTest
    public static void createInvoice() {

            String newBody = '{"data": {"object": {"id": "in_1Q7z5SBfMVXATIYrYVQpc6Nn", "object": "invoice", "amount_due": 0, "amount_paid": 0, "amount_remaining": 0, "customer_email": "dtcarney08+bobsmith@gmail.com", "customer_name": "Bob smith"}}, "type": "invoice.created"}';
            RestRequest req = new RestRequest();
            RestResponse res = new RestResponse();
            req.requestBody = Blob.valueOf(newBody);
            req.httpMethod = 'POST';
            RestContext.request = req;
            RestContext.response = res;
    


        Test.setMock(HttpCalloutMock.class, new StripeWebhookRestResourceMock());

        Test.startTest();

        StripeWebhookRestResource.handlePost();

        Test.stopTest();
        Invoice__c inv = [SELECT Id, External_Id__c FROM Invoice__c WHERE External_Id__c = :'in_1Q7z5SBfMVXATIYrYVQpc6Nn'];
        Assert.areEqual('in_1Q7z5SBfMVXATIYrYVQpc6Nn',inv.External_Id__c);

    }

    @isTest
    public static void deleteInvoice() {

    
        Invoice__c invoice = new Invoice__c();
        invoice.External_Id__c = 'in_1Q7z5SBfMVXATIYrYVQpc6Nn';
        insert invoice;

        String newBody = '{"data": {"object": {"id": "in_1Q7z5SBfMVXATIYrYVQpc6Nn", "object": "invoice", "amount_due": 0, "amount_paid": 0, "amount_remaining": 0, "customer_email": "dtcarney08+bobsmith@gmail.com", "customer_name": "Bob smith"}}, "type": "invoice.deleted"}';
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestBody = Blob.valueOf(newBody);
        req.httpMethod = 'POST';
        RestContext.request = req;
        RestContext.response = res;


        Test.setMock(HttpCalloutMock.class, new StripeWebhookRestResourceMock());

        Test.startTest();

        StripeWebhookRestResource.handlePost();

        Test.stopTest();
        List<Invoice__c> invoices = [SELECT Id from Invoice__c];
        Assert.areEqual(0, invoices.size());

    }






}