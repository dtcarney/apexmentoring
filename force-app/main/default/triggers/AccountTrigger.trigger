trigger AccountTrigger on Account (Before insert, Before update,After insert, After update) {



if(Trigger.isBefore && Trigger.isInsert){

    for(Account acct: Trigger.New){
        acct.Rating = 'Warm';

        if(acct.website != null && acct.website.contains('.edu') ){
            acct.Industry = 'Education';
        }

    }
}

if(Trigger.isBefore && Trigger.isUpdate){

    for(Account acct: Trigger.New){
        if(acct.website != null && acct.website.contains('.edu') ){
            acct.Industry = 'Education';
        }

    }
}



}




