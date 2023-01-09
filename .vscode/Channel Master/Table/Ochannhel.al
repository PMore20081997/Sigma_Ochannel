table 90019 "Ochannel Graph"
{
    DataClassification = ToBeClassified;

    fields
    {
        field(1; "User ID"; text[132])
        {
            DataClassification = ToBeClassified;
        }
        field(2; "Period Lenth"; option)
        {
            OptionMembers = "Day",Week,Month,Quarter,Year;
        }
        field(3; "Show Orders"; Boolean)
        {

        }
        field(4; "Use Work Date As Base"; Boolean)
        {
        }
        field(5; "Value To Calculate"; Option)
        {
            OptionMembers = "Decimal";
        }
        field(6; "Latest Order Document Date"; Date)
        {

        }
    }

    keys
    {
        key(Key1; "User ID")
        {
            Clustered = true;
        }
    }

    var
        myInt: Integer;

    trigger OnInsert()
    begin

    end;

    trigger OnModify()
    begin

    end;

    trigger OnDelete()
    begin

    end;

    trigger OnRename()
    begin

    end;

}