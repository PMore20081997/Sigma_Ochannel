//CAS-26633-Z8W1Y1.MH
page 90031 "Web Sales Invoice SubForm"
{
    PageType = ListPart;
    SourceTable = "Web Sales Invoice Line";
    Caption = 'Web Sales Invoice Lines';
    ModifyAllowed = False;
    DelayedInsert = true;
    DeleteAllowed = false;
    InsertAllowed = false;

    layout
    {
        area(Content)
        {
            repeater(Lines)
            {
                field("Web Sales Invoice No."; Rec."Web Sales Invoice No.")
                {
                    ApplicationArea = All;
                }
                field("Trade Partner Code"; Rec."Trade Partner Code")
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
                    ApplicationArea = All;
                }
                field("NAV Variant code"; Rec."NAV Variant code")
                {
                    ApplicationArea = All;
                }
                field("Unit of Measure Code"; Rec."Unit of Measure Code")
                {
                    ApplicationArea = All;
                }
                field(Quantity; Rec.Quantity)
                {
                    ApplicationArea = All;
                }
                field("Quantity(Base)"; Rec."Quantity(Base)")
                {
                    ApplicationArea = All;
                }
                field("Unit Price"; Rec."Unit Price")
                {
                    ApplicationArea = All;
                }
                field("VAT%"; Rec."VAT%")
                {
                    ApplicationArea = All;
                    Visible = false;
                    //Prathamesh
                }
                field("Vat Amount"; Rec."Vat Amount")
                {
                    ApplicationArea = All;
                    //Prathamesh
                }
                field(Amount; Rec.Amount)
                {
                    ApplicationArea = All;
                }
                field("Amount Including VAT"; Rec."Amount Including VAT")
                {
                    ApplicationArea = All;
                }
                field("Stock Posted"; rec."Stock Posted")
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
            /* action(GetShipmentLines)
             {
                 AccessByPermission = TableData "Sales Shipment Header" = R;
                 ApplicationArea = Suite;
                 Caption = 'Get &Trolley Lines';
                 Ellipsis = true;
                 Image = Shipment;

                 trigger OnAction()
                 var
                     //GetTrolleyDetails: report "Get Trolley Details";
                     GetTrolleyDetails: report "Get Scanned Lines";
                     WSI: Record "Web Sales Invoice";
                 begin
                     WSI.get(Rec."Web Sales Invoice No.");
                     GetTrolleyDetails.SetChannelcode(WSI."Web Sales Invoice No.", WSI."Trade Partner Code");
                     GetTrolleyDetails.Run();
                 end;
             }*/

            action(WebOrderLines)
            {
                ApplicationArea = Suite;
                Caption = 'Show Web Orders Lines';
                Ellipsis = true;
                Image = Shipment;

                trigger OnAction()
                var
                    L_HISL: Record "Handled Interim Sales Line";
                    L_HandledLinePage: Page "Handled Web Order Line";
                begin
                    L_HISL.Reset();
                    L_HISL.SetRange("Web Sales Invoice No.", Rec."Web Sales Invoice No.");
                    If L_HISL.FindSet() then begin
                        L_HandledLinePage.SetTableView(L_HISL);
                        L_HandledLinePage.Run();
                    end;
                end;
            }
            action(WebOrders)
            {
                ApplicationArea = Suite;
                Caption = 'Show Web Orders';
                Ellipsis = true;
                Image = Shipment;

                trigger OnAction()
                var
                    L_HISH: Record "Handled Interim Sales Header";
                    L_HandledHeaderPage: Page "Handled Web Order List";
                begin
                    L_HISH.Reset();
                    L_HISH.SetRange("Invoice No.", Rec."Web Sales Invoice No.");
                    If L_HISH.FindSet() then begin
                        L_HandledHeaderPage.SetTableView(L_HISH);
                        L_HandledHeaderPage.Run();
                    end;
                end;
            }
        }
    }

    trigger OnDeleteRecord(): Boolean
    var
        myInt: Integer;
        HISL: Record "Handled Interim Sales Line";
        HISL2: Record "Handled Interim Sales Line";
    begin
        HISL.SetRange(Type, HISL.Type::Item);
        HISL.SetRange("No.", Rec."No.");
        HISL.SetRange("NAV Variant code", Rec."NAV Variant code");
        HISL.SetRange("Trade Partner Code", Rec."Trade Partner Code");
        HISL.SetRange("Web Sales Invoice No.", Rec."Web Sales Invoice No.");
        If HISL.FindSet() then
            repeat
                if HISL2.get(HISL."Document Type", HISL."Document No", HISL."Line No.") then begin
                    Clear(HISL2."Web Sales Invoice No.");
                    HISL2.Modify();
                end;
            until HISL.Next() = 0;
    end;
}