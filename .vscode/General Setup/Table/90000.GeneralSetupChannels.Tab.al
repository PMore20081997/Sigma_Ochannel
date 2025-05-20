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
        field(6; "Despatch Scan Enabled"; Boolean)
        {
        }
        field(7; "Delete Shipment Tracking"; Boolean)
        {
        }
        field(8; "Allocate Web Orders"; Boolean)
        {
        }
        field(9; "Enable Carriage credit"; Boolean)
        {
            DataClassification = ToBeClassified;
        }
        field(10; "Quantity Restriction (SINGLE)"; Decimal)
        {
        }
        field(11; "Courier Label Container Name"; Text[250])
        {
        }
        field(12; "Courier Label Container Token"; Text[250])
        {
        }
        field(13; "Courier Container Endpoint"; Text[250])
        {
            Caption = 'Courier Label Container Endpoint';
        }
        field(14; "Courier Container Attribute"; Text[250])
        {
            Caption = 'Courier Label Container Attribute';
        }
        field(15; "Download Lable on Azure"; Boolean)
        {
            DataClassification = ToBeClassified;
            Caption = 'Download Delivery Lable on Azure';
        }
        field(16; "Auto Release Sales Orders"; Boolean)
        {
        }
        field(17; "Consolidated Sales No. Series"; Code[10])
        {
            TableRelation = "No. Series";
            DataClassification = ToBeClassified;
        }
        field(18; "Knapp Consolidation Counter"; Integer)
        {
            DataClassification = ToBeClassified;
        }
        field(19; "Update Variant Counter"; Integer)
        {
            DataClassification = ToBeClassified;
        }
        field(20; "DC TOS Start Date"; Date)
        {
            DataClassification = ToBeClassified;
        }
        field(21; "No. Of Days"; Code[10])
        {
            DataClassification = ToBeClassified;
        }
    }
}