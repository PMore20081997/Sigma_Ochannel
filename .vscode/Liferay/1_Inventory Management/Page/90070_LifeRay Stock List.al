page 90070 "LifeRay Stock List"
{
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Lists;
    SourceTable = "LifeRay Stock";
    // DeleteAllowed = false;
    // Editable = false;
    // InsertAllowed = false;
    // ModifyAllowed = false;

    layout
    {
        area(Content)
        {
            repeater(List)
            {
                //Editable = false;
                field("Entry No."; Rec."Entry No.")
                {
                    ApplicationArea = All;
                }
                field("Channel Code"; Rec."Channel Code")
                {
                    ApplicationArea = All;
                }
                field("Sync Type"; Rec."Sync Type")
                {
                    Caption = 'Type';
                    ApplicationArea = All;
                }
                field("Item No."; Rec."Item No.")
                {
                    ApplicationArea = All;

                }
                field("Variant Code"; Rec."Variant Code")
                {
                    ApplicationArea = All;

                }
                field("Variant Priority"; Rec."Variant Priority")
                {
                    ApplicationArea = All;

                }
                field("Location Code"; Rec."Location Code")
                {
                    ApplicationArea = All;

                }
                field(Inventory; Rec.Inventory)
                {
                    ApplicationArea = All;

                }
                field("Created On"; Rec."Created On")
                {
                    ApplicationArea = All;

                }
                field(Sync; Rec.Sync)
                {
                    ApplicationArea = All;

                }
                field(SystemCreatedAt; Rec.SystemCreatedAt)
                {
                    ApplicationArea = All;

                }
                field(SystemCreatedBy; GetUserName(Rec.SystemCreatedBy))
                {
                    ApplicationArea = All;

                }
            }

        }
        area(FactBoxes)
        {

        }
    }

    actions
    {
        area(Processing)
        {
            group(Integration)
            {
                action("Sync selected inventory to LifeRay")
                {
                    ApplicationArea = All;
                    Image = Create;
                    ToolTip = 'Sync selected full & delta inventory to LifeRay';
                    trigger OnAction()
                    var
                        SyncProduct_Inventory: Codeunit "Sync Product/Inv./Cust./Price";
                        L_LiferayStock: Record "LifeRay Stock";
                        Windows: Dialog;
                        ProgressCount: Integer;
                        NoOfRecs: Integer;
                        Count: Integer;
                    // Test: Codeunit "Process Inventory Push Queue";
                    // test1: Record "Job Queue Entry";
                    begin
                        L_LiferayStock.Reset();
                        CurrPage.SetSelectionFilter(L_LiferayStock);
                        L_LiferayStock.SetRange(Sync, false);
                        L_LiferayStock.SetRange("Channel Code", 'LIFERAY');
                        if L_LiferayStock.FindSet() then begin
                            Windows.OPEN('Synchronization in progress with Liferay' + ' @1@@@@@@@@@@@@@\' + 'Please Wait..');
                            NoOfRecs := L_LiferayStock.Count;
                            repeat
                                ProgressCount += 1;
                                if NoOfRecs > 0 then begin
                                    if NoOfRecs <= 100 then begin
                                        Windows.UPDATE(1, (ProgressCount / NoOfRecs * 10000) DIV 1)
                                    end else begin
                                        IF Count MOD (NoOfRecs DIV 100) = 0 THEN BEGIN
                                            Windows.UPDATE(1, (ProgressCount / NoOfRecs * 10000) DIV 1)
                                        END;
                                    end;
                                end;

                                //Start syncing process+++
                                if L_LiferayStock."Sync Type" = L_LiferayStock."Sync Type"::Full then
                                    SyncProduct_Inventory.SyncFullInventoryToLiferay(L_LiferayStock."Entry No.", L_LiferayStock."Channel Code");

                                if L_LiferayStock."Sync Type" = L_LiferayStock."Sync Type"::Delta then
                                    SyncProduct_Inventory.SyncDeltaInventoryToLiferay(L_LiferayStock."Entry No.", L_LiferayStock."Channel Code");
                            until L_LiferayStock.Next() = 0;
                        end;
                        //Test.Run(test1);
                    end;
                }

                action("Corralation-ID Tracking")
                {
                    ApplicationArea = all;
                    Image = Navigate;
                    ToolTip = 'Open Corralation-ID Tracking page for selected line (SyncDate >= WorkDate)';
                    trigger OnAction()
                    var
                        L_CorrelationIDtracking: Record "correlation-id Tracking";
                        PageLiferayCorrelationIDTrack: Page "Liferay Correlation ID Track";
                    begin
                        Clear(PageLiferayCorrelationIDTrack);
                        L_CorrelationIDtracking.Reset();
                        if Rec."Sync Type" = Rec."Sync Type"::Full then
                            L_CorrelationIDtracking.SetRange("Document Type", L_CorrelationIDtracking."Document Type"::FullIventory)
                        else
                            L_CorrelationIDtracking.SetRange("Document Type", L_CorrelationIDtracking."Document Type"::DeltaInventory);
                        L_CorrelationIDtracking.SetRange("Document No.", Format(Rec."Entry No."));
                        L_CorrelationIDtracking.SetRange("Channel Code", Rec."Channel Code");
                        L_CorrelationIDtracking.SetFilter("Sync Date", '>=%1', WorkDate());
                        PageLiferayCorrelationIDTrack.SetTableView(L_CorrelationIDtracking);
                        PageLiferayCorrelationIDTrack.Run();
                    end;
                }

                action("Show Error for Inventory")
                {
                    Image = ErrorLog;
                    ApplicationArea = All;
                    ToolTip = 'Open error list for inventory';

                    trigger OnAction()
                    var
                        page_LiferayErrorLog: Page "LifeRay Error Logs";
                        Table_LiferayErrorLog: Record "LifeRay Error Log";
                    begin
                        Clear(page_LiferayErrorLog);
                        if Rec."Sync Type" = Rec."Sync Type"::Full then
                            Table_LiferayErrorLog.SetRange("Document Type", Table_LiferayErrorLog."Document Type"::FullIventory);
                        if Rec."Sync Type" = Rec."Sync Type"::Delta then
                            Table_LiferayErrorLog.SetRange("Document Type", Table_LiferayErrorLog."Document Type"::DeltaInventory);
                        Table_LiferayErrorLog.SetFilter("Sync Date", '>=%1', WorkDate());
                        Table_LiferayErrorLog.SetRange("Channel Code", Rec."Channel Code");
                        page_LiferayErrorLog.SetTableView(Table_LiferayErrorLog);
                        page_LiferayErrorLog.Run();
                    end;
                }
            }
        }
        area(Promoted)
        {
            group(Integration_Prometed)
            {
                Caption = 'Integration';
                actionref("Sync Stock to LifeRay_Prometed"; "Sync selected inventory to LifeRay")
                {

                }
                actionref("Show Error for Inventory_Prometed"; "Show Error for Inventory")
                {

                }
                actionref("Corralation-ID Tracking_Prometed"; "Corralation-ID Tracking")
                {

                }
            }
        }

    }

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