tableextension 90094 "Item Ext Allocation" extends Item
{
    fields
    {
        field(90100; "W/H Inventory"; Decimal)
        {
            FieldClass = FlowField;
            Editable = false;
            CalcFormula = Sum("Warehouse Entry"."Qty. (Base)" WHERE("Item No." = FIELD("No."), "Location Code" = FIELD("Location Filter"), "Bin Code" = FIELD("Bin Filter"), "Variant Code" = FIELD("Variant Filter"), "Lot No." = FIELD("Lot No. Filter"), "Serial No." = FIELD("Serial No. Filter")));
        }
        field(90101; "Qty. on Web Order"; Decimal)
        {
            Caption = 'Qty. on Web Order(Reserved)';
            FieldClass = FlowField;
            Editable = false;

            CalcFormula = Sum("Interim Sales Line".Quantity WHERE("Document Type" = CONST(Order), Type = CONST(Item), "No." = FIELD("No."), Reserved = CONST(true), "Destination Doc No." = FILTER(<> '')));
        }
        field(90102; "Bin Type Filter"; Code[20])
        {
            Caption = 'Bin Type Filter';
            FieldClass = FlowFilter;
            TableRelation = Bin."Bin Type Code" WHERE("Location Code" = FIELD("Location Filter"));
        }
    }
}