import {wire, LightningElement } from 'lwc';
import getCases from '@salesforce/apex/CaseController.getCases';

import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import { getPicklistValues } from 'lightning/uiObjectInfoApi';
import CASE_OBJECT from '@salesforce/schema/Case';
import PRIORITY_FIELD from '@salesforce/schema/Case.Priority';

const COLS = [
    { label: 'Case Number', fieldName: 'CaseNumber', type: 'text' },
    { label: 'Subject', fieldName: 'Subject', type: 'text' },
    { label: 'Status', fieldName: 'Status', type: 'text' },
    { label: 'Priority', fieldName: 'Priority', type: 'priorityPicklist', wrapText: true,
        typeAttributes: {
            options:{ fieldName : 'picklistOptions'},
            value: { fieldName: 'Priority' },
            placeholder: 'Choose Priority'
        }
    }
    ];

export default class CaseTableWithPicklist extends LightningElement {

    columns = COLS;
    cases = [];
    casePriority = [];
    
    @wire(getObjectInfo, { objectApiName: CASE_OBJECT })
    caseObjectMetadata;

    @wire(getPicklistValues, { recordTypeId: '$caseObjectMetadata.defaultRecordTypeId', fieldApiName: PRIORITY_FIELD })
    CasePriorityPicklist({ data, error }) {
        if(data){
            this.casePriority = data.values;
            this.fetchCases();
        }
        else if(error){
            console.log('Error in getting picklist values:', error);
        }

    }

    fetchCases() {
        getCases()
            .then((result) => {
                let options = [];
                for(var key in this.casePriority){
                    options.push({label :this.casePriority[key].label, value:this.casePriority[key].value}  );
                }
                this.cases = result.map((record) => {
                    return{
                        ...record,
                        'picklistOptions': options
                    }
                });
            this.error = undefined;
            })
            .catch((error) => {
                this.cases = undefined;
                this.error = error;
            });
        }   

}