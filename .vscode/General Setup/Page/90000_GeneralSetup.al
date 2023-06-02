page 90000 "General Setup - Channels"
{
    UsageCategory = Administration;
    ApplicationArea = All;
    PageType = Card;
    SourceTable = "General Setup - Channels";
    InsertAllowed = false;
    DeleteAllowed = false;
    ModifyAllowed = true;
    layout
    {
        area(Content)
        {
            group(General)
            {
                field("Sales Channel Order Id"; Rec."Web Order Nos")
                {
                    ApplicationArea = All;
                }
                field("Shipping G/L No."; Rec."Shipping G/L No.")
                {
                    ApplicationArea = All;
                }
                field("GiftWrap G/L No."; Rec."GiftWrap G/L No.")
                {
                    ApplicationArea = All;
                }
                field("Invoice G/L No."; Rec."Invoice G/L No.")
                {
                    ApplicationArea = All;
                }
                field("Manifest Nos"; Rec."Manifest Nos")
                {
                    ApplicationArea = All;
                }
                field("Despatch Scan Enabled"; rec."Despatch Scan Enabled")
                {
                    ApplicationArea = All;
                }
                //Sofyan++
                field("Consolidate Item on WIP"; Rec."Consolidate Item on WIP")
                {
                    ApplicationArea = All;
                }
                field("Auto Release Sales Orders"; Rec."Auto Release Sales Orders")
                {
                    ApplicationArea = All;
                }
                //Sofyan--
                //Pranali++
                field("Print Return Note"; Rec."Print Return Note")
                {
                    ApplicationArea = All;
                }
                field("Print Order Label"; Rec."Print Order Label")
                {
                    ApplicationArea = All;
                }
                field("Print Return Label"; Rec."Print Return Label")
                {
                    ApplicationArea = All;
                }
                //Pranali--
                field("Web Sales Invoice No.s"; Rec."Web Sales Invoice No.s")
                {
                    ApplicationArea = All;
                    Description = 'CAS-26633-Z8W1Y1.MH';
                }
                field("Item Journal Template"; Rec."Item Journal Template")
                {
                    ApplicationArea = All;
                    Description = 'CAS-26633-Z8W1Y1.MH';
                }
                field("Item Journal Batch"; Rec."Item Journal Batch")
                {
                    ApplicationArea = All;
                    Description = 'CAS-26633-Z8W1Y1.MH';
                }
                field("Cash Rct Template Name"; Rec."Cash Rct Template Name")
                {
                    ApplicationArea = All;
                    Description = 'CAS-27945-M1R5J2';
                }
                field("Cash Rct Batch Name"; Rec."Cash Rct Batch Name")
                {
                    ApplicationArea = All;
                    Description = 'CAS-27945-M1R5J2';
                }
                field("Quantity Restriction"; Rec."Quantity Restriction")
                {
                    ApplicationArea = All;
                    DecimalPlaces = 0 : 0;
                    Caption = 'Multi-Line Quantity Restriction';
                }
                field("Quantity Restriction (SINGLE)"; Rec."Quantity Restriction (SINGLE)")
                {
                    ApplicationArea = All;
                    DecimalPlaces = 0 : 0;
                    Caption = 'Single-Line Quantity Restriction';
                }
                field("Production Item Inventory"; Rec."Production Item Inventory")
                {
                    ApplicationArea = all;
                    CaptionML = ENG = 'Production Item Inventory', ENU = 'Production Item Inventory';
                    trigger OnValidate()
                    var
                        CIL: Record "Channel Item Listing";
                        ItemRec: Record Item;
                    begin
                        If xRec."Production Item Inventory" <> Rec."Production Item Inventory" then begin
                            ItemRec.Reset();
                            ItemRec.SetRange("Production Item", true);
                            if ItemRec.FindFirst() then begin
                                repeat
                                    CIL.Reset();
                                    CIL.SetFilter("Item No.", '<>%1', '');
                                    CIL.SetRange("Item No.", ItemRec."No.");
                                    if CIL.FindFirst() then begin
                                        CIL."Inventory Synced" := false;
                                        CIL.Modify();
                                    end;
                                until ItemRec.Next() = 0;
                            end;
                        end;
                    end;
                }
                field("Bank Account No."; Rec."Bank Account No.")
                {
                    ApplicationArea = All;
                }
                field("Threshold Value"; Rec."Threshold Value")
                {
                    ApplicationArea = All;
                    DecimalPlaces = 0 : 2;
                }
                field("Delete Shipment Tracking"; Rec."Delete Shipment Tracking")
                {
                    ApplicationArea = All;
                }
                field("Payment Journal Template"; Rec."Payment Journal Template")
                {
                    ApplicationArea = All;
                }
                field("Payment Jounal Batch"; Rec."Payment Jounal Batch")
                {
                    ApplicationArea = All;
                }
                field("G/L Account No."; Rec."G/L Account No.")
                {
                    ApplicationArea = All;
                    Caption = 'G/L Account for Fee Posting';
                }
                field("Allocate Web Orders"; Rec."Allocate Web Orders")
                {
                    ApplicationArea = All;
                }
                field("Enable Carriage credit"; rec."Enable Carriage credit")
                {
                    ApplicationArea = All;
                }
                field("Download Lable on Azure"; Rec."Download Lable on Azure")
                {
                    ApplicationArea = All;
                    trigger OnValidate()
                    begin
                        IsDownloadonAzureEnable := rec."Download Lable on Azure";
                    end;

                }
                field("Courier Label Container Name"; rec."Courier Label Container Name")
                {
                    ApplicationArea = All;
                    Editable = IsDownloadonAzureEnable;
                }
                field("Courier Label Container Token"; rec."Courier Label Container Token")
                {
                    ApplicationArea = All;
                    Editable = IsDownloadonAzureEnable;
                    ExtendedDatatype = Masked;
                }
                field("Courier Container Attribute"; rec."Courier Container Attribute")
                {
                    ApplicationArea = All;
                    Editable = IsDownloadonAzureEnable;
                }
                field("Courier Container Endpoint"; rec."Courier Container Endpoint")
                {
                    ApplicationArea = All;
                    Editable = IsDownloadonAzureEnable;
                }
                field("Order Value"; Rec."Order Value")
                {
                    ApplicationArea = All;
                }

                field(AutoReserve; Rec.AutoReserve)
                {
                    Caption = 'Auto Reserve';
                    ApplicationArea = All;
                }

            }
            group(Despatch)
            {
                field("Despatch Printer Selection"; Rec."Despatch Printer Selection")
                {
                    ApplicationArea = All;
                    ToolTip = 'Enable this to add workstation selection on B2C Despatch scan. Reports selections will need to be set up for the relevent reports';
                }
                field("Label Report ID"; Rec."Label Report ID")
                {
                    ApplicationArea = all;
                    ToolTip = 'Set this to the Label Report id used for automatic despatch. used by Despatch Printer Selection';
                }
                field("DPD Label Report ID"; Rec."DPD Label Report ID")
                {
                    ApplicationArea = all;
                    ToolTip = 'Set this to the DPD Label report id used for automatic despatch. used by Despatch Printer Selection';
                }
                field("Despatch Note Report ID"; Rec."Despatch Note Report ID")
                {
                    ApplicationArea = all;
                    ToolTip = 'Set this to the Despatch Note id used for automatic despatch. used by Despatch Printer Selection';
                }

            }
        }
    }


    trigger OnOpenPage()
    var
    begin
        Rec.RESET;
        IF NOT Rec.GET THEN BEGIN
            Rec.INIT;
            Rec.INSERT;
        END;
    end;

    trigger OnAfterGetRecord()
    begin
        IsDownloadonAzureEnable := rec."Download Lable on Azure";
    end;

    var
        [InDataSet]
        IsDownloadonAzureEnable: Boolean;
}