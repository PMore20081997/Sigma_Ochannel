table 90012 "Order Level Response"
{
    fields
    {
        field(1; "Entry No."; Integer)
        {
            AutoIncrement = true;
        }
        field(2; Reason; Text[250])
        {

        }
        field(3; Message; Text[250])
        {

        }
        field(4; "Error Code"; Code[20])
        {
            trigger OnValidate()
            var
                L_OrderLevelResponse: Record "Order Level Response";
            begin
                if Rec."Error Code" <> '' then begin
                    L_OrderLevelResponse.Reset();
                    L_OrderLevelResponse.SetRange("Error Code", Rec."Error Code");
                    if L_OrderLevelResponse.FindFirst() then
                        Error('Error Code %1 already exist', Rec."Error Code");
                end;

            end;
        }
    }
    keys
    {
        key(PK; "Entry No.")
        {

        }
    }
}