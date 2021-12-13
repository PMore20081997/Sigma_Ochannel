//CAS-26633-Z8W1Y1.MH

report 90022 "Get Scanned Lines"
{
    UsageCategory = Tasks;
    ApplicationArea = All;
    ProcessingOnly = true;
    AccessByPermission = tabledata "Handled Interim Sales Line" = m;
    UseRequestPage = false;

    dataset
    {
        dataitem(ArchiveScannedEntries; "Archive Scanned Entries")
        {
            DataItemTableView = SORTING("Entry No.") where("Web Inv No" = filter(''), "Warehouse Journal Posted" = filter(true), "Item Journal Posted" = filter(false));
            trigger OnPreDataItem()
            begin
                SetRange("Channel Parter Code", ChannelCode);
                Webinvh.Get(WebSalesInvNo);
                if (Webinvh."From Date" <> 0D) AND (Webinvh."To Date" <> 0D) then
                    ArchiveScannedEntries.SetFilter("Scan Date Time", '%1..%2', CreateDateTime(Webinvh."From Date", 000001T), CreateDateTime(Webinvh."To Date", 235900T));
                TotalCount := Count;

                Clear(TotalInvDis);
                Window.OPEN('Processing: @1@@@@@@@@@@@@@@@');
            end;

            trigger OnAfterGetRecord()
            begin
                Counter += 1;
                CalcTrolleyDetails("Item No.", "Variant code", ChannelCode);
                Window.UPDATE(1, ROUND(Counter / TotalCount * 10000, 1));
            end;

            trigger OnPostDataItem()
            var
                _WSIH: record "Web Sales Invoice";
                _ChannelRec: Record "Trade Partner";
            begin
                CreatecheckNGLEnrtry(WebSalesInvNo);
                UpdateItemonWSIL(WebSalesInvNo); //Prathamesh 24112021
                UpdateInvoiceNoonHandledHeader(WebSalesInvNo);
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
        L_ArchivedScannedEntry: Record "Archive Scanned Entries";
        L_ArchivedScannedEntry2: Record "Archive Scanned Entries";
        L_HISL: Record "Handled Interim Sales Line";

        L_UoM: Code[20];
        L_UnitPrice: Decimal;
    begin
        Clear(L_UoM);
        Clear(L_UnitPrice);
        // L_ArchivedScannedEntry.SetRange(Type, HISL.Type::Item);

        L_ArchivedScannedEntry.SetRange("Item No.", PItemNo);
        L_ArchivedScannedEntry.SetRange("Variant code", PNavvariant);
        L_ArchivedScannedEntry.SetRange("Channel Parter Code", PChannelCode);
        L_ArchivedScannedEntry.SetFilter("Web Inv No", '%1', '');
        L_ArchivedScannedEntry.SetRange("Warehouse Journal Posted", true);
        L_ArchivedScannedEntry.SetRange("Item Journal Posted", false);
        if (Webinvh."From Date" <> 0D) AND (Webinvh."To Date" <> 0D) then
            L_ArchivedScannedEntry.SetFilter("Scan Date Time", '%1..%2', CreateDateTime(Webinvh."From Date", 000001T), CreateDateTime(Webinvh."To Date", 235900T));
        If L_ArchivedScannedEntry.FindSet() then
            repeat
                L_HISL.Reset();
                L_HISL.SetRange("Document Type", L_HISL."Document Type"::Order);
                L_HISL.SetRange("Document No", L_ArchivedScannedEntry."Order No");
                L_HISL.SetRange("Line No.", L_ArchivedScannedEntry."Order Line No.");
                L_HISL.SetRange(Type, L_HISL.Type::Item);
                L_HISL.SetRange("No.", L_ArchivedScannedEntry."Item No.");
                If L_HISL.FindFirst() then Begin
                    if L_ArchivedScannedEntry2.get(L_ArchivedScannedEntry."Entry No.") then begin
                        L_ArchivedScannedEntry2."Web Inv No" := WebSalesInvNo;
                        L_ArchivedScannedEntry."Item Journal Posted" := true;
                        L_ArchivedScannedEntry2.Modify();
                        L_HISL."Web Sales Invoice No." := WebSalesInvNo;
                        L_HISL.Modify();
                    end;

                    Qty += L_ArchivedScannedEntry."Scanned Quantity";
                    QtyBase += L_ArchivedScannedEntry."Scanned Quantity";
                    Amt += L_HISL.Amount;
                    AmtIncl += L_HISL."Amount Including VAT";
                    L_HISL."Web Sales Invoice No." := WebSalesInvNo;
                    L_HISL.Modify();
                    L_UoM := L_HISL."Unit of Measure Code";
                    L_UnitPrice := L_HISL."Unit Price";
                    InsertTempWeborder(L_HISL."Document No");
                End;
            until L_ArchivedScannedEntry.Next() = 0;

        If (QtyBase <> 0) then begin
            GlobalLine := GetLineno() + 10000;

            WSIL.Init();
            WSIL."Web Sales Invoice No." := WebSalesInvNo;
            WSIL."Line No." := GlobalLine;
            WSIL."Trade Partner Code" := PChannelCode;
            WSIL.Type := WSIL.Type::Item;
            WSIL.validate("No.", PItemNo);
            WSIL.validate("NAV Variant code", PNavvariant);
            WSIL.Description := L_ArchivedScannedEntry."Item Desciption";
            WSIL."Unit of Measure Code" := L_UoM;
            WSIL.Quantity := Qty;
            WSIL."Quantity(Base)" := QtyBase;
            WSIL."Unit Price" := L_UnitPrice;
            WSIL.Amount := Amt;
            WSIL."Amount Including VAT" := AmtIncl;
            WSIL.Insert();
        end;

        //CreatecheckNGLEnrtry(WebSalesInvNo);

        //UpdateInvoiceNoonHandledHeader(WebSalesInvNo);
    end;

    local procedure GetLineno(): Integer
    var
        WSILLoc: record "Web Sales Invoice Line";
    begin
        WSILLoc.SetRange("Web Sales Invoice No.", WebSalesInvNo);
        If WSILLoc.FindLast() then
            Exit(WSILLoC."Line No.");

        Exit(0);
    end;

    procedure SetChannelcode(PWebSalesInvNo: code[20]; Pchannelcode: code[20])
    begin
        WebSalesInvNo := PWebSalesInvNo;
        ChannelCode := Pchannelcode;
    end;

    local procedure InsertTempWeborder(P_WeborderNo: Code[20])
    begin
        TempItem.Reset;
        Tempitem.SetRange("No.", P_WeborderNo);
        If Not TempItem.FindFirst() then Begin
            TempItem.Init();
            TempItem."No." := P_WeborderNo;
            TempItem.Insert();
        End;
    end;
    //Prathamesh
    procedure UpdateItemonWSIL(P_WebInvHdr: Code[20])
    var
        L_HSIL: Record "Handled Interim Sales Line";
        L_WebInvLine: Record "Web Sales Invoice Line";
        L_WSIL: Record "Web Sales Invoice Line";
        L_WSIL2: Record "Web Sales Invoice Line";
    begin
        TempItem.Reset;
        If TempItem.FindFirst() then
            repeat
                L_HSIL.Reset();
                L_HSIL.SetRange("Document Type", L_HSIL."Document Type"::Order);
                L_HSIL.SetRange("Document No", TempItem."No.");
                L_HSIL.SetRange(Type, L_HSIL.Type::Item);
                If L_HSIL.FindSet() then
                    repeat
                        L_WSIL2.Reset();
                        L_WSIL2.SetRange("Web Sales Invoice No.", P_WebInvHdr);
                        L_WSIL2.SetRange(Type, L_WSIL2.Type::Item);
                        L_WSIL2.SetRange("No.", L_HSIL."No.");
                        if L_WSIL2.FindFirst() then begin
                            L_WSIL2."VAT%" := L_HSIL."VAT%";
                            L_WSIL2."Vat Amount" := L_HSIL."VAT amount";
                            L_WSIL2.Modify(true);
                        end;
                    until L_HSIL.Next() = 0;
            until TempItem.Next() = 0;
    end;
    //Prathamesh 24/11/2021
    procedure CreatecheckNGLEnrtry(P_WebInvHdr: Code[20])
    var
        L_HSIL: Record "Handled Interim Sales Line";
        L_WebInvLine: Record "Web Sales Invoice Line";
        L_WSIL: Record "Web Sales Invoice Line";
        L_WSIL2: Record "Web Sales Invoice Line";
    begin
        TempItem.Reset;
        If TempItem.FindFirst() then
            repeat
                L_HSIL.Reset();
                L_HSIL.SetRange("Document Type", L_HSIL."Document Type"::Order);
                L_HSIL.SetRange("Document No", TempItem."No.");
                L_HSIL.SetRange(Type, L_HSIL.Type::"G/L Account");
                If L_HSIL.FindSet() then
                    repeat
                        L_WSIL2.Reset();
                        L_WSIL2.SetRange("Web Sales Invoice No.", P_WebInvHdr);
                        L_WSIL2.SetRange(Type, L_WSIL2.Type::"G/L Account");
                        L_WSIL2.SetRange("No.", L_HSIL."No.");
                        If Not L_WSIL2.FindFirst() then begin
                            L_WSIL.Init();
                            L_WSIL."Web Sales Invoice No." := WebSalesInvNo;
                            L_WSIL."Line No." := GlobalLine + 10000;
                            L_WSIL."Trade Partner Code" := L_HSIL."Trade Partner Code";
                            L_WSIL.Type := L_WSIL.Type::"G/L Account";
                            L_WSIL.validate("No.", L_HSIL."No.");
                            L_WSIL.Description := L_HSIL.Description;
                            L_WSIL.Quantity := 1;
                            L_WSIL."Quantity(Base)" := 1;
                            L_WSIL."Unit Price" := L_HSIL."Unit Price";
                            L_WSIL.Amount := L_HSIL.Amount;
                            L_WSIL."Amount Including VAT" := L_HSIL."Amount Including VAT";
                            L_WSIL.Insert();
                        end Else begin
                            L_WSIL2."Unit Price" += L_HSIL."Unit Price";
                            L_WSIL2.Amount += L_HSIL.Amount;
                            L_WSIL2."Amount Including VAT" += L_HSIL."Amount Including VAT";
                            L_WSIL2.Modify();
                        end;
                    until L_HSIL.Next() = 0;
            Until TempItem.Next() = 0
    end;

    procedure UpdateInvoiceNoonHandledHeader(P_WebInvHdr: Code[20])
    var
        L_WebInvLine: Record "Web Sales Invoice Line";
        L_HISH: Record "Handled Interim Sales Header";
    begin
        TempItem.Reset;
        If TempItem.FindFirst() then
            repeat
                L_HISH.Reset();
                L_HISH.SetRange("Document Type", L_HISH."Document Type"::Order);
                L_HISH.SetRange("No.", TempItem."No.");
                If L_HISH.FindSet() then
                    repeat
                        L_HISH."Invoice No." := P_WebInvHdr;
                        TotalInvDis += L_HISH."Order Discount Amount";
                        L_HISH.Modify();
                    until L_HISH.Next() = 0;
            Until TempItem.Next() = 0
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
        TempItem: Record Item temporary;
        Webinvh: Record "Web Sales Invoice";

}