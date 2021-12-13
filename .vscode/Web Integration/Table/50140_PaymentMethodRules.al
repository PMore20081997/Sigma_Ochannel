table 90071 "Payment Method Rules"
{
    DataClassification = ToBeClassified;
    ObsoleteReason = 'Replaced by Web payments table';
    ObsoleteState = Removed;
    ObsoleteTag = '18.0';
    fields
    {
        field(1; "Channel Code"; Code[20])
        {
            DataClassification = ToBeClassified;

        }
        field(2; "Nav Payment Code"; Code[10])
        {
            DataClassification = ToBeClassified;
            TableRelation = "Payment Method";

        }
        field(3; "Web Payment Code"; Text[50])
        {
            DataClassification = ToBeClassified;

        }
    }
    keys
    {
        key(PK; "Channel Code", "Nav Payment Code", "Web Payment Code")
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