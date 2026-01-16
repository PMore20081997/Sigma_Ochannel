report 90004 "Sync POD Job"
{
    UsageCategory = ReportsAndAnalysis;
    ApplicationArea = All;
    ProcessingOnly = true;

    dataset
    {
        dataitem("Sales Invoice Header"; "Sales Invoice Header")
        {
            RequestFilterFields = "No.";


            trigger OnAfterGetRecord()
            var
                L_PODfatherIntegration: Codeunit "POD Father Integration";
            begin
                //Run Process ++
                L_PODfatherIntegration.Job_OnPODFatherPortalNew("Sales Invoice Header"."No.", G_ChannelSetupCode)
            end;

            trigger OnPreDataItem()
            var
                L_PodFatherIntegration: Codeunit "POD Father Integration";
            begin
                if (G_DocumentType = G_DocumentType::" ") AND (G_DocumentType = G_DocumentType::"Sales Shipment") then
                    CurrReport.Skip();

                //Check Credential & Setup++
                L_PodFatherIntegration.CheckMandatoryfieldForJob(G_ChannelSetupCode);


                //Apply required filters++
                "Sales Invoice Header".SetRange("ePOD Sync", false);
                "Sales Invoice Header".SetRange("Customer Synced", true);
                "Sales Invoice Header".SetRange("Route Synced", true);
                if G_ShipmentDate <> 0D then
                    "Sales Invoice Header".SetRange("Shipment Date", G_ShipmentDate)
                else
                    "Sales Invoice Header".SetRange("Shipment Date", WorkDate());

            end;
        }
        // dataitem("Sales Shipment Header"; "Sales Shipment Header")
        // {

        //     trigger OnAfterGetRecord()
        //     begin
        //         //not required in sigma process+++
        //     end;

        //     trigger OnPreDataItem()
        //     begin
        //         if (G_DocumentType = G_DocumentType::" ") AND (G_DocumentType = G_DocumentType::"Sales Invoice") then
        //             CurrReport.Skip();
        //     end;
        // }
    }

    requestpage
    {
        layout
        {
            area(Content)
            {
                group("Filters: ")
                {
                    field(G_ChannelSetupCode; G_ChannelSetupCode)
                    {
                        Caption = 'Channel Setup Code: ';
                        ApplicationArea = All;
                        TableRelation = "Trade Partner".Code where(PodFather = const(true));
                    }

                    field(G_DocumentType; G_DocumentType)
                    {
                        Caption = 'Document Type: ';
                        ApplicationArea = All;
                        ToolTip = 'Specifies the type of document to process. Choose Sales Invoice to work with posted sales invoices,Sales Shipment to work with posted sales shipments';
                        ShowMandatory = true;
                    }
                    field(G_ShipmentDate; G_ShipmentDate)
                    {
                        Caption = 'Shipment Date: ';
                        ApplicationArea = All;
                        ToolTip = 'Specifies the shipment date to process';
                    }
                }
            }
        }
    }

    trigger OnPreReport()
    begin
        if G_DocumentType = G_DocumentType::" " then
            Error('Document type should not be blank');

        if G_ChannelSetupCode = '' then
            Error('Channel Setup Code should not be blank');
    end;

    var
        myInt: Integer;
        G_DocumentType: Option " ","Sales Invoice","Sales Shipment";
        G_ShipmentDate: Date;
        G_ChannelSetupCode: Code[20];

}