import { LightningElement, api, track } from 'lwc';

import { 
    ShowToastEvent,
    //user functions
    getUsers,
    getGroupedUsers,
    //group functions
    createGroup,
    getGroups
} from './utils'

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
        this.loading()

        this.users = await getUsers({ p:this.profile })
        this.groups = await getGroups()

        this.loading()
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
        this.loading()

        const result = await getGroupedUsers({ groupIds: this._selectedGroups })

        this.groupedUsers = [...result]
        this.loading()
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
        this.loading()

        if (!this._selectedUsers.length) {
            this.errorToast('Please Select a user to add to the group.')
            return
        }

        if (!this.contractorGroupName) {
            this.errorToast('Please enter a group name.')
            return
        }

        const result = await createGroup({name: this.contractorGroupName, uids: this._selectedUsers})

        this.groups = [...this.groups, result]

        this.tastyToast(`${result.Name} created.`)
        this.selectedRows = []
        this.contractorGroupName = ''
        this.loading()
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