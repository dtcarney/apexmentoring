public with sharing class ParticipantERPSyncScheduled implements Schedulable {

    public void execute(SchedulableContext SC){
        ParticipantERPSyncBatch batch = new ParticipantERPSyncBatch();
        Database.executeBatch(batch,200);
    }
}