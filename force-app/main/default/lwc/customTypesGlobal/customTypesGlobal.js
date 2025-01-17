import LightningDatatable from 'lightning/datatable';
import customPicklistStatic from './customPicklistStatic.html';
import customPicklistColumn from './customPicklistColumn.html';

export default class CustomTypesGlobal extends LightningDatatable {
    static customTypes = {
        statusPicklist: {
            template: customPicklistStatic,
            editTemplate: customPicklistColumn,
            standardCellLayout: true,
            typeAttributes: ['label', 'value', 'placeholder', 'options', 'context']
        }
    }
}
