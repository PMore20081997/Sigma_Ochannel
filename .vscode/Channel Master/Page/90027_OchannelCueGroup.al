page 90027 "Ochannel Cue Group"
{
    PageType = CardPart;
    ApplicationArea = All;
    UsageCategory = Administration;
   
    layout
    {
        area(Content)
        {
            cuegroup("Despatch Scan")
            {
                actions
                {  
                    action("B2C Despatch Scan")
                    {
                        ApplicationArea = All;
                        Caption = 'Open Despatch Scan';
                        Image = TileBlue;
                        Promoted = true;
                        PromotedIsBig = true;
                        ToolTip = 'Open Despatch Scan Screen to scan web order in trolley.';
                        RunObject = page "Despatch Scan Screen";
                    }

                    action("B2C Return Scan")
                    {
                        ApplicationArea = All;
                        Caption = 'Open Return Order Scan';
                        Image = TileOrange;
                        Promoted = true;
                        PromotedIsBig = true;
                        ToolTip = 'Open Return Order Scan Screen' ;
                        RunObject = page "Return Order Screen";
                    }
                }    
            }
        }
    }
    
    actions
    {
        area(Processing)
        {
            action(ActionName)
            {
                ApplicationArea = All;
                
                trigger OnAction()
                begin
                    
                end;
            }
        }
    }
    
    var
        myInt: Integer;
}