tableextension 90022 "OC CustomerTrends" extends "CustomerTrends"
{
    fields
    {
        field(90000; "Web Orders Qty"; Decimal)
        {
            FieldClass = FlowField;
            Editable = false;
            DecimalPlaces = 0 : 5;
            CalcFormula = sum("Interim Sales Line"."Qty. to Deliver" where("Document Type" = const(Order), Type = const(Item), "No." = field("Item No."), "Reason Code" = filter('Order line created|Partial Quantity Delivered'), "Sales Order Created" = const(false), "Consolidated Order" = const(false)));
        }
        modify("Qty. to be added to SO")
        {
            trigger OnAfterValidate()
            var
                L_FreeQty: Decimal;
            begin
                Clear(L_FreeQty);
                if "Qty. to be added to SO" <> 0 then begin
                    //Check Free Quantity (For Both Promotion and Normal Item)++
                    L_FreeQty := G_CT_Function.CT_Onvalidate_Free(Rec);
                    if L_FreeQty < 0 then
                        L_FreeQty := 0;
                    if "Qty. to be added to SO" > L_FreeQty then
                        Error('Quantity to be added to SO should be less than Free Inventory: %1. Item Number: %2.', L_FreeQty, Rec."Item No.");
                end;
            end;
        }
    }

    var
        G_CT_Function: Codeunit "Inventory Calculation";
}