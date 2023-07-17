page 90029 "Web Order Header API Card"
{
    PageType = API;
    SourceTable = "Interim Sales Header";
    APIPublisher = 'Robosol';
    APIGroup = 'orders';
    APIVersion = 'v1.0';
    EntitySetName = 'headers';
    EntityName = 'header';
    DelayedInsert = true;
    ODataKeyFields = SystemId;

    layout
    {
        area(Content)
        {
            field(id; Rec.SystemId)
            {
                ApplicationArea = All;
            }
            field(HeaderNo; Rec."No.")
            {
                ApplicationArea = All;
            }
            field(DocumentType; Rec."Document Type")
            {
                ApplicationArea = All;
            }
            field(ChannelCode; Rec."Trade Partner Code")
            {
                ApplicationArea = All;
            }
            field(ChannelOrderId; Rec."Channel Order ID")
            {
                ApplicationArea = All;
            }
            field(ExternalDocumentNo; Rec."External Document No.")
            {
                ApplicationArea = All;
            }
            field(SelltoCustomerNo; Rec."Sell-to Customer No.")
            {
                ApplicationArea = All;
            }
            field(LocationCode; Rec."Location Code")
            {
                ApplicationArea = All;
            }
            field(OrderDate; Rec."Order Date")
            {
                // trigger OnValidate()
                // begin
                //     "Document Date":=rec."Order Date";
                // end;
                ApplicationArea = All;
            }
            field(DocumentDate; Rec."Document Date")
            {
                ApplicationArea = All;
            }
            field(OrderPlacedAt; Rec."Order Placed At")
            {
                ApplicationArea = All;
            }
            field(OrderCreatedOn; Rec."Order Created On")
            {
                ApplicationArea = All;
            }
            field(ShipmentDate; Rec."Shipment Date")
            {
                Editable = true;
                ApplicationArea = All;
            }
            field(Status; Rec.status)
            {
                ApplicationArea = All;
            }
            field(NetOrderAmount; Rec."Net Order Amount")
            {
                ApplicationArea = All;
            }
            field(OrderAmount; Rec."Order Amount")
            {
                ApplicationArea = All;
            }
            // field(PaymentMethod; Rec."Payment Method")
            // {
            //     ApplicationArea = All;
            // }
            field(BillToName; Rec."Bill- to Name")
            {
                ApplicationArea = All;
            }
            field(BillToAddress; Rec.Address)
            {
                ApplicationArea = All;
            }
            field(BillToAddress2; Rec."Address 2")
            {
                ApplicationArea = All;
            }
            field(BillToCity; Rec.City)
            {
                ApplicationArea = All;
            }
            field(BillToPostCode; Rec."Post Code")
            {
                ApplicationArea = All;
            }
            field(ShipToName; Rec."Ship-to Name")
            {
                ApplicationArea = All;
            }
            field(ShipToAddress; Rec."Ship-to Address")
            {
                ApplicationArea = All;
            }
            field(ShipToAddress2; Rec."Ship-to Address 2")
            {
                ApplicationArea = All;
            }
            field(ShipToCity; Rec."Ship-to City")
            {
                ApplicationArea = All;
            }
            field(ShipToCountryRegionCode; Rec."Ship-to Country/Region Code")
            {
                ApplicationArea = All;
            }
            field(ShipToPostCode; Rec."Ship-to Post Code")
            {
                ApplicationArea = All;
            }
            field(ShipToEmail; Rec."Ship-to Email")
            {
                ApplicationArea = All;
            }
            // field(WebShipmentMethod; Rec."Web Shipment Method")
            // {
            //     ApplicationArea = All;
            // }
            // field("Shipping_Agent_Code"; Rec."Shipping Agent Code")
            // {
            //     ApplicationArea = All;
            // }
            // field("Shipping_Agent_Service_Code"; Rec."Shipping Agent Service Code")
            // {
            //     ApplicationArea = All;
            // }
            // field(ShippingPrice; Rec."Shipping Price")
            // {
            //     ApplicationArea = All;
            // }
            part(lines; "Web Order Line Subpage")
            {
                EntitySetName = 'lines';
                EntityName = 'line';
                SubPageLink = "Header Id" = field(SystemId);
            }
        }
    }

    trigger OnInsertRecord(BelowxRec: Boolean): Boolean
    var
        CU_WebOrderManagement: Codeunit "Web Order Mgt";
        IsExist: Boolean;
        ChannelPartner: Record "Trade Partner";
        SellToCustomer: Record Customer;
    begin
        //Duplicate Detection Code
        if ((Rec."Trade Partner Code" <> '') and (Rec."Channel Order ID" <> '')) then begin
            IsExist := CU_WebOrderManagement.CheckOrderNotExist(Rec."Trade Partner Code", Rec."Channel Order ID");
            if IsExist = false then begin
                Error(StrSubstNo('Order Already Exists With Order Id %1 For Channel Partner %2', Rec."Channel Order ID", Rec."Trade Partner Code"));
            end;

            ChannelPartner.Get(Rec."Trade Partner Code");
            if (Rec."Sell-to Customer No." <> '') then begin
                Case ChannelPartner."Customer Mapping" OF
                    ChannelPartner."Customer Mapping"::"Default Customer":
                        SellToCustomer.GET(ChannelPartner."Customer No.");
                    ChannelPartner."Customer Mapping"::"Order Customer":
                        SellToCustomer.GET(Rec."Sell-to Customer No.");
                End;
                if SellToCustomer.Blocked = SellToCustomer.Blocked::" " then begin
                    Rec."Sell-to Customer No." := SellToCustomer."No.";
                    Rec."Bill- to Name" := CopyStr(SellToCustomer.Name, 1, 50);
                    Rec.Address := SellToCustomer.Address;
                    Rec."Address 2" := SellToCustomer."Address 2";
                    Rec.City := SellToCustomer.City;
                    Rec."Post Code" := SellToCustomer."Post Code";
                    Rec."Sell to Country" := SellToCustomer."Country/Region Code";
                    if SellToCustomer."Location Code" <> '' then
                        Rec."Location Code" := SellToCustomer."Location Code"
                    else
                        Rec."Location Code" := ChannelPartner.Location;
                end
                else begin
                    Error(StrSubstNo('Customer %1 is Blocked in System.', SellToCustomer."No."));
                end;
            end;
        end;
    end;

    trigger OnAfterGetRecord()
    var
        CU_WebOrderManagement: Codeunit "Web Order Mgt";
    begin
        CU_WebOrderManagement.OrderValidations(Rec);
    end;
}