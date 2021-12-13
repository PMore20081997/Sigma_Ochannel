report 90080 "Courier Label - DHL"
{
    // ApplicationArea = All;
    //UsageCategory = ReportsAndAnalysis;
    DefaultLayout = RDLC;
    RDLCLayout = './CourierLabel_DHL.rdl';

    dataset
    {

        dataitem("Shipment Tracking"; "Shipment Tracking")
        {
            RequestFilterFields = "Document No.", "Shipping Agent Code";
            CalcFields = Label;
            DataItemTableView = WHERE("Document Type" = CONST(Order));
            column(Label_ShipmentTracking; "Shipment Tracking".Label)
            {
            }

        }

    }
    var
        CompanyInfo: Record "Company Information";
}

