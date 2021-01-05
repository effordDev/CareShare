public without sharing class ShareCareHelper {
    
    //user methods
    @AuraEnabled(cacheable=false)
    public static List<User> getUsers(String p) {
        
        List <User> u = [
            SELECT Id, Name, Email,  Profile.Name
            FROM User
            WHERE Profile.Name = : p
            ORDER BY Name
        ];

        return u;
    }

    @AuraEnabled(cacheable=false)
    public static List<User> getGroupedUsers(List<Id> groupIds) {
        
        List<GroupMember> groupMember = [
            SELECT GroupId, UserOrGroupId
            FROM GroupMember
            WHERE GroupId IN : groupIds
        ];

        List<Id> uids = new List<Id>();

        for (GroupMember members : groupMember) {
            uids.add(members.UserOrGroupId);
        }

        List<User> users = [
            SELECT Id, Name, Email
            FROM User
            WHERE Id IN : uids
        ];

        return users;
    }

    //group methods
    @AuraEnabled(cacheable=false)
    public static List<Group> getGroups() {
        return [
            SELECT Id, Name
            FROM Group 
            WHERE Name LIKE '%Share%'
            ORDER BY Name
        ];
    }

    @AuraEnabled
    public static Group createGroup(String name, List<Id> uids){
        
        name = name + ' (Share)';

        Group newGroup = new Group();
            newGroup.Name = name;
        insert newGroup;

        List<User> users = [
            SELECT Id, Name
            FROM User
            WHERE Id IN : uids
        ];

        List<GroupMember> listGroupMember = new List<GroupMember>(); 

        for (User u : users) {
            
            GroupMember gm = new GroupMember();
                gm.GroupId          = newGroup.Id;
                gm.UserOrGroupId    = u.Id;
            listGroupMember.add(gm);
        }

        insert listGroupMember;

        return newGroup;
    }

    @AuraEnabled
    public static List<Group> deleteGroups(List<Id> groupIds) {
        
        List<Group> groupsToDelete = [
            SELECT Id, Name
            FROM Group
            WHERE Id IN : groupIds
        ];

        delete groupsToDelete;

        return groupsToDelete;
    }

    @AuraEnabled
    public static List <Group> addMember(List<Id> groupIds, List<Id> uids){

        List <GroupMember> membersToInsert = new List <GroupMember>();

        List <Group> groups = [
            SELECT Id, Name
            FROM Group
            WHERE Id IN : groupIds
        ];

        List <User> users = [
            SELECT Id, Name
            FROM User
            WHERE Id IN : uids
        ];

        for (Group g : groups) {

            for (User u : users) {

                GroupMember newMember = new GroupMember();
                    newMember.GroupId       = g.Id;
                    newMember.UserOrGroupId = u.Id;
                membersToInsert.add(newMember);
            }
        } 

        insert membersToInsert;
        return groups;
    }

    @AuraEnabled
    public static List<GroupMember> deleteMembers(List<Id> groupIds, List<Id> uids) {
        
        List<GroupMember> membersToDelete = [
            SELECT GroupId, UserOrGroupId
            FROM GroupMember
            WHERE GroupId IN : groupIds
                AND UserOrGroupId IN : uids
        ];


        delete membersToDelete;

        return membersToDelete;
    }

    //sharing
    @AuraEnabled
    public static List<SObject> availableSObjects(String sob) {
        
        List<sObject> sobjList = Database.query('SELECT Id, Name FROM ' + sob);

        return sobjList;
    }
}
