tableextension 90094 "Item Ext Allocation" extends Item
{
    fields
    {
        field(90100; "W/H Inventory"; Decimal)
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
        field(90101; "Qty. on Web Order"; Decimal)
        {
            Caption = 'Qty. on Web Order(Reserved)';
            FieldClass = FlowField;
            Editable = false;
            CalcFormula = Sum("Interim Sales Line".Quantity WHERE("Document Type" = CONST(Order), Type = CONST(Item), "No." = FIELD("No."), Reserved = CONST(true)));
        }
        field(90105; "Qty. on Resv Web Order"; Decimal)
        {
            Caption = 'Qty. on Web Order(Reserved)';
            FieldClass = FlowField;
            Editable = false;
            CalcFormula = Sum("Interim Sales Line"."Reserved Qty" WHERE("Document Type" = CONST(Order), Type = CONST(Item), "No." = FIELD("No."), Reserved = CONST(true)));
        }

        field(90102; "Bin Type Filter"; Code[20])
        {
            Caption = 'Bin Type Filter';
            FieldClass = FlowFilter;
            TableRelation = Bin."Bin Type Code" WHERE("Location Code" = FIELD("Location Filter"));
        }
        //Field to Calculate W/H Inventory Without Bin Type Code Filter 
        field(90103; "Inventory Qty."; Decimal)
        {
            FieldClass = FlowField;
            Editable = false;
            CalcFormula = Sum("Warehouse Entry"."Qty. (Base)" WHERE("Item No." = FIELD("No."), "Location Code" = FIELD("Location Filter"), "Bin Type Code" = FIELD("Bin Type Filter"), "Variant Code" = FIELD("Variant Filter"), "Lot No." = FIELD("Lot No. Filter"), "Serial No." = FIELD("Serial No. Filter")));
        }

        field(90104; "Vendor Name"; Text[100])
        {
            FieldClass = FlowField;
            CalcFormula = lookup(Vendor.Name where("No." = field("Vendor No.")));
        }
        field(90106; "WebOrder Status"; Option)
        {
            OptionMembers = ,CONTINUED,DISCONTINUED;
            DataClassification = ToBeClassified;
        }
    }
}