global class SObjectPicker extends VisualEditor.DynamicPickList {
    
    global override VisualEditor.DataRow getDefaultValue(){
        VisualEditor.DataRow defaultValue = new VisualEditor.DataRow('None', 'None');
        return defaultValue;
    }

    global override VisualEditor.DynamicPickListRows getValues() {

        // Map<String, String> sObjects= new Map<String, String>();

        VisualEditor.DynamicPickListRows  myValues = new VisualEditor.DynamicPickListRows();

        for(Schema.SObjectType objTyp : Schema.getGlobalDescribe().Values()){

            String apiName = objTyp.getDescribe().getName();
            String labelName = objTyp.getDescribe().getLabel();
            
            // Exclude all the unwanted Sobjects e.g. History, Share etc..
            if((!apiName.containsignorecase('history') 
                && !apiName.containsignorecase('tag') 
                && !apiName.containsignorecase('share') 
                && !apiName.containsignorecase('feed')) 
                || apiName.contains('__c')) {    
                     
                VisualEditor.DataRow value = new VisualEditor.DataRow(labelName, apiName);
                myValues.addRow(value);
            }
        }
        
        return myValues;
    }

}
