pageextension 90073 "Warehouse Shipment List Ext" extends "Warehouse Shipment List"
{

    procedure AddToFilterText2(VAR TextVar: Text[250]; Separator: Code[1]; Comparator: Code[2]; Addendum: Code[20])
    begin
        IF TextVar = '' THEN
            TextVar := Comparator + Addendum
        ELSE
            TextVar += Separator + Comparator + Addendum;
    end;



}