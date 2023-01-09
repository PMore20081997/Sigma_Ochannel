page 90037 "WH Shipment Lines"
{
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
                field("Channel Code"; Rec."Channel Code")
                {
                    Caption = 'Channel Partner Code';
                    StyleExpr = Styletext;
                    ApplicationArea = All;
                }
                field("Channel Order ID"; rec."Channel Order ID")
                {
                    Editable = false;
                    ApplicationArea = All;
                    StyleExpr = Styletext;
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
                field("Scanned Quantity"; Rec."Scanned Quantity")
                {
                    ApplicationArea = All;
                    StyleExpr = Styletext;
                }

                field("Scan Status"; Rec."Scan Status")
                {
                    ApplicationArea = All;
                    StyleExpr = Styletext;
                }
                field("Scanned By"; Rec."Scanned By")
                {
                    ApplicationArea = All;
                    StyleExpr = Styletext;
                }
                field("Scan Station"; Rec."Scan Station")
                {
                    ApplicationArea = All;
                    StyleExpr = Styletext;
                }
                field("Scanned Date"; Rec."Scanned Date")
                {
                    ApplicationArea = All;
                    StyleExpr = Styletext;
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
                        L_WhseShipmentLine: Record "Warehouse Shipment Line";
                    begin
                        L_WhseShipmentLine.Reset();
                        L_WhseShipmentLine.SetRange("Channel Order ID", Rec."Channel Order ID");
                        If L_WhseShipmentLine.FindSet() then begin
                            repeat
                                L_WhseShipmentLine.Parked := false;
                                L_WhseShipmentLine.Modify(true);
                                CurrPage.Update(true);
                            until L_WhseShipmentLine.Next() = 0;
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

            }

        }

    }
    trigger OnAfterGetRecord()
    begin
        if Rec."Scan Status" = Rec."Scan Status"::Scanned then
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

