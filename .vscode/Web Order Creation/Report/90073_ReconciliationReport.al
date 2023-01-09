report 90011 "Reconciliation Report"
{
    UsageCategory = Administration;
    ApplicationArea = All;
    DefaultLayout = RDLC;
    RDLCLayout = 'Reconciliation1.rdl';


    dataset
    {

        dataitem(DateDataItem; Date)
        {
            column(G_ChannelPartner; G_ChannelPartner)
            {

            }
            column(Period_Start; Format("Period Start"))
            {

            }
            column(HandledOrderQuantity; HandledOrderQuantity)
            {

            }
            column(StockPostedILE; ABS(StockPostedILE))
            {

            }
            column(HandledQuantityAmt; HandledQuantityAmt)
            {

            }
            column(HandledQuantityAmtInclVat; HandledQuantityAmtInclVat)
            {

            }
            column(InvoiceAmtPostedIntoCustomerLedger; InvoiceAmtPostedIntoCustomerLedger)
            {

            }
            column(InvoiceAmtLCYPostedIntoCustomerLedger; InvoiceAmtLCYPostedIntoCustomerLedger)
            {

            }


            trigger OnAfterGetRecord()
            var
                L_HnadledOrderLineRec: Record "Handled Interim Sales Line";
                L_HandledOrderHeaderRec: Record "Handled Interim Sales Header";
                L_ItemLedgerEntryRec: Record "Item Ledger Entry";
                L_CustomerLedgerEntryRec: Record "Cust. Ledger Entry";
                L_TradePartnerRec: Record "Trade Partner";

            begin

                Clear(HandledOrderQuantity);
                Clear(StockPostedILE);
                Clear(HandledQuantityAmt);
                Clear(HandledQuantityAmtInclVat);


                // To Get Handled Quantity
                L_HnadledOrderLineRec.Reset();
                if G_ItemNo <> '' then
                    L_HnadledOrderLineRec.SetRange("No.", G_ItemNo);
                L_HnadledOrderLineRec.SetFilter("Scanned Date", '%1..%2', CreateDateTime(DateDataItem."Period Start", 000100T), CreateDateTime(DateDataItem."Period Start", 235900T));
                L_HnadledOrderLineRec.SetFilter("Trade Partner Code", G_ChannelPartner);
                L_HnadledOrderLineRec.SetFilter("Line Status", '<>%1', L_HnadledOrderLineRec."Line Status"::Cancelled);
                L_HnadledOrderLineRec.SetFilter(Type, '%1', L_HnadledOrderLineRec.Type::Item);
                if L_HnadledOrderLineRec.FindSet() then begin
                    repeat
                        L_HandledOrderHeaderRec.Reset();
                        L_HandledOrderHeaderRec.SetRange("No.", L_HnadledOrderLineRec."Document No");
                        if L_HandledOrderHeaderRec.FindFirst() then begin
                            if L_HandledOrderHeaderRec.status <> L_HandledOrderHeaderRec.status::Cancelled then begin
                                HandledOrderQuantity += L_HnadledOrderLineRec.Quantity;
                                HandledQuantityAmt += L_HnadledOrderLineRec.Amount;
                                HandledQuantityAmtInclVat += L_HnadledOrderLineRec."Amount Including VAT";
                            end;
                        end;

                    until L_HnadledOrderLineRec.Next() = 0
                end;


                // Stock Posting in ILE
                L_ItemLedgerEntryRec.Reset();
                if G_ItemNo <> '' then
                    L_ItemLedgerEntryRec.SetRange("Item No.", G_ItemNo);
                L_ItemLedgerEntryRec.SetFilter("Posting Date", '%1', DateDataItem."Period Start");
                L_ItemLedgerEntryRec.SetFilter("Entry Type", '%1', L_ItemLedgerEntryRec."Entry Type"::Sale);
                L_ItemLedgerEntryRec.SetFilter("Document Type", '%1', L_ItemLedgerEntryRec."Document Type"::" ");
                if L_ItemLedgerEntryRec.FindSet() then begin
                    repeat
                        StockPostedILE += L_ItemLedgerEntryRec.Quantity;
                    until L_ItemLedgerEntryRec.Next() = 0;
                end;


                // Calculating Invoice Amt posted into customer ledger entry
                Clear(InvoiceAmtPostedIntoCustomerLedger);
                Clear(InvoiceAmtLCYPostedIntoCustomerLedger);
                L_TradePartnerRec.Reset();
                L_TradePartnerRec.SetRange(Code, G_ChannelPartner);
                if L_TradePartnerRec.FindFirst() then begin
                    L_CustomerLedgerEntryRec.Reset();
                    L_CustomerLedgerEntryRec.SetRange("Customer No.", L_TradePartnerRec."Customer No.");
                    L_CustomerLedgerEntryRec.SetFilter("Document Type", '%1', L_CustomerLedgerEntryRec."Document Type"::Invoice);
                    L_CustomerLedgerEntryRec.SetFilter("Posting Date", '%1', DateDataItem."Period Start");
                    if L_CustomerLedgerEntryRec.FindSet() then begin
                        repeat
                            L_CustomerLedgerEntryRec.CalcFields(Amount);
                            L_CustomerLedgerEntryRec.CalcFields("Amount (LCY)");
                            InvoiceAmtPostedIntoCustomerLedger += L_CustomerLedgerEntryRec.Amount;
                            InvoiceAmtLCYPostedIntoCustomerLedger += L_CustomerLedgerEntryRec."Amount (LCY)";
                        until L_CustomerLedgerEntryRec.Next() = 0;

                    end;
                end;
            end;

            trigger OnPreDataItem()
            begin
                DateDataItem.SetFilter("Period Type", '%1', DateDataItem."Period Type"::Date);
                DateDataItem.SetFilter("Period Start", '%1..%2', G_FromDate, G_ToDate);
            end;
        }

    }

    requestpage
    {
        layout
        {
            area(Content)
            {
                group(GroupName)
                {
                    field(FromDate; G_FromDate)
                    {
                        Caption = 'From Date';
                        ApplicationArea = All;
                        ShowMandatory = true;
                    }
                    field(G_ToDate; G_ToDate)
                    {
                        Caption = 'To Date';
                        ApplicationArea = All;
                        ShowMandatory = true;
                    }
                    field(G_ChannelPartner; G_ChannelPartner)
                    {
                        Caption = 'Channel Partner';
                        ApplicationArea = All;
                        ShowMandatory = true;
                        TableRelation = "Trade Partner".Code;

                    }
                    field(G_ItemNo; G_ItemNo)
                    {
                        Caption = 'Item No.';
                        ApplicationArea = All;
                        TableRelation = Item."No.";
                    }
                }
            }
        }



        trigger OnInit()
        begin
            Clear(G_FromDate);
            Clear(G_ToDate);
            Clear(G_ChannelPartner);
        end;

        trigger OnQueryClosePage(CloseAction: Action): Boolean
        begin
            if G_FromDate = 0D then begin
                Error('From Date is mandotory to Run Reconciliation Report');
            end;

            if G_ToDate = 0D then begin
                Error('To Date is mandotory. Please Enter a value in To Date');
            end;

            if G_ChannelPartner = '' then begin
                Error('Channel Partner is mandotory. Please Enter a value in Channel Partner');
            end;
        end;
    }


    trigger OnInitReport()
    begin

        Clear(HandledOrderQuantity);
    end;

    var
        G_FromDate: Date;
        G_ToDate: Date;
        G_ChannelPartner: Code[100];
        G_ItemNo: Code[100];
        HandledOrderQuantity: Decimal;
        HandledQuantityAmt: Decimal;
        StockPostedILE: Decimal;
        HandledQuantityAmtInclVat: Decimal;

        InvoiceAmtPostedIntoCustomerLedger: Decimal;

        InvoiceAmtLCYPostedIntoCustomerLedger: Decimal;

}