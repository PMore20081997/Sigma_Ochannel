pageextension 90024 "OC Customer Trend Card" extends "Customer Trend Card"
{
    layout
    {
        // Add changes to page layout here
    }

    actions
    {
        // Add changes to page actions here
        addbefore(Comments)
        {
            action("Register Sales Order")
            {
                ApplicationArea = All;
                Image = Register;
                Enabled = Rec."Entry Number" <> '';

                trigger OnAction()
                var
                    CreateUpdateWebOrder: Codeunit "OC Create & Update WebOrder";
                    L_CustomertrendLine: Record CustomerTrends;
                    L_Customer: Record Customer;
                    L_UserSetup: Record "User Setup";
                    L_CustomertrendLine2: Record CustomerTrends;
                    L_Amount: Decimal;
                    L_PriceExist: Boolean;
                    Billtocustomer: Record Customer;
                begin
                    L_PriceExist := false;
                    //Confirmation Message++
                    if not Confirm('Do you want to register?', false) then
                        Error('');

                    //Check Mandatory Fields++
                    Rec.TestField("Delivery Date");
                    Rec.TestField("Salesperson Code");
                    Rec.TestField("Customer No.");
                    Rec.TestField("Shipping Agent Code");
                    Rec.TestField("Shipping Agent Service Code");

                    //Check Line if ready to process++ 
                    L_CustomertrendLine.Reset();
                    L_CustomertrendLine.SetRange("Entry Number", Rec."Entry Number");
                    L_CustomertrendLine.SetFilter("Qty. to be added to SO", '>%1', 0);
                    if L_CustomertrendLine.IsEmpty then
                        Error('Nothing to Register');

                    Clear(L_Amount);
                    L_CustomertrendLine2.Reset();
                    L_CustomertrendLine2.SetRange("Entry Number", Rec."Entry Number");
                    L_CustomertrendLine2.SetFilter("Qty. to be added to SO", '>%1', 0);
                    if L_CustomertrendLine2.FindSet() then begin
                        repeat
                            if L_CustomertrendLine2."Unit Price" = 0 then
                                L_PriceExist := true;
                            L_Amount += L_CustomertrendLine2."Amount Including VAT";
                        until L_CustomertrendLine2.Next() = 0;
                        if L_Amount > 0 then begin
                            L_Customer.Reset();
                            L_Customer.SetRange("No.", Rec."Customer No.");
                            if L_Customer.FindFirst() then begin
                                if L_Customer."Bill-to Customer No." <> '' then begin
                                    Billtocustomer.Reset();
                                    Billtocustomer.SetRange("No.", L_Customer."Bill-to Customer No.");
                                    if Billtocustomer.FindFirst() then begin
                                        if Billtocustomer."Credit Limit (LCY)" > 0 then begin
                                            if Billtocustomer."Credit Limit (LCY)" < L_Amount then
                                                Error('Credit limit should not be exceeded');
                                        end;
                                    end;
                                end else begin
                                    if L_Customer."Credit Limit (LCY)" > 0 then begin
                                        if L_Customer."Credit Limit (LCY)" < L_Amount then
                                            Error('Credit limit should not be exceeded');
                                    end;
                                end;
                            end;
                        end;

                        if L_PriceExist = true then
                            Error('Price should not be zero');
                    end;

                    //Create and Update Web Order++
                    CreateUpdateWebOrder.CreateAndUpdateWebOrder(Rec);
                end;
            }
        }
    }

    var
        myInt: Integer;
}