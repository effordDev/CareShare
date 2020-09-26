public without sharing class ShareCareHelper {
    
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

}
