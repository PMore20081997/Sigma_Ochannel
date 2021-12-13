page 90007 "Despatch Scan Subform"
{
    Caption = 'B2C Dispatch Line';
    DelayedInsert = true;
    DeleteAllowed = false;
    PageType = ListPart;
    SourceTable = "Despatch Scan Line";
    SourceTableView = SORTING("Entry No.")
                      ORDER(Descending);

    layout
    {
        area(content)
        {
            repeater("Group")
            {
                Editable = false;
                Enabled = false;
                field("Trade Partner"; rec."Channel Parter Code")
                {
                    StyleExpr = Styletext;
                    ApplicationArea = All;
                }
                field("Order No"; rec."Order No")
                {
                    Editable = false;
                    QuickEntry = false;
                    StyleExpr = Styletext;
                    ApplicationArea = All;
                }
                field("Item No"; rec."Item No.")
                {
                    Editable = false;
                    QuickEntry = false;
                    StyleExpr = Styletext;
                    ApplicationArea = All;
                }
                field("Variant Code"; rec."Variant Code")
                {
                    Editable = false;
                    QuickEntry = false;
                    StyleExpr = Styletext;
                    ApplicationArea = All;

                }
                field("Item Desciption"; rec."Item Desciption")
                {
                    Editable = false;
                    QuickEntry = false;
                    StyleExpr = Styletext;
                    ApplicationArea = All;
                }
                field(Qty; rec.Quantity)
                {
                    Caption = 'Order Quantity';
                    Editable = false;
                    QuickEntry = false;
                    StyleExpr = Styletext;
                    ApplicationArea = All;
                }
                field("Scanned Quantity"; rec."Scanned Quantity")
                {
                    StyleExpr = Styletext;
                    ApplicationArea = All;
                }
                field("Quantity Handeled"; Rec."Trolley closed Quantity")
                {
                    ApplicationArea = All;

                }
                field(Scanned; rec.Scanned)
                {
                    Editable = false;
                    QuickEntry = false;
                    StyleExpr = Styletext;
                    ApplicationArea = All;
                }
                field("Channel Order Id"; ChannelOrderId)
                {
                    ApplicationArea = All;
                    StyleExpr = Styletext;
                }
                field("BayNo."; rec."Bay No.")
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
            action("Update Dispatch on Web Orders")
            {
                Caption = 'Close Trolley';
                Image = Shipment;
                Promoted = true;
                PromotedCategory = Process;
                ApplicationArea = All;

                trigger OnAction()
                var
                    DespatchLine: Record "Despatch Scan Line";
                    DespatchHeader: Record "Despatch Scan Header";
                begin
                    DespatchLine.RESET;
                    DespatchLine.SETRANGE("Trolley No", Rec."Trolley No");
                    IF DespatchLine.FINDSET THEN BEGIN
                        DespatchHeader.Reset();
                        DespatchHeader.SetRange("Trolley No", Rec."Trolley No");
                        DespatchHeader.SetRange("User ID", UserId);
                        if DespatchHeader.FindSet() then begin
                            UpdateDispatchedOnWebOrder.CheckWebOrderLinesFoUnscannedQty(Rec."Trolley No");
                            UpdateDispatchedOnWebOrder.UpdatedDispatchOnWebOrderNew(DespatchLine, Rec."Trolley No", Rec."Bay No.", DespatchHeader);
                        end;

                    END;
                    CurrPage.CLOSE;

                end;
            }
        }
    }
    trigger OnAfterGetRecord()
    var
        L_ISH: Record "Interim Sales Header";
    begin
        Rec.SetRange("Trolley No",G_TrolleyNo);
        IF (rec."Trolley No" <> '') AND (rec.Scanned = TRUE) THEN BEGIN
            Styletext := ChangeStyle(Rec."Trolley No", Rec."Order No")
        END
        ELSE
            Styletext := 'Standard';

        CLEAR(ChannelOrderId);
        IF L_ISH.GET(L_ISH."Document Type"::Order, Rec."Order No") THEN
            ChannelOrderId := L_ISH."Channel Order ID";


    end;

    local procedure ChangeStyle(L_TrolleyNo: Code[20]; L_weborderNo: Code[20]): Text
    var
        L_Despatch: Record "Despatch Scan Line";
        L_InterimSalesLine: Record "Interim Sales Line";
        TotalSalesLines: Integer;
        TotalDespatchLines: Integer;
    begin
        CLEAR(TotalDespatchLines);
        CLEAR(TotalSalesLines);
        L_Despatch.RESET;
        L_Despatch.SETRANGE("Trolley No", L_TrolleyNo);
        L_Despatch.SETRANGE(Scanned, TRUE);
        L_Despatch.SETRANGE("Order No", L_weborderNo);
        IF L_Despatch.FINDSET THEN
            TotalDespatchLines := L_Despatch.COUNT;

        L_InterimSalesLine.RESET;
        L_InterimSalesLine.SETRANGE(Type, L_InterimSalesLine.Type::Item);
        L_InterimSalesLine.SETRANGE("Document No", L_weborderNo);
        L_InterimSalesLine.SETFILTER("Item Type", '<>%1', L_InterimSalesLine."Item Type"::Assembly);
        IF L_InterimSalesLine.FINDSET THEN
            TotalSalesLines := L_InterimSalesLine.COUNT;

        IF TotalDespatchLines = TotalSalesLines THEN
            EXIT('Favorable')
        ELSE
            EXIT('Ambiguous');

    end;

    var
        Styletext: Text;
        ChannelOrderId: Text;
        UpdateDispatchedOnWebOrder: Report "Update Dispatched On Web Order";
        G_TrolleyNo: Code[20];
    trigger OnOpenPage()
    begin
        Rec.RESET;
        Rec.SETRANGE("User ID", USERID);
    end;

    procedure Setfilter(P_TrolleyNo: Code[20]; P_UserID: Code[50])
    var
    
    begin
        Rec.RESET;
        Rec.ASCENDING(FALSE);
        Rec.SETRANGE("User ID", P_UserID);
        Rec.SetRange("Trolley No", P_TrolleyNo);
        Rec.SetRange(Scanned, true);
       // Rec.FindLast();
        G_TrolleyNo := P_TrolleyNo;
    end;
}

