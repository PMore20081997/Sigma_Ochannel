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
        field(6; "Manifest Nos"; Code[20])
        {
            TableRelation = "No. Series".Code;
        }
        field(7; "Despatch Scan Enabled"; Boolean)
        {
        }
        //Sofyan++
        field(8; "Consolidate Item on WIP"; Boolean)
        {
            Caption = 'Consolidate Item On Warehouse Internal Pick';
        }
        //Sofyan--
        //pranali++
        field(9; "Print Return Note"; Boolean)
        {
            DataClassification = ToBeClassified;
            trigger OnValidate()
            var
                TradePartner: Record "Trade Partner";
            begin
                if Rec."Print Return Label" = false then begin
                    TradePartner.Reset();
                    if TradePartner.FindSet() then begin
                        repeat
                            TradePartner.Validate("Print Return Note", false);
                            TradePartner.Modify(true);
                        until TradePartner.Next() = 0;
                    end;
                end;
            end;
        }
        field(10; "Print Order Label"; Boolean)
        {
            DataClassification = ToBeClassified;

        }
        field(11; "Print Return Label"; Boolean)
        {
            DataClassification = ToBeClassified;
        }
        //Pranali--
        field(12; "Web Sales Invoice No.s"; code[20])
        {
            DataClassification = ToBeClassified;
            Description = 'CAS-26633-Z8W1Y1.MH';
            TableRelation = "No. Series";
        }
        field(13; "Item Journal Template"; code[10])
        {
            DataClassification = ToBeClassified;
            Description = 'CAS-26633-Z8W1Y1.MH';
            Tablerelation = "Item Journal Template";
        }
        field(14; "Item Journal Batch"; code[10])
        {
            DataClassification = ToBeClassified;
            Description = 'CAS-26633-Z8W1Y1.MH';
            Tablerelation = "Item Journal Batch";
            trigger OnLookup()
            var
                ItemJnlBatch: record "Item Journal Batch";
            begin
                IF ("Item Journal Template" = '') then
                    Error('Item Journal Template must have a value');

                ItemJnlBatch.SetRange("Journal Template Name", "Item Journal Template");
                if Page.RunModal(0, ItemJnlBatch) = ACTION::LookUpOk then
                    "Item Journal Batch" := ItemJnlBatch.Name;
            end;

            trigger OnValidate()
            var
                ItemJnlBatch: Record "Item Journal Batch";
            begin
                ItemJnlBatch.SetRange("Journal Template Name", "Item Journal Template");
                ItemJnlBatch.SetRange("Name", "Item Journal Batch");
                if ItemJnlBatch.IsEmpty() then
                    ItemJnlBatch.FieldError(ItemJnlBatch.Name);
            end;
        }

        field(15; "Zone Code"; Code[20])
        {
            TableRelation = Zone.Code;
        }
        //CAS-27945-M1R5J2.MH -->
        field(16; "Cash Rct Template Name"; Code[10])
        {
            Caption = 'Cash Rct Template Name';
            TableRelation = "Gen. Journal Template";
        }

        field(17; "Cash Rct Batch Name"; Code[10])
        {
            Caption = 'Cash Rct Batch Name';
            TableRelation = "Gen. Journal Batch".Name WHERE("Journal Template Name" = FIELD("Cash Rct Template Name"));
        }
        //CAS-27945-M1R5J2.MH <--
        field(18; "Quantity Restriction"; Decimal)
        {

        }
        field(19; "Delete Shipment Tracking"; Boolean)
        {

        }
        field(20; "Threshold Value"; Decimal)
        {

        }
        field(21; "Bank Account No."; Code[20])
        {
            TableRelation = "Bank Account"."No.";
        }
        field(22; "Payment Journal Template"; Code[20])
        {
            TableRelation = "Gen. Journal Template";
        }
        field(23; "Payment Jounal Batch"; Code[20])
        {
            TableRelation = "Gen. Journal Batch".Name WHERE("Journal Template Name" = FIELD("Payment Journal Template"));
        }
        field(24; "G/L Account No."; Code[20])
        {
            TableRelation = "G/L Account"."No.";
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
        field(34; "Production Item Inventory"; Integer)
        {

        }
        field(35; "Order Value"; Decimal)
        {
            trigger OnValidate()
            var
                L_InterimSalesHeader: Record "Interim Sales Header";
            begin
                L_InterimSalesHeader.Reset();
                L_InterimSalesHeader.SetRange("Document Type", L_InterimSalesHeader."Document Type"::Order);
                L_InterimSalesHeader.SetRange(status, L_InterimSalesHeader.status::"In Progress");
                if L_InterimSalesHeader.FindSet() then
                    repeat
                        if L_InterimSalesHeader."Order Amount" > Rec."Order Value" then begin
                            L_InterimSalesHeader."Fraud Check" := true;
                            L_InterimSalesHeader.Modify();
                        end
                        else begin
                            L_InterimSalesHeader."Fraud Check" := false;
                            L_InterimSalesHeader.Modify();
                        end;
                    until L_InterimSalesHeader.Next() = 0;
            end;
        }
        field(36; "Despatch Printer Selection"; Boolean)
        {

        }
        field(37; "Despatch Note Report ID"; Integer)
        {

        }
        field(38; "Label Report ID"; Integer)
        {

        }
        field(39; "DPD Label Report ID"; Integer)
        {

        }

        field(40; "AutoReserve"; Boolean)
        {

        }

    }

}