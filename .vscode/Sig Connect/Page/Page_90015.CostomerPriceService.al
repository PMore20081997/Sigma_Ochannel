page 90015 "Customer Price Service"
{
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Administration;
    SourceTable = 7001;
    SourceTableView = where(Status = filter(Active), "Sync Price" = filter(false));

    layout
    {
        area(Content)
        {
            group(GroupName)
            {

                field("Source Type"; Rec."Source Type")
                {
                    ApplicationArea = All;
                }
                field("Source No."; Rec."Source No.")
                {
                    ApplicationArea = all;
                }
                field("Item No."; Rec."Product No.")
                {
                    ApplicationArea = All;
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = All;
                }
                field("Variant Code"; Rec."Variant Code")
                {
                    ApplicationArea = All;
                }
                field("Unit Price"; Rec."Unit Price")
                {
                    ApplicationArea = all;
                }
                field("Sync Price"; Rec."Sync Price")
                {
                    ApplicationArea = All;
                }
            }
        }
    }

    var
        myInt: Integer;
        tes: Page 7016;
}