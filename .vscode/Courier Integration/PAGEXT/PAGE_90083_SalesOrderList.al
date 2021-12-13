pageextension 90083 "Sales Order List Ext" extends "Sales Order List"
{
    actions
    {
        addafter(Release)
        {
            action("Shipment Tracking")
            {
                Image = Track;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                ApplicationArea = All;
                trigger OnAction()
                var
                    L_ShipTrack: Record "Shipment Tracking";
                    L_ShipPage: Page "Shipment Tracking";
                begin
                    Clear(L_ShipPage);
                    L_ShipTrack.Reset();
                    L_ShipTrack.SetRange("Document No.", Rec."No.");
                    if L_ShipTrack.FindFirst() then begin
                        L_ShipPage.SetTableView(L_ShipTrack);
                        L_ShipPage.Run();
                    end;
                end;
            }

            action("Generate Shipment Label")
            {
                Image = Shipment;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                ApplicationArea = All;
                trigger OnAction()
                var
                    L_SalesHeader: Record "Sales Header";
                    CU_TNT: Codeunit "TNT Courier";
                begin
                    Clear(L_SalesHeader);
                    L_SalesHeader := Rec;
                    CurrPage.SetSelectionFilter(L_SalesHeader);
                    L_SalesHeader.SetRange(Status, Rec.Status::Open);
                    if L_SalesHeader.FindSet() then begin
                        repeat
                            Temp_SalesHeader.DeleteAll();
                            //SalesHeaderMapping(L_SalesHeader);
                            CU_TNT.CreateConsignment(L_SalesHeader);
                        until L_SalesHeader.Next() = 0;
                        Message('Label Generated Successfully');
                    end;
                end;
            }
        }
    }

    var
        Temp_SalesHeader: Record "Sales Header" temporary;


    local procedure SalesHeaderMapping(P_SalesHeader: Record "Sales Header")
    var
        L_SalesLine: Record "Sales Line";
        Rec_SalesLine: Record "Sales Line";
        Counter: Integer;
        LineCount: Integer;
        L_Location: Record Location;
        L_Item: Record Item;
        L_Weight: Decimal;
        ShippingAgent: Record "Shipping Agent";
    begin
        Counter := 1;
        L_SalesLine.Reset();
        L_SalesLine.SetRange("Document No.", P_SalesHeader."No.");
        if L_SalesLine.FindSet() then begin
            repeat
                Temp_SalesHeader.Init;
                Temp_SalesHeader."Document Type" := P_SalesHeader."Document Type";

                if Counter > 1 then begin
                    Temp_SalesHeader."No." := P_SalesHeader."No." + Format(Counter);
                end
                else begin
                    Temp_SalesHeader."No." := P_SalesHeader."No.";
                end;

                if P_SalesHeader."Shipping Agent Code" <> '' then begin
                    Temp_SalesHeader."Shipping Agent Code" := P_SalesHeader."Shipping Agent Code";
                end
                else begin
                    Error(StrSubstNo('Shipping Agent Code is Blank for Order %1', P_SalesHeader."No."));
                end;

                //For SENDER/LOCATION Details
                if P_SalesHeader."Location Code" <> '' then begin
                    L_Location.Reset();
                    L_Location.SetRange(Code, P_SalesHeader."Location Code");
                    if L_Location.FindFirst() then begin
                        //Dial Code?
                        if (L_Location.Address <> '') and (L_Location.City <> '') and (L_Location.County <> '')
                        and (L_Location."Country/Region Code" <> '') and (L_Location."Post Code" <> '')
                        and (L_Location.Name <> '') and (L_Location."Phone No." <> '') and (L_Location.Contact <> '') then begin
                            Temp_SalesHeader."Bill-to Address" := L_Location.Address;
                            Temp_SalesHeader."Bill-to City" := L_Location.City;
                            Temp_SalesHeader."Bill-to County" := L_Location.County;
                            Temp_SalesHeader."Bill-to Country/Region Code" := L_Location."Country/Region Code";
                            Temp_SalesHeader."Bill-to Post Code" := L_Location."Post Code";
                            Temp_SalesHeader."Bill-to Name 2" := L_Location.Name;  //Company Name
                            Temp_SalesHeader."Bill-to Contact" := L_Location.Contact;  //Contact Name
                            Temp_SalesHeader."Bill-to Contact No." := L_Location."Phone No.";  //Contact Phone No 
                        end
                        else begin
                            Error(StrSubstNo('Address Details Fields are Blank for Location %1', L_Location.Code));
                        end;
                    end
                    else begin
                        Error(StrSubstNo('No Location Details Found for Sales Order %1', P_SalesHeader."No."));
                    end;
                end
                else begin
                    Error(StrSubstNo('Sales Order %1 does not have Location Code on it', P_SalesHeader."No."));
                end;

                if P_SalesHeader."Shipment Date" <> 0D then begin
                    Temp_SalesHeader."Shipment Date" := P_SalesHeader."Shipment Date";
                end
                else begin
                    Error(StrSubstNo('Shipment Date Field is Blank for Sales Order %1', P_SalesHeader."No."));
                end;

                //For RECEIVER Details
                //Phone No?
                //Dial Code?
                if (P_SalesHeader."Ship-to Address" <> '') and (P_SalesHeader."Ship-to City" <> '')
                and (P_SalesHeader."Ship-to Post Code" <> '') and (P_SalesHeader."Ship-to Country/Region Code" <> '')
                and (P_SalesHeader."Ship-to Contact" <> '') then begin
                    Temp_SalesHeader."Ship-to Address" := P_SalesHeader."Ship-to Address";
                    Temp_SalesHeader."Ship-to City" := P_SalesHeader."Ship-to City";
                    Temp_SalesHeader."Ship-to Post Code" := P_SalesHeader."Ship-to Post Code";
                    Temp_SalesHeader."Ship-to Country/Region Code" := P_SalesHeader."Ship-to Country/Region Code";
                    Temp_SalesHeader."Ship-to Contact" := P_SalesHeader."Ship-to Contact";  //Contact Name
                    Temp_SalesHeader."Ship-to Name" := P_SalesHeader."Ship-to Name";  //Cmompany Name
                end
                else begin
                    Error(StrSubstNo('Shipping Address Details are Blank for Sales Order %1', P_SalesHeader."No."));
                end;

                //Total Items Count, and Total Weight
                Clear(LineCount);
                Clear(L_Weight);
                Rec_SalesLine.Reset();
                Rec_SalesLine.SetRange("Document Type", Rec_SalesLine."Document Type"::Order);
                Rec_SalesLine.SetRange(Type, Rec_SalesLine.Type::Item);
                Rec_SalesLine.SetRange("Document No.", P_SalesHeader."No.");
                if Rec_SalesLine.FindSet() then begin
                    repeat
                        L_Item.Reset();
                        L_Item.SetRange("No.", Rec_SalesLine."No.");
                        if L_Item.FindFirst() then begin
                            L_Weight := L_Weight + L_Item."Gross Weight";
                        end;
                    until Rec_SalesLine.Next() = 0;

                    if L_Weight <> 0 then begin
                        Temp_SalesHeader."Payment Discount %" := L_Weight / 1000;  //Total Weight of Items
                    end
                    else begin
                        Error(StrSubstNo('Total Weight for Order %1 is Zero', P_SalesHeader."No."));
                    end;

                    LineCount := Rec_SalesLine.Count;
                    if LineCount <> 0 then begin
                        Temp_SalesHeader."Doc. No. Occurrence" := LineCount;  //Total No of Items for Order
                    end
                    else begin
                        Error('Total Item Count is Zero');
                    end;
                end;

                if (L_SalesLine.Description <> '') and (L_SalesLine."Amount Including VAT" <> 0) then begin
                    Temp_SalesHeader."Prepmt. Posting Description" := L_SalesLine.Description;
                    Temp_SalesHeader."VAT Base Discount %" := L_SalesLine."Amount Including VAT";
                    L_Item.Reset();
                    L_Item.SetRange("No.", L_SalesLine."No.");
                    if L_Item.FindFirst() then begin
                        if (L_Item."Gross Weight" <> 0) and (L_Item."Country/Region of Origin Code" <> '') then begin
                            Temp_SalesHeader."Invoice Discount Value" := L_Item."Gross Weight";
                            Temp_SalesHeader."Payment Terms Code" := L_Item."Country/Region of Origin Code";
                        end
                        else begin
                            Error(StrSubstNo('Either Gross Weight or Country Origin Code is Blank for Item %1', L_Item."No."));
                        end;
                    end;
                end
                else begin
                    Error(StrSubstNo('Either Description or Amount Inc VAT is Blank for Item %1', L_SalesLine."No."));
                end;

                Temp_SalesHeader.Insert();
                Counter := Counter + 1;
            until L_SalesLine.Next() = 0;

            ShippingAgent.Reset();
            ShippingAgent.SetRange(Code, P_SalesHeader."Shipping Agent Code");
            if ShippingAgent.FindFirst() then begin
                Codeunit.Run(ShippingAgent."Procesing Codeunit", Temp_SalesHeader);
            end;
        end;
    end;
}