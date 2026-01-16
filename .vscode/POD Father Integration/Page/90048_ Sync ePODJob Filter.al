page 90048 "Sync ePODJob Filter"
{
    PageType = StandardDialog;
    UsageCategory = Administration;
    SourceTable = "Sync ePODJob Table";
    Caption = 'ePOD Job Filter';

    layout
    {
        area(Content)
        {
            group("Sales Details")
            {
                field("Customer Sync"; Rec."Customer Sync")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Route Sync"; Rec."Route Sync")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Shipment Date"; Rec."Shipment Date")
                {
                    ApplicationArea = All;
                    ShowMandatory = true;
                    trigger OnValidate()
                    var
                    begin
                        if Rec."Shipment Date" <> 0D then begin
                            Rec."Shipping Agent Code" := '';
                            Rec."Shipping Agent Service Code" := '';
                            Rec."Weekend Shipping Agent Code" := '';
                            Rec."Weekend Shipping Service Code" := '';
                        end;
                    end;
                }
                field("Shipping Agent Code"; Rec."Shipping Agent Code")
                {
                    ApplicationArea = All;
                    ShowMandatory = true;
                    trigger OnValidate()
                    begin
                        if Rec."Shipping Agent Code" <> '' then begin
                            //Remove shipping agent service code+++
                            Rec."Shipping Agent Service Code" := '';


                            //Check Shipment Date Value+++
                            if Rec."Shipment Date" = 0D then
                                Error('Shipment Date Should not be blank');

                            //Check Shipment date if it is weekend date+++
                            if (Format(Rec."Shipment Date", 0, '<Weekday Text>') = 'Saturday') OR (Format(Rec."Shipment Date", 0, '<Weekday Text>') = 'Sunday') then begin
                                Error('Selection of a Shipping Agent Code is not allowed for shipment dates "%1" that fall on weekends.', Rec."Shipment Date");
                            end;

                            #region Check Weekend shipping details if entering shipping agent code++
                            if Rec."Weekend Shipping Agent Code" <> '' then
                                Error('Weekend Shipping Agent Code should be blank');

                            if Rec."Weekend Shipping Service Code" <> '' then
                                Error('Weekend Shipping Agent Service Code should be blank');
                            #Endregion Check Weekend shipping details if entering shipping agent code++
                        end;

                        //Calculate Total Count based on selected shipping details++++
                        if (Rec."Shipment Date" <> 0D) and (Rec."Shipping Agent Code" <> '') and (Rec."Shipping Agent Service Code" <> '') then begin
                            CalculateOrderDetails(Rec);
                        end else
                            TotalOrderCount := 0;
                    end;
                }
                field("Shipping Agent Service Code"; Rec."Shipping Agent Service Code")
                {
                    ApplicationArea = All;
                    ShowMandatory = true;
                    trigger OnValidate()
                    var
                    begin
                        if Rec."Shipping Agent Service Code" <> '' then begin
                            //Check Shipping Agent Code value+++
                            if Rec."Shipping Agent Code" = '' then begin
                                Error('Shipping Agent Code should not be blank');
                            end;

                            #region Check Weekend shipping details if entering shipping agent code++
                            if Rec."Weekend Shipping Agent Code" <> '' then
                                Error('Weekend Shipping Agent Code should be blank');

                            if Rec."Weekend Shipping Service Code" <> '' then
                                Error('Weekend Shipping Agent Service Code should be blank');
                            #Endregion Check Weekend shipping details if entering shipping agent code++
                        end;

                        //Calculate Total Count based on selected shipping details++++
                        if (Rec."Shipment Date" <> 0D) and (Rec."Shipping Agent Code" <> '') and (Rec."Shipping Agent Service Code" <> '') then begin
                            CalculateOrderDetails(Rec);
                        end else
                            TotalOrderCount := 0;
                    end;
                }
                field("Weekend Shipping Agent Code"; Rec."Weekend Shipping Agent Code")
                {
                    ApplicationArea = All;
                    ShowMandatory = true;

                    trigger OnValidate()
                    var
                    begin
                        if Rec."Weekend Shipping Agent Code" <> '' then begin
                            //Remove shipping agent service code+++
                            Rec."Weekend Shipping Service Code" := '';

                            //Check Shipment Date Value+++
                            if Rec."Shipment Date" = 0D then
                                Error('Shipment Date Should not be blank');

                            //Check Shipment date if it is weekend date+++
                            if (Format(Rec."Shipment Date", 0, '<Weekday Text>') <> 'Saturday') AND (Format(Rec."Shipment Date", 0, '<Weekday Text>') <> 'Sunday') then begin
                                Error('Selection of a Weekend Shipping Agent Code is not allowed for shipment dates "%1" that fall on weekdays.', Rec."Shipment Date");
                            end;

                            #region Check Weekend shipping details if entering shipping agent code++
                            if Rec."Shipping Agent Code" <> '' then
                                Error('Shipping Agent Code should be blank');

                            if Rec."Shipping Agent Service Code" <> '' then
                                Error('Shipping Agent Service Code should be blank');
                            #Endregion Check Weekend shipping details if entering shipping agent code++
                        end;

                        //Calculate Total Count based on selected shipping details++++
                        if (Rec."Shipment Date" <> 0D) and (Rec."Weekend Shipping Agent Code" <> '') and (Rec."Weekend Shipping Service Code" <> '') then begin
                            CalculateOrderDetails(Rec);
                        end else
                            TotalOrderCount := 0;
                    end;
                }
                field("Weekend Shipping Service Code"; REc."Weekend Shipping Service Code")
                {
                    ApplicationArea = All;
                    ShowMandatory = true;

                    trigger OnValidate()
                    var
                    begin
                        if Rec."Weekend Shipping Service Code" <> '' then begin
                            //Check Weekend Shipping Agent Code value+++
                            if Rec."Weekend Shipping Agent Code" = '' then begin
                                Error('Shipping Agent Code should not be blank');
                            end;

                            #region Check Weekend shipping details if entering shipping agent code++
                            if Rec."Shipping Agent Code" <> '' then
                                Error('Shipping Agent Code should be blank');

                            if Rec."Shipping Agent Service Code" <> '' then
                                Error('Shipping Agent Service Code should be blank');
                            #Endregion Check Weekend shipping details if entering shipping agent code++
                        end;

                        //Calculate Total Count based on selected shipping details++++
                        if (Rec."Shipment Date" <> 0D) and (Rec."Weekend Shipping Agent Code" <> '') and (Rec."Weekend Shipping Service Code" <> '') then begin
                            CalculateOrderDetails(Rec);
                        end else
                            TotalOrderCount := 0;
                    end;
                }
                group("Total Orders Details")
                {
                    field(TotalOrderCount; TotalOrderCount)
                    {
                        Caption = 'Total Jobs';
                        ApplicationArea = All;
                        Editable = false;
                    }
                }
            }
        }
    }

    trigger OnOpenPage()
    var
    begin
        Clear(TotalOrderCount);
    end;

    local procedure CalculateOrderDetails(var P_OrderFilterTable: Record "Sync ePODJob Table")
    var
        L_SalesInvoiceHeader: Record "Sales Invoice Header";
    begin
        Clear(TotalOrderCount);
        Clear(L_SalesInvoiceHeader);
        L_SalesInvoiceHeader.Reset();
        L_SalesInvoiceHeader.SetRange("Shipment Date", P_OrderFilterTable."Shipment Date");
        L_SalesInvoiceHeader.SetRange("Customer Synced", P_OrderFilterTable."Customer Sync");
        L_SalesInvoiceHeader.SetRange("Route Synced", P_OrderFilterTable."Route Sync");
        L_SalesInvoiceHeader.SetRange("ePOD Sync", false);
        if P_OrderFilterTable."Weekend Shipping Agent Code" <> '' then begin
            L_SalesInvoiceHeader.SetRange("Weekend Shipping Agent Code", P_OrderFilterTable."Weekend Shipping Agent Code");
            L_SalesInvoiceHeader.SetFilter("Weekend Ship. Agnt. Serv. Code", P_OrderFilterTable."Weekend Shipping Service Code");
        end else begin
            L_SalesInvoiceHeader.SetRange("Shipping Agent Code", P_OrderFilterTable."Shipping Agent Code");
            L_SalesInvoiceHeader.SetFilter("Shipping Agent Service Code", P_OrderFilterTable."Shipping Agent Service Code");
        end;
        if L_SalesInvoiceHeader.FindSet() then
            TotalOrderCount := L_SalesInvoiceHeader.Count;
    end;

    var
        TotalOrderCount: Integer;
}