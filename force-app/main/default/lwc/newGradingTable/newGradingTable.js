import { LightningElement, track, api, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

import getParticipants from '@salesforce/apex/StudentGradingTableController.getParticipants';
//import fetchParticipants from '@salesforce/apex/StudentGradingTableController.fetchParticipants';
import updateParticipants from '@salesforce/apex/studentGradingTableController.updateParticipants';

import { getObjectInfo, getPicklistValues } from 'lightning/uiObjectInfoApi';
import { updateRecord } from 'lightning/uiRecordApi';
import { refreshApex } from '@salesforce/apex';

import PARTICIPANT_OBJECT from '@salesforce/schema/Participant__c';
import STATUS_FIELD from '@salesforce/schema/Participant__c.Status__c';

export default class newGradingTable extends LightningElement {
    @track participants = [];
    @track draftValues = [];
    @track participantStatuses = [];
    @track participantData;
    lastSavedData = [];

    @api recordId;
    @api showSearch;
    @api isLoaded = false;
    error;
    errorMessage;
    CUSTOM_SUCCESS_TITLE_LABEL = 'Success!';
    CUSTOM_SUCCESS_MESSAGE_LABEL = 'Your changes have been saved.';
    CUSTOM_SUCCESS_VARIANT_LABEL = 'success';
    CUSTOM_ERROR_TITLE_LABEL = 'Error!';

    @wire(getObjectInfo, { objectApiName: PARTICIPANT_OBJECT })
    participantObjectMetadata;

    @wire(getPicklistValues, { recordTypeId: '012000000000000AAA', fieldApiName: STATUS_FIELD })
    wirePicklist({ data, error }) {
        if (data) {
            this.participantStatuses = data.values;
            // this.loadParticipants();
            console.log('getPicklistValues ran: ', this.participantStatuses);
        }
        else if (error) {
            console.log('getPicklistValues error: ' + JSON.stringify(error));
        }
    }

    columns = [
        {
            label: 'Name',
            fieldName: 'participantUrl',
            type: 'url',
            editable: false,
            displayReadOnlyIcon: true,
            typeAttributes: {
                label: { fieldName: 'ContactName' },
                target: '_self'
            }
        },
        { label: 'Email', fieldName: 'ContactEmail', editable: false, type: 'email' },
        {
            label: 'Status', fieldName: 'Status', editable: true, type: 'statusPicklist', wrapText: true,
            typeAttributes: {
                options: { fieldName: 'participantStatuses' },
                value: { fieldName: 'participantStatus' },
                placeholder: 'Select a Status...',
                context: { fieldName: 'Id' }
            }
        },
        { label: 'GPA', fieldName: 'Grade', editable: true, type: 'number' },
        { label: 'Passed', fieldName: 'Passed', editable: true, type: 'boolean' },
        {
            type: "button", label: 'Delete', cellAttributes: { alignment: 'center' }, typeAttributes: {
                name: 'delete',
                title: 'Delete',
                disabled: false,
                value: 'delete',
                iconPosition: 'left',
                iconName: 'utility:delete',
                label: 'Delete',
                variant: 'destructive'
            }
        }
    ];

    connectedCallback() {
        // this.loadParticipants();
    }

    loadParticipants() {
        getParticipants({ trainingId: this.recordId })
            .then(result => {
                this.participantData = result;
                this.lastSavedData = JSON.parse(JSON.stringify(this.participantData));
                this.error = undefined;
            })
            .catch(error => {
                this.error = error;
                this.participantData = undefined;
            });
    }

    @wire(getParticipants, { trainingId: '$recordId', pickList: '$participantStatuses' })
    participantData(result) {
        this.participantData = result;
        console.log('getParticipants success', this.participantData);
        if (result.data) {
            console.log('result.data ', JSON.stringify(result.data));
            this.participants = JSON.parse(JSON.stringify(result.data));
            console.log('participants ' + this.participants);

            this.participants.forEach(ele => {
                ele.participantStatuses = this.participantStatuses;
            })

            this.lastSavedData = JSON.parse(JSON.stringify(this.participants));

        } else if (result.error) {
            console.error('Error in getParticipants:', result.error);
            this.participants = undefined;
        }
    }

    updateDraftValues(updateItem) {
        let draftValueChanged = false;
        let copyDraftValues = [...this.draftValues];
        copyDraftValues.forEach(item => {
            if (item.Id === updateItem.Id) {
                for (let field in updateItem) {
                    item[field] = updateItem[field];
                }
                draftValueChanged = true;
            }
        });

        if (draftValueChanged) {
            this.draftValues = [...copyDraftValues];
        } else {
            this.draftValues = [...copyDraftValues, updateItem];
        }
    }

    handleCellChange(event) {
        let draftValues = event.detail.draftValues;
        draftValues.forEach(element => {
            this.updateDraftValues(element);
        });
    }

    handleOptionSelect(event) {
        const selectedValue = event.currentTarget.dataset.value;
        this.selectedList = selectedValue;
        this.toggleDropdown();
    }

    async handleInlineEditSave(event) {
        const draftValues = event.detail.draftValues;
        if (draftValues.length === 0) {
            return;
        }
        const records = draftValues.map(draftValue => ({
            fields: {
                ...draftValue
            }
        }));
        this.draftValues = [];
        try {
            const recordUpdatePromises = records.map((record) =>
                updateRecord(record)
            );
            await Promise.all(recordUpdatePromises);
            const title = CUSTOM_SUCCESS_TITLE_LABEL;
            const message = CUSTOM_SUCCESS_MESSAGE_LABEL;
            const variant = CUSTOM_SUCCESS_VARIANT_LABEL;
            this.createAndDispatchToast(title, message, variant);
            refreshApex(this.participantData);
        } catch (error) {
            console.log('error updating records: ' + error);
            this.createAndDispatchToast(this.customErrorTitle,
                this.customErrorMessage, this.customErrorVariant);
        }
    }


    /** Code from old table */
    handleSave(event) {
        console.log('event', event);
        console.log('event detail: ', event.detail);
        console.log('event detail draft values: ', event.detail.draftValues);
        this.copyDraftToParticipants(event.detail.draftValues);
        this.saveParticipants();
        this.draftValues = [];

        console.log('(handleSave) this.participants: ', JSON.stringify(this.participants));
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

                    if (draftElement.Status !== null) {
                        participantElement.Status = draftElement.Status;
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
            })
            .catch(error => {
                this.error = JSON.stringify(error);
                // this.errorMessage = error.body.message;
                this.showToast('Error', 'An error occurred while trying to save the changes.', 'error');
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
}