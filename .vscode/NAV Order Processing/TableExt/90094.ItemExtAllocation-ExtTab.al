tableextension 90094 "Item Ext Allocation" extends Item
{
    fields
    {
        field(90000; "W/H Inventory"; Decimal)
        {
            FieldClass = FlowField;
            Editable = false;
            CalcFormula = Sum("Warehouse Entry"."Qty. (Base)" WHERE("Item No." = FIELD("No."), "Location Code" = FIELD("Location Filter"), "Bin Code" = FIELD("Bin Filter"), "Variant Code" = FIELD("Variant Filter"), "Lot No." = FIELD("Lot No. Filter"), "Serial No." = FIELD("Serial No. Filter"), "Bin Type Code" = filter('PUTPICK|PICK')));
        }
        field(90001; "Ship Bin Inventory"; Decimal)
        {
            FieldClass = FlowField;
            Editable = false;
            CalcFormula = Sum("Warehouse Entry"."Qty. (Base)" WHERE("Item No." = FIELD("No."), "Location Code" = FIELD("Location Filter"), "Bin Code" = FIELD("Bin Filter"), "Variant Code" = FIELD("Variant Filter"), "Lot No." = FIELD("Lot No. Filter"), "Serial No." = FIELD("Serial No. Filter"), "Bin Type Code" = filter('SHIP')));
        }
        field(90002; "Qty. on Web Order"; Decimal)
        {
            FieldClass = FlowField;
            CalcFormula = sum("Interim Sales Line".Quantity where(Type = const(Item), "No." = field("No."), "Reason Code" = filter('Order line created|Partial Quantity Delivered'), "Sales Order Created" = const(false)));
            DecimalPlaces = 0 : 5;
            Editable = false;
        }
        field(90003; "Qty. on Resv Web Order"; Decimal)
        {
            Caption = 'Qty. on Web Order(Reserved)';
            FieldClass = FlowField;
            Editable = false;
            CalcFormula = Sum("Interim Sales Line"."Reserved Qty" WHERE("Document Type" = CONST(Order), Type = CONST(Item), "No." = FIELD("No."), Reserved = CONST(true)));
        }
        field(90004; "Bin Type Filter"; Code[20])
        {
            Caption = 'Bin Type Filter';
            FieldClass = FlowFilter;
            TableRelation = Bin."Bin Type Code" WHERE("Location Code" = FIELD("Location Filter"));
        }
        //Field to Calculate W/H Inventory Without Bin Type Code Filter 
        field(90005; "Inventory Qty."; Decimal)
        {
            FieldClass = FlowField;
            Editable = false;
            CalcFormula = Sum("Warehouse Entry"."Qty. (Base)" WHERE("Item No." = FIELD("No."), "Location Code" = FIELD("Location Filter"), "Bin Type Code" = FIELD("Bin Type Filter"), "Variant Code" = FIELD("Variant Filter"), "Lot No." = FIELD("Lot No. Filter"), "Serial No." = FIELD("Serial No. Filter")));
        }
        field(90006; "Vendor Name"; Text[100])
        {
            FieldClass = FlowField;
            CalcFormula = lookup(Vendor.Name where("No." = field("Vendor No.")));
        }
        field(90007; "WebOrder Status"; Option)
        {
            OptionMembers = ,CONTINUED,DISCONTINUED;
            DataClassification = ToBeClassified;
        }
    }
}