table 90021 "Sync ePODJob Table"
{
    DataClassification = ToBeClassified;

    fields
    {
        field(1; "Primary key"; Text[100])
        {
            DataClassification = ToBeClassified;
        }
        field(2; "Shipment Date"; Date)
        {
            DataClassification = ToBeClassified;
        }

        field(3; "Shipping Agent Code"; Code[10])
        {
            TableRelation = "Shipping Agent" where("ePOD ID" = filter(> 0));
        }
        field(4; "Shipping Agent Service Code"; Code[10])
        {
            TableRelation = "Shipping Agent Services".Code where("Shipping Agent Code" = field("Shipping Agent Code"));
            ValidateTableRelation = false;
        }
        field(5; "Customer Sync"; Boolean)
        {
        }
        field(6; "Route Sync"; Boolean)
        {

        }
        field(8; "No. of Orders to Process"; Integer)
        {
            DataClassification = ToBeClassified;
        }
        field(9; "Weekend Shipping Agent Code"; Code[10])
        {
            TableRelation = "Shipping Agent" where("ePOD ID" = filter(> 0));
        }
        field(10; "Weekend Shipping Service Code"; Code[10])
        {
            Caption = 'Weekend Shipping Agent Service Code';
            TableRelation = "Shipping Agent Services".Code where("Shipping Agent Code" = field("Weekend Shipping Agent Code"));
            ValidateTableRelation = false;
        }

    }

    keys
    {
        key(PK; "Primary key")
        {
            Clustered = true;
        }
    }
}