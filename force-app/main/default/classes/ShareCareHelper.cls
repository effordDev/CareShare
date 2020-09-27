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
}
