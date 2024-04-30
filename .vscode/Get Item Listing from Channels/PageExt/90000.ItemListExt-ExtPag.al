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
        // Add changes to page layout here
        // addlast(Control1)
        // {
        //     // field("W/H Inventory"; Rec."W/H Inventory")
        //     // {
        //     //     DecimalPlaces = 0;
        //     //     Caption = 'Available Inventory';
        //     //     ApplicationArea = All;
        //     // }




        //     // field("Available Inventory"; Rec."Available Inventory")
        //     // {
        //     //     DecimalPlaces = 0;
        //     //     Caption = 'Available Inventory';
        //     //     ApplicationArea = All;
        //     // }
        // }
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
        addafter(Orders)
        {
            action("PO Stock-Level")
            {
                ApplicationArea = All;
                Image = Sales;
                Promoted = true;
                PromotedIsBig = true;

                trigger OnAction()
                var
                begin
                    Report.RunModal(90095, true, false, Rec);
                end;
            }
        }


    }

    var
        myInt: Integer;
        ManageItemListing: Codeunit "Manage Channel Item Listing";
}