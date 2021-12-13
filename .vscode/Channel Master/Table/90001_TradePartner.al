table 90001 "Trade Partner"
{
    DataClassification = ToBeClassified;

    fields
    {
        field(1; Code; Code[10])
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
            trigger OnValidate()
            var
                myInt: Integer;
            begin
                CLEAR("Incoming Order File Path");
                CLEAR("Arch. Incoming Order File Path");
            end;
        }
        field(4; "Incoming Order File Path"; Text[250])
        {
            DataClassification = ToBeClassified;
            trigger OnLookup()
            var
                FileName: Text;
                FileName2: Text;
                FileMgt: Codeunit "File Management";
                Path: Text;
            begin
                TESTFIELD("Inbox Type", "Inbox Type"::"File Location");
                IF "Incoming Order File Path" = '' THEN
                    FileName := STRSUBSTNO('%1.xml', Code)
                ELSE
                    FileName := "Incoming Order File Path" + STRSUBSTNO('\%1.xml', Code);

                //FileName2 := FileMgt.SaveFileDialog(Text005,FileName,'');//Need to review
                IF FileName <> FileName2 THEN BEGIN
                    Path := FileMgt.GetDirectoryName(FileName2);
                    IF Path <> '' THEN
                        "Incoming Order File Path" := COPYSTR(Path, 1, 250);
                END;
            end;
        }
        field(5; "Arch. Incoming Order File Path"; Text[250])
        {
            DataClassification = ToBeClassified;
            trigger OnLookup()
            var
                myInt: Integer;
            begin
                // TESTFIELD("Inbox Type", "Inbox Type"::"File Location");
                // IF "Inbox Details" = '' THEN
                //     FileName := STRSUBSTNO('%1.xml', Code)
                // ELSE
                //     FileName := "Inbox Details" + STRSUBSTNO('\%1.xml', Code);

                // FileName2 := FileMgt.SaveFileDialog(Text005, FileName, '');
                // IF FileName <> FileName2 THEN BEGIN
                //     Path := FileMgt.GetDirectoryName(FileName2);
                //     IF Path <> '' THEN
                //         "Archived Inbox Details" := COPYSTR(Path, 1, 250);
                // END;
            end;
        }
        field(6; "Customer Mapping"; Option)
        {
            OptionMembers = "Default Customer","Order Customer";
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


        field(50000; "Last Tracking No"; Text[100])
        {
        }
        field(50001; Location; Code[10])
        {
        }
        field(50002; SyncItem; Boolean)
        {
        }
        field(50004; "Last Customer Sync"; DateTime)
        {
        }
        field(50008; "Process Order Type"; Option)
        {
            OptionMembers = "Internal Pick","Single Order","Consolidate Order";
        }
        field(50017; "FTP Incoming File Path"; Text[250])
        {
            DataClassification = ToBeClassified;
        }
        field(50018; "FTP IP Address"; Text[100])
        {
            DataClassification = ToBeClassified;
        }
        field(50019; "FTP User ID"; Text[50])
        {
            DataClassification = ToBeClassified;
        }
        field(50020; "FTP Password"; Text[50])
        {
            DataClassification = ToBeClassified;
        }
        field(50021; "FTP Outgoing File path1"; Text[150])
        {
            DataClassification = ToBeClassified;
        }
        field(50022; "FTP Outgoing File path2"; Text[150])
        {
            DataClassification = ToBeClassified;
        }
        field(50023; "FTP Archive File Path"; Text[150])
        {
            DataClassification = ToBeClassified;
        }
        field(50024; "Positng G/L No."; Code[20])
        {
            DataClassification = ToBeClassified;
            TableRelation = "G/L Account"."No.";
        }
        field(50025; Manifest; Boolean)
        {
            DataClassification = ToBeClassified;
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
        field(50029; "FTP Upload Password"; Text[30])
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
            OptionMembers = "Item Cross Reference",ASIN,"Channel SKU";
        }
        field(50033; "Explode Bom"; Boolean)
        {
            DataClassification = ToBeClassified;
        }
        field(50034; "Order Import Codeunit"; Integer)
        {
            DataClassification = ToBeClassified;
            TableRelation = AllObjWithCaption."Object ID" WHERE("Object Type" = CONST(Codeunit));
        }
        field(50035; "Use Channel List Price"; Boolean)
        {
            DataClassification = ToBeClassified;
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
        }
        field(50045; "Incoming Orders Token"; Text[250])
        {
        }
        field(50046; "API Endpoint"; Text[250])
        {
        }
        field(50047; "API Attribute"; Text[250])
        {
        }
        field(50048; "Status Conatiner Name"; Text[20])
        {
        }
        field(50049; "Status Token"; Text[250])
        {
        }
        field(50050; "Order Acknow. Conatiner Name"; Text[250])
        {
        }
        field(50051; "Order Acknow. Token"; Text[250])
        {
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
        //CAS-27945-M1R5J2.MH -->
        field(50056; "Post auto payment"; Boolean)
        {
            DataClassification = ToBeClassified;
        }
        field(50057; "Bank Account Code"; Code[20])
        {
            TableRelation = "Bank Account";
        }
        //CAS-27945-M1R5J2.MH <--
        field(50058; "Print Return Note"; Boolean)
        {
            DataClassification = ToBeClassified;
        }
        field(50059; "Send Email To Customer"; Boolean)
        {

        }
    }

    keys
    {
        key(PK; Code)
        {
            Clustered = true;
        }
    }
    procedure CreatePaymentDetails(ChannelCode: Code[20]; ChannelOrderID: Code[50]; TotalAmount: Decimal; PayMethod: Text[50]; TransId: Code[50]; TransactionDate: DateTime)
    var

        //PaymentMethodRules: Record "Payment Method Rules";
        RecChannelMedia: Record "Channel Media";
        i: Integer;
        TransDate: Date;
        ChannelMedia: Record "Channel Media";
        RecChannelMedia1: Record "Channel Media";
    begin
        IF RecChannelMedia.FINDLAST THEN
            i := RecChannelMedia."Entry No" + 1
        ELSE
            i := 1;

        RecChannelMedia1.RESET;
        RecChannelMedia1.SETRANGE("Channel Order ID", ChannelOrderID);
        RecChannelMedia1.SETRANGE(Amount, TotalAmount);
        IF NOT RecChannelMedia1.FINDSET THEN BEGIN
            ChannelMedia.INIT;
            ChannelMedia.VALIDATE("Entry No", i);
            ChannelMedia.VALIDATE("Channel Code", ChannelCode);
            ChannelMedia.VALIDATE("Entry Type", ChannelMedia."Entry Type"::Payment);
            ChannelMedia.VALIDATE("Transaction Date", DT2DATE(TransactionDate));
            ChannelMedia.VALIDATE("Channel Order ID", ChannelOrderID);
            ChannelMedia.VALIDATE(Amount, TotalAmount);
            ChannelMedia.VALIDATE("Payment Method", PayMethod);
            ChannelMedia.VALIDATE("Transaction ID", TransId);
            ChannelMedia.INSERT;
        END ELSE BEGIN
            RecChannelMedia1.VALIDATE("Channel Code", ChannelCode);
            RecChannelMedia1.VALIDATE("Entry Type", ChannelMedia."Entry Type"::Payment);
            RecChannelMedia1.VALIDATE("Transaction Date", DT2DATE(TransactionDate));
            RecChannelMedia1.VALIDATE("Channel Order ID", ChannelOrderID);
            RecChannelMedia1.VALIDATE(Amount, TotalAmount);
            RecChannelMedia1.VALIDATE("Payment Method", PayMethod);
            RecChannelMedia1.VALIDATE("Transaction ID", TransId);
            RecChannelMedia1.MODIFY;
        END;
    end;


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