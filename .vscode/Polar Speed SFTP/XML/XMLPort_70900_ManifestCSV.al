/// <summary>
/// XmlPort Manifest (ID 70900).
/// </summary>
xmlport 90034 Manifest
{
    Caption = 'Export Manifest File';
    DefaultFieldsValidation = false;
    Direction = Export;
    TableSeparator = '<NewLine>';   // rows = \r\n
    FieldSeparator = ',';        // columns = ,
    FieldDelimiter = '"';
    RecordSeparator = '<NewLine>';
    Format = VariableText;
    TextEncoding = WINDOWS;
    UseRequestPage = false;
    //FileName = 'Sigma.CSV';



    schema
    {
        textelement(Root)
        {
            tableelement(Integer; Integer)
            {
                SourceTableView = SORTING(Number) WHERE(Number = CONST(1));
                textelement("REFERENCE")
                {
                }
                textelement("BARCODE")
                {
                }
                textelement("SERVICE")
                {
                }
                textelement("TEMPERATURE")
                {
                }
                textelement("TRANSITUNIT")
                {
                }
                textelement("TASK")
                {
                }
                textelement("WEIGHT")
                {
                }
                textelement("DATE")
                {
                }
                textelement("ARRIVALDATE")
                {
                }
                textelement("FTAO")
                {
                }
                textelement("ADDRESS1")
                {
                }
                textelement("ADDRESS2")
                {
                }
                textelement("ADDRESS3")
                {
                }
                textelement("ADDRESS4")
                {
                }
                textelement("ADDRESS5")
                {
                }
                textelement("POSTALCODE")
                {
                }
                textelement("COUNTRY")
                {
                }
                textelement("NOTES")
                {
                }
                textelement("TELEPHONE")
                {
                }
                textelement("DESCRIPTION")
                {
                }
                textelement("CLIENTINFO1")
                {
                }
                textelement("CLIENTINFO2")
                {
                }
                textelement("CLIENTINFO3")
                {
                }
                textelement("CLIENTINFO4")
                {
                }
                textelement("CLIENTINFO5")
                {
                }
                textelement("SMS")
                {
                }
                textelement("EMAIL")
                {
                }
                trigger OnAfterGetRecord()
                var
                begin
                    "REFERENCE" := 'REFERENCE';
                    "BARCODE" := 'BARCODE';
                    "SERVICE" := 'SERVICE';
                    "TEMPERATURE" := 'TEMPERATURE';
                    "TRANSITUNIT" := 'TRANSITUNIT';
                    "TASK" := 'TASK';
                    "WEIGHT" := 'WEIGHT';
                    "DATE" := 'DATE';
                    "ARRIVALDATE" := 'ARRIVALDATE';
                    "FTAO" := 'FTAO';
                    "ADDRESS1" := 'ADDRESS1';
                    "ADDRESS2" := 'ADDRESS2';
                    "ADDRESS3" := 'ADDRESS3';
                    "ADDRESS4" := 'ADDRESS4';
                    "ADDRESS5" := 'ADDRESS5';
                    "POSTALCODE" := 'POSTALCODE';
                    "COUNTRY" := 'COUNTRY';
                    "NOTES" := 'NOTES';
                    "TELEPHONE" := 'TELEPHONE';
                    "DESCRIPTION" := 'DESCRIPTION';
                    "CLIENTINFO1" := 'CLIENTINFO1';
                    "CLIENTINFO2" := 'CLIENTINFO2';
                    "CLIENTINFO3" := 'CLIENTINFO3';
                    "CLIENTINFO4" := 'CLIENTINFO4';
                    "CLIENTINFO5" := 'CLIENTINFO5';
                    "SMS" := 'SMS';
                    "EMAIL" := 'EMAIL';


                end;

            }
            tableelement(PostedSalesInvoice; "Sales Invoice Header")
            {
                textelement("_REFERENCE")
                {

                }
                textelement("_BARCODE")
                {

                }
                textelement("_SERVICE")
                {

                }
                textelement("_TEMPERATURE")
                {

                }
                textelement("_TRANSITUNIT")
                {

                }
                textelement("_TASK")
                {

                }
                textelement("_WEIGHT")
                {

                }
                textelement("_DATE")
                {

                }
                textelement("_ARRIVALDATE")
                {

                }
                textelement("_FTAO")
                {

                }
                textelement("_ADDRESS1")
                {

                }
                textelement("_ADDRESS2")
                {

                }
                textelement("_ADDRESS3")
                {

                }
                textelement("_ADDRESS4")
                {

                }
                textelement("_ADDRESS5")
                {

                }
                textelement("_POSTALCODE")
                {

                }
                textelement("_COUNTRY")
                {

                }
                textelement("_NOTES")
                {

                }
                textelement("_TELEPHONE")
                {

                }
                textelement("_DESCRIPTION")
                {

                }
                textelement("_CLIENTINFO1")
                {

                }
                textelement("_CLIENTINFO2")
                {

                }
                textelement("_CLIENTINFO3")
                {

                }
                textelement("_CLIENTINFO4")
                {

                }
                textelement("_CLIENTINFO5")
                {

                }
                textelement("_SMS")
                {

                }
                textelement("_EMAIL")
                {

                }

                trigger OnPreXmlItem()
                begin
                    PostedSalesInvoice.SetRange("Shipping Agent Code", 'PS');
                    PostedSalesInvoice.SetFilter("Location Code", '%1|%2', 'KNAPP', 'DEPOT1');
                    if G_ShipmentDate <> 0D then begin
                        PostedSalesInvoice.SetRange("Shipment Date", G_ShipmentDate);
                        //PostedSalesInvoice.SetFilter("No.", '%1', '5001996020');
                    end;
                end;

                trigger OnAfterGetRecord()
                var
                    Tbl_SIL: Record "Sales Invoice Line";
                    Tbl_KOR: Record "Knapp Order Response";
                    Tbl_Itm: Record Item;
                    Tbl_TR: Record "Temperature Range";
                    Tbl_IUM: Record "Item Unit of Measure";
                    DistinctLoadUnits: Dictionary of [Text, Integer];
                    i: Integer;
                    Tbl_WarehouseClasses: Record "Warehouse Class";
                    Tbl_Barcode: Record "Polar Speed Barcode";
                // CRLF: Text[2];
                begin
                    // CRLF[1] := 13;
                    // CRLF[2] := 10;
                    Tbl_SIL.Reset();
                    Tbl_SIL.SetFilter("Document No.", PostedSalesInvoice."No.");
                    if Tbl_SIL.FindSet() THEN begin
                        repeat
                            Tbl_KOR.Reset();
                            Tbl_KOR.SetRange("Document No.", PostedSalesInvoice."Order No.");
                            Tbl_KOR.SetRange("Document Type", Tbl_KOR."Document Type"::Order);
                            Tbl_KOR.SetRange("Item No.", Tbl_SIL."No.");
                            if Tbl_KOR.FindSet() then begin
                                repeat
                                    if not DistinctLoadUnits.ContainsKey(Tbl_KOR."Load Unit") then begin
                                        i := i + 1;
                                        DistinctLoadUnits.Add(Tbl_KOR."Load Unit", i);
                                        _CLIENTINFO1 := Tbl_KOR."Load Unit";
                                        _CLIENTINFO2 := '';
                                        _CLIENTINFO3 := '';
                                        _CLIENTINFO4 := '';
                                        _CLIENTINFO5 := '';
                                        _REFERENCE := Format(Tbl_SIL."Document No.");
                                        _BARCODE := GetBarcodeNumber(Tbl_SIL."Document No.", Tbl_KOR."Load Unit", PostedSalesInvoice."Order No.");
                                        _SERVICE := GetServiceCode(PostedSalesInvoice."Ship-to Post Code");
                                        Tbl_Itm.Reset();
                                        Tbl_Itm.SetRange("No.", Tbl_SIL."No.");
                                        Tbl_Itm.SetFilter("Warehouse Class Code", '<>%1', '');
                                        if Tbl_Itm.FindFirst() then begin
                                            Tbl_WarehouseClasses.Reset();
                                            Tbl_WarehouseClasses.SetRange(Code, Tbl_Itm."Warehouse Class Code");
                                            Tbl_WarehouseClasses.SetRange(Fridge, true);
                                            if Tbl_WarehouseClasses.FindFirst() then begin
                                                _TEMPERATURE := 'Chilled';
                                            end
                                            else begin
                                                _TEMPERATURE := 'Ambient';
                                            end;
                                        end
                                        else begin
                                            _TEMPERATURE := 'Ambient';
                                        end;

                                        _TRANSITUNIT := 'BOX';
                                        if (G_ShipmentDate <> G_ShipmentNextDate) then begin
                                            _TASK := 'Collection';
                                        end
                                        else begin
                                            _TASK := '';
                                        end;


                                        Tbl_IUM.Reset();
                                        Tbl_IUM.SetFilter(Code, Tbl_Itm."Base Unit of Measure");
                                        if Tbl_IUM.FindFirst() then begin
                                            _WEIGHT := Format(Tbl_IUM.Weight);
                                        end
                                        else begin
                                            _WEIGHT := '';
                                        end;
                                        _DATE := Format(PostedSalesInvoice."Shipment Date");
                                        _ARRIVALDATE := Format(CalcDate('-1D', PostedSalesInvoice."Shipment Date"));
                                        _FTAO := PostedSalesInvoice."Ship-to Name";
                                        _ADDRESS1 := PostedSalesInvoice."Ship-to Address";
                                        _ADDRESS2 := PostedSalesInvoice."Ship-to Address 2";
                                        _ADDRESS3 := '';
                                        _ADDRESS4 := '';
                                        _ADDRESS5 := '';
                                        _POSTALCODE := PostedSalesInvoice."Ship-to Post Code";
                                        _COUNTRY := PostedSalesInvoice."Ship-to Country/Region Code";
                                        _NOTES := '';
                                        _TELEPHONE := PostedSalesInvoice."Ship-to Phone No.";
                                        _DESCRIPTION := '';
                                        _SMS := PostedSalesInvoice."Ship-to Phone No.";
                                        _EMAIL := PostedSalesInvoice."Sell-to E-Mail";
                                        ;
                                    end;
                                until Tbl_KOR.Next() = 0;
                            end
                            else begin
                                _CLIENTINFO1 := '';
                                _CLIENTINFO2 := '';
                                _CLIENTINFO3 := '';
                                _CLIENTINFO4 := '';
                                _CLIENTINFO5 := '';
                                _REFERENCE := Format(Tbl_SIL."Document No.");
                                _BARCODE := GetBarcodeNumber(Tbl_SIL."Document No.", Tbl_KOR."Load Unit", PostedSalesInvoice."Order No.");
                                _SERVICE := GetServiceCode(PostedSalesInvoice."Ship-to Post Code");
                                Tbl_Itm.Reset();
                                Tbl_Itm.SetRange("No.", Tbl_SIL."No.");
                                Tbl_Itm.SetFilter("Warehouse Class Code", '<>%1', '');
                                if Tbl_Itm.FindFirst() then begin
                                    Tbl_WarehouseClasses.Reset();
                                    Tbl_WarehouseClasses.SetRange(Code, Tbl_Itm."Warehouse Class Code");
                                    Tbl_WarehouseClasses.SetRange(Fridge, true);
                                    if Tbl_WarehouseClasses.FindFirst() then begin
                                        _TEMPERATURE := 'Chilled';
                                    end
                                    else begin
                                        _TEMPERATURE := 'Ambient';
                                    end;
                                end
                                else begin
                                    _TEMPERATURE := 'Ambient';
                                end;

                                _TRANSITUNIT := 'BOX';
                                if (G_ShipmentDate <> G_ShipmentNextDate) then begin
                                    _TASK := 'Collection';
                                end
                                else begin
                                    _TASK := '';
                                end;

                                Tbl_IUM.Reset();
                                Tbl_IUM.SetFilter(Code, Tbl_Itm."Base Unit of Measure");
                                if Tbl_IUM.FindFirst() then begin
                                    _WEIGHT := Format(Tbl_IUM.Weight);
                                end
                                else begin
                                    _WEIGHT := '';
                                end;
                                _DATE := Format(PostedSalesInvoice."Shipment Date");
                                _ARRIVALDATE := Format(CalcDate('-1D', PostedSalesInvoice."Shipment Date"));
                                _FTAO := PostedSalesInvoice."Ship-to Name";
                                _ADDRESS1 := PostedSalesInvoice."Ship-to Address";
                                _ADDRESS2 := PostedSalesInvoice."Ship-to Address 2";
                                _ADDRESS3 := '';
                                _ADDRESS4 := '';
                                _ADDRESS5 := '';
                                _POSTALCODE := PostedSalesInvoice."Ship-to Post Code";
                                _COUNTRY := PostedSalesInvoice."Ship-to Country/Region Code";
                                _NOTES := '';
                                _TELEPHONE := PostedSalesInvoice."Ship-to Phone No.";
                                _DESCRIPTION := '';
                                _SMS := PostedSalesInvoice."Ship-to Phone No.";
                                _EMAIL := PostedSalesInvoice."Sell-to E-Mail";
                                ;
                            end;
                        until Tbl_SIL.Next() = 0;
                    end;
                end;

            }
        }

    }
    var
        RecordCount: Integer;
        G_ShipmentDate: Date;
        G_ShipmentNextDate: Date;
        G_Barcode: Text;

    /// <summary>
    /// GetFilters.
    /// </summary>
    /// <param name="_ShipmentDate">Date.</param>
    procedure GetFilters(_ShipmentDate: Date; i: Integer)
    begin
        Clear(G_ShipmentDate);
        G_ShipmentDate := _ShipmentDate;
        if i = 0 then begin
            G_ShipmentNextDate := G_ShipmentDate;
        end else
            G_ShipmentNextDate := CalcDate('<' + '1D>', _ShipmentDate);
    end;

    procedure GetBarcodeNumber(_DocumentNo: Text; _LoadUnit: Text; OrderNo: Code[20]): Text
    var
        Tbl_Barcode: Record "Polar Speed Barcode";
        L_SalesInvoiceLine: Record "Sales Invoice Line";
        L_ValueEntry: Record "Value Entry";
        L_ItemLedgEntry: Record "Item Ledger Entry";
        L_SalesShipmentHeader: Record "Sales Shipment Header";

        L_Barcode: Record "Polar Speed Barcode";

        KnappResponse: Record "Knapp Order Response";

        BarcodeString: Text;
        QRcodeString: Text;
        BarcodeSymbology: Enum "Barcode Symbology";
        BarcodeFontProvider: Interface "Barcode Font Provider";
        QRcodeSymbology: Enum "Barcode Symbology 2D";
        QRFontProvider: Interface "Barcode Font Provider 2D";
        NoSeriesMgt: Codeunit "No. Series";

    begin
        Clear(G_Barcode);
        Tbl_Barcode.Reset();
        Tbl_Barcode.SetRange("Sales Invoice No.", _DocumentNo);
        Tbl_Barcode.SetRange("Tote No.", _LoadUnit);
        if Tbl_Barcode.FindLast() then begin
            G_Barcode := Tbl_Barcode."Barcode No.";
        end else begin
            L_SalesInvoiceLine.Reset();
            L_SalesInvoiceLine.SetRange("Document No.", _DocumentNo);
            L_SalesInvoiceLine.SetFilter(Quantity, '>%1', 0);
            L_SalesInvoiceLine.SetRange(Type, L_SalesInvoiceLine.Type::Item);
            L_SalesInvoiceLine.SetRange("Location Code", '<>%1', 'KNAAP');
            if L_SalesInvoiceLine.FindFirst() then begin
                Clear(Boxes);
                L_ValueEntry.Reset();
                L_ValueEntry.SetCurrentKey("Document No.");
                L_ValueEntry.SetRange("Document No.", L_SalesInvoiceLine."Document No.");
                L_ValueEntry.SetRange("Document Type", L_ValueEntry."Document Type"::"Sales Invoice");
                L_ValueEntry.SetRange("Document Line No.", L_SalesInvoiceLine."Line No.");
                if L_ValueEntry.FindFirst() then begin
                    repeat
                        if Boxes <> 0 then
                            break;
                        L_ItemLedgEntry.Get(L_ValueEntry."Item Ledger Entry No.");
                        if L_ItemLedgEntry."Document Type" = L_ItemLedgEntry."Document Type"::"Sales Shipment" then
                            if L_SalesShipmentHeader.Get(L_ItemLedgEntry."Document No.") then begin
                                Boxes := L_SalesShipmentHeader."No of Boxes";
                            end;
                    until L_ValueEntry.Next() = 0;
                end;

                if Boxes > 0 then
                    LabelCount := Boxes
                else
                    LabelCount := 1;

                // L_Barcode.Reset();
                // L_Barcode.SetRange("Sales Invoice No", "Sales Invoice Header"."No.");
                // if not FindFirst() then begin
                // if "Sales Invoice Header"."Barcode Generated" = false then begin
                G_Boxes := 1;
                for countt := 1 to LabelCount do begin
                    L_Barcode.Init();
                    L_Barcode."Entry No." := getlastentryno();
                    L_Barcode."Sales Invoice No." := _DocumentNo;
                    L_Barcode."Tote No." := '';
                    L_Barcode."Box No." := G_Boxes;
                    G_Boxes := G_Boxes + 1;
                    UniqueBarcodeNo := NoSeriesMgt.GetNextNo('IPICK', WorkDate(), true);

                    // Barcode from Invoice Order No.
                    //BarcodeString := "Sales Invoice Header"."No.";
                    BarcodeFontProvider := Enum::"Barcode Font Provider"::IDAutomation1D;
                    BarcodeSymbology := Enum::"Barcode Symbology"::Code39;
                    EncodedText := BarcodeFontProvider.EncodeFont(UniqueBarcodeNo, BarcodeSymbology);

                    // QR from Invoice Order No.
                    //QRcodeString := "Sales Invoice Header"."No.";
                    QRFontProvider := Enum::"Barcode Font Provider 2D"::IDAutomation2D;
                    QRcodeSymbology := Enum::"Barcode Symbology 2D"::"QR-Code";
                    QREncodeText := QRFontProvider.EncodeFont(UniqueBarcodeNo, QRcodeSymbology);

                    L_Barcode.Barcode := EncodedText;
                    L_Barcode."Barcode No." := UniqueBarcodeNo;
                    L_Barcode.Insert();
                end;
            end else begin

                Clear(LoadUnitList);
                KnappResponse.Reset();
                KnappResponse.SetRange("Document No.", OrderNo);
                KnappResponse.SetRange("Document Type", KnappResponse."Document Type"::Order);
                if KnappResponse.FindSet() then
                    repeat
                        if not LoadUnitList.Contains(KnappResponse."Load Unit") then
                            LoadUnitList.Add(KnappResponse."Load Unit");

                    until KnappResponse.Next() = 0;
                LabelCount := LoadUnitList.Count();

                G_Tote := 1;
                for countt := 1 to LabelCount do begin
                    L_Barcode.Init();
                    L_Barcode."Entry No." := getlastentryno();
                    L_Barcode."Sales Invoice No." := _DocumentNo;
                    L_Barcode."Tote No." := LoadUnitList.Get(G_Tote);
                    G_Tote := G_Tote + 1;
                    L_Barcode."Box No." := 0;
                    UniqueBarcodeNo := NoSeriesMgt.GetNextNo('IPICK', WorkDate(), true);

                    // Barcode from Invoice Order No.
                    //BarcodeString := "Sales Invoice Header"."No.";
                    BarcodeFontProvider := Enum::"Barcode Font Provider"::IDAutomation1D;
                    BarcodeSymbology := Enum::"Barcode Symbology"::Code39;
                    EncodedText := BarcodeFontProvider.EncodeFont(UniqueBarcodeNo, BarcodeSymbology);

                    // QR from Invoice Order No.
                    //QRcodeString := "Sales Invoice Header"."No.";
                    QRFontProvider := Enum::"Barcode Font Provider 2D"::IDAutomation2D;
                    QRcodeSymbology := Enum::"Barcode Symbology 2D"::"QR-Code";
                    QREncodeText := QRFontProvider.EncodeFont(UniqueBarcodeNo, QRcodeSymbology);

                    L_Barcode.Barcode := EncodedText;
                    L_Barcode."Barcode No." := UniqueBarcodeNo;
                    L_Barcode.Insert();
                end;
            end;
            G_Barcode := UniqueBarcodeNo;
        end;
        exit(G_Barcode)
    end;

    procedure GetServiceCode(_SearchPostCode: Text): Text
    var
        Tbl_RoutingCode: Record "PS Route Setup";
        ShippingService: Text;
    begin
        Clear(ShippingService);
        Tbl_RoutingCode.Reset();
        while _SearchPostCode <> '' do begin
            Tbl_RoutingCode.SetRange(Postcode, _SearchPostCode);
            if Tbl_RoutingCode.FindFirst() then begin
                ShippingService := Tbl_RoutingCode.Service;
                exit;
            end;
            _SearchPostCode := CopyStr(_SearchPostCode, 1, StrLen(_SearchPostCode) - 1);
            Tbl_RoutingCode.Reset();
        end;
    end;

    local procedure getlastentryno(): Integer
    var
        barcode: Record "Polar Speed Barcode";
    begin
        barcode.Reset();
        IF barcode.FINDLAST THEN
            exit(barcode."Entry No." + 1)
        ELSE
            exit(1);
    end;

    var
        Boxes: Integer;
        G_Boxes: Integer;
        G_Tote: Integer;
        AreaCode: Text[20];
        UniqueBarcodeNo: Text[25];
        UniqueBarcodeNo1: Text[25];
        countt: Integer;

        EncodedText: Text;
        QREncodeText: Text;
        LabelCount: Integer;
        LoadUnitList: List of [Code[500]];

}