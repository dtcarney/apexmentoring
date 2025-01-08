public with sharing class EmailService {


    public static void notifyTrainerAboutTrainingStart(List<Training__c> trainings){
        List<Messaging.SingleEmailMessage> mailList =  new List<Messaging.SingleEmailMessage>();

        for (Training__c training: trainings){
            List<Participant__c> participants = TrainingReminderScheduled.participantsInTraining(training);
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            mail.setTargetObjectId(training.Trainer_Contact__c);
            mail.setSubject('Training starts in 3 days');
            String body = 'Dear '+ training.Trainer_Contact__r.FirstName +',\n \n';    
            body+='This is an automatic reminder for the upcoming training '+training.Name+' will take place from '
            +training.Start_Date__c+' to ' + training.End_Date__c + '. \n \n';
            body+= 'There are in total '+ training.Number_of_Participants__c + ' number of participants: \n';
            for(Participant__c participant: participants){
                body+='- '+participant.Contact_Name__r.Name+'\n';
            }
            body+='\n Thanks, \n';
            body+='Cloud Prism';
            mail.setPlainTextBody(body);
            mailList.add(mail);
        }
        Messaging.sendEmail(mailList);
    }


    public static void notifyParticipantsAboutTrainingStart(List<Participant__c> activeParticipants){
        List<Messaging.SingleEmailMessage> mailList =  new List<Messaging.SingleEmailMessage>();
        EmailTemplate participantReminderTemplate = [
            SELECT Id
            FROM EmailTemplate
            WHERE DeveloperName = 'Participant_Reminder_Email_1721695403134'
            LIMIT 1
        ];
        
        if(participantReminderTemplate == null){
            throw new EmailServiceException('Participant Reminder Email Template not found.');
        }

        for (Participant__c participant: activeParticipants){
            
            Messaging.SingleEmailMessage mail = Messaging.renderStoredEmailTemplate(participantReminderTemplate.Id,participant.Contact_Name__c,participant.Training__c);
            mailList.add(mail);
        }
        Messaging.sendEmail(mailList);
    }

    public static void sendRegistrationConfirmationEmail(List<Participant__c> participants){
        EmailTemplate registrationEmailTemplate = [
            SELECT Id FROM EmailTemplate WHERE DeveloperName = 'Participant_Registration_Email_1721819003419'
        ];

        if(registrationEmailTemplate == null){
            throw new EmailServiceException('Participant Registration Email Template not found.');
        }
    
        List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();

        for(Participant__c participant : participants){
            Messaging.SingleEmailMessage email = Messaging.renderStoredEmailTemplate(registrationEmailTemplate.Id,participant.Contact_Name__c,participant.Training__c);
            emails.add(email);
        }
        Messaging.sendEmail(emails);
    }

    public static void sendQueuedParticipantEmail(Map<Participant__c,Integer> participantQueuePosition){

        List<Messaging.SingleEmailMessage> mailList =  new List<Messaging.SingleEmailMessage>();

        for(Participant__c participant : participantQueuePosition.keySet()){

            Messaging.SingleEmailMessage newMail = new Messaging.SingleEmailMessage();
            List<String> sendToAddressesList = new List<String>();
            System.debug('contact email '+ participant.Contact_Name__r.Email);
            sendToAddressesList.add(participant.Contact_Name__r.Email);
            newMail.setToAddresses(sendToAddressesList);
            newMail.setSubject('Your have registered for training: '+ participant.Training__r.Name);
            String body = 'Hello ' + participant.Contact_Name__r.Name + ',<br> <br> ';
            body += 'You have been added to the queue for the training: '+ participant.Training__r.Name + '<br><br>';
            body += 'Your position in the queue is: '+ participantQueuePosition.get(participant) + '<br><br>';
            body+= 'Thank you!, <br>';
            body+= 'CloudPrism';
            newMail.setHtmlBody(body);
            mailList.add(newMail);
        }
        Messaging.sendEmail(mailList);

    }


    
    public static void sendPaymentLink(List<Participant__c> participants){

        List<Messaging.SingleEmailMessage> mailList =  new List<Messaging.SingleEmailMessage>();

        for(Participant__c participant : participants){

            Messaging.SingleEmailMessage newMail = new Messaging.SingleEmailMessage();
            List<String> sendToAddressesList = new List<String>();
            System.debug('contact email '+ participant.Contact_Name__r.Email);
            sendToAddressesList.add(participant.Contact_Name__r.Email);
            newMail.setToAddresses(sendToAddressesList);
            newMail.setSubject('Registration Payment Link for : '+ participant.Training__r.Name);
            String body = 'Hello ' + participant.Contact_Name__r.Name + ',<br> <br> ';
            body += 'Thank you for signing up for the training: '+ participant.Training__r.Name + '<br><br>';
            body += 'To complete your registration, please make a payment by clicking the link below: '+ '<br><br>';
            body +=  participant.PaymentLink__c + '<br><br>';
            body+= 'Thank you!, <br>';
            body+= 'CloudPrism';
            newMail.setHtmlBody(body);
            mailList.add(newMail);
        }
        Messaging.sendEmail(mailList);

    }

    public class EmailServiceException extends Exception {


    }
    
}