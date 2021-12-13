report 90003 "Delivery Note-A6"
{
    // version CAS-21704-Q9F4H9

    DefaultLayout = RDLC;
    RDLCLayout = './Delivery Note-A6.rdl';

    dataset
    {
        dataitem("Interim Sales Header"; "Interim Sales Header")
        {
            DataItemTableView = WHERE("Document Type" = CONST(Order));
            column(OrderDate_InterimSalesHeader; FORMAT("Interim Sales Header"."Order Date"))
            {
            }
            column(No_InterimSalesHeader; "Interim Sales Header"."No.")
            {
            }
            column(BilltoName_InterimSalesHeader; "Interim Sales Header"."Bill- to Name")
            {
            }
            column(WebShipmentMethod_InterimSalesHeader; "Interim Sales Header"."Web Shipment Method")
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
            column(TradePartnerCode_InterimSalesHeader; "Interim Sales Header"."Trade Partner Code")
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
            column(ChannelOrderID_InterimSalesHeader; "Interim Sales Header"."Channel Order ID")
            {
            }
            dataitem("Shipment Tracking"; "Shipment Tracking")
            {
                CalcFields = Label;
                //DataItemLink = "Interim Document No" = FIELD("No.");
                DataItemLink = "Document No." = field("No.");
                DataItemTableView = WHERE("Document Type" = CONST(Order));
                column(EntryNo; "Shipment Tracking"."Entry No.")
                {
                }
                column(Label_ShipmentTracking; "Shipment Tracking"."A6 Label1")
                {
                }
                dataitem("Interim Sales Line"; "Interim Sales Line")
                {
                    DataItemLink = "Document Type" = FIELD("Document Type"),
                                   "Document No" = FIELD("No.");
                    DataItemLinkReference = "Interim Sales Header";
                    DataItemTableView = WHERE(Type = CONST(Item),
                                              "Item Type" = FILTER(<> Component));
                    RequestFilterFields = "No.";
                    column(DocumentNo_InterimSalesLine; "Interim Sales Line"."Document No")
                    {
                    }
                    column(LineNo_InterimSalesLine; "Interim Sales Line"."Line No.")
                    {
                    }
                    column(No_InterimSalesLine; "Interim Sales Line"."No.")
                    {
                    }
                    column(SKU_InterimSalesLine; "Interim Sales Line"."Channel SKU")
                    {
                    }
                    column(Description_InterimSalesLine; "Interim Sales Line".Description)
                    {
                    }
                    column(Quantity_InterimSalesLine; "Interim Sales Line".Quantity)
                    {
                    }

                    trigger OnAfterGetRecord()
                    var
                        L_Item: Record 27;
                    begin
                    end;

                    trigger OnPostDataItem()
                    var
                        L_SalesLine: Record 37;
                    begin
                    end;
                }
            }

            trigger OnAfterGetRecord()
            var
                InterimSalesLine: Record "Interim Sales Line";
            begin
                TradePartner.RESET;
                IF TradePartner.GET("Interim Sales Header"."Trade Partner Code") THEN BEGIN
                    TradePartner.CALCFIELDS(Logo);
                    Customer.RESET;
                    IF Customer.GET(TradePartner."Customer No.") THEN;
                END;

                CLEAR(Var1);
                CLEAR(Var2);
                CLEAR(Var3);
                CLEAR(Var4);
                IF "Interim Sales Header"."Trade Partner Code" = 'GROUPON' THEN BEGIN
                    Var1 := 'Groupon Goods Return';
                    Var2 := 'For your pre-paid return label,';
                    Var3 := 'please follow instructions below';
                END;
                IF "Interim Sales Header"."Trade Partner Code" = 'ARGOS' THEN BEGIN
                    Var4 := 'Thank-You for shopping with Argos';
                END;

                ShipAdd[1] := "Interim Sales Header"."Ship-to Name";
                ShipAdd[2] := "Interim Sales Header"."Ship-to Address";
                ShipAdd[3] := "Interim Sales Header"."Ship-to Address 2";
                ShipAdd[4] := "Interim Sales Header"."Ship-to City";
                ShipAdd[5] := "Interim Sales Header"."Ship-to Post Code" + ' ' + "Interim Sales Header"."Ship-to County";
                COMPRESSARRAY(ShipAdd);
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

    var
        TradePartner: Record "Trade Partner";
        Customer: Record 18;
        Text000: Label 'Groupon Goods Return';
        Text001: Label 'For your pre-paid return label,';
        Text002: Label 'please follow instructions below';
        Var1: Text[50];
        Var2: Text[50];
        Var3: Text[50];
        Var4: Text[50];
        ShipAdd: array[5] of Text;
}

