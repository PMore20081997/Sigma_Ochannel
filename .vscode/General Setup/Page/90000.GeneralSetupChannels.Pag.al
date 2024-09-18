page 90000 "General Setup - Channels"
{
    UsageCategory = Administration;
    ApplicationArea = All;
    PageType = Card;
    SourceTable = "General Setup - Channels";
    InsertAllowed = false;
    DeleteAllowed = false;
    ModifyAllowed = true;
    layout
    {
        area(Content)
        {
            group(General)
            {
                field("Consolidated Sales No. Series"; Rec."Consolidated Sales No. Series")
                {
                    ApplicationArea = All;
                    Caption = 'Consolidated Sales Order No. Series';
                }
                field("Shipping G/L No."; Rec."Shipping G/L No.")
                {
                    ApplicationArea = All;
                }
                field("Knapp Consolidation Counter"; Rec."Knapp Consolidation Counter")
                {
                    ApplicationArea = All;
                    Caption = 'Knapp Web Order Consolidation Counter';
                }
                field("Update Variant Counter"; Rec."Update Variant Counter")
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
            action("Update Location Code")
            {
                ApplicationArea = All;
                Caption = 'Update Knapp Location Code';

                trigger OnAction()
                var
                    L_SalesHeader: Record "Sales Header";
                    L_Location: Record Location;
                    L_SalesLine: Record "Sales Line";
                begin
                    L_Location.Reset();
                    L_Location.SetRange("Knapp Location", true);
                    if L_Location.FindFirst() then;

                    L_SalesHeader.Reset();
                    L_SalesHeader.SetRange("Document Type", L_SalesHeader."Document Type"::Order);
                    L_SalesHeader.SetRange("Knapp Order", true);
                    L_SalesHeader.SetRange("Web Order", true);
                    L_SalesHeader.SetRange(Status, L_SalesHeader.Status::Released);
                    L_SalesHeader.SetFilter("Location Code", '<>%1', L_Location.Code);
                    if L_SalesHeader.FindSet() then begin
                        repeat
                            L_SalesHeader."Location Code" := L_Location.Code;
                            L_SalesHeader.Modify();

                            L_SalesLine.Reset();
                            L_SalesLine.SetRange("Document Type", L_SalesLine."Document Type"::Order);
                            L_SalesLine.SetRange(Type, L_SalesLine.Type::Item);
                            L_SalesLine.SetRange("Document No.", L_SalesHeader."No.");
                            if L_SalesLine.FindSet() then begin
                                L_SalesLine.ModifyAll("Location Code", L_Location.Code);
                            end;
                        until L_SalesHeader.Next() = 0;
                    end;
                end;
            }

            action("Update Qty. to Ship")
            {
                ApplicationArea = All;
                Caption = 'Update Qty. to Ship';

                trigger OnAction()
                var
                    L_SalesHeader: Record "Sales Header";
                    L_SalesLine: Record "Sales Line";
                begin
                    L_SalesHeader.Reset();
                    L_SalesHeader.CalcFields("Inv. Pick Exist");
                    L_SalesHeader.SetRange("Document Type", L_SalesHeader."Document Type"::Order);
                    L_SalesHeader.SetRange("Knapp Order", false);
                    L_SalesHeader.SetRange("Inv. Pick Exist", false);
                    L_SalesHeader.SetFilter(Status, '%1|%2', L_SalesHeader.Status::Open, L_SalesHeader.Status::Released);
                    if L_SalesHeader.FindSet() then begin
                        repeat
                            L_SalesLine.Reset();
                            L_SalesLine.SetRange("Document Type", L_SalesLine."Document Type"::Order);
                            L_SalesLine.SetRange(Type, L_SalesLine.Type::Item);
                            L_SalesLine.SetRange("Document No.", L_SalesHeader."No.");
                            L_SalesLine.SetFilter(Quantity, '>0');
                            L_SalesLine.SetFilter("Qty. to Ship", '0');
                            if L_SalesLine.FindSet() then begin
                                repeat
                                    L_SalesLine.Validate("Qty. to Ship", L_SalesLine."Outstanding Quantity");
                                    L_SalesLine.Validate("Qty. to Invoice", L_SalesLine."Outstanding Quantity");
                                    L_SalesLine.Modify(true);
                                    Commit();
                                until L_SalesLine.Next() = 0;
                            end;
                        until L_SalesHeader.Next() = 0;
                    end;
                end;
            }
        }
    }


    trigger OnOpenPage()
    var
    begin
        Rec.RESET;
        IF NOT Rec.GET THEN BEGIN
            Rec.INIT;
            Rec.INSERT;
        END;
    end;
}