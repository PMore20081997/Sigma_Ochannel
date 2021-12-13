report 90071 DelivryNote1
{

    DefaultLayout = RDLC;
    RDLCLayout = './HandledWebDeliveryNote.rdl';

    dataset
    {
        dataitem("Handled Interim Sales Header"; "Handled Interim Sales Header")
        {
            //  DataItemTableView = WHERE("Document Type" = CONST(Order));
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
                column(PrintReturnNote; Ggeneralsetup."Print Return Note")
                {

                }
                column(PrintOrderLabel; Ggeneralsetup."Print Order Label")
                {

                }
                column(PrintReturnLabel; Ggeneralsetup."Print Return Label")
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
                    Clear(RowCount);
                end;

                trigger OnAfterGetRecord()
                var
                    L_Item: Record 27;
                    //Pranali++
                    L_GeneralSetup: Record "General Setup - Channels";
                    L_ShipmentTracking: Record "Shipment Tracking";
                begin
                    Clear(BarcodeText);
                    Clear(recTmpBlob1);
                    Clear(BarcodeMgt);
                    BarcodeText := "Handled Interim Sales Header"."Channel Order ID";
                    BarcodeMgt.EncodeCode128(BarcodeText, 1, false, recTmpBlob1);
                    //Pranali--
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

                //Pranali++
                Clear(BarcodeText1);
                Clear(recTmpBlob2);
                if CopyStr("Handled Interim Sales Header"."No.", 1, 3) = 'WEB' then
                    BarcodeText1 := CopyStr("Handled Interim Sales Header"."No.", 4)
                else
                    BarcodeText1 := "Handled Interim Sales Header"."No.";
                BarcodeMgt.EncodeCode128(BarcodeText1, 1, false, recTmpBlob2);
                //Pranali++

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
                ShipAdd[5] := "Handled Interim Sales Header"."Ship-to Post Code" + ' ' + "Handled Interim Sales Header"."Ship-to County";
                COMPRESSARRAY(ShipAdd);



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

    begin
        CompanyInfo.Get();
        CompanyInfo.CalcFields(Picture);

    end;

    trigger OnPreReport()

    begin
        Ggeneralsetup.Get();
    end;
    //Pranali--
    var
        TradePartner: Record "Trade Partner";//"90005";
        Customer: Record 18;
        Text000: Label 'Groupon Goods Return';
        Text001: Label 'For your pre-paid return label,';
        Text002: Label 'please follow instructions below';
        Var1: Text[50];
        Var2: Text[50];
        Var3: Text[50];
        Var4: Text[50];
        ShipAdd: array[5] of Text;
        FirstItem: Code[30];
        FirstItemDescription: Text;
        CompanyInfo: Record "Company Information";//pranali
        BarcodeMgt: Codeunit "Barcode Management";//pranali
        recTmpBlob1: Record "Name/Value Buffer" temporary;//pranali
        BarcodeText: Code[20];
        BarcodeText1: Code[20];
        recTmpBlob2: Record "Name/Value Buffer" temporary;
        Ggeneralsetup: Record "General Setup - Channels";
        G_LineCount: Integer;
        RowCount: Integer;
        Flag: Boolean;
}

