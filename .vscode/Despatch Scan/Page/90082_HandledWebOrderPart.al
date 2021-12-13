page 90082 "Handled Web Order Detail"
{
    DeleteAllowed = false;
    Editable = false;
    PageType = ListPart;
    RefreshOnActivate = true;
    ModifyAllowed = false;
    SourceTable = "Handled Interim Sales Header";
    SourceTableView = WHERE("Document Type" = CONST(Order), "Return Note Download" = filter(false), "Package Tracking No." = filter(<> ''));
    InsertAllowed = false;
    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Trade Partner Code"; Rec."Trade Partner Code")
                {
                    ApplicationArea = all;
                }
                field("Channel Order ID"; Rec."Channel Order ID")
                {
                    ApplicationArea = all;
                }
                field("No."; Rec."No.")
                {
                    ApplicationArea = all;
                }
                field("Shipping Agent Code"; Rec."Shipping Agent Code")
                {
                    ApplicationArea = All;
                }
                field("Package Tracking No."; Rec."Package Tracking No.")
                {
                    ApplicationArea = All;
                }

            }
        }
    }
    actions
    {
        area(Processing)
        {
            action("Download Return Label")
            {
                Promoted = true;
                PromotedIsBig = true;
                PromotedCategory = Process;
                ApplicationArea = All;
                Image = Download;
                trigger OnAction()
                var
                    HISH: Record "Handled Interim Sales Header";
                    L_ShipmentTracking: Record "Shipment Tracking";
                    filename: Text;
                    FileOutStream: OutStream;
                    TempBlob: Codeunit "Temp Blob";
                    ReturnLabel: Report "Return Label";
                    FileMgt: Codeunit "File Management";
                    L_ShipmentTracking2: Record "Shipment Tracking";
                    FilterText: Code[250];
                    InStm: InStream;
                begin
                    Clear(FilterText);
                    Clear(HISH);
                    HISH := Rec;
                    CurrPage.SetSelectionFilter(HISH);
                    if HISH.FindSet() then begin
                        repeat
                            if HISH.Count = 1 then begin
                                L_ShipmentTracking.Reset();
                                L_ShipmentTracking.SetRange("Document Type", L_ShipmentTracking."Document Type"::Order);
                                L_ShipmentTracking.SetRange("Document No.", HISH."No.");
                                if L_ShipmentTracking.FindFirst() then begin
                                    L_ShipmentTracking.CalcFields("A6 Label1");
                                    L_ShipmentTracking."A6 Label1".CreateInStream(InStm);
                                    filename := 'ReturnLabel' + '-' + L_ShipmentTracking."Document No." + '.pdf';
                                    DownloadFromStream(InStm, '', '', '', filename);
                                end;
                                HISH."Return Note Download" := true;
                                HISH.Modify(true);
                            end;
                        until HISH.Next() = 0;
                    end;
                end;
            }
        }
    }
}

