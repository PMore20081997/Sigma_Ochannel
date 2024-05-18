tableextension 90009 "CustomerAdd" extends Customer
{
    fields
    {
        field(90000; "Payment Service Code"; Code[20])
        {
        }
        field(90001; "Web Customer No. 2"; Code[20])
        {
            DataClassification = ToBeClassified;
            Caption = 'Web Customer No.';
        }
        field(90002; "Customer type 2"; Option)
        {
            DataClassification = ToBeClassified;
            OptionMembers = NAV,Web,Both;
            OptionCaptionML = ENU = 'BC,Web,Both', ENG = 'BC,Web,Both';
        }
        field(90003; "Company Reg. No. 3"; Text[20])
        {
            CaptionML = ENU = 'Company Reg. No.';
        }
        field(90004; "EDI Invoice/Credit"; Boolean)
        {
            DataClassification = ToBeClassified;
        }
    }
}