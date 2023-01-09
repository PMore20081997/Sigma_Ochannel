tableextension 90005 LocationExt extends Location
{
    fields
    {
        field(90000; "Default DD Bin"; code[20])
        {
            DataClassification = ToBeClassified;
            TableRelation = Bin.Code where("Location Code" = field(Code));
        }
    }

    var
        myInt: Integer;
}