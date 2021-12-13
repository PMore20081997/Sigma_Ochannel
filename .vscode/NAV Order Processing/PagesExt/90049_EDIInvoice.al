page 90049 "EDI Invoice"
{
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Lists;
    Caption = 'EDI Invoice';
    SourceTable = "Sales Invoice Header";
    Permissions = tabledata "Sales Invoice Header" = M;
    Editable = false;
    DeleteAllowed = false;
    InsertAllowed = false;
    layout
    {
        area(Content)
        {
            repeater(GroupName)
            {
                field("No."; Rec."No.")
                {
                    ApplicationArea = All;

                }
                field("Bill-to Customer No."; Rec."Bill-to Customer No.")
                {
                    ApplicationArea = All;

                }
                field("Bill-to Name"; Rec."Bill-to Name")
                {
                    ApplicationArea = All;

                }
                field("Currency Code"; Rec."Currency Code")
                {
                    ApplicationArea = All;

                }
                field("Due Date"; Rec."Due Date")
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
                field("Remaining Amount"; Rec."Remaining Amount")
                {
                    ApplicationArea = All;

                }
                field("Location Code"; Rec."Location Code")
                {
                    ApplicationArea = All;

                }
                field(Export; Rec.Export)
                {
                    ApplicationArea = All;

                }


            }
        }
        area(Factboxes)
        {

        }
    }
    actions
    {
        area(Processing)
        {
            action(ExportEDI)
            {
                ApplicationArea = All;
                Caption = 'Export EDI';
                Image = Export;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                PromotedOnly = true;

                trigger OnAction()
                begin
                    JohnlewisCodeunit.GetEDIRecords();
                    CurrPage.Update();
                end;
            }

        }


    }

    var
        JohnlewisCodeunit: Codeunit JohnlewisEDI;
        CustomerNumber: Text;

    trigger OnOpenPage()
    var
        TradepartnerRecord: Record "Trade Partner";
    begin
        CustomerNumber := '';
        TradepartnerRecord.Reset();
        TradepartnerRecord.SetRange("Export Invoice", true);
        if TradepartnerRecord.FindSet() then begin
            repeat
                if CustomerNumber <> '' then
                    CustomerNumber += '|' + TradepartnerRecord."Customer No."
                else
                    CustomerNumber := TradepartnerRecord."Customer No."
           until TradepartnerRecord.Next() = 0;

        end;

        Rec.FilterGroup(2);
        /*  if CustomerNumber <> '' then
              Rec.SetFilter("Sell-to Customer No.", CustomerNumber)
          else
              Rec.SetRange("Sell-to Customer No.", '');*/

        Rec.FilterGroup(0);
    end;

    trigger OnAfterGetRecord()
    var
        TradepartnerRecord: Record "Trade Partner";

    begin
        CustomerNumber := '';
        TradepartnerRecord.Reset();
        TradepartnerRecord.SetRange("Export Invoice", true);
        if TradepartnerRecord.FindFirst() then begin
            repeat
                if CustomerNumber <> '' then
                    CustomerNumber += '|' + TradepartnerRecord."Customer No."
                else
                    CustomerNumber := TradepartnerRecord."Customer No."
           until TradepartnerRecord.Next() = 0;

        end;
        Rec.FilterGroup(2);
        if CustomerNumber <> '' then
              Rec.SetFilter("Bill-to Customer No.", CustomerNumber)
          else
              Rec.SetRange("Sell-to Customer No.", '');

        Rec.FilterGroup(0);
    end;

}