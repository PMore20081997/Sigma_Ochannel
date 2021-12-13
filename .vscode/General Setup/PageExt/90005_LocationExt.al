pageextension 90005 LocationExt extends "Location Card"
{
    layout
    {
       addafter("Shipment Bin Code")
       {
         field("Default DD Bin"; rec."Default DD Bin")
         {
             ApplicationArea = All;
         }
       }
    }
}