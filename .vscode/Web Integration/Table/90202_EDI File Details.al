table 90023 "EDI File Details"
{
    DataClassification = ToBeClassified;

    fields
    {
        field(1; "Document No"; Code[20])
        {
            DataClassification = ToBeClassified;
        }
        field(2; "Document Type"; Option)
        {
            DataClassification = ToBeClassified;
            OptionMembers = " ",Order,Invoice,"Credit Memo";
        }
        field(3; "File Name"; Text[100])
        {
            DataClassification = ToBeClassified;
        }
        field(4; Sync; Boolean)
        {
            DataClassification = ToBeClassified;
        }
        field(5; "Synced Date"; Date)
        {
            DataClassification = ToBeClassified;
        }
    }

    keys
    {
        key(Key1; "Document No", "Document Type")
        {
            Clustered = true;
        }
    }

    fieldgroups
    {
        // Add changes to field groups here
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