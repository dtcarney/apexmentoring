import { LightningElement, api, wire, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getParticipants from '@salesforce/apex/studentGradingTableController.getParticipants';
import updateParticipants from '@salesforce/apex/studentGradingTableController.updateParticipants';
import getParticipantFromERP from '@salesforce/apex/studentGradingTableController.getParticipantFromERP';
import { deleteRecord } from 'lightning/uiRecordApi';
import { getPicklistValues } from 'lightning/uiObjectInfoApi';
import STATUS_FIELD from '@salesforce/schema/Participant__c.Status__c';

export default class StudentGradingTable extends LightningElement {
    columns = [
        {
            label: 'Participant',
            fieldName: 'participantUrl',
            type: 'url',
            typeAttributes: {
                label: { fieldName: 'ContactName' },
                target: '_self'
            },
        },
        { label: 'Student Email', fieldName: 'ContactEmail' },
        { label: 'ERPId', fieldName: 'ERPId' },
        { label: 'Training Course', fieldName: 'TrainingName' },
        {
            label: 'Status',
            fieldName: 'Status', // Use the exact API name here
            editable: true,
            type: 'customPicklist', // Custom type for picklist created in ParticipantStatus
            typeAttributes: {
                placeholder: 'Choose status',
                value: { fieldName: 'Status' },
                recordId: { fieldName: 'Id' },
                options: { fieldName: 'options' }
            }
        },
        { label: 'Grade', fieldName: 'Grade', type: 'number', editable: true },
        { label: 'Passed', fieldName: 'Passed', editable: true, type: 'boolean' },
        {
            type: "button", label: 'Delete', initialWidth: 110, typeAttributes: {
                label: 'Delete',
                name: 'Delete',
                title: 'Delete',
                disabled: false,
                value: 'delete',
                iconPosition: 'left',
                iconName: 'utility:delete',
                variant: 'destructive'
            }
        }

    ];

    participants = [];
    draftValues = [];
    hasError = false;
    errorMessage = ''
    erpLoaded = false;
    isConnected = false;

    @api recordId;
    @api enableSearch;
    @track wireResult;
    @track options = [];

    @wire(getPicklistValues, { recordTypeId: "012aj000003y03U", fieldApiName: STATUS_FIELD })
    wiredPicklistValues({ error, data }) {
        console.log('hitting wire method for picklist values');

        if (data) {
            this.options = data.values; // Extract the picklist options
            this.erpLoaded = true;

            console.log('Participants with options:', JSON.stringify(this.participants));
        }
        // If an error occurred, log it
        else if (error) {
            console.error('Error fetching picklist values:', JSON.stringify(error));
        }
    }


    handleStatusChange(event) {
        const { value, recordId } = event.detail;
        const index = this.participants.findIndex(part => part.Id === recordId);
        if (index !== -1) {
            this.participants[index].status = value;
            // Save or process the change as necessary
        }
    }

    loadParticipants() {
        console.log('load participants called');
        getParticipants({ recordId: this.recordId })
            .then(result => {
                this.participants = result;
                console.log('Participants:', this.participants);
                this.errorMessage = '';
                this.hasError = false;

                for(let participant of this.participants) {
                    participant.options = this.options;
                    console.log('Participant:', participant);
                }
            })
            .catch(error => {
                this.error = error;
                this.errorMessage = 'Failed to load participants. Please try again later.';
                this.hasError = true;
                console.log(this.errorMessage);
            });
    }


    connectedCallback() {
        console.log('give me something');
        this.isConnected = true;
        this.loadParticipants();
        this.enableSearch = true;
        console.log('recordId:', this.recordId);
        console.log('Participants:', this.participants);
        this.dispatchEvent(new CustomEvent('recordIdSet', {
            detail: { trainingId: this.recordId },
            bubbles: true,
            composed: true
        }));
    }
    handleSave(event) {
        console.log('event', event);
        console.log('event detail: ', event.detail);
        console.log('event detail draft values: ', event.detail.draftValues);
        this.copyDraftToParticipants(event.detail.draftValues);
        this.saveParticipants();
        this.draftValues = [];
    }
    copyDraftToParticipants(draftValues) {
        draftValues.forEach((draftElement) => {
            this.participants.forEach((participantElement) => {
                if (draftElement.Id === participantElement.Id) {
                    if (draftElement.Grade) {
                        participantElement.Grade = draftElement.Grade;
                    }
                    console.log('draft passed: ', draftElement.Passed);
                    if (draftElement.Passed !== null) {
                        participantElement.Passed = draftElement.Passed;
                    }
                }
            });
        });
    }
    saveParticipants() {
        updateParticipants({ serializedParticipants: JSON.stringify(this.participants) })

            .then(result => {
                JSON.stringify(result);
                this.showToast('Success', 'Your changes are saved.', 'success');
                this.errorMessage = '';
                this.hasError = false;
            })
            .catch(error => {
                this.error = JSON.stringify(error);
                this.errorMessage = error.body.message;
                this.hasError = true;
                this.showToast('Error', 'An error occurred while trying to save the changes.', 'error');
            });
    }


    handleImportParticipant(event) {
        const erpId = event.detail.erpId;
        this.importParticipant(erpId);
    }

    importParticipant(erpId) {
        getParticipantFromERP({ erpId: erpId, recordId: this.recordId })
            .then(result => {
                this.showToast('Success', 'Participant imported', 'success');
                this.participants = [...this.participants, result];
            })
            .catch(error => {
                this.showToast('Error', 'Error getting participant', 'error');
                console.error('Error importing participant:', error);
            });
    }





    showToast(title, message, variant) {
        this.dispatchEvent(
            new ShowToastEvent({
                title: title,
                message: message,
                variant: variant,
            })
        );
    }

    addNewlyCreatedParticipant(event) {
        this.loadParticipants

    }

    callRowAction(event) {
        const recId = event.detail.row.Id;
        const actionName = event.detail.action.name;
        console.log('Action' + actionName);
        console.log('Record ID' + recId);
        if (actionName === 'Edit') {
            this.handleAction(recId, 'edit');
        } else if (actionName === 'Delete') {
            this.handleDeleteRow(recId);
        } else if (actionName === 'View') {
            this.handleAction(recId, 'view');
        }
    }
    handleDeleteRow(recordIdToDelete) {
        console.log('Deleting record' + recordIdToDelete);
        deleteRecord(recordIdToDelete)
            .then(result => {
                this.showToast('Success!!', 'Record deleted successfully!!', 'success', 'dismissable');
                this.loadParticipants();
            }).catch(error => {
                this.error = error;
            });
    }


}