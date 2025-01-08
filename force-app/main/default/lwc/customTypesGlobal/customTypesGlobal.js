
import customPicklist from './customPicklist.html';

export default class CustomTypesGlobal extends LightningDataTable {
    static customTypes = {
        priorityPicklist: {
            template: customPicklist,
            standardCellLayout: true,
            typeAttributes: ['label','value', 'placeholder'] 
        }
    }
}