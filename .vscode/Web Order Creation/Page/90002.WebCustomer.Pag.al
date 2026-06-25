page 90002 "Web Customer"
{
    Caption = 'Channel Customer';
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Lists;
    SourceTable = "Interim Customer";
    InsertAllowed = false;

    layout
    {
        area(Content)
        {
            repeater(WebCustomerList)
            {
                field("Channel Code"; Rec."Channel Code")
                {
                    ApplicationArea = All;
                    Caption = 'Channel Code';
                    Editable = false;
                }
                field("Customer No."; Rec."Customer No.")
                {
                    ApplicationArea = All;
                    Caption = 'Customer No.';
                    Editable = false;
                }
                field("Concerto Customer No."; Rec."Concerto Customer No.")
                {
                    ApplicationArea = All;
                    Visible = false;
                    Editable = false;
                }
                field(Name; Rec.Name)
                {
                    ApplicationArea = All;
                    Caption = 'Name';
                    Editable = false;
                }
                field(Address; Rec.Address)
                {
                    ApplicationArea = All;
                    Caption = 'Address';
                    Editable = false;
                }
                field("Address 2"; Rec."Address 2")
                {
                    ApplicationArea = All;
                    Caption = 'Address 2';
                    Editable = false;
                }
                field(City; Rec.City)
                {
                    ApplicationArea = All;
                    Caption = 'City';
                    Editable = false;
                }
                field("Phone No"; Rec."Phone No")
                {
                    ApplicationArea = All;
                    Caption = 'Phone No';
                    Editable = false;
                }
                field("Post Code"; Rec."Post Code")
                {
                    ApplicationArea = All;
                    Caption = 'Post Code';
                    Editable = false;
                }
                field("Bill to Customer No."; Rec."Bill to Customer No.")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Bill to Customer Name"; Rec."Bill to Customer Name")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Credit Limit (LCY)"; Rec."Credit Limit (LCY)")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Credit Limit Warning"; Rec."Credit Limit Warning")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Customer Price Group 1"; Rec."Customer Price Group 1")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Customer Price Group 2"; Rec."Customer Price Group 2")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Customer Price Group 3"; Rec."Customer Price Group 3")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Customer Price Group 4"; Rec."Customer Price Group 4")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Customer Price Group 5"; Rec."Customer Price Group 5")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Customer Price Group 6"; Rec."Customer Price Group 6")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Customer Price Group 7"; Rec."Customer Price Group 7")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Customer Price Group 8"; Rec."Customer Price Group 8")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Customer Price Group 9"; Rec."Customer Price Group 9")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Customer Price Group 10"; Rec."Customer Price Group 10")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field(Blocked; Rec.Blocked)
                {
                    ApplicationArea = All;
                    Caption = 'Blocked';
                    Editable = false;
                }
                field("Block Reason"; Rec."Block Reason")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Listing Status Setting"; Rec."Listing Status Setting")
                {
                    ApplicationArea = All;
                    ToolTip = 'This is a user-editable field to enable/disable BC Customers in the portal';
                }
                field("Listing Status"; Rec."Listing Status")
                {
                    ApplicationArea = All;
                    ToolTip = 'Status to show if the Customer is Listed in the Portal or not';
                    Editable = false;
                }
                field("Customer Sync"; Rec."Customer Sync")
                {
                    ApplicationArea = All;
                    ToolTip = 'Acknowledgment from Portal that Customer has synced on their side';
                    //Editable = false;
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action("Open Customer Card")
            {
                ApplicationArea = All;
                Caption = 'Open Customer Card';
                ToolTip = 'Open Customer Card for selected line';
                Image = Customer;
                PromotedCategory = Process;
                Promoted = true;
                PromotedIsBig = true;
                PromotedOnly = true;

                trigger OnAction()
                var
                    L_Customer: Record Customer;
                begin
                    if Rec."Customer No." <> '' then begin
                        L_Customer.SetRange("No.", Rec."Customer No.");
                        if L_Customer.FindFirst() then
                            PAGE.Run(PAGE::"Customer Card", L_Customer)
                        else
                            MESSAGE('Customer %1 does not exist in the system.', Rec."Customer No.");
                    end else
                        MESSAGE('No Customer linked to this record.');
                end;
            }
            action("Update Web Customer")
            {
                ApplicationArea = All;
                Caption = 'Update Web Customer for selected line';
                ToolTip = 'Update Web Customer for selected line';
                Image = UpdateDescription;
                PromotedCategory = Process;
                Promoted = true;
                PromotedIsBig = true;
                PromotedOnly = true;
                trigger OnAction()
                var
                    L_InterimCustomer: Record "Interim Customer";
                    UpdateChannelCustomer: Codeunit "Update Channel Customer";
                    Windows: Dialog;
                    ProgressCount: Integer;
                    NoOfRecs: Integer;
                    Count: Integer;
                begin
                    L_InterimCustomer.Reset();
                    CurrPage.SetSelectionFilter(L_InterimCustomer);
                    if L_InterimCustomer.FindSet() then begin
                        Windows.OPEN('Updating...' + ' @1@@@@@@@@@@@@@\' + 'Please Wait..');
                        NoOfRecs := L_InterimCustomer.Count;
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

                            //Start Process++
                            UpdateChannelCustomer.UpdateWebcustomer(L_InterimCustomer."Channel Code", L_InterimCustomer."Customer No.");
                        until L_InterimCustomer.Next() = 0;
                    end;
                end;
            }


            group("LifeRay Integration")
            {
                action("Sales Price for selected line")
                {
                    ApplicationArea = All;
                    Image = Price;

                    trigger OnAction()
                    var
                        L_PriceListLine: Record "Channel Price";
                        CustomerPriceGroupText: Text;
                        L_LifeRaySalesPrice: Page "Channel Price List";
                    begin
                        Clear(CustomerPriceGroupText);
                        if Rec."Customer Price Group 1" <> '' then
                            CustomerPriceGroupText := CustomerPriceGroupText + Rec."Customer Price Group 1";
                        if Rec."Customer Price Group 2" <> '' then
                            CustomerPriceGroupText := CustomerPriceGroupText + '|' + Rec."Customer Price Group 2";
                        if Rec."Customer Price Group 3" <> '' then
                            CustomerPriceGroupText := CustomerPriceGroupText + '|' + Rec."Customer Price Group 3";
                        if Rec."Customer Price Group 4" <> '' then
                            CustomerPriceGroupText := CustomerPriceGroupText + '|' + Rec."Customer Price Group 4";
                        if Rec."Customer Price Group 5" <> '' then
                            CustomerPriceGroupText := CustomerPriceGroupText + '|' + Rec."Customer Price Group 5";
                        if Rec."Customer Price Group 6" <> '' then
                            CustomerPriceGroupText := CustomerPriceGroupText + '|' + Rec."Customer Price Group 6";
                        if Rec."Customer Price Group 7" <> '' then
                            CustomerPriceGroupText := CustomerPriceGroupText + '|' + Rec."Customer Price Group 7";
                        if Rec."Customer Price Group 8" <> '' then
                            CustomerPriceGroupText := CustomerPriceGroupText + '|' + Rec."Customer Price Group 8";
                        if Rec."Customer Price Group 9" <> '' then
                            CustomerPriceGroupText := CustomerPriceGroupText + '|' + Rec."Customer Price Group 9";
                        if Rec."Customer Price Group 10" <> '' then
                            CustomerPriceGroupText := CustomerPriceGroupText + '|' + Rec."Customer Price Group 10";

                        if CopyStr(CustomerPriceGroupText, 1, 1) = '|' then
                            CustomerPriceGroupText := CopyStr(CustomerPriceGroupText, 2);

                        Clear(L_LifeRaySalesPrice);
                        L_PriceListLine.Reset();
                        L_PriceListLine.SetRange("Price Type", L_PriceListLine."Price Type"::Sale);
                        L_PriceListLine.SetFilter("Price List Code", CustomerPriceGroupText);
                        L_PriceListLine.SetRange("Channel Code", Rec."Channel Code");
                        L_LifeRaySalesPrice.SetTableView(L_PriceListLine);
                        L_LifeRaySalesPrice.RunModal();
                    end;
                }
                action("Sync Customer to LifeRay")
                {
                    ApplicationArea = All;
                    Image = Create;
                    ToolTip = 'Sync Customer to LifeRay';
                    trigger OnAction()
                    var
                        Sync_Customer: Codeunit "Sync Product/Inv./Cust./Price";
                        L_InterimCustomer: Record "Interim Customer";
                        Windows: Dialog;
                        ProgressCount: Integer;
                        NoOfRecs: Integer;
                        Count: Integer;
                    begin
                        L_InterimCustomer.Reset();
                        CurrPage.SetSelectionFilter(L_InterimCustomer);
                        L_InterimCustomer.SetRange("Customer Sync", false);
                        L_InterimCustomer.SetRange("Channel Code", 'LIFERAY');
                        if L_InterimCustomer.FindSet() then begin
                            Windows.OPEN('Synchronization in progress with Liferay' + ' @1@@@@@@@@@@@@@\' + 'Please Wait..');
                            NoOfRecs := L_InterimCustomer.Count;
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
                                Sync_Customer.SyncCustomerToLiferay(L_InterimCustomer."Customer No.", L_InterimCustomer."Channel Code");
                            until L_InterimCustomer.Next() = 0;
                        end else
                            MESSAGE('No Customer to sync for selected record(s).');
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
                        L_CorrelationIDtracking.SetRange("Document Type", L_CorrelationIDtracking."Document Type"::Customer);
                        L_CorrelationIDtracking.SetRange("Document No.", Rec."Customer No.");
                        L_CorrelationIDtracking.SetFilter("Sync Date", '>=%1', WorkDate());
                        L_CorrelationIDtracking.SetRange("Channel Code", Rec."Channel Code");
                        PageLiferayCorrelationIDTrack.SetTableView(L_CorrelationIDtracking);
                        PageLiferayCorrelationIDTrack.Run();
                    end;
                }

                action("Show Error for Customer")
                {
                    Image = ErrorLog;
                    ApplicationArea = All;
                    ToolTip = 'Open Error List for Customer (SyncDate >= WorkDate)';

                    trigger OnAction()
                    var
                        page_LiferayErrorLog: Page "LifeRay Error Logs";
                        Table_LiferayErrorLog: Record "LifeRay Error Log";
                    begin
                        Clear(page_LiferayErrorLog);
                        Table_LiferayErrorLog.SetRange("Document Type", Table_LiferayErrorLog."Document Type"::Customer);
                        Table_LiferayErrorLog.SetFilter("Sync Date", '>=%1', WorkDate());
                        Table_LiferayErrorLog.SetRange("Channel Code", Rec."Channel Code");
                        page_LiferayErrorLog.SetTableView(Table_LiferayErrorLog);
                        page_LiferayErrorLog.Run();
                    end;
                }
            }
            group("Sigconnect Integration")
            {
                action("Update Customer Price Group")
                {
                    ApplicationArea = All;
                    Image = UpdateDescription;

                    trigger OnAction()
                    var
                        L_InterimCustomer: Record "Interim Customer";
                        L_Customer: Record Customer;
                        L_Modified: Boolean;
                    begin
                        L_InterimCustomer.Reset();
                        L_InterimCustomer.SetRange("Channel Code", 'SIGCONNECT');
                        if L_InterimCustomer.FindSet() then begin
                            repeat
                                Clear(L_Modified);
                                L_Customer.Reset();
                                L_Customer.SetRange("No.", L_InterimCustomer."No.");
                                if L_Customer.FindFirst() then begin
                                    if L_Customer."Customer Price Group" <> L_InterimCustomer."Customer Price Group 1" then begin
                                        L_InterimCustomer."Customer Price Group 1" := L_Customer."Customer Price Group";
                                        L_Modified := true;
                                    end;

                                    if L_InterimCustomer."Customer Price Group 2" <> L_Customer."Customer Price Group 2" then begin
                                        L_InterimCustomer."Customer Price Group 2" := L_Customer."Customer Price Group 2";
                                        L_Modified := true;
                                    end;

                                    if L_InterimCustomer."Customer Price Group 3" <> L_Customer."Customer Price Group 3" then begin
                                        L_InterimCustomer."Customer Price Group 3" := L_Customer."Customer Price Group 3";
                                        L_Modified := true;
                                    end;

                                    if L_InterimCustomer."Customer Price Group 4" <> L_Customer."Customer Price Group 4" then begin
                                        L_InterimCustomer."Customer Price Group 4" := L_Customer."Customer Price Group 4";
                                        L_Modified := true;
                                    end;

                                    if L_InterimCustomer."Customer Price Group 5" <> L_Customer."Customer Price Group 5" then begin
                                        L_InterimCustomer."Customer Price Group 5" := L_Customer."Customer Price Group 5";
                                        L_Modified := true;
                                    end;

                                    if L_InterimCustomer."Customer Price Group 6" <> L_Customer."Customer Price Group 6" then begin
                                        L_InterimCustomer."Customer Price Group 6" := L_Customer."Customer Price Group 6";
                                        L_Modified := true;
                                    end;

                                    if L_InterimCustomer."Customer Price Group 7" <> L_Customer."Customer Price Group 7" then begin
                                        L_InterimCustomer."Customer Price Group 7" := L_Customer."Customer Price Group 7";
                                        L_Modified := true;
                                    end;

                                    if L_InterimCustomer."Customer Price Group 8" <> L_Customer."Customer Price Group 8" then begin
                                        L_InterimCustomer."Customer Price Group 8" := L_Customer."Customer Price Group 8";
                                        L_Modified := true;
                                    end;

                                    if L_InterimCustomer."Customer Price Group 9" <> L_Customer."Customer Price Group 9" then begin
                                        L_InterimCustomer."Customer Price Group 9" := L_Customer."Customer Price Group 9";
                                        L_Modified := true;
                                    end;

                                    if L_InterimCustomer."Customer Price Group 10" <> L_Customer."Customer Price Group 10" then begin
                                        L_InterimCustomer."Customer Price Group 10" := L_Customer."Customer Price Group 10";
                                        L_Modified := true;
                                    end;

                                    if L_Modified then begin
                                        L_InterimCustomer."Customer Sync" := false;
                                        L_InterimCustomer.Modify();
                                    end;
                                end;
                            until L_InterimCustomer.Next() = 0;
                        end;

                        Message('Process Completed');
                    end;
                }

            }
        }
    }
}