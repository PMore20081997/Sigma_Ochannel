page 90062 "PS Label Details"
{
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Administration;
    SourceTable = "Polar Speed Barcode Details";
    // Editable = false;
    // ModifyAllowed = false;
    // DeleteAllowed = false;

    layout
    {
        area(Content)
        {
            repeater(List)
            {
                field("Order Category"; Rec."Order Category")
                {
                    ApplicationArea = All;
                }
                field("Print Date"; Rec."Print Date")
                {
                    ApplicationArea = All;
                }
                field("Order No."; Rec."Order No.")
                {
                    ApplicationArea = All;
                }
                field("Sales Invoice No"; Rec."Sales Invoice No.")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field("Customer No."; Rec."Customer No.")
                {
                    ApplicationArea = All;
                    Caption = 'Sell to Customer No.';
                }
                field("Tote No"; Rec."Tote/Order No.")
                {
                    ApplicationArea = All;
                    Caption = 'Tote/Order No.';
                }
                field("Barcode No."; Rec."Barcode No.")
                {
                    ApplicationArea = All;
                    Caption = 'Barcode';
                }
                field("Box No"; Rec."No. of Box / Tote Sequence")
                {
                    ApplicationArea = All;
                    Caption = 'No. of Box / Tote Sequence';
                }
                field(Temprature; Rec.Temprature)
                {
                    ApplicationArea = All;
                }
                field("Shipment Date"; Rec."Shipment Date")
                {
                    ApplicationArea = All;
                }
                field("No. of Print"; Rec."No. of Print")
                {
                    ApplicationArea = all;
                    Editable = false;
                    Visible = false;
                }
                field(SystemCreatedBy; GetUserName(Rec.SystemCreatedBy))
                {
                    ApplicationArea = All;
                    Caption = 'Created By';
                }

            }
        }
    }

    actions
    {
        area(Processing)
        {
            action("Polar Item Label")
            {
                Caption = 'Polar Item Label';
                Image = Print;
                ApplicationArea = All;
                Promoted = true;
                PromotedCategory = Process;

                trigger OnAction()
                var
                    L_Barcode: Record "Polar Speed Barcode Details";
                    Report_PolarItemLabel: Report "Polar Item Label";
                begin
                    Clear(Report_PolarItemLabel);
                    L_Barcode.Reset();
                    CurrPage.SetSelectionFilter(L_Barcode);
                    Report_PolarItemLabel.SetTableView(L_Barcode);
                    Report_PolarItemLabel.UseRequestPage(true);
                    Report_PolarItemLabel.RunModal();
                end;
            }

            action("Download Manifest File")
            {
                Caption = 'Download manifest file to PC';
                Image = Download;
                ApplicationArea = All;
                Promoted = true;
                PromotedCategory = Process;
                trigger OnAction()
                var
                    L_Barcode: Record "Polar Speed Barcode Details";
                    PSManifestFile: XmlPort "PS Manifest File";
                begin
                    Clear(PSManifestFile);
                    L_Barcode.Reset();
                    CurrPage.SetSelectionFilter(L_Barcode);
                    if L_Barcode.FindFirst() then begin
                        PSManifestFile.SetTableView(L_Barcode);
                        PSManifestFile.GetFilters(WorkDate(), 0, L_Barcode.Temprature);
                        PSManifestFile.Filename('ManifestFile.CSV');
                        PSManifestFile.Run();
                    end;
                end;
            }
            action("Upload Manifest File")
            {
                Caption = 'Upload manifest file to container';
                Image = Download;
                ApplicationArea = All;
                Promoted = true;
                PromotedCategory = Process;

                trigger OnAction()
                var
                    PSManifestFileJob: Codeunit "PS Manifest File Job";
                begin
                    PSManifestFileJob.UploadManifestFileToContainer('POLARSPEED');
                end;
            }
        }
    }

    var
        myInt: Integer;

    procedure GetUserName(UserSecurityId: Code[50]): Text[100]
    var
        Users: Record User;
    begin
        Users.Reset();
        Users.SetRange("User Security ID", UserSecurityId);
        if Users.FindFirst() then
            exit(Users."User Name");
    end;
}