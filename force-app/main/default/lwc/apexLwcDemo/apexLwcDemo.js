import { api, LightningElement } from 'lwc';
import queryContactById from '@salesforce/apex/LwcApexCallDemo.queryContactById';
import queryParticipantsByContactId from '@salesforce/apex/LwcApexCallDemo.queryParticipantsByContactId';

export default class ApexLwcDemo extends LightningElement {
    @api recordId;
    contacts;
    participants;
    error;

    participantColumns = [
        { label: 'Training', fieldName: 'Training__r.Name' },
        { label: 'Status', fieldName: 'Status__c' }
    ];



    connectedCallback() {//place is made for the page, used when lwc is placed on page and use this to initialize and load data
        this.queryContact();
        this.queryParticipants();
        console.log('connectedCallback called');
    }


    queryContact(){

        queryContactById()
            .then(result => {
                this.contacts = result;
                console.log('contacts => ', this.contacts);
            })
            .catch(error => {
                this.error = error;
            });
    }

    queryParticipants(){

        queryParticipantsByContactId({recordId: this.recordId})
            .then(result => {
                this.participants = result;
                
            })
            .catch(error => {
                this.error = error;
            });
    }


}