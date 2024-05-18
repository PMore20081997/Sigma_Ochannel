table 90072 "LinnWorksLocation"
{
    DataClassification = ToBeClassified;

    fields
    {
        field(1; "Location Id"; Code[250])
        {
            DataClassification = ToBeClassified;
        }
        field(2; StockLocationIntId; Code[250])
        {
        }
        field(3; LocationName; Text[50])
        {
        }
        field(4; IsFulfillmentCenter; Boolean)
        {
        }
        field(5; LocationTag; Code[50])
        {
        }
        field(6; IsWarehouseManaged; Boolean)
        {
        }
        field(7; "No."; Integer)
        {
        }
    }

    keys
    {
        key(PK; "Location Id")
        {
            Clustered = true;
        }
    }
}