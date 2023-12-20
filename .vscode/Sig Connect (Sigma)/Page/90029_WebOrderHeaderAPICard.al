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
            field(Id; Rec.SystemId)
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
            field(OrderReferenceNo; Rec."No.")
            {
                ApplicationArea = All;
            }
            field(DocumentType; Rec."Document Type")
            {
                ApplicationArea = All;
            }
            field(SelltoCustomerNo; Rec."Sell-to Customer No.")
            {
                ApplicationArea = All;
            }
            field(DocumentDate; Rec."Document Date")
            {
                ApplicationArea = All;
            }
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
        if ((Rec."Trade Partner Code" <> '') and (Rec."Channel Order ID" <> '')) then begin
            //Duplicate Detection Code
            IsExist := CU_WebOrderManagement.CheckOrderNotExist(Rec."Trade Partner Code", Rec."Channel Order ID");
            if IsExist = false then begin
                Error(StrSubstNo('Order Already Exists With Order Id %1 For Channel Partner %2', Rec."Channel Order ID", Rec."Trade Partner Code"));
            end;



            //Insert Header Record++


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