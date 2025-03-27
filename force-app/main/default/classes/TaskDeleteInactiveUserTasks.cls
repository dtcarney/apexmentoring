public with sharing class TaskDeleteInactiveUserTasks implements Schedulable {
    public TaskDeleteInactiveUserTasks() {

    }

    public void execute(SchedulableContext SC ){

        List<Task> tasks = [SELECT Id, OwnerId FROM Task WHERE Status = 'Open' AND Owner.isActive = false];
        delete tasks;


    }



}