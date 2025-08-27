page 90051 "Line Response"
{
    PageType = ListPart;
    SourceTable = "Interim Sales Line";
    DelayedInsert = true;
    AutoSplitKey = true;
    PopulateAllFields = true;
    ODataKeyFields = SystemId;
    layout
    {
        area(Content)
        {
            repeater(LineDetails)
            {
                field(id; Rec.SystemId)
                {
                    ApplicationArea = All;
                }
                field(DocumentNo; Rec."Document No")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field(TradePartnerCode; Rec."Trade Partner Code")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field(DocumentType; Rec."Document Type")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field(Type; Rec.Type)
                {
                    ApplicationArea = ALl;
                    Editable = false;
                }
                field(LineNo; Rec."Line No.")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field(PIPCode; Rec."Channel SKU")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field(No; Rec."No.")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field(ChannelItemId; Rec."Sig Channel Item Id")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field(Quantity; Rec.Quantity)
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field(Qty_to_Deliver; Rec."Qty. to Deliver")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field(ReasonCode; Rec."Reason Code")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field(ReasonMessage; Rec."Reason Message")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
            }
        }
    }
}