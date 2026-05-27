tableextension 90096 "Item Variant Ext" extends "Item Variant"
{
    fields
    {
        field(90000; "VAT Prod Posting Group"; Code[20])
        {
            TableRelation = "VAT Product Posting Group";
        }
        field(90001; "Shelf No."; Code[20])
        {
        }
        field(90002; "Web Orders Qty"; Decimal)
        {
            FieldClass = FlowField;
            CalcFormula = sum("Interim Sales Line"."Qty. to Deliver" where("Document Type" = const(Order), Type = const(Item), "No." = field("Item No."), "Reason Code" = filter('Order line created|Partial Quantity Delivered'), "Sales Order Created" = const(false), "Consolidated Order" = const(false)));
            DecimalPlaces = 0 : 5;
            Editable = false;
        }

        modify(Code)
        {
            trigger OnAfterValidate()
            var
                L_ChannelItemListing: Record "Channel Item Listing";
                test: Page "Item Variant Card";
            begin
                #Region LifeRay Integration+++
                if Rec.Code <> xRec.Code then begin
                    L_ChannelItemListing.Reset();
                    L_ChannelItemListing.SetRange("Item No.", Rec."Item No.");
                    L_ChannelItemListing.SetRange("Channel Code", 'LIFERAY');
                    if L_ChannelItemListing.FindFirst() then begin
                        L_ChannelItemListing."Item Sync" := false;
                        L_ChannelItemListing.Modify();
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
        #Region LifeRay Integration+++
        L_ChannelItemListing.Reset();
        L_ChannelItemListing.SetRange("Item No.", Rec."Item No.");
        L_ChannelItemListing.SetRange("Channel Code", 'LIFERAY');
        if L_ChannelItemListing.FindFirst() then begin
            L_ChannelItemListing."Item Sync" := false;
            L_ChannelItemListing.Modify();
        end;
        #EndRegion LifeRay Integration+++
    end;
}