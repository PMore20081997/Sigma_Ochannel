tableextension 90097 "Sales Line Extended" extends "Sales Line"
{

    fields
    {
        field(90000; "Scanned Date"; DateTime)
        {

        }
        field(90001; "Channel Order ID"; Code[50])
        {
        }
        field(90002; "Channel Code"; Code[20])
        {
        }
        field(90003; "Web Order"; Boolean)
        {

        }
        field(90004; "Web Orders Qty"; Decimal)
        {
            FieldClass = FlowField;
            CalcFormula = sum("Interim Sales Line".Quantity where(Type = const(Item), "No." = field("No."), "Reason Message" = const('Successful'), "Sales Order Created" = const(false)));
            DecimalPlaces = 0 : 5;
            Editable = false;
        }
        field(90005; "Ship-to Code"; Code[20])
        {
            //FTP Integration
        }
        field(90006; "Temp Web Order No."; Code[2048])
        {
            //FTP Integration
        }

    }
}