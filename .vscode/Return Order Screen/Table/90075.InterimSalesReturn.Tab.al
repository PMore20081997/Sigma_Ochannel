table 90075 "Interim Sales Return"
{
    fields
    {
        field(1; "Entry No."; Integer)
        {
            DataClassification = ToBeClassified;
        }
        field(2; "Web Order No."; Code[20])
        {

        }
        field(3; "Item No."; Code[20])
        {

        }
        field(4; Barcode; Code[250])
        {

        }
        field(5; "Variant Code"; Code[20])
        {

        }
        field(6; "User ID"; Code[50])
        {
            DataClassification = ToBeClassified;
        }
        field(7; "Channel Code"; Code[20])
        {

        }
        field(8; Description; Text[100])
        {
            DataClassification = ToBeClassified;
        }
        field(9; "Channel Order id"; code[50])
        {
            DataClassification = ToBeClassified;
        }
        field(10; "Order Quantity"; decimal)
        {
            DataClassification = ToBeClassified;
        }
        field(11; "Quantity to Return"; Decimal)
        {
            DataClassification = ToBeClassified;
        }
        field(12; "Item Unit of Measure"; code[10])
        {
            DataClassification = ToBeClassified;
        }
        field(13; Condition; Code[10])
        {

        }
        field(14; "Return Reason"; Code[10])
        {

        }
        field(15; "Source Line No."; Integer)
        {

        }
        field(16; "Unit Price"; Decimal)
        {
            DataClassification = ToBeClassified;
        }
        field(17; "Trolley No."; Decimal)
        {
            DataClassification = ToBeClassified;
        }
        field(18; "Bay No."; Code[20])
        {
            DataClassification = ToBeClassified;
        }
        field(19; "Discount %"; Decimal)
        {
            DataClassification = ToBeClassified;
        }
        field(20; Type; Enum "Sales Line Type")
        {
            DataClassification = ToBeClassified;


        }
        //Azhar++
        field(21; "Scanned Date"; DateTime)
        {
            DataClassification = ToBeClassified;
        }
        field(22; "Scanned Qty"; Decimal)
        {
            DataClassification = ToBeClassified;
        }
        //Azhar--
    }
    keys
    {
        key(PK; "Entry No.")
        {
            Clustered = true;
        }
        key(sk; "Trolley No.", "Bay No.")
        {
            SumIndexFields = "Quantity to Return";
        }
        key(key2; "Web Order No.")
        {

        }
    }
}