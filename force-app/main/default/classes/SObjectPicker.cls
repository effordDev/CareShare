global class SObjectPicker {
    
    @AuraEnabled(cacheable = false)
    public static List<sfObject> getValues() {

        List<sfObject> allObjects = new List<sfObject>();

        for(Schema.SObjectType objTyp : Schema.getGlobalDescribe().Values()){

            String apiName = objTyp.getDescribe().getName();
            String labelName = objTyp.getDescribe().getLabel();
            
            // Exclude all the unwanted Sobjects e.g. History, Share etc..
            if((!apiName.containsignorecase('history') 
                && !apiName.containsignorecase('tag') 
                && !apiName.containsignorecase('share') 
                && !apiName.containsignorecase('feed')) 
                && apiName.contains('__c')) {    
                     
                    sfObject value = new sfObject(labelName, apiName);
                    allObjects.add(value);
            }
        }

        return allObjects;
    }

    public class sfObject {
        @AuraEnabled 
        public String label {get;set;}
        @AuraEnabled 
        public String value{get;set;}

        public sfObject() {}

        public sfObject(String o_Label, String o_api) {
            label = o_Label;
            value = o_api;
        }
    }

}
