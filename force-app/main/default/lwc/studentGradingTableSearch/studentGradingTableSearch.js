import { api, LightningElement} from 'lwc';
import NewParticipantModal from 'c/newParticipantModal';


export default class StudentGradingTableSearch extends LightningElement {
    id;
    @api trainingid;
    isConnected = false;

    handleIdChange(event) {
        this.id = event.target.value;
    }

    handleAddParticipantFromERPClick() {
        console.log('Clicked new participant');
        this.dispatchEvent(new CustomEvent('importparticipant', {
            detail: { erpId: this.id }
        }));
    }
    handleNewParticipantClick() {
        console.log('clicked new participant');
        console.log('Training ID before modal open:', this.trainingid);
        NewParticipantModal.open({
            size: 'large',
            description: 'Screen to create new participant on training',
            content: 'Passed into content api',
            trainingid: this.trainingid,
            onreloadparticipants: (e) => {
                console.log('Event received in StudentGradingTableSearch');
                this.dispatchEvent(new CustomEvent('reloadparticipants', { detail: e.detail }));
            }
        }
        
        );

        console.log(result);

    }

}