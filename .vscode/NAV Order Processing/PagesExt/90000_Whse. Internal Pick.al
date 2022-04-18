pageextension 90010 "Ext. Whse. Internal Pick" extends "Whse. Internal Pick"
{
    layout
    {
        addafter("Sorting Method")
        {
            field("Trolley No."; Rec."Trolley No.")
            {
                ApplicationArea = All;
            }
        }
    }

    actions
    {
        // Add changes to page actions here
        addfirst(processing)
        {
            action("Print Delivery Note")
            {
                ApplicationArea = All;
                Image = Print;
                Promoted = true;
                PromotedCategory = Process;
                PromotedOnly = true;

                trigger OnAction()
                var
                    L_InterimSalesHeader: Record "Interim Sales Header";
                    R_DeliveryNote: Report 90072;
                begin
                    L_InterimSalesHeader.RESET;
                    L_InterimSalesHeader.SETRANGE("Destination Doc Type", L_InterimSalesHeader."Destination Doc Type"::"Internal Pick");
                    L_InterimSalesHeader.SETRANGE("Destination Doc No.", Rec."No.");
                    if Rec."Order Line Type" = Rec."Order Line Type"::"Single Line Orders" then begin
                        // L_InterimSalesHeader.CalcFields("Shelf No.");
                        L_InterimSalesHeader.SetCurrentKey("Shelf No.");
                        L_InterimSalesHeader.SetAscending("Shelf No.", true);
                    end;
                    IF L_InterimSalesHeader.FindSet() THEN BEGIN
                        Clear(R_DeliveryNote);
                        R_DeliveryNote.SetTableView(L_InterimSalesHeader);
                        R_DeliveryNote.UseRequestPage(false);
                        R_DeliveryNote.Run();
                    END;
                end;
            }
            action("Download Delivery Label")
            {
                ApplicationArea = All;
                Image = Print;
                Promoted = true;
                PromotedCategory = Process;
                PromotedOnly = true;
                trigger OnAction()
                var
                    R_CourierLabel: Report "Courier Label";
                    L_InterimSalesHeader: Record "Interim Sales Header";
                    L_ShipmentTracking: Record "Shipment Tracking";
                    L_ShipmentTracking2: Record "Shipment Tracking";
                    tempblob: Codeunit "Temp Blob";
                    RecRef: RecordRef;
                    Out: OutStream;
                    CU_90071: Codeunit 90071;
                    CU_90000: Codeunit 90000;
                    InStm: InStream;
                    fileName: text;
                    GeneralSetupOchannel: Record "General Setup - Channels";
                    CU_90089: Codeunit "Shipment Tracking Insertion";
                begin
                    GeneralSetupOchannel.Get();
                    if Not GeneralSetupOchannel."Download Lable on Azure" then begin
                        L_InterimSalesHeader.RESET;
                        L_InterimSalesHeader.SETRANGE("Destination Doc Type", L_InterimSalesHeader."Destination Doc Type"::"Internal Pick");
                        L_InterimSalesHeader.SETRANGE("Destination Doc No.", Rec."No.");
                        IF L_InterimSalesHeader.FindSet() THEN BEGIN
                            repeat
                                L_InterimSalesHeader.Mark(true);
                            until L_InterimSalesHeader.Next() = 0;
                            L_InterimSalesHeader.MarkedOnly(true);
                            if L_InterimSalesHeader.FindSet() then begin
                                repeat
                                    L_ShipmentTracking.Reset();
                                    L_ShipmentTracking.SetRange("Document No.", L_InterimSalesHeader."No.");
                                    L_ShipmentTracking.SetRange("Shipping Agent Code", L_InterimSalesHeader."Shipping Agent Code");
                                    if L_ShipmentTracking.FindSet() then begin
                                        repeat
                                            L_ShipmentTracking.Mark(true);
                                        until L_ShipmentTracking.Next() = 0;
                                        L_ShipmentTracking.MarkedOnly(true);
                                        if L_ShipmentTracking.FindSet() then begin
                                            L_ShipmentTracking.CheckForPrint := true;
                                            L_ShipmentTracking.Modify();
                                        end;
                                    end;
                                until L_InterimSalesHeader.Next() = 0;
                                L_ShipmentTracking2.Reset();
                                L_ShipmentTracking2.SetRange(CheckForPrint, true);
                                if L_ShipmentTracking2.FindSet() then begin
                                    Clear(R_CourierLabel);
                                    R_CourierLabel.SETTABLEVIEW(L_ShipmentTracking2);
                                    R_CourierLabel.USEREQUESTPAGE(FALSE);
                                    R_CourierLabel.Run();
                                end;
                            end;
                            L_ShipmentTracking2.Reset();
                            L_ShipmentTracking2.SetRange(CheckForPrint, true);
                            if L_ShipmentTracking2.FindSet() then begin
                                repeat
                                    L_ShipmentTracking2.CheckForPrint := false;
                                    L_ShipmentTracking2.Modify();
                                until L_ShipmentTracking2.Next() = 0;
                            end;
                        END;
                    End else begin
                        GeneralSetupOchannel.TestField("Courier Container Endpoint");
                        GeneralSetupOchannel.TestField("Courier Label Container Name");
                        GeneralSetupOchannel.TestField("Courier Label Container Token");
                        L_InterimSalesHeader.RESET;
                        L_InterimSalesHeader.SETRANGE("Destination Doc Type", L_InterimSalesHeader."Destination Doc Type"::"Internal Pick");
                        L_InterimSalesHeader.SETRANGE("Destination Doc No.", Rec."No.");
                        IF L_InterimSalesHeader.FindSet() THEN
                            repeat
                                L_ShipmentTracking.Reset();
                                L_ShipmentTracking.SetRange("Document No.", L_InterimSalesHeader."No.");
                                if L_ShipmentTracking.FindSet() then begin
                                    CU_90089.DownloadCourierLabeltoAzure(L_ShipmentTracking);
                                end;
                            until L_InterimSalesHeader.Next() = 0;
                    end;
                end;
            }
        }
        modify(CreatePick)
        {
            trigger OnBeforeAction()
            var
                RegisteredPick: Record "Registered Whse. Activity Hdr.";
            begin
                IF Rec."Trolley No." <> '' THEN BEGIN
                    RegisteredPick.RESET;
                    RegisteredPick.SETRANGE(Type, RegisteredPick.Type::Pick);
                    RegisteredPick.SETRANGE("Trolley No.", Rec."Trolley No.");
                    RegisteredPick.SETRANGE("Trolley Closed", FALSE);
                    IF RegisteredPick.FINDFIRST THEN
                        ERROR('You cannot create pick until previous trolley assigned on internal pick will close.');
                END;
            end;


        }
    }

    trigger OnDeleteRecord(): Boolean
    begin
        CreateWHInvPickHeaderWis."OndeleteW/HPick"(Rec);
    end;



    var
        CreateWHInvPickHeaderWis: Codeunit "Process Web Order";
}