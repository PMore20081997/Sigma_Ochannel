page 90067 "Liferay Correlation ID Track"
{
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Lists;
    SourceTable = "correlation-id Tracking";
    // ModifyAllowed = false;
    // InsertAllowed = false;
    // DelayedInsert = false;
    // Editable = false;

    layout
    {
        area(Content)
        {
            repeater(Details)
            {
                field("Channel Code"; Rec."Channel Code")
                {
                    Editable = false;
                    ApplicationArea = All;

                }
                field("Document Type"; Rec."Document Type")
                {
                    Editable = false;
                    ApplicationArea = All;

                }
                field("Document No."; Rec."Document No.")
                {
                    Editable = false;
                    ApplicationArea = All;

                }
                field("Document Line No."; Rec."Document Line No.")
                {
                    Editable = false;
                    ApplicationArea = All;

                }
                field("Sync Date"; Rec."Sync Date")
                {
                    Editable = false;
                    ApplicationArea = All;

                }
                field(SystemCreatedBy; GetUserName(Rec.SystemCreatedBy))
                {
                    Editable = false;
                    ApplicationArea = All;

                }
                field("Correlation-Id"; Rec."Correlation-Id")
                {
                    Editable = false;
                    ApplicationArea = All;

                }
                field(Data; Rec.Data)
                {
                    Editable = false;
                    ApplicationArea = All;

                    trigger OnAssistEdit()
                    begin
                        Message(GetDataDetails);
                    end;
                }
            }
        }
    }
    actions
    {
        area(Processing)
        {
            action("Show Data")
            {
                ApplicationArea = All;
                Image = ViewComments;
                PromotedCategory = Process;
                Promoted = true;
                PromotedIsBig = true;
                PromotedOnly = true;

                trigger OnAction()
                begin
                    Message(GetDataDetails);
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


    procedure GetDataDetails() ErrorMessage: Text
    var
        TypeHelper: Codeunit "Type Helper";
        InStream: InStream;
    begin
        Rec.CalcFields(Data);
        Rec.Data.CreateInStream(InStream, TEXTENCODING::UTF8);
        exit(TypeHelper.TryReadAsTextWithSepAndFieldErrMsg(InStream, TypeHelper.LFSeparator(), Rec.FieldName(Data)));
    end;
}


