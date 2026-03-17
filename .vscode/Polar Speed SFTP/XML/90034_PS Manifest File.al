xmlport 90034 "PS Manifest File"
{
    Caption = 'Export Manifest File';
    DefaultFieldsValidation = false;
    Direction = Export;
    TableSeparator = '<NewLine>';
    FieldSeparator = ',';
    FieldDelimiter = '"';
    RecordSeparator = '<NewLine>';
    Format = VariableText;
    TextEncoding = WINDOWS;
    UseRequestPage = false;



    schema
    {
        textelement(Root)
        {
            tableelement(ExcelHeader; Integer)
            {
                SourceTableView = SORTING(Number) WHERE(Number = CONST(1));
                textelement(REFERENCE)
                {
                }
                textelement(BARCODE)
                {
                }
                textelement(SERVICE)
                {
                }
                textelement(TEMPERATURE)
                {
                }
                textelement(TRANSITUNIT)
                {
                }
                textelement(TASK)
                {
                }
                textelement(WEIGHT)
                {
                }
                textelement(DATE)
                {
                }
                textelement(ARRIVALDATE)
                {
                }
                textelement(FTAO)
                {
                }
                textelement(ADDRESS1)
                {
                }
                textelement(ADDRESS2)
                {
                }
                textelement(ADDRESS3)
                {
                }
                textelement(ADDRESS4)
                {
                }
                textelement(ADDRESS5)
                {
                }
                textelement(POSTALCODE)
                {
                }
                textelement(COUNTRY)
                {
                }
                textelement(NOTES)
                {
                }
                textelement(TELEPHONE)
                {
                }
                textelement(DESCRIPTION)
                {
                }
                textelement(CLIENTINFO1)
                {
                }
                textelement(CLIENTINFO2)
                {
                }
                textelement(CLIENTINFO3)
                {
                }
                textelement(CLIENTINFO4)
                {
                }
                textelement(CLIENTINFO5)
                {
                }
                textelement(SMS)
                {
                }
                textelement(EMAIL)
                {
                }
                trigger OnAfterGetRecord()
                var
                begin
                    REFERENCE := 'REFERENCE';
                    BARCODE := 'BARCODE';
                    SERVICE := 'SERVICE';
                    TEMPERATURE := 'TEMPERATURE';
                    TRANSITUNIT := 'TRANSITUNIT';
                    TASK := 'TASK';
                    WEIGHT := 'WEIGHT';
                    DATE := 'DATE';
                    ARRIVALDATE := 'ARRIVALDATE';
                    FTAO := 'FTAO';
                    ADDRESS1 := 'ADDRESS1';
                    ADDRESS2 := 'ADDRESS2';
                    ADDRESS3 := 'ADDRESS3';
                    ADDRESS4 := 'ADDRESS4';
                    ADDRESS5 := 'ADDRESS5';
                    POSTALCODE := 'POSTALCODE';
                    COUNTRY := 'COUNTRY';
                    NOTES := 'NOTES';
                    TELEPHONE := 'TELEPHONE';
                    DESCRIPTION := 'DESCRIPTION';
                    CLIENTINFO1 := 'CLIENTINFO1';
                    CLIENTINFO2 := 'CLIENTINFO2';
                    CLIENTINFO3 := 'CLIENTINFO3';
                    CLIENTINFO4 := 'CLIENTINFO4';
                    CLIENTINFO5 := 'CLIENTINFO5';
                    SMS := 'SMS';
                    EMAIL := 'EMAIL';
                end;

            }

            tableelement(Polar_Speed_Barcode_Details; "Polar Speed Barcode Details")
            {
                textelement(_REFERENCE)
                {

                }
                textelement(_BARCODE)
                {

                }
                textelement(_SERVICE)
                {

                }
                textelement(_TEMPERATURE)
                {

                }
                textelement(_TRANSITUNIT)
                {

                }
                textelement(_TASK)
                {

                }
                textelement(_WEIGHT)
                {

                }
                textelement(_DATE)
                {

                }
                textelement(_ARRIVALDATE)
                {

                }
                textelement(_FTAO)
                {

                }
                textelement(_ADDRESS1)
                {

                }
                textelement(_ADDRESS2)
                {

                }
                textelement(_ADDRESS3)
                {

                }
                textelement(_ADDRESS4)
                {

                }
                textelement(_ADDRESS5)
                {

                }
                textelement(_POSTALCODE)
                {

                }
                textelement(_COUNTRY)
                {

                }
                textelement(_NOTES)
                {

                }
                textelement(_TELEPHONE)
                {

                }
                textelement(_DESCRIPTION)
                {

                }
                textelement(_CLIENTINFO1)
                {

                }
                textelement(_CLIENTINFO2)
                {

                }
                textelement(_CLIENTINFO3)
                {

                }
                textelement(_CLIENTINFO4)
                {

                }
                textelement(_CLIENTINFO5)
                {

                }
                textelement(_SMS)
                {

                }
                textelement(_EMAIL)
                {

                }

                trigger OnAfterGetRecord()
                var
                    L_Customer: Record Customer;
                    L_SalesInvoiceHeader: Record "Sales Invoice Header";
                    L_SalesInvoiceLine: Record "Sales Invoice Line";
                    L_Item: Record Item;
                    L_WarhouseClass: Record "Warehouse Class";
                    L_KnappResp: Record "Knapp Order Response";
                    L_SalesLine: Record "Sales Line";
                    L_IUM: Record "Item Unit of Measure";
                begin
                    //Create Body of Excel++
                    _REFERENCE := Format(Polar_Speed_Barcode_Details."Order No.");
                    _BARCODE := Format(Polar_Speed_Barcode_Details."Barcode No.");
                    _TRANSITUNIT := 'Box';
                    if G_ShipmentDate <> G_ShipmentNextDate then
                        _TASK := 'Collection'
                    else
                        _TASK := '';
                    _DATE := Format(Polar_Speed_Barcode_Details."Shipment Date");
                    _ARRIVALDATE := Format(CalcDate('-1D', Polar_Speed_Barcode_Details."Shipment Date"));
                    _NOTES := '';
                    _DESCRIPTION := '';
                    _CLIENTINFO1 := Polar_Speed_Barcode_Details."Tote/Order No.";
                    _CLIENTINFO2 := '';
                    _CLIENTINFO3 := '';
                    _CLIENTINFO4 := '';
                    _CLIENTINFO5 := '';
                    L_Customer.Reset();
                    L_Customer.SetRange("No.", Polar_Speed_Barcode_Details."Customer No.");
                    if L_Customer.FindFirst() then begin
                        _FTAO := Format(L_Customer.Name);
                        _SERVICE := GetServiceCode(L_Customer."Post Code");
                        _ADDRESS1 := Format(L_Customer.Address);
                        _ADDRESS2 := Format(L_Customer."Address 2");
                        _ADDRESS3 := '';
                        _ADDRESS4 := '';
                        _ADDRESS5 := '';
                        _POSTALCODE := Format(L_Customer."Post Code");
                        _COUNTRY := Format(L_Customer."Country/Region Code");
                        _TELEPHONE := Format(L_Customer."Phone No.");
                        _SMS := Format(L_Customer."Phone No.");
                        _EMAIL := Format(L_Customer."E-Mail");
                    end;
                    _TEMPERATURE := Polar_Speed_Barcode_Details.Temprature;
                    if Polar_Speed_Barcode_Details."Order Category" = Polar_Speed_Barcode_Details."Order Category"::Manual then begin
                        //Sigma- One invoice for one warehouse class code+++
                        L_SalesInvoiceHeader.Reset();
                        L_SalesInvoiceHeader.SetRange("Inv. Pick No.", Polar_Speed_Barcode_Details."Tote/Order No."); // "Tote/Order No." = Inv Pick No for Manuall Order++
                        if L_SalesInvoiceHeader.FindFirst() then begin
                            L_SalesInvoiceLine.Reset();
                            L_SalesInvoiceLine.SetRange("Document No.", L_SalesInvoiceHeader."No.");
                            if L_SalesInvoiceLine.FindFirst() then begin
                                if L_Item.Get(L_SalesInvoiceLine."No.") then begin
                                    // L_WarhouseClass.Reset();
                                    // L_WarhouseClass.SetRange(Code, L_Item."Warehouse Class Code");
                                    // if L_WarhouseClass.FindFirst() then begin
                                    //     if L_WarhouseClass.Fridge = true then
                                    //         _TEMPERATURE := 'Chilled'
                                    //     else
                                    //         _TEMPERATURE := 'Ambient';
                                    // end else
                                    //     _TEMPERATURE := 'Ambient';

                                    L_IUM.Reset();
                                    L_IUM.SetFilter(Code, L_Item."Base Unit of Measure");
                                    if L_IUM.FindFirst() then begin
                                        _WEIGHT := Format(L_IUM.Weight);
                                    end
                                    else begin
                                        _WEIGHT := '';
                                    end;

                                end;
                            end;
                        end;
                    end else begin
                        if Polar_Speed_Barcode_Details."Order Category" = Polar_Speed_Barcode_Details."Order Category"::Knapp then begin
                            L_KnappResp.Reset();
                            L_KnappResp.SetRange("Load Unit", Polar_Speed_Barcode_Details."Tote/Order No.");
                            L_KnappResp.SetFilter(SystemCreatedAt, '%1..%2', CreateDateTime(Polar_Speed_Barcode_Details."Print Date", 000000T), CreateDateTime(Polar_Speed_Barcode_Details."Print Date", 235959T));
                            if L_KnappResp.FindFirst() then begin
                                L_SalesLine.Reset();
                                L_SalesLine.SetRange("No.", L_KnappResp."Item No.");
                                L_SalesLine.SetRange(Type, L_SalesLine.Type::Item);
                                L_SalesLine.SetRange("Document No.", L_KnappResp."Document No.");
                                L_SalesLine.SetRange("Line No.", L_KnappResp."Line No.");
                                if L_SalesLine.FindFirst() then begin
                                    if L_Item.Get(L_SalesLine."No.") then begin
                                        // L_WarhouseClass.Reset();
                                        // L_WarhouseClass.SetRange(Code, L_Item."Warehouse Class Code");
                                        // if L_WarhouseClass.FindFirst() then begin
                                        //     if L_WarhouseClass.Fridge = true then
                                        //         _TEMPERATURE := 'Chilled'
                                        //     else
                                        //         _TEMPERATURE := 'Ambient';
                                        // end else
                                        //     _TEMPERATURE := 'Ambient';

                                        L_IUM.Reset();
                                        L_IUM.SetFilter(Code, L_Item."Base Unit of Measure");
                                        if L_IUM.FindFirst() then begin
                                            _WEIGHT := Format(L_IUM.Weight);
                                        end else begin
                                            _WEIGHT := '';
                                        end;
                                    end;
                                end else begin
                                    L_SalesInvoiceLine.Reset();
                                    L_SalesInvoiceLine.SetRange("Order No.", L_KnappResp."Document No.");
                                    L_SalesInvoiceLine.SetRange("Order Line No.", L_KnappResp."Line No.");
                                    if L_SalesInvoiceLine.FindFirst() then begin
                                        if L_Item.Get(L_SalesInvoiceLine."No.") then begin
                                            // L_WarhouseClass.Reset();
                                            // L_WarhouseClass.SetRange(Code, L_Item."Warehouse Class Code");
                                            // if L_WarhouseClass.FindFirst() then begin
                                            //     if L_WarhouseClass.Fridge = true then
                                            //         _TEMPERATURE := 'Chilled'
                                            //     else
                                            //         _TEMPERATURE := 'Ambient';
                                            // end else
                                            //     _TEMPERATURE := 'Ambient';

                                            L_IUM.Reset();
                                            L_IUM.SetFilter(Code, L_Item."Base Unit of Measure");
                                            if L_IUM.FindFirst() then begin
                                                _WEIGHT := Format(L_IUM.Weight);
                                            end else begin
                                                _WEIGHT := '';
                                            end;
                                        end;
                                    end;
                                end;
                            end;
                        end;
                    end;
                end;

                trigger OnPreXmlItem()
                begin
                    Polar_Speed_Barcode_Details.SetRange("Shipment Date", G_ShipmentDate);
                    Polar_Speed_Barcode_Details.SetRange(Temprature, G_Temprature);
                end;
            }

        }

    }
    var
        G_ShipmentDate: Date;
        G_ShipmentNextDate: Date;
        G_Temprature: Text[100];



    procedure GetFilters(_ShipmentDate: Date; i: Integer; _Temprature: Text[100])
    begin
        Clear(G_ShipmentDate);
        Clear(G_ShipmentNextDate);
        Clear(G_Temprature);
        G_ShipmentDate := _ShipmentDate;
        G_Temprature := _Temprature;
        if i = 0 then begin
            G_ShipmentNextDate := G_ShipmentDate;
        end else
            G_ShipmentNextDate := CalcDate('<' + '1D>', _ShipmentDate);
    end;

    procedure GetServiceCode(_SearchPostCode: Text): Text
    var
        Tbl_RoutingCode: Record "PS Route Setup";
        ShippingService: Text;
    begin
        Clear(ShippingService);
        Tbl_RoutingCode.Reset();
        while (_SearchPostCode <> '') AND (StrLen(ShippingService) = 0) do begin
            Tbl_RoutingCode.SetRange(Postcode, _SearchPostCode);
            if Tbl_RoutingCode.FindFirst() then begin
                ShippingService := Tbl_RoutingCode."Service Value";
                exit(ShippingService);
            end;
            _SearchPostCode := CopyStr(_SearchPostCode, 1, StrLen(_SearchPostCode) - 1);
            Tbl_RoutingCode.Reset();
        end;
    end;

    var

}