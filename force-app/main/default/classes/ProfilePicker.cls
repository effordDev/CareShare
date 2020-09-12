global class ProfilePicker extends VisualEditor.DynamicPickList {

    global override VisualEditor.DataRow getDefaultValue(){
        VisualEditor.DataRow defaultValue = new VisualEditor.DataRow('None', 'None');
        return defaultValue;
    }

    global override VisualEditor.DynamicPickListRows getValues() {

        List<Profile> profiles = new List<Profile>();

        profiles = [
            SELECT Id, Name, Description
            FROM Profile
            ORDER BY Name
        ];

        VisualEditor.DynamicPickListRows  myValues = new VisualEditor.DynamicPickListRows();

        for (Profile p : profiles) {
            VisualEditor.DataRow value = new VisualEditor.DataRow(p.Name, p.Name);
            myValues.addRow(value);
        }
        
        return myValues;
    }
}
