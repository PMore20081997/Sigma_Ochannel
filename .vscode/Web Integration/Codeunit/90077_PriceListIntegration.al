codeunit 90077 "Price List Integration"
{
    SingleInstance = true;
    trigger OnRun()
    begin
    end;

    procedure CalculateUnitPrice(L_InterimSalesHeader: Record "Interim Sales Header"; var L_InterimSalesLine: Record "Interim Sales Line")
    var
        L_TempSalesHeader: Record "Sales Header" temporary;
        L_TempSalesLine: Record "Sales Line" temporary;
        L_Customer: Record Customer;

    begin
        OldFeatureSalesPrice := false;
        NewFeatureSalesPrice := false;
        L_TempSalesLine.DeleteAll();
        //if No <> L_InterimSalesHeader."No." then begin
        L_TempSalesHeader.DeleteAll();
        L_TempSalesHeader.Init();
        L_TempSalesHeader."No." := L_InterimSalesHeader."No.";
        L_TempSalesHeader."Document Type" := L_TempSalesHeader."Document Type"::Order;
        L_TempSalesHeader."Sell-to Customer No." := L_InterimSalesHeader."Sell-to Customer No.";
        L_TempSalesHeader."Bill-to Customer No." := L_InterimSalesHeader."Sell-to Customer No.";
        L_TempSalesHeader."Currency Code" := L_InterimSalesHeader."Currency Code";
        L_TempSalesHeader.Insert(true);
        //No := L_InterimSalesHeader."No.";
        //end;

        if L_InterimSalesLine.Type = L_InterimSalesLine.Type::Item then begin
            L_TempSalesLine.init();
            L_TempSalesLine."Document Type" := L_TempSalesLine."Document Type"::Order;
            L_TempSalesLine."Document No." := L_TempSalesHeader."No.";
            L_TempSalesLine."Line No." := L_InterimSalesLine."Line No.";
            L_TempSalesLine.Type := L_TempSalesLine.Type::Item;
            L_TempSalesLine."Sell-to Customer No." := L_TempSalesHeader."Sell-to Customer No.";
            L_TempSalesLine."Bill-to Customer No." := L_TempSalesHeader."Sell-to Customer No.";
            L_Customer.Reset();
            L_Customer.SetRange("No.", L_InterimSalesLine."Sell-to Customer No.");
            if L_Customer.FindFirst() then
                L_TempSalesLine."Customer Price Group" := L_Customer."Customer Price Group";
            L_TempSalesLine.SetSalesHeader(L_TempSalesHeader);
            L_TempSalesLine."No." := L_InterimSalesLine."No.";
            L_TempSalesLine."Variant Code" := L_InterimSalesLine."NAV Variant code";
            L_TempSalesLine.Validate(Quantity, L_InterimSalesLine.Quantity);
            L_TempSalesLine.Insert(true);

            FeatureKey.Reset();
            FeatureKey.SetRange(ID, 'SalesPrices');
            if FeatureKey.FindFirst() then begin
                if FeatureKey.Enabled = FeatureKey.Enabled::"All Users" then begin
                    if NewFeatureSalesPrice then
                        L_InterimSalesLine."Unit Price" := 0
                    else
                        L_InterimSalesLine.Validate("Unit Price", L_TempSalesLine."Unit Price")
                end
                else begin
                    if OldFeatureSalesPrice then
                        L_InterimSalesLine."Unit Price" := 0
                    else
                        L_InterimSalesLine.Validate("Unit Price", L_TempSalesLine."Unit Price")
                end;
            end;
        end;
    end;


    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Sales Price Calc. Mgt.", 'OnAfterCalcBestUnitPriceAsItemUnitPrice', '', false, false)]
    local procedure OnAfterCalcBestUnitPriceAsItemUnitPrice(var SalesPrice: Record "Sales Price"; var Item: Record Item)
    begin
        OldFeatureSalesPrice := true;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Price Calculation - V16", 'OnAfterPickBestLine', '', false, false)]
    local procedure OnAfterPickBestLine(AmountType: Enum "Price Amount Type"; PriceListLine: Record "Price List Line"; var BestPriceListLine: Record "Price List Line"; var FoundBestLine: Boolean)
    begin
        if not FoundBestLine then
            NewFeatureSalesPrice := true;
    end;


    var
        No: Code[20];
        OldFeatureSalesPrice: Boolean;
        NewFeatureSalesPrice: Boolean;
        ChackHeader: Boolean;
        FeatureKey: Record "Feature Key";
}