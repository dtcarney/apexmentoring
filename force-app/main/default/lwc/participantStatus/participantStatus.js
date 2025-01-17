import { LightningElement, api, wire, track } from 'lwc';

export default class ParticipantStatus extends LightningElement {
    @api value; // Current value of the picklist field for the record
    @api recordId; // Record ID for the row in the datatable
    @api options = []; // Array to store picklist options

    renderedCallback() {
        console.log('ParticipantStatus component rendered');
        console.log('options: ' + JSON.stringify(this.options));
        console.log('options: ', this.options);
    }
}
