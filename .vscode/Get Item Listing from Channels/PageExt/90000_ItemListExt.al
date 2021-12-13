pageextension 90000 ItemListExt extends "Item List"
{
    layout
    {
        // Add changes to page layout here
    }

    actions
    {

        addlast(processing)
        {
            action("Add to Channel Item List")
            {
                ApplicationArea = All;
                Promoted = true;
                PromotedCategory = Process;
                Image = Process;
                trigger OnAction()
                var
                    G_Item: Record Item;
                begin
                    G_Item := Rec;
                    CurrPage.SETSELECTIONFILTER(G_Item);
                    ManageItemListing.CreateChannelItemListingForMultipleSelection(G_Item);
                end;
            }

            action("Channel Listing")
            {
                ApplicationArea = All;
                Promoted = true;
                PromotedCategory = Process;
                Image = EntriesList;
                RunObject = Page "Channel Item Listing";
                RunPageLink = "Item No." = FIELD("No.");
                RunPageOnRec = false;
                trigger OnAction()
                begin
                end;
            }

            action("Add To Item Catelog")
            {
                ApplicationArea = All;
                Visible = false;
                trigger OnAction()
                begin
                    // CurrPage.SETSELECTIONFILTER(Rec);
                    // IF FINDFIRST THEN
                    //     REPEAT
                    //         "Release to Item Catelog" := TRUE;
                    //         MODIFY;
                    //     UNTIL NEXT = 0;
                    // RESET;
                end;
            }
        }

    }

    var
        myInt: Integer;
        ManageItemListing: Codeunit "Manage Channel Item Listing";
}