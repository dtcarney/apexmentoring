

public with sharing class ERPparticipantQueuable implements Queueable, Database.AllowsCallouts {

    private Set<Id> participantIds;
    /*
    public ParticipantERPCallOut(Set<Id> participantIds) {
        if(participantIds == null || participantIds.isEmpty()) {
            throw new PaymentLinkCalloutException('Participant Ids cannot be null or empty');
        }
        
        this.participantIds = participantIds;
    } */

    public void execute(QueueableContext context) {
        List<Participant__c> participants = ParticipantQueries.queryParticipantContactData(participantIds);
/*
        ERPparticipantCallout erpParticipantCallout = new ERPparticipantCallout();
        
        for(Participant__c participant: participants){
            String resposneBody = erpParticipantCallout.paymentLinkCallout(participant);
            participant.erpId__c = erpParticipantCallout.parseLinkFromResposneBody(responseBody);
        }

        update participants;

        EmailService.sendPaymentLink(participants);*/
    }
}
