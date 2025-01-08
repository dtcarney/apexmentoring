public with sharing class ErrorLogCleanUpSchedulable implements Schedulable {

    public void execute(SchedulableContext SC){
        ErrorLogCleanUpBatch batch = new ErrorLogCleanUpBatch();
        Database.executeBatch(batch);
    }

}