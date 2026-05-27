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
            CalcFormula = sum("Interim Sales Line"."Qty. to Deliver" where("Document Type" = const(Order), Type = const(Item), "No." = field("No."), "Reason Code" = filter('Order line created|Partial Quantity Delivered'), "Sales Order Created" = const(false), "Consolidated Order" = const(false)));
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
        modify("Min Sell Price")
        {
            trigger OnAfterValidate()
            var
                L_ChannelItemListing: Record "Channel Item Listing";
            begin
                #Region LifeRay Integration+++
                if xRec."Min Sell Price" <> Rec."Min Sell Price" then begin
                    L_ChannelItemListing.Reset();
                    L_ChannelItemListing.SetRange("Item No.", Rec."No.");
                    L_ChannelItemListing.SetRange("Channel Code", 'LIFERAY');
                    if L_ChannelItemListing.FindSet() then begin
                        repeat
                            L_ChannelItemListing.Validate("Min Sell Price", Rec."Min Sell Price");
                            L_ChannelItemListing."Item Sync" := false;
                            L_ChannelItemListing.Modify();
                        until L_ChannelItemListing.Next() = 0;
                    end;
                end;
                #EndRegion LifeRay Integration+++
            end;
        }
        modify("Unit Price")
        {
            trigger OnAfterValidate()
            var
                L_ChannelItemListing: Record "Channel Item Listing";
            begin
                #Region LifeRay Integration+++
                if xRec."Unit Price" <> Rec."Unit Price" then begin
                    L_ChannelItemListing.Reset();
                    L_ChannelItemListing.SetRange("Item No.", Rec."No.");
                    L_ChannelItemListing.SetRange("Channel Code", 'LIFERAY');
                    if L_ChannelItemListing.FindSet() then begin
                        repeat
                            L_ChannelItemListing.Validate("Unit Price", Rec."Unit Price");
                            L_ChannelItemListing."Item Sync" := false;
                            L_ChannelItemListing.Modify();
                        until L_ChannelItemListing.Next() = 0;
                    end;
                end;
                #EndRegion LifeRay Integration+++


                #Region SigConnect Integration+++
                if xRec."Unit Price" <> Rec."Unit Price" then begin
                    L_ChannelItemListing.Reset();
                    L_ChannelItemListing.SetRange("Item No.", Rec."No.");
                    L_ChannelItemListing.SetRange("Channel Code", 'SIGCONNECT');
                    if L_ChannelItemListing.FindSet() then begin
                        repeat
                            L_ChannelItemListing."Unit Price" := Rec."Unit Price";
                            L_ChannelItemListing."Item Sync" := false;
                            L_ChannelItemListing.Modify();
                        until L_ChannelItemListing.Next() = 0;
                    end;
                end;
                #EndRegion SigConnect Integration+++
            end;
        }
        modify(RRP)
        {
            trigger OnAfterValidate()
            var
                L_ChannelItemListing: Record "Channel Item Listing";
            begin
                #Region LifeRay Integration+++
                if xRec.RRP <> Rec.RRP then begin
                    L_ChannelItemListing.Reset();
                    L_ChannelItemListing.SetRange("Item No.", Rec."No.");
                    L_ChannelItemListing.SetRange("Channel Code", 'LIFERAY');
                    if L_ChannelItemListing.FindSet() then begin
                        repeat
                            L_ChannelItemListing.Validate(RRP, Rec.RRP);
                            L_ChannelItemListing."Item Sync" := false;
                            L_ChannelItemListing.Modify();
                        until L_ChannelItemListing.Next() = 0;
                    end;
                end;
                #EndRegion LifeRay Integration+++

                #Region SigConnect Integration+++
                if xRec.RRP <> Rec.RRP then begin
                    L_ChannelItemListing.Reset();
                    L_ChannelItemListing.SetRange("Item No.", Rec."No.");
                    L_ChannelItemListing.SetRange("Channel Code", 'SIGCONNECT');
                    if L_ChannelItemListing.FindSet() then begin
                        repeat
                            L_ChannelItemListing.RRP := Rec.RRP;
                            L_ChannelItemListing."Item Sync" := false;
                            L_ChannelItemListing.Modify();
                        until L_ChannelItemListing.Next() = 0;
                    end;
                end;
                #EndRegion SigConnect Integration+++
            end;
        }
        modify(Description)
        {
            trigger OnAfterValidate()
            var
                L_ChannelItemListing: Record "Channel Item Listing";
            begin
                #Region LifeRay Integration+++
                if xRec.Description <> Rec.Description then begin
                    L_ChannelItemListing.Reset();
                    L_ChannelItemListing.SetRange("Item No.", Rec."No.");
                    L_ChannelItemListing.SetRange("Channel Code", 'LIFERAY');
                    if L_ChannelItemListing.FindSet() then begin
                        repeat
                            L_ChannelItemListing.Validate(Description, Rec.Description);
                            L_ChannelItemListing."Item Sync" := false;
                            L_ChannelItemListing.Modify();
                        until L_ChannelItemListing.Next() = 0;
                    end;
                end;
                #EndRegion LifeRay Integration+++

                #Region SigConnect Integration+++
                if xRec.Description <> Rec.Description then begin
                    L_ChannelItemListing.Reset();
                    L_ChannelItemListing.SetRange("Item No.", Rec."No.");
                    L_ChannelItemListing.SetRange("Channel Code", 'SIGCONNECT');
                    if L_ChannelItemListing.FindSet() then begin
                        repeat
                            L_ChannelItemListing.Description := Rec.Description;
                            L_ChannelItemListing."Item Sync" := false;
                            L_ChannelItemListing.Modify();
                        until L_ChannelItemListing.Next() = 0;
                    end;
                end;
                #EndRegion SigConnect Integration+++
            end;
        }
        modify("Item Category Code")
        {
            trigger OnAfterValidate()
            var
                L_ChannelItemListing: Record "Channel Item Listing";
            begin
                #Region LifeRay Integration+++
                if xRec."Item Category Code" <> Rec."Item Category Code" then begin
                    L_ChannelItemListing.Reset();
                    L_ChannelItemListing.SetRange("Item No.", Rec."No.");
                    L_ChannelItemListing.SetRange("Channel Code", 'LIFERAY');
                    if L_ChannelItemListing.FindSet() then begin
                        repeat
                            L_ChannelItemListing.Validate("Item Category Code", Rec."Item Category Code");
                            L_ChannelItemListing."Item Sync" := false;
                            L_ChannelItemListing.Modify();
                        until L_ChannelItemListing.Next() = 0;
                    end;
                end;
                #EndRegion LifeRay Integration+++


                #Region SigConnect Integration+++
                if xRec."Item Category Code" <> Rec."Item Category Code" then begin
                    L_ChannelItemListing.Reset();
                    L_ChannelItemListing.SetRange("Item No.", Rec."No.");
                    L_ChannelItemListing.SetRange("Channel Code", 'SIGCONNECT');
                    if L_ChannelItemListing.FindSet() then begin
                        repeat
                            L_ChannelItemListing."Item Category Code" := Rec."Item Category Code";
                            L_ChannelItemListing."Item Sync" := false;
                            L_ChannelItemListing.Modify();
                        until L_ChannelItemListing.Next() = 0;
                    end;
                end;
                #EndRegion SigConnect Integration+++
            end;
        }
        modify("Sales Blocked")
        {
            trigger OnAfterValidate()
            var
                L_ChannelItemListing: Record "Channel Item Listing";
            begin
                #Region LifeRay Integration+++
                if xRec."Sales Blocked" <> Rec."Sales Blocked" then begin
                    L_ChannelItemListing.Reset();
                    L_ChannelItemListing.SetRange("Item No.", Rec."No.");
                    L_ChannelItemListing.SetRange("Channel Code", 'LIFERAY');
                    if L_ChannelItemListing.FindSet() then begin
                        repeat
                            L_ChannelItemListing.Validate("Sales Blocked", Rec."Sales Blocked");
                            L_ChannelItemListing."Item Sync" := false;
                            L_ChannelItemListing.Modify();
                        until L_ChannelItemListing.Next() = 0;
                    end;
                end;
                #EndRegion LifeRay Integration+++
            end;
        }
        modify("Ops Sales Blocked")
        {
            trigger OnAfterValidate()
            var
                L_ChannelItemListing: Record "Channel Item Listing";
            begin
                #Region LifeRay Integration+++
                if xRec."Ops Sales Blocked" <> Rec."Ops Sales Blocked" then begin
                    L_ChannelItemListing.Reset();
                    L_ChannelItemListing.SetRange("Item No.", Rec."No.");
                    L_ChannelItemListing.SetRange("Channel Code", 'LIFERAY');
                    if L_ChannelItemListing.FindSet() then begin
                        repeat
                            L_ChannelItemListing.Validate("Ops Sales Blocked", Rec."Ops Sales Blocked");
                            L_ChannelItemListing."Item Sync" := false;
                            L_ChannelItemListing.Modify();
                        until L_ChannelItemListing.Next() = 0;
                    end;
                end;
                #EndRegion LifeRay Integration+++
            end;
        }
        modify("Minimum Order Quantity")
        {
            trigger OnAfterValidate()
            var
                L_ChannelItemListing: Record "Channel Item Listing";
            begin
                #Region LifeRay Integration+++
                if xRec."Minimum Order Quantity" <> Rec."Minimum Order Quantity" then begin
                    L_ChannelItemListing.Reset();
                    L_ChannelItemListing.SetRange("Item No.", Rec."No.");
                    L_ChannelItemListing.SetRange("Channel Code", 'LIFERAY');
                    if L_ChannelItemListing.FindSet() then begin
                        repeat
                            L_ChannelItemListing.Validate("Lowstock Threshold", Rec."Minimum Order Quantity");
                            L_ChannelItemListing."Item Sync" := false;
                            L_ChannelItemListing.Modify();
                        until L_ChannelItemListing.Next() = 0;
                    end;
                end;
                #EndRegion LifeRay Integration+++
            end;
        }
        modify("Pack Size")
        {
            trigger OnAfterValidate()
            var
                L_ChannelItemListing: Record "Channel Item Listing";
            begin
                #Region LifeRay Integration+++
                if xRec."Pack Size" <> Rec."Pack Size" then begin
                    L_ChannelItemListing.Reset();
                    L_ChannelItemListing.SetRange("Item No.", Rec."No.");
                    L_ChannelItemListing.SetRange("Channel Code", 'LIFERAY');
                    if L_ChannelItemListing.FindSet() then begin
                        repeat
                            L_ChannelItemListing.Validate("Pack Size", Rec."Pack Size");
                            L_ChannelItemListing."Item Sync" := false;
                            L_ChannelItemListing.Modify();
                        until L_ChannelItemListing.Next() = 0;
                    end;
                end;
                #EndRegion LifeRay Integration+++
            end;
        }
    }

    trigger OnDelete()
    var
        L_ChannelItemListing: Record "Channel Item Listing";
    begin
        L_ChannelItemListing.Reset();
        L_ChannelItemListing.SetRange("Item No.", Rec."No.");
        //L_ChannelItemListing.SetRange("Channel Code", 'LIFERAY');
        if L_ChannelItemListing.FindSet() then begin
            if not Confirm(StrSubstNo('Item No. “%1” is linked to the PMR channel item listing. If you delete this item, it will be marked as inactive in the PMR channel item listing. Do you want to continue?', Rec."No."), true) then
                exit;

            //++Update++
            repeat
                L_ChannelItemListing.Status := L_ChannelItemListing.Status::Inactive;
                L_ChannelItemListing."Item Sync" := false;
                L_ChannelItemListing.Modify();
            until L_ChannelItemListing.Next() = 0;
        end;
    end;
}