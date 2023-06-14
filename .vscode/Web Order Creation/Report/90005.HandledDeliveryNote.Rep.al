report 90005 "Handled Delivery Note"
{
    // version CAS-21704-Q9F4H9
    Caption = 'Delivery Note';
    DefaultLayout = RDLC;
    RDLCLayout = './HandledDeliveryNoteNew.rdl';

    dataset
    {
        dataitem("Handled Interim Sales Header"; "Handled Interim Sales Header")
        {
            DataItemTableView = WHERE("Document Type" = CONST(Order));

            column(CompanyAddress1; CompanyAddress[1])
            {
            }
            column(CompanyAddress2; CompanyAddress[2])
            {
            }
            column(CompanyAddress3; CompanyAddress[3])
            {
            }
            column(CompanyAddress4; CompanyAddress[4])
            {
            }
            column(CompanyAddress5; CompanyAddress[5])
            {
            }
            column(CompanyAddress6; CompanyAddress[6])
            {
            }
            column(CompanyAddress7; CompanyAddress[7])
            {
            }
            column(CompanyAddress8; CompanyAddress[8])
            {
            }
            column(RowNo; RowNo)
            {
            }

            column(FirstItem; FirstItem)
            {
            }
            column(FirstItemDescription; FirstItemDescription)
            {
            }
            column(OrderDate_InterimSalesHeader; FORMAT("Handled Interim Sales Header"."Order Date"))
            {
            }
            column(No_InterimSalesHeader; "Handled Interim Sales Header"."No.")
            {
            }
            column(BilltoName_InterimSalesHeader; "Handled Interim Sales Header"."Bill- to Name")
            {
            }
            column(WebShipmentMethod_InterimSalesHeader; "Handled Interim Sales Header"."Web Shipment Method")
            {
            }
            column(ShiptoName_InterimSalesHeader; ShipAdd[1])
            {
            }
            column(ShiptoAddress_InterimSalesHeader; ShipAdd[2])
            {
            }
            column(ShiptoAddress2_InterimSalesHeader; ShipAdd[3])
            {
            }
            column(ShiptoCity_InterimSalesHeader; ShipAdd[4])
            {
            }
            column(ShiptoPostCode_InterimSalesHeader; ShipAdd[5])
            {
            }
            column(ShiptoCounty_InterimSalesHeader; ShipAdd[6])
            {
            }
            column(Logo; TradePartner.Logo)
            {
            }
            column(Cust_Email; Customer."E-Mail")
            {
            }
            column(Cust_HomePage; Customer."Home Page")
            {
            }
            column(TradePartnerCode_InterimSalesHeader; "Handled Interim Sales Header"."Trade Partner Code")
            {
            }
            column(Var1; Var1)
            {
            }
            column(Var2; Var2)
            {
            }
            column(Var3; Var3)
            {
            }
            column(Var4; Var4)
            {
            }
            column(ChannelOrderID_InterimSalesHeader; "Handled Interim Sales Header"."Channel Order ID")
            {
            }
            column(recTmpBlob2; recTmpBlob2."Value BLOB")
            {

            }
            column(Flag; Flag)
            {

            }
            column(BarcodeText1; BarcodeText1)
            {

            }
            dataitem("Handled Interim Sales Line"; "Handled Interim Sales Line")
            {
                DataItemLink = "Document Type" = FIELD("Document Type"),
                                   "Document No" = FIELD("No.");
                DataItemLinkReference = "Handled Interim Sales Header";
                DataItemTableView = WHERE(Type = CONST(Item),
                                              "Item Type" = FILTER(<> Component),
                                              "Line Status" = filter(<> Cancelled));
                RequestFilterFields = "No.";

                column(DocumentNo_InterimSalesLine; "Handled Interim Sales Line"."Document No")
                {
                }
                column(LineNo_InterimSalesLine; "Handled Interim Sales Line"."Line No.")
                {
                }
                column(No_InterimSalesLine; "Handled Interim Sales Line"."No.")
                {
                }
                column(SKU_InterimSalesLine; "Handled Interim Sales Line"."Channel SKU")
                {
                }
                column(Description_InterimSalesLine; "Handled Interim Sales Line".Description)
                {
                }
                column(Quantity_InterimSalesLine; "Handled Interim Sales Line".Quantity)
                {
                }
                column(Unit_Price; "Unit Price")
                {
                }
                column(CompanyLogo; CompanyInfo.Picture)
                {

                }
                column(recTmpBlob1_Blob; recTmpBlob1."Value BLOB")
                {
                }
                column(BarcodeText; BarcodeText)
                {

                }

                column(G_LineCount; G_LineCount)
                {

                }
                column(RowCount; RowCount)
                {

                }

                dataitem("Shipment Tracking"; "Shipment Tracking")
                {
                    CalcFields = Label, "A6 Label1";
                    DataItemLink = "Document No." = FIELD("No.");

                    DataItemTableView = WHERE("Document Type" = CONST(Order));
                    DataItemLinkReference = "Handled Interim Sales Header";
                    column(EntryNo; "Shipment Tracking"."Entry No.")
                    {
                    }
                    column(Label_ShipmentTracking; "Shipment Tracking".Label)
                    {
                    }
                    column(A6_Label1; "Shipment Tracking"."A6 Label1")
                    {

                    }
                    trigger OnAfterGetRecord()
                    begin
                        //Message('SHIP %1', "Shipment Tracking"."Document No.");
                    end;
                }
                trigger OnPreDataItem()
                begin
                    Clear(G_LineCount);
                end;

                trigger OnAfterGetRecord()
                var
                    L_Item: Record 27;
                    //Pranali++
                    L_ShipmentTracking: Record "Shipment Tracking";
                    //NIKHIL_18/04/2022
                    BarcodeString: Text;
                    BarcodeSymbology: Enum "Barcode Symbology";
                    BarcodeFontProvider: Interface "Barcode Font Provider";
                begin
                    Clear(BarcodeText);
                    Clear(BarcodeString);
                    /*Clear(recTmpBlob1);
                    Clear(BarcodeMgt);
                    BarcodeText := "Handled Interim Sales Header"."Channel Order ID";
                    BarcodeMgt.EncodeCode128(BarcodeText, 1, false, recTmpBlob1);
                    //Pranali--*///NIKHIL_18/04/2022_Comment
                    //NIKHIL_18/04/2022++
                    BarcodeFontProvider := Enum::"Barcode Font Provider"::IDAutomation1D;
                    BarcodeSymbology := Enum::"Barcode Symbology"::Code128;
                    BarcodeString := "Handled Interim Sales Header"."Channel Order ID";
                    BarcodeFontProvider.ValidateInput(BarcodeString, BarcodeSymbology);
                    BarcodeText := BarcodeFontProvider.EncodeFont(BarcodeString, BarcodeSymbology);
                    //NIKHIL_18/04/2022--

                    if "Handled Interim Sales Line".Type = "Handled Interim Sales Line".Type::Item then begin
                        G_LineCount += 1;
                    end;

                    if G_LineCount < 4 then
                        RowCount := 1;

                    if ((G_LineCount < 7) AND (G_LineCount > 3)) then
                        RowCount := 2;


                    if ((G_LineCount < 10) AND (G_LineCount > 6)) then
                        RowCount := 3;


                    if ((G_LineCount < 13) AND (G_LineCount > 9)) then
                        RowCount := 4;


                    if ((G_LineCount < 16) AND (G_LineCount > 12)) then
                        RowCount := 5;


                    if ((G_LineCount < 19) AND (G_LineCount > 15)) then
                        RowCount := 6;


                    if ((G_LineCount < 22) AND (G_LineCount > 18)) then
                        RowCount := 7;


                    if ((G_LineCount < 26) AND (G_LineCount > 21)) then
                        RowCount := 8;


                    RowNo += 1;


                end;

                trigger OnPostDataItem()
                var
                    L_SalesLine: Record 37;
                begin
                end;

            }

            trigger OnAfterGetRecord()
            var
                InterimSalesLine: Record "Handled Interim Sales Line";//"90009";
                ItemRec: Record 27;
                //NIKHIL_18/04/2022
                BarcodeString: Text;
                BarcodeSymbology: Enum "Barcode Symbology";
                BarcodeFontProvider: Interface "Barcode Font Provider";
            begin
                TradePartner.RESET;
                IF TradePartner.GET("Handled Interim Sales Header"."Trade Partner Code") THEN BEGIN
                    if TradePartner."Print Return Note" = true then
                        Flag := true
                    else
                        Flag := false;
                    TradePartner.CALCFIELDS(Logo);
                    Customer.RESET;
                    IF Customer.GET(TradePartner."Customer No.") THEN;
                END;

                /*//Pranali++
                Clear(BarcodeText1);
                Clear(recTmpBlob2);
                if CopyStr("Handled Interim Sales Header"."No.", 1, 3) = 'WEB' then
                    BarcodeText1 := CopyStr("Handled Interim Sales Header"."No.", 4)
                else
                    BarcodeText1 := "Handled Interim Sales Header"."No.";
                BarcodeMgt.EncodeCode128(BarcodeText1, 1, false, recTmpBlob2);
                //Pranali++*///NIKHIL_18/04/2022_Comment

                //NIKHIL_18/04/2022++
                Clear(BarcodeText1);
                Clear(BarcodeString);

                BarcodeFontProvider := Enum::"Barcode Font Provider"::IDAutomation1D;
                BarcodeSymbology := Enum::"Barcode Symbology"::Code128;
                if CopyStr("Handled Interim Sales Header"."No.", 1, 3) = 'WEB' then
                    BarcodeString := CopyStr("Handled Interim Sales Header"."No.", 4)
                else
                    BarcodeString := "Handled Interim Sales Header"."No.";
                BarcodeFontProvider.ValidateInput(BarcodeString, BarcodeSymbology);
                BarcodeText1 := BarcodeFontProvider.EncodeFont(BarcodeString, BarcodeSymbology);
                //NIKHIL_18/04/2022--

                CLEAR(Var1);
                CLEAR(Var2);
                CLEAR(Var3);
                CLEAR(Var4);
                IF ("Handled Interim Sales Header"."Trade Partner Code" = 'GROUPON') OR ("Handled Interim Sales Header"."Trade Partner Code" = 'GROUPON2') THEN BEGIN
                    Var1 := 'Groupon Goods Return';
                    Var2 := 'For your pre-paid return label,';
                    Var3 := 'please follow instructions below';
                END;
                IF "Handled Interim Sales Header"."Trade Partner Code" = 'ARGOS' THEN BEGIN
                    Var4 := 'Thank-You for shopping with Argos';
                END;

                ShipAdd[1] := "Handled Interim Sales Header"."Ship-to Name";
                ShipAdd[2] := "Handled Interim Sales Header"."Ship-to Address";
                ShipAdd[3] := "Handled Interim Sales Header"."Ship-to Address 2";
                ShipAdd[4] := "Handled Interim Sales Header"."Ship-to City";
                ShipAdd[5] := "Handled Interim Sales Header"."Ship-to Post Code";
                ShipAdd[6] := "Handled Interim Sales Header"."Ship-to County";
                COMPRESSARRAY(ShipAdd);



                CompanyAddress[1] := CompanyInfo.Name;
                CompanyAddress[2] := CompanyInfo.Address;
                CompanyAddress[3] := CompanyInfo."Address 2";
                CompanyAddress[4] := CompanyInfo.City;
                CompanyAddress[5] := CompanyInfo."Post Code" + ' ' + CompanyInfo.County;
                CompanyAddress[6] := 'Tel: ' + CompanyInfo."Phone No.";
                CompanyAddress[7] := 'VAT Number: ' + CompanyInfo."VAT Registration No.";
                CompanyAddress[8] := 'Company Registered Number: ' + CompanyInfo."Registration No.";
                CompressArray(CompanyAddress);



                CLEAR(FirstItem);
                CLEAR(FirstItemDescription);
                InterimSalesLine.RESET;
                InterimSalesLine.SETRANGE("Document Type", InterimSalesLine."Document Type"::Order);
                InterimSalesLine.SETRANGE("Document No", "Handled Interim Sales Header"."No.");
                InterimSalesLine.SETRANGE(Type, InterimSalesLine.Type::Item);
                IF InterimSalesLine.FINDFIRST THEN BEGIN
                    FirstItem := InterimSalesLine."No.";
                    IF ItemRec.GET(InterimSalesLine."No.") THEN
                        FirstItemDescription := ItemRec.Description;
                END;

                Clear(RowNo);  // Irshad
            end;
        }


    }



    requestpage
    {

        layout
        {
        }

        actions
        {
        }
    }

    labels
    {
    }
    //Pranali++
    trigger OnInitReport()
    var
    // FormatAddress: Codeunit "Format Address";
    begin
        CompanyInfo.Get();
        CompanyInfo.CalcFields(Picture);
        // FormatAddress.Company(CompanyAddress, CompanyInfo);
    end;

    trigger OnPreReport()

    begin
        Ggeneralsetup.Get();
    end;
    //Pranali--
    var
        CompanyAddress: array[8] of Text[100];
        TradePartner: Record "Trade Partner";//"90005";
        Customer: Record 18;
        Text000: Label 'Groupon Goods Return';
        Text001: Label 'For your pre-paid return label,';
        Text002: Label 'please follow instructions below';
        Var1: Text[50];
        Var2: Text[50];
        Var3: Text[50];
        Var4: Text[50];
        ShipAdd: array[6] of Text;
        FirstItem: Code[30];
        FirstItemDescription: Text;
        CompanyInfo: Record "Company Information";//pranali

        recTmpBlob1: Record "Name/Value Buffer" temporary;//pranali
        BarcodeText: Code[20];
        BarcodeText1: Code[20];
        recTmpBlob2: Record "Name/Value Buffer" temporary;
        Ggeneralsetup: Record "General Setup - Channels";
        G_LineCount: Integer;
        RowCount: Integer;
        Flag: Boolean;

        RowNo: Integer;
}

