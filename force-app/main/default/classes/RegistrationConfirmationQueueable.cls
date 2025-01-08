public with sharing class RegistrationConfirmationQueueable implements Queueable {

    public static Boolean bypassPaymentLinkCallout= false;

    public class RegistrationConfirmationQueueableException extends Exception {}
    
    private Set<Id> participantIds;

    public RegistrationConfirmationQueueable(Set<Id> participantIds) {
        if(participantIds == null || participantIds.isEmpty()) {
            throw new RegistrationConfirmationQueueableException('Participant Ids cannot be null or empty');
        }
        
        this.participantIds = participantIds;
    }

    public void execute(QueueableContext context) {
        List<Participant__c> participants = ParticipantQueries.queryParticipantsByIds(participantIds);
        
        if(!bypassPaymentLinkCallout){
            System.enqueueJob(new PaymentLinkQueueable(participantIds));}

        EmailService.sendRegistrationConfirmationEmail(participants);

    }
    
}