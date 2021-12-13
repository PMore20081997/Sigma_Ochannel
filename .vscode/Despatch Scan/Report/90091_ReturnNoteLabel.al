report 90091 "Return Label"
{

    DefaultLayout = RDLC;
    RDLCLayout = './CourierLabel.rdl';

    dataset
    {

        dataitem("Shipment Tracking"; "Shipment Tracking")
        {
            CalcFields = Label;
            DataItemTableView = WHERE("Document Type" = CONST(Order));
            column(Label_ShipmentTracking; "Shipment Tracking"."A6 Label1")
            {
            }
            column(Document_No_; "Document No.")
            {

            }
        }


    }
    var
        CompanyInfo: Record "Company Information";
}

