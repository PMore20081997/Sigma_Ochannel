//CAS-26633-Z8W1Y1.MH

codeunit 90031 "Post Stock and Invoice"
{
    trigger OnRun()
    begin

    end;

    procedure ProcessforStockPosting(WebSalesInvNo_P: code[20])
    var
        _WSInvHdr: record "Web Sales Invoice";
        _ChannelRec: Record "Trade Partner";
        _PostErr: Label 'Document already Posted, Posting Aborted';
        _ItemJnlBatch: record "Item Journal Batch";
        _JnlBatch: Record "Gen. Journal Batch";
    begin
        GetSetup.Get();
        GetSetup.TestField("Item Journal Template");
        Getsetup.TestField("Item Journal Batch");

        GetSetup.TestField("Cash Rct Template Name");
        Getsetup.TestField("Cash Rct Batch Name");

        if _ItemJnlBatch.get(GetSetup."Item Journal Template", GetSetup."Item Journal Batch") then begin
            If (_ItemJnlBatch."No. Series" <> '') then
                Error('No. series must be blank on Batch Name %1', _ItemJnlBatch.Name);
        end;

        if _JnlBatch.get(GetSetup."Cash Rct Template Name", GetSetup."Cash Rct Batch Name") then begin
            if (_JnlBatch."No. Series" = '') then
                Error('No. series must not be blank on Batch Name %1', _JnlBatch.Name);
        end;

        _WSInvHdr.get(WebSalesInvNo_P);
        _ChannelRec.get(_WSInvHdr."Trade Partner Code");
        _ChannelRec.TestField(_ChannelRec."Bank Account Code");

        _WSInvHdr.TestField("Posting Date");
        _WSInvHdr.TestField("Location Code");
        if _WSInvHdr.Posted then
            Error(_PostErr);
        if not _WSInvHdr."Stock Posted" then begin
            CheckWebSalesInvLines(WebSalesInvNo_P);
            CreateNPostWhseJnlLines(WebSalesInvNo_P);
        end;
        if (GetLastErrorText() = '') then
            CreateNPostSalesInvoice(_WSInvHdr."Web Sales Invoice No.");
    end;


    procedure ProcessStockPosting(WebSalesInvNo_P: code[20])//CS++
    var
        _WSInvHdr: record "Web Sales Invoice";
        _PostErr: Label 'Document already Posted, Posting Aborted';
        _ItemJnlBatch: record "Item Journal Batch";
    begin
        GetSetup.Get();
        GetSetup.TestField("Item Journal Template");
        Getsetup.TestField("Item Journal Batch");

        if _ItemJnlBatch.get(GetSetup."Item Journal Template", GetSetup."Item Journal Batch") then begin
            If (_ItemJnlBatch."No. Series" <> '') then
                Error('No. series must be blank on Batch Name %1', _ItemJnlBatch.Name);
        end;

        _WSInvHdr.get(WebSalesInvNo_P);

        _WSInvHdr.TestField("Posting Date");
        _WSInvHdr.TestField("Location Code");
        if _WSInvHdr.Posted then
            Error(_PostErr);
        if not _WSInvHdr."Stock Posted" then begin
            CheckWebSalesInvLines(WebSalesInvNo_P);
            CreateNPostItemJournalLines(WebSalesInvNo_P);
        end;
        if (GetLastErrorText() = '') then
            CreateNPostSalesInvoice(_WSInvHdr."Web Sales Invoice No.");
    end;

    procedure CreateNPostSalesInvoice(WebSalesInvNo_P: code[20])
    var
        _WSInvHdr: record "Web Sales Invoice";
        _ChannelRec: record "Trade Partner";
        _SalesInv: record "sales header";
        _SalesPost: Codeunit "Sales-Post";
        _cust: record Customer;
        SalesCalcDiscByType: Codeunit "Sales - Calc Discount By Type";
        paymentposted: Boolean;

    begin
        _WSInvHdr.get(WebSalesInvNo_P);
        if _WSInvHdr."Invoice Posted" then
            exit;
        _ChannelRec.get(_WSInvHdr."Trade Partner Code");
        _Cust.GET(_ChannelRec."Customer No.");
        IF _Cust."Prices Including VAT" THEN
            ERROR(STRSUBSTNO('Price including VAT must be No on Customer %1', _Cust."No."));
        if not _WSInvHdr."Invoice Created" then begin
            _SalesInv.Init();
            _SalesInv.Validate("Document Type", _SalesInv."Document Type"::Invoice);
            _SalesInv.InitRecord();
            _SalesInv.Validate("No.", _WSInvHdr."Web Sales Invoice No.");
            _SalesInv.Insert(true);
            _SalesInv.Validate("Sell-to Customer No.", _ChannelRec."Customer No.");
            _SalesInv.validate("External Document No.", _WSInvHdr."Web Sales Invoice No.");
            _SalesInv.Validate("Posting Date", _WSInvHdr."Posting Date");
            _SalesInv.Validate("Location Code", _WSInvHdr."Location Code");
            _SalesInv.Validate("Posting No.", _SalesInv."No.");
            _SalesInv.Invoice := true;
            _SalesInv.Modify();
            CreateSalesInvLines(_SalesInv."No.", _WSInvHdr."Web Sales Invoice No.");
            SalesCalcDiscByType.ApplyInvDiscBasedOnAmt(_WSInvHdr."Total Invoice Discount", _SalesInv);
            /*_SalesInv.get(_SalesInv."Document Type",_SalesInv."No.");
            _SalesInv.Validate("Invoice Discount Calculation",_SalesInv."Invoice Discount Calculation"::Amount);
            _SalesInv.validate("Invoice Discount Value",_WSInvHdr."Total Invoice Discount");
            _SalesInv.Modify();*/
            Commit();
        end else begin
            _SalesInv.get(2, WebSalesInvNo_P);
        end;

        if not _SalesPost.Run(_SalesInv) then begin
            _WSInvHdr."Invoice Created" := true;
            _WSInvHdr."Processing Error" := copystr(GetLastErrorText(), 1, 250);
            _WSInvHdr."Invoice Posted" := false;
            _WSInvHdr.Modify();
        end else begin
            clear(_WSInvHdr."Processing Error");
            _WSInvHdr."Invoice Created" := true;
            _WSInvHdr."Invoice Posted" := true;
            _WSInvHdr.Modify();
        end;
        if (_WSInvHdr."Processing Error" = '') then begin
            _WSInvHdr.Posted := true;
            _WSInvHdr.Modify();
            //CAS-27945-M1R5J2.MH -->
            if _ChannelRec."Post auto payment" then begin
                paymentposted := CreatenPostCashRcptJnl(_WSInvHdr."Web Sales Invoice No.", _ChannelRec.Code);
            end;
            //CAS-27945-M1R5J2.MH <--
            if _ChannelRec."Post auto payment" then begin
                if paymentposted then
                    MoveWebInvoiceToPosted(_WSInvHdr."Web Sales Invoice No.");
            end else
                MoveWebInvoiceToPosted(_WSInvHdr."Web Sales Invoice No.");
        end;

    end;

    procedure MoveWebInvoiceToPosted(P_WebInvoice: Code[20])
    var
        L_WebInvHdr: Record "Web Sales Invoice";
        L_WebInvLine: Record "Web Sales Invoice Line";
        L_PostedWebInvHdr: Record "Posted Web Sales Invoice";
        L_PostedWebInvLine: Record "Posted Web Sales Inv. Line";
        _ChannelRec: record "Trade Partner";
    begin
        If L_WebInvHdr.get(P_WebInvoice) then begin
            If Not L_WebInvHdr.Posted then
                exit;

            L_PostedWebInvHdr.Init();
            L_PostedWebInvHdr.TransferFields(L_WebInvHdr);
            L_PostedWebInvHdr.Insert();

            _ChannelRec.get(L_PostedWebInvHdr."Trade Partner Code");

            L_WebInvLine.Reset();
            L_WebInvLine.SetRange("Web Sales Invoice No.", P_WebInvoice);
            //L_WebInvLine.SetRange("Stock Posted", true);
            If L_WebInvLine.FindFirst() then
                repeat
                    L_PostedWebInvLine.Init();
                    L_PostedWebInvLine.TransferFields(L_WebInvLine);
                    L_PostedWebInvLine.Insert();
                until L_WebInvLine.Next() = 0;

            L_WebInvHdr.Delete(true);


        end;
    end;

    //CAS-27945-M1R5J2.MH -->
    procedure CreatenPostCashRcptJnl(P_WebInvoice: Code[20]; P_TradePartnercode: code[20]): Boolean
    var
        _HISH: Record "Handled Interim Sales Header";
        _HISHtemp: Record "Handled Interim Sales Header" temporary;
        _HISL: Record "Handled Interim Sales Line";
        _GenJnlLine: Record "Gen. Journal Line";
        _PSI: record "Sales Invoice Header";
        _ChannelRec: record "Trade Partner";
        _Paymentmth: Record "Payment Method";
        _JnlBatch: Record "Gen. Journal Batch";
        _Noseriesmngmnt: codeunit NoSeriesManagement;
        _PayDetails: Record "Channel Media";
        _PayDetails2: Record "Channel Media";
        _PayDetailstemp: Record "Channel Media" temporary;
        _PayDetails2temp: Record "Channel Media" temporary;
        _WebPayment: Record "Web Payment";
        _Lineno: Integer;
        _PmtMethod: Code[10];
        _amt: Decimal;
        _AmtInclVAT: Decimal;
        _ChannelOrdID: Text;
        PaymentMethod: Record "Payment Method";
        salesin: Page "Sales Invoice";
        GenJnlPost: Codeunit "Gen. Jnl.-Post Batch";
        GetSetup: Record "General Setup - Channels";
        _GenJnlLine1: Record "Gen. Journal Line";
        L_Cust: Record Customer;//Sofyan
    begin
        Commit();
        _ChannelRec.get(P_TradePartnercode);
        GetSetup.Get();
        if NOT _ChannelRec."Post auto payment" then
            exit;
        _PSI.SetRange("External Document No.", P_WebInvoice);
        If _PSI.FindFirst() then;

        _HISL.SetRange("Web Sales Invoice No.", P_WebInvoice);
        if _HISL.FindSet() then
            repeat
                if not _HISHtemp.get(_HISL."Document Type", _HISL."Document No") then begin
                    if _HISH.Get(_HISL."Document Type", _HISL."Document No") then begin
                        _HISHtemp.Init();
                        _HISHtemp.TransferFields(_HISH);
                        _HISHtemp.Insert();
                        if _ChannelOrdID <> '' then
                            _ChannelOrdID := _ChannelOrdID + '|' + _HISH."Channel Order ID"
                        else
                            _ChannelOrdID := _HISH."Channel Order ID";

                    end;
                end;
            until _HISL.Next() = 0;

        _PayDetails.SetCurrentKey("Payment Method", "Channel Order ID");
        _PayDetails.SetRange("Channel Code", P_TradePartnercode);
        _PayDetails.SetFilter("Channel Order ID", _ChannelOrdID);
        if _PayDetails.findset then
            repeat
                _PayDetailstemp.init();
                _PayDetailstemp.transferfields(_PayDetails);
                _PayDetailstemp.insert;

                _WebPayment.SetRange("Channel Code", _PayDetails."Channel Code");
                _WebPayment.SetRange("Web Payment Method", _PayDetails."Payment Method");
                if _WebPayment.FindFirst() then begin
                    _PayDetailstemp."Payment Method" := _WebPayment."NAV Payment Method 2";
                    _PayDetailstemp."Nav Payment Method" := _WebPayment."NAV Payment Method 2";
                    _PayDetailstemp."Customer No." := _WebPayment."Payment Service Customer No.";
                    _PayDetailstemp.Modify();
                end;
                _PayDetails2temp.Init();
                _PayDetails2temp.TransferFields(_PayDetailstemp);
                _PayDetails2temp.Insert();

            until _PayDetails.next() = 0;

        _PayDetailstemp.SetCurrentKey("Payment Method", "Channel Order ID");
        _PayDetailstemp.SetRange("Channel Code", P_TradePartnercode);
        _PayDetailstemp.SetFilter("Channel Order ID", _ChannelOrdID);
        if _PayDetailstemp.FindSet() then
            repeat

                if _PmtMethod <> _PayDetailstemp."Payment Method" then begin

                    _PmtMethod := _PayDetailstemp."Payment Method";
                    //if _Paymentmth.get(_PmtMethod) then;
                    if _Paymentmth.get(_PayDetailstemp."Nav Payment Method") then;
                    clear(_AmtInclVAT);

                    _PayDetails2temp.Reset();
                    _PayDetails2temp.SetCurrentKey("Payment Method", "Channel Order ID");
                    _PayDetails2temp.SetRange("Channel Code", P_TradePartnercode);
                    _PayDetails2temp.SetFilter("Channel Order ID", _ChannelOrdID);
                    _PayDetails2temp.SetRange("Payment Method", _PmtMethod);
                    if _PayDetails2temp.FindSet() then
                        repeat
                            //_HISH.Reset();
                            //_HISH.SetRange("Document Type", _HISHtemp."Document Type");
                            // _HISH.SetRange("No.", _HISHtemp."No.");
                            //_HISH.SetRange("Payment Method", _PmtMethod);

                            // _HISH.SetRange("Trade Partner Code", _PayDetails2temp."Channel Code");
                            // _HISH.SetRange("Channel Order ID", _PayDetails2temp."Channel Order ID");
                            // _HISH.SetRange("Web Sales Invoice No. Filter", P_WebInvoice); //Flowfilter
                            // _HISH.SetAutoCalcFields("WebInv Amount", "WebInv Amt Incl VAT");
                            // if _HISH.FindSet() then
                            //     repeat
                            //         _amt += _HISH."WebInv Amount";
                            //         _AmtInclVAT += _HISH."WebInv Amt Incl VAT";
                            //     until _HISH.Next() = 0;
                            _AmtInclVAT += _PayDetails2temp.Amount;//  _PayDetailstemp.Amount;
                        until _PayDetails2temp.Next() = 0;

                    If (_AmtInclVAT <> 0) then begin

                        _JnlBatch.get(GetSetup."Cash Rct Template Name", GetSetup."Cash Rct Batch Name");
                        _GenJnlLine.Reset();
                        _GenJnlLine.SetRange("Journal Template Name", GetSetup."Cash Rct Template Name");
                        _GenJnlLine.SetRange("Journal Batch Name", GetSetup."Cash Rct Batch Name");
                        _GenJnlLine.SetRange("Source Code", 'CASHRECJNL');
                        if _GenJnlLine.FindLast() then
                            _Lineno := _GenJnlLine."Line No." + 10000
                        else
                            _Lineno += 10000;

                        _GenJnlLine.Init();
                        _GenJnlLine.VALIDATE("Journal Template Name", GetSetup."Cash Rct Template Name");
                        _GenJnlLine.VALIDATE("Journal Batch Name", GetSetup."Cash Rct Batch Name");
                        _GenJnlLine.VALIDATE("Line No.", _Lineno);
                        _GenJnlLine.validate("Posting Date", WorkDate());
                        _GenJnlLine.VALIDATE("Source Code", 'CASHRECJNL');
                        _GenJnlLine.VALIDATE("Document Type", _GenJnlLine."Document Type"::" ");
                        _GenJnlLine."Document No." := _Noseriesmngmnt.GetNextNo(_JnlBatch."No. Series", Today, true);
                        _GenJnlLine.Validate("Account Type", _GenJnlLine."Account Type"::Customer);
                        //  _GenJnlLine.Validate("Account No.", _ChannelRec."Customer No.");//Sofyan
                        L_Cust.Reset();
                        L_Cust.SetRange("No.", _ChannelRec."Customer No.");
                        if L_Cust.FindFirst() then begin
                            if L_Cust."No." <> L_Cust."Bill-to Customer No." then
                                _GenJnlLine.Validate("Account No.", L_Cust."Bill-to Customer No.")
                            else
                                _GenJnlLine.Validate("Account No.", L_Cust."No.");
                        end;
                        _GenJnlLine.validate("External Document No.", P_WebInvoice);
                        _GenJnlLine.Description := _Paymentmth.Description;
                        if PaymentMethod.Get(_Paymentmth.Code) then
                            _GenJnlLine.validate(_GenJnlLine."Payment Method Code", _Paymentmth.Code);
                        _GenJnlLine.Validate(Amount, -_AmtInclVAT);
                        _GenJnlLine.Insert();

                        _GenJnlLine1.Init();
                        _GenJnlLine1.copy(_GenJnlLine);
                        _GenJnlLine1."Line No." := _GenJnlLine."Line No." + 10000;
                        _GenJnlLine1."Account No." := _PayDetailstemp."Customer No.";
                        _GenJnlLine1.Validate(Amount, _AmtInclVAT);
                        /*_GenJnlLine.Validate("Bal. Account Type", _GenJnlLine."Bal. Account Type"::"Bank Account");
                        _GenJnlLine.Validate("Bal. Account No.", _ChannelRec."Bank Account Code");
                        _GenJnlLine.Validate("Applies-to Doc. Type", _GenJnlLine."Applies-to Doc. Type"::Invoice);
                        _GenJnlLine.validate("Applies-to Doc. No.", _Psi."No.");*/
                        _GenJnlLine1.Insert();

                    end;
                end;

            until _PayDetailstemp.Next() = 0;
        if (_Lineno <> 0) then begin
            _GenJnlLine.SetRange("External Document No.", P_WebInvoice);
            //if GenJnlPost.Run(_GenJnlLine) then
            CODEUNIT.RUN(CODEUNIT::"Gen. Jnl.-Post Batch", _GenJnlLine);
            exit(true)
            //else  
            //exit(false)
        end;
    end;
    //CAS-27945-M1R5J2.MH <--
    local procedure CreateSalesInvLines(InvNo: code[20]; WebSalesInvNo_P: code[20])
    var
        _WSInvLine: record "Web Sales Invoice Line";
        _WSInvHdr: record "Web Sales Invoice";
        _SL: record "Sales Line";
        _SalesInv: record "sales header";
        _ChannelRec: record "Trade Partner";
        _DimensionVal: Record "Dimension Value";
        _TempDimSetEntry: record "Dimension Set Entry" temporary;
        _dimMgt: Codeunit DimensionManagement;
        _Lineno: Integer;
        L_GenSetup_Channel: Record "General Setup - Channels";
        L_SL: record "Sales Line";
    begin
        L_GenSetup_Channel.Get();
        _SalesInv.get(_SalesInv."Document Type"::Invoice, InvNo);
        _WSInvHdr.get(WebSalesInvNo_P);
        _ChannelRec.get(_WSInvHdr."Trade Partner Code");
        _WSInvLine.SetRange("Web Sales Invoice No.", WebSalesInvNo_P);
        //  _WSInvLine.SetRange(Type, _WSInvLine.Type::Item);
        _WSInvLine.SetFilter("No.", '<>%1', '');
        _WSInvLine.SetFilter(Quantity, '<>%1', 0);
        If _WSInvLine.FindSet() then
            repeat
                _Lineno += 10000;

                /*_DimensionVal.get('CHANNEL', '1002');
                _TempDimSetEntry.DeleteAll();
                clear(_TempDimSetEntry);
                _TempDimSetEntry.INIT;
                _TempDimSetEntry.VALIDATE("Dimension Code", 'CHANNEL');
                _TempDimSetEntry.VALIDATE("Dimension Value Code", _DimensionVal.Code);
                _TempDimSetEntry."Dimension Value ID" := _DimensionVal."Dimension Value ID";
                _TempDimSetEntry.INSERT;*/
                L_SL.Reset();
                L_SL.SetRange("Document Type", _SalesInv."Document Type");
                L_SL.SetRange("Document No.", _SalesInv."No.");
                L_SL.SetRange(Type, L_SL.Type::"G/L Account");
                IF _WSInvLine.Type = _WSInvLine.Type::"G/L Account" then begin
                    L_SL.SetRange("No.", _WSInvLine."No.");
                end Else begin
                    If _ChannelRec."Positng G/L No." <> '' then
                        L_SL.SetRange("No.", _ChannelRec."Positng G/L No.")
                    Else begin
                        L_SL.SetRange("No.", L_GenSetup_Channel."Invoice G/L No.");
                    end;
                end;
                L_SL.SetRange("VAT Prod. Posting Group", _WSInvLine."VAT Prod. Posting Group");
                If Not L_SL.FindFirst() then begin
                    _SL.Init();
                    _SL.Validate("Document Type", _SL."Document Type"::Invoice);
                    _SL.Validate("Document No.", InvNo);
                    _SL.validate("Line No.", _Lineno);
                    _SL.Validate("Location Code", _WSInvHdr."Location Code");
                    _SL.validate("Sell-to Customer No.", _SalesInv."Sell-to Customer No.");
                    _SL.validate(Type, _SL.Type::"G/L Account");
                    IF _WSInvLine.Type = _WSInvLine.Type::"G/L Account" then begin
                        _SL.Validate("No.", _WSInvLine."No.");
                    end Else begin
                        If _ChannelRec."Positng G/L No." <> '' then
                            _SL.Validate("No.", _ChannelRec."Positng G/L No.")
                        Else begin
                            _SL.Validate("No.", L_GenSetup_Channel."Invoice G/L No.");
                        end;
                    end;
                    /* If _ChannelRec."Positng G/L No." <> '' then
                         _SL.Validate("No.", _ChannelRec."Positng G/L No.")
                     Else begin
                         _SL.Validate("No.", L_GenSetup_Channel."Invoice G/L No.");
                     end;*/
                    if _WSInvHdr."Total Invoice Discount" > 0 then
                        _SL."Allow Invoice Disc." := true;
                    _SL.Validate(Quantity, 1);
                    _sl.validate("Qty. to Ship", 1);
                    _SL.validate("Qty. to Invoice", 1);
                    _SL.validate("Unit Price", _WSInvLine.Amount);
                    _SL.Validate("VAT Prod. Posting Group", _WSInvLine."VAT Prod. Posting Group");
                    //_SL.Validate("Dimension Set ID", _DimMgt.GetDimensionSetID(_TempDimSetEntry));
                    _SL.Insert();

                end Else begin
                    L_SL.validate("Unit Price", (L_SL."Unit Price" + _WSInvLine.Amount));
                    L_SL.Modify();
                end;
            until _WSInvLine.Next() = 0;
    end;

    local procedure CreateNPostWhseJnlLines(WebSalesInvNo_p: code[20])
    var
        _WSInvLines: Record "Web Sales Invoice Line";
        _WSInvHdr: record "Web Sales Invoice";
        _channelcode: code[20];
    begin
        _WSInvHdr.get(WebSalesInvNo_p);
        _WSInvLines.SetRange("Web Sales Invoice No.", WebSalesInvNo_P);
        _WSInvLines.SetRange(Type, _WSInvLines.Type::Item);
        _WSInvLines.SetFilter("Trade Partner Code", '<>%1', '');
        if _WSInvLines.FindSet() then begin
            DeletePriorWhseLine('ITEM', 'DEFAULT');
            repeat
                if _channelcode = '' then
                    _channelcode := _WSInvLines."Trade Partner Code";
                CreateWhseJnlLines('ITEM', 'DEFAULT', _WSInvHdr."Location Code", _WSInvLines."No.", _WSInvLines."NAV Variant code", -(_WSInvLines.Quantity), _WSInvLines."Trade Partner Code");
            until _WSInvLines.Next() = 0;
            Commit();
            PostWhseJnlLines('ITEM', 'DEFAULT', _WSInvHdr."Location Code", _channelcode);
        end;
    end;

    local procedure CreateNPostItemJournalLines(WebSalesInvNo_p: code[20])
    var
        _WSInvLines: Record "Web Sales Invoice Line";
        _WSInvHdr: record "Web Sales Invoice";
        _channelcode: code[20];
        ErrTxt: Text;
    begin
        /*_WSInvHdr.get(WebSalesInvNo_p);
        _WSInvLines.SetRange("Web Sales Invoice No.", WebSalesInvNo_P);
        _WSInvLines.SetRange(Type, _WSInvLines.Type::Item);
        _WSInvLines.SetFilter("Trade Partner Code", '<>%1', '');
        if _WSInvLines.FindSet() then begin
            DeletePriorWhseLine('ITEM', 'DEFAULT');
            repeat
                if _channelcode = '' then
                    _channelcode := _WSInvLines."Trade Partner Code";
                CreateWhseJnlLines('ITEM', 'DEFAULT', _WSInvHdr."Location Code", _WSInvLines."No.", _WSInvLines."NAV Variant code", -(_WSInvLines.Quantity), _WSInvLines."Trade Partner Code");
            until _WSInvLines.Next() = 0;
            Commit();
            PostWhseJnlLines('ITEM', 'DEFAULT', _WSInvHdr."Location Code", _channelcode);*/
        ProcessItemJournal(_channelcode, ErrTxt);
        //end;
    end;

    local procedure DeletePriorWhseLine(TemplateName_P: code[10]; BatchName_P: Code[10])
    var
        _WJnLLine: record "Warehouse Journal Line";
    begin
        _WJnLLine.SetRange("Journal Template Name", TemplateName_P);
        _WJnLLine.SetRange("Journal Batch Name", BatchName_P);
        if _WJnLLine.FindLast() then
            _WJnLLine.DeleteAll();
    end;

    local procedure PostWhseJnlLines(TemplateName_P: code[10]; BatchName_P: Code[10]; Locationcode_P: Code[10]; channel_P: Code[20])
    var
        _WJnLLine: record "Warehouse Journal Line";
        _WSInvHdr: Record "Web Sales Invoice";
        ErrTxt: text;
    begin
        _WJnLLine.SetRange("Journal Template Name", TemplateName_P);
        _WJnLLine.SetRange("Journal Batch Name", BatchName_P);
        _WJnLLine.SetRange("Location Code", Locationcode_P);
        If _WJnLLine.FindSet() then begin
            IF CODEUNIT.RUN(CODEUNIT::"Whse. Jnl.-Register Batch", _WJnLLine) THEN begin
                ProcessItemJournal(channel_P, ErrTxt);
                if (ErrTxt <> '') then
                    _WSInvHdr."Processing Error" := copystr(ErrTxt, 1, 250)
            end else
                _WSInvHdr."Processing Error" := copystr(GetLastErrorText(), 1, 250);
            if (GetLastErrorText() <> '') or (ErrTxt <> '') then
                _WSInvHdr.Modify();
        end;
    end;

    local procedure PostWhseJnlLinesByTrolley(TemplateName_P: code[10]; BatchName_P: Code[10]; Locationcode_P: Code[10]; channel_P: Code[20]; P_TrolleyNo: Code[20])
    var
        _WJnLLine: record "Warehouse Journal Line";
        _WSInvHdr: Record "Web Sales Invoice";
        ErrTxt: text;
    begin
        Commit();
        _WJnLLine.SetRange("Journal Template Name", TemplateName_P);
        _WJnLLine.SetRange("Journal Batch Name", BatchName_P);
        _WJnLLine.SetRange("Location Code", Locationcode_P);
        If _WJnLLine.FindSet() then begin
            IF CODEUNIT.RUN(CODEUNIT::"Whse. Jnl.-Register Batch", _WJnLLine) THEN begin
                UpdateWhseJournalPostedOnArchieved(P_TrolleyNo);
            end else
                _WJnLLine.SetRange("Journal Template Name", TemplateName_P);
            _WJnLLine.SetRange("Journal Batch Name", BatchName_P);
            _WJnLLine.SetRange("Location Code", Locationcode_P);
            _WJnLLine.DeleteAll();
            //Message(GetLastErrorText());

        end;
    end;

    local procedure UpdateWhseJournalPostedOnArchieved(P_TrolleyNo: Code[20])
    var
        L_ArchivedEntry: Record "Archive Scanned Entries";
    begin
        L_ArchivedEntry.Reset();
        L_ArchivedEntry.SetRange("Trolley No", P_TrolleyNo);
        L_ArchivedEntry.SetRange("Warehouse Journal Posted", false);
        If L_ArchivedEntry.FindSet() then
            L_ArchivedEntry.ModifyAll("Warehouse Journal Posted", true);
    end;

    local procedure ProcessItemJournal(channel_P: Code[20]; var ErrorText_P: Text)
    var
        _ItemJnlLine: Record "Item Journal Line";
        _ItemJnlLine2: Record "Item Journal Line";
        _CalcAdjmnt: Report "Calc. Whse. Adjustment";
        _DocumentNo: Code[20];
    begin
        GetSetup.Get();
        _ItemJnlLine.SetRange("Journal Template Name", GetSetup."Item Journal Template");
        _ItemJnlLine.SetRange("Journal Batch Name", GetSetup."Item Journal Batch");
        _ItemJnlLine.DeleteAll();

        _ItemJnlLine.Reset();
        _ItemJnlLine.INIT;
        _ItemJnlLine.VALIDATE("Journal Template Name", GetSetup."Item Journal Template");
        _ItemJnlLine.VALIDATE("Journal Batch Name", GetSetup."Item Journal Batch");
        _ItemJnlLine.VALIDATE("Document No.", 'WO ' + FORMAT(Today));

        _CalcAdjmnt.SetItemJnlLine(_ItemJnlLine);
        _CalcAdjmnt.USEREQUESTPAGE(false);
        _CalcAdjmnt.SetParameter(channel_P, TempWJL);
        _DocumentNo := DELCHR(('DD ' + FORMAT(today)), '=', '/-');
        _CalcAdjmnt.InitializeRequest(Today, _DocumentNo + '-' + channel_P);//'DD '+FORMAT(postingDate)
        _CalcAdjmnt.RUN;
        CLEAR(_CalcAdjmnt);
        COMMIT;

        _ItemJnlLine2.RESET;
        _ItemJnlLine2.SETRANGE("Journal Batch Name", _ItemJnlLine."Journal Batch Name");
        _ItemJnlLine2.SETRANGE("Journal Template Name", _ItemJnlLine."Journal Template Name");
        _ItemJnlLine2.SETfilter("Entry Type", '<>%1', _ItemJnlLine2."Entry Type"::Sale);
        _ItemJnlLine2.SetFilter("Reason Code", '<>%1', 'SALESPOST');
        _ItemJnlLine.SetFilter("External Document No.", '<>%1', channel_P);
        IF _ItemJnlLine2.FINDSET THEN
            _ItemJnlLine2.DeleteAll();

        _ItemJnlLine2.RESET;
        _ItemJnlLine2.SETRANGE("Journal Batch Name", _ItemJnlLine."Journal Batch Name");
        _ItemJnlLine2.SETRANGE("Journal Template Name", _ItemJnlLine."Journal Template Name");
        IF _ItemJnlLine2.FINDSET THEN
            /*IF CODEUNIT.RUN(CODEUNIT::"Item Jnl.-Post Batch", _ItemJnlLine2) THEN begin
            end ELSE BEGIN
                ErrorText_P := GETLASTERRORTEXT;
                _ItemJnlLine2.DELETEALL;
            END;*/
        CLEAR(_ItemJnlLine2);
    end;

    local procedure CreateWhseJnlLines(TemplateName_P: code[10]; BatchName_P: Code[10]; Locationcode_P: Code[10]; ItemNo_P: code[20]; navvariant_P: code[20]; Qty_P: Decimal; Channel_P: code[20])
    var
        _WJnLLine: record "Warehouse Journal Line";
        _WJL: record "Warehouse Journal Line";
        _Location: Record Location;
        _ItemUnitofMeasure: Record "Item Unit of Measure";
        _Bin: Record Bin;
        _AdjBin: Record Bin;
        _Item: Record Item;
        _LineNo: Integer;
        _DocNo: code[20];
    begin
        if _Item.get(ItemNo_P) then;

        IF _Location.GET(Locationcode_P) THEN;

        _Bin.RESET;
        _Bin.SETRANGE("Location Code", Locationcode_P);
        _Bin.SETRANGE(Code, _Location."Default DD Bin");
        IF _Bin.FINDFIRST THEN;

        _AdjBin.RESET;
        _AdjBin.SETRANGE("Location Code", Locationcode_P);
        _AdjBin.SETRANGE(Code, _Location."Adjustment Bin Code");
        IF _AdjBin.FINDFIRST THEN;

        _WJnLLine.SetRange("Journal Template Name", TemplateName_P);
        _WJnLLine.SetRange("Journal Batch Name", BatchName_P);
        if _WJnLLine.FindLast() then
            _LineNo := _WJnLLine."Line No.";
        _LineNo += 10000;

        _DocNo := DELCHR(('DD ' + FORMAT(Today)), '=', '/-');

        _ItemUnitofMeasure.RESET;
        _ItemUnitofMeasure.SETRANGE("Item No.", ItemNo_P);
        _ItemUnitofMeasure.SETRANGE(Code, _Item."Base Unit of Measure");
        IF _ItemUnitofMeasure.FINDFIRST THEN;

        _WJL.Init();
        _WJL.VALIDATE("Journal Template Name", TemplateName_P);
        _WJL.VALIDATE("Journal Batch Name", BatchName_P);
        _WJL.VALIDATE("Line No.", _LineNo);
        _WJL.VALIDATE("Entry Type", _WJL."Entry Type"::"Negative Adjmt.");
        _WJL.VALIDATE("Whse. Document No.", _DocNo + '-' + Channel_P);
        _WJL."Registering Date" := Today;
        _WJL.Validate("Location Code", Locationcode_P);
        _WJL.VALIDATE("Item No.", ItemNo_P);
        _WJL.VALIDATE("Unit of Measure Code", _Item."Base Unit of Measure");
        _WJL.Validate("Variant Code", navvariant_P);
        _WJL.VALIDATE("Zone Code", _Bin."Zone Code");
        _WJL.VALIDATE("Bin Code", _Bin.Code);
        _WJL.VALIDATE("Qty. (Absolute)", ABS(Qty_P));
        _WJL.VALIDATE(Quantity, Qty_P);
        _WJL.VALIDATE("Qty. (Absolute, Base)", ABS(Qty_P * _ItemUnitofMeasure."Qty. per Unit of Measure"));
        _WJL.VALIDATE("Qty. (Base)", Qty_P * _ItemUnitofMeasure."Qty. per Unit of Measure");
        _WJL.VALIDATE("Qty. per Unit of Measure", ABS(_ItemUnitofMeasure."Qty. per Unit of Measure"));
        _WJL.VALIDATE("Reason Code", 'SALESPOST');
        _WJL.VALIDATE("Trade Partner Code", Channel_P);
        _WJL.VALIDATE("From Zone Code", _Bin."Zone Code");
        _WJL.VALIDATE("From Bin Type Code", _Bin."Bin Type Code");
        _WJL.VALIDATE("From Bin Code", _Bin.Code);
        _WJL."To Zone Code" := _AdjBin."Zone Code";
        _WJL."To Bin Code" := _AdjBin.Code;
        _WJL.Insert();

    end;

    local procedure CheckWebSalesInvLines(WebSalesInvNo_P: code[20])
    var
        _CurrBinQty: Decimal;
        _WSInvLines: Record "Web Sales Invoice Line";
    begin

        _WSInvLines.SetRange("Web Sales Invoice No.", WebSalesInvNo_P);
        _WSInvLines.SetRange(Type, _WSInvLines.Type::Item);
        if _WSInvLines.FindSet() then begin
            repeat
                /* _CurrBinQty := CalcStockInBin('SRDC', _WSInvLines."No.", _WSInvLines."Unit of Measure Code", _WSInvLines."NAV Variant code");
                 if (_CurrBinQty < _WSInvLines."Quantity(Base)") then
                     Error('Current Quantity %1 on Bin is less then %2 for Item No. %3 with Variant %4', _CurrBinQty, _WSInvLines."Quantity(Base)",
                      _WSInvLines."No.", _WSInvLines."NAV Variant code");*///CS++

                TempWJL.Init();
                TempWJL.TransferFields(_WSInvLines);
                TempWJL.Insert();
            until _WSInvLines.Next() = 0;
        end;
    end;

    local procedure CalcStockInBin(Locationcode_P: Code[10]; Itemno_P: Code[20]; UOM_P: code[10]; navVariant_P: Code[10]): Decimal
    var
        _CheckItemQty: Query "Get ItemQty By BinContent";
        _Bincontent: Record "Bin Content";
        _Location: Record Location;
        _QtyLeftinBin: Decimal;
    begin
        _Location.Get(Locationcode_P);
        // _CheckItemQty.SetRange(_CheckItemQty.Item_No_, Itemno_P);
        // _CheckItemQty.SetRange(_CheckItemQty.Unit_of_Measure_Code, UOM_P);
        // _CheckItemQty.SetRange(_CheckItemQty.Location_Code, Locationcode_P);
        // _CheckItemQty.SetRange(_CheckItemQty.Bin_Code, _Location."Default Bin Code");
        // _CheckItemQty.Open();
        // If _CheckItemQty.Read() then begin
        //     _QtyLeftinBin := _CheckItemQty.Quantity__Base_;
        // end;
        //_CheckItemQty.Close();
        _Bincontent.SetRange("Location Code", Locationcode_P);
        _Bincontent.SetRange("Bin Code", _Location."Default DD Bin");
        _Bincontent.SetRange("Item No.", Itemno_P);
        _Bincontent.SetRange("Unit of Measure Code", UOM_P);
        _Bincontent.SetRange("Variant Code", navVariant_P);
        if _Bincontent.FindFirst() then begin
            _Bincontent.CalcFields("Quantity (Base)");
            _QtyLeftinBin := _Bincontent."Quantity (Base)";
        end;
        exit(_QtyLeftinBin);
    end;

    procedure CreateNPostWhseJnlLinesForTrolley(TrolleyNo: code[20])
    var
        _channelcode: code[20];
        L_ArchivedScannedLines: Record "Archive Scanned Entries";
        L_ISH: Record "Interim Sales Header";
        L_Locationcode: code[20];
    begin
        L_ArchivedScannedLines.Reset();
        L_ArchivedScannedLines.SetRange("Trolley No", TrolleyNo);
        L_ArchivedScannedLines.SetRange("Warehouse Journal Posted", false);
        L_ArchivedScannedLines.SetRange(Scanned, true);
        if L_ArchivedScannedLines.FindSet() then begin
            DeletePriorWhseLine('ITEM', 'DEFAULT');
            L_Locationcode := GetLocationCode(L_ArchivedScannedLines."Order No");
            repeat
                if _channelcode = '' then
                    _channelcode := L_ArchivedScannedLines."Channel Parter Code";
                CreateWhseJnlLines('ITEM', 'DEFAULT', L_Locationcode, L_ArchivedScannedLines."Item No.", L_ArchivedScannedLines."Variant code", -(L_ArchivedScannedLines.Quantity), L_ArchivedScannedLines."Channel Parter Code");
            until L_ArchivedScannedLines.Next() = 0;
            Commit();
            PostWhseJnlLinesByTrolley('ITEM', 'DEFAULT', L_Locationcode, _channelcode, TrolleyNo);
        end;
    end;

    local procedure GetLocationCode(P_WebOrderNo: Code[20]): Code[20]
    var
        L_ISH: Record "Interim Sales Header";
        L_HISH: Record "Handled Interim Sales Header";
    begin
        L_ISH.Reset;
        L_ISH.SetRange("Document Type", L_ISH."Document Type"::Order);
        L_ISH.SetRange("No.", P_WebOrderNo);
        If L_ISH.FindFirst() then
            exit(L_ISH."Location Code");

        L_HISH.Reset;
        L_HISH.SetRange("Document Type", L_ISH."Document Type"::Order);
        L_HISH.SetRange("No.", P_WebOrderNo);
        If L_HISH.FindFirst() then
            exit(L_HISH."Location Code");
    end;


    procedure CreateandpostItemJournal()
    var
        myInt: Integer;
        Spost: Codeunit 80;
        WsheL: Codeunit "Whse.-Post Shipment";
    begin
        //InsertItemJnlLine
    end;

    local procedure InsertItemJnlLine(var P_WInvHdr: Record "Web Sales Invoice"; var P_WInvLine: Record "Web Sales Invoice Line"; G_GenSetup: Record "General Setup - Channels")
    var
        NextLineNo: Integer;
        ItemJnlPostLine: Codeunit 22;
        ItemJnlLine: Record "Item Journal Line";
        ItemJnlLineError: Record "Item Journal Line";
        TempWhseJnlLine2: Record "Warehouse Journal Line" temporary;
        WhseJnlPostLine: Codeunit "Whse. Jnl.-Register Line";
        TradePartner: Record "Trade Partner";
        L_Cust: Record Customer;
    begin
        //  with ItemJnlLine do begin

        ItemJnlLine."Journal Template Name" := G_GenSetup."Item Journal Template";
        ItemJnlLine."Journal Batch Name" := G_GenSetup."Item Journal Batch";
        if NextLineNo = 0 then begin
            ItemJnlLine.LockTable();
            ItemJnlLine.Reset;
            ItemJnlLine.SetRange("Journal Template Name", ItemJnlLine."Journal Template Name");
            ItemJnlLine.SetRange("Journal Batch Name", ItemJnlLine."Journal Batch Name");
            if ItemJnlLine.Find('+') then
                NextLineNo := ItemJnlLine."Line No.";

        end;
        NextLineNo := NextLineNo + 10000;
        ItemJnlLine.Init;
        ItemJnlLine."Line No." := NextLineNo;
        ItemJnlLine.Validate("Posting Date", P_WInvHdr."Posting Date");

        ItemJnlLine.Validate("Entry Type", ItemJnlLine."Entry Type"::Sale);
        ItemJnlLine.Validate("Document No.", P_WInvHdr."Web Sales Invoice No.");
        ItemJnlLine.Validate("Item No.", P_WInvLine."No.");
        ItemJnlLine.Validate("Variant Code", P_WInvLine."NAV Variant code");
        ItemJnlLine.Validate("Location Code", P_WInvHdr."Location Code");
        ItemJnlLine.Validate("Source Code", '');
        ItemJnlLine.Validate("Unit of Measure Code", P_WInvLine."Unit of Measure Code");
        // "Posting No. Series" := ItemJnlBatch."Posting No. Series";
        ItemJnlLine.Validate(Quantity, P_WInvLine.Quantity);
        ItemJnlLine."Quantity (Base)" := P_WInvLine."Quantity(Base)";
        ItemJnlLine."Invoiced Qty. (Base)" := P_WInvLine."Quantity(Base)";
        ItemJnlLine.VALIDATE("Reason Code", 'SALESPOST');
        ItemJnlLine.VALIDATE("External Document No.", DELCHR(('DD ' + FORMAT(P_WInvHdr."Posting Date")), '=', '/-'));
        ;
        ItemJnlLine.Validate("Unit Amount", P_WInvLine."Unit Price");
        ItemJnlLine.Validate(Amount, P_WInvLine.Amount);
        ItemJnlLine."Warehouse Adjustment" := false;
        TradePartner.Get(P_WInvHdr."Trade Partner Code");
        L_Cust.get(TradePartner."Customer No.");
        ItemJnlLine."Source No." := L_Cust."No.";
        ItemJnlLine.Validate("Shortcut Dimension 1 Code", L_Cust."Global Dimension 1 Code");
        ItemJnlLine.Validate("Shortcut Dimension 2 Code", L_Cust."Global Dimension 2 Code");
        ItemJnlLine.Insert(true);

        CreateWhseJnlLine(ItemJnlLine, TempWhseJnlLine2, P_WInvLine);
        Commit();


        If ItemJnlPostLine.Run(ItemJnlLine) then begin
            P_WInvHdr."Stock Posted" := true;
            P_WInvHdr.Modify();
            P_WInvLine."Stock Posted" := true;
            P_WInvLine.Modify();
        end Else begin
            P_WInvHdr."Stock Posted" := false;
            P_WInvHdr."Processing Error" := GetLastErrorText();
            TempWhseJnlLine2.DeleteAll();
            ItemJnlLineError.SetRange("Journal Template Name", G_GenSetup."Item Journal Template");
            ItemJnlLineError.SetRange("Journal Batch Name", G_GenSetup."Item Journal Batch");
            ItemJnlLineError.DeleteAll();
            P_WInvHdr.Modify();
        end;

        TempWhseJnlLine2.Reset();
        if TempWhseJnlLine2.FindSet() then
            repeat
                WhseJnlPostLine.Run(TempWhseJnlLine2);
            until TempWhseJnlLine2.Next() = 0;

    end;


    procedure CreateWhseJnlLine(ItemJnlLine: Record "Item Journal Line"; var TempWhseJnlLine: Record "Warehouse Journal Line" temporary; WebInvoiceLine: Record "Web Sales Invoice Line")
    var
        WhseMgt: Codeunit "Whse. Management";
        WMSMgt: Codeunit "WMS Management";
        IsHandled: Boolean;
        Location: Record Location;
    begin
        If Location.get('SRDC') then;
        WMSMgt.CheckAdjmtBin(Location, ItemJnlLine.Quantity, true);
        WMSMgt.CreateWhseJnlLine(ItemJnlLine, 0, TempWhseJnlLine, false);
        TempWhseJnlLine."Source Type" := DATABASE::"Web Sales Invoice Line";
        //TempWhseJnlLine."Source Subtype" := "Document Type".AsInteger();
        //TempWhseJnlLine."Source Code" := SrcCode;
        //TempWhseJnlLine."Source Document" := WhseMgt.GetWhseJnlSourceDocument(TempWhseJnlLine."Source Type", TempWhseJnlLine."Source Subtype");
        TempWhseJnlLine."Source No." := WebInvoiceLine."Web Sales Invoice No.";
        TempWhseJnlLine."Source Line No." := WebInvoiceLine."Line No.";
        TempWhseJnlLine."Reference No." := ItemJnlLine."External Document No.";
        TempWhseJnlLine.Insert();
    end;


    procedure ProcessItemJournalPosting(WebSalesInvNo_P: code[20])//CS++
    var
        _WSInvHdr: record "Web Sales Invoice";
        _PostErr: Label 'Document already Posted, Posting Aborted';
        _ItemJnlBatch: record "Item Journal Batch";
        L_WSInvLine: Record "Web Sales Invoice Line";
    begin
        GetSetup.Get();
        GetSetup.TestField("Item Journal Template");
        Getsetup.TestField("Item Journal Batch");
        _WSInvHdr.get(WebSalesInvNo_P);

        if _ItemJnlBatch.get(GetSetup."Item Journal Template", GetSetup."Item Journal Batch") then begin
            If (_ItemJnlBatch."No. Series" <> '') then
                Error('No. series must be blank on Batch Name %1', _ItemJnlBatch.Name);
        end;

        L_WSInvLine.Reset();
        L_WSInvLine.SetRange("Web Sales Invoice No.", WebSalesInvNo_P);
        L_WSInvLine.SetRange(Type, L_WSInvLine.Type::Item);
        L_WSInvLine.SetRange("Stock Posted", false);
        If L_WSInvLine.FindSet() then
            repeat
                if not CheckLineData(L_WSInvLine) then
                    InsertItemJnlLine(_WSInvHdr, L_WSInvLine, GetSetup);
            until L_WSInvLine.Next() = 0;

    end;

    procedure CheckHeaderData(WebSalesInvNo_P: code[20]): Boolean
    var
        L_WSInvHdr: record "Web Sales Invoice";
        L_WSInvLine: Record "Web Sales Invoice Line";
        L_tradepartner: Record "Trade Partner";
        L_cust: Record Customer;
        salespos: Codeunit "Sales-Post (Yes/No)";
        UserSetupManagement: Codeunit "User Setup Management";
        SetupRecordID: RecordID;
        L_GenSetup_Channel: Record "General Setup - Channels";
        BankAcc: Record "Bank Account";
        errorlog: Record "Incoming/Outgoing Error Log";
        HandledWebH: Record "Handled Interim Sales Header";
        paymentDetail: Record "Channel Media";
        webpaymentMethod: Record "Web Payment";
    begin
        errorlog.Reset();
        errorlog.SetRange("Document No.", WebSalesInvNo_P);
        if errorlog.FindSet() then
            errorlog.DeleteAll();
        if L_WSInvHdr.Get(WebSalesInvNo_P) then begin
            L_cust.get(L_WSInvHdr."Bill-to Customer No.");
            if L_cust.Blocked <> L_cust.Blocked::" " then
                errorgeneraed := InsertErrorLog(StrSubstNo('You can not post this document because customer %1 is blocked.', L_cust."No."), L_WSInvHdr."Web Sales Invoice No.");

            if L_cust."Gen. Bus. Posting Group" = '' then
                errorgeneraed := InsertErrorLog(StrSubstNo('Gen. Bus. Posting Group must not be blank for customer %1.', L_cust."No."), L_WSInvHdr."Web Sales Invoice No.");

            if L_cust."VAT Bus. Posting Group" = '' then
                errorgeneraed := InsertErrorLog(StrSubstNo('VAT Bus. Posting Group must not be blank for customer %1.', L_cust."No."), L_WSInvHdr."Web Sales Invoice No.");

            if L_cust."Customer Posting Group" = '' then
                errorgeneraed := InsertErrorLog(StrSubstNo('Customer Posting Group must not be blank for customer %1.', L_cust."No."), L_WSInvHdr."Web Sales Invoice No.");

            if not UserSetupManagement.IsPostingDateValidWithSetup(L_WSInvHdr."Posting Date", SetupRecordID) then
                errorgeneraed := InsertErrorLog('Posting date is not allowed', L_WSInvHdr."Web Sales Invoice No.");

            L_GenSetup_Channel.Get();
            L_tradepartner.Get(L_WSInvHdr."Trade Partner Code");

            if (L_tradepartner."Post auto payment") then begin
                if L_tradepartner."Bank Account Code" = '' then
                    errorgeneraed := InsertErrorLog(StrSubstNo('Bank Account Code must not be blank for channel code %1 if auto post payment is enable', L_tradepartner.Code), L_WSInvHdr."Web Sales Invoice No.")
                else begin
                    BankAcc.get(L_tradepartner."Bank Account Code");
                    if BankAcc."Bank Acc. Posting Group" = '' then
                        errorgeneraed := InsertErrorLog(StrSubstNo('Bank Account posting group must not be blank for bank account %1', BankAcc."No."), L_WSInvHdr."Web Sales Invoice No.");
                    if BankAcc.Blocked then
                        errorgeneraed := InsertErrorLog(StrSubstNo('Bank Account %1 is bloked', BankAcc."No."), L_WSInvHdr."Web Sales Invoice No.");
                    if L_GenSetup_Channel."Cash Rct Template Name" = '' then
                        errorgeneraed := InsertErrorLog(StrSubstNo('Cash Rct Template Name must not be blank for Channel %1', L_tradepartner.Code), L_WSInvHdr."Web Sales Invoice No.");
                    if L_GenSetup_Channel."Cash Rct Batch Name" = '' then
                        errorgeneraed := InsertErrorLog(StrSubstNo('Cash Rct Batch Name must not be blank for Channel %1', L_tradepartner.Code), L_WSInvHdr."Web Sales Invoice No.");

                    HandledWebH.Reset();
                    HandledWebH.SetRange("Invoice No.", L_WSInvHdr."Web Sales Invoice No.");
                    if HandledWebH.FindSet() then
                        repeat
                            paymentDetail.Reset();
                            paymentDetail.SetRange("channel code", L_WSInvHdr."Trade Partner Code");
                            paymentDetail.SetRange("Channel Order ID", HandledWebH."Channel Order ID");
                            if paymentDetail.FindSet() then
                                repeat
                                    paymentDetail.Mark(true);
                                until paymentDetail.Next() = 0;
                        until HandledWebH.Next() = 0;

                    paymentDetail.MarkedOnly(true);
                    paymentDetail.SetCurrentKey("Payment Method");
                    if paymentDetail.FindFirst() then
                        repeat
                            webpaymentMethod.Reset();
                            webpaymentMethod.SetRange("Channel Code", paymentDetail."Channel Code");
                            webpaymentMethod.SetRange("Web Payment Method", paymentDetail."Payment Method");
                            if NOT webpaymentMethod.FindFirst() then
                                errorgeneraed := InsertErrorLog(StrSubstNo('Web payment Method is not setup for Channel code %1, Web Payment Method %2', L_tradepartner.Code, paymentDetail."Payment Method"), L_WSInvHdr."Web Sales Invoice No.");
                            paymentDetail.SetRange("Payment Method", paymentDetail."Payment Method");
                            paymentDetail.FindLast();
                            paymentDetail.SetRange("Payment Method");
                        until paymentDetail.Next() = 0;
                end;
            end;


            if (L_tradepartner."Positng G/L No." = '') and (L_GenSetup_Channel."Invoice G/L No." = '') then
                errorgeneraed := InsertErrorLog(StrSubstNo('G/L Account Code must not be blank. Please updae for channel code %1 if auto post payment is enable', L_tradepartner.Code), L_WSInvHdr."Web Sales Invoice No.");

            if L_tradepartner."Positng G/L No." <> '' then
                errorgeneraed := CheckGLaccount(L_tradepartner."Positng G/L No.", L_WSInvHdr."Web Sales Invoice No.");

            if L_GenSetup_Channel."Invoice G/L No." <> '' then
                errorgeneraed := CheckGLaccount(L_GenSetup_Channel."Invoice G/L No.", L_WSInvHdr."Web Sales Invoice No.");

            L_WSInvLine.reset;
            L_WSInvLine.SetRange("Web Sales Invoice No.", L_WSInvHdr."Web Sales Invoice No.");
            if L_WSInvLine.Count = 0 then
                errorgeneraed := InsertErrorLog('There is nothing to post.', L_WSInvHdr."Web Sales Invoice No.");
        end;
        exit(errorgeneraed);
    end;

    procedure CheckLineData(var P_WSInvLine: Record "Web Sales Invoice Line"): Boolean
    var
        L_item: Record Item;
    begin
        case P_WSInvLine.Type of
            P_WSInvLine.Type::Item:
                begin
                    L_item.Get(P_WSInvLine."No.");
                    if L_item.Blocked then
                        errorgeneraed := InsertErrorLog(StrSubstNo('Item no %1 is blocked.', L_item."No."), P_WSInvLine."Web Sales Invoice No.");

                end;
            P_WSInvLine.Type::"G/L Account":
                begin
                    errorgeneraed := CheckGLaccount(P_WSInvLine."No.", P_WSInvLine."Web Sales Invoice No.");
                end;
        end
    end;

    local procedure CheckGLaccount(P_GLAccount: Code[20]; P_webinv: Code[20]): Boolean
    var
        GLAccount: Record "G/L Account";
    begin
        if GLAccount.Get(P_GLAccount) then begin
            if GLAccount.Blocked then
                errorgeneraed := InsertErrorLog(StrSubstNo('G/L Account no %1 is blocked', P_GLAccount), P_webinv);
            if not GLAccount."Direct Posting" then
                errorgeneraed := InsertErrorLog(StrSubstNo('Direct posting must be equal to yes in G/L account %1', P_GLAccount), P_webinv);
        end else
            errorgeneraed := InsertErrorLog(StrSubstNo('G/L Account no %1 doen not exists.', P_GLAccount), P_webinv);

        exit(errorgeneraed);
    end;

    procedure InsertErrorLog(P_Text: Text[250]; var P_WebinvNo: Code[20]): Boolean
    var
        ErrorLog: Record "Incoming/Outgoing Error Log";
        L_ErrorLog: Record "Incoming/Outgoing Error Log";
    begin
        ErrorLog.INIT;
        ErrorLog."Document No." := P_WebinvNo;
        ErrorLog.Date := WORKDATE;

        ErrorLog.RESET;
        L_ErrorLog.SETRANGE("Document No.", P_WebinvNo);
        IF L_ErrorLog.FINDLAST THEN
            ErrorLog."Line No." := L_ErrorLog."Line No." + 10000
        ELSE
            ErrorLog."Line No." := 10000;

        ErrorLog."Error Text" := P_Text;
        ErrorLog.INSERT;

        exit(true);
    end;

    var
        TempWJL: record "Web Sales Invoice Line" temporary;
        GlobalLine: Integer;
        GetSetup: record "General Setup - Channels";
        errorgeneraed: Boolean;
}
