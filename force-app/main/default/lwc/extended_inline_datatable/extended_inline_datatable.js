import { LightningElement, wire, track } from 'lwc';
import getContacts from '@salesforce/apex/LWCInlineCtrl.getContacts';
import { updateRecord } from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { refreshApex } from '@salesforce/apex';
import { getPicklistValues, getObjectInfo } from 'lightning/uiObjectInfoApi';
import CONTACT_OBJECT from '@salesforce/schema/Contact';
import  PICKLIST_FIELD from '@salesforce/schema/Contact.GenderIdentity';
import { RefreshEvent } from "lightning/refresh";

const columns = [
    {
        label: 'Name',
        fieldName: 'Name',
        type: 'text',
    }, {
        label: 'FirstName',
        fieldName: 'FirstName',
        type: 'text',
        editable: true,
    }, {
        label: 'LastName',
        fieldName: 'LastName',
        type: 'text',
        editable: true,
    }, {
        label: 'Phone',
        fieldName: 'Phone',
        type: 'phone',
        editable: true,
       
    },
    {
        label: 'Gender Identity', fieldName: 'GenderIdentity', type: 'picklistColumn', editable: true,
         typeAttributes: {
            placeholder: 'Choose Gender', options: { fieldName: 'pickListOptions' }, 
            value: { fieldName: 'GenderIdentity' }, // default value for picklist,
            context: { fieldName: 'Id' } // binding contact Id with context variable to be returned back
        }
    },
    {
        label: 'Do Not Call',
        fieldName: 'DoNotCall',
        type: 'toggel',
        editable: false,
        typeAttributes: {
            value: { fieldName: 'DoNotCall' }, // default value for toggel,
            context: { fieldName: 'Id' } // binding contact Id with context variable to be returned back
        }
    }
];
 
export default class Extended_inline_datatable extends LightningElement {
    columns = columns;
    @track contacts;
    @track condata=[];
     saveDraftValues = [];
    @track pickListOptions;
    lastSavedData=[];

    @wire(getObjectInfo, { objectApiName: CONTACT_OBJECT })
    objectInfo;
 
    //fetch picklist options 
    @wire(getPicklistValues, {
        recordTypeId: "$objectInfo.data.defaultRecordTypeId",
        fieldApiName: PICKLIST_FIELD
    })
 
    wirePickList({ error, data }) {
        if (data) {
            this.pickListOptions = data.values;
        } else if (error) {
            console.log(error);
        }
    }
    @wire(getContacts,{pickList: '$pickListOptions'})
    contactData(result) {
       
        if(result.data!=null && JSON.stringify(result.data)!='undefined')
        {
           
            this.contacts = JSON.parse(JSON.stringify(result.data));
            this.lastSavedData=this.contacts;
            this.contacts.forEach(ele => {
                ele.pickListOptions=this.pickListOptions;
            })
        }
       
     
        if (result.error) {
            this.contacts = undefined;
        }
    };
    //update list of contatcs with changed data
    updateColumnData(updatedItem)
    {
        let copyData = JSON.parse(JSON.stringify(this.contacts));
 
        copyData.forEach(item => {
            if (item.Id === updatedItem.Id) {
                for (let field in updatedItem) {
                    item[field] = updatedItem[field];
                }
            }
        });
 
        this.contacts = [...copyData];
    }
//update draft values to enable edit mode
    updateDraftValuesAndData(updateItem) {
        let draftValueChanged = false;
        let copyDraftValues = [...this.saveDraftValues];

       copyDraftValues.forEach(item => {
            if (item.Id === updateItem.Id) {
                for (let field in updateItem) {
                    item[field] = updateItem[field];
                }
                draftValueChanged = true;
            }
        });
 
        if (draftValueChanged) {
            this.saveDraftValues = [...copyDraftValues];
        } else {
            this.saveDraftValues = [...copyDraftValues, updateItem];
        }
        console.log('draftValueChanged ' + draftValueChanged);
    }
 
    //if cell vlue is changed then update draft values and column list
    handleCellChange(event) {
        
       
        let draftValues = event.detail.draftValues;
        draftValues.forEach(ele=>{
            this.updateDraftValuesAndData(ele);
            this.updateColumnData(ele);
        })
    }
//save the data
    handleSave(event) {
        this.saveDraftValues = event.detail.draftValues;
        const recordInputs = this.saveDraftValues.slice().map(draft => {
            const fields = Object.assign({}, draft);
            return { fields };
        });
       
        // Updateing the records using the UiRecordAPi
        const promises = recordInputs.map(recordInput => updateRecord(recordInput));
        Promise.all(promises).then(res => {
           
            this.ShowToast('Success', 'Records Updated Successfully!', 'success', 'dismissable');
            this.saveDraftValues = [];
            return this.refresh();
        }).catch(error => {
            this.ShowToast('Error', 'An Error Occured!!', 'error', 'dismissable');
        }).finally(() => {
            this.saveDraftValues = [];
        });
    }
//handler for toggel select
    handletoggelselect(event) {
        console.log('in toggel select');
        console.log(JSON.stringify(event));
    
        event.stopPropagation();
        let toggleid = event.detail.data.context;
        let toggleValue = event.detail.data.value;
        console.log('in toggel select toggleValue ' + toggleValue);
       console.log(JSON.stringify(event));
       let updatedItem = { Id: toggleid, DoNotCall: toggleValue  };
       this.updateDraftValuesAndData(updatedItem);
       this.updateColumnData(updatedItem);
    
      
    }
//Handel cancel 
    handleCancel(event) {
        //remove draftValues & revert data changes
        let savepicklist=this.pickListOptions;
        this.contacts =[];
        this.pickListOptions=null;
        this.pickListOptions=savepicklist;
    
    }

    ShowToast(title, message, variant, mode){
        const evt = new ShowToastEvent({
                title: title,
                message:message,
                variant: variant,
                mode: mode
            });
            this.dispatchEvent(evt);
    }
 
    // This function is used to refresh the table once data updated
    async refresh() {
        await refreshApex(this.contacts);
    }
}