import { api, LightningElement } from 'lwc';

export default class Child extends LightningElement {

@api trainingid;
isRendered = false;
isConnected = false;


connectedCallback() {
    console.log('Training ID in connectedCallback:', this.trainingid);
    this.isConnected = true;
}


}