xmlport 90005 "Export File"
{
    Caption = 'Export File';
    DefaultFieldsValidation = false;
    Direction = Export;
    FieldSeparator = ',';
    FieldDelimiter = '<None>';
    TableSeparator = '<NewLine>';
    Format = VariableText;
    TextEncoding = UTF16;
    UseRequestPage = false;

    schema
    {
        textelement(root)
        {
            XmlName = 'Root';
            tableelement("Interim_Sales_Line"; "Interim Sales Line")
            {
                textelement(ETAccessCode)
                {

                }
                textelement(CustomerNo)
                {

                }
                textelement(OrderResponse)
                {

                }
                textelement(SigmaOrderNo)
                {

                }
                textelement(TotalOrderValue)
                {

                }
                textelement(TransmittedFlag)
                {

                }
                textelement(LineNumber)
                {

                }
                textelement(PipCode)
                {

                }
                textelement(Qty)
                {

                }
                textelement(ProductResponse)
                {

                }
                textelement(Misc)
                {

                }
                textelement(FileName)
                {

                }

                trigger OnAfterGetRecord()
                var
                    L_Header: Record "Interim Sales Header";
                begin
                    L_Header.Get(Interim_Sales_Line."Document Type", Interim_Sales_Line."Document No");
                    ETAccessCode := L_Header."ET Access Code";
                    CustomerNo := L_Header."Channel Order ID";
                    OrderResponse := L_Header."Reason Code";
                    SigmaOrderNo := L_Header."No.";
                    TotalOrderValue := Format(L_Header."Order Amount");
                    TransmittedFlag := Format(1);
                    LineNumber := Interim_Sales_Line."Channel Item Id";
                    PipCode := Interim_Sales_Line."Channel SKU";
                    Qty := Format(Interim_Sales_Line."Qty. to Deliver");
                    ProductResponse := Interim_Sales_Line."Reason Code";
                    Misc := '';
                    FileName := L_Header."File Name";
                end;
            }
        }
    }
}