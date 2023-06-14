table 90000 "General Setup - Channels"
{
    fields
    {
        field(1; "Primary Key"; Code[10])
        {

        }
        field(2; "Web Order Nos"; Code[10])
        {
            TableRelation = "No. Series";
        }
        field(3; "Shipping G/L No."; CODE[20])
        {
            TableRelation = "G/L Account"."No.";
        }
        field(4; "GiftWrap G/L No."; Code[20])
        {
            TableRelation = "G/L Account"."No.";
        }

        field(5; "Invoice G/L No."; Code[20])
        {
            TableRelation = "G/L Account"."No.";
        }

        field(7; "Despatch Scan Enabled"; Boolean)
        {
        }

        field(19; "Delete Shipment Tracking"; Boolean)
        {

        }
        field(25; "Allocate Web Orders"; Boolean)
        {

        }
        field(26; "Enable Carriage credit"; Boolean)
        {
            DataClassification = ToBeClassified;
        }
        field(27; "Quantity Restriction (SINGLE)"; Decimal)
        {

        }
        field(28; "Courier Label Container Name"; Text[250])
        {

        }
        field(29; "Courier Label Container Token"; Text[250])
        {
        }
        field(30; "Courier Container Endpoint"; Text[250])
        {
            Caption = 'Courier Label Container Endpoint';
        }
        field(31; "Courier Container Attribute"; Text[250])
        {
            Caption = 'Courier Label Container Attribute';
        }
        field(32; "Download Lable on Azure"; Boolean)
        {
            DataClassification = ToBeClassified;
            Caption = 'Download Delivery Lable on Azure';
        }
        field(33; "Auto Release Sales Orders"; Boolean)
        {

        }

    }

}