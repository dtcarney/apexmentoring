public with sharing class ERPCallout {
    //public static final String ENDPOINT_API_BASE = 'https://66d9b2844ad2f6b8ed55b0bb.mockapi.io/api';
    public static final String ENDPOINT_API_BASE = 'callout:ERPParticipant';
    public static final String METHOD_POST = 'POST';
    public static final String METHOD_PUT = 'PUT';
    public static final String METHOD_GET = 'GET';
    public static final String API_VERSION = '/v1';
    public static final String API_PARTICIPANT = '/participants';

    public HttpResponse postRequestToErp(
        String bodyToSend, 
        Map<String, String> headers,
        String endPoint, 
        String method
    ) {
        HttpRequest request = new HttpRequest();
        request.setEndpoint(endPoint);
        request.setMethod(method);
        for(String key : headers.keySet()){
            request.setHeader(key, headers.get(key));
        }
        request.setBody(bodyToSend);
        System.debug('Endpoint: ' + endPoint);
        System.debug('Method: ' + method);
        System.debug('Headers: ' + headers);
        System.debug('Body: ' + bodyToSend);

        Http http = new Http();

        HttpResponse response = http.send(request);

        return response;
    }

    public HttpResponse putRequestToErp(
        String bodyToSend, 
        Map<String, String> headers,
        String endPoint, 
        String method,
        String id
    ) {
        HttpRequest request = new HttpRequest();
        request.setEndpoint(endPoint + '/' + id);
        System.debug('ERP used in endpoint: ' + id);
        request.setMethod(method);
        for(String key : headers.keySet()){
            request.setHeader(key, headers.get(key));
        }
        request.setBody(bodyToSend);
        System.debug('Endpoint: ' + endPoint);
        System.debug('Method: ' + method);
        System.debug('Headers: ' + headers);
        System.debug('Body: ' + bodyToSend);

        Http http = new Http();

        HttpResponse response = http.send(request);

        return response;
    }


    public HttpResponse getRequestToErp(
        Map<String, String> headers,
        String endPoint, 
        String method,
        Integer id
    ) {
        HttpRequest request = new HttpRequest();
        request.setEndpoint(endPoint + '/' +  String.valueOf(id));
        System.debug('ERP used in endpoint: ' + id);
        request.setMethod(method);
        for(String key : headers.keySet()){
            request.setHeader(key, headers.get(key));
        }
        System.debug('Endpoint: ' + endPoint);
        System.debug('Method: ' + method);
        System.debug('Headers: ' + headers);

        Http http = new Http();

        HttpResponse response = http.send(request);

        return response;
    }


}