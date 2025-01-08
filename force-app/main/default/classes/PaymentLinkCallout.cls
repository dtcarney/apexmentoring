public with sharing class PaymentLinkCallout {

    public class PaymentLinkCalloutException extends Exception {}

    public static final String ENDPOINT = 'https://735ef563-176d-431c-85ce-2cc07056ef03.mock.pstmn.io/payments/link';

    public String makeGetCalloutToPaymentSystem(Participant__c participant){
        HttpRequest request = new HttpRequest();
        request.setEndpoint(ENDPOINT);
        request.setHeader('Content-Type', 'application/json');
        request.setMethod('GET');

        Http http = new Http();
        HttpResponse response = http.send(request);

        if(response.getStatusCode() >= 400){
            throw new PaymentLinkCalloutException('Error: ' + response.getStatus());
        }

        String link = parseLinkFromResponseBody(response.getBody());
        return link;
    }

    public String parseLinkFromResponseBody(String bodyToParse){
        PaymentLinkPayload payload = (PaymentLinkPayload) JSON.deserialize(bodyToParse, PaymentLinkPayload.class);
        return payload.payer.link;
    }

    public class PaymentLinkPayload {
        public Payer payer;
    }

    public class Payer {
        public String link;
    }
}
