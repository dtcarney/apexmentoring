public with sharing class studentGradingTableController {

    
    @AuraEnabled(cacheable = true)
    public static List<ParticipantWrapper> getParticipants(Id recordId) {
        List<Participant__c> participants = [
            SELECT Id, Name,Grade__c,Status__c, Training__r.Name, Passed__c, Contact_Name__r.Name, Contact_Name__r.Email, ErpId__c 
            FROM Participant__c
            WHERE Training__c = :recordId
            ORDER BY Contact_Name__r.Name
        ];
        List<ParticipantWrapper> wrappedParticipants = new List<ParticipantWrapper>();
        for (Participant__c participant: participants){
            wrappedParticipants.add(new ParticipantWrapper(participant));
            }
        System.debug('getParticipants wrappedParticipants: '+ wrappedParticipants);
        for (ParticipantWrapper wrapper: wrappedParticipants){
            System.debug('wrapper: '+ wrapper);
        }
        System.debug('participants size : ' + wrappedParticipants.size());

        return wrappedParticipants;
    }

    @AuraEnabled
    public static List<ParticipantWrapper>  updateParticipants(String serializedParticipants) {
        
        List<ParticipantWrapper> updatedParticipants = (List<ParticipantWrapper>) JSON.deserialize(serializedParticipants, List<ParticipantWrapper>.class);

        System.debug('Deserialized Participants: ' + updatedParticipants);
        List<ParticipantWrapper> participantWrapperToReturn = updatedParticipants;
        List<Participant__c> participantsToUpdate = new List<Participant__c>();

        
        Set<Id> participantIds = new Set<Id>();

        for (ParticipantWrapper wrapper : updatedParticipants) {
            Participant__c participant = new Participant__c(Id = wrapper.Id);
            participant.Grade__c = wrapper.Grade;
            participant.Passed__c = (wrapper.Passed != null) ? wrapper.Passed : false;
            participant.Status__c = wrapper.Status;
            System.debug('wrapper: '+ wrapper);
            participantsToUpdate.add(participant);
            participantIds.add(participant.Id);
        }
        update participantsToUpdate;


        List<Participant__c> participants = [
            SELECT Id, Name,Grade__c,Status__c, Training__r.Name, Passed__c, Contact_Name__r.Name, 
                   Contact_Name__r.Email, ErpId__c 
            FROM Participant__c
            WHERE Id IN:participantIds
        ];

        for(Participant__c participant: participants){
            ParticipantWrapper wrapper = new ParticipantWrapper(participant);
            participantWrapperToReturn.add(wrapper);
        }


        return participantWrapperToReturn; 

    }

    @AuraEnabled
    public static ParticipantWrapper getParticipantFromERP(Integer erpId, Id recordId){

        Map<String,String> headers = new Map<String,String>();
        headers.put('Content-Type','application/json');

        ERPCallout erpCalloutObject = new ERPCallout();

        HttpResponse response = erpCalloutObject.getRequestToErp( 
            headers,
            ERPCallout.ENDPOINT_API_BASE+ERPCallout.API_VERSION+ERPCallout.API_PARTICIPANT,
            ERPCallout.METHOD_GET,
            erpId
        );

        String bodyToParse = response.getBody();

        ParticipantWrapper wrapper = (ParticipantWrapper) JSON.deserialize(
            bodyToParse, 
            ParticipantWrapper.class
        );

        System.debug('wrapper: '+ wrapper);
        Participant__c participant = new Participant__c();
        participant.Training__c = recordId;
        participant.Contact_Name__c = wrapper.ContactId;
        participant.ErpId__c = wrapper.id;
        insert participant;

        participant = [
            SELECT Id, Name,Grade__c,Status__c, Training__r.Name, Passed__c, Contact_Name__r.Name, 
                   Contact_Name__r.Email, ErpId__c 
            FROM Participant__c
            WHERE Id = :participant.Id
        ];

        ParticipantWrapper wrapperToReturn = new ParticipantWrapper(participant);
        return wrapperToReturn;
    }

    public class ParticipantWrapper {
        @AuraEnabled 
        public String Id { get; set; }

        @AuraEnabled
        public String participantUrl { get; set; }

        @AuraEnabled 
        public Decimal Grade { get; set; }

        @AuraEnabled 
        public String TrainingName { get; set; }

        @AuraEnabled 
        public String ContactId { get; set; }

        @AuraEnabled 
        public String ContactName { get; set; }

        @AuraEnabled 
        public String ContactEmail { get; set; }

        @AuraEnabled 
        public Boolean Passed { get; set; }

        @AuraEnabled 
        public String Status { get; set; }

        @AuraEnabled 
        public String ERPId { get; set; }

        public ParticipantWrapper() {}
    
        public ParticipantWrapper(Participant__c participant) {
            this.Id = participant.Id;
            this.Grade = participant.Grade__c;
            this.participantUrl = '/' + participant.Id;
            this.TrainingName = participant?.Training__r?.Name; // != null ? participant.Training__r.Name : null;
            this.ContactName = participant.Contact_Name__r != null ? participant.Contact_Name__r.Name : null;
            System.debug('Contact Name: '+ this.ContactName);
            this.ContactId = participant.Contact_Name__c;
            this.ContactEmail = participant.Contact_Name__r.Email != null ? participant.Contact_Name__r.Email : null;
            this.Passed = participant.Passed__c;
            this.Status = participant.Status__c;
            this.ERPId = participant.ErpId__c;
        }
    }
}