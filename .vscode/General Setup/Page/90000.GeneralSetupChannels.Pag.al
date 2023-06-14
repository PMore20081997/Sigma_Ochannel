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

                field("Despatch Scan Enabled"; rec."Despatch Scan Enabled")
                {
                    ApplicationArea = All;
                }

                field("Auto Release Sales Orders"; Rec."Auto Release Sales Orders")
                {
                    ApplicationArea = All;
                }

                field("Delete Shipment Tracking"; Rec."Delete Shipment Tracking")
                {
                    ApplicationArea = All;
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