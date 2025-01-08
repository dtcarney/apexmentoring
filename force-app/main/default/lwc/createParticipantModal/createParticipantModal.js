import {api, LightningElement } from 'lwc';

import LightningModal from 'lightning/modal';

export default class createParticipantModal extends LightningElement {
    @api content;

    handleOkay() {
        this.close('okay');
    }
}


