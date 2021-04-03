public without sharing class ShareCareHelper {
    
    //user methods
    @AuraEnabled(cacheable=false)
    public static List<User> getUsers(String p) {
        
        List <User> u = [
            SELECT Id, Name, Email,  Profile.Name
            FROM User
            WHERE ProfileId =: p
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
        
        String q = 'SELECT Id, Name, CreatedDate FROM ' + sob + ' LIMIT 1000';

        List<sObject> sobjList = Database.query(q);

        return sobjList;
    }

    @AuraEnabled
    public static Boolean createShares(List<Id> recordIds, List<Id> groupIds, String sob) {

        List<Group> groups = [
            SELECT Id, Name
            FROM Group
            WHERE Id IN : groupIds
        ];

        String q = 'SELECT Id FROM ' + sob + ' WHERE Id IN: recordIds';

        List<sobject> records = Database.query(q);

        String shareApi = sob.substring(0, sob.length() - 1) + 'Share';

        List<sobject> shares = new List<sobject>();

        try {

            for (sobject o : records) {

                for (Group g : groups) {
    
                    Schema.SObjectType shareType = Schema.getGlobalDescribe().get(shareApi);
                    SObject share = shareType.newSObject();
                        share.put('ParentId', o.Id);
                        share.put('AccessLevel', 'Edit');
                        share.put('UserorGroupId', g.Id);
                        // share.AccessLevel   = 'Edit';
                        // share.UserorGroupId = g.Id;
                    shares.add(share);
                }
            }
            
            system.debug(' here are the shares');
			system.debug(shares);	
            
            if (!shares.isEmpty()) {
                insert shares;
                return true;
            }

            return true;

        } catch (DmlException e) {

            System.debug('The following exception has occurred: ' + e.getMessage());
            return false;
        }
    }

    //TODO: add to ui
    //TODO: add current access and add to ui
    @AuraEnabled
    public static Boolean deleteShares(List<Id> groupIds, List<Id> recordIds) {

        String q = 'SELECT ParentId, UserorGroupId FROM sObject WHERE ParentId IN: recordIds AND UserorGroupId IN: groupIds';
        List<sObject> sharesToDelete = Database.query(q);
            
        try {

            if (!sharesToDelete.isEmpty()){
                delete sharesToDelete;
                return true;
            }

            return true;

        } catch (DmlException e) {
            System.debug('The following exception has occurred: ' + e.getMessage());
            return false;
        }
    }
}
