global class ProfilePicker {

    @AuraEnabled(cacheable = false)
    public static List<Profile> getValues() {

        List<Profile> profiles = new List<Profile>();

        return profiles = [
            SELECT Id, Name, Description
            FROM Profile
            ORDER BY Name
        ];
    }
}
