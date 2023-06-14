pageextension 90085 "Posted Whse. Rcpt Card" extends "Registered Pick"
{
    layout
    {
        addafter("Registering Date")
        {
            field("No. of Boxes"; Rec."No. of Boxes")
            {
                ApplicationArea = All;
            }
            field("Total weight (consignment)"; Rec."Total weight (consignment)")
            {
                ApplicationArea = All;
            }
            field("Shipping Agent Code"; Rec."Shipping Agent Code")
            {
                ApplicationArea = All;
            }
            field("Shipping Agent Service Code"; Rec."Shipping Agent Service Code")
            {
                ApplicationArea = All;
            }
        }
        addlast(General)
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
        addbefore(WhseActivityLines)
        {
            field(Comments; Rec.Comments)
            {
                ApplicationArea = all;
                Editable = false;
            }
        }
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
}