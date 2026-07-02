codeunit 90019 "Manage Channel Customer List"
{
    //Manage Customer Price API++
    [EventSubscriber(ObjectType::Table, Database::"Price List Line", 'OnAfterModifyEvent', '', false, false)]
    local procedure OnAfterCopyToPriceSource(var Rec: Record "Price List Line"; var xRec: Record "Price List Line"; RunTrigger: Boolean);
    var
        PriceListManagement: Codeunit "Price List Management";
        PriceListHeader: Record "Price List Header";
    begin
        if GuiAllowed = false then begin
            PriceListHeader.Reset();
            PriceListHeader.SetRange(Code, Rec."Price List Code");
            if PriceListHeader.FindFirst() then
                PriceListManagement.ActivateDraftLines(PriceListHeader)
            else
                Error('in');
        end;
        // else
        //     Error('Out');
    end;


    //Manage Customers API++
    Procedure CreateChannelCustomerlistingForMultipleSelection(VAR _Customer: Record Customer)
    var
        SelectTradePartner: FilterPageBuilder;
        TradePartner: Record "Trade Partner";
        VarDefaultVeiw: Text;
        TradePartner2: Record "Trade Partner";
        InterimCustomer: Record "Interim Customer";
        Billto_Customer: Record Customer;
        L_Dimension: Record "Default Dimension";
    begin
        TradePartner.RESET;
        TradePartner.SETRANGE("Partner Type", TradePartner."Partner Type"::Channel);
        IF TradePartner.FINDSET THEN BEGIN
            VarDefaultVeiw := TradePartner.GETVIEW;
            SelectTradePartner.ADDTABLE('Trade Partner', DATABASE::"Trade Partner");
            SelectTradePartner.SETVIEW('Trade Partner', VarDefaultVeiw);
            SelectTradePartner.ADDFIELD('Trade Partner', TradePartner.Code, '');
            IF SelectTradePartner.RUNMODAL = TRUE THEN BEGIN
            END;
            TradePartner2.SETVIEW(SelectTradePartner.GETVIEW('Trade Partner'));
            IF TradePartner2.GETFILTER(Code) = '' THEN
                EXIT;
            IF TradePartner2.FINDFIRST THEN
                REPEAT
                    if _Customer.FindSet() then
                        repeat
                            InterimCustomer.Reset();
                            InterimCustomer.SetRange("Channel Code", TradePartner2.Code);
                            //InterimCustomer.SetRange("No.", _Customer."No.");
                            InterimCustomer.SetRange("Customer No.", _Customer."No.");
                            if not InterimCustomer.FindFirst() then begin
                                InterimCustomer.Init();
                                InterimCustomer.Validate("Channel Code", TradePartner2.Code);
                                InterimCustomer.Validate("No.", _Customer."No."); //For Sigma No field Consider as Customer No.
                                InterimCustomer.Validate("Customer No.", _Customer."No.");
                                InterimCustomer.Validate("Concerto Customer No.", _Customer."No.");
                                InterimCustomer.Validate(Name, _Customer.Name);
                                InterimCustomer.Validate(Address, _Customer.Address);
                                InterimCustomer.Validate("Address 2", _Customer."Address 2");
                                InterimCustomer.Validate(City, _Customer.City);
                                InterimCustomer.Validate("Post Code", _Customer."Post Code");
                                InterimCustomer.Validate("Phone No", _Customer."Phone No.");
                                InterimCustomer.Validate("E-Mail", _Customer."E-Mail");
                                InterimCustomer.Validate(Country, _Customer."Country/Region Code");
                                InterimCustomer.Validate(Blocked, _Customer.Blocked);
                                InterimCustomer.Validate("Block Reason", _Customer."Block Reason");
                                InterimCustomer.Validate("Credit Limit Warning", _Customer."Credit Limit Warning");
                                InterimCustomer.Validate("Shipping Agent Code", _Customer."Shipping Agent Code");
                                InterimCustomer.Validate("Shipping Agent Service Code", _Customer."Shipping Agent Service Code");
                                InterimCustomer.Validate("Customer Price Group 1", _Customer."Customer Price Group");
                                InterimCustomer.Validate("Customer Price Group 2", _Customer."Customer Price Group 2");
                                InterimCustomer.Validate("Customer Price Group 3", _Customer."Customer Price Group 3");
                                InterimCustomer.Validate("Customer Price Group 4", _Customer."Customer Price Group 4");
                                InterimCustomer.Validate("Customer Price Group 5", _Customer."Customer Price Group 5");
                                InterimCustomer.Validate("Customer Price Group 6", _Customer."Customer Price Group 6");
                                InterimCustomer.Validate("Customer Price Group 7", _Customer."Customer Price Group 7");
                                InterimCustomer.Validate("Customer Price Group 8", _Customer."Customer Price Group 8");
                                InterimCustomer.Validate("Customer Price Group 9", _Customer."Customer Price Group 9");
                                InterimCustomer.Validate("Customer Price Group 10", _Customer."Customer Price Group 10");
                                InterimCustomer."Min Order Value" := _Customer."Min Order Value";
                                InterimCustomer."Credit Limit (LCY)" := _Customer."Credit Limit (LCY)";
                                if _Customer."Bill-to Customer No." <> '' then begin
                                    InterimCustomer.Validate("Bill to Customer No.", _Customer."Bill-to Customer No.");
                                    if Billto_Customer.Get(_Customer."Bill-to Customer No.") then begin
                                        InterimCustomer.Validate("Bill to Customer Name", Billto_Customer.Name);
                                        InterimCustomer.Validate("Billing Address", Billto_Customer.Address);
                                        InterimCustomer.Validate("Billing Address 2", Billto_Customer."Address 2");
                                        InterimCustomer.Validate("Billing City", Billto_Customer.City);
                                        InterimCustomer.Validate("Billing Post Code", Billto_Customer."Post Code");
                                        InterimCustomer.Validate("Billing Phone No.", Billto_Customer."Phone No.");
                                        InterimCustomer.Validate("Billing Country", Billto_Customer."Country/Region Code");
                                    end;
                                end else begin
                                    //InterimCustomer.Validate("Bill to Customer No.", _Customer."No.");
                                    //InterimCustomer.Validate("Bill to Customer Name", _Customer.Name);
                                    InterimCustomer.Validate("Bill to Customer No.", '');
                                    InterimCustomer.Validate("Bill to Customer Name", '');
                                end;

                                L_Dimension.Reset();
                                L_Dimension.SetRange("Table ID", DATABASE::Customer);
                                L_Dimension.SetRange("No.", _Customer."No.");
                                L_Dimension.SetRange("Dimension Code", 'CUSTOMER TYPE');
                                if L_Dimension.FindFirst() then begin
                                    L_Dimension.CalcFields("Dimension Value Name");
                                    InterimCustomer."Customer Type" := L_Dimension."Dimension Value Name";
                                end;
                                InterimCustomer.Validate("Listing Status", InterimCustomer."Listing Status"::"Not Listed");
                                InterimCustomer."Listing Status Setting" := InterimCustomer."Listing Status Setting"::Active;
                                InterimCustomer.Insert();
                            end;
                        until _Customer.Next() = 0;
                UNTIL TradePartner2.NEXT = 0;
            MESSAGE('Customers added in channel Customer listing successfully.');
        END;
    end;
}