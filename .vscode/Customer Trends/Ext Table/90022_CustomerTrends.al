tableextension 90022 "OC CustomerTrends" extends "CustomerTrends"
{
    fields
    {
        // Add changes to table fields here
        field(90022; "Web Orders Qty"; Decimal)
        {
            FieldClass = FlowField;
            CalcFormula = sum("Interim Sales Line".Quantity where(Type = const(Item), "No." = field("Item No."), "Reason Message" = filter('Successful|Partial Quantity Delivered'), "Sales Order Created" = const(false)));
            Editable = false;
            DecimalPlaces = 0 : 5;
        }

        modify("Qty. to be added to SO")
        {
            trigger OnAfterValidate()
            begin
                if "Qty. to be added to SO" <> 0 then begin
                    //Check Free Quantity (For Both Promotion and Normal Item)++
                    if "Qty. to be added to SO" > G_CT_Function.CT_Onvalidate_Free(Rec) then
                        Error('Quantity to be added to SO should be less than Free Inventory: %1. Item Number: %2.', G_CT_Function.CT_Onvalidate_Free(Rec), Rec."Item No.");
                end;
            end;
        }
    }

    keys
    {
        // Add changes to keys here
    }

    fieldgroups
    {
        // Add changes to field groups here
    }

    var
        myInt: Integer;
        G_CT_Function: Codeunit "Inventory Calculation";

}