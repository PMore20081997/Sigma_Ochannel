//CAS-26633-Z8W1Y1.MH

tableextension 90021 MyExtension extends "Warehouse Entry"
{
    fields
    {
        // Add changes to table fields here
        field(90000; "Trade Partner Code"; Code[20])
        {
            TableRelation = "Trade Partner";
            DataClassification = ToBeClassified;
        }
    }

    var
        myInt: Integer;
}