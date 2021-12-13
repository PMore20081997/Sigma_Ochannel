//CAS-26633-Z8W1Y1.MH

table 90020 "Web Sales Invoice"
{
    DataClassification = ToBeClassified;
    LookupPageId = "Web Sales Invoices";

    fields
    {
        field(1; "Web Sales Invoice No."; Code[20])
        {
            DataClassification = ToBeClassified;
            trigger OnValidate()
            begin
                if "Web Sales Invoice No." <> xRec."Web Sales Invoice No." then begin
                    GetSetup;
                    NoSeriesMgt.TestManual(GetNoSeriesCode);
                    "No. Series" := '';
                end;
            end;
        }
        field(2; "Trade Partner Code"; Code[20])
        {
            TableRelation = "Trade Partner";
            DataClassification = ToBeClassified;
            trigger OnValidate()
            var
                LinesRec: Record "Web Sales Invoice Line";
                TradePartner: Record "Trade Partner";
                Cust: Record customer;
            begin
                LinesRec.SetRange("Web Sales Invoice No.", Rec."Web Sales Invoice No.");
                if not LinesRec.IsEmpty then
                    Error(DelReqLbl);
                if TradePartner.Get(Rec."Trade Partner Code") then begin
                    "Location Code" := TradePartner.Location;
                    Cust.Get(TradePartner."Customer No.");
                    if Cust."Bill-to Customer No." <> '' then
                        "Bill-to Customer No." := Cust."Bill-to Customer No."
                    else
                        "Bill-to Customer No." := Cust."No.";
                end;
            end;
        }
        field(3; "Document Creation DateTime"; DateTime)
        {
            DataClassification = ToBeClassified;
            Editable = false;
        }
        field(4; "Posted"; Boolean)
        {
            DataClassification = ToBeClassified;
            Editable = False;
        }
        field(5; "No. Series"; Code[20])
        {
            Caption = 'No. Series';
            Editable = false;
            TableRelation = "No. Series";
            DataClassification = ToBeClassified;
        }
        field(6; "Posting Date"; Date)
        {
            Caption = 'Posting Date';
            DataClassification = ToBeClassified;
        }
        field(7; "Location Code"; code[10])
        {
            Caption = 'Location Code';
            TableRelation = Location;
            Editable = false;
        }
        field(8; "Processing Error"; Text[250])
        {

            Caption = 'Processing Error';
            TableRelation = Location;
            Editable = false;
        }
        field(9; "Stock Posted"; Boolean)
        {
            Caption = 'Stock Posted';
            Editable = False;
        }

        field(10; "Invoice Posted"; Boolean)
        {
            Caption = 'Invoice Posted';
            Editable = False;
        }
        field(11; "Total Qty. to post"; Decimal)
        {
            Caption = 'Total Qty. to post';
            Editable = false;
            FieldClass = FlowField;
            CalcFormula = sum("Web Sales Invoice Line".Quantity where("Web Sales Invoice No." = field("Web Sales Invoice No."), Type = const(Item)));
        }
        field(12; "Total Amt. to post"; Decimal)
        {
            Caption = 'Total Amt. to post';
            Editable = false;
            FieldClass = FlowField;
            CalcFormula = sum("Web Sales Invoice Line".Amount where("Web Sales Invoice No." = field("Web Sales Invoice No.")));
        }

        field(13; "Bill-to Customer No."; Code[20])
        {
            Caption = 'Invoice Posted';
            Editable = False;
        }
        field(14; "No of Error"; Integer)
        {
            Caption = 'No of Error';
            Editable = False;
            FieldClass = FlowField;
            CalcFormula = count("Incoming/Outgoing Error Log" where("Document No." = field("Web Sales Invoice No.")));
        }
        field(15; "Total Invoice Discount"; decimal)
        {
            Caption = 'Total Invoice Discount';
            Editable = false;
        }
        field(16; "Invoice Created"; Boolean)
        {
            Caption = 'Invoice Created';
            Editable = false;
        }
        field(17; "Payment Posted"; Boolean)
        {
            DataClassification = ToBeClassified;
            Editable = false;
        }
        field(18; "From Date"; Date)
        {
            DataClassification = ToBeClassified;
        }
        field(19; "To Date"; Date)
        {
            DataClassification = ToBeClassified;
        }

    }

    keys
    {
        key(PK; "Web Sales Invoice No.")
        {
            Clustered = true;
        }
    }

    var
        myInt: Integer;

    trigger OnInsert()
    begin
        InitInsert();
        "Document Creation DateTime" := CurrentDateTime;
        "Posting Date" := WorkDate();
    end;

    trigger OnModify()
    begin

    end;

    trigger OnDelete()
    var
        LinesRec: Record "Web Sales Invoice Line";
    begin
        LinesRec.SetRange("Web Sales Invoice No.", Rec."Web Sales Invoice No.");
        If LinesRec.FindSet() then
            LinesRec.DeleteAll(true);
    end;

    trigger OnRename()
    begin

    end;

    procedure InitInsert()
    begin
        GetSetup();
        if ("Web Sales Invoice No." = '') then begin
            TestNoSeries;
            NoSeriesMgt.InitSeries(GetNoSeriesCode, xRec."No. Series", Today, "Web Sales Invoice No.", "No. Series");
        end;
    end;

    procedure AssistEdit(OldWebSalesInv: Record "Web Sales Invoice") Result: Boolean
    var
        WebSalesInv2: Record "Web Sales Invoice";
    begin
        //With WebSalesInv do begin

        Copy(Rec);
        GetSetup();
        TestNoSeries;
        if NoSeriesMgt.SelectSeries(GetNoSeriesCode, OldWebSalesInv."No. Series", "No. Series") then begin
            NoSeriesMgt.SetSeries("Web Sales Invoice No.");
            Rec := WebSalesInv;
            exit(true);
        End;
    end;


    procedure GetNoSeriesCode(): Code[20]
    var
        NoSeriesCode: Code[20];
    begin
        GetSetup;
        NoSeriesCode := GeneralSetup."Web Sales Invoice No.s";
        exit(NoSeriesMgt.GetNoSeriesWithCheck(NoSeriesCode, SelectNoSeriesAllowed, "No. Series"));
    end;

    procedure SetAllowSelectNoSeries()
    begin
        SelectNoSeriesAllowed := true;
    end;

    procedure TestNoSeries()
    begin
        GeneralSetup.TestField("Web Sales Invoice No.s");
    end;

    procedure GetSetup()
    begin
        GeneralSetup.get();
    end;

    var
        DelErrLbl: Label 'Web Sales Invoice deletion is prohibited as Document posted already';
        DelReqLbl: Label 'Web Sales Invoice Lines must be deleted first';
        GeneralSetup: record "General Setup - Channels";
        WebSalesInv: Record "Web Sales Invoice";
        NoSeriesMgt: Codeunit NoSeriesManagement;
        SelectNoSeriesAllowed: Boolean;
}