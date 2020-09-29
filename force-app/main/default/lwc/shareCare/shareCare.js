import { LightningElement, api, track } from 'lwc';

import getUsers from '@salesforce/apex/ShareCareHelper.getUsers';
import getGroupedUsers from '@salesforce/apex/ShareCareHelper.getGroupedUsers'

import createGroup from '@salesforce/apex/ShareCareHelper.createGroup';
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

    @track _selectedGroups = []
    @track _selectedUsers = []

    @track userColumns = userTable()
    @track groupColumns = groupTable()

    @track selectedRows

    @track contractorGroupName = ''

    @track showCreateGroup = false

    @track isLoading = false
    // -START-

    async connectedCallback() {

        this.users = await getUsers({ p:this.profile })
        this.groups = await getGroups()
    }

    // user table functions
    getSelectedUsers(event) {
        const selected = event.detail.selectedRows

        this._selectedUsers = []

        for (let s of selected) {
            this._selectedUsers.push(s.Id)
        }
    }
    

    //user table functions
    async fetchGroupedUsers() {

        const result = await getGroupedUsers({ groupIds: this._selectedGroups })

        this.groupedUsers = [...result]
    }

    //group table functions
    getSelectedGroups(event) {
        
        const selected = event.detail.selectedRows

        this._selectedGroups = []

        for (const s of selected) {
            this._selectedGroups.push(s.Id)
        } 
        
        if (this._selectedGroups.length) {
            this.fetchGroupedUsers()
        }
        this.groupedUsers = []
    }

    //buttons
    async onCreateGroup(event) {

        if (!this._selectedUsers.length) {
            this.errorToast('Please Select a user to add to the group.')
            return
        }

        if (!this.contractorGroupName) {
            this.errorToast('Please enter a group name.')
            return
        }

        this.contractorGroupName = `GMS Contractors - ${this.contractorGroupName}`

        const result = await createGroup({name: this.contractorGroupName, uids: this._selectedUsers})

        this.groups = [...this.groups, result]

        this.tastyToast(`${this.contractorGroupName} created.`)
        this.selectedRows = []
        this.contractorGroupName = ''
    }

    createGroupModal() {
        this.showCreateGroup = this.showCreateGroup ? false : true 
    }

    onDeleteGroups() {
        console.log('hey we will delete groups here');
    }

    // utils
    onSetContratorName(event) {
        this.contractorGroupName = event.target.value
        console.log(this.contractorGroupName)
    }

    loading() {
        this.isLoading = this.isLoading ? false : true
    }

    errorToast(m) {
        this.dispatchEvent(
            new ShowToastEvent({
                title: 'Error',
                message: m,
                variant: 'error'
            })
        );
    }

    tastyToast(m) {
        this.dispatchEvent(
            new ShowToastEvent({
                title: 'Success',
                message: m,
                variant: 'success'
            })
        );
    }
}