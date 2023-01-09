report 90084 "Courier Label - DPD"
{
    // Used as a dummy report to attach correct printer via workstation seletection 
    // ApplicationArea = All;
    //UsageCategory = ReportsAndAnalysis;
    DefaultLayout = RDLC;
    RDLCLayout = './CourierLabel.rdl';

    dataset
    {

        dataitem("Shipment Tracking"; "Shipment Tracking")
        {
            //    RequestFilterFields = "Document No.", "Shipping Agent Code";
            CalcFields = Label;
            DataItemTableView = WHERE("Document Type" = CONST(Order));
            column(Label_ShipmentTracking; "Shipment Tracking".Label)
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

