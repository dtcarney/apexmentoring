import { LightningElement } from 'lwc';
import getActiveUsers from '@salesforce/apex/userListController.getActiveUsers';

import USER_OBJECT from "@salesforce/schema/User";
import FIRST_NAME_FIELD from "@salesforce/schema/User.FirstName";
import LAST_NAME_FIELD from "@salesforce/schema/User.LastName";
import USER_NAME_FIELD from "@salesforce/schema/User.Username";

export default class UserList extends LightningElement {
    /*users = [
        { Id: '1', Name: 'John Doe', Title: 'Manager', Username: 'jdoe@salesforce.com', Phone: '555-555-5555', Department: 'Sales' },
        { Id: '2', Name: 'Jane Smith', Title: 'VP', Username: 'jsmith@salesforce.com', Phone: '555-555-1234', Department: 'Engineering' },
        { Id: '3', Name: 'Bob Johnson', Title: 'Director', Username: 'bjohnson@salesforce.com', Phone: '555-555-9876', Department: 'Sales' },
        { Id: '4', Name: 'Alice White', Title: 'DevOps Manager', Username: 'awhite@salesforce.com', Phone: '555-555-3456', Department: 'Engineering' },
        { Id: '5', Name: 'Tom Green', Title: 'Salesforce Developer', Username: 'tgreen@salesforce.com', Phone: '555-555-6789', Department: 'Engineering' },
    ]; */

    users = [];
    showSpinner = false;

    objectApiName = 'Contact';
    myFields = [FIRST_NAME_FIELD,LAST_NAME_FIELD,USER_NAME_FIELD];

    connectedCallback() {
        this.showSpinner = true;
        getActiveUsers()
            .then(result => {this.users = result;})
            .catch(error => {
                this.error = error;
            })
            .finally(() => {
                console.log('Finally block executed');
            });
        this.showSpinner = false;
    }
}