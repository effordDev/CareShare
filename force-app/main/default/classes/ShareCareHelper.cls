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
    public static List<String> deleteGroups(List<Id> groupIds) {
        
        List<Group> groupsToDelete = [
            SELECT Id, Name
            FROM Group
            WHERE Id IN : groupIds
        ];

        List<String> deletedGroups = new List<String>();
        
        for (Group g : groupsToDelete) {
            deletedGroups.add(g.Name);
        }

        delete groupsToDelete;

        return deletedGroups;
    }
}
