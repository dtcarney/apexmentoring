public with sharing class ParticipantService {

    public static final String ACTIVE_STATUS = 'Active';
    public static final String IN_QUEUE_STATUS = 'In Queue';
    public static final String PARTICIPATED_STATUS = 'Participated';
    public static Boolean bypassRegistrationQueueable = false;
    

    /**
    * This method has two business process - increasing the count and recalculating commision forecast
    *
    */

    public void setStatus(List<Participant__c> newList){
        
        Set<Id> trainingIds = collectRelatedTrainingIds(newList);
        List<Training__c> trainings = queryTrainingsByIds(trainingIds);
        Map<Id, Integer> trainingAvailableCapacity = getTrainingAvailableCapacity(trainings);//need to make
        List<Participant__c> participantByStatus = determineStatus(newList,trainingAvailableCapacity);//need to make

    }

    private Map<Id,Integer> getTrainingAvailableCapacity(List<Training__c> trainings){
        Map<Id, Integer> trainingToCapacity = new Map<Id, Integer>();

        for(Training__c training : trainings){
            Integer availableCapacity = Integer.valueOf(training.Maximum_Participant_Capacity__c - training.Number_of_Participants__c);
            trainingToCapacity.put(training.Id,availableCapacity);
        }
        return trainingToCapacity;
    }

    private List<Participant__c> determineStatus(List<Participant__c> newList,Map<Id, Integer> trainingAvailableCapacity){
        for(Participant__c participant : newList){
            if(trainingAvailableCapacity.get(participant.Training__c) > 0){
                participant.Status__c = ACTIVE_STATUS;
                Integer count = trainingAvailableCapacity.get(participant.Training__c);
                trainingAvailableCapacity.put(participant.Training__c, count - 1);
            } else {
                participant.Status__c = IN_QUEUE_STATUS;
            }
        }
        return newList;
    }

    //this is for inserted participants
    public void sendParticipantRegistrationEmail(List<Participant__c> newList){
        List<Participant__c> activeParticipants = filterParticipantsByStatus(newList, ACTIVE_STATUS);
        if(activeParticipants == null || activeParticipants.isEmpty()) {
            return;
        }

        Set<Id> idSet = (new Map<Id, Participant__c> (activeParticipants)).keySet();
        if(bypassRegistrationQueueable == false){
            System.enqueueJob(new RegistrationConfirmationQueueable(idSet));}

        
    }

    //this is for updated participants
    public void sendParticipantRegistrationEmail(List<Participant__c> newParticipants, Map<Id,Participant__c> oldMap){
        List<Participant__c> activeParticipants = filterParticipantsActivated(newParticipants, oldMap);

        if(activeParticipants == null || activeParticipants.isEmpty()) {
            return;
        }
        
        Set<Id> idSet = (new Map<Id, Participant__c> (activeParticipants)).keySet();
        if(bypassRegistrationQueueable == false){
            System.enqueueJob(new RegistrationConfirmationQueueable(idSet));}
    }

    public void updateParticipantCountOnTrainings(List<Participant__c> newList){
        List<Participant__c> activeParticipants = filterParticipantsByStatus(newList, ACTIVE_STATUS);
        
        System.debug('active participants ' + activeParticipants);

        if(activeParticipants.isEmpty()){
            return;
        }

        Set<Id> trainingIds = collectRelatedTrainingIds(activeParticipants);
        Map<Id, Integer> trainingUpdatedParticipantCount = createTrainigToParticipantCount(activeParticipants);

        List<Training__c> trainings = queryTrainingsByIds(trainingUpdatedParticipantCount.keySet());
        System.debug('trainings before increasing participant count '+ trainings);
        incsreaseNumberOfParticipantsByCount(trainings, trainingUpdatedParticipantCount);
        System.debug('trainings after increasing participant count '+ trainings);
    
        TrainingService trainingService = new TrainingService();
        trainingService.calculateInitialRestaurantCommissionForecast(trainings);

        update trainings;
    }

    private void incsreaseNumberOfParticipantsByCount(
        List<Training__c> trainings, 
        Map<Id, Integer> trainingUpdatedParticipantCountMap
    ){
        for(Training__c training : trainings){
            training.Number_of_Participants__c = training.Number_of_Participants__c + trainingUpdatedParticipantCountMap.get(training.Id);
        }
    }

    private void decreaseNumberOfParticipantsByCount(
        List<Training__c> trainings, 
        Map<Id, Integer> trainingUpdatedParticipantCountMap
    ) {
        System.debug('training and paricipated count map before decreasing '+ trainings +' -- ' + trainingUpdatedParticipantCountMap);
        for(Training__c training : trainings){
            training.Number_of_Participants__c = training.Number_of_Participants__c - trainingUpdatedParticipantCountMap.get(training.Id);
        }
        System.debug('training and paricipated count map after decreasing '+ trainings +' -- ' + trainingUpdatedParticipantCountMap);
    }


    private List<Training__c> queryTrainingsByIds(Set<Id> trainingIds){
        return [
            SELECT Id,Name,Start_Date__c, End_Date__c,Number_of_Participants__c,Maximum_Participant_Capacity__c,Restaurant__c, 
                   Restaurant_Commission_Forecast__c, Training_Length_Days__c 
            FROM Training__c 
            WHERE Id IN :trainingIds
        ];
    }

    private List<Participant__c> filterParticipantsByStatus(List<Participant__c> participants, String status){
        List<Participant__c> filteredParticipants = new List<Participant__c>();
    

        for(Participant__c participant : participants){
            System.debug('Participant Name '+ participant.Contact_Name__r.Name + ' Status ' + participant.Status__c);
            if(participant.Status__c == status){
                filteredParticipants.add(participant);
            }
        }
        System.debug('Filtered Participants '+ filteredParticipants);
        System.debug('Filtered participants size ' + filteredParticipants.size());

        return filteredParticipants;
    }

    private Set<Id> collectRelatedTrainingIds(List<Participant__c> participants){
        Set<Id> trainingIds = new Set<Id>();

        for(Participant__c participant : participants){
            trainingIds.add(participant.Training__c);
        }

        return trainingIds;
    }

    private Map<Id,Integer> createTrainigToParticipantCount(List<Participant__c> newList){
        Map<Id,Integer> trainingToParticipantCount = new Map<Id,Integer>();

        for(Participant__c participant : newList){
            if(trainingToParticipantCount.containsKey(participant.Training__c)){
                Integer count = trainingToParticipantCount.get(participant.Training__c);

                trainingToParticipantCount.put(participant.Training__c, count + 1);
            } else {
                trainingToParticipantCount.put(participant.Training__c,1);
            }
            
        }
        System.debug('createTrainigToParticipantCount trainingToParticipant Count map '+ trainingToParticipantCount);

        return trainingToParticipantCount;
    }

    public void updateParticipantCountOnTrainings(List<Participant__c> newParticipants, Map<Id,Participant__c> oldMap) {
        System.debug('hitting updated participants method');
        Set<Id> trainingIds = collectRelatedTrainingIds(newParticipants);
        Map<Id, Training__c> trainingMap = new Map<Id, Training__c> (queryTrainingsByIds(trainingIds));


        List<Participant__c> activatedParticipants = filterParticipantsActivated(newParticipants, oldMap);
        List<Participant__c> deactivatedParticipants = filterParticipantsDeactivated(newParticipants, oldMap);
        System.debug('activated participants: ' + activatedParticipants);
        System.debug('deactivated participants: ' + deactivatedParticipants);

        System.debug('trainingMap before doing anything ' + trainingMap);

        for(Participant__c activeParticipant : activatedParticipants){
            Training__c training = trainingMap.get(activeParticipant.Training__c);
            System.debug('adding participant: training number before adding ' + training.Number_of_Participants__c);
            training.Number_of_Participants__c = training.Number_of_Participants__c + 1;
            System.debug('adding participant: training number after adding ' + training.Number_of_Participants__c);
        }

        for(Participant__c inactiveParticipant : deactivatedParticipants){
            Training__c training = trainingMap.get(inactiveParticipant.Training__c);
            System.debug('removing participant: training number before removing ' + training.Number_of_Participants__c);
            training.Number_of_Participants__c = training.Number_of_Participants__c - 1;
            System.debug('removing participant: training number after removing ' + training.Number_of_Participants__c);
        }

        System.debug('trainingMap after doing loop ' + trainingMap);


        List<Training__c> trainings = trainingMap.values();
        System.debug('Trainings after querying using map keyset ' + trainings);

        TrainingService trainingService = new TrainingService();
        trainingService.calculateInitialRestaurantCommissionForecast(trainings);
        System.debug('trainings after update ' + trainings);
        update trainings;
        
    }

    private List<Participant__c> filterParticipantsActivated(
        List<Participant__c> newParticipants,  
        Map<Id,Participant__c> oldMap
    ) {
        List<Participant__c> filtered = new List<Participant__c>();

        for(Participant__c participant : newParticipants){
            if(participant.Status__c == ACTIVE_STATUS && oldMap.get(participant.Id).Status__c != ACTIVE_STATUS){
                filtered.add(participant);
            }
        }

        return filtered;
    }

    private List<Participant__c> filterParticipantsDeactivated(
        List<Participant__c> newParticipants,  
        Map<Id,Participant__c> oldMap
    ) {
        List<Participant__c> filtered = new List<Participant__c>();

        for(Participant__c participant : newParticipants){
            if(participant.Status__c != ACTIVE_STATUS && participant.Status__c!= PARTICIPATED_STATUS && oldMap.get(participant.Id).Status__c == ACTIVE_STATUS){
                filtered.add(participant);
            }
        }

        return filtered;
    }


    public void deleteParticipantCountOnTrainings(List<Participant__c> oldList){
        List<Participant__c> activeParticipants = filterParticipantsByStatus(oldList, ACTIVE_STATUS);
        System.debug('delete participants activeParticipants '+ activeParticipants);
        if(activeParticipants.isEmpty()){
            return;
        }

        Set<Id> trainingIds = collectRelatedTrainingIds(activeParticipants);
        Map<Id, Integer> trainingUpdatedParticipantCount = createTrainigToParticipantCount(oldList);

        List<Training__c> trainings = queryTrainingsByIds(trainingUpdatedParticipantCount.keySet());
        System.debug('trainings before decreassing ' + trainings);
        decreaseNumberOfParticipantsByCount(trainings, trainingUpdatedParticipantCount);
        System.debug('trainings after decreassing ' + trainings);
        TrainingService trainingService = new TrainingService();
        trainingService.calculateInitialRestaurantCommissionForecast(trainings);

        update trainings;
    }

    public void sendQueuedRegistrantEmail(List<Participant__c> participants){
        List<Participant__c> queuedParticipants =  filterParticipantsByStatus(participants,IN_QUEUE_STATUS);
        Set<Id> participantIds = new Set<Id>();
        for (Participant__c participant: queuedParticipants){
            participantIds.add(participant.Id);
        }
        List<Participant__c> queuedParticipantsWithAllData = ParticipantQueries.queryParticipantsByIds(participantIds);
        Map<Participant__c,Integer> participantQueuePosition = determineParticipantQueuePosition(queuedParticipantswithAllData);
        EmailService.sendQueuedParticipantEmail(participantQueuePosition);
    }


    private Map<Participant__c,Integer> determineParticipantQueuePosition(List<Participant__c> queuedParticipants){
        Map<Participant__c,Integer> participantQueuePosition = new Map<Participant__c,Integer>();
        Set<Id> trainingIds = collectRelatedTrainingIds(queuedParticipants);
        List<Training__c> trainings = queryTrainingsByIds(trainingIds);

        for (Training__c training: trainings){
            Map<Participant__c,Integer> participantLocationInTraining = determineParticipantLocationIndividualTraning(queuedParticipants, training);
            for (Participant__c participant: queuedParticipants){
        
                participantQueuePosition.put(participant, participantLocationInTraining.get(participant));
            }
        }

        return participantQueuePosition;
    }

    private Map<Participant__c,Integer> determineParticipantLocationIndividualTraning(
        List<Participant__c> queuedParticipantsinTraining, 
        Training__c training
    ){
        Map<Participant__c,Integer> participantQueuePositionIndividiualTraining = new Map<Participant__c,Integer>();

        List<Participant__c> queuedParticipantsinIndividualTraining = ParticipantQueries.queryParticipantsByIdAndStatus(
            training.Id, 
            IN_QUEUE_STATUS
        );

        for(Participant__c participant : queuedParticipantsinIndividualTraining){
            Integer participantPosition = queuedParticipantsinIndividualTraining.indexOf(participant) + 1;
            participantQueuePositionIndividiualTraining.put(participant,participantPosition);
        }

        return participantQueuePositionIndividiualTraining;
    }

    public void SendEmail(Map<Participant__c,Integer> participantQueuePosition){

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

}

