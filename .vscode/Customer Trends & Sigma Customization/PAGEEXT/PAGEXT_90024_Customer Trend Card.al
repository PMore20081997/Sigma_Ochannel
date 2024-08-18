pageextension 90024 "OC Customer Trend Card" extends "Customer Trend Card"
{
    layout
    {
        // Add changes to page layout here
    }

    actions
    {
        // Add changes to page actions here
        addbefore(Comments)
        {
            action("Register Sales Order")
            {
                ApplicationArea = All;
                Image = Register;
                Enabled = Rec."Entry Number" <> '';

                trigger OnAction()
                var
                    CreateUpdateWebOrder: Codeunit "OC Create & Update WebOrder";
                    L_CustomertrendLine: Record CustomerTrends;
                begin
                    //Confirmation Message++
                    if not Confirm('Do you want to register?', false) then
                        Error('');

                    //Check Mandatory Fields++
                    Rec.TestField("Delivery Date");
                    Rec.TestField("Salesperson Code");
                    Rec.TestField("Customer No.");
                    Rec.TestField("Shipping Agent Code");
                    Rec.TestField("Shipping Agent Service Code");

                    //Check Line if ready to process++ 
                    L_CustomertrendLine.Reset();
                    L_CustomertrendLine.SetRange("Entry Number", Rec."Entry Number");
                    L_CustomertrendLine.SetFilter("Qty. to be added to SO", '>%1', 0);
                    if L_CustomertrendLine.IsEmpty then
                        Error('Nothing to Register');

                    //Create and Update Web Order++
                    CreateUpdateWebOrder.CreateAndUpdateWebOrder(Rec);
                end;
            }
        }
    }

    var
        myInt: Integer;
}