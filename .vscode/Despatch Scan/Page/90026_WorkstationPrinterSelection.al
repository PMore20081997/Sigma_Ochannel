page 90026 "Workstation Printer Selection"
{
    ApplicationArea = All;
    Caption = 'WorkstationPrinterSelection';
    PageType = List;
    SourceTable = "Workstation Printer Selection";
    UsageCategory = Administration;

    layout
    {
        area(content)
        {
            repeater(General)
            {
                field(Workstation; Rec.Workstation)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Workstation.';
                }
                field("Despatch Note Printer"; Rec."Despatch Note Printer")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Despatch Note Printer.';
                }
                field("Label Printer"; Rec."Label Printer")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Label Printer.';
                }
                field("DPD Label Printer"; Rec."DPD Label Printer")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the DPD Label Printer.';
                }

            }
        }
    }
}
