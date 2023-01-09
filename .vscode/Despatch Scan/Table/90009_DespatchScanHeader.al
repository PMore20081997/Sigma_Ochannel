table 90009 "Despatch Scan Header"
{
    fields
    {
        field(1; "Entry No."; Integer)
        {
            DataClassification = ToBeClassified;

        }
        field(2; "Trolley No"; Code[20])
        {
            DataClassification = ToBeClassified;
        }
        field(3; "Bay No."; Code[10])
        {
            DataClassification = ToBeClassified;
        }
        field(4; "Item No."; Code[20])
        {
            DataClassification = ToBeClassified;
        }
        field(5; "User ID"; Code[50])
        {
            DataClassification = ToBeClassified;
        }
        field(6; Scanned; Boolean)
        {
            DataClassification = ToBeClassified;
        }
        field(7; "Order No"; Code[20])
        {
            DataClassification = ToBeClassified;
        }
        field(8; "Line exist"; Boolean)
        {

            FieldClass = FlowField;
            CalcFormula = exist("Despatch Scan Line" where("Trolley No" = field("Trolley No")));
        }
        field(9; "Dispatch Order-Wise"; Boolean)
        {
        }
    }
    keys
    {
        key(PK; "Entry No.")
        {
            Clustered = true;
        }
    }
    trigger OnDelete()
    var
        L_DespatchScanLine: Record "Despatch Scan Line";
    begin
        L_DespatchScanLine.Reset();
        L_DespatchScanLine.SetRange("Trolley No", Rec."Trolley No");
        L_DespatchScanLine.SetRange("User ID", Rec."User ID");
        if L_DespatchScanLine.FindSet() then begin
            repeat
                L_DespatchScanLine.Delete(true);
            until L_DespatchScanLine.Next() = 0;
        end;
    end;
}