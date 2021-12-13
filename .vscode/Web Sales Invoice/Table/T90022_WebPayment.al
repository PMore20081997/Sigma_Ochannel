//Robosol.MH 

table 90022 "Web Payment"
{
    DataClassification = ToBeClassified;

    fields
    {
        field(1; "Channel Code"; code[20])
        {
            DataClassification = ToBeClassified;
            TableRelation = "Trade Partner";
        }
        field(2; "Web Payment Method"; Text[50])
        {
            DataClassification = ToBeClassified;
        }
        field(3; "NAV Payment Method"; code[10])
        {
            DataClassification = ToBeClassified;
            TableRelation = "Payment Method";
        }
        field(4; Commission; Decimal)
        {

        }
        field(5; "Payment Service Customer No."; code[20])
        {
            TableRelation = Customer."No." where("Payment Service Code" = filter(<> ''));
        }
        field(6; "NAV Payment Method 2"; code[10])
        {
            DataClassification = ToBeClassified;
            TableRelation = "Payment Method";
        }

    }

    keys
    {
        key(Key1; "Channel Code", "Web Payment Method", "NAV Payment Method")
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