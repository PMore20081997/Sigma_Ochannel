codeunit 90039 "Update Channel Customer"
{
    TableNo = "Job Queue Entry";
    trigger OnRun()
    begin
        StartParameter := Rec."Parameter String";
        if StartParameter <> '' then
            UpdateWebcustomer(StartParameter, '')
        else
            Error('Parameter String is missing');
    end;

    var
        myInt: Integer;
        StartParameter: Text;

    procedure UpdateWebcustomer(_ChannelCode: Code[20]; _CustomerNo: Code[20])
    var
        L_WebCustomer: Record "Interim Customer";
        L_TradePartner: Record "Trade Partner";
        L_Modified: Boolean;
        L_BilltoCustomer: Record Customer;
        L_Dimension: Record "Default Dimension";
        L_Customer: Record Customer;
    begin
        //Clear Variable++
        Clear(L_Modified);

        //Start Process to Update Web Customer++    
        L_WebCustomer.Reset();
        if _CustomerNo <> '' then
            L_WebCustomer.SetRange("Customer No.", _CustomerNo);
        L_WebCustomer.SetFilter("Channel Code", _ChannelCode);
        //L_WebCustomer.SetRange("Listing Status Setting", L_WebCustomer."Listing Status Setting"::Active);
        L_WebCustomer.SetCurrentKey("Channel Code");
        L_WebCustomer.Ascending(true);
        if L_WebCustomer.FindSet() then begin
            repeat
                L_Customer.Reset();
                L_Customer.SetRange("No.", L_WebCustomer."Customer No.");
                if L_Customer.FindFirst() then begin
                    Clear(L_Modified);

                    //Customer Name++
                    if L_WebCustomer.Name <> L_Customer.Name then begin
                        L_WebCustomer.Name := L_Customer.Name;
                        L_Modified := true;
                    end;

                    //Bill to customer No++
                    if L_WebCustomer."Bill to Customer No." <> L_Customer."Bill-to Customer No." then begin
                        L_WebCustomer."Bill to Customer No." := L_Customer."Bill-to Customer No.";
                        L_Modified := true;
                    end;

                    //Bill to Customer Name++
                    L_BilltoCustomer.Reset();
                    L_BilltoCustomer.SetRange("No.", L_Customer."Bill-to Customer No.");
                    if L_BilltoCustomer.FindFirst() then begin
                        if L_WebCustomer."Bill to Customer Name" <> L_BilltoCustomer.Name then begin
                            L_WebCustomer."Bill to Customer Name" := L_BilltoCustomer.Name;
                            L_Modified := true;
                        end;
                    end else begin
                        L_WebCustomer."Bill to Customer Name" := '';
                        L_Modified := true;
                    end;

                    #Region Only For LIFERAY & Other Channels+++
                    if L_WebCustomer."Channel Code" <> 'SIGCONNECT' then begin
                        //Customer Address++
                        if L_WebCustomer.Address <> L_Customer.Address then begin
                            L_WebCustomer.Address := L_Customer.Address;
                            L_Modified := true;
                        end;

                        if L_WebCustomer."Address 2" <> L_Customer."Address 2" then begin
                            L_WebCustomer."Address 2" := L_Customer."Address 2";
                            L_Modified := true;
                        end;

                        if L_WebCustomer.City <> L_Customer.City then begin
                            L_WebCustomer.City := L_Customer.City;
                            L_Modified := true;
                        end;

                        if L_WebCustomer.Country <> L_Customer."Country/Region Code" then begin
                            L_WebCustomer.Country := L_Customer."Country/Region Code";
                            L_Modified := true;
                        end;

                        if L_WebCustomer."Post Code" <> L_Customer."Post Code" then begin
                            L_WebCustomer."Post Code" := L_Customer."Post Code";
                            L_Modified := true;
                        end;

                        //Billing Address++
                        L_BilltoCustomer.Reset();
                        L_BilltoCustomer.SetRange("No.", L_Customer."Bill-to Customer No.");
                        if L_BilltoCustomer.FindFirst() then begin
                            if L_WebCustomer."Billing Address" <> L_BilltoCustomer.Address then begin
                                L_WebCustomer."Billing Address" := L_BilltoCustomer.Address;
                                L_Modified := true;
                            end;

                            if L_WebCustomer."Billing Address 2" <> L_BilltoCustomer."Address 2" then begin
                                L_WebCustomer."Billing Address 2" := L_BilltoCustomer."Address 2";
                                L_Modified := true;
                            end;

                            if L_WebCustomer."Billing City" <> L_BilltoCustomer.City then begin
                                L_WebCustomer."Billing City" := L_BilltoCustomer.City;
                                L_Modified := true;
                            end;

                            if L_WebCustomer."Billing Country" <> L_BilltoCustomer."Country/Region Code" then begin
                                L_WebCustomer."Billing Country" := L_BilltoCustomer."Country/Region Code";
                                L_Modified := true;
                            end;

                            if L_WebCustomer."Billing Post Code" <> L_BilltoCustomer."Post Code" then begin
                                L_WebCustomer."Billing Post Code" := L_BilltoCustomer."Post Code";
                                L_Modified := true;
                            end;
                        end else begin
                            L_WebCustomer."Billing Address" := '';
                            L_WebCustomer."Billing Address 2" := '';
                            L_WebCustomer."Billing City" := '';
                            L_WebCustomer."Billing Country" := '';
                            L_WebCustomer."Billing Post Code" := '';
                            L_Modified := true;
                        end;

                        //Customer Type++
                        L_Dimension.Reset();
                        L_Dimension.SetRange("Table ID", DATABASE::Customer);
                        L_Dimension.SetRange("No.", L_Customer."No.");
                        L_Dimension.SetRange("Dimension Code", 'CUSTOMER TYPE');
                        if L_Dimension.FindFirst() then begin
                            L_Dimension.CalcFields("Dimension Value Name");
                            if L_WebCustomer."Customer Type" <> L_Dimension."Dimension Value Name" then begin
                                L_WebCustomer."Customer Type" := L_Dimension."Dimension Value Name";
                                L_Modified := true;
                            end;
                        end else begin
                            L_WebCustomer."Customer Type" := '';
                            L_Modified := true;
                        end;

                        //Shipping agent Code++
                        if L_WebCustomer."Shipping Agent Code" <> L_Customer."Shipping Agent Code" then begin
                            L_WebCustomer."Shipping Agent Code" := L_Customer."Shipping Agent Code";
                            L_Modified := true;
                        end;

                        //Shipping agent Service Code++
                        if L_WebCustomer."Shipping Agent Service Code" <> L_Customer."Shipping Agent Service Code" then begin
                            L_WebCustomer."Shipping Agent Service Code" := L_Customer."Shipping Agent Service Code";
                            L_Modified := true;
                        end;

                        //Credit Limit++
                        L_BilltoCustomer.Reset();
                        L_BilltoCustomer.SetRange("No.", L_Customer."Bill-to Customer No.");
                        if L_BilltoCustomer.FindFirst() then begin
                            if L_WebCustomer."Credit Limit (LCY)" <> L_BilltoCustomer."Credit Limit (LCY)" then begin
                                L_WebCustomer."Credit Limit (LCY)" := L_BilltoCustomer."Credit Limit (LCY)";
                                L_Modified := true;
                            end;
                        end else begin
                            if L_WebCustomer."Credit Limit (LCY)" <> L_Customer."Credit Limit (LCY)" then begin
                                L_WebCustomer."Credit Limit (LCY)" := L_Customer."Credit Limit (LCY)";
                                L_Modified := true;
                            end;
                        end;

                        //Credit Limit Warning++
                        if L_WebCustomer."Credit Limit Warning" <> L_Customer."Credit Limit Warning" then begin
                            L_WebCustomer."Credit Limit Warning" := L_Customer."Credit Limit Warning";
                            L_Modified := true;
                        end;

                        //Blocked++
                        if L_WebCustomer.Blocked <> L_Customer.Blocked then begin
                            L_WebCustomer.Blocked := L_Customer.Blocked;
                            L_Modified := true;
                        end;

                        //Blocked Reason++
                        if L_WebCustomer."Block Reason" <> L_Customer."Block Reason" then begin
                            L_WebCustomer."Block Reason" := L_Customer."Block Reason";
                            L_Modified := true;
                        end;

                        //Customer Price Group++
                        if L_Customer."Customer Price Group" <> L_WebCustomer."Customer Price Group 1" then begin
                            L_WebCustomer."Customer Price Group 1" := L_Customer."Customer Price Group";
                            L_Modified := true;
                        end;

                        if L_WebCustomer."Customer Price Group 2" <> L_Customer."Customer Price Group 2" then begin
                            L_WebCustomer."Customer Price Group 2" := L_Customer."Customer Price Group 2";
                            L_Modified := true;
                        end;

                        if L_WebCustomer."Customer Price Group 3" <> L_Customer."Customer Price Group 3" then begin
                            L_WebCustomer."Customer Price Group 3" := L_Customer."Customer Price Group 3";
                            L_Modified := true;
                        end;

                    end;
                    #EndRegion Only For LIFERAY & Other Channels+++

                    #Region Only for Sigconnect+++
                    if (L_WebCustomer."Channel Code" = 'SIGCONNECT') then begin
                        if L_Customer."Customer Price Group" <> L_WebCustomer."Customer Price Group 1" then begin
                            L_WebCustomer."Customer Price Group 1" := L_Customer."Customer Price Group";
                            L_Modified := true;
                        end;

                        if L_WebCustomer."Customer Price Group 2" <> L_Customer."Customer Price Group 2" then begin
                            L_WebCustomer."Customer Price Group 2" := L_Customer."Customer Price Group 2";
                            L_Modified := true;
                        end;

                        if L_WebCustomer."Customer Price Group 3" <> L_Customer."Customer Price Group 3" then begin
                            L_WebCustomer."Customer Price Group 3" := L_Customer."Customer Price Group 3";
                            L_Modified := true;
                        end;

                        if L_WebCustomer."Customer Price Group 4" <> L_Customer."Customer Price Group 4" then begin
                            L_WebCustomer."Customer Price Group 4" := L_Customer."Customer Price Group 4";
                            L_Modified := true;
                        end;

                        if L_WebCustomer."Customer Price Group 5" <> L_Customer."Customer Price Group 5" then begin
                            L_WebCustomer."Customer Price Group 5" := L_Customer."Customer Price Group 5";
                            L_Modified := true;
                        end;

                        if L_WebCustomer."Customer Price Group 6" <> L_Customer."Customer Price Group 6" then begin
                            L_WebCustomer."Customer Price Group 6" := L_Customer."Customer Price Group 6";
                            L_Modified := true;
                        end;

                        if L_WebCustomer."Customer Price Group 7" <> L_Customer."Customer Price Group 7" then begin
                            L_WebCustomer."Customer Price Group 7" := L_Customer."Customer Price Group 7";
                            L_Modified := true;
                        end;

                        if L_WebCustomer."Customer Price Group 8" <> L_Customer."Customer Price Group 8" then begin
                            L_WebCustomer."Customer Price Group 8" := L_Customer."Customer Price Group 8";
                            L_Modified := true;
                        end;

                        if L_WebCustomer."Customer Price Group 9" <> L_Customer."Customer Price Group 9" then begin
                            L_WebCustomer."Customer Price Group 9" := L_Customer."Customer Price Group 9";
                            L_Modified := true;
                        end;

                        if L_WebCustomer."Customer Price Group 10" <> L_Customer."Customer Price Group 10" then begin
                            L_WebCustomer."Customer Price Group 10" := L_Customer."Customer Price Group 10";
                            L_Modified := true;
                        end;
                    end;
                    #EndRegion Only for Sigconnect & DC+++

                    if L_Modified = true then begin
                        L_WebCustomer."Customer Sync" := false;
                        L_WebCustomer.Modify();
                    end;
                end;
            until L_WebCustomer.Next() = 0;
        end;
    end;
}