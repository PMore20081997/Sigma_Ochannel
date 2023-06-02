page 90018 "Web Order Line List"
{
    // version INTE1.0

    AutoSplitKey = true;
    Caption = 'Web Order Line List';
    DelayedInsert = true;
    DeleteAllowed = true;
    Editable = false;
    InsertAllowed = false;
    LinksAllowed = false;
    ModifyAllowed = true;
    PageType = List;
    SourceTable = "Interim Sales Line";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Order Date"; rec."Order Date")
                {
                    ApplicationArea = All;
                }
                field("Document No"; Rec."Document No")
                {
                    ApplicationArea = All;
                }
                field("Shelf No."; Rec."Shelf No.")
                {
                    ApplicationArea = All;
                    Editable = false;
                    Visible = false;
                }
                field("Document Date"; rec."Document Date")
                {
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
                field(Description; Rec.Description)
                {
                    Editable = true;
                    ApplicationArea = All;
                }
                field(Description2; Rec.Description2)
                {
                    Editable = true;
                    Visible = false;
                    ApplicationArea = All;
                }
                field("Channel Variant"; Rec."Channel Variant")
                {
                    Visible = false;
                    ApplicationArea = All;
                }
                field("NAV Variant code"; rec."NAV Variant code")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field(Quantity; Rec.Quantity)
                {
                    ApplicationArea = All;

                }
                field("Unit Price"; Rec."Unit Price")
                {
                    ApplicationArea = All;
                }
                field("Unit of Measure Code"; Rec."Unit of Measure Code")
                {
                    ApplicationArea = All;
                }
                field("Trolley No."; rec."Trolley No.")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field("Shipping Price"; Rec."Shipping Price")
                {
                    ApplicationArea = All;
                }
                field("Gift Wrap Price"; Rec."Gift Wrap Price")
                {
                    ApplicationArea = All;
                }
                field(Discount; Rec.Discount)
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
                field("VAT amount"; Rec."VAT amount")
                {
                    ApplicationArea = All;
                }
                field("Channel SKU"; Rec."Channel SKU")
                {
                    ApplicationArea = All;
                }
                field("Channel Identifier"; Rec."Channel Identifier")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field("Channel Item Id"; Rec."Channel Item Id")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field("VAT Prod. Posting Group"; Rec."VAT Prod. Posting Group")
                {
                    ApplicationArea = All;
                }
                field("VAT Bus. Posting Group"; Rec."VAT Bus. Posting Group")
                {
                    ApplicationArea = All;
                }
                field("VAT%"; Rec."VAT%")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field("Trade Partner Code"; Rec."Trade Partner Code")
                {
                    ApplicationArea = All;
                }
                field("Destination Doc Type"; Rec."Destination Doc Type")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field("Destination Doc No."; Rec."Destination Doc No.")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                //Paarth D Dave - 8197-3 - Adding Assembly Order No. ---- Start
                field("Assembly Order"; Rec."Auto Assembly Order")
                {
                    Editable = false;
                    ApplicationArea = All;
                    Caption = 'Assembly Order';
                }
                field("Assembly Order No."; Rec."Assembly Order No.")
                {
                    Editable = false;
                    ApplicationArea = ALl;
                }
                field("Posted Ass. Order No "; Rec."Pstd. Ass. Order No ")
                {
                    Editable = false;
                    ApplicationArea = All;
                    Caption = 'Posted Ass. Order No.';
                }
                //Paarth D Dave - 8197-3 - Adding Assembly Order No. ---- End
                field("Gift Card"; Rec."Gift Card")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Gift Card field.';
                }
            }
        }
    }


    actions
    {
        area(processing)
        {
            /*action("Payment Details")
            {
                Image = Payment;
                ApplicationArea = All;

                trigger OnAction()
                var

                    ChannelMedia: Record "Channel Media";
                    ChannelOrderId: Text;
                begin
                    
                end;
            }*///NG_need_to_check_with_chandan
            Action("Web Order")
            {
                Image = Order;
                ApplicationArea = All;
                RunObject = page "Web Order Header";
                RunPageLink = "Document Type" = field("Document Type"), "No." = field("Document No");
                Promoted = true;
                PromotedCategory = Process;
                PromotedOnly = true;
                PromotedIsBig = true;
                trigger OnAction()
                begin

                end;
            }
            Action("Remove Lines From Trolley")
            {
                Image = RemoveLine;
                ApplicationArea = All;
                Promoted = true;
                PromotedCategory = Process;
                PromotedOnly = true;
                PromotedIsBig = true;
                Visible = false;

                trigger OnAction()
                var
                    L_InterimSalesLine: Record "Interim Sales Line";
                begin
                    CurrPage.SetSelectionFilter(L_InterimSalesLine);
                    UpdateDispatchedOnWebOrder.SetCalledFromDispatch(CalledFromDispatch);
                    UpdateDispatchedOnWebOrder.RemoveSelectedLinesFromTrolleyNew(L_InterimSalesLine, FALSE);
                end;
            }
            Action("Update Out of Stock")
            {
                ApplicationArea = All;
                Visible = IsOutOfStockAllowed;

                trigger OnAction()
                var
                    L_InterimSalesLine: Record "Interim Sales Line";
                begin
                    CurrPage.SETSELECTIONFILTER(L_InterimSalesLine);
                    UpdateDispatchedOnWebOrder.SetCalledFromDispatch(CalledFromDispatch);
                    UpdateDispatchedOnWebOrder.RemoveSelectedLinesFromTrolleyNew(L_InterimSalesLine, TRUE);
                end;
            }

            Action("Process Web Order Lines")
            {
                Image = CompleteLine;
                ApplicationArea = All;
                Visible = IsOutOfStockAllowed;

                trigger OnAction()
                var
                    L_InterimSalesL: Record "Interim Sales Line";
                    L_InterimSalesL2: Record "Interim Sales Line";
                    TempOrderH: Record "Interim Sales Header" temporary;
                    L_TradePartner: Record "Trade Partner";
                    R90107: Report "Process Web Orders";
                begin
                    CurrPage.SETSELECTIONFILTER(L_InterimSalesL);
                    CurrPage.SETSELECTIONFILTER(L_InterimSalesL2);
                    IF L_InterimSalesL.FINDSET THEN BEGIN
                        L_InterimSalesL2.SETFILTER("Trade Partner Code", '<>%1', L_InterimSalesL."Trade Partner Code");
                        IF L_InterimSalesL2.FINDFIRST THEN
                            ERROR('You can not select multiple channel partner order lines.');
                        REPEAT
                            TempOrderH.INIT;
                            TempOrderH."Document Type" := L_InterimSalesL."Document Type";
                            TempOrderH."No." := L_InterimSalesL."Document No";
                            TempOrderH.INSERT;
                            TempOrderH.MARK(TRUE);
                            L_InterimSalesL.SETRANGE("Document No", L_InterimSalesL."Document No");
                            L_InterimSalesL.FIND('+');
                            L_InterimSalesL.SETRANGE("Document No");
                        UNTIL L_InterimSalesL.NEXT = 0;
                    END;
                    //IF TempOrderH.FINDFIRST THEN REPEAT
                    CLEAR(R90107);
                    R90107.USEREQUESTPAGE(FALSE);
                    TempOrderH.MARKEDONLY(TRUE);
                    R90107.SetChannelPartner(L_InterimSalesL."Trade Partner Code");
                    R90107.SETTABLEVIEW(TempOrderH);
                    R90107.RUNMODAL;
                    //UNTIL TempOrderH.NEXT = 0
                end;
            }
        }
    }
    var
        UpdateDispatchedOnWebOrder: Report "Update Dispatched On Web Order";
        CalledFromDispatch: Boolean;
        IsOutOfStockAllowed: Boolean;
        VisibleOutOfStock: Boolean;

    procedure SetParameter(P_bool: Boolean)
    begin
        VisibleOutOfStock := P_bool;
    end;

    procedure SetCalledFromDispatch(P_bool: Boolean)
    begin
        CalledFromDispatch := P_bool;
    end;

}

