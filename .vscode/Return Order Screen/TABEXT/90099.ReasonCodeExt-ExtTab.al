tableextension 90099 "Reason Code Ext" extends "Reason Code"
{
    fields
    {
        field(90000; "Zone Code"; Code[20])
        {
            TableRelation = Zone.Code;
        }
    }
    fieldgroups
    {
        addlast(Brick; "Zone Code")
        {

        }
    }
}