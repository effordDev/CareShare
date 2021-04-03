import { LightningElement, api, track } from 'lwc';

import { 
    ShowToastEvent,
    //config functions
    getProfiles,
    getObjects,
    //user functions
    getUsers,
    getGroupedUsers,
    addMember,
    deleteMembers,
    //group functions
    createGroups,
    deleteGroups,
    getGroups,
    availableSObjects,
    createShares,
} from './utils'

import { 
    userTable, 
    groupTable,
    recordTable,
} from './tableData'

export default class ShareCare extends LightningElement {

    records = []
    _selectedRecords = []

    sobjects = []
    _selectedSobject = ''

    profiles = []
    _selectedProfile = ''

    users = []
    groups = []
    groupedUsers = []

    _selectedGroups = []
    _selectedUsers = []

    userColumns = userTable()
    groupColumns = groupTable()
    recordColumns = recordTable()

    selectedRows

    contractorGroupName = ''

    showMainView = false
    showCreateGroup = false
    showAddUser = false

    isLoading = false
    
    async connectedCallback() {
        this.loading()

        // this.users = await getUsers({ p:this.profile })
        this.groups = await getGroups()
        this.setProfiles()
        this.setsObjects()

        this.loading()
    }

    setShowMainView() {
        this.showMainView = this._selectedProfile != '' && this._selectedSobject != '' ? true : false
    }
    //config
    async setProfiles() {
        const result = await getProfiles()

        this.profiles = result.map(p => {
            const item = {
                label: p.Name,
                value: p.Id
            }
            return item
        })
    }

    async setUsers() {
        this.users = await getUsers({ p:this._selectedProfile })
        console.log(JSON.parse(JSON.stringify(this.users)))
    }

    handleProfileSelect(event) {
        this._selectedProfile = event.detail.value

        this.setUsers()
        this.setShowMainView()
    }

    async setsObjects() {
        this.sobjects = await getObjects()
    }

    handleObjectSelect(event) {
        this._selectedSobject = event.detail.value
        this.setRecords()
        this.setShowMainView()
    }

    async setRecords() {
        this.records = await availableSObjects({ sob:this._selectedSobject })
        console.log(JSON.parse(JSON.stringify(this.records)))
    }

    getSelectedRecords(event) {
        const selected = event.detail.selectedRows

        this._selectedRecords = []

        for (let s of selected) {
            this._selectedRecords.push(s.Id)
        } 
        console.log(this._selectedRecords)
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
        console.log(this._selectedGroups)
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

        const result = await createGroups({name: this.contractorGroupName, uids: this._selectedUsers})

        this.groups = [...this.groups, result]

        this.tastyToast(`${result.Name} created.`)
        this.selectedRows = []
        this.contractorGroupName = ''
        this.loading()
    }

    createGroupModal() {
        this.showCreateGroup = this.showCreateGroup ? false : true 
    }

    async onDeleteGroups() {
        this.loading()

        if (!this._selectedGroups.length) {
            this.errorToast('Please Select a group.')
            this.loading()
            return
        }

        const deletedGroupsResult = await deleteGroups({ groupIds : this._selectedGroups })

        this.groups = [...(await getGroups())]

        this.tastyToast(`${this._selectedGroups.length} Groups Deleted`)

        this.loading()
    }

    
    async onAddUser() {

        this.loading();

        if(!this._selectedUsers.length) {
            this.errorToast('Please Select a User')
            return
        }

        await addMember({ groupIds:this._selectedGroups, uids:this._selectedUsers })

        await this.fetchGroupedUsers()

        this.selectedRows = []

        this.loading()

        this.tastyToast('Success')
    }

    async onRemoveUser() {
        this.loading()

        if (!this._selectedGroups.length) {
            this.errorToast('Please Select a Group')
            return
        }
        if (!this._selectedUsers.length) {
            this.errorToast('Please Select a User')
            return
        }

        await deleteMembers({ groupIds: this._selectedGroups, uids: this._selectedUsers})

        await this.fetchGroupedUsers()

        this.loading()

        this.tastyToast('Success')
    }

    onOpenAddUserModal() {

        if (!this._selectedGroups.length) {
            this.errorToast('Please Select a Group')
            return
        }

        this.showAddUser = true
    }

    onCloseAddUserModal() {
        this.showAddUser = false
    }
    //sharing
    async createShares(event) {

        this.loading()
        this.disabled = true

        let e = false

        if (!this._selectedRecords.length) {
            this.errorToast('Please Select a Record(s) to share')
            e = true
        }

        if (!this._selectedGroups.length) {
            this.errorToast('Please Select a Group(s)')
            e = true
        }

        if (e) {
            // this.disabled = false
            this.loading()
            return
        }        

        try {
            const result = await createShares({ agreementIds:this._selectedRecords, groupIds:this._selectedGroups, sob:this._selectedSobject })

            if (result) {

                this.tastyToast('Success')

            } else {

                this.errorToast('Error Creating Shares')

            }

            // this.getCurrentAccess()

            // this.disabled = false
            this.loading()

        } catch (error) {

            this.errorToast('Error Creating Shares')

        }

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