pageextension 90079 "Ext Whse. Shipment Subform" extends "Whse. Shipment Subform"
{
    layout
    {
        // modify("Qty. to Ship")
        // {
        //     Editable = isAllowedtoEditQtytoShip;
        // }
        addafter("Source No.")
        {
            field("Channel Order ID"; Rec."Channel Order ID")
            {
                ApplicationArea = All;
                //Editable = false;
                Visible = false;
            }
            field("Scanned Quantity"; Rec."Scanned Quantity")
            {
                ApplicationArea = All;
                Editable = false;
                DecimalPlaces = 0 : 0;
                Visible = false;
            }
            field("Scan Status"; Rec."Scan Status")
            {
                ApplicationArea = All;
                Editable = false;
                Visible = false;
            }
            field("Scanned By"; Rec."Scanned By")
            {
                ApplicationArea = All;
                Editable = false;
                Visible = false;
            }
            field("Scan Station"; Rec."Scan Station")
            {
                ApplicationArea = All;
                Editable = false;
                Visible = false;
            }
            field("Scanned Date"; Rec."Scanned Date")
            {
                ApplicationArea = All;
                Editable = false;
                Visible = false;
            }
            field("Dispatch Scan"; Rec."Dispatch Scan")
            {
                ApplicationArea = All;
                Visible = false;
            }
            field("User ID"; Rec."User ID")
            {
                ApplicationArea = All;
                Visible = false;
            }
            field(Parked; Rec.Parked)
            {
                ApplicationArea = All;
                Visible = false;
            }

        }
        addafter("Qty. per Unit of Measure")
        {
            field("Bay No."; Rec."Bay No.")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the value of the Bay No. field.';
                Visible = false;
            }
        }

    }
    trigger OnAfterGetCurrRecord()
    var
        G_UserSetup: Record "User Setup";
    begin
        G_UserSetup.Reset();
        if G_UserSetup.Get(UserId) then begin
            if G_UserSetup."Allow Edit Qty. to ship" then
                isAllowedtoEditQtytoShip := true
            else
                isAllowedtoEditQtytoShip := false;

            CurrPage.Update(false);
        end;
    end;

    var
        isAllowedtoEditQtytoShip: Boolean;
}