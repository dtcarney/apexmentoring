import { LightningElement, api, wire, track } from 'lwc';

export default class ParticipantStatus extends LightningElement {
    @api value; // Current value of the picklist field for the record
    @api recordId; // Record ID for the row in the datatable
    @api options = []; // Array to store picklist options

    connectedCallback() {
        console.log('ParticipantStatus component connected');
        // Temporary static options to confirm combobox renders correctly
        console.log('here are options');
        console.log(this.options);

    }
    renderedCallback() {
        console.log('ParticipantStatus component rendered');

    }

    handleClick(event) {
        console.log('ParticipantStatus component handle click. Options: ', JSON.stringify(this.options));
        console.log('Option size: ', this.options.length);
    
        }

    // Event handler for combobox change
    handleChange(event) {
        console.log('ParticipantStatus component handle change');
        const selectedValue = event.target.value;
        console.log("Dispatching picklistchange event with:", selectedValue, this.recordId);

        // Dispatch an event with the selected picklist value and record ID
        this.dispatchEvent(
            new CustomEvent('statuschange', {
                detail: { value: selectedValue, recordId: this.recordId }
            })
        );
    }
}
