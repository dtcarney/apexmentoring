public with sharing class ERPparticipantCallout {

    public class ERPparticipantCalloutException extends Exception {}

    @InvocableMethod
    public static void getERPid(List<Id> participantIds){
        Id participantId = participantIds.get(0);

        System.debug('participantId: '+ participantId);

        Participant__c participant = [
            SELECT Id, Contact_Name__r.Email,Contact_Name__r.Name, Training__r.Name, Status__c, ErpId__c
            FROM Participant__c 
            WHERE Id =: participantId
        ];

        System.debug('participant record: ' +participant);

        ParticipantERPWrapper participantWrapper = new ParticipantERPWrapper();
        participantWrapper = participantWrapper.generateParticipantWrapper(participant);
        System.debug('participant wrapper in main class getERPid: '+ participantWrapper);

        String body = JSON.serialize(participantWrapper);
        Map<String,String> headers = new Map<String,String>();
        headers.put('Content-Type','application/json');
        System.debug('headers: '+ headers);

        System.debug('payload body ' +body);
        ERPCallout erpCalloutObject = new ERPCallout();


        HttpResponse response = erpCalloutObject.postRequestToErp(
            body, 
            headers,
            ERPCallout.ENDPOINT_API_BASE+ERPCallout.API_VERSION+ERPCallout.API_PARTICIPANT,
            ERPCallout.METHOD_POST
        );
        
        if(response.getStatusCode() >= 400){
            throw new ERPparticipantCalloutException(response.toString());
        }
        String erpId = parseERPidFromResponseBody(response.getBody());
        
        participant.ErpId__c = erpId;

        update participant;
    }

    public static Participant__c createParticipantinERP(Participant__c participant){

        System.debug('participant record: ' +participant);

        ParticipantERPWrapper participantWrapper = new ParticipantERPWrapper();
        participantWrapper = participantWrapper.generateParticipantWrapper(participant);
        System.debug('participant wrapper in main class createParticipantinERP: '+ participantWrapper);

        String body = JSON.serialize(participantWrapper);
        Map<String,String> headers = new Map<String,String>();
        headers.put('Content-Type','application/json');
        System.debug('headers: '+ headers);

        System.debug('payload body ' +body);
        ERPCallout erpCalloutObject = new ERPCallout();

        HttpResponse response = erpCalloutObject.postRequestToErp(
            body, 
            headers,
            ERPCallout.ENDPOINT_API_BASE+ERPCallout.API_VERSION+ERPCallout.API_PARTICIPANT,
            ERPCallout.METHOD_POST
        );
        System.debug(response);
        System.debug(response.getBody());

        if(response.getStatusCode() >= 400){
            throw new ERPparticipantCalloutException(response.toString());
        }
        String erpId = parseERPidFromResponseBody(response.getBody());
        
        participant.ErpId__c = erpId;

        return participant;
    }


    public static void syncParticipantWithERP(Participant__c participant){

        ParticipantERPWrapper participantWrapper = new ParticipantERPWrapper();
        participantWrapper = participantWrapper.generateParticipantWrapper(participant);
        System.debug('participant wrapper in main class syncParticipantWithERP: '+ participantWrapper);

        String body = JSON.serialize(participantWrapper);
        Map<String,String> headers = new Map<String,String>();
        headers.put('Content-Type','application/json');
        System.debug('headers: '+ headers);
        String id = participant.ErpId__c;
        System.debug('erp id set in participant: '+ id);

        System.debug('payload body ' +body);
        ERPCallout erpCalloutObject = new ERPCallout();

        HttpResponse response = erpCalloutObject.putRequestToErp(
            body, 
            headers,
            ERPCallout.ENDPOINT_API_BASE+ERPCallout.API_VERSION+ERPCallout.API_PARTICIPANT,
            ERPCallout.METHOD_PUT,
            id
        );
        System.debug(response);
        System.debug(response.getBody());

        if(response.getStatusCode() >= 400){
            throw new ERPparticipantCalloutException(response.toString());
        }

    }
    
    @AuraEnabled
    public static void getParticipantFromERP(Integer erpId){

        Map<String,String> headers = new Map<String,String>();
        headers.put('Content-Type','application/json');
        System.debug('headers: '+ headers);
        Integer id = erpId;
        System.debug('erp id set in participant: '+ id);

        ERPCallout erpCalloutObject = new ERPCallout();

        HttpResponse response = erpCalloutObject.getRequestToErp( 
            headers,
            ERPCallout.ENDPOINT_API_BASE+ERPCallout.API_VERSION+ERPCallout.API_PARTICIPANT,
            ERPCallout.METHOD_GET,
            id
        );

        if(response.getStatusCode() >= 400){
            throw new ERPparticipantCalloutException(response.toString());
        }
        System.debug(response);
        System.debug(response.getBody());

        String bodyToParse = response.getBody();

        ParticipantERPWrapper wrapper = (ParticipantERPWrapper) JSON.deserialize(bodyToParse, ParticipantERPWrapper.class);
        Participant__c participant = new Participant__c();
        participant.Training__c = wrapper.TrainingId;
        participant.Contact_Name__c = wrapper.ContactId;
        participant.ErpId__c = wrapper.id;

        insert participant;
        System.debug('participant inserted: '+ participant);
    }



    private static String parseERPidFromResponseBody(String bodyToParse){
        ParticipantERPPayload payload = (ParticipantERPPayload) JSON.deserialize(bodyToParse, ParticipantERPPayload.class);
        return payload.id;
    }

    public class ParticipantERPPayload {
        public String id;
    }

    public class ParticipantERPWrapper {
        //public String SalesforceId;
        public String Status;
        public String TrainingName;
        public String Email;
        public String Name;
        public String ContactId;
        public String TrainingId;
        public String id;

        public ParticipantERPWrapper generateParticipantWrapper(Participant__c participant){
            ParticipantERPWrapper participantWrapper = new ERPparticipantCallout.ParticipantERPWrapper();
            participantWrapper.Name = participant.Contact_Name__r.Name;
            participantWrapper.Email = participant.Contact_Name__r.Email;
            participantWrapper.Status = participant.Status__c;
            //participantWrapper.SalesforceId = participant.Id;
            participantWrapper.TrainingName = participant.Training__r.Name;
            participantWrapper.TrainingId = participant.Training__c;
            participantWrapper.ContactId = participant.Contact_Name__c;
            System.debug('participantWrapper in ERPCallOutClass: '+ participantWrapper);

            return participantWrapper;
        }
    }

}