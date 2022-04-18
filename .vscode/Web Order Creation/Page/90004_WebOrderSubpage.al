page 90004 "Web order Subpage"
{
    PageType = ListPart;
    //ApplicationArea = All;
    //UsageCategory = Administration;
    SourceTable = "Interim Sales Line";
    CaptionML = ENU = 'Web order Subpage', ENG = 'Web order Subpage';
    ModifyAllowed = true;
    // LinksAllowed = false;
    // DelayedInsert = true;
    AutoSplitKey = true;
    InsertAllowed = true;
    DeleteAllowed = true;
    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Document No"; Rec."Document No")
                {
                    Visible = false;
                    ApplicationArea = All;
                }
                field(Type; Rec.Type)
                {
                    ApplicationArea = All;
                }
                field("No."; Rec."No.")
                {
                    ApplicationArea = All;
                }
                field("Shelf No."; Rec."Shelf No.")
                {
                    ApplicationArea = All;
                }
                field(Description; Rec.Description)
                {
                    Editable = true;
                    ApplicationArea = All;
                    trigger OnValidate()
                    var
                        ISH: Record "Interim Sales Header";
                    begin
                        ISH.Reset();
                        ISH.SetRange("No.", Rec."Document No");
                        ISH.SetRange("Document Type", Rec."Document Type");
                        if ISH.FindFirst() then begin
                            if Rec."Trade Partner Code" = '' then begin
                                Rec.Validate("Trade Partner Code", ISH."Trade Partner Code");
                                Rec.Validate("Channel Order ID", ISH."Channel Order ID");
                            end;
                        end;
                    end;
                }

                field(Description2; Rec.Description2)
                {
                    Editable = true;
                    Visible = false;
                    ApplicationArea = All;
                }

                field(Quantity; Rec.Quantity)
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Reserved Qty"; Rec."Reserved Qty")
                {
                    ApplicationArea = ALl;
                    Editable = false;
                }
                field(Reserved; Rec.Reserved)
                {
                    ApplicationArea = All;
                }
                field("Unit of Measure Code"; Rec."Unit of Measure Code")
                {
                    ApplicationArea = All;
                }
                field("Unit Price"; Rec."Unit Price")
                {
                    ApplicationArea = All;
                }
                field("Quantity Handeled"; Rec."Trolley closed Quantity")
                {
                    ApplicationArea = All;

                }
                field("Shipping Price"; Rec."Shipping Price")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field("Gift Wrap Price"; Rec."Gift Wrap Price")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field(Weight; Rec.Weight)
                {
                    ApplicationArea = All;
                }
                field(Discount; Rec.Discount)
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field("Discount %"; Rec."Discount %")
                {
                    ApplicationArea = All;
                }
                field(Amount; Rec.Amount)
                {
                    ApplicationArea = All;
                }
                field("Amount Including VAT"; Rec."Amount Including VAT")
                {
                    ApplicationArea = All;
                }
                field("Channel SKU"; Rec."Channel SKU")
                {
                    ApplicationArea = All;
                }
                field("Channel Order ID"; Rec."Channel Order ID")
                {
                    ApplicationArea = All;
                }
                field("NAV Variant code"; Rec."NAV Variant code")
                {
                    ApplicationArea = All;
                }
                field("Location Code"; Rec."Location Code")
                {
                    ApplicationArea = All;
                    Caption = 'Location Code';
                }
                field("Gift Wrap"; Rec."Gift Wrap")
                {
                    ApplicationArea = All;
                    Editable = true;
                    Enabled = true;
                }
                field("Channel Identifier"; Rec."Channel Identifier")
                {
                    Visible = false;
                    ApplicationArea = All;
                }
                field("Channel Item Id"; Rec."Channel Item Id")
                {
                    Visible = false;
                    ApplicationArea = All;
                }
                field("VAT Prod. Posting Group"; Rec."VAT Prod. Posting Group")
                {
                    Visible = false;
                    ApplicationArea = All;
                }
                field("Trolley No."; rec."Trolley No.")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Bay No."; Rec."Bay No.")
                {
                    ApplicationArea = All;
                    //Editable = false;
                }
                field("Scanned Date"; rec."Scanned Date")
                {
                    ApplicationArea = All;
                }
            }
        }
    }

    actions
    {
        area(processing)
        {
            action("Cancel Selected Lines")
            {
                ApplicationArea = All;
                Image = Cancel;
                trigger OnAction()
                var
                    L_InterimSalesLine: Record "Interim Sales Line";
                    UpdateDispatchedOnWebOrder: Report "Update Dispatched On Web Order";
                    L_InterimSalesHeader: Record "Interim Sales Header";
                begin
                    L_InterimSalesHeader.Get(Rec."Document Type", rec."Document No");
                    if NOT (L_InterimSalesHeader.status IN [L_InterimSalesHeader.status::"Partially Scanned", L_InterimSalesHeader.status::Processing, L_InterimSalesHeader.status::Cancelled]) then
                        Error('Line can cancel only when order status is Partially Scanned or Processing or Cancelled');
                    Clear(L_InterimSalesLine);
                    L_InterimSalesLine := Rec;
                    CurrPage.SETSELECTIONFILTER(L_InterimSalesLine);
                    UpdateDispatchedOnWebOrder.CancelSelectedLines(L_InterimSalesLine);
                end;
            }
        }
    }
}

