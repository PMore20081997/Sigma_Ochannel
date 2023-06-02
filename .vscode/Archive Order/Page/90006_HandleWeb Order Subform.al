#pragma implicitwith disable
page 90006 "Handled Web Order Subpage"
{
    Editable = true;
    ModifyAllowed = true;
    InsertAllowed = true;
    DeleteAllowed = false;
    PageType = ListPart;
    SourceTable = "Handled Interim Sales Line";
    CaptionML = ENU = 'Handle Web Order Subpage', ENG = 'Handle Web Order Subpage';
    AutoSplitKey = true;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field(Type; Rec.Type)
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("No."; Rec."No.")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = All;

                    trigger OnValidate()
                    var
                        HISH: Record "Handled Interim Sales Header";
                    begin
                        HISH.Reset();
                        HISH.SetRange("No.", Rec."Document No");
                        HISH.SetRange("Document Type", Rec."Document Type");
                        if HISH.FindFirst() then begin
                            if Rec."Trade Partner Code" = '' then begin
                                Rec.Validate("Trade Partner Code", HISH."Trade Partner Code");
                                Rec.Validate("Channel Order ID", HISH."Channel Order ID");
                            end;
                        end;
                    end;

                }
                field("Channel Variant"; Rec."Channel Variant")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field("NAV Variant"; Rec."NAV Variant code")
                {
                    ApplicationArea = All;
                    Visible = false;
                    Editable = false;
                }
                field(Quantity; Rec.Quantity)
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Unit of Measure Code"; Rec."Unit of Measure Code")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Channel Price"; Rec."Channel Price")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Unit Price"; Rec."Unit Price")
                {
                    Caption = 'Unit Price Ex. VAT';
                    ApplicationArea = All;
                    Editable = false;
                }
                field(Weight; Rec.Weight)
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("VAT amount"; Rec."VAT amount")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Shipping Price"; Rec."Shipping Price")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Gift Wrap Price"; Rec."Gift Wrap Price")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field(Discount; Rec.Discount)
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field(Amount; Rec.Amount)
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Amount Including VAT"; Rec."Amount Including VAT")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field(SKU; Rec."Channel SKU")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Channel Order ID"; Rec."Channel Order ID")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Location Code"; Rec."Location Code")
                {
                    ApplicationArea = All;
                    Editable = false;

                }

                field("Reserved Qty"; Rec."Reserved Qty")
                {
                    ApplicationArea = All;
                    Editable = false;
                    Visible = false;
                }

                field(Reserved; Rec.Reserved)
                {
                    ApplicationArea = All;
                    Editable = false;
                    Visible = false;
                }
                field("VAT Bus. Posting Group"; Rec."VAT Bus. Posting Group")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("VAT Prod. Posting Group"; Rec."VAT Prod. Posting Group")
                {
                    ApplicationArea = All;
                    Editable = false;
                }

                field("Gift Wrap"; Rec."Gift Wrap")
                {
                    ApplicationArea = All;
                    Visible = false;
                    CaptionML = ENU = 'Gift', ENG = 'Gift';
                }
                field("Gift Card"; Rec."Gift Card")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Sacnned Qty"; Rec."Sacnned Qty")
                {
                    ApplicationArea = All;
                    Editable = false;
                    Visible = false;
                }
                field("Scanned Date"; Rec."Scanned Date")
                {
                    ApplicationArea = All;
                    Editable = false;
                }

                field("Line Status"; Rec."Line Status")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Assembly Order No."; Rec."Assembly Order No.")
                {
                    ApplicationArea = All;
                    Editable = false;
                }

                //Paarth D Dave - 8197-6 - Adding Posted Assembly Order No ---- Start
                field("Pstd. Ass. Order No "; Rec."Pstd. Ass. Order No ")
                {
                    ApplicationArea = All;
                    Editable = false;
                    Caption = 'Posted Ass. Order No';

                }

                //Paarth D Dave - 8197-6 - Adding Posted Assembly Order No ---- End
            }
        }
    }

    actions
    {
    }
}

#pragma implicitwith restore

