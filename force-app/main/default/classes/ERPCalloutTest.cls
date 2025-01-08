@isTest
public with sharing class ERPCalloutTest {
    @isTest
    public static void postSuccessRequestToErpTest() {

        String bodyToSend = 'success';
        Map<String,String> headers = new Map<String,String>();
        headers.put('Content-Type','application/json');
        String endPoint = 'https://endpoint.test.url/v1/participants';
        String method = 'POST';

        Test.setMock(HttpCalloutMock.class, new MockERPResponseGenerator());
        Test.startTest();
        ERPCallout erpCallout = new ERPCallout();
        HttpResponse response = erpCallout.postRequestToErp(bodyToSend, headers, endPoint, method);
        Test.stopTest();
        Assert.areEqual(response.getStatusCode(), 200);
        Assert.areEqual(response.getBody(), MockERPResponseGenerator.generateBodyString());
    }

    @isTest
    public static void postFailureRequestToErpTest() {

        String bodyToSend = 'failure';
        Map<String,String> headers = new Map<String,String>();
        headers.put('Content-Type','application/json');
        String endPoint = 'https://endpoint.test.url/v1/participants';
        String method = 'POST';

        Test.setMock(HttpCalloutMock.class, new MockERPResponseGenerator());
        Test.startTest();
        ERPCallout erpCallout = new ERPCallout();
        HttpResponse response = erpCallout.postRequestToErp(bodyToSend, headers, endPoint, method);
        Test.stopTest();
        Assert.areEqual(response.getStatusCode(), 400);
        Assert.areEqual(response.getBody(), MockERPResponseGenerator.generateBodyString());
    }


    @isTest
    public static void putSuccessRequestToErpTest() {

        String bodyToSend = 'success';
        Map<String,String> headers = new Map<String,String>();
        headers.put('Content-Type','application/json');
        String endPoint = 'https://endpoint.test.url/v1/participants';
        String id = '1';
        String method = 'POST';

        Test.setMock(HttpCalloutMock.class, new MockERPResponseGenerator());
        Test.startTest();
        ERPCallout erpCallout = new ERPCallout();
        HttpResponse response = erpCallout.putRequestToErp(bodyToSend, headers, endPoint, method, id);
        Test.stopTest();
        Assert.areEqual(response.getStatusCode(), 200);
        Assert.areEqual(response.getBody(), MockERPResponseGenerator.generateBodyString());
    }

    @isTest
    public static void putFailureRequestToErpTest() {

        String bodyToSend = 'failure';
        Map<String,String> headers = new Map<String,String>();
        headers.put('Content-Type','application/json');
        String endPoint = 'https://endpoint.test.url/v1/participants';
        String id = '1';
        String method = 'PUT';

        Test.setMock(HttpCalloutMock.class, new MockERPResponseGenerator());
        Test.startTest();
        ERPCallout erpCallout = new ERPCallout();
        HttpResponse response = erpCallout.putRequestToErp(bodyToSend, headers, endPoint, method, id);
        Test.stopTest();
        Assert.areEqual(response.getStatusCode(), 400);
        Assert.areEqual(response.getBody(), MockERPResponseGenerator.generateBodyString());
    }









}