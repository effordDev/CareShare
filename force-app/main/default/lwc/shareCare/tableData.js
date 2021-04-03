const userTable = () => {

    return [
        { 
            label: 'Name', 
            fieldName: 'Name', 
            type: 'text' 
        }, 
        {
            label: 'Email',
            fieldName: 'Email',
            type: 'text'
        }
    ]

}

const groupTable = () => {

    return [
        { 
            label: 'Group', 
            fieldName: 'Name', 
            type: 'text'
        }
    ]

}

const recordTable = () => {

    return [
        { 
            label: 'Name', 
            fieldName: 'Name', 
            type: 'text'
        },
        { 
            label: 'Created Date', 
            fieldName: 'createdDate', 
            type: 'date'
        }
    ]

}

export { 
    userTable,
    groupTable,
    recordTable
}