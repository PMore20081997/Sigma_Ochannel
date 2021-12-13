tableextension 90083 "Shipping Agent Ext" extends "Shipping Agent"
{
    fields
    {
        field(50000; "API URL"; Text[100])
        {
            DataClassification = ToBeClassified;

        }
        field(50001; "Access Key"; Text[100])
        {
            DataClassification = ToBeClassified;

        }
        field(50002; "Secret Key"; Text[100])
        {
            DataClassification = ToBeClassified;

        }
        field(50003; "Business Account No"; Text[50])
        {
            DataClassification = ToBeClassified;

        }
        field(50004; "Access Token"; Text[250])
        {
            DataClassification = ToBeClassified;

        }
        field(50005; "Refresh Token"; Text[250])
        {
            DataClassification = ToBeClassified;

        }
        field(50006; "Client Id"; Text[100])
        {
            DataClassification = ToBeClassified;

        }
        field(50007; "Client Secret"; Text[100])
        {
            DataClassification = ToBeClassified;

        }
        field(50008; "Procesing Codeunit"; Integer)
        {
            DataClassification = ToBeClassified;
            TableRelation = AllObjWithCaption."Object ID" WHERE("Object Type" = CONST(Codeunit));
        }
        field(50009; AuthenticationToken; Text[50])
        {
            DataClassification = ToBeClassified;
        }
        field(50010; AuthDate; Date)
        {
            ObsoleteState = Removed;
            ObsoleteReason = 'Created New Field New_AuthDate';
            DataClassification = ToBeClassified;
        }
        field(50011; New_AuthDate; DateTime)
        {
            DataClassification = ToBeClassified;
        }
        field(50012; "Shipping G/L No."; Code[20])
        {
            DataClassification = ToBeClassified;
            TableRelation = "G/L Account"."No.";
        }
    }

}