pageextension 90019 "OC Item Reference List" extends "Item Reference List"
{
    layout
    {
        // Add changes to page layout here
    }

    // actions
    // {
    //     // Add changes to page actions here
    //     addbefore(PrintLabel)
    //     {
    //         action("Sync PIP Code")
    //         {
    //             ApplicationArea = All;
    //             Image = Action;
    //             trigger OnAction()
    //             var
    //                 L_UpdateItemReference: Codeunit "Update Item Reference";
    //             begin
    //                 L_UpdateItemReference.Run();
    //             end;
    //         }
    //     }
    // }

    var
        myInt: Integer;
}