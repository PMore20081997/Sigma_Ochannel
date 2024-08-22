tableextension 90001 "Price List Headers Ext" extends "Price List Header"
{
    fields
    {
        field(90000; "Listing Status Setting"; Option)
        {
            OptionMembers = Inactive,Active;
            OptionCaptionML = ENU = 'Inactive,Active', ENG = 'Inactive,Active';

            trigger OnValidate()
            var
                L_PriceListLine: Record "Price List Line";
            begin
                if (Rec."Drug Special" = true) and (Rec."Listing Status Setting" = Rec."Listing Status Setting"::Active) then
                    Error('You can not Activate the Drug Special Price List');
                L_PriceListLine.Reset();
                L_PriceListLine.SetRange("Price List Code", Rec.Code);
                if L_PriceListLine.FindSet() then begin
                    repeat
                        L_PriceListLine."Listing Status Setting" := Rec."Listing Status Setting";
                        if Rec."Listing Status Setting" = Rec."Listing Status Setting"::Inactive then
                            L_PriceListLine."Sync Price" := false;
                        L_PriceListLine.Modify();
                    until L_PriceListLine.Next() = 0;
                end;
            end;
        }
    }
}