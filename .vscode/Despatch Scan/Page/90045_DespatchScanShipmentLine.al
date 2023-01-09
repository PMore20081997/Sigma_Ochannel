page 90045 "Despatch Scan Int. Pick"
{
    Caption = 'Whse. Shipment Lines';
    DelayedInsert = true;
    DeleteAllowed = false;
    PageType = ListPart;
    InsertAllowed = false;
    SourceTable = "Warehouse Shipment Line";
    layout
    {
        area(content)
        {
            repeater("Group")
            {
                Editable = false;
                Enabled = false;
                field("Channel Code"; Rec."Channel Code")
                {
                    Caption = 'Channel Partner Code';
                    StyleExpr = Styletext;
                    ApplicationArea = All;
                }

                field("Item No."; rec."Item No.")
                {
                    StyleExpr = Styletext;
                    ApplicationArea = All;
                }
                field("Variant Code"; rec."Variant Code")
                {
                    Editable = false;
                    ApplicationArea = All;
                    StyleExpr = Styletext;
                    Visible = false;

                }
                field(Description; rec.Description)
                {

                    Editable = false;
                    ApplicationArea = All;
                    StyleExpr = Styletext;
                }
                field("Bay No."; Rec."Bay No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Bay No. field.';
                }

                field(Quantity; Rec.Quantity)
                {
                    Caption = 'Order Quantity';
                    Editable = false;
                    ApplicationArea = All;
                    StyleExpr = Styletext;
                }
                field("Qty. Picked"; rec."Qty. Picked")
                {
                    Caption = 'Total Picked Quantity';
                    Editable = false;
                    ApplicationArea = All;
                    StyleExpr = Styletext;
                }
                field("Qty. to Ship"; Rec."Qty. to Ship")
                {
                    Caption = 'Scanned Qty';
                    ApplicationArea = All;
                    ToolTip = 'Specifies the quantity of items that remain to be shipped.';
                    StyleExpr = Styletext;
                }
                field("Channel Order ID"; rec."Channel Order ID")
                {
                    Editable = false;
                    ApplicationArea = All;
                    StyleExpr = Styletext;
                }
                // field("Quantity Scanned"; rec."Quantity Scanned")
                // {
                //     Caption = 'Scanned Quantity';
                //     Editable = false;
                //     ApplicationArea = All;
                //     StyleExpr = Styletext;
                // }


                field("Line Status"; Rec."Line Status")
                {
                    Caption = 'Status';
                    ApplicationArea = All;
                }
            }
        }

    }
    actions
    {
        area(Processing)
        {
            group("Undo Parked Orders")
            {
                Caption = 'Undo Parked Orders';
                action("Undo Parked Order")
                {
                    ApplicationArea = All;
                    Image = Undo;

                    trigger OnAction()
                    var
                        L_IntrimSalesLine: Record "Interim Sales Line";
                    begin

                        L_IntrimSalesLine.Reset();
                        L_IntrimSalesLine.SetRange("Channel Order ID", Rec."Channel Order ID");
                        L_IntrimSalesLine.SetRange(type, L_IntrimSalesLine.Type::Item);
                        If L_IntrimSalesLine.FindSet() then begin
                            repeat
                                // L_IntrimSalesLine."Partially Post" := false;
                                L_IntrimSalesLine.Parked := false;
                                L_IntrimSalesLine.Modify(true);
                                CurrPage.Update(true);
                            until L_IntrimSalesLine.Next() = 0;
                        end;
                    end;
                }
            }
            group("Source Document")
            {
                action("Warhouse Shipment")
                {
                    ApplicationArea = All;
                    Image = Shipment;
                    trigger OnAction()
                    var
                        WarehouseShipmentHeader: Record "Warehouse Shipment Header";
                        Page_WarShpment: Page "Warehouse Shipment";

                    begin
                        WarehouseShipmentHeader.Reset();
                        WarehouseShipmentHeader.SetRange("No.", Rec."No.");
                        if WarehouseShipmentHeader.FindFirst() then begin
                            Clear(Page_WarShpment);
                            Page_WarShpment.SetRecord(WarehouseShipmentHeader);
                            Page_WarShpment.Run();
                        end;
                    end;
                }
                action("Sales Order")
                {
                    ApplicationArea = All;
                    Image = Order;

                    trigger OnAction()
                    var
                        SalesHeader: Record "Sales Header";
                        Page_SalesOrder: Page "Sales Order";
                    begin
                        SalesHeader.Reset();
                        SalesHeader.SetRange("No.", Rec."Source No.");
                        if SalesHeader.FindFirst() then begin
                            Clear(Page_SalesOrder);
                            Page_SalesOrder.SetRecord(SalesHeader);
                            Page_SalesOrder.Run();
                        end;
                    end;
                }
                action("Web Order")
                {
                    ApplicationArea = All;
                    Image = Web;

                    trigger OnAction()
                    var
                        InterimSalesHeader: Record "Interim Sales Header";
                        HandledInterimSalesHeader: Record "Handled Interim Sales Header";
                        P_WebOrder: Page "Web Order Header";
                        P_HnadledWebOrder: Page "Handle Web Order";
                    begin
                        If not Rec."Dispatch Scan" then begin
                            InterimSalesHeader.Reset();
                            InterimSalesHeader.SetRange("Channel Order ID", Rec."Channel Order ID");
                            if InterimSalesHeader.FindFirst() then begin
                                Clear(P_WebOrder);
                                P_WebOrder.SetRecord(InterimSalesHeader);
                                P_WebOrder.Run();
                            end;
                        end
                        else begin
                            HandledInterimSalesHeader.Reset();
                            HandledInterimSalesHeader.SetRange("Channel Order ID", Rec."Channel Order ID");
                            if HandledInterimSalesHeader.FindFirst() then begin
                                Clear(P_HnadledWebOrder);
                                P_HnadledWebOrder.SetRecord(HandledInterimSalesHeader);
                                P_HnadledWebOrder.Run();
                            end;
                        end;

                    end;
                }
            }

        }

    }

    trigger OnAfterGetRecord()
    begin
        //Clear(Styletext);
        // Rec.CalcFields(Parked, Parked);//khan++

        // IF rec."Qty. Picked" = 0 then
        //     Styletext := 'Attention'
        // else
        //     Styletext := 'Standard';
        if Rec."Dispatch Scan" then
            Styletext := 'Favorable'
        else
            Styletext := 'Standard';

        if Rec.Parked then
            Styletext := 'Attention';


        CurrPage.Update(false);
    end;

    var
        Styletext: Text;

}

