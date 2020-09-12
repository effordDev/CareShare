import { LightningElement, api, track } from 'lwc';
import getUsers from '@salesforce/apex/ShareCareHelper.getUsers';

import { userTable } from './tableData'

export default class ShareCare extends LightningElement {

    @api profile
    @api sobject

    @track users = []

    @track userColumns = userTable()

    async connectedCallback() {

        this.users = await getUsers({ p:this.profile })

    }
}