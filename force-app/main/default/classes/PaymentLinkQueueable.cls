public with sharing class PaymentLinkQueueable implements Queueable, Database.AllowsCallouts {

    private Set<Id> participantIds;
    
    public PaymentLinkQueueable(Set<Id> participantIds) {
        if(participantIds == null || participantIds.isEmpty()) {
            throw new PaymentLinkCallout.PaymentLinkCalloutException('Participant Ids cannot be null or empty');
        }
        
        this.participantIds = participantIds;
    }

    public void execute(QueueableContext context) {
        List<Participant__c> participants = ParticipantQueries.queryParticipantsByIds(participantIds);

        PaymentLinkCallout paymentLinkCallout = new PaymentLinkCallout();

        for(Participant__c participant: participants){

            String responseBody = '';
            try {
                responseBody = paymentLinkCallout.makeGetCalloutToPaymentSystem(participant);
            } catch (LimitException e) {
                ErrorLogWrapper.logError(e, true);
            } catch (Exception e) {
                ErrorLogWrapper.logError(e, false);
            }
             
            participant.PaymentLink__c = paymentLinkCallout.parseLinkFromResponseBody(responseBody);
        }

        update participants;

        EmailService.sendPaymentLink(participants);
    }
}