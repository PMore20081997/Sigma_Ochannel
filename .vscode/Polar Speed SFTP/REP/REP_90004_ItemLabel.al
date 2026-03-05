report 90008 "Polar Item Label"
{
    UsageCategory = ReportsAndAnalysis;
    ApplicationArea = All;
    DefaultLayout = RDLC;
    RDLCLayout = 'PSItemLabel.rdl';

    dataset
    {
        dataitem(Barcodes; "Polar Speed Barcode Details")
        {
            column(Barcode; EncodedText)
            {

            }
            column(QRBase64; QREncodeText)
            {

            }
            column(Temprature; Temprature)
            {

            }
            column(routingInfo; routingInfo)
            {

            }

            column(ShipToAdd1; ShipToAdd[1])
            {

            }
            column(ShipToAdd2; ShipToAdd[2])
            {

            }
            column(ShipToAdd3; ShipToAdd[3])
            {

            }
            column(ShipToAdd4; ShipToAdd[4])
            {

            }
            column(ShipToAdd5; ShipToAdd[5])
            {

            }
            column(ShipToAdd6; ShipToAdd[6])
            {

            }
            column(ShipToAdd7; ShipToAdd[7])
            {

            }
            column(ShipptoPostCode; ShipptoPostCode)
            {

            }

            column(Service; Service)
            {

            }
            column(AreaCode; AreaCode)
            {

            }
            column(Sales_Invoice_No_; "Order No.")
            {
                //Order No+++
            }
            column(Requested_Delivery_Date; "Shipment Date")
            {

            }
            column(Tote_No_; "Tote/Order No.")
            {

            }
            column(ToteSequence; ToteSequence)
            {

            }

            trigger OnAfterGetRecord()
            var
                NoSeriesMgt: Codeunit "No. Series";
                ItemRec: Record Item;
                routingcode: Record "PS Route Setup";
                L_SalesInvoiceLine: Record "Sales Invoice Line";
                L_ValueEntry: Record "Value Entry";
                L_ItemLedgEntry: Record "Item Ledger Entry";
                L_SalesShipmentHeader: Record "Sales Shipment Header";
                KnappResponse: Record "Knapp Order Response";
                L_SalesHeader: Record "Sales Header";
                L_SalesLine: Record "Sales Line";
                salesinvHeader: Record "Sales Invoice Header";
                salesinvLine: Record "Sales Invoice Line";
                SearchPostCode: Code[20];
                L_Customer: Record Customer;
                BarcodeString: Text;
                QRcodeString: Text;
                BarcodeSymbology: Enum "Barcode Symbology";
                BarcodeFontProvider: Interface "Barcode Font Provider";
                QRcodeSymbology: Enum "Barcode Symbology 2D";
                QRFontProvider: Interface "Barcode Font Provider 2D";
                knappResp: Record "Knapp Order Response";
            begin
                Clear(ToteSequence);
                Clear(Temprature);
                if Barcodes."Order Category" = Barcodes."Order Category"::Manual then begin
                    //Sigma- One invoice for one warehouse class code+++
                    salesinvHeader.Reset();
                    salesinvHeader.SetRange("Inv. Pick No.", Barcodes."Tote/Order No.");
                    if salesinvHeader.FindFirst() then begin
                        salesinvLine.Reset();
                        salesinvLine.SetRange("Document No.", salesinvHeader."No.");
                        if salesinvLine.FindFirst() then begin
                            if ItemRec.Get(salesinvLine."No.") then begin
                                //Temprature1 := ItemRec.Storage;
                                if ItemRec.Storage = '2-8' then begin
                                    Temprature := '2-8';
                                end else begin
                                    Temprature := '2-25';
                                end;
                            end;
                            Requested_Delivery_Date := salesinvHeader."Shipment Date";
                        end;
                    end;
                end else begin
                    if Barcodes."Order Category" = Barcodes."Order Category"::Knapp then begin
                        knappResp.Reset();
                        knappResp.SetRange("Load Unit", Barcodes."Tote/Order No.");
                        knappResp.SetFilter(SystemCreatedAt, '%1..%2', CreateDateTime(Barcodes."Print Date", 000000T), CreateDateTime(Barcodes."Print Date", 235959T));
                        if knappResp.FindFirst() then begin
                            L_SalesLine.Reset();
                            L_SalesLine.SetRange("No.", knappResp."Item No.");
                            L_SalesLine.SetRange(Type, L_SalesLine.Type::Item);
                            L_SalesLine.SetRange("Document No.", knappResp."Document No.");
                            L_SalesLine.SetRange("Line No.", knappResp."Line No.");
                            if L_SalesLine.FindFirst() then begin
                                if ItemRec.Get(L_SalesLine."No.") then begin
                                    //Temprature1 := ItemRec.Storage;
                                    if ItemRec.Storage = '2-8' then begin
                                        Temprature := '2-8';
                                    end else begin
                                        Temprature := '2-25';
                                    end;
                                    Requested_Delivery_Date := L_SalesLine."Shipment Date";
                                end;
                            end;
                        end;
                        ToteSequence := '-' + Format(Barcodes."No. of Box / Tote Sequence");
                    end;
                end;

                //Get Address++
                L_Customer.Reset();
                L_Customer.SetRange("No.", Barcodes."Customer No.");
                if L_Customer.FindFirst() then begin
                    Clear(ShipToAdd);
                    ShipToAdd[1] := L_Customer.Name;
                    ShipToAdd[2] := L_Customer."Name 2";
                    ShipToAdd[3] := L_Customer.Address;
                    ShipToAdd[4] := L_Customer."Address 2";
                    ShipToAdd[5] := L_Customer.County;
                    ShipToAdd[6] := L_Customer.City;
                    //ShipToAdd[7] := L_Customer."Post Code";
                    CompressArray(ShipToAdd);
                    Clear(ShipptoPostCode);
                    ShipptoPostCode := L_Customer."Post Code";


                    SearchPostCode := L_Customer."Post Code";
                    while (SearchPostCode <> '') do begin
                        routingcode.Reset();
                        routingcode.SetRange(Postcode, SearchPostCode);
                        if routingcode.FindFirst() then begin
                            routingInfo := routingcode.Depot;
                            Service := routingcode.Service;
                            AreaCode := routingcode.Area;
                        end;
                        SearchPostCode := CopyStr(SearchPostCode, 1, StrLen(SearchPostCode) - 1);
                    end;
                end;
                UniqueBarcodeNo := Barcodes."Barcode No.";


                // Barcode from Invoice Order No.
                BarcodeFontProvider := Enum::"Barcode Font Provider"::IDAutomation1D;
                BarcodeSymbology := Enum::"Barcode Symbology"::Code39;
                EncodedText := BarcodeFontProvider.EncodeFont(UniqueBarcodeNo, BarcodeSymbology);

                // QR from Invoice Order No.
                QRFontProvider := Enum::"Barcode Font Provider 2D"::IDAutomation2D;
                QRcodeSymbology := Enum::"Barcode Symbology 2D"::"QR-Code";
                QREncodeText := QRFontProvider.EncodeFont(UniqueBarcodeNo, QRcodeSymbology);
            end;


        }
    }

    var
        ShipptoPostCode: Code[20];
        LoadUnitList: List of [Code[500]];
        EncodedText: Text;
        QREncodeText: Text;
        Temprature: Code[25];
        Temprature1: Code[25];
        routingInfo: Code[20];
        Service: Code[20];
        LabelCount: Integer;
        ShipToAdd: array[7] of Text;
        Boxes: Integer;
        G_Boxes: Integer;
        G_Tote: Integer;
        AreaCode: Text[20];
        UniqueBarcodeNo: Text[25];
        UniqueBarcodeNo1: Text[25];
        countt: Integer;
        NoOfPrints: Integer;
        Requested_Delivery_Date: Date;
        ToteSequence: Text;

}
