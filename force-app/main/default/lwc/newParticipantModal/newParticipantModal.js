import { api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import LightningModal from 'lightning/modal';

export default class NewParticipantModal extends LightningModal {
    @api trainingid;

    handleSuccess(event) {
        console.log('New participant created:', event.detail);
        this.dispatchEvent(new CustomEvent('reloadparticipants', { detail: event.detail }));
        console.log('New participant created:', event.detail);
        this.showToast('Success', 'New participant created.', 'success');
        this.close({ result: 'success', recordId: event.detail.id });
    }

    handleCancel() {
        this.close();
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
