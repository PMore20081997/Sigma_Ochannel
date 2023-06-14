codeunit 90072 "Update Status"
{
    Description = 'This codeunit in not in use';
    TableNo = 472;
    trigger OnRun()
    begin
        IF (STRPOS(Rec."Parameter String", ';')) > 0 THEN begin
            StartParameter := COPYSTR(Rec."Parameter String", 1, (STRPOS(Rec."Parameter String", ';') - 1));
            RunType := COPYSTR(Rec."Parameter String", (STRPOS(Rec."Parameter String", ';') + 1), (STRLEN(Rec."Parameter String") - STRPOS(Rec."Parameter String", ';')));
        end;

        CASE StartParameter OF
            'SHOPDIRECT':
                BEGIN
                    GetFileNameFromAzure(StartParameter);
                End;
        end;
    end;

    local procedure GetFileNameFromAzure(P_ChannelCode: Code[20])
    var
        apiEndPoint: Text;
        containerName: Text;
        apiattribute: Text;
        sasToken: Text;
        apiUrl: Text;
        httpClient: HttpClient;
        httpResponse: HttpResponseMessage;
        ResponseText: Text;
        xmlDoc: XmlDocument;
        L_Root: XmlElement;
        L_Orders: XmlNodeList;
        L_Node: XmlNode;
        e: XmlElement;
        L_Orders2: XmlNodeList;
        L_Node2: XmlNode;
        L_Orders3: XmlNodeList;
        L_Node3: XmlNode;
        TradePartner: Record "Trade Partner";
    begin
        ClearLastError();
        TradePartner.Reset();
        TradePartner.SetRange(Code, P_ChannelCode);
        if TradePartner.FindFirst() then begin
            apiEndPoint := TradePartner."API Endpoint";
            apiattribute := TradePartner."API Attribute";
            containerName := TradePartner."Status Conatiner Name";
            sasToken := TradePartner."Status Token";
        end;
        // apiEndPoint := 'https://shopdirect.blob.core.windows.net';
        // containerName := 'teststupdout';
        // apiattribute := '?restype=container&comp=list';
        // sasToken := 'sp=r&st=2021-06-28T19:10:09Z&se=2021-06-29T03:10:09Z&sv=2020-02-10&sr=c&sig=jZkW7%2BNtLBfJXHAC10tGOtinM2OxBmRVs2m4QORwRYw%3D';
        apiUrl := apiEndPoint + '/' + containerName + apiattribute + '&' + sasToken;

        httpClient.Get(apiUrl, httpResponse);
        if (httpResponse.HttpStatusCode = 200) then begin
            if (httpResponse.IsSuccessStatusCode = true) then begin
                httpResponse.Content().ReadAs(ResponseText);
                if XmlDocument.ReadFrom(ResponseText, xmlDoc) then begin
                    xmlDoc.GetRoot(L_Root);
                    L_Orders := L_Root.GetChildElements('Blobs');
                    foreach L_Node in L_Orders do begin
                        Clear(e);
                        e := L_Node.AsXmlElement();
                        Clear(L_Orders2);
                        Clear(L_Node2);
                        L_Orders2 := L_Node.AsXmlElement().GetChildElements();
                        foreach L_Node2 in L_Orders2 do begin
                            Clear(e);
                            e := L_Node2.AsXmlElement();
                            Clear(L_Orders3);
                            Clear(L_Node3);
                            L_Orders3 := L_Node2.AsXmlElement().GetChildElements();
                            foreach L_Node3 in L_Orders3 do begin
                                Clear(e);
                                e := L_Node3.AsXmlElement();
                                if e.Name = 'Name' then begin
                                    UpdateStatus(StartParameter, e.InnerText);
                                end;
                            end;
                        end;
                    end;
                end;
            end;
        end;
    end;


    local procedure UpdateStatus(P_ChannelCode: Code[20]; FileName: Text)
    begin

    end;

    var
        StartParameter: Text;
        RunType: Text;
        Windows: Dialog;
        Text001: TextConst ENG = 'Channel Partner....';
}