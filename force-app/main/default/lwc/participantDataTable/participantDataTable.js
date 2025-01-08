import LightningDatatable from 'lightning/datatable';
import participantStatus from './templates/participantStatus.html';
import { api } from 'lwc';

export default class ParticipantDataTable extends LightningDatatable {
    static customTypes = {
        customPicklist: {
            template: participantStatus,
            typeAttributes: ['placeholder', 'value', 'recordId', 'options']
        }
    };
    handleClick(event) {
        console.log('### handleClick clicked');
    }
    @api options;
    connectedCallback() {
        console.log('ParticipantDataTable component connected');
        console.log(JSON.stringify(this.options));
    }

    @api
    handleStatusChange(event) {
        this.dispatchEvent(new CustomEvent('statuschange', { detail: event.detail }));
    }

    get updatedColumns() {
        console.log('Options in ParticipantDataTable:', this.options);
        return this.columns.map(column => {
            if (column.type === 'customPicklist') {
                return {
                    ...column,
                    typeAttributes: {
                        ...column.typeAttributes,
                        options: this.options
                    }
                };
            }
            return column;
        });
    }
}
