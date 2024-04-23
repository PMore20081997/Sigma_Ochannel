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
                textelement(ChannelCode)
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
                    ChannelCode := L_Header."Trade Partner Code";
                    CustomerNo := L_Header."Sell-to Customer No.";
                    OrderResponse := L_Header."Reason Code";
                    SigmaOrderNo := L_Header."No.";
                    TotalOrderValue := Format(L_Header."Order Amount");
                    TransmittedFlag := Format(1);
                    LineNumber := Format(Interim_Sales_Line."Line No.");
                    PipCode := Interim_Sales_Line."No.";
                    //Qty := Format(Interim_Sales_Line.Quantity);
                    Qty := Format(Interim_Sales_Line."Qty. to Deliver");
                    ProductResponse := Interim_Sales_Line."Reason Code";
                    Misc := '';
                    FileName := L_Header."File Name";
                end;
            }
        }
    }
}