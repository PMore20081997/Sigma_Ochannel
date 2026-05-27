pageextension 90000 "ItemListExt" extends "Item List"
{
    layout
    {
        addafter(InventoryField)
        {
            field("Qty. on Web Order"; Rec."Qty. on Web Order")
            {
                ApplicationArea = All;
                Editable = false;
                DecimalPlaces = 0 : 5;
                ToolTip = 'Sucessfull Electronic Orders';
            }
        }
    }

    actions
    {
        addlast(processing)
        {

            group("Channel Item Listing Details")
            {
                action("Add to Channel Item List")
                {
                    ApplicationArea = All;
                    Image = Create;
                    trigger OnAction()
                    var
                        G_Item: Record Item;
                        ManageItemListing: Codeunit "Manage Channel Item Listing";
                    begin
                        G_Item := Rec;
                        CurrPage.SETSELECTIONFILTER(G_Item);
                        ManageItemListing.SigmaCreateChannelItemListingForMultipleSelection(G_Item);
                    end;
                }

                action("Open Channel Listing")
                {
                    ApplicationArea = All;
                    Image = Navigate;
                    trigger OnAction()
                    var
                        Page_ChannelItemListing: Page "Channel Item Listing";
                        Table_ChannelItemListing: Record "Channel Item Listing";
                    begin
                        Clear(Page_ChannelItemListing);
                        Table_ChannelItemListing.Reset();
                        Table_ChannelItemListing.SetRange("Item No.", Rec."No.");
                        Page_ChannelItemListing.SetTableView(Table_ChannelItemListing);
                        Page_ChannelItemListing.RunModal();
                    end;
                }

            }
        }

        addbefore(Category_Category7)
        {
            group(Category_Category77)
            {
                Caption = 'Channel Item Listing Details';
                actionref(AddtoChannelItemist; "Add to Channel Item List")
                {
                }
                actionref(OpenChannelListing; "Open Channel Listing")
                {
                }

            }
        }
    }

    var
        myInt: Integer;
}