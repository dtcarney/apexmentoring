public with sharing class StripeWebhookRestResourceMock implements HttpCalloutMock {
    public static final String PAYMENT_LINK = 'https://www.example.com';



    public static HTTPResponse respond(HTTPRequest req) {
        StripeWebhookRestResource.InvoiceWrapper invoiceObj = new StripeWebhookRestResource.InvoiceWrapper();
        invoiceObj.id = 'in_1Q7z5SBfMVXATIYrYVQpc6an';
        invoiceObj.amount_due = 0;
        invoiceObj.amount_paid = 0;
        invoiceObj.amount_remaining = 0;
        invoiceObj.customer_email = 'dtcarney08+bobsmith@gmail.com';
        invoiceObj.customer_name = 'Bob smith';

        StripeWebhookRestResource.DataWrapper dataObj = new StripeWebhookRestResource.DataWrapper();
        dataObj.object_x = invoiceObj;

        StripeWebhookRestResource.EventWrapper eventWrapper = new StripeWebhookRestResource.EventWrapper();
        eventWrapper.id = 'in_1Q7z5SBfMVXATIYrYVQpc6Nn'; // or any other event ID
        eventWrapper.object_x = 'invoice';
        eventWrapper.data = dataObj;
        eventWrapper.type = 'invoice.created';

        String newBody = JSON.serialize(eventWrapper);

        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody(newBody);
        res.setStatusCode(200);
        return res;
    }
}