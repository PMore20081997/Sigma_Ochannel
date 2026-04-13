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
            column(Temprature; Storage)
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
                routingcode: Record "PS Route Setup";
                SearchPostCode: Code[20];
                L_Customer: Record Customer;
                BarcodeString: Text;
                QRcodeString: Text;
                BarcodeSymbology: Enum "Barcode Symbology";
                BarcodeFontProvider: Interface "Barcode Font Provider";
                QRcodeSymbology: Enum "Barcode Symbology 2D";
                QRFontProvider: Interface "Barcode Font Provider 2D";
                PolarSpeedBarcodeDetails: Record "Polar Speed Barcode Details";
            begin
                //Get ToteSequence
                Clear(ToteSequence);
                if Barcodes."Order Category" = Barcodes."Order Category"::Knapp then
                    ToteSequence := '-' + Format(Barcodes."No. of Box / Tote Sequence");

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

                    //++
                    Clear(ShipptoPostCode);
                    ShipptoPostCode := L_Customer."Post Code";

                    //++
                    SearchPostCode := L_Customer."Post Code";
                    while (SearchPostCode <> '') AND (StrLen(Service) = 0) do begin
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

                // Barcode from Invoice Order No.
                Clear(UniqueBarcodeNo);
                UniqueBarcodeNo := Barcodes."Barcode No.";
                BarcodeFontProvider := Enum::"Barcode Font Provider"::IDAutomation1D;
                BarcodeSymbology := Enum::"Barcode Symbology"::Code39;
                EncodedText := BarcodeFontProvider.EncodeFont(UniqueBarcodeNo, BarcodeSymbology);

                // QR from Invoice Order No.
                QRFontProvider := Enum::"Barcode Font Provider 2D"::IDAutomation2D;
                QRcodeSymbology := Enum::"Barcode Symbology 2D"::"QR-Code";
                QREncodeText := QRFontProvider.EncodeFont(UniqueBarcodeNo, QRcodeSymbology);

                //Update No of Printed++
                if not IsReportInPreviewMode then begin
                    PolarSpeedBarcodeDetails.Reset();
                    PolarSpeedBarcodeDetails.SetRange("Entry No.", Barcodes."Entry No.");
                    if PolarSpeedBarcodeDetails.FindFirst() then begin
                        PolarSpeedBarcodeDetails."No. Printed" := PolarSpeedBarcodeDetails."No. Printed" + 1;
                        PolarSpeedBarcodeDetails.Modify();
                    end;
                end;
            end;
        }
    }

    var
        ShipptoPostCode: Code[20];
        EncodedText: Text;
        QREncodeText: Text;
        routingInfo: Code[20];
        Service: Code[20];
        LabelCount: Integer;
        ShipToAdd: array[7] of Text;
        AreaCode: Text[20];
        UniqueBarcodeNo: Text[25];
        ToteSequence: Text;


    protected procedure IsReportInPreviewMode(): Boolean
    var
        MailManagement: Codeunit "Mail Management";
    begin
        exit(CurrReport.Preview() or MailManagement.IsHandlingGetEmailBody());
    end;

}
