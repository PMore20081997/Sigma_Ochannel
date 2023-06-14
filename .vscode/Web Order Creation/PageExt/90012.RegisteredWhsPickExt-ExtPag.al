pageextension 90012 "Registered Whs Pick Ext" extends "Registered Whse. Picks"
{
    layout
    {
        // Add changes to page layout here
        addlast(Control1)
        {
            field("Trolley No."; Rec."Trolley No.")
            {
                ApplicationArea = All;
            }
            field("Trolley Closed"; Rec."Trolley Closed")
            {
                ApplicationArea = All;
            }
            field(SystemCreatedAt; Rec.SystemCreatedAt)
            {
                ApplicationArea = All;
            }
            field(CreateBy; GetUser(Rec.SystemCreatedBy))
            {
                Caption = 'Created By';
                ApplicationArea = All;
            }
        }
    }


    actions
    {
        // Add changes to page actions here
    }

    procedure GetUser(UserGUID: Guid): Text
    var
        User: Record User;
    begin
        User.Reset();
        User.SetRange("User Security ID", UserGUID);
        if User.FindFirst() then
            exit(User."Full Name");
    end;

    var
        myInt: Integer;
}