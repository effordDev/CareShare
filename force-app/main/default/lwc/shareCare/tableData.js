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

export { 
    userTable,
    groupTable 
}