tableextension 90029 "OC Price List Line" extends "Price List Line"
{
    fields
    {
        modify("Unit Price")
        {
            trigger OnAfterValidate()
            var
                L_ChannelPrice: Record "Channel Price";
            begin
                #Region Sigconnect++
                if Rec."Unit Price" <> xRec."Unit Price" then begin
                    Rec."Sync Price" := false;
                    Rec.Modify();
                end;
                #EndRegion Sigconnect++


                #Region LifeRay & Other PMR++
                if (Rec."Unit Price" <> xRec."Unit Price") AND (Rec."Price Type" = Rec."Price Type"::Sale) then begin
                    L_ChannelPrice.Reset();
                    L_ChannelPrice.SetRange("Price List Code", Rec."Price List Code");
                    L_ChannelPrice.SetRange("Line No.", Rec."Line No.");
                    if L_ChannelPrice.FindSet() then begin
                        repeat
                            L_ChannelPrice."Unit Price" := Rec."Unit Price";
                            L_ChannelPrice."Sync Price" := false;
                            L_ChannelPrice.Modify();
                        until L_ChannelPrice.Next() = 0;
                    end;
                end;
                #EndRegion LifeRay & Other PMR++
            end;
        }
        field(90000; "Listing Status Setting"; Option)
        {
            DataClassification = ToBeClassified;
            OptionMembers = Inactive,Active;
            OptionCaptionML = ENU = 'Inactive,Active', ENG = 'Inactive,Active';

            trigger OnValidate()
            var
                L_ChannelPrice: Record "Channel Price";
            begin
                #Region LifeRay & Other PMR++
                if (Rec."Listing Status Setting" <> xRec."Listing Status Setting") AND (Rec."Price Type" = Rec."Price Type"::Sale) then begin
                    L_ChannelPrice.Reset();
                    L_ChannelPrice.SetRange("Price List Code", Rec."Price List Code");
                    L_ChannelPrice.SetRange("Line No.", Rec."Line No.");
                    if L_ChannelPrice.FindSet() then begin
                        repeat
                            L_ChannelPrice."Listing Status Setting" := Rec."Listing Status Setting";
                            L_ChannelPrice."Sync Price" := false;
                            L_ChannelPrice.Modify();
                        until L_ChannelPrice.Next() = 0;
                    end;
                end;
                #EndRegion LifeRay & Other PMR++
            end;
        }
        field(90001; "Listing Status"; Option)
        {
            DataClassification = ToBeClassified;
            OptionMembers = "Not Listed",Listed;
            OptionCaptionML = ENU = 'Not Listed,Listed', ENG = 'Not Listed,Listed';
        }
        field(90002; "Sync Price"; Boolean)
        {
            DataClassification = ToBeClassified;
        }
    }

    trigger OnBeforeInsert()
    var
        L_PriceListHeader: Record "Price List Header";
    begin
        L_PriceListHeader.Reset();
        L_PriceListHeader.SetRange(Code, Rec."Price List Code");
        if L_PriceListHeader.FindFirst() then
            Rec."Listing Status Setting" := L_PriceListHeader."Listing Status Setting";
    end;

    trigger OnAfterDelete()
    var
        L_ChannelPrice: Record "Channel Price";
    begin
        #Region LifeRay & Other PMR++
        if Rec."Price Type" = Rec."Price Type"::Sale then begin
            L_ChannelPrice.Reset();
            L_ChannelPrice.SetRange("Price List Code", Rec."Price List Code");
            L_ChannelPrice.SetRange("Line No.", Rec."Line No.");
            if L_ChannelPrice.FindSet() then begin
                if not Confirm(StrSubstNo('This price line is linked to the PMR channel price. If you delete this price line, it will be marked as inactive in the PMR channel price. Do you want to continue?'), true) then
                    exit;

                //++Update++
                repeat
                    L_ChannelPrice."Listing Status Setting" := L_ChannelPrice."Listing Status Setting"::Inactive;
                    L_ChannelPrice."Sync Price" := false;
                    L_ChannelPrice.Modify();
                until L_ChannelPrice.Next() = 0;
            end;
        end;
        #EndRegion LifeRay & Other PMR++
    end;
}