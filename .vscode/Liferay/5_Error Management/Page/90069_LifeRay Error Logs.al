page 90069 "LifeRay Error Logs"
{
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Lists;
    SourceTable = "LifeRay Error Log";
    // ModifyAllowed = false;
    // InsertAllowed = false;
    // Editable = false;
    // DeleteAllowed = false;
    layout
    {
        area(Content)
        {
            repeater(Details)
            {
                field("Entry No."; Rec."Entry No.")
                {
                    ApplicationArea = All;
                    Editable = false;
                    Visible = false;

                }
                field("Channel Code"; Rec."Channel Code")
                {
                    ApplicationArea = All;
                    Editable = false;

                }
                field("Document Type"; Rec."Document Type")
                {
                    ApplicationArea = All;
                    Editable = false;

                }
                field("Document No."; Rec."Document No.")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Sync Date"; Rec."Sync Date")
                {
                    ApplicationArea = All;
                    Editable = false;

                }
                field("Error Message"; Rec."Error Message")
                {
                    ApplicationArea = All;
                    Editable = false;

                    trigger OnAssistEdit()
                    begin
                        Message(GetErrorMessage);
                    end;
                }
                field(SystemCreatedBy; GetUserName(Rec.SystemCreatedBy))
                {
                    ApplicationArea = All;
                    Editable = false;
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action("Show Error Message")
            {
                ApplicationArea = All;
                Image = ViewComments;
                PromotedCategory = Process;
                Promoted = true;
                PromotedIsBig = true;
                PromotedOnly = true;

                trigger OnAction()
                begin
                    Message(GetErrorMessage);
                end;
            }
        }
    }

    procedure GetUserName(UserSecurityId: Code[50]): Text[100]
    var
        Users: Record User;
    begin
        Users.Reset();
        Users.SetRange("User Security ID", UserSecurityId);
        if Users.FindFirst() then
            exit(Users."User Name");
    end;

    procedure GetErrorMessage() ErrorMessage: Text
    var
        TypeHelper: Codeunit "Type Helper";
        InStream: InStream;
    begin
        Rec.CalcFields("Error Message");
        Rec."Error Message".CreateInStream(InStream, TEXTENCODING::UTF8);
        exit(TypeHelper.TryReadAsTextWithSepAndFieldErrMsg(InStream, TypeHelper.LFSeparator(), Rec.FieldName("Error Message")));
    end;
}