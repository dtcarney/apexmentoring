public with sharing class AccountQueable implements Queueable, Database.AllowsCallouts{
 

    public static void execute(QueueableContext qc){


        String endpoint = 'https://735ef563-176d-431c-85ce-2cc07056ef03.mock.pstmn.io/payments/link';
        HttpRequest request = new HttpRequest();
        request.setEndpoint(endpoint);
        request.setHeader('Content-Type','application-json');
        request.setMethod('GET');

        Http http = new Http();

        HttpResponse response = http.send(request);

        Map<String, Object> payload = (Map<String,Object>) JSON.deserializeUntyped(response.getBody());
        Map<String, Object> payer = (Map<String,Object>) payload.get('payer');
        String link = (String) payer.get('link');
   
        System.debug(link);


    }

}