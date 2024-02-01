page 90035 "Channel Item Reference"
{
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Lists;
    SourceTable = "Item Reference";
    //SourceTableView = where("Reference Type" = filter("PIP Code"));

    layout
    {
        area(Content)
        {
            repeater(GroupName)
            {
                field("Item No."; Rec."Item No.")
                {
                    ApplicationArea = All;

                }
                field("PIP Code"; Rec."Reference No.")
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
                field(Synced; Rec.Synced)
                {
                    ApplicationArea = All;
                }
            }
        }
    }

}