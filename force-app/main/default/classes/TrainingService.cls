public with sharing class TrainingService {
    public static final String ACTIVE_STATUS = 'Active';
    public static final String IN_QUEUE_STATUS = 'In Queue';

    public void calculateInitialRestaurantCommissionForecast(List<Training__c> newTrainingList) {
        RestaurantCommissionMetadata__mdt restaurantCommission =  RestaurantCommissionMetadata__mdt.getInstance('Default_Commission');

        Set<Id> restaurantIds = new Set<Id>();

        for (Training__c training : newTrainingList) {
            restaurantIds.add(training.Restaurant__c);
        }

        Map<Id, Restaurant__c> restaurantMap = new Map<Id, Restaurant__c>();

        List <Restaurant__c> restaurantList = 
            [SELECT Id, AverageMealCost__c, CommissionRate__c 
            FROM Restaurant__c 
            WHERE Id IN :restaurantIds];

        for (Restaurant__c restaurant : restaurantList){
            restaurantMap.put(restaurant.Id, restaurant);
        }
        
        for (Training__c training : newTrainingList){
            Integer participants;

            If (training.Number_of_Participants__c == null || training.Number_of_Participants__c == 0){
                participants = 1;
            } else {
                participants = Integer.valueOf(training.Number_of_Participants__c);
            }

            training.Restaurant_Commission_Forecast__c = 
                participants * 
                training.Training_Length_Days__c * 
                (restaurantMap.get(training.Restaurant__c).CommissionRate__c /100)  * 
                (restaurantCommission.ProbabilityToBuyPerParticipant__c/100) *
                restaurantMap.get(training.Restaurant__c).AverageMealCost__c;
        }
    }

    public void updateParticipantCount(Map<Id,Integer> trainingUpdatedParticipantCountMap){
        List<Training__c> trainings = [
            SELECT Id,Name,Start_Date__c, End_Date__c,Number_of_Participants__c,Restaurant__c, 
                   Restaurant_Commission_Forecast__c, Training_Length_Days__c 
            FROM Training__c 
            WHERE Id in:trainingUpdatedParticipantCountMap.keySet()
        ];
        
        for(Training__c training : trainings){
            training.Number_of_Participants__c = training.Number_of_Participants__c + trainingUpdatedParticipantCountMap.get(training.Id);
        }
    
        calculateInitialRestaurantCommissionForecast(trainings);

        update trainings;
    }


    public void expandedTrainingCapacity (List<Training__c> newList, Map<Id,Training__c> oldMap){
        Map<Id,Integer> trainingAdditionalSeatsAvailable = getNewCapacitySeatsAvailable(newList, oldMap);
        setParticipantActive(trainingAdditionalSeatsAvailable);
         
    }

    public void registrationsDecreases(List<Training__c> newList, Map<Id,Training__c> oldMap){
        Map<Id,Integer> trainingAdditionalSeatsAvailable = getAdditionalSeatsAvailable(newList, oldMap);
        System.debug('registrationDecreases additional seats available '+ trainingAdditionalSeatsAvailable);
        setParticipantActive(trainingAdditionalSeatsAvailable);
    }

    private Map<Id,Integer> getAdditionalSeatsAvailable (List<Training__c> newList,Map<Id,Training__c> oldMap ){
        Map<Id,Integer> trainingAdditionalSeatsAvailable = new Map<Id,Integer>();
        for(Training__c training: newList){
            Integer seatsOpenedUp;
            if(training.Number_of_Participants__c < oldMap.get(training.Id).Number_of_Participants__c){
                seatsOpenedUp = Integer.valueOf(oldMap.get(training.Id).Number_of_Participants__c - training.Number_of_Participants__c);
                trainingAdditionalSeatsAvailable.put(training.Id, seatsOpenedUp);
            }

        }
        return trainingAdditionalSeatsAvailable;
    }

    private Map<Id,Integer> getNewCapacitySeatsAvailable(List<Training__c> newList,Map<Id,Training__c> oldMap ){
        Map<Id,Integer> capacityDifferenceMap = new Map<Id,Integer>();
        for(Training__c training: newList){
            Integer newCapacityDifference;
            if(training.Maximum_Participant_Capacity__c > oldMap.get(training.Id).Maximum_Participant_Capacity__c){
                newCapacityDifference = Integer.valueOf(training.Maximum_Participant_Capacity__c - oldMap.get(training.Id).Maximum_Participant_Capacity__c);
                capacityDifferenceMap.put(training.Id, newCapacityDifference);
            }

        }
        return capacityDifferenceMap;
    }

    private void setParticipantActive(Map<Id,Integer> expandedCapacityMap){
        Set<Id> trainingIds = expandedCapacityMap.keySet();
        List<Participant__c> participants = getQueuedParticipants(trainingIds);
        List<Participant__c> participantsChangedStatus = determineParticipantstoActivate(participants,expandedCapacityMap);
        //List<Participant__c> participantsToActivate = setParticipantActive(participantsChangedStatus);
        update participantsChangedStatus;
    }
     

    private List<Participant__c> getQueuedParticipants(Set<Id> trainingIds){
        List<Participant__c> participants = [
            SELECT Id, Training__c, Status__c, CreatedDate
            FROM Participant__c
            WHERE Training__c =:trainingIds AND Status__c =: IN_QUEUE_STATUS Order By CreatedDate
        ];
        return participants;
    }

    private List<Participant__c> determineParticipantstoActivate(
        List<Participant__c> participants, 
        Map<Id,Integer> expandedCapacityMap
    ){
        //there may not be any participants to activate for a training
        //for participants in list, put trainings into set of Ids
        Set<Id> trainingsWithQueuedParticipants = collectRelatedTrainingIds(participants);

        List<Participant__c> participantsToActivate = new List<Participant__c>();

        // Query map: trainingId -> List of queue participants

        List<Training__c> trainings = [
            SELECT Id, Name, (
                                SELECT Id, Training__c, Status__c, CreatedDate 
                                FROM Participants__r 
                                WHERE Status__c = 'In Queue' 
                                ORDER BY CreatedDate
                            )
            FROM Training__c
            WHERE Id IN :trainingsWithQueuedParticipants
        ];

        //Dan come back and revisit this section
        Map<Id,List<Participant__c>> trainingIdToQueueParts = new Map<Id,List<Participant__c>>();
        List<Participant__c> participantsToUpdate = new List<Participant__c>();
        for(Training__c training : trainings){
            List<Participant__c> queuedParticipantsinTraining = training.Participants__r;
            Integer maxParticipantsToAdd = expandedCapacityMap.get(trainingId);

            if(queuedParticipantsinTraining.size() <= maxParticipantsToAdd){
                for(Participant__c participant : queuedParticipantsinTraining){
                    Participant__c participantToActivate = new Participant__c(
                        Id = participant.Id, 
                        Status__c = 'Active'
                    );
                    participantsToActivate.add(participantToActivate);
                }
            } if (queuedParticipantsinTraining.size() > maxParticipantsToAdd){
                Integer participantsAdded = 0;
                
                for(Participant__c participant : queuedParticipantsinTraining){
                    if(participantsAdded == maxParticipantsToAdd){
                        break;
                    }

                    Participant__c participantToActivate = new Participant__c(
                        Id = participant.Id, 
                        Status__c = 'Active'
                    );
                    participantsToActivate.add(participantToActivate);
                    participantsAdded++;
                }
            }
        }

        // Participant__c p1 = new Participant__c(Id = 'a91ndoiomd', Status__c = 'Active');
        // update p1;
        
        for(Id trainingId : trainingsWithQueuedParticipants){
            Integer maxParticipantsToAdd = expandedCapacityMap.get(trainingId);
            // List<Participant__c> queuedParticipantsinTraining = getQueuedParticipants(new Set<Id>{trainingId}); 

            List<Participant__c> queuedParticipantsinTraining = trainingIdToQueueParts.get(trainingId);
            
            if(queuedParticipantsinTraining.size() <= maxParticipantsToAdd){
                participantsToActivate.addAll(queuedParticipantsinTraining);
            } if (queuedParticipantsinTraining.size() > maxParticipantsToAdd){
                Integer participantsAdded = 0;
                for(Participant__c participant : queuedParticipantsinTraining){
                    if(participantsAdded < maxParticipantsToAdd){
                        participantsToActivate.add(participant);
                        participantsAdded++;

                    }
                }
            }

        }
        return participantsToActivate;
    }



    private Set<Id> collectRelatedTrainingIds(List<Participant__c> participants){
        Set<Id> trainingIds = new Set<Id>();

        for(Participant__c participant : participants){
            trainingIds.add(participant.Training__c);
        }

        return trainingIds;
    }

    private List<Participant__c> setParticipantActive(List<Participant__c> participantsToActivate){
        for(Participant__c participant : participantsToActivate){
            participant.Status__c = ACTIVE_STATUS;
        }
        return participantsToActivate;

    }

    }