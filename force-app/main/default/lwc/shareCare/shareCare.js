import { LightningElement, api, track } from 'lwc';
import getUsers from '@salesforce/apex/ShareCareHelper.getUsers';

import { userTable, groupTable } from './tableData'

export default class ShareCare extends LightningElement {

    @api profile
    @api sobject

    @track users = []
    @track groups = []
    @track groupedUsers = []

    @track userColumns = userTable()
    @track groupColumns = groupTable()

    async connectedCallback() {

        this.users = await getUsers({ p:this.profile })

    }
}