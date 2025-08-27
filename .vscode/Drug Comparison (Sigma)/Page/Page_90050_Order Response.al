page 90050 "Order Response(DC)"
{
    PageType = API;
    SourceTable = "Interim Sales Header";
    APIPublisher = 'Robosol';
    APIGroup = 'DCorderResponse';
    APIVersion = 'v2.0';
    EntitySetName = 'HeaderDetails';
    EntityName = 'Header';
    DelayedInsert = true;
    SourceTableView = where("Document Type" = const(Order));
    RefreshOnActivate = true;
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
                Editable = false;
            }
            field(ChannelOrderId; Rec."Channel Order ID")
            {
                ApplicationArea = All;
                Editable = false;
            }
            field(OrderReferenceNo; Rec."No.")
            {
                ApplicationArea = All;
                Editable = false;
            }
            field(DocumentType; Rec."Document Type")
            {
                ApplicationArea = All;
                Editable = false;
            }

            field(ETAccessCode; REc."ET Access Code")
            {
                ApplicationArea = All;
                Editable = false;
            }
            field(SelltoCustomerNo; Rec."Sell-to Customer No.")
            {
                ApplicationArea = All;
                Editable = false;
            }
            field(DocumentDate; Rec."Document Date")
            {
                ApplicationArea = All;
                Editable = false;
            }
            field(ReasonCode; Rec."Reason Code")
            {
                ApplicationArea = All;
                Editable = false;
            }
            field(ReasonMessage; Rec."Reason Message")
            {
                ApplicationArea = All;
                Editable = false;
            }
            part(LineDetail; "Line Response")
            {
                EntitySetName = 'lines';
                EntityName = 'line';
                ApplicationArea = All;
                //SubPageLink = "Document Type" = FIELD("Document Type"), "Document No" = FIELD("No.");
                SubPageLink = "Header Id" = field(SystemId);
                Editable = false;
                UpdatePropagation = Both;
            }

        }
    }
}