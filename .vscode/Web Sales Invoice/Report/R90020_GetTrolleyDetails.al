//CAS-26633-Z8W1Y1.MH

report 90020 "Get Trolley Details"
{
    UsageCategory = Tasks;
    ApplicationArea = All;
    ProcessingOnly = true;
    AccessByPermission = tabledata "Handled Interim Sales Line" = m;
    UseRequestPage = false;

    dataset
    {
        dataitem(HandledInterimSalesLine; "Handled Interim Sales Line")
        {
            DataItemTableView = SORTING(Type, "No.", "NAV Variant code");
            trigger OnPreDataItem()
            begin
                SetRange(Type, Type::Item);
                SetRange("Trade Partner Code", ChannelCode);
                SetFilter("Web Sales Invoice No.", '%1', '');
                TotalCount := Count;
                Clear(TotalInvDis);
                Window.OPEN('Processing: @1@@@@@@@@@@@@@@@');
            end;

            trigger OnAfterGetRecord()
            begin
                Counter += 1;
                CalcTrolleyDetails("No.", "NAV Variant code", ChannelCode);
                Window.UPDATE(1, ROUND(Counter / TotalCount * 10000, 1));
            end;

            trigger OnPostDataItem()
            var
                _WSIH: record "Web Sales Invoice";
                _ChannelRec: Record "Trade Partner";
            begin
                _WSIH.get(WebSalesInvNo);
                _ChannelRec.get(ChannelCode);
                _WSIH."Location Code" := _ChannelRec.Location;
                _WSIH."Posting Date" := WorkDate();
                _WSIH."Total Invoice Discount" := TotalInvDis;
                _WSIH.Modify();
                Window.Close();
            end;
        }
    }

    requestpage
    {
        // layout
        // {
        //     area(Content)
        //     {
        //         group(GroupName)
        //         {
        //             field(Name; SourceExpression)
        //             {
        //                 ApplicationArea = All;

        //             }
        //         }
        //     }
        // }

        // actions
        // {
        //     area(processing)
        //     {
        //         action(ActionName)
        //         {
        //             ApplicationArea = All;

        //         }
        //     }
        // }
    }

    trigger OnPreReport()
    begin
        If ChannelCode = '' then
            Error(Batcherr);
    end;


    local procedure CalcTrolleyDetails(PItemNo: code[20]; PNavvariant: Code[20]; PChannelCode: code[20])
    var
        Amt: Decimal;
        AmtIncl: Decimal;
        Qty: Decimal;
        QtyBase: Decimal;
        HISH: Record "Handled Interim Sales Header";
        HISL: Record "Handled Interim Sales Line";
        HISL2: Record "Handled Interim Sales Line";
    begin
        HISL.SetRange(Type, HISL.Type::Item);
        HISL.SetRange("No.", PItemNo);
        HISL.SetRange("NAV Variant code", PNavvariant);
        HISL.SetRange("Trade Partner Code", PChannelCode);
        HISL.SetFilter("Web Sales Invoice No.", '%1', '');
        If HISL.FindSet() then
            repeat
                if HISL2.get(HISL."Document Type", HISL."Document No", HISL."Line No.") then begin
                    HISL2."Web Sales Invoice No." := WebSalesInvNo;
                    HISL2.Modify();
                end;

                Qty += HISL.Quantity;
                QtyBase += HISL."Quantity(Base)";
                Amt += HISL.Amount;
                AmtIncl += HISL."Amount Including VAT";
                if (HISH."No." = '') or (HISL."Document No" <> HISH."No.") then
                  if HISH.Get(HISH."Document Type"::Order,HISL."Document No") then
                    TotalInvDis += HISH."Order Discount Amount";
            until HISL.Next() = 0;

        If (QtyBase <> 0) then begin
            GlobalLine += GetLineno() + 10000;

            WSIL.Init();
            WSIL."Web Sales Invoice No." := WebSalesInvNo;
            WSIL."Line No." := GlobalLine;
            WSIL."Trade Partner Code" := PChannelCode;
            WSIL.Type := WSIL.Type::Item;
            WSIL."No." := PItemNo;
            WSIL."NAV Variant code" := PNavvariant;
            WSIL.Description := HISL.Description;
            WSIL."Unit of Measure Code" := HISL."Unit of Measure Code";
            WSIL.Quantity := Qty;
            WSIL."Quantity(Base)" := QtyBase;
            WSIL."Unit Price" := HISL."Unit Price";
            WSIL.Amount := Amt;
            WSIL."Amount Including VAT" := AmtIncl;
            WSIL.Insert();
        end;
    end;

    local procedure GetLineno(): Integer
    var
        WSILLoc: record "Web Sales Invoice Line";
    begin
        WSILLoc.SetRange("Web Sales Invoice No.", WebSalesInvNo);
        If WSILLoc.FindLast() then
            Exit(WSILLoC."Line No.");
    end;

    procedure SetChannelcode(PWebSalesInvNo: code[20]; Pchannelcode: code[20])
    begin
        WebSalesInvNo := PWebSalesInvNo;
        ChannelCode := Pchannelcode;
    end;

    var
        WSIL: record "Web Sales Invoice Line";
        GlobalLine: Integer;
        Window: Dialog;
        TotalCount: Integer;
        Counter: Integer;
        ChannelCode: Code[20];
        WebSalesInvNo: code[20];
        Batcherr: Label 'Trade Partner code must be provided on Web Sales Invoice';
        TotalInvDis: Decimal;
}