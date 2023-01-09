page 90014 "Payment Details"
{
    //ApplicationArea = All;
    // UsageCategory = Administration;
    DelayedInsert = true;
    DeleteAllowed = true;
    ModifyAllowed = true;
    Caption = 'Web Payment Details';
    PageType = List;
    SourceTable = "Channel Media";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Entry Type"; Rec."Entry Type")
                {
                    Visible = IsOrder;
                    ApplicationArea = All;
                }
                field("Channel Code"; Rec."Channel Code")
                {
                    Visible = false;
                    ApplicationArea = All;
                }
                field("Transaction Date"; Rec."Transaction Date")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Transaction ID"; Rec."Transaction ID")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Channel Order ID"; Rec."Channel Order ID")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Payment Method"; Rec."Payment Method")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                //Irshad++
                field("Nav Payment Method"; Rec."Nav Payment Method")
                {
                    ApplicationArea = All;
                }
                //Irshad-- 
                field(Amount; Rec.Amount)
                {
                    ApplicationArea = All;
                }
                field("Nav Order No."; Rec."Web Order No.")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field(Status; Rec.Status)
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field("Transaction Reference no"; Rec."Transaction Reference no")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field("Invoice No."; rec."Invoice No.")
                {
                    ApplicationArea = All;
                }
            }
        }


    }
    actions
    {
        area(Processing)
        {
            action("updagte invoice no")
            {
                ApplicationArea = All;

                trigger OnAction();
                var
                    HandledOrderheader: record "Handled Interim Sales Header";
                    OrderPaymentDetail: record "Channel Media";
                begin
                    OrderPaymentDetail.Reset();
                    if OrderPaymentDetail.FindFirst() then
                        repeat
                            HandledOrderheader.Reset();
                            HandledOrderheader.SetRange("Document Type", HandledOrderheader."Document Type"::Order);
                            HandledOrderheader.SetRange("No.", OrderPaymentDetail."Web Order No.");
                            if HandledOrderheader.FindFirst() then begin
                                OrderPaymentDetail."Invoice No." := HandledOrderheader."Invoice No.";
                                OrderPaymentDetail.Modify();
                            end;
                        until OrderPaymentDetail.Next() = 0;
                end;
            }
        }
    }


    trigger OnInsertRecord(BelowxRec: Boolean): Boolean
    begin
        Rec."Channel Code" := ChannelCode;
        Rec."Web Order No." := OrderId;
    end;

    trigger OnNewRecord(BelowxRec: Boolean)
    begin
        Rec."Channel Code" := ChannelCode;
        Rec."Web Order No." := OrderId;
    end;

    trigger OnOpenPage()
    begin
        Rec."Channel Code" := ChannelCode;
        Rec."Web Order No." := OrderId;
        IsOrder := bool1;
    end;





    var
        ChannelCode: Text;
        OrderId: Text;
        IsOrder: Boolean;
        bool1: Boolean;

    procedure SetParameter(TCode: Text; Ordno: Text; bool: Boolean)
    begin
        ChannelCode := TCode;
        OrderId := Ordno;
        bool1 := bool;
    end;
}

