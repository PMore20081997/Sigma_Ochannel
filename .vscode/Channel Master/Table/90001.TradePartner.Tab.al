table 90001 "Trade Partner"
{
    DataClassification = ToBeClassified;

    fields
    {
        field(1; Code; Code[20])
        {
            DataClassification = ToBeClassified;

        }
        field(2; Name; Text[50])
        {
            CaptionML = ENG = 'Name', ENU = 'Name';
        }
        field(3; "Inbox Type"; Option)
        {

            OptionMembers = "File Location","Web service";
            CaptionML = ENG = 'Inbox Type', ENU = 'Inbox Type';
        }

        field(6; "Customer Mapping"; Option)
        {
            OptionMembers = "Default Customer","Order Customer","ET Access Customer";
            trigger OnValidate()
            var
                myInt: Integer;
            begin
                CLEAR("Customer No.");
                CLEAR("Customer Name");
            end;

        }
        field(7; "Customer No."; Code[20])
        {
            TableRelation = IF ("Customer Mapping" = FILTER("Default Customer")) Customer."No.";
            trigger OnValidate()
            var
                Cust: Record Customer;
            begin
                CLEAR("Customer Name");
                IF Cust.GET("Customer No.") THEN BEGIN
                    "Customer Name" := Cust.Name;
                END;
            end;
        }
        field(8; "Customer Name"; Text[50])
        {
        }
        field(10; Blocked; Boolean)
        {
        }
        field(16; AccessKeyId; Text[250])
        {
        }
        field(17; MarketplaceId; Text[250])
        {
        }
        field(18; MerchantId; Text[250])
        {
        }
        field(19; SecretAccessKey; Text[250])
        {
        }
        field(20; "Partner Type"; Option)
        {
            Description = 'Channel,Carrier';
            OptionMembers = Channel,Carrier;
        }
        field(21; "Sevice/API URL"; Text[250])
        {
        }
        field(22; "Last Product Sync"; DateTime)
        {
        }
        field(23; "Last Order Sync"; DateTime)
        {
        }
        field(24; "Channel Sub Name"; Text[50])
        {
        }
        field(25; "Shipping G/L No."; CODE[20])
        {
            TableRelation = "G/L Account"."No.";
        }
        field(26; "Tracking No Valid. Required"; Boolean)
        {
            DataClassification = ToBeClassified;
        }
        field(27; "Last Inventory Sync"; DateTime)
        {
        }
        field(33; "Last Order Acknowledgment"; DateTime)
        {
        }
        field(34; "Last Order Fullfillment"; DateTime)
        {
        }
        field(38; "GiftWrap G/L No."; Code[20])
        {
            TableRelation = "G/L Account"."No.";
        }
        field(40; SyncPrice; Boolean)
        {
        }
        field(41; SyncInventory; Boolean)
        {
        }
        field(42; SyncOrder; Boolean)
        {
        }
        field(44; OrderFullFilment; Boolean)
        {
        }
        field(45; Token; BLOB)
        {
        }
        field(50001; Location; Code[10])
        {
        }

        field(50004; "Last Customer Sync"; DateTime)
        {
        }
        field(50008; "Process Order Type"; Option)
        {
            OptionMembers = "Internal Pick","Single Order","Consolidate Order";
        }
        field(50024; "Positng G/L No."; Code[20])
        {
            DataClassification = ToBeClassified;
            TableRelation = "G/L Account"."No.";
        }

        field(50026; "Minimum Inventory"; Decimal)
        {
            DataClassification = ToBeClassified;
        }
        field(50027; "Maximum Inventory"; Decimal)
        {
            DataClassification = ToBeClassified;
        }
        field(50028; "FTP Upload user ID"; Code[20])
        {
            DataClassification = ToBeClassified;
        }

        field(50030; "Prices Including VAT"; Boolean)
        {
            DataClassification = ToBeClassified;
        }
        field(50031; "Invoicing Method"; Option)
        {
            DataClassification = ToBeClassified;
            OptionMembers = " ","Consolidate invoice","Per order Invoice";
        }
        field(50032; "Order Item By"; Option)
        {
            DataClassification = ToBeClassified;
            OptionMembers = "Item Reference",ASIN,"Channel SKU";
        }

        field(50034; "Order Import Codeunit"; Integer)
        {
            DataClassification = ToBeClassified;
            TableRelation = AllObjWithCaption."Object ID" WHERE("Object Type" = CONST(Codeunit));
        }

        field(50036; "Channel List Price"; Option)
        {
            OptionMembers = "Unit Price","Special Price";
            DataClassification = ToBeClassified;
        }
        field(50037; "Logo"; Blob)
        {
            Subtype = Bitmap;
            DataClassification = ToBeClassified;
        }
        field(50038; "Shipping Rule"; Boolean)
        {

            DataClassification = ToBeClassified;
            ObsoleteState = Removed;
        }
        field(50039; "Customer No. Series"; Code[10])
        {
            DataClassification = ToBeClassified;
            TableRelation = "No. Series".Code;
        }
        field(50040; "Order Acknowledgement Required"; Boolean)
        {
            DataClassification = ToBeClassified;
            trigger OnValidate()
            begin
                if Rec."Order Acknowledgement Required" = true then
                    Rec."Last Date to Export Order Ack" := Today;
            end;
        }
        field(50041; "Order Acknowledgement Codeunit"; Integer)
        {
            DataClassification = ToBeClassified;
            TableRelation = AllObjWithCaption."Object ID" WHERE("Object Type" = CONST(Codeunit));
        }
        field(50042; TariffCode; Text[20])
        {
            Editable = false;
        }
        field(50043; "Last Date to Export Order Ack"; Date)
        {
            Editable = false;
        }
        //ContainersDetail++
        field(50044; "Incoming Orders Conatiner Name"; Text[250])
        {
            Caption = 'Incoming Container 1 Name';
        }
        field(50045; "Incoming Orders Token"; Text[250])
        {
            Caption = 'Incoming Container 1 Token';
        }
        field(50046; "API Endpoint"; Text[250])
        {
        }
        field(50047; "API Attribute"; Text[250])
        {
        }
        field(50048; "Status Conatiner Name"; Text[20])
        {
            Caption = 'Incoming Container 2 Name';
        }
        field(50049; "Status Token"; Text[250])
        {
            Caption = 'Incoming Container 2 Token';
        }
        field(50050; "Order Acknow. Conatiner Name"; Text[250])
        {
            Caption = 'Outgoing Container Name';
        }
        field(50051; "Order Acknow. Token"; Text[250])
        {
            Caption = 'Outgoing Container Token';
        }
        //ContainersDetail--
        field(50052; "Export Invoice"; Boolean)
        {

        }
        field(50053; "EDI No.Series"; Code[20])
        {
            DataClassification = ToBeClassified;
            Caption = 'EDI Invoice No.';
            TableRelation = "No. Series";
        }
        field(50054; "Last EDI Invoice No."; Code[20])
        {
            Editable = false;
        }
        field(50055; "Shipping Rule Validation"; Option)
        {

            OptionMembers = None,Both,"Shipping Agent";
        }
        field(50056; "Post auto payment"; Boolean)
        {
            DataClassification = ToBeClassified;
        }
        field(50057; "Bank Account Code"; Code[20])
        {
            TableRelation = "Bank Account";
        }
        field(50058; "Print Return Note"; Boolean)
        {
            DataClassification = ToBeClassified;
        }
        field(50059; "Send Email To Customer"; Boolean)
        {

        }
        field(50060; "Last Date to Ex. Odr. fullfill"; Date)
        {

        }
        field(50061; "Outgoing Container 2 Name"; Text[250])
        {

        }
        field(50062; "Outgoing Container 2 Token"; Text[250])
        {

        }

        field(50063; "Outgoing Container 3 Name"; Text[250])
        {

        }
        field(50064; "Outgoing Container 3 Token"; Text[250])
        {

        }
        field(50065; "Price Pick From"; Option)
        {
            OptionMembers = "Order Source","channel Price","Sales Price";
            Caption = 'Price Pick From';

        }

        field(50066; "Update Tracking Information"; Boolean)
        {
            DataClassification = ToBeClassified;

        }
        field(50067; "Customer Trend Code"; Boolean)
        {
            trigger OnValidate()
            var
                L_TradPartner: Record "Trade Partner";
            begin
                if Rec."Customer Trend Code" = true then begin
                    L_TradPartner.SetFilter(Code, '<>%1', Rec.Code);
                    L_TradPartner.SetRange("Customer Trend Code", true);
                    if L_TradPartner.FindFirst() then
                        Error('Customer Trend Code should not be more than one');
                end;
            end;
        }
        field(50068; "Customer trends Order Nos"; Code[20])
        {
            //This is used at the time of Creating Temp Order++
            TableRelation = "No. Series".Code;
        }


    }
    keys
    {
        key(PK; Code)
        {
            Clustered = true;
        }
    }
}