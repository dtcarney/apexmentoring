import { api, LightningElement, track } from 'lwc';
import Child from 'c/child'

export default class Parent extends LightningElement {

@api recordId
isConnected = false;

connectedCallback() {
    this.isConnected = true;
    console.log('recordId '+ this.recordId);
}

}