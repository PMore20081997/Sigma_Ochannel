report 90083 "Process Shipping Rule"
{/*
    ProcessingOnly = true;

    dataset
    {
        dataitem(InterimSH; "Interim Sales Header")
        {
            CalcFields = "Tracking No.";
            DataItemTableView = SORTING("Document Type", "No.")
                                ORDER(Ascending)
                                WHERE("Document Type" = FILTER(Order),
                                      //"Order status" = FILTER("In Progress"),
                                      "Tracking No." = FILTER(''));
            RequestFilterFields = "Trade Partner Code", "No.", "Sell-to Customer No.", "Ship-to Country/Region Code";

            trigger OnAfterGetRecord()
            var
                //  CourierIntegration: Codeunit "Courier Integration";//Commented By Pavan
                CurrRec: Integer;
                ChanCode: Code[20];
                ItemNo: Code[20];
                CustomerNo: Code[20];
                ISL: Record "Interim Sales Line";
                InterimSalesHeader: Record "Interim Sales Header";
                HISH: Record "Handled Interim Sales Header";
                HISL: Record "Handled Interim Sales Line";
                InterimSalesHeader1: Record "Interim Sales Header";
                Customer: Record 18;
                ShipmentTracking: Record "Shipment Tracking";
                //CreateOrder: Codeunit "CreateSingleOrder-Innox";
            begin

                InterimSalesHeader.CALCFIELDS("Tracking No.");
                i := i + 1;
                //IF InterimSalesHeader."Tracking No."='' THEN
                //BEGIN

                //OrderRead.CS_CheckExistingErrorrRecord(InterimSH);
                ShippingRuleTracking(InterimSH);

                //END;

                IF NoofOrders > 0 THEN BEGIN
                    IF i >= NoofOrders THEN
                        CurrReport.BREAK;
                END;

                COMMIT;
                //END;
            end;

            trigger OnPreDataItem()
            begin
                Window.OPEN('Validating and Generating Tracking... @1@@@@@@@@@@');
                /*IF NoOfItems=NoOfItems::Single THEN
                  InterimSH.SETFILTER("No. of Items",'%1',1);
                
                IF  NoOfItems=NoOfItems::Multiple THEN
                  InterimSH.SETFILTER("No. of Items",'>%1',1);
                CLEAR(NoOfRecs);
                CLEAR(CurrRec);
                NoOfRecs := InterimSH.COUNT;

            end;
        }
    }

    requestpage
    {

        layout
        {
            area(content)
            {
                field("Item No"; Itemno)
                {
                    Visible = false;
                    ApplicationArea = All;

                    trigger OnLookup(var Text: Text): Boolean
                    begin
                        CLEAR(ItemList);
                        RecItem.RESET;
                        RecItem.SETRANGE(Blocked, FALSE);
                        ItemList.SETTABLEVIEW(RecItem);
                        ItemList.LOOKUPMODE(TRUE);
                        IF ItemList.RUNMODAL = ACTION::LookupOK THEN BEGIN
                            Itemno := ItemList.GetSelectionFilter();
                        END;
                    end;
                }
                field("No Of Orders"; NoofOrders)
                {
                    ApplicationArea = All;

                    trigger OnValidate()
                    begin

                        //CompanyInformation.VALIDATE("No Of Orders",NoofOrders);
                        //CompanyInformation.MODIFY;
                    end;
                }
                field("No Of Items"; NoOfItems)
                {
                    Caption = 'No Of Items';
                    ShowMandatory = true;
                    Visible = false;
                    ApplicationArea = All;
                }
            }
        }

        actions
        {

        }

        trigger OnOpenPage()
        begin
            NoofOrders := 0;
        end;

        trigger OnQueryClosePage(CloseAction: Action): Boolean
        begin
            /*IF CloseAction=ACTION::OK THEN
            IF NoOfItems=NoOfItems::" " THEN
              ERROR('Please select no of items');

        end;
    }

    labels
    {
    }

    trigger OnPostReport()
    begin
        Window.CLOSE;
        /*IF CS_ISH.FINDSET THEN;
        COMMIT;
        CLEAR(ProcessWebOrders_New);
        ProcessWebOrders_New.SETTABLEVIEW(CS_ISH);
        ProcessWebOrders_New.SetNoOfOrders(NoofOrders);
        ProcessWebOrders_New.USEREQUESTPAGE:=FALSE;
        ProcessWebOrders_New.RUNMODAL();

    end;

    trigger OnPreReport()
    begin
        Window.OPEN('Validating Required Information... @1@@@@@@@@@@');
        DeleteRejectedLines; // Chris *****Code for moving to Handled
        //Checkforerrors; //Chris **Code check for errors

        //UpdateNoofItems;
        CS_ISH.COPYFILTERS(InterimSH);
        CLEAR(i);
        Window.CLOSE;
    end;

    var
        //OrderRead: Codeunit "Process Order File-Innox";
        
        // AmazonIntegration: Codeunit "Amazon Integration"; //Commented By Pavan
        HeaderNo: Code[20];
        ShipmentTracking: Record "Shipment Tracking";
        LineNo: Integer;
        TempSalesHeader: Record 36;
        SalesLine: Record 37;
        RecSalesLine1: Record 37;
        Itemno: Text;
        FirstOrder: Boolean;
        NoOfRecs: Integer;
        Window: Dialog;
        ItemList: Page 31;
        RecItem: Record 27;
        CS_ISH: Record "Interim Sales Header";
        CurrRec: Integer;
        IsLocalDelivery: Boolean;
        PostCode: Record 225;
        ChannelCode: Text;
        NoofOrders: Integer;
        [SecurityFiltering(SecurityFilter::Ignored)]
        CompanyInformation: Record "Company Information";
        i: Integer;
        NoOfItems: Option " ",Single,Multiple;

    local procedure DeleteRejectedLines()
    var
        ISH: Record "Interim Sales Header";
        ISL: Record "Interim Sales Line";
        HISH: Record "Handled Interim Sales Header";
        HISL: Record "Handled Interim Sales Line";
    begin
        // Chris *****Code for moving to Handled **ST*****
        ISH.RESET;
        //ISH.SETFILTER("Line Action", '%1', ISH."Line Action"::Reject);
        IF ISH.FINDSET THEN BEGIN
            REPEAT
                //  DeleteRejected(ISH);
                HISL.RESET;
                HISL.INIT;
                ISL.RESET;
                //ISL.SETRANGE("Transaction No.", ISH."Transaction No.");
                IF ISL.FINDSET THEN BEGIN
                    REPEAT
                    // HISL.TRANSFERFIELDS(ISL);
                    // HISL.INSERT(TRUE);
                    UNTIL ISL.NEXT = 0;
                    ISL.DELETEALL(TRUE);
                END;
            UNTIL ISH.NEXT = 0;
            ISH.DELETEALL(TRUE);
        END;


        // Chris *****Code for moving to Handled **EN*****
    end;

    local procedure Checkforerrors()
    var
        InterimSalesHeader1: Record "Interim Sales Header";
        Customer: Record Customer;
    begin
        InterimSalesHeader1.RESET;
        // InterimSalesHeader1.SETFILTER("Line Action", '<>%1', InterimSalesHeader1."Line Action"::Accept);
        InterimSalesHeader1.SETFILTER("Shipping Agent Code", '%1', '');
        InterimSalesHeader1.SETFILTER("Tracking No.", '%1', '');
        //InterimSalesHeader1.SETFILTER("Sales Order No.", '%1', '');
        IF InterimSalesHeader1.FINDSET THEN
            REPEAT
            // OrderRead.CH_CheckExistingErrorrRecord(InterimSalesHeader1."Transaction No.");
            /*IF Customer.GET(InterimSalesHeader1."Sell-to Customer No.") THEN BEGIN
              InterimSalesHeader1.VALIDATE("Location Code",Customer."Location Code");
              InterimSalesHeader1.VALIDATE("Ship-to Phone",Customer."Phone No.");
              InterimSalesHeader1.MODIFY;
              //MESSAGE('cust %1..%2',Customer."Location Code",InterimSalesHeader1."No.");
              END;

            UNTIL InterimSalesHeader1.NEXT = 0;

    end;

    procedure ShippingRuleTracking(var ISH: Record "Interim Sales Header")
    var
        ISL: Record "Interim Sales Header";
        //  CourierIntegration: Codeunit "Courier Integration";//Commented By Pavan
        L_InterimSalesLine: Record "Interim Sales Line";
        L_InterimSalesHeader: Record "Interim Sales Header";
        TotalWeight: Decimal;
        L_Item: Record 27;
    begin
        // Chris *****Code for creating shipping rule and tracking **ST*****
        ISH.CALCFIELDS("No of Error");
        //ISH.SETRANGE("No of Error",0);
        //ISH.SETRANGE("Line Action",ISH."Line Action"::Accept);
        /*IF (ISH."No of Error" = 0) AND (ISH."Line Action" = ISH."Line Action"::Accept) THEN BEGIN
            CurrRec += 1;
            IF NoOfRecs <= 100 THEN
                Window.UPDATE(1, (CurrRec / NoOfRecs * 10000) DIV 1)
            ELSE
                IF CurrRec MOD (NoOfRecs DIV 100) = 0 THEN
                    Window.UPDATE(1, (CurrRec / NoOfRecs * 10000) DIV 1);

            IF NOT IsShipmentTrackingCreated(ISH) THEN BEGIN
                IF COMPANYNAME = 'INNOX  UAT NEW' THEN BEGIN
                    OrderValidationEvent.CH_ShippingRuleValidate(ISH, ISH."Earliest Ship Date", ISH."Earliest Delivery date");
                    InsertLabeldetailsToShipmentTracking(ISH, ISH."No.");

                END ELSE BEGIN
                    IsLocalDelivery := IsLocalDeliveryAvailable(ISH."Ship-to Post Code", ISH."Ship-to Country/Region Code");
                    IsLocalDelivery := true;
                    IF ((IsLocalDelivery) AND (ISH."Trade Partner Code" = 'MAGENTO')) THEN BEGIN  //Change By PS Behalf Magento 
                        InsertLabeldetailsToShipmentTracking(ISH, ISH."No.");
                        message('PostCodeFound');
                    END
                    ELSE BEGIN
                        OrderValidationEvent.CH_ShippingRuleValidate(ISH, ISH."Earliest Ship Date", ISH."Earliest Delivery date");
                        Message('postCodeNotfound');
                        IF (ISH."Document Type" = ISH."Document Type"::Order) OR (ISH."Document Type" = ISH."Document Type"::"Return Order") THEN BEGIN
                            //    CourierIntegration.CH_UpdateCourierDetailsOrder(ISH); //Commented By Pavan
                            ISH.CALCFIELDS("Tracking No.");
                            IF (ISH."Tracking No." = '') AND (ISH.Remarks <> '') THEN BEGIN
                                OrderRead.CH_InsertErrorlog(ISH.Remarks, ISH);

                            END;
                        END;
                    END;
                END;
            END;//Chandan++ Commented for testing scanning and consolidation by creating manual tracking number
        END;
        // Chris *****Code for creating shipping rule and tracking **EN*****

    end;

    local procedure ModifyISH(ISL: Record "Interim Sales Line")
    var
        ISH: Record "Interim Sales Header";
    begin
        /*IF ISH.GET(ISL."Transaction No.", ISL."Document Type", ISL."Document No") THEN BEGIN
            ISH.VALIDATE(Status, ISH.Status::Processing);
            ISH.MODIFY;
        END;
    end;

    local procedure CheckOrderExists(L_InterimSalesLine: Record "Interim Sales Line"; L_InterimSalesHeader: Record "Interim Sales Header")
    var
        RecInterimSalesLine: Record "Interim Sales Line";
        Item: Record 27;
        SalesHeader: Record 36;
        WhseValidateSourceLine: Codeunit 5777;
        SalesLine: Record 37;
    begin
        IF L_InterimSalesLine.Type = L_InterimSalesLine.Type::Item THEN BEGIN
            //Start_NIKHIL_29/01/2019
            SalesLine.RESET;
            //SalesLine.CALCFIELDS(Status, "Whse. Outstanding Qty.", "Order Created On", "Campaign No.", "Ship-to Country/Region Code");
            SalesLine.SETRANGE("Document Type", SalesLine."Document Type"::Order);
            SalesLine.SETRANGE(Type, L_InterimSalesLine.Type);
            SalesLine.SETRANGE("Sell-to Customer No.", L_InterimSalesLine."Sell-to Customer No.");
            SalesLine.SETRANGE("Shortcut Dimension 1 Code", L_InterimSalesLine."Trade Partner Code");
            SalesLine.SETRANGE("No.", L_InterimSalesLine."No.");
            SalesLine.SETFILTER("Whse. Outstanding Qty.", '%1', 0);
            SalesLine.SETFILTER("Outstanding Quantity", '<>%1', 0);
            //SalesLine.SETFILTER(Status, '%1', SalesLine.Status::Open);
            //SalesLine.SETRANGE("Existing Order", FALSE);
            //SalesLine.SETRANGE("Ship-to Country/Region Code", L_InterimSalesHeader."Ship-to Country");
            /*IF L_InterimSalesHeader."Deal ID" <> '' THEN
                SalesLine.SETFILTER("Campaign No.", L_InterimSalesHeader."Deal ID");
            //SalesLine.SETRANGE("Order Created On",CREATEDATETIME(WORKDATE,000000T),CREATEDATETIME(WORKDATE,235900T));
            IF SalesLine.FINDFIRST THEN BEGIN
                /*IF WhseValidateSourceLine.WhseLinesExist(
                   DATABASE::"Sales Line", SalesLine."Document No.",
                   SalesLine."Line No.", 0, SalesLine.Quantity) THEN BEGIN
                    HeaderNo := NewCreateSalesHeader(L_InterimSalesLine);
                    LineNo := NewCreateSalesLine(HeaderNo, L_InterimSalesLine);
                    UpdateOrderNo(L_InterimSalesLine);
                END*/
 /*ELSE BEGIN
     UpdateSalesLine(SalesLine, L_InterimSalesLine);
     UpdateOrderNo(L_InterimSalesLine);
 END;
END
ELSE BEGIN
 HeaderNo := NewCreateSalesHeader(L_InterimSalesLine);
 LineNo := NewCreateSalesLine(HeaderNo, L_InterimSalesLine);
 UpdateOrderNo(L_InterimSalesLine);
END;
END
ELSE BEGIN
IF L_InterimSalesLine.Type = L_InterimSalesLine.Type::"G/L Account" THEN BEGIN
 IF HeaderNo <> '' THEN BEGIN
     SalesLine.RESET;
     SalesLine.SETRANGE("Document Type", SalesLine."Document Type"::Order);
     SalesLine.SETRANGE("Document No.", HeaderNo);
     SalesLine.SETRANGE(Type, SalesLine.Type::"G/L Account");
     SalesLine.SETRANGE("No.", L_InterimSalesLine."No.");
     IF SalesLine.FINDFIRST THEN BEGIN
         UpdateSalesLine(SalesLine, L_InterimSalesLine);
         UpdateOrderNo(L_InterimSalesLine);
     END
     ELSE BEGIN
         LineNo := NewCreateSalesLine(HeaderNo, L_InterimSalesLine);
         UpdateOrderNo(L_InterimSalesLine);
     END;
 END;
END;
END;
end;

local procedure DeleteRejected(ISH: Record "Interim Sales Header")
var
ISL: Record "Interim Sales Line";
HISH: Record "Handled Incoming Message";
HISL: Record "Handled Interim Sales Line";
begin
// Chris *****Code for moving to Handled **ST*****
HISH.INIT;
ISH.CALCFIELDS("Tracking No.", "Gift Wrap Required");
HISH.VALIDATE("Document Type", ISH."Document Type");
HISH.VALIDATE("Document No.", ISH."No.");
HISH.VALIDATE("Sell-to Customer No.", ISH."Sell-to Customer No.");
HISH.VALIDATE("Web Customer No.", ISH."Web Customer No.");
HISH.VALIDATE(Address, ISH.Address);
HISH.VALIDATE("Address 2", ISH."Address 2");
HISH.VALIDATE(City, ISH.City);
HISH.VALIDATE("Post Code", ISH."Post Code");
HISH.VALIDATE("Order Date", ISH."Order Date");
//HISH.VALIDATE(Status, ISH."Order Status");
HISH.VALIDATE(Remarks, ISH.Remarks);
HISH.VALIDATE("Bill-to Customer No.", ISH."Bill-to Customer No.");
HISH.VALIDATE("Ship-to Name", ISH."Ship-to Name");
HISH.VALIDATE("Ship-to Address", ISH."Ship-to Address");
HISH.VALIDATE("Ship-to Address 2", ISH."Ship-to Address 2");
HISH.VALIDATE("Ship-to City", ISH."Ship-to City");
HISH.VALIDATE("Ship-to Post Code", ISH."Ship-to Post Code");
HISH.VALIDATE("Ship-to County", ISH."Ship-to County");
HISH.VALIDATE("Ship-to Country", ISH."Ship-to Country");
HISH.VALIDATE("Document Date", ISH."Document Date");
HISH.VALIDATE("External Document No.", ISH."External Document No.");
HISH.VALIDATE("Buyer Email", ISH."Buyer Email");
HISH.VALIDATE("Buyer Name", ISH."Buyer Name");
HISH.VALIDATE("Earliest Delivery date", ISH."Earliest Delivery date");
HISH.VALIDATE("Earliest Ship Date", ISH."Earliest Ship Date");
HISH.VALIDATE("Fullfillment Channel", ISH."Fullfillment Channel");
HISH.VALIDATE("Order Type", ISH."Order Type");
HISH.VALIDATE("Order Amount", ISH."Order Amount");
HISH.VALIDATE("Channel Order ID", ISH."Channel Order ID");
HISH.VALIDATE("Shipment Method Code", ISH."Shipment Method Code");
HISH.VALIDATE("Currency Code", ISH."Currency Code");
HISH.VALIDATE("Gift Message", ISH."Gift Message");
HISH.VALIDATE("Order Placed At", ISH."Order Placed At");
HISH.VALIDATE("Web Shipment Method", ISH."Web Shipment Method");
HISH.VALIDATE("Bill- to Name", ISH."Bill- to Name");
HISH.VALIDATE("Web Shipping Agent", ISH."Web Shipping Agent");
HISH.VALIDATE("Bill-to CompanyName", ISH."Bill-to CompanyName");
HISH.VALIDATE("Ship-to CompanyName", ISH."Ship-to CompanyName");
HISH.VALIDATE("Deal ID", ISH."Deal ID");
HISH.VALIDATE("Bill-to County", ISH."Bill-to County");
HISH.VALIDATE(IsLLOrder, ISH.IsLLOrder);
HISH.VALIDATE("Trade Partner Code", ISH."Trade Partner Code");
HISH.VALIDATE("Shipping Agent Code", ISH."Shipping Agent Code");
HISH.VALIDATE("Shipping Agent Service Code", ISH."Shipping Agent Service Code");
HISH.VALIDATE("Shipment Date", ISH."Shipment Date");
HISH.VALIDATE("Ship-to Country/Region Code", ISH."Ship-to Country/Region Code");
HISH.VALIDATE("Promised Delivery Date", ISH."Promised Delivery Date");
HISH.VALIDATE("Amount Including VAT", ISH."Amount Including VAT");
HISH.VALIDATE("Shipping Time", ISH."Shipping Time");
HISH.VALIDATE("Requested Delivery Date", ISH."Requested Delivery Date");
HISH.VALIDATE("Currency Factor", ISH."Currency Factor");
HISH.VALIDATE(Comments, ISH.Comments);
HISH.VALIDATE("Package Tracking No.", ISH."Package Tracking No.");
HISH.VALIDATE("Location Code", ISH."Location Code");
HISH.VALIDATE("Pickup Name", ISH."Pickup Name");
HISH.VALIDATE("Pickup Address", ISH."Pickup Address");
HISH.VALIDATE("Pickup Address 2", ISH."Pickup Address 2");
HISH.VALIDATE("Pickup City", ISH."Pickup City");
HISH.VALIDATE("Pickup Post Code", ISH."Pickup Post Code");
HISH.VALIDATE("Pickup County", ISH."Pickup County");
HISH.VALIDATE("Pickup Country/Region Code", ISH."Pickup Country/Region Code");
HISH.VALIDATE("Total Weight", ISH."Total Weight");
HISH.VALIDATE("Pickup Date", ISH."Pickup Date");
HISH.VALIDATE("Email (Location)", ISH."Email (Location)");
HISH.VALIDATE("No. Of Parcels", ISH."No. Of Parcels");
HISH.VALIDATE("Tracking No.", ISH."Tracking No.");
HISH.VALIDATE("Job Reference", ISH."Job Reference");
HISH.VALIDATE("Order Tracking ID", ISH."Order Tracking ID");
HISH.VALIDATE("Gift Wrap Required", ISH."Gift Wrap Required");
HISH.VALIDATE("Gift Wrap By", ISH."Gift Wrap By");
HISH.VALIDATE("Gift Wrap date", ISH."Gift Wrap date");

HISH.VALIDATE("Order Created On", ISH."Order Created On");
HISH.VALIDATE("Ship-to Phone", ISH."Ship-to Phone");
HISH.VALIDATE("Ship-to Email", ISH."Ship-to Email");
HISH.INSERT(TRUE);
end;

local procedure UpdateSalesLine(L_SalesLine: Record 37; L_InterimSalesLine: Record "Interim Sales Line")
var
RecSalesLine: Record 37;
OldQty: Decimal;
begin
//Start_NIKHIL_29/01/2019
IF RecSalesLine.GET(L_SalesLine."Document Type", L_SalesLine."Document No.", L_SalesLine."Line No.") THEN BEGIN
CLEAR(OldQty);
OldQty := RecSalesLine.Quantity;
RecSalesLine.VALIDATE(Quantity, OldQty + L_InterimSalesLine.Quantity);
RecSalesLine.MODIFY;
HeaderNo := RecSalesLine."Document No.";
LineNo := RecSalesLine."Line No.";
END;
//END_NIKHIL_29/01/2019
end;

local procedure UpdateOrderNo(L_InterimSalesLine: Record "Interim Sales Line")
var
RecInterimSalesLine: Record "Interim Sales Line";
RecInterimSalesHeader: Record "Interim Sales Header";
begin
//Start_NIKHIL_29/01/2019
IF RecInterimSalesLine.GET(L_InterimSalesLine."Document Type", L_InterimSalesLine."Document No", L_InterimSalesLine."Line No.") THEN BEGIN
RecInterimSalesLine.MODIFY;
IF RecInterimSalesHeader.GET(L_InterimSalesLine."Document Type", L_InterimSalesLine."Document No") THEN BEGIN
 //RecInterimSalesHeader.VALIDATE("order status", RecInterimSalesHeader."Order Status"::Processing);
 //RecInterimSalesHeader.VALIDATE("Sales Order No.", HeaderNo);
 RecInterimSalesHeader.MODIFY;
END;
InsertIntoTempHeader(HeaderNo);
//  AmazonIntegration.UpdateSalesOrderNoInShippmentTrackingLine(RecInterimSalesLine);//NIKHIL_28/01/19 //Commented By Pavan
END;
//END_NIKHIL_29/01/2019
end;

local procedure NewCreateSalesHeader(L_InterimSalesLine: Record "Interim Sales Line") SNo: Code[20]
var
L_SalesH: Record 36;
"S&R": Record 311;
Countryregion: Record 9;
Campaigns: Record 5071;
NoSeriesManagement: Codeunit 396;
Customer: Record 18;
PartnerErrorLog: Record "Incoming/Outgoing Error Log";
InterimSalesHeader: Record "Interim Sales Header";
begin
"S&R".GET;
CLEAR(L_SalesH);
IF InterimSalesHeader.GET(L_InterimSalesLine."Document Type", L_InterimSalesLine."Document No") THEN;
L_SalesH.INIT;
L_SalesH.VALIDATE("Document Type", L_SalesH."Document Type"::Order);
L_SalesH."No." := NoSeriesManagement.GetNextNo("S&R"."Order Nos.", WORKDATE, TRUE);
L_SalesH.VALIDATE("No.");
L_SalesH.VALIDATE("Posting Date", WORKDATE);
L_SalesH.VALIDATE("Order Date", InterimSalesHeader."Document Date");
//L_SalesH.VALIDATE("Web Order No.",InterimSalesHeader."No."); //Commented by shailesh 030719
L_SalesH.VALIDATE("Document Date", InterimSalesHeader."Document Date"); //Commented by shailesh 030719
                                                                 //L_SalesH.VALIDATE("Order placed At",InterimSalesHeader."Order Placed At");
L_SalesH.VALIDATE("Sell-to Customer No.", InterimSalesHeader."Sell-to Customer No.");
//L_SalesH.VALIDATE("External Document No.",InterimSalesHeader."Channel Order ID");//Block_Nikhil_30/01/19
IF InterimSalesHeader."Earliest Delivery date" <> 0D THEN BEGIN
IF InterimSalesHeader."Earliest Delivery date" < WORKDATE THEN
 L_SalesH.VALIDATE("Shipment Date", WORKDATE)
ELSE
 L_SalesH.VALIDATE("Promised Delivery Date", InterimSalesHeader."Earliest Delivery date");
END;
IF InterimSalesHeader."Earliest Ship Date" <> 0D THEN BEGIN
IF InterimSalesHeader."Earliest Ship Date" < WORKDATE THEN BEGIN
 L_SalesH.VALIDATE("Shipment Date", WORKDATE);
 //L_SalesH.VALIDATE("Pickup Date",WORKDATE); //Commented by shailesh 030719
END
ELSE BEGIN
 L_SalesH.VALIDATE("Shipment Date", InterimSalesHeader."Earliest Ship Date");
 //L_SalesH.VALIDATE("Pickup Date",InterimSalesHeader."Earliest Ship Date"); //Commented by shailesh 030719
END;
END;

//L_SalesH.VALIDATE("Pickup Time",170000T); //Commented by shailesh 030719
/*L_SalesH."Ship-to Name"  := InterimSalesHeader."Ship-to Name";
L_SalesH."Ship-to Address" := InterimSalesHeader."Ship-to Address";
L_SalesH."Ship-to Address 2" := InterimSalesHeader."Ship-to Address 2";
L_SalesH."Ship-to City"  := InterimSalesHeader."Ship-to City";
L_SalesH."Ship-to Post Code" := InterimSalesHeader."Ship-to Post Code";
L_SalesH."Ship-to County" := InterimSalesHeader."Ship-to County";
L_SalesH."Ship-to Country/Region Code" := InterimSalesHeader."Ship-to Country";*///Block_Nikhil_30/01/19

    /*Countryregion.RESET;
    IF Countryregion.GET(InterimSalesHeader."Ship-to Country") THEN
      L_SalesH."VAT Bus. Posting Group":=Countryregion."VAT. Bus. Posting Group";*/


    /*L_SalesH."Bill-to Name 2":=InterimSalesHeader."Bill- to Name";
    L_SalesH."Bill-to Address" := InterimSalesHeader.Address;
    L_SalesH."Bill-to Address 2" := InterimSalesHeader."Address 2";
    L_SalesH."Bill-to City"  := InterimSalesHeader.City;
    L_SalesH."Bill-to Post Code" := InterimSalesHeader."Post Code";
    L_SalesH."Bill-to County" := InterimSalesHeader."Bill-to County";
    L_SalesH."Bill-to Country/Region Code" := InterimSalesHeader.Country;

    IF Customer.GET(InterimSalesHeader."Sell-to Customer No.") THEN;
    /*L_SalesH."Sell-to Customer Name" := Customer.Name;
    L_SalesH."Sell-to Address" := InterimSalesHeader.Address;
    L_SalesH."Sell-to Address 2" := InterimSalesHeader."Address 2";
    L_SalesH."Sell-to City"  := InterimSalesHeader.City;
    L_SalesH."Sell-to Post Code" := InterimSalesHeader."Post Code";
    L_SalesH."Sell-to Country/Region Code" := InterimSalesHeader.Country;//Block_Nikhil_30/01/19
                                                                           //L_SalesH."Fullfillment Channel":=InterimSalesHeader."Fullfillment Channel";  //Commented by shailesh 030719
                                                                           //L_SalesH."Prime Order":=InterimSalesHeader."Prime Order"; //Commented by shailesh 030719
                                                                           //L_SalesH."Gift Message" :=InterimSalesHeader."Gift Message"; //Commented by shailesh 030719
                                                                           //L_SalesH."Web Shipment Method":=InterimSalesHeader."Web Shipment Method"; //Commented by shailesh 030719
                                                                           //L_SalesH."Web Shipping Agent":=InterimSalesHeader."Web Shipping Agent"; //Commented by shailesh 030719
                                                                           //L_SalesH."Ship-to Email" := InterimSalesHeader."Buyer Email"; //Commented by shailesh 030719
                                                                           //L_SalesH.VALIDATE("Ship-to Phone",InterimSalesHeader."Phone Number");//Block_Nikhil_30/01/19
    L_SalesH.VALIDATE("Payment Method Code", GetPaymentMethodCode(InterimSalesHeader."Trade Partner Code", InterimSalesHeader."Channel Order ID", L_SalesH."No."));

    IF InterimSalesHeader."Deal ID" <> '' THEN BEGIN
        Campaigns.RESET;
        Campaigns.SETRANGE("No.", InterimSalesHeader."Deal ID");
        IF Campaigns.FINDFIRST THEN
            L_SalesH.VALIDATE("Campaign No.", InterimSalesHeader."Deal ID")
        ELSE
            InsertErrorlog('Deal Id not found.', InterimSalesHeader);
    END;
    //L_SalesH."Shipment Day"  := FORMAT(L_SalesH."Shipment Date",0,'<Weekday Text>'); //Commented by shailesh 030719
    //L_SalesH."Channel Code":= InterimSalesHeader."Trade Partner Code"; //Commented by shailesh 030719
    L_SalesH."Shortcut Dimension 1 Code" := InterimSalesHeader."Trade Partner Code";
    L_SalesH.INSERT(TRUE);

    EXIT(L_SalesH."No.");

end;

local procedure NewCreateSalesLine(HeaderNo: Code[20]; L_IntrimSalesLine: Record "Interim Sales Line"): Integer
var
    L_SalesL: Record 37;
    totalWeight: Decimal;
    line: Integer;
    ISL: Record "Interim Sales Line";
    Qty: Decimal;
    Amt: Decimal;
    item: Record 27;
    desc: Text;
    desc2: Text;
    ItemLineNo: Integer;
    L_SalesH: Record 36;
    L_ChargeSetup: Record "Charge Setup";
    InterimSalesHeader: Record "Interim Sales Header";
begin
    CLEAR(line);
    CLEAR(totalWeight);
    CLEAR(Qty);
    CLEAR(Amt);
    CLEAR(ItemLineNo);
    /*L_SalesL.RESET;
    L_SalesL.SETRANGE("Document Type",L_SalesL."Document Type"::Order);
    L_SalesL.SETRANGE("Document No.",HeaderNo);
    L_SalesL.SETRANGE("No.",IntrimSalesLine."No.");
    IF L_SalesL.FINDFIRST THEN
      EXIT;*/

    /*L_SalesL.RESET;
    L_SalesL.SETRANGE("Document Type",L_SalesL."Document Type"::Order);
    L_SalesL.SETRANGE("Document No.",HeaderNo);
    IF L_SalesL.FINDLAST THEN
      line:=L_SalesL."Line No."+ 10000
    ELSE*/

    //MESSAGE('%1..%2',ChannelCode,HeaderNo);

    /*ISL.RESET;
    ISL.SETRANGE("Trade Partner Code",ChannelCode);
    ISL.SETFILTER("No of Error",'%1',0);
    ISL.SETRANGE("No.",ItemNo);
    ISL.SETFILTER("Sales Order No.",'%1','');
    ISL.SETRANGE("SO Created",FALSE);*/


    //line := 10000;
    /*IntrimSalesLine.CALCSUMS(Quantity);
    IntrimSalesLine.CALCSUMS(Amount);//Block_Nikhil_280119
    Qty := L_IntrimSalesLine.Quantity;
    Amt := L_IntrimSalesLine.Amount;

    CLEAR(L_SalesL);
    L_SalesL.INIT;
    L_SalesL.VALIDATE("Document Type", L_SalesL."Document Type"::Order);
    L_SalesL.VALIDATE("Document No.", HeaderNo);
    L_SalesL.VALIDATE("Line No.", GetLastLineNo(HeaderNo));
    L_SalesL.VALIDATE(Type, L_IntrimSalesLine.Type);
    //MESSAGE('%1..%2',IntrimSalesLine."No.",HeaderNo);
    L_SalesL.VALIDATE("No.", L_IntrimSalesLine."No.");


    item.RESET;  //Ranjit 04-04-2018
    IF (L_IntrimSalesLine.Type = L_IntrimSalesLine.Type::Item) AND (item.GET(L_IntrimSalesLine."No.")) THEN BEGIN
        totalWeight := item."Net Weight" * Qty;
    END;  //Ranjit 04-04-2018


    //IF L_SalesL.Description='' THEN //MADAN 02/04/2017
    //  L_SalesL.Description := IntrimSalesLine.Description;
    //L_SalesL."Description 2" := IntrimSalesLine.Description2;
    IF (STRLEN(L_IntrimSalesLine.Description) > 50) THEN BEGIN
        desc := COPYSTR(L_IntrimSalesLine.Description, 1, 50);
        desc2 := COPYSTR(L_IntrimSalesLine.Description, 51, STRLEN(L_IntrimSalesLine.Description));
        L_SalesL.Description := desc;
        L_SalesL."Description 2" := desc2;
    END ELSE BEGIN
        L_SalesL.Description := L_IntrimSalesLine.Description;
        L_SalesL."Description 2" := L_IntrimSalesLine.Description2;
    END;


    IF L_SalesL.Type <> L_SalesL.Type::" " THEN BEGIN
        ItemLineNo := L_SalesL."Line No.";
        L_SalesL.VALIDATE(Quantity, Qty);
        L_SalesL.VALIDATE("Unit Price", L_IntrimSalesLine."Unit Price");

        L_SalesL.VALIDATE("Shortcut Dimension 1 Code", L_IntrimSalesLine."Trade Partner Code");

        L_SalesL.VALIDATE(Amount, Amt);
    END
    ELSE BEGIN

    END;




    IF (L_IntrimSalesLine.Discount > 0) THEN BEGIN
        L_SalesL.VALIDATE("Line Discount Amount", L_IntrimSalesLine.Discount);
    END;

    L_SalesL.INSERT(TRUE);
    IF L_SalesL.Type = L_SalesL.Type::Item THEN  //Chandan


        IF L_SalesL.Type <> L_SalesL.Type::" " THEN BEGIN
            L_ChargeSetup.RESET;
            //L_ChargeSetup.SETRANGE(L_ChargeSetup."Column/Row Indentifier", L_IntrimSalesLine."Rebate Type");
            IF L_ChargeSetup.FINDFIRST THEN;
            CASE L_ChargeSetup."Apply Discount by" OF
                L_ChargeSetup."Apply Discount by"::"Fixed Value":
                    L_SalesL.VALIDATE("Line Discount Amount", L_ChargeSetup."Discount value");
                L_ChargeSetup."Apply Discount by"::Percentage:
                    L_SalesL.VALIDATE("Line Discount %", L_ChargeSetup."Discount value");
            END;

        END;
    IF L_SalesH.GET(L_SalesL."Document Type", L_SalesL."Document No.") THEN
        L_SalesL.VALIDATE("Location Code", L_SalesH."Location Code");
    L_SalesL.MODIFY(TRUE);

    L_SalesH.RESET;
    L_SalesH.SETRANGE("Document Type", L_SalesH."Document Type"::Order);
    L_SalesH.SETRANGE("No.", HeaderNo);
    IF L_SalesH.FINDFIRST THEN BEGIN
        //L_SalesH.VALIDATE("Total Weight", totalWeight);
        L_SalesH.MODIFY;
    END;

    EXIT(L_SalesL."Line No.");

    /*ISL.RESET;
        ISL.SETRANGE("Trade Partner Code",ChannelCode);
        ISL.SETFILTER("No of Error",'%1',0);
        ISL.SETRANGE("No.",ItemNo);
        ISL.SETFILTER("Sales Order No.",'%1','');
        ISL.SETRANGE("SO Created",FALSE);
        IF ISL.FINDSET THEN BEGIN
        REPEAT
        ISL.VALIDATE("SO Created",TRUE);
        ISL.VALIDATE("Sales Order No.",HeaderNo);
        ISL.MODIFY;
        ModifyISH(ISL);
        AmazonIntegration.UpdateSalesOrderNoInShippmentTrackingLine(ISL);//NIKHIL_28/01/19
        UNTIL ISL.NEXT=0;
        END;*///Block_Nikhil_28/01/19

    /*IF ISL.GET(IntrimSalesLine."Transaction No.",IntrimSalesLine."Document Type",IntrimSalesLine."Document No",IntrimSalesLine."Line No.") THEN
      BEGIN
        ISL.VALIDATE("Sales Order No.",HeaderNo);
        ISL.VALIDATE("SO Created",TRUE);
        ISL.MODIFY;
        AmazonIntegration.UpdateSalesOrderNoInShippmentTrackingLine(ISL);//NIKHIL_28/01/19
      END;
end;

local procedure CreateConsolidatedOrder()
var
    //CourierIntegration: Codeunit "Courier Integration";// Commented By Pavan 
    ISH: Record "Interim Sales Header";
    NoOfRecs: Integer;
    CurrRec: Integer;
    Window: Dialog;
    ChanCode: Code[20];
    ItemNo: Code[20];
    CustomerNo: Code[20];
    ISL: Record "Interim Sales Line";
    InterimSalesHeader: Record "Interim Sales Header";
    HISH: Record "Handled Interim Sales Header";
    HISL: Record "Handled Interim Sales Line";
    InterimSalesHeader1: Record "Interim Sales Header";
    Customer: Record 18;
    ShipmentTracking: Record "Shipment Tracking";
    FirstOrder: Boolean;
begin

    ISH.RESET;
    ISH.CALCFIELDS("Tracking No.");
    ISH.SETRANGE("Document Type", ISH."Document Type"::Order);

    ///Code Added by Chandan++++++120219++++++++++
    IF ChannelCode<>'' THEN
      ISH.SETRANGE("Channel Code",ChannelCode);

    IF CustomerNo<>'' THEN
      ISH.SETRANGE("Sell-to Customer No.",CustomerNo);

    IF ShippingCountry<>'' THEN
      ISH.SETRANGE("Ship-to Country/Region Code",ShippingCountry);

    IF DealID<>'' THEN
      ISH.SETRANGE("Deal ID",DealID);
    //Code Added by Chandan------120219-------------

    //ISH.SETFILTER("No.",'WEB30018..WEB30029');
    //ISH.SETRANGE("No. of Items",1);
    //ISH.SETRANGE("Line Action", ISH."Line Action"::Accept);
    //ISH.SETFILTER("Sales Order No.", '%1', '');
    ISH.SETFILTER("Tracking No.", '<>%1', '');
    IF ISH.FINDSET THEN BEGIN
        Window.OPEN('Creating Sales Order... @1@@@@@@@@@@');
        NoOfRecs := ISH.COUNT;
        REPEAT
            IF FirstOrder = FALSE THEN BEGIN
                IF ISH."No. of Items" = 1 THEN BEGIN
                    CLEAR(HeaderNo);
                    ISL.RESET;
                    ISL.SETRANGE("Document Type", ISH."Document Type"::Order);
                    ISL.SETRANGE("Document No", ISH."No.");
                    //ISL.SETRANGE(Type,ISL.Type::Item);
                    IF ISL.FINDSET THEN
                        REPEAT
                            CLEAR(LineNo);
                            CheckOrderExists(ISL, ISH);
                        UNTIL ISL.NEXT = 0;
                END
                ELSE BEGIN
                    IF ISH."No. of Items" > 1 THEN BEGIN
                        CLEAR(HeaderNo);
                        ISL.RESET;
                        ISL.SETRANGE("Document Type", ISH."Document Type"::Order);
                        ISL.SETRANGE("Document No", ISH."No.");
                        IF ISL.FINDSET THEN BEGIN
                            HeaderNo := NewCreateSalesHeader(ISL);
                            REPEAT
                                CLEAR(LineNo);
                                LineNo := NewCreateSalesLine(HeaderNo, ISL);
                                UpdateOrderNo(ISL);
                            UNTIL ISL.NEXT = 0;
                        END;
                    END;
                END;
            END
            ELSE BEGIN
                CLEAR(HeaderNo);
                ISL.RESET;
                ISL.SETRANGE("Document Type", ISH."Document Type"::Order);
                ISL.SETRANGE("Document No", ISH."No.");
                IF ISL.FINDSET THEN BEGIN
                    HeaderNo := NewCreateSalesHeader(ISL);
                    REPEAT
                        CLEAR(LineNo);
                        LineNo := NewCreateSalesLine(HeaderNo, ISL);
                        UpdateOrderNo(ISL);
                    UNTIL ISL.NEXT = 0;
                    FirstOrder := FALSE;
                END;
            END;
            CurrRec += 1;
            IF NoOfRecs <= 100 THEN
                Window.UPDATE(1, (CurrRec / NoOfRecs * 10000) DIV 1)
            ELSE
                IF CurrRec MOD (NoOfRecs DIV 100) = 0 THEN
                    Window.UPDATE(1, (CurrRec / NoOfRecs * 10000) DIV 1);
        UNTIL ISH.NEXT = 0;
        Window.CLOSE;
    END;

end;

local procedure GetLastLineNo(HeaderNo: Code[20]): Integer
var
    L_SalesLine: Record 37;
begin
    L_SalesLine.RESET;
    L_SalesLine.SETRANGE("Document Type", L_SalesLine."Document Type"::Order);
    L_SalesLine.SETRANGE("Document No.", HeaderNo);
    IF L_SalesLine.FINDLAST THEN
        EXIT(L_SalesLine."Line No." + 10000)
    ELSE
        EXIT(10000);
end;

local procedure InsertIntoTempHeader(DocNo: Code[20])
begin
    TempSalesHeader.RESET;
    TempSalesHeader.SETRANGE("Document Type", TempSalesHeader."Document Type"::Order);
    TempSalesHeader.SETRANGE("No.", DocNo);
    IF NOT TempSalesHeader.FINDFIRST THEN BEGIN
        TempSalesHeader.INIT;
        TempSalesHeader."Document Type" := TempSalesHeader."Document Type"::Order;
        TempSalesHeader."No." := DocNo;
        TempSalesHeader.INSERT;
    END;
end;

local procedure StockAllocation()
var
    L_SalesHeader: Record 36;
    NoOfRecs: Integer;
    CurrRec: Integer;
    Window: Dialog;
begin
    TempSalesHeader.RESET;
    IF TempSalesHeader.FINDSET THEN BEGIN
        Window.OPEN('Stock Allocation... @1@@@@@@@@@@');
        NoOfRecs := TempSalesHeader.COUNT;
        REPEAT
            IF L_SalesHeader.GET(TempSalesHeader."Document Type", TempSalesHeader."No.") THEN
                //SalesLine.OnAutoReseveCall(L_SalesHeader);
            CurrRec += 1;
            IF NoOfRecs <= 100 THEN
                Window.UPDATE(1, (CurrRec / NoOfRecs * 10000) DIV 1)
            ELSE
                IF CurrRec MOD (NoOfRecs DIV 100) = 0 THEN
                    Window.UPDATE(1, (CurrRec / NoOfRecs * 10000) DIV 1);

        UNTIL TempSalesHeader.NEXT = 0;
        Window.CLOSE;
    END;
end;

local procedure ReleaseSO()
var
    L_SalesHeader: Record 36;
    NoOfRecs: Integer;
    CurrRec: Integer;
    Window: Dialog;
    ReleaseSalesDocument: Codeunit 414;
begin
    TempSalesHeader.RESET;
    IF TempSalesHeader.FINDSET THEN BEGIN
        Window.OPEN('Release sales order... @1@@@@@@@@@@');
        NoOfRecs := TempSalesHeader.COUNT;
        REPEAT
            IF L_SalesHeader.GET(TempSalesHeader."Document Type", TempSalesHeader."No.") THEN
                ReleaseSalesDocument.PerformManualRelease(L_SalesHeader);
            CurrRec += 1;
            IF NoOfRecs <= 100 THEN
                Window.UPDATE(1, (CurrRec / NoOfRecs * 10000) DIV 1)
            ELSE
                IF CurrRec MOD (NoOfRecs DIV 100) = 0 THEN
                    Window.UPDATE(1, (CurrRec / NoOfRecs * 10000) DIV 1);

        UNTIL TempSalesHeader.NEXT = 0;
        Window.CLOSE;
    END;
end;

procedure GetNoOfItems(var Rec_InterimSH: Record "Interim Sales Header")
var
    Rec_InterimSL: Record "Interim Sales Line";
    TempItem: Record 27;
    L_SalesLine: Record "Interim Sales Line";
begin
    Rec_InterimSL.RESET;
    Rec_InterimSL.SETRANGE("Document Type", Rec_InterimSH."Document Type");
    Rec_InterimSL.SETRANGE("Document No", Rec_InterimSH."No.");
    Rec_InterimSL.SETRANGE(Type, Rec_InterimSL.Type::Item);
    IF Rec_InterimSL.FINDSET THEN
        REPEAT
            IF NOT TempItem.GET(Rec_InterimSL."No.") THEN BEGIN
                TempItem."No." := Rec_InterimSL."No.";
                TempItem.INSERT;
            END;
        UNTIL Rec_InterimSL.NEXT = 0;
    Rec_InterimSH."No. of Items" := TempItem.COUNT;
    Rec_InterimSH.MODIFY;
end;

local procedure IsShipmentTrackingCreated(var REC_ISH: Record "Interim Sales Header"): Boolean
var
    ShipmentTracking: Record "Shipment Tracking";
begin
    ShipmentTracking.RESET;
    ShipmentTracking.SETRANGE("Document Type", ShipmentTracking."Document Type"::Order);
    ShipmentTracking.SETRANGE("Document No.", REC_ISH."No.");
    IF ShipmentTracking.FINDSET THEN
        EXIT(TRUE);
end;

local procedure GetPaymentMethodCode(ChannelCode: Code[20]; ChannelOrderId: Code[50]; SalesOrderID: Code[20]): Code[20]
var
    PaymentMethodRules: Record "Payment Method Rules";
    ChannelMedia: Record "Channel Media";
begin
    ChannelMedia.RESET;
    ChannelMedia.SETRANGE("Channel Code", ChannelCode);
    ChannelMedia.SETRANGE("Channel Order ID", ChannelOrderId);
    IF ChannelMedia.FINDSET THEN BEGIN
        PaymentMethodRules.RESET;
        PaymentMethodRules.SETRANGE("Channel Code", ChannelMedia."Channel Code");
        PaymentMethodRules.SETRANGE("Web Payment Code", ChannelMedia."Payment Method");
        IF PaymentMethodRules.FINDSET THEN BEGIN
            ChannelMedia.VALIDATE(Status, ChannelMedia.Status::Created);
            ChannelMedia.VALIDATE("Web Order No.", SalesOrderID);
            ChannelMedia.MODIFY;
            EXIT(PaymentMethodRules."Nav Payment Code");
        END;
    END;
end;

procedure InsertErrorlog(P_Text: Text[250]; var InterimSalesHeader: Record "Interim Sales Header")
var
    L_PartnerErrorLog: Record "Incoming/Outgoing Error Log";
    L_LineNo: Integer;
    PartnerErrorLog: Record "Incoming/Outgoing Error Log";
begin
    L_PartnerErrorLog.RESET;
    IF L_PartnerErrorLog.FINDLAST THEN
        L_LineNo := L_PartnerErrorLog."Line No." + 10000
    ELSE
        L_LineNo := 10000;

    PartnerErrorLog.INIT;
    PartnerErrorLog."Document No." := InterimSalesHeader."No.";
    PartnerErrorLog.Date := WORKDATE;
    PartnerErrorLog."Line No." := L_LineNo;

    PartnerErrorLog."Error Text" := P_Text;
    PartnerErrorLog.INSERT;
    InterimSalesHeader.MODIFY;
end;

procedure IsLocalDeliveryAvailable(Ship_To_Post_Code: Code[50]; Ship_to_Country: Code[50]) IsLocalDelivery: Boolean
var
    Postalcode: Code[3];
    IsPresent: Integer;
begin
    PostCode.RESET;
    // Postalcode := COPYSTR(Ship_To_Post_Code, 1, 3);
    // IsPresent := STRPOS(Postcode.Code,Postalcode);
    /*
    PostCode.SETRANGE(Code, Ship_To_Post_Code);
    PostCode.SETRANGE("Country/Region Code", Ship_to_Country);
    IF PostCode.FINDFIRST THEN BEGIN
        EXIT(PostCode."Local Delivery");
    EN*
end;

procedure InsertLabeldetailsToShipmentTracking(var L_InterimSH: Record "Interim Sales Header"; Parcelnumber: Text)
var
    ShipmentTrack: Record "Shipment Tracking";
    RecShipmentTracking: Record "Shipment Tracking";
    EntryNo: Integer;
    BigTxt: BigText;

    ToFile: Variant;

    Ostream: OutStream;
begin


    IF L_InterimSH."Shipment Method Code" = '' THEN
        L_InterimSH."Shipment Method Code" := 'Local';

    IF L_InterimSH."Shipping Agent Code" = '' THEN
        L_InterimSH."Shipping Agent Code" := 'Local';

    IF L_InterimSH."Shipping Agent Service Code" = '' THEN
        L_InterimSH."Shipping Agent Service Code" := 'Local';

    L_InterimSH.MODIFY;


    ShipmentTrack.RESET;
    ShipmentTrack.VALIDATE("Document Type", L_InterimSH."Document Type");
    //  ShipmentTrack.VALIDATE("Document No.",L_InterimSH."No.");
    ShipmentTrack.VALIDATE(ShipmentTrack."Document No.", L_InterimSH."No.");
    ShipmentTrack.VALIDATE("Shipping Agent Code", L_InterimSH."Shipping Agent Code");
    // ShipmentTrack.VALIDATE("Shipping Agent Service Code", L_InterimSH."Shipping Agent Service Code");Commented By PS 
    ShipmentTrack.VALIDATE(Weight, L_InterimSH."Total Weight");
    ShipmentTrack.VALIDATE("Agent Shipment No.", L_InterimSH."External Document No.");

    IF Parcelnumber <> '' THEN
        ShipmentTrack.VALIDATE("Tracking No.", L_InterimSH."No.")
    ELSE
        ShipmentTrack.VALIDATE("Tracking No.", Parcelnumber);

    IF RecShipmentTracking.FINDLAST THEN BEGIN
        EntryNo := RecShipmentTracking."Entry No." + 1;
        ShipmentTrack.VALIDATE("Entry No.", EntryNo);
    END;
    ShipmentTrack.INSERT;
    L_InterimSH."Package Tracking No." := Parcelnumber;
    L_InterimSH.MODIFY;
    //Added By Nikhil W

end;

procedure UpdateNoofItems()
var
    InterimSalesHeader: Record "Interim Sales Header";
    InterimSalesLine: Record "Interim Sales Line";
    tempNoOfRec: Integer;
begin
    InterimSalesHeader.RESET;
    InterimSalesHeader.COPYFILTERS(InterimSH);
    InterimSalesHeader.CALCFIELDS("Tracking No.");
    InterimSalesHeader.SETRANGE("Document Type", InterimSalesHeader."Document Type"::Order);
    InterimSalesHeader.SETRANGE("Tracking No.", '');
    //InterimSalesHeader.SETRANGE("Order Status", InterimSalesHeader."Order Status"::"In Progress");
    InterimSalesHeader.SETRANGE("No. of Items", 0);
    tempNoOfRec := InterimSalesHeader.COUNT;
    IF InterimSalesHeader.FINDSET THEN
        REPEAT
            IF GUIALLOWED THEN BEGIN
                CurrRec += 1;
                IF NoOfRecs <= 100 THEN
                    Window.UPDATE(1, (CurrRec / tempNoOfRec * 10000) DIV 1)
                ELSE
                    IF CurrRec MOD (NoOfRecs DIV 100) = 0 THEN
                        Window.UPDATE(1, (CurrRec / tempNoOfRec * 10000) DIV 1);
            END;
            GetNoOfItems(InterimSalesHeader);
        UNTIL InterimSalesHeader.NEXT = 0;
end;

procedure CalculateWeight(var Rec_InterimSH: Record "Interim Sales Header")
var
    Rec_InterimSL: Record "Interim Sales Line";
    RecItem: Record 27;
    totalWeight: Decimal;
begin
    Rec_InterimSL.RESET;
    Rec_InterimSL.SETRANGE("Document Type", Rec_InterimSH."Document Type");
    Rec_InterimSL.SETRANGE("Document No", Rec_InterimSH."No.");
    Rec_InterimSL.SETRANGE(Type, Rec_InterimSL.Type::Item);
    IF Rec_InterimSL.FINDSET THEN
        REPEAT
            IF RecItem.GET(Rec_InterimSL."No.") THEN
                totalWeight := totalWeight + (RecItem."Net Weight" * Rec_InterimSL.Quantity);
        UNTIL Rec_InterimSL.NEXT = 0;
    Rec_InterimSH."Total Weight" := totalWeight;
    Rec_InterimSH."No. Of Parcels" := 1;
    Rec_InterimSH.MODIFY;
end;*/
}

