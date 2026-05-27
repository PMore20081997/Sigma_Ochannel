tableextension 90030 "OC Item Reference" extends "Item Reference"
{
    fields
    {
        field(90000; "Listing Status Setting"; Option)
        {
            DataClassification = ToBeClassified;
            OptionMembers = Inactive,Active;
            OptionCaptionML = ENU = 'Inactive,Active', ENG = 'Inactive,Active';
            trigger OnValidate()
            var
                L_ChannelItemListing: Record "Channel Item Listing";
            begin
                if Rec."Reference Type" = "Reference Type"::"PIP Code" then begin
                    #Region SigConnect Integration+++
                    if Rec."Listing Status Setting" = xRec."Listing Status Setting" then begin
                        Rec.Synced := false;
                    end;
                    #EndRegion SigConnect Integration+++


                    // #Region LifeRay Integration+++
                    // if Rec."Listing Status Setting" <> xRec."Listing Status Setting" then begin
                    //     L_ChannelItemListing.Reset();
                    //     L_ChannelItemListing.SetRange("Item No.", Rec."Item No.");
                    //     L_ChannelItemListing.SetRange("Channel Code", 'LIFERAY');
                    //     if L_ChannelItemListing.FindFirst() then begin
                    //         L_ChannelItemListing."Item Sync" := false;
                    //         L_ChannelItemListing.Modify();
                    //     end;
                    // end;
                    // #EndRegion LifeRay Integration+++
                end;
            end;
        }
        field(90001; "Listing Status"; Option)
        {
            DataClassification = ToBeClassified;
            OptionMembers = "Not Listed",Listed;
            OptionCaptionML = ENU = 'Not Listed,Listed', ENG = 'Not Listed,Listed';
        }
        field(90002; Synced; Boolean)
        {

        }
        modify("Reference No.")
        {
            trigger OnAfterValidate()
            var
                i: Integer;
                Char: Text[1];
                L_ChannelItemListing: Record "Channel Item Listing";
            begin
                if Rec."Reference Type" = Rec."Reference Type"::"PIP Code" then begin
                    for i := 1 to StrLen(Rec."Reference No.") do begin
                        Char := CopyStr(Rec."Reference No.", i, 1);
                        if (Char < '0') or (Char > '9') then
                            Error('Invalid PIP Code. Reference No. must contain only numbers. Dashes and special characters are not allowed.');
                    end;

                    if StrLen(Rec."Reference No.") <> 7 then
                        Error('Invalid PIP Code. Reference No. must be of 7 digits.');


                    #Region LifeRay Integration+++
                    if Rec."Reference No." <> xRec."Reference No." then begin
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
            end;
        }
    }

    trigger OnDelete()
    var
        L_ChannelItemListing: Record "Channel Item Listing";
    begin
        #Region LifeRay Integration+++
        if Rec."Reference Type" = "Reference Type"::"PIP Code" then begin
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