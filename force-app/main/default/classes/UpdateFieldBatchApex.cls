public with sharing class UpdateFieldBatchApex implements Database.Batchable<sObject> {
    public final String Query;
    public final String Entity;
    public final String Field;
    public final String Value;
    
    public UpdateFieldBatchApex(String query, String entity, String field, String value) {
        System.debug('query: ' + query);
        System.debug('entity: ' + entity);
        System.debug('field: ' + field);
        System.debug('value: ' + value);
        
        this.Query = query;
        this.Entity = entity;
        this.Field = field;
        this.Value = value;

        System.debug('Query: ' + Query);
        System.debug('Entity: ' + Entity);
        System.debug('Field: ' + Field);
        System.debug('Value: ' + Value);

    }

    public Database.QueryLocator start(Database.BatchableContext BC) {
        System.debug('Query in start: ' + Query);
        return Database.getQueryLocator(Query);
    }

    public void execute(Database.BatchableContext BC, List<sObject> scope) {
        for(SObject s : scope){ 
            if(s.get(Field) != Value){
                s.put(Field, Value);
            }
        }
        update scope;
    }

    public void finish(Database.BatchableContext BC) {
    }
}