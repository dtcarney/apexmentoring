
@istest
public class MockERPResponseGenerator implements HttpCalloutMock {
    public static final String DEFAULT_ID = '9174';

    public HTTPResponse respond(HTTPRequest req) {
        System.debug('method: '+ req.getMethod());
        System.debug('body: ' + req.getBody());
        
        if(req.getMethod() == 'POST'){
            if(req.getBody().contains('success')){
                return postSuccessResponse(req);
            } else {
                return postFailureResponse(req);
            }}
        else if ( req.getMethod() == 'PUT'){
            if(req.getBody().contains('success')){
                return putSuccessResponse(req);
            } else {
                return putFailureResponse(req);
            }
        }
            else return new HttpResponse();
        
        }


    private HttpResponse postSuccessResponse(HTTPRequest req) {
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        String responseBody = generateBodyString();
        res.setBody(responseBody);
        res.setStatusCode(200);
        return res;
    }

    private HttpResponse postFailureResponse(HTTPRequest req) {
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        String responseBody = generateBodyString();
        res.setBody(responseBody);
        res.setStatusCode(400);
        return res;
    }

    private HttpResponse putSuccessResponse(HTTPRequest req) {
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        String responseBody = generateBodyString();
        res.setBody(responseBody);
        res.setStatusCode(200);
        return res;
    }
    private HttpResponse putFailureResponse(HTTPRequest req) {
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        String responseBody = generateBodyString();
        res.setBody(responseBody);
        res.setStatusCode(400);
        return res;
    }




    public static String generateBodyString() {
        return '{"id":"' + DEFAULT_ID + '"}';
    }
}