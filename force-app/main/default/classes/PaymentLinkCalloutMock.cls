public class PaymentLinkCalloutMock implements HttpCalloutMock {
    public static final String PAYMENT_LINK = 'https://www.example.com';

    public static HTTPResponse respond(HTTPRequest req) {
        //StaticResource sr = [SELECT Id, Body FROM StaticResource WHERE Name = 'testAPIresponse' LIMIT 1];
        // String body = sr.Body.toString();
        String newBody = '{payer: { "paymentLink": "' + PAYMENT_LINK + '" }}';

        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody(newBody);
        res.setStatusCode(200);
        return res;
    }
}