import { LightningElement } from 'lwc';

export default class EventsDemo extends LightningElement {

    message = 'No button clicks yet';
    clickCount = 0;

    handleClick(){
        this.clickCount +=1;
        this.message = 'Clicked count:  ' + this.clickCount;
    }

}
