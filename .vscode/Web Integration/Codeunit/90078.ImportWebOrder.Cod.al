codeunit 90078 "ImportWebOrder"
{
    TableNo = 472;
    trigger OnRun()
    begin
        IF (STRPOS(Rec."Parameter String", ';')) > 0 THEN begin
            StartParameter := COPYSTR(Rec."Parameter String", 1, (STRPOS(Rec."Parameter String", ';') - 1));
            RunType := COPYSTR(Rec."Parameter String", (STRPOS(Rec."Parameter String", ';') + 1), (STRLEN(Rec."Parameter String") - STRPOS(Rec."Parameter String", ';')));
        end;
        CASE RunType OF
            ImportOrderLabel:
                BEGIN
                    ImportSalesOrder(StartParameter);
                End;
        end;
    end;

    procedure ImportSalesOrder(ChannelCode: Code[20])
    var
        DialoCaption: Text;
        UploadResult: Boolean;
        InStr: InStream;
        FileName: Text[250];
        SheetName: Text[100];
        Rec_ExcelBuffer: Record "Excel Buffer";
        Rows: Integer;
        Columns: Integer;
        RowNo: Integer;
        ExcelQtyEvaulate: Decimal;
        ExcelPriceEvaulate: Decimal;
        L_InterimHeader: Record "Interim Sales Header" temporary;
        L_InterimLine: Record "Interim Sales Line" temporary;
        L_ShipmnetTracking: Record "Shipment Tracking" temporary;
        L_PaymentDetails: Record "Channel Media" temporary;
        L_No: Code[20];
        L_TradePartner: Record "Trade Partner";
        LineNo: Integer;
        HeaderCreated: Boolean;
        C_InterimHeader: Record "Interim Sales Header";
        DuplicateChannID: Boolean;
        Customer: Record Customer;
        Item: Record Item;
        ItemErrorMessage: Text;
    begin
        Clear(HeaderCreated);
        Clear(DuplicateChannID);
        Clear(ShowMsg);
        L_InterimHeader.DeleteAll();
        L_InterimLine.DeleteAll();
        L_ShipmnetTracking.DeleteAll();
        L_PaymentDetails.DeleteAll();
        Rec_ExcelBuffer.DeleteAll();

        Rows := 0;
        Columns := 0;
        DialoCaption := 'Select File to upload';
        RowNo := 0;

        UploadResult := UploadIntoStream(DialoCaption, '', '', FileName, InStr);

        if FileName <> '' then
            SheetName := Rec_ExcelBuffer.SelectSheetsNameStream(InStr)
        else
            exit;

        Rec_ExcelBuffer.Reset();
        Rec_ExcelBuffer.OpenBookStream(InStr, SheetName);
        Rec_ExcelBuffer.ReadSheet();
        Commit();


        //Finiding Total No of Rows to Import
        Rec_ExcelBuffer.Reset();

        Rec_ExcelBuffer.SetRange("Column No.", 1);

        If Rec_ExcelBuffer.FindFirst() then
            repeat
                Rows := Rows + 1;
            until Rec_ExcelBuffer.Next() = 0;



        //Finding total number of columns to import

        Rec_ExcelBuffer.Reset();
        Rec_ExcelBuffer.SetRange("Row No.", 1);
        if Rec_ExcelBuffer.FindFirst() then
            repeat
                Columns := Columns + 1;
            until Rec_ExcelBuffer.Next() = 0;

        //Creating Header++
        if Rows > 1 then begin
            if GetValueAtIndex(2, 4) <> '' then begin
                C_InterimHeader.Reset();
                C_InterimHeader.SetRange("Channel Order ID", GetValueAtIndex(2, 4));
                if C_InterimHeader.FindFirst() then begin
                    DuplicateChannID := true;
                end;

                L_TradePartner.Get(ChannelCode);
                Customer.Get(L_TradePartner."Customer No.");
                Clear(L_No);
                L_InterimHeader.Reset();
                L_InterimHeader.SetRange("Document Type", L_InterimHeader."Document Type"::Order);
                if L_InterimHeader.FindLast() then
                    L_No := IncStr(L_InterimHeader."No.")
                else
                    L_No := '10000';
                L_InterimHeader.Init();
                L_InterimHeader."Document Type" := L_InterimHeader."Document Type"::Order;
                L_InterimHeader."No." := L_No;
                L_InterimHeader.Validate("Trade Partner Code", ChannelCode);
                L_InterimHeader.Validate("Sell-to Customer No.", L_TradePartner."Customer No.");
                L_InterimHeader.Validate("Customer Posting Group", Customer."Customer Posting Group");
                L_InterimHeader.Validate("File Name", FileName);
                L_InterimHeader.Validate("Document Date", WorkDate);
                L_InterimHeader.Validate("Channel Order ID", GetValueAtIndex(2, 4));
                L_InterimHeader.Insert(true);
                HeaderCreated := true;
            end;
        end;
        //Creating Header--

        // for RowNo := 2 to Rows do begin

        // end;
        Clear(LineNo);
        Clear(ItemErrorMessage);
        if HeaderCreated = true then begin
            for RowNo := 2 to Rows do begin
                //Creating Lines++
                // Clear(LineNo);
                // L_InterimLine.Reset();
                // L_InterimLine.SetRange("Document Type", L_InterimHeader."Document Type");
                // L_InterimLine.SetRange("Document No", L_InterimHeader."No.");
                // if not L_InterimLine.FindFirst() then begin
                //     LineNo := 10000;
                // end else begin
                //     LineNo := L_InterimLine."Line No." + 10000;
                // end;
                if Item.Get(GetValueAtIndex(RowNo, 1)) then begin
                    LineNo += 10000;  // Irshad
                    L_InterimLine.Init();
                    L_InterimLine."Document Type" := L_InterimLine."Document Type"::Order;
                    L_InterimLine."Document No" := L_InterimHeader."No.";
                    L_InterimLine."Line No." := LineNo;
                    L_InterimLine.Validate("Trade Partner Code", ChannelCode);
                    L_InterimLine.Validate("Channel Order ID", L_InterimHeader."Channel Order ID");
                    L_InterimLine.Validate("Channel SKU", GetValueAtIndex(RowNo, 1));
                    L_InterimLine.Validate("No.", GetValueAtIndex(RowNo, 1));
                    L_InterimLine.Validate("VAT Bus. Posting Group", Customer."Customer Posting Group");
                    L_InterimLine.Validate("VAT Prod. Posting Group", Item."VAT Prod. Posting Group");
                    L_InterimLine.Insert(true);
                    //Creating Lines--

                    if (GetValueAtIndex(RowNo, 2)) <> '' then begin
                        Evaluate(ExcelQtyEvaulate, GetValueAtIndex(RowNo, 2));
                        L_InterimLine.Quantity := ExcelQtyEvaulate;
                        L_InterimLine.Modify();
                    end;

                    if (GetValueAtIndex(RowNo, 3)) <> '' then begin
                        Evaluate(ExcelPriceEvaulate, GetValueAtIndex(RowNo, 3));
                        L_InterimLine."Unit Price" := ExcelPriceEvaulate;
                        L_InterimLine.Modify();
                    end;
                end
                else begin
                    ItemErrorMessage += GetValueAtIndex(RowNo, 1) + ',';
                end;
            end;
            ItemErrorMessage := ItemErrorMessage.TrimEnd(',');
            if ItemErrorMessage <> '' then
                Error('Items does not exist - ' + ItemErrorMessage);
        end;

        //Creating Web order From Temp++
        L_InterimHeader.Reset();
        if L_InterimHeader.FindSet() then begin
            if L_InterimHeader."No." <> '' then begin
                repeat
                    L_InterimLine.Reset();
                    L_InterimLine.SetRange("Document Type", L_InterimHeader."Document Type");
                    L_InterimLine.SetRange("Document No", L_InterimHeader."No.");
                    if L_InterimLine.FindSet() then begin
                        //repeat
                        //Message('Header' + L_InterimHeader."No." + ' LineNo.:-' + Format(L_InterimLine."Line No."));
                        //until L_InterimLine.Next = 0;
                    end;
                    CUWebOrderMgt.CreateWebOrder(L_InterimHeader, L_InterimLine, L_ShipmnetTracking, L_PaymentDetails);
                    ShowMsg := true;
                until L_InterimHeader.Next = 0;
                //CUWebOrderMgt.CreateWebOrder(L_InterimHeader, L_InterimLine, L_ShipmnetTracking, L_PaymentDetails);
            end;
        end;
        //Creating Web order From Temp--

        if DuplicateChannID = false then begin
            if ShowMsg = true then
                Message('Imported SuccessFully');
        end;

    end;

    local procedure GetValueAtIndex(RowNo: Integer; ColNo: Integer): Text
    var
        Rec_ExcelBuffer: Record "Excel Buffer";
    begin
        Rec_ExcelBuffer.Reset();
        If Rec_ExcelBuffer.Get(RowNo, ColNo) then
            exit(Rec_ExcelBuffer."Cell Value as Text");
    end;




    var
        myInt: Integer;
        StartParameter: Text;
        RunType: Text;
        ImportOrderLabel: Label 'ImportOrder';
        CUWebOrderMgt: Codeunit "Web Order Mgt";
        ShowMsg: Boolean;
}