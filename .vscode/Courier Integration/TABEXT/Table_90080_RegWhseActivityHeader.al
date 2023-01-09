tableextension 90080 "Reg Whse. Activity Hdr" extends "Registered Whse. Activity Hdr."
{
    fields
    {
        field(50000; "No. of Boxes"; Decimal)
        {

        }
        field(50001; "Total weight (consignment)"; Decimal)
        {

        }
        field(50002; "Shipping Agent Code"; Code[10])
        {
            TableRelation = "Shipping Agent".Code;

        }
        field(50004; "Shipping Agent Service Code"; Code[20])
        {
            TableRelation = "Shipping Agent Services".Code where("Shipping Agent Code" = field("Shipping Agent Service Code"));
        }
        //Robosol Ochannel++
        field(90000; "Trolley Closed"; Boolean)
        {
            Caption = '"Trolley Closed"';
        }
        field(90001; "Trolley No."; Code[20])
        {
            Caption = 'Trolley No.';
        }
        field(50007; "Created Date"; Date)
        {
            Editable = false;
        }

        field(90002; Comments; Text[250])
        {
            Caption = 'Comments';
            DataClassification = ToBeClassified;
        }
        //Robosol Ochannel--
    }

    var
        cod: Codeunit "Create Pick";
}