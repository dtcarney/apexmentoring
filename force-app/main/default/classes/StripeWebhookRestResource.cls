@RestResource(urlMapping='/stripe/webhook/*')
global without sharing class StripeWebhookRestResource {

    @HttpPost
    global static void handlePost() {
            RestRequest req = RestContext.request;
            String requestBodyString = req.requestBody.toString().replace('object', 'object_x');
            System.debug('request body: '+ requestBodyString);
            EventWrapper eventWrapper = (EventWrapper)JSON.deserialize(requestBodyString, EventWrapper.class);
            System.debug('eventWrapper'+ eventWrapper);
            System.debug('eventWrapperType: '+ eventWrapper.type);

            DataWrapper dataWrapper = eventWrapper.data;
            System.debug('dataWrapper: '+ dataWrapper);
            InvoiceWrapper invoiceWrapper = eventWrapper.data.object_x;
            System.debug('invoiceWrapper'+ invoiceWrapper);

            
            
            if(eventWrapper.type == 'invoice.deleted'){
                System.debug('wants to delete here is ID: '+ invoiceWrapper.id);
                deleteInvoice(invoiceWrapper.id);
                return;
            }
            System.debug('after delete invoice');

            Invoice__c inv = new Invoice__c();
            inv.External_Id__c = invoiceWrapper.id;
            inv.Amount_Due__c = invoiceWrapper.amount_due;
            inv.Amount_Paid__c = invoiceWrapper.amount_paid;
            inv.Amount_Remaining__c = invoiceWrapper.amount_remaining;
            inv.Customer_Email__c = invoiceWrapper.customer_email;
            inv.Customer_Name__c = invoiceWrapper.customer_name;
            upsert inv External_Id__c;
    } 

    private static void deleteInvoice(String externalId) {
        System.debug('hitting deleteInvoice externalId: ' + externalId);
        Invoice__c inv = [SELECT Id, External_Id__c FROM Invoice__c WHERE External_Id__c =: externalId];
        System.debug('Invoice found: '+ inv);
        delete inv;
    }

    /*@HttpDelete
    global static void handleDelete() {
            System.debug('hitting delete method');
            RestRequest req = RestContext.request;
            String requestBodyString = req.requestBody.toString().replace('object', 'object_x');
            System.debug('request body: '+ requestBodyString);
            EventWrapper eventWrapper = (EventWrapper)JSON.deserialize(requestBodyString, EventWrapper.class);
            System.debug('eventWrapper'+ eventWrapper);
            DataWrapper dataWrapper = eventWrapper.data;
            System.debug('dataWrapper: '+ dataWrapper);
            InvoiceWrapper invoiceWrapper = eventWrapper.data.object_x;
            System.debug('invoiceWrapper: '+ invoiceWrapper);

            Invoice__c invoiceToDelete = [SELECT Id, External_Id__c
                                          FROM Invoice__c
                                          WHERE External_Id__c =: invoiceWrapper.id ];
                                            
            delete invoiceToDelete;

  
    }*/


public class EventWrapper {
        public String id;
        public String object_x;
        public DataWrapper data;
        public String type;
    }

public class DataWrapper {
        public InvoiceWrapper object_x;
    }

public class InvoiceWrapper{
    public String id;
    public Integer amount_due;
    public Integer amount_paid;
    public Integer amount_remaining;
    public String customer_email;
    public String customer_name;
}

}