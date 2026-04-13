tableextension 90007 "OC UserSetupExt" extends "User Setup"
{
    fields
    {
        field(90000; "Allow Edit Qty. to ship"; Boolean)
        {
            Caption = 'Edit Qty. to ship';
            DataClassification = CustomerContent;
        }
        field(90001; "Allow to Auth. Web Order Price"; Boolean)
        {
            DataClassification = ToBeClassified;
        }
        field(90002; "Allow Edit Order/Product Resp."; Boolean)
        {
            DataClassification = ToBeClassified;
        }
        field(90003; "Allow to Move Web Orders"; Boolean)
        {
            DataClassification = ToBeClassified;
        }
        field(90004; "Allow to Delete Bulk SO"; Boolean)
        {
            DataClassification = ToBeClassified;
        }
        field(90005; "Allow to Delete Bulk Invoices"; Boolean)
        {
            DataClassification = ToBeClassified;
        }
        field(90006; "Allow Delete Bulk Credit Memos"; Boolean)
        {
            DataClassification = ToBeClassified;
        }
        field(90007; "Allow to Print PS Label"; Boolean)
        {
            DataClassification = ToBeClassified;
        }
    }
}