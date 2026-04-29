xmlport 90036 "MIO(HandledOrders)"
{
    Caption = 'Export File';
    DefaultFieldsValidation = false;
    Direction = Export;
    TableSeparator = '<NewLine>';
    Format = VariableText;
    TextEncoding = UTF8;
    UseRequestPage = false;
    FileName = 'mio32.csv';
    schema
    {
        textelement(Root)
        {
            tableelement(Integer; Integer)
            {
                SourceTableView = SORTING(Number) WHERE(Number = CONST(1));
                textelement(TradePartnerCode_HeaderCaption)
                {

                }
                textelement(DocumentType_HeaderCaption)
                {
                }
                textelement(DocumentNo_HeaderCaption)
                {
                }
                textelement(LineNo_HeaderCaption)
                {

                }
                textelement(SelltoCustomerNo_HeaderCaption)
                {

                }
                textelement(Type_HeaderCaption)
                {
                }
                textelement(No_HeaderCaption)
                {
                }
                textelement(QtytoDeliver_HeaderCaption)
                {
                }
                textelement(Quantity_HeaderCaption)
                {
                }

                textelement(OrderDate_HeaderCaption)
                {
                }
                textelement(LineStatus_HeaderCaption)
                {
                }
                textelement(ReasonCode_HeaderCaption)
                {
                }
                textelement(ReasonMessage_HeaderCaption)
                {
                }
                // textelement(SalesDocument_HeaderCaption)
                // {

                // }

                trigger OnAfterGetRecord()
                begin
                    TradePartnerCode_HeaderCaption := 'Trade Partner Code';
                    DocumentType_HeaderCaption := 'Document Type';
                    DocumentNo_HeaderCaption := 'Document No.';
                    LineNo_HeaderCaption := 'Line No.';
                    LineStatus_HeaderCaption := 'Line Status';
                    SelltoCustomerNo_HeaderCaption := 'Sell-to Customer No.';
                    Type_HeaderCaption := 'Type';
                    No_HeaderCaption := 'No.';
                    QtytoDeliver_HeaderCaption := 'Qty. to Deliver';
                    Quantity_HeaderCaption := 'Quantity';
                    OrderDate_HeaderCaption := 'Order Date';
                    ReasonCode_HeaderCaption := 'Reason Code';
                    ReasonMessage_HeaderCaption := 'Reason Message';
                    //SalesDocument_HeaderCaption := 'Sales Document Number';
                end;

            }

            tableelement(HandledInterimSalesLine; "Handled Interim Sales Line")
            {
                SourceTableView = where(Type = const(Item), "Document Type" = const(Order));
                textelement(TradePartnerCode)
                {

                }
                textelement(DocumentType)
                {
                }
                textelement(DocumentNo)
                {
                }
                textelement(LineNo)
                {

                }
                textelement(SelltoCustomerNo)
                {

                }
                textelement(Type)
                {
                }
                textelement(No)
                {
                }
                textelement(QtytoDeliver)
                {
                }
                textelement(Quantity)
                {
                }
                textelement(OrderDate)
                {
                }
                textelement(LineStatus)
                {
                }
                textelement(ReasonCode)
                {
                }
                textelement(ReasonMessage)
                {
                }
                // textelement(salesDocumentNo)
                // {

                // }
                trigger OnAfterGetRecord()
                var
                    L_InterimHandledSalesHeader: Record "Handled Interim Sales Header";
                // L_WebBuffer: Record "Web Buffer";
                begin
                    TradePartnerCode := HandledInterimSalesLine."Trade Partner Code";
                    DocumentType := Format(HandledInterimSalesLine."Document Type");
                    DocumentNo := Format(HandledInterimSalesLine."Document No");
                    LineNo := Format(HandledInterimSalesLine."Line No.");
                    L_InterimHandledSalesHeader.Reset();
                    L_InterimHandledSalesHeader.SetRange("Document Type", HandledInterimSalesLine."Document Type");
                    L_InterimHandledSalesHeader.SetRange("No.", HandledInterimSalesLine."Document No");
                    if L_InterimHandledSalesHeader.FindFirst() then begin
                        LineStatus := Format(L_InterimHandledSalesHeader.Status);
                    end;
                    SelltoCustomerNo := Format(HandledInterimSalesLine."Sell-to Customer No.");
                    Type := Format(HandledInterimSalesLine.Type);
                    No := Format(HandledInterimSalesLine."No.");
                    QtytoDeliver := Format(HandledInterimSalesLine."Qty. to Deliver");
                    Quantity := Format(HandledInterimSalesLine.Quantity);
                    OrderDate := FormatDateForCSV(HandledInterimSalesLine."Order Date");
                    ReasonCode := Format(HandledInterimSalesLine."Reason Code");
                    ReasonMessage := Format(HandledInterimSalesLine."Reason Message");

                    // L_WebBuffer.Reset();
                    // L_WebBuffer.SetRange("Web Document No.", HandledInterimSalesLine."Document No");
                    // if L_WebBuffer.FindFirst() then begin
                    //     salesDocumentNo := L_WebBuffer."Sales Document No.";
                    // end;
                end;

                trigger OnPreXmlItem()
                begin
                    if G_OrderDate <> 0D then
                        HandledInterimSalesLine.SetRange("Order Date", G_OrderDate)
                    else begin
                        HandledInterimSalesLine.SetFilter("Order Date", '%1', CalcDate('-2D', WorkDate()));
                    end;
                end;
            }
        }
    }

    requestpage
    {
        layout
        {
            area(content)
            {
                group("Filters: ")
                {
                    field(G_OrderDate; G_OrderDate)
                    {
                        Caption = 'Order Date: ';
                        ApplicationArea = All;
                    }
                }
            }
        }
    }

    var
        myInt: Integer;
        G_OrderDate: Date;


    procedure FormatDateForCSV(MyDate: Date): Text[10];
    var
        DayStr: Text[2];
        MonthStr: Text[2];
        YearStr: Text[4];
    begin
        if MyDate = 0D then
            exit('');
        DayStr := Format(Date2DMY(MyDate, 1));
        MonthStr := Format(Date2DMY(MyDate, 2));
        YearStr := Format(Date2DMY(MyDate, 3));

        if STRLEN(DayStr) = 1 then
            DayStr := '0' + DayStr;
        if STRLEN(MonthStr) = 1 then
            MonthStr := '0' + MonthStr;
        exit(DayStr + '/' + MonthStr + '/' + YearStr);
    end;
}