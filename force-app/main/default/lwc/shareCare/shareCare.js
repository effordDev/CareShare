import { LightningElement, api, track } from 'lwc';
import getUsers from '@salesforce/apex/ShareCareHelper.getUsers';
import getGroupedUsers from '@salesforce/apex/contractorSharingHelper.getGroupedUsers'
import getGroups from '@salesforce/apex/ShareCareHelper.getGroups';

import { 
    userTable, 
    groupTable 
} from './tableData'

export default class ShareCare extends LightningElement {

    @api profile
    @api sobject

    @track users = []
    @track groups = []
    @track groupedUsers = []

    @track _selectedGroups

    @track userColumns = userTable()
    @track groupColumns = groupTable()

    async connectedCallback() {

        this.users = await getUsers({ p:this.profile })
        this.groups = await getGroups()
    }

    //user table functions
    async fetchGroupedUsers() {

        const result = await getGroupedUsers({ groupIds: this._selectedGroups })

        this.groupedUsers = [...result]

    }

    //group table functions
    getSelectedGroups(event) {
        const selected = event.detail.selectedRows

        for (let s of selected) {
            this._selectedGroups.push(s.Id)
        } 

        if (this._selectedGroups.length) {
            this.fetchGroupedUsers()
        }
    }
}