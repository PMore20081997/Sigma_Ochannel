tableextension 90083 "Shipping Agent Ext" extends "Shipping Agent"
{
    fields
    {
        field(90000; "API URL"; Text[100])
        {
            DataClassification = ToBeClassified;
        }
        field(90001; "Access Key"; Text[100])
        {
            DataClassification = ToBeClassified;
        }
        field(90002; "Secret Key"; Text[100])
        {
            DataClassification = ToBeClassified;
        }
        field(90003; "Business Account No"; Text[50])
        {
            DataClassification = ToBeClassified;
        }
        field(90004; "Access Token"; Text[250])
        {
            DataClassification = ToBeClassified;
        }
        field(90005; "Refresh Token"; Text[250])
        {
            DataClassification = ToBeClassified;
        }
        field(90006; "Client Id"; Text[100])
        {
            DataClassification = ToBeClassified;
        }
        field(90007; "Client Secret"; Text[100])
        {
            DataClassification = ToBeClassified;
        }
        field(90008; "Procesing Codeunit"; Integer)
        {
            DataClassification = ToBeClassified;
            TableRelation = AllObjWithCaption."Object ID" WHERE("Object Type" = CONST(Codeunit));
        }
        field(90009; AuthenticationToken; Text[50])
        {
            DataClassification = ToBeClassified;
        }
        field(90010; AuthDate; Date)
        {
            ObsoleteState = Removed;
            ObsoleteReason = 'Created New Field New_AuthDate';
            DataClassification = ToBeClassified;
        }
        field(90011; New_AuthDate; DateTime)
        {
            DataClassification = ToBeClassified;
        }
        field(90012; "Shipping G/L No."; Code[20])
        {
            DataClassification = ToBeClassified;
            TableRelation = "G/L Account"."No.";
        }
        field(90013; "Manifest"; Blob)
        {
            Subtype = Bitmap;
            DataClassification = ToBeClassified;
            Compressed = false;
        }
        field(90014; "Printing Options"; Option)
        {
            DataClassification = ToBeClassified;
            OptionMembers = " ",RAW,PDF;
        }
    }
}