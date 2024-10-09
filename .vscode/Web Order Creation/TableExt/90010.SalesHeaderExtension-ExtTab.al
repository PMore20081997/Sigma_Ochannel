tableextension 90010 "Sales Header Extension" extends "Sales Header"
{
    fields
    {

        modify("Sell-to Customer No.")
        {
            trigger OnAfterValidate()
            var
                L_Date: Record Date;
                L_Customer: Record Customer;
                L_ShippingAgentservices: Record "Shipping Agent Services";
                L_Shift: Text[20];
            begin
                Clear(L_Shift);
                L_Customer.Reset();
                L_Customer.SetRange("No.", Rec."Sell-to Customer No.");
                if L_Customer.FindFirst() then begin
                    //Get Shift++
                    L_Date.Reset();
                    L_Date.SetRange(L_Date."Period Type", L_Date."Period Type"::Date);
                    L_Date.SetRange(L_Date."Period Start", WorkDate());
                    if L_Date.FindFirst() then
                        if UpperCase(L_Date."Period Name") = UpperCase('FRIDAY') then begin
                            L_ShippingAgentservices.Reset();
                            if (L_Customer."Weekend Shipping Agent Code" <> '') AND (L_Customer."Weekend Ship. Agnt. Serv. Code" <> '') then begin
                                L_ShippingAgentservices.SetRange("Shipping Agent Code", L_Customer."Weekend Shipping Agent Code");
                                L_ShippingAgentservices.SetRange(Code, L_Customer."Weekend Ship. Agnt. Serv. Code");
                            end else begin
                                L_ShippingAgentservices.SetRange("Shipping Agent Code", L_Customer."Shipping Agent Code");
                                L_ShippingAgentservices.SetRange(Code, L_Customer."Shipping Agent Service Code");
                            end;
                            if L_ShippingAgentservices.FindFirst() then
                                L_Shift := Format(L_ShippingAgentservices.Shift);
                        end;


                    L_Date.Reset();
                    L_Date.SetRange(L_Date."Period Type", L_Date."Period Type"::Date);
                    L_Date.SetRange(L_Date."Period Start", WorkDate());
                    if L_Date.FindFirst() then
                        if UpperCase(L_Date."Period Name") = UpperCase('FRIDAY') then begin
                            //E - Shift
                            if UpperCase(L_Shift) = UpperCase('E') then begin
                                if (L_Customer."Weekend Shipping Agent Code" <> '') AND (L_Customer."Weekend Ship. Agnt. Serv. Code" <> '') then
                                    //Update Saturday++
                                    Rec.Validate("Shipment Date", CalcDate('<+1D>', WorkDate()))
                                else begin
                                    //Update Monday
                                    Rec.Validate("Shipment Date", CalcDate('<+3D>', WorkDate()));
                                end;
                            end;

                            //A - Shift
                            if UpperCase(L_Shift) = UpperCase('A') then begin
                                //Update Monday
                                Rec.Validate("Shipment Date", CalcDate('<+3D>', WorkDate()));
                            end;

                            //M - Shift
                            //Phase2+++

                            //X - Shift
                            //Phase2+++

                        end else begin
                            //As discussed shipment date shoud be next day all condistion++
                            Rec.Validate("Shipment Date", CalcDate('<+1D>', WorkDate()));

                            // //New Code based on calendar+++
                            // if UpperCase(L_Date."Period Name") = UpperCase('SATURDAY') then begin
                            //     if L_Customer."Base Calendar Code" <> '' then
                            //         Rec.Validate("Shipment Date", Rec.CalcPlannedShptDate(21))
                            //     else begin
                            //         L_ShipingAgentService.Reset();
                            //         L_ShipingAgentService.SetRange("Shipping Agent Code", L_Customer."Shipping Agent Code");
                            //         L_ShipingAgentService.SetRange(Code, L_Customer."Shipping Agent Service Code");
                            //         if L_ShipingAgentService.FindFirst() then begin
                            //             if L_ShipingAgentService."Base Calendar Code" <> '' then
                            //                 Rec.Validate("Shipment Date", Rec.CalcPlannedShptDate(21))
                            //             else
                            //                 //Update Monday
                            //                 Rec.Validate("Shipment Date", CalcDate('<+2D>', WorkDate()));
                            //         end;
                            //     end;
                            // end else begin
                            //     if L_Customer."Base Calendar Code" <> '' then
                            //         Rec.Validate("Shipment Date", Rec.CalcPlannedShptDate(21))
                            //     else begin
                            //         L_ShipingAgentService.Reset();
                            //         L_ShipingAgentService.SetRange("Shipping Agent Code", L_Customer."Shipping Agent Code");
                            //         L_ShipingAgentService.SetRange(Code, L_Customer."Shipping Agent Service Code");
                            //         if L_ShipingAgentService.FindFirst() then begin
                            //             if L_ShipingAgentService."Base Calendar Code" <> '' then
                            //                 Rec.Validate("Shipment Date", Rec.CalcPlannedShptDate(21))
                            //             else begin
                            //                 if L_Customer."Shipping Time" <> L_BlankDatFormula then begin
                            //                     Rec.Validate("Shipment Date", CalcDate(L_Customer."Shipping Time", Rec."Shipment Date"))
                            //                 end else begin
                            //                     L_ShipingAgentService.Reset();
                            //                     L_ShipingAgentService.SetRange("Shipping Agent Code", L_Customer."Shipping Agent Code");
                            //                     L_ShipingAgentService.SetRange(Code, L_Customer."Shipping Agent Service Code");
                            //                     if L_ShipingAgentService.FindFirst() then begin
                            //                         if L_ShipingAgentService."Shipping Time" <> L_BlankDatFormula then
                            //                             Rec.Validate("Shipment Date", CalcDate(L_ShipingAgentService."Shipping Time", Rec."Shipment Date"));
                            //                     end;
                            //                 end;
                            //             end;
                            //         end;
                            //     end;
                            // end;
                        end;
                end;
            end;
        }

        field(90000; "Web Shipment Method"; Code[50])
        {
            DataClassification = ToBeClassified;
        }
        field(90001; "Channel Code"; Code[20])
        {
            DataClassification = ToBeClassified;
        }
        field(90002; SalesOrderReturnNo; Code[20])
        {
            Caption = 'Sales Order Return No.';
            Editable = false;
            DataClassification = ToBeClassified;
        }
        field(90003; "Web Order"; Boolean)
        {
        }
        field(90004; "Marged Web Order"; Boolean)
        {
        }
        field(90005; Export; Boolean)
        {
            DataClassification = ToBeClassified;
            Caption = 'Export';
        }
    }


    // trigger OnDelete()
    // var
    //     InterimSalesHeader: Record "Interim Sales Header";
    //     Return_HISH: Record "Handled Interim Sales Header";
    //     Return_HISL: Record "Handled Interim Sales Line";
    // begin
    //     //DeleteHandledReturnOrder++
    //     if Rec."Document Type" = Rec."Document Type"::"Return Order" then begin
    //         Return_HISH.Reset();
    //         Return_HISH.SetRange("Document Type", Return_HISH."Document Type"::"Return Order");
    //         Return_HISH.SetRange("External Document No.", Rec."No.");
    //         if Return_HISH.FindSet() then begin
    //             repeat
    //                 Return_HISL.Reset();
    //                 Return_HISL.SetRange("Document Type", Return_HISL."Document Type"::"Return Order");
    //                 Return_HISL.SetRange("Document No", Return_HISH."No.");
    //                 if Return_HISL.FindSet() then begin
    //                     repeat
    //                         Return_HISL.Delete(true);
    //                     until Return_HISL.Next() = 0;
    //                 end;
    //                 Return_HISH.Delete(true);
    //             until Return_HISH.Next() = 0;
    //         end;
    //     end;
    //     //DeleteHandledReturnOrder--
    //     InterimSalesHeader.Reset();
    //     InterimSalesHeader.SetRange("Destination Doc Type", InterimSalesHeader."Destination Doc Type"::"Sales Order");
    //     InterimSalesHeader.SetRange("Destination Doc No.", Rec."No.");
    //     if InterimSalesHeader.FindFirst() then begin
    //         InterimSalesHeader."Destination Doc No." := '';
    //         Clear(InterimSalesHeader."Destination Doc Type");
    //         InterimSalesHeader.status := InterimSalesHeader.status::Accepted;
    //         InterimSalesHeader.Modify(true);
    //     end;
    // end;
}