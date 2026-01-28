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
            begin
                if Rec."Listing Status Setting" = Rec."Listing Status Setting"::Inactive then
                    Rec.Synced := false;
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
            begin
                if Rec."Reference Type" = Rec."Reference Type"::"PIP Code" then begin
                    for i := 1 to StrLen(Rec."Reference No.") do begin
                        Char := CopyStr(Rec."Reference No.", i, 1);
                        if (Char < '0') or (Char > '9') then
                            Error('Invalid PIP Code. Reference No. must contain only numbers. Dashes and special characters are not allowed.');
                    end;

                    if StrLen(Rec."Reference No.") <> 7 then
                        Error('Invalid PIP Code. Reference No. must be of 7 digits.');
                end;
            end;
        }
    }
}