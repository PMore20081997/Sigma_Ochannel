page 90083 "Download Return Label"
{
    DeleteAllowed = false;
    PageType = Worksheet;
    SourceTable = "Return Label";
    SourceTableView = SORTING("Entry No.")
                      ORDER(Descending);

    layout
    {
        area(Content)
        {
            group("Option")
            {
                ShowCaption = false;
                field("Channel Code"; Rec."Channel Code")
                {
                    ApplicationArea = All;
                    Editable = true;
                }
            }

            part("Handled Web Order Detail"; "Handled Web Order Detail")
            {
                ApplicationArea = All;
                SubPageLink = "Trade Partner Code" = field("Channel Code");
            }

        }

    }

    trigger OnOpenPage()
    begin
        RN.Reset();
        RN.SetRange("User ID", UserId);
        if NOT RN.FindFirst() then begin
            RN.Init();
            RN."Entry No." := 1;
            RN."User ID" := UserId;
            RN.Insert(true);
        end;
    end;

    trigger OnClosePage()
    begin
        RN.Reset();
        RN.SetRange("User ID", UserId);
        if RN.FindFirst() then
            RN.Delete();
    end;

    var
        RN: Record "Return Label";
}