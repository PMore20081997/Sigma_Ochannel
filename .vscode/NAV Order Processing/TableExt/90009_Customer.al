tableextension 90009 CustomerAdd extends Customer
{
    fields
    {
        field(70194825; "Web Customer No."; Code[20])
        {
            DataClassification = ToBeClassified;
            Caption = 'Web Customer No.';
            ObsoleteState = Removed;
            ObsoleteReason = 'Not In use';
        }
        field(70194826; "Customer type"; Option)
        {
            DataClassification = ToBeClassified;
            OptionMembers = NAV,Web,Both;
            OptionCaptionML = ENU = 'NAV,Web,Both', ENG = 'NAV,Web,Both';
            ObsoleteState = Removed;
            ObsoleteReason = 'Not In use';
        }
        field(70194827; "Company Reg. No."; Text[20])
        {
            CaptionML = ENU = 'Company Reg. No.';
            ObsoleteState = Removed;
            ObsoleteReason = 'Not In use';
        }
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
            OptionCaptionML = ENU = 'NAV,Web,Both', ENG = 'NAV,Web,Both';

        }
        field(90003; "Company Reg. No. 3"; Text[20])
        {
            CaptionML = ENU = 'Company Reg. No.';

        }

    }

    var
        myInt: Integer;
}