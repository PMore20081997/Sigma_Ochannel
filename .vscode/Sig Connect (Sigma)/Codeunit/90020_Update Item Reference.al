codeunit 90020 "Update Item Reference"
{
    trigger OnRun()
    var
        jsonText: JsonObject;
    begin
        //Input('{Value:[{"Item_No": "000-0596","Variant_Code": "","Unit_of_Measure": "PCS","Reference_Type": "PIP Code","PIP_Code": "0000596", "Synced": false},{"Item_No": "000-12891","Variant_Code": "","Unit_of_Measure": "PCS","Reference_Type": "PIP Code","PIP_Code": "0001289", "Synced": true}]}')
    end;

    var
        //For Response++
        Response_JsonArrayLine: JsonArray;
        Response_JsonObject: JsonObject;

    procedure Input(jsonText: Text) _Response: Text
    var
        JsonObject: JsonObject;
    begin
        if not JsonObject.ReadFrom(jsonText) then
            Error('Error reading jsonText');

        //Proceed request and Genrate response++
        Clear(_Response);
        _Response := ReadeandProceed(JsonObject);
        exit(_Response);
    end;

    local procedure ReadeandProceed(JO: JsonObject) _Response: Text
    var
        JsonArrayLine: JsonArray;
        JsonTokenLine: JsonToken;
        JsonObjectLine: JsonObject;
        JsonObject: JsonObject;
        JsonObjectForLine: JsonObject;

    begin
        //Creating Response more code on UpdateChannelItemReference function++
        Clear(_Response);
        Clear(Response_JsonObject);
        Clear(Response_JsonArrayLine);
        Response_JsonObject.Add('Value', Response_JsonArrayLine);

        //Read Value Details++
        Clear(JsonArrayLine);
        JsonArrayLine := GetJsonValue(JO, 'Value').AsArray();
        foreach JsonTokenLine in JsonArrayLine do begin
            Clear(JsonObjectLine);
            JsonObjectLine := JsonTokenLine.AsObject();
            UpdateChannelItemReference(JsonObjectLine);
        end;


        //Send Respose Back to API++
        Response_JsonObject.WriteTo(_Response);
    end;

    local procedure GetJsonValue(JsonObject: JsonObject; TokenKey: Text) JsonToken: JsonToken;
    begin
        if not JsonObject.Get(TokenKey, JsonToken) then
            Error('Could not find a token with key %1', TokenKey);
    end;

    local procedure UpdateChannelItemReference(_JsonObjectLine: JsonObject)
    var
        L_ItemReference: Record "Item Reference";
        _Synced: Boolean;
        Response_JsonObjectForLine: JsonObject;
    begin
        Clear(_Synced);
        Evaluate(_Synced, GetJsonValue(_JsonObjectLine, 'Synced').AsValue().AsCode());
        L_ItemReference.Reset();
        L_ItemReference.SetRange("Reference Type", L_ItemReference."Reference Type"::"PIP Code");
        L_ItemReference.SetRange("Item No.", GetJsonValue(_JsonObjectLine, 'Item_No').AsValue().AsCode());
        L_ItemReference.SetRange("Variant Code", GetJsonValue(_JsonObjectLine, 'Variant_Code').AsValue().AsCode());
        L_ItemReference.SetRange("Unit of Measure", GetJsonValue(_JsonObjectLine, 'Unit_of_Measure').AsValue().AsCode());
        L_ItemReference.SetRange("Reference No.", GetJsonValue(_JsonObjectLine, 'PIP_Code').AsValue().AsCode());
        if L_ItemReference.FindFirst() then begin
            if L_ItemReference.Synced <> _Synced then begin
                L_ItemReference.Synced := _Synced;
                L_ItemReference.Modify();
            end;

            //Generatig Response++
            Clear(Response_JsonObjectForLine);
            Response_JsonObjectForLine.Add('Item_No', L_ItemReference."Item No.");
            Response_JsonObjectForLine.Add('PIP_Code', L_ItemReference."Reference No.");
            Response_JsonObjectForLine.Add('Synced', _Synced);
            Response_JsonObjectForLine.Add('Response', 'Updated');
            // Response_JsonObjectForLine.Add('Variant_Code', L_ItemReference."Variant Code");
            // Response_JsonObjectForLine.Add('Unit_of_Measure', L_ItemReference."Unit of Measure");
            // Response_JsonObjectForLine.Add('Reference_Type', 'PIP Code');
            // Response_JsonObjectForLine.Add('PIP_Code', L_ItemReference."Reference No.");
            // Response_JsonObjectForLine.Add('Synced', L_ItemReference.Synced);
            Response_JsonArrayLine.Add(Response_JsonObjectForLine);
            //Generatig Response--
        end else begin
            //Generatig Response++
            Clear(Response_JsonObjectForLine);
            Response_JsonObjectForLine.Add('Item_No', L_ItemReference."Item No.");
            Response_JsonObjectForLine.Add('PIP_Code', L_ItemReference."Reference No.");
            Response_JsonObjectForLine.Add('Synced', _Synced);
            Response_JsonObjectForLine.Add('Response', 'Not Updated');
            // Response_JsonObjectForLine.Add('Item_No', GetJsonValue(_JsonObjectLine, 'Item_No').AsValue().AsCode());
            // Response_JsonObjectForLine.Add('Variant_Code', GetJsonValue(_JsonObjectLine, 'Variant_Code').AsValue().AsCode());
            // Response_JsonObjectForLine.Add('Unit_of_Measure', GetJsonValue(_JsonObjectLine, 'Unit_of_Measure').AsValue().AsCode());
            // Response_JsonObjectForLine.Add('Reference_Type', 'PIP Code');
            // Response_JsonObjectForLine.Add('PIP_Code', GetJsonValue(_JsonObjectLine, 'PIP_Code').AsValue().AsCode());
            // Response_JsonObjectForLine.Add('Synced', _Synced);
            Response_JsonArrayLine.Add(Response_JsonObjectForLine);
            //Generatig Response--
        end;
    end;

}