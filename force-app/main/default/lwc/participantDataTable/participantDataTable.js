import LightningDatatable from 'lightning/datatable';
import picklistCell from './picklistCell.html';

import { api } from 'lwc';

export default class ParticipantDataTable extends LightningDatatable {
    static customTypes = {
        customPicklist: {
            template: picklistCell,
            typeAttributes: ['placeholder', 'value', 'recordId', 'options']
        }
    };
}
