table 90100 "Prority Zone Sequence"
{
    fields
    {
        field(1; "Location Code"; Code[20])
        {
            Editable = false;
            TableRelation = Location;
        }
        field(2; "Zone Code"; Code[20])
        {
            Editable = false;
            TableRelation = Zone.Code WHERE("Location Code" = FIELD("Location Code"));
        }
        field(3; "Priority Zone Code"; Code[20])
        {

        }
        field(4; "Priority Sequence"; Integer)
        {

        }
    }
    keys
    {
        key(PK; "Location Code", "Zone Code", "Priority Zone Code", "Priority Sequence")
        {
            Clustered = true;
        }
    }
}