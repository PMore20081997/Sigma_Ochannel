tableextension 90014 SalesPriceExtension extends "Sales Price"
{
    fields
    {
        field(90000; "RRP"; Decimal)
        {
            Caption = 'RRP';
            DataClassification = ToBeClassified;
            trigger OnValidate()
            var
                L_Item: Record item;
                G_PackSize: Decimal;
                L_ItemUoM: Record "Item Unit of Measure";
                L_SalesRec: Record "Inventory Setup";
                L_SingleUnitPrice: Decimal;
                L_vatAmount: Decimal;
                SalesSetup: Record "Sales & Receivables Setup";
                VATPostingSetup: Record "VAT Posting Setup";
                L_UnitPriceIncVat: Decimal;
            begin
                If L_Item.Get(Rec."Item No.") then begin
                    Clear(G_PackSize);
                    Clear(L_UnitPriceIncVat);
                    Clear(L_vatAmount);
                    If Not Rec."Price Includes VAT" then begin
                        SalesSetup.Get();
                        SalesSetup.TestField("VAT Bus. Posting Gr. (Price)");
                        "VAT Bus. Posting Gr. (Price)" := SalesSetup."VAT Bus. Posting Gr. (Price)";
                        VATPostingSetup.Get("VAT Bus. Posting Gr. (Price)", L_Item."VAT Prod. Posting Group");

                        L_UnitPriceIncVat := ((ROUND((Rec."Unit Price") * (1 + (VATPostingSetup."VAT %" / 100)), 0.01)));
                        L_vatAmount := L_UnitPriceIncVat - Rec."Unit Price";
                    end;

                    G_PackSize := L_Item.Pack;
                    If L_Item.Pack > 0 then begin
                        G_PackSize := L_item.Pack;
                        L_SingleUnitPrice := ((rec."Unit Price" + L_vatAmount) / G_PackSize);
                    end
                    Else begin
                        L_SalesRec.Get();
                        L_ItemUoM.Reset();
                        L_ItemUoM.SetRange("Item No.", Rec."Item No.");
                        L_ItemUoM.SetRange("Code", L_SalesRec."Single Unit of Measure");
                        If L_ItemUoM.FindFirst() then begin
                            G_PackSize := L_item.Pack;
                            L_SingleUnitPrice := ((rec."Unit Price" + L_vatAmount) * G_PackSize);
                        end;
                    end;

                    If "RRP" > 0 then
                        Rec."POR %" := ((rec."RRP" - L_SingleUnitPrice) / Rec."RRP") * 100
                    else
                        Rec."POR %" := 0;
                end;
                /* Clear(G_PackSize);
                 L_Item.SetRange("No.", Rec."Asset No.");
                 if L_Item.FindFirst() then begin
                     G_PackSize := L_Item.Pack;
                 end;

                 Clear(L_SingleUnitPrice);
                 L_SingleUnitPrice := Rec."Unit Price" / G_PackSize;
                 Clear(L_SingleUPriceCalculation);
                 L_SingleUPriceCalculation := (L_SingleUnitPrice * 20) / 100;

                 Rec."POR Price" := (rec."RRP Price" - (L_SingleUPriceCalculation + L_SingleUnitPrice) / Rec."RRP Price") * 100;
                 // POR = ([RRP] - [Price including VAT/PackSize]) / [RRP]*/
            end;
        }
        field(90001; "POR %"; Decimal)
        {
            Caption = 'POR';
            DataClassification = ToBeClassified;
        }
    }
}
