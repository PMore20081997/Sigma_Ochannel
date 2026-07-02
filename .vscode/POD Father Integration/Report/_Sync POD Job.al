report 90004 "Sync POD Job"
{
    // UsageCategory = ReportsAndAnalysis;
    // ApplicationArea = All;
    ProcessingOnly = true;

    dataset
    {
        dataitem("Sales Invoice Header"; "Sales Invoice Header")
        {
            RequestFilterFields = "No.";


            trigger OnAfterGetRecord()
            begin
                //Run Process ++
                L_PODfatherIntegration.DeliveryJob_SynctoPOD("Sales Invoice Header"."No.", G_ChannelSetupCode)
            end;

            trigger OnPreDataItem()
            begin
                if G_DeliveryJob = false then
                    CurrReport.Break();

                if (G_DocumentType = G_DocumentType::" ") AND (G_DocumentType = G_DocumentType::"Sales Shipment") then
                    CurrReport.Break();

                //Check Credential & Setup++
                L_PodFatherIntegration.CheckMandatoryfieldForJob(G_ChannelSetupCode, G_JobType::Delivery);


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
        dataitem("Sales Header"; "Sales Header")
        {
            trigger OnAfterGetRecord()
            begin
                //Run Process ++
                L_PODfatherIntegration.CollectionJob_SynctoPOD("Sales Header"."No.", G_ExpectedReceiptDate, G_ChannelSetupCode)
            end;

            trigger OnPreDataItem()
            begin
                if G_CollectionJob = false then
                    CurrReport.Break();

                //Update Expected Receipt Date ++
                if G_ExpectedReceiptDate = 0D then
                    G_ExpectedReceiptDate := WorkDate();

                //Apply Filters++
                "Sales Header".SetRange("Sigma Driver Collection", true);
                "Sales Header".SetRange("Document Type", "Sales Header"."Document Type"::"Return Order");
                "Sales Header".SetRange(Status, "Sales Header".Status::Released);
                "Sales Header".SetRange("ePOD Sync", false);

                //Check Credential & Setup++
                L_PodFatherIntegration.CheckMandatoryfieldForJob(G_ChannelSetupCode, G_JobType::Collection);
            end;
        }
    }

    requestpage
    {
        layout
        {
            area(Content)
            {
                field(G_ChannelSetupCode; G_ChannelSetupCode)
                {
                    Caption = 'Channel Setup Code: ';
                    ApplicationArea = All;
                    TableRelation = "Trade Partner".Code where(PodFather = const(true));
                }
                group("DeliveryJob Filters: ")
                {
                    field(G_DeliveryJob; G_DeliveryJob)
                    {
                        ApplicationArea = All;
                        Caption = 'Enable Delivery Job: ';
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
                group("CollectionJob Filters: ")
                {
                    field(G_CollectionJob; G_CollectionJob)
                    {
                        ApplicationArea = All;
                        Caption = 'Enable Collection Job: ';
                    }
                    field(G_ExpectedReceiptDate; G_ExpectedReceiptDate)
                    {
                        Caption = 'Expected Receipt Date ';
                        ApplicationArea = All;
                        ToolTip = 'This Expected Receipt Date specifies when the Tote/Box need to be collected. If it is left blank, the system will always create the collection job for the same day when the job queue run.';
                    }
                }
            }
        }
    }

    trigger OnPreReport()
    begin
        if G_DeliveryJob = true then
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
        G_CollectionJob: Boolean;
        G_ExpectedReceiptDate: Date;
        G_DeliveryJob: Boolean;
        G_JobType: Option Delivery,Collection;
        L_PODfatherIntegration: Codeunit "POD Father Integration";

}