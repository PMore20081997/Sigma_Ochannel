codeunit 90045 "Update Channel Item Listing"
{
    TableNo = "Job Queue Entry";
    trigger OnRun()
    begin
        StartParameter := Rec."Parameter String";
        if StartParameter <> '' then
            UpdateChannelItemListing(StartParameter, '')
        else
            Error('Parameter String is missing');
    end;

    var
        myInt: Integer;
        StartParameter: Text;

    procedure UpdateChannelItemListing(_ChannelCode: Code[20]; _ItemNo: Code[20])
    var
        L_Modified: Boolean;
        L_ChannelItemListing: Record "Channel Item Listing";
        L_Item: Record Item;
        L_ItemReference: Record "Item Reference";
    begin
        //NOTE-
        //For PIP code & Variant Code - Code written on "Item Referenec" table++ 


        //Clear Variable++
        Clear(L_Modified);

        //Start Process to Update channel Price++    
        L_ChannelItemListing.Reset();
        if _ItemNo <> '' then
            L_ChannelItemListing.SetRange("Item No.", _ItemNo);
        L_ChannelItemListing.SetFilter("Channel Code", _ChannelCode);
        L_ChannelItemListing.SetRange(Status, L_ChannelItemListing.Status::Active);
        L_ChannelItemListing.SetCurrentKey("Channel Code");
        L_ChannelItemListing.Ascending(true);
        if L_ChannelItemListing.FindSet() then begin
            repeat
                L_ChannelItemListing.CalcFields("Item SystemModifiedAt");
                if L_ChannelItemListing."Item SystemModifiedAt" > L_ChannelItemListing.SystemModifiedAt then begin
                    L_Item.Reset();
                    L_Item.SetRange("No.", L_ChannelItemListing."Item No.");
                    if L_Item.FindFirst() then begin
                        //Description++
                        if L_ChannelItemListing.Description <> L_Item.Description then begin
                            L_ChannelItemListing.Description := L_Item.Description;
                            L_Modified := true;
                        end;

                        //Item Category++
                        if L_ChannelItemListing."Item Category Code" <> L_Item."Item Category Code" then begin
                            L_ChannelItemListing."Item Category Code" := L_Item."Item Category Code";
                            L_Modified := true;
                        end;

                        //Sales Blocked++
                        if L_ChannelItemListing."Sales Blocked" <> L_Item."Sales Blocked" then begin
                            L_ChannelItemListing."Sales Blocked" := L_Item."Sales Blocked";
                            L_Modified := true;
                        end;

                        //Ops Sales Blocked++
                        if L_ChannelItemListing."Ops Sales Blocked" <> L_Item."Ops Sales Blocked" then begin
                            L_ChannelItemListing."Ops Sales Blocked" := L_Item."Ops Sales Blocked";
                            L_Modified := true;
                        end;

                        //Blocked++
                        if L_ChannelItemListing.Blocked <> L_Item.Blocked then begin
                            L_ChannelItemListing.Blocked := L_Item.Blocked;
                            if L_Item.Blocked = true then begin
                                L_ChannelItemListing.Status := L_ChannelItemListing.Status::Inactive
                            end else begin
                                L_ChannelItemListing.Status := L_ChannelItemListing.Status::Active;
                            end;
                            L_Modified := true;
                        end;

                        //Inventory Posting Group++
                        if L_ChannelItemListing."Inventory Posting Group" <> L_Item."Inventory Posting Group" then begin
                            L_ChannelItemListing."Inventory Posting Group" := L_Item."Inventory Posting Group";

                            if L_Item."Inventory Posting Group" <> 'FINISHED' then
                                L_ChannelItemListing.Status := L_ChannelItemListing.Status::Inactive
                            else
                                L_ChannelItemListing.Status := L_ChannelItemListing.Status::Active;
                            L_Modified := true;
                        end;

                        //RRP Price++
                        if L_ChannelItemListing.RRP <> L_Item.RRP then begin
                            L_ChannelItemListing.RRP := L_Item.RRP;
                            L_Modified := true;
                        end;

                        //Unit Price++
                        if L_ChannelItemListing."Unit Price" <> L_Item."Unit Price" then begin
                            L_ChannelItemListing."Unit Price" := L_Item."Unit Price";
                            L_Modified := true;
                        end;

                        //Pack Size++
                        if L_ChannelItemListing."Pack Size" <> L_Item."Pack Size" then begin
                            L_ChannelItemListing."Pack Size" := L_Item."Pack Size";
                            L_Modified := true;
                        end;

                        //Strength++
                        if L_ChannelItemListing.Strength <> L_Item.Strength then begin
                            L_ChannelItemListing.Strength := L_Item.Strength;
                            L_Modified := true;
                        end;

                        //Item Configuration++
                        if L_ChannelItemListing."Item Configuration" <> L_Item."Item Configuration" then begin
                            L_ChannelItemListing."Item Configuration" := L_Item."Item Configuration";
                            L_Modified := true;
                        end;

                        #Region Liferay only+++
                        if L_ChannelItemListing."Channel Code" = 'LIFERAY' then begin
                            //For PIP code & Variant Code - Code written on "Item Referenec" table++ 

                            //Min Sell Price++
                            if L_ChannelItemListing."Min Sell Price" <> L_Item."Min Sell Price" then begin
                                L_ChannelItemListing."Min Sell Price" := L_Item."Min Sell Price";
                                L_Modified := true;
                            end;
                        end;
                        #EndRegion Liferay only+++

                        #Region Sigconnect only+++
                        if L_ChannelItemListing."Channel Code" = 'SIGCONNECT' then begin

                        end;
                        #EndRegion Sigconnect only+++

                        if L_Modified = true then begin
                            L_ChannelItemListing."Item Sync" := false;
                            L_ChannelItemListing.Modify();
                        end;
                    end;
                end;
            until L_ChannelItemListing.Next() = 0;
        end;
    end;
}