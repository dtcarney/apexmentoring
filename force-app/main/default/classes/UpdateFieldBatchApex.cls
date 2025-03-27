public with sharing class UpdateFieldBatchApex implements Database.Batchable<sObject> {
    public final String Query;
    public final String Entity;
    public final String Field;
    public final String Value;
    
    public UpdateFieldBatchApex(String query, String entity, String field, String value) {
        this.Query = query;
        this.Entity = entity;
        this.Field = field;
        this.Value = value;
    }

    public Database.QueryLocator start(Database.BatchableContext BC) {
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