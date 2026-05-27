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
        field(4; "Customer Mapping"; Option)
        {
            OptionMembers = "Default Customer","Order Customer","ET Access Customer";
            trigger OnValidate()
            begin
                CLEAR("Customer No.");
                CLEAR("Customer Name");
            end;
        }
        field(5; "Customer No."; Code[20])
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
        field(6; "Customer Name"; Text[50])
        {
        }
        field(7; Blocked; Boolean)
        {
        }
        field(8; AccessKeyId; Text[250])
        {
        }
        field(9; MarketplaceId; Text[250])
        {
        }
        field(10; MerchantId; Text[250])
        {
        }
        field(11; SecretAccessKey; Text[250])
        {
        }
        field(12; "Partner Type"; Option)
        {
            Description = 'Channel,Carrier';
            OptionMembers = Channel,Carrier;
        }
        field(13; "Sevice/API URL"; Text[250])
        {
        }
        field(14; "Last Product Sync"; DateTime)
        {
        }
        field(15; "Last Order Sync"; DateTime)
        {
        }
        field(16; "Channel Sub Name"; Text[50])
        {
        }
        field(17; "Shipping G/L No."; CODE[20])
        {
            TableRelation = "G/L Account"."No.";
        }
        field(18; "Tracking No Valid. Required"; Boolean)
        {
            DataClassification = ToBeClassified;
        }
        field(19; "Last Inventory Sync"; DateTime)
        {
        }
        field(20; "Last Order Acknowledgment"; DateTime)
        {
        }
        field(21; "Last Order Fullfillment"; DateTime)
        {
        }
        field(22; "GiftWrap G/L No."; Code[20])
        {
            TableRelation = "G/L Account"."No.";
        }
        field(23; SyncPrice; Boolean)
        {
        }
        field(24; SyncInventory; Boolean)
        {
        }
        field(25; SyncOrder; Boolean)
        {
        }
        field(26; OrderFullFilment; Boolean)
        {
        }
        field(27; Token; BLOB)
        {
        }
        field(28; Location; Code[10])
        {
        }
        field(29; "Last Customer Sync"; DateTime)
        {
        }
        field(30; "Process Order Type"; Option)
        {
            OptionMembers = "Internal Pick","Single Order","Consolidate Order";
        }
        field(31; "Positng G/L No."; Code[20])
        {
            DataClassification = ToBeClassified;
            TableRelation = "G/L Account"."No.";
        }
        field(32; "Minimum Inventory"; Decimal)
        {
            DataClassification = ToBeClassified;
        }
        field(33; "Maximum Inventory"; Decimal)
        {
            DataClassification = ToBeClassified;
        }
        field(34; "FTP Upload user ID"; Code[20])
        {
            DataClassification = ToBeClassified;
        }
        field(35; "Prices Including VAT"; Boolean)
        {
            DataClassification = ToBeClassified;
        }
        field(36; "Invoicing Method"; Option)
        {
            DataClassification = ToBeClassified;
            OptionMembers = " ","Consolidate invoice","Per order Invoice";
        }
        field(37; "Order Item By"; Option)
        {
            DataClassification = ToBeClassified;
            OptionMembers = "Item Reference",ASIN,"Channel SKU";
        }
        field(38; "Order Import Codeunit"; Integer)
        {
            DataClassification = ToBeClassified;
            TableRelation = AllObjWithCaption."Object ID" WHERE("Object Type" = CONST(Codeunit));
        }
        field(39; "Channel List Price"; Option)
        {
            OptionMembers = "Unit Price","Special Price";
            DataClassification = ToBeClassified;
        }
        field(40; "Logo"; Blob)
        {
            Subtype = Bitmap;
            DataClassification = ToBeClassified;
        }
        field(41; "Shipping Rule"; Boolean)
        {
            DataClassification = ToBeClassified;
            ObsoleteState = Removed;
        }
        field(42; "Customer No. Series"; Code[10])
        {
            DataClassification = ToBeClassified;
            TableRelation = "No. Series".Code;
        }
        field(43; "Order Acknowledgement Required"; Boolean)
        {
            DataClassification = ToBeClassified;
            trigger OnValidate()
            begin
                if Rec."Order Acknowledgement Required" = true then
                    Rec."Last Date to Export Order Ack" := Today;
            end;
        }
        field(44; "Order Acknowledgement Codeunit"; Integer)
        {
            DataClassification = ToBeClassified;
            TableRelation = AllObjWithCaption."Object ID" WHERE("Object Type" = CONST(Codeunit));
        }
        field(45; TariffCode; Text[20])
        {
            Editable = false;
        }
        field(46; "Last Date to Export Order Ack"; Date)
        {
            Editable = false;
        }
        field(47; "Incoming Order Container Name"; Text[250])
        {
            DataClassification = ToBeClassified;
        }
        field(48; "Incoming Order Container Token"; Text[250])
        {
            DataClassification = ToBeClassified;
        }
        field(49; "API Endpoint"; Text[250])
        {
        }
        field(50; "API Attribute"; Text[250])
        {
        }
        field(51; "Storage Account Name"; Text[250])
        {
            DataClassification = ToBeClassified;
        }
        field(52; "Shared Access Key"; Text[250])
        {
            DataClassification = ToBeClassified;
        }
        field(53; "Order Acknow. Container Name"; Text[250])
        {
            DataClassification = ToBeClassified;
        }
        field(54; "Order Acknow. Container Token"; Text[250])
        {
            DataClassification = ToBeClassified;
        }
        field(55; "Export Invoice"; Boolean)
        {
        }
        field(56; "EDI No.Series"; Code[20])
        {
            DataClassification = ToBeClassified;
            Caption = 'EDI Invoice No.';
            TableRelation = "No. Series";
        }
        field(57; "Last EDI Invoice No."; Code[20])
        {
            Editable = false;
        }
        field(58; "Shipping Rule Validation"; Option)
        {
            OptionMembers = None,Both,"Shipping Agent";
        }
        field(59; "Post auto payment"; Boolean)
        {
            DataClassification = ToBeClassified;
        }
        field(60; "Bank Account Code"; Code[20])
        {
            TableRelation = "Bank Account";
        }
        field(61; "Print Return Note"; Boolean)
        {
            DataClassification = ToBeClassified;
        }
        field(62; "Send Email To Customer"; Boolean)
        {
        }
        field(63; "Last Date to Ex. Odr. fullfill"; Date)
        {
        }
        field(64; "Outgoing Container 2 Name"; Text[250])
        {
        }
        field(65; "Outgoing Container 2 Token"; Text[250])
        {
        }
        field(66; "Outgoing Container 3 Name"; Text[250])
        {
        }
        field(67; "Outgoing Container 3 Token"; Text[250])
        {
        }
        field(68; "Price Pick From"; Option)
        {
            OptionMembers = "Order Source","channel Price","Sales Price";
            Caption = 'Price Pick From';
        }
        field(69; "Update Tracking Information"; Boolean)
        {
            DataClassification = ToBeClassified;
        }
        field(70; "Customer Trend Code"; Boolean)
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
        field(71; "Customer trends Order Nos"; Code[20])
        {
            //This is used at the time of Creating Temp Order++
            TableRelation = "No. Series".Code;
        }
        field(72; "Channel Order No. Series"; Code[20])
        {
            //Channel Specific No. Series
            DataClassification = ToBeClassified;
            TableRelation = "No. Series".Code;
        }
        field(73; "ePOD Template ID"; Integer)
        {

        }
        field(74; "PMR Order Issue"; Boolean)
        {

        }
        field(75; "PodFather"; Boolean)
        {

        }
        field(76; "ePOD Collection Template ID"; Integer)
        {

        }
        field(78; "Last Price Sync"; DateTime)
        {
        }
        field(79; "Batch Size"; Integer)
        {

        }
        field(80; "Sync Customer"; Boolean)
        {

        }
        field(81; "Sync Product"; Boolean)
        {

        }
        field(82; "New QuotaByQuantity Response"; Boolean)
        {

        }
        field(83; "Auth Date"; DateTime)
        {
            Caption = 'Auth Date';
            DataClassification = CustomerContent;
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