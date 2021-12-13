pageextension 90072 "Whse. Internal Pick List Ext" extends "Whse. Internal Pick List"
{
    layout
    {
        addafter(Status)
        {
          field("Channel Code"; rec."Channel Code")
          {
            ApplicationArea = All;
          }
          field("Trolley No."; rec."Trolley No.")
          {
            ApplicationArea = All;
          }
        }
        
    }
    
    //Sofyan++
    trigger OnDeleteRecord(): Boolean
    begin
        CreateWHInvPickHeaderWis."OndeleteW/HPick"(Rec);
    end;
    //Sofyan--

    var
        CreateWHInvPickHeaderWis: Codeunit "Process Web Order";
}