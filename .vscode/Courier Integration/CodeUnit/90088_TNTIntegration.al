codeunit 90088 "TNT Courier"
{
    TableNo = 36;
    trigger OnRun()
    begin
        CreateConsignment(Rec);
    end;

    var
        Username: Text;
        Password: Text;
        ServiceURL: Text;


    local procedure GetCredentials(ShippingAgentCode: Code[10])
    var
        L_ShippingAgent: Record "Shipping Agent";
    begin
        L_ShippingAgent.Reset();
        if L_ShippingAgent.Get(ShippingAgentCode) then begin
            Username := L_ShippingAgent."Access Key";
            Password := L_ShippingAgent."Secret Key";
            ServiceURL := L_ShippingAgent."API URL";
        End;
    end;


    procedure CreateConsignment(var Temp_SalesHeader: Record "Sales Header" temporary)
    var
        Client: HttpClient;
        headers: HttpHeaders;
        Content: HttpContent;
        RequestMessage: HttpRequestMessage;
        ResponseMessage: HttpResponseMessage;
        body: Text;
        URL: Text;
        Response: Text;
        FinalXml: XmlDocument;
    begin
        GetCredentials(Temp_SalesHeader."Shipping Agent Code");
        FinalXml := CreateXml(Temp_SalesHeader);
        Message('%1', FinalXml);
        URL := 'https://express.tnt.com/expressconnect/shipping/ship';

        RequestMessage.SetRequestUri(URL);
        RequestMessage.Method('POST');
        FinalXml.WriteTo(body);
        Content.WriteFrom(body);
        Content.GetHeaders(Headers);
        Headers.Remove('Content-Type');
        Headers.Add('Content-Type', 'text/xml;charset=utf-8');
        RequestMessage.Content := Content;
        Client.Send(RequestMessage, ResponseMessage);
        ResponseMessage.Content().ReadAs(Response);
        Message(Response);
    end;


    procedure CreateXml(var Temp_SalesHeader: Record "Sales Header" temporary): XmlDocument
    var
        L_XmlDocument: XmlDocument;
        L_XmlDeclare: XmlDeclaration;
        L_XmlElement: XmlElement;
        Login: XmlElement;
        ConnBatch: XmlElement;
        Sender: XmlElement;
        Sender_Collection: XmlElement;
        Sen_Coll_PrefCollTime: XmlElement;
        Consignment: XmlElement;
        Consign_Details: XmlElement;
        Consgn_Det_Receiver: XmlElement;
        Consgn_Det_Deliver: XmlElement;
        Consgn_Det_Package: XmlElement;
        Consgn_Det_Package_Article: XmlElement;
        Activity: XmlElement;
        Activity_Create: XmlElement;
        Activity_Ship: XmlElement;
        Activity_Print: XmlElement;
        Print_Connote: XmlElement;
        Print_Label: XmlElement;
        Print_Manifest: XmlElement;
        Print_Invoice: XmlElement;
    begin
        L_XmlDocument := XmlDocument.Create;
        L_XmlDeclare := XmlDeclaration.Create('1.0', 'UTF-8', 'no');
        L_XmlDocument.SetDeclaration(L_XmlDeclare);

        L_XmlElement := XmlElement.Create('ESHIPPER');

        Login := XmlElement.Create('LOGIN');
        L_XmlElement.Add(Login);
        CreateXmlGeneric(Login, 'COMPANY', 'startri_T');
        CreateXmlGeneric(Login, 'PASSWORD', 'Test@1234');
        CreateXmlGeneric(Login, 'APPID', 'EC');
        CreateXmlGeneric(Login, 'APPVERSION', '3.1');

        ConnBatch := XmlElement.Create('CONSIGNMENTBATCH');
        Sender := XmlElement.Create('SENDER');
        L_XmlElement.Add(ConnBatch);
        ConnBatch.Add(Sender);
        CreateXmlGeneric(Sender, 'COMPANYNAME', '[CDATA[Sender Co 01-008]]');
        CreateXmlGeneric(Sender, 'STREETADDRESS1', '[CDATA[TEST DO NOT COLLECT1]]');//optional
        CreateXmlGeneric(Sender, 'CITY', '[CDATA[Atherstone]]');
        CreateXmlGeneric(Sender, 'PROVINCE', '[CDATA[Warwickshire]]');//optional
        CreateXmlGeneric(Sender, 'POSTCODE', '[CDATA[CV9 2ry]]');//optional
        CreateXmlGeneric(Sender, 'COUNTRY', '[CDATA[GB]]');
        CreateXmlGeneric(Sender, 'ACCOUNT', '[CDATA[905300550]]');
        CreateXmlGeneric(Sender, 'CONTACTNAME', '[CDATA[Mr Contact]]');
        CreateXmlGeneric(Sender, 'CONTACTDIALCODE', '[CDATA[01827]]');
        CreateXmlGeneric(Sender, 'CONTACTTELEPHONE', '[CDATA[717733]]');
        CreateXmlGeneric(Sender, 'CONTACTEMAIL', '[CDATA[contact@tnt.com]]');

        Sender_Collection := XmlElement.Create('COLLECTION');
        Sender.Add(Sender_Collection);
        CreateXmlGeneric(Sender_Collection, 'SHIPDATE', '[CDATA[26/08/2021]]');//should be in DD/MM/CCYY format
        Sen_Coll_PrefCollTime := XmlElement.Create('PREFCOLLECTTIME');
        CreateXmlGeneric(Sen_Coll_PrefCollTime, 'FROM', '[CDATA[09:00]]');
        CreateXmlGeneric(Sen_Coll_PrefCollTime, 'TO', '[CDATA[10:00]]');
        Sender_Collection.Add(Sen_Coll_PrefCollTime);
        CreateXmlGeneric(Sender_Collection, 'COLLINSTRUCTIONS', '[CDATA[use rear gate 01-008]]');

        Consignment := XmlElement.Create('CONSIGNMENT');
        ConnBatch.Add(Consignment);
        CreateXmlGeneric(Consignment, 'CONREF', 'ref05_012');
        Consign_Details := XmlElement.Create('DETAILS');
        Consignment.Add(Consign_Details);
        Consgn_Det_Receiver := XmlElement.Create('RECEIVER');
        Consign_Details.Add(Consgn_Det_Receiver);
        Consgn_Det_Deliver := XmlElement.Create('DELIVERY');
        Consign_Details.Add(Consgn_Det_Deliver);


        CreateXmlGeneric(Consgn_Det_Receiver, 'COMPANYNAME', '[CDATA[Receiver Name]]');
        CreateXmlGeneric(Consgn_Det_Receiver, 'STREETADDRESS1', '[CDATA[TEST DO NOT COLLECT7]]');
        CreateXmlGeneric(Consgn_Det_Receiver, 'CITY', '[CDATA[Amsterdam]');
        CreateXmlGeneric(Consgn_Det_Receiver, 'POSTCODE', '[CDATA[1012 AA]]');
        CreateXmlGeneric(Consgn_Det_Receiver, 'COUNTRY', '[CDATA[NL]]');
        CreateXmlGeneric(Consgn_Det_Receiver, 'CONTACTNAME', '[CDATA[Mr Bob]]');
        CreateXmlGeneric(Consgn_Det_Receiver, 'CONTACTDIALCODE', '[CDATA[1672]]');
        CreateXmlGeneric(Consgn_Det_Receiver, 'CONTACTTELEPHONE', '[CDATA[987432]]');
        CreateXmlGeneric(Consgn_Det_Receiver, 'CONTACTEMAIL', '[CDATA[contact@tnt.com]]');

        CreateXmlGeneric(Consgn_Det_Deliver, 'COMPANYNAME', '[CDATA[Delivery Company Name]]');
        CreateXmlGeneric(Consgn_Det_Deliver, 'STREETADDRESS1', '[CDATA[TEST DO NOT COLLECT7]]');
        CreateXmlGeneric(Consgn_Det_Deliver, 'CITY', '[CDATA[Hoofddorp]');
        CreateXmlGeneric(Consgn_Det_Deliver, 'POSTCODE', '[CDATA[2132 LS]]');
        CreateXmlGeneric(Consgn_Det_Deliver, 'COUNTRY', '[CDATA[NL]]');
        CreateXmlGeneric(Consgn_Det_Deliver, 'CONTACTNAME', '[CDATA[Mr Bob]]');
        CreateXmlGeneric(Consgn_Det_Deliver, 'CONTACTDIALCODE', '[CDATA[1672]]');
        CreateXmlGeneric(Consgn_Det_Deliver, 'CONTACTTELEPHONE', '[CDATA[987432]]');
        CreateXmlGeneric(Consgn_Det_Deliver, 'CONTACTEMAIL', '[CDATA[contact@tnt.com]]');

        CreateXmlGeneric(Consign_Details, 'CUSTOMERREF', '[CDATA[Customer supplied ref]]');
        CreateXmlGeneric(Consign_Details, 'CONTYPE', '[CDATA[N]');
        CreateXmlGeneric(Consign_Details, 'PAYMENTIND', '[CDATA[S]]');//optional
        CreateXmlGeneric(Consign_Details, 'ITEMS', '[CDATA[1]]');//number of lines count
        CreateXmlGeneric(Consign_Details, 'TOTALWEIGHT', '[CDATA[1.8]]');
        CreateXmlGeneric(Consign_Details, 'TOTALVOLUME', '[CDATA[0.62]]');
        CreateXmlGeneric(Consign_Details, 'CURRENCY', '[CDATA[GBP]]');
        CreateXmlGeneric(Consign_Details, 'GOODSVALUE', '[CDATA[180.00]]');
        CreateXmlGeneric(Consign_Details, 'DIVISION', '[CDATA[G]]');
        CreateXmlGeneric(Consign_Details, 'SERVICE', '[CDATA[15N]]');
        CreateXmlGeneric(Consign_Details, 'DESCRIPTION', '[CDATA[assorted office accessories]]');//optional
        CreateXmlGeneric(Consign_Details, 'DELIVERYINST', '[CDATA[Delivery Instructions TEST]]');//optional

        Consgn_Det_Package := XmlElement.Create('PACKAGE');
        Consign_Details.Add(Consgn_Det_Package);
        CreateXmlGeneric(Consgn_Det_Package, 'ITEMS', '786');
        CreateXmlGeneric(Consgn_Det_Package, 'DESCRIPTION', '[CDATA[box 1]]');
        CreateXmlGeneric(Consgn_Det_Package, 'LENGTH', '[CDATA[0.1]]');
        CreateXmlGeneric(Consgn_Det_Package, 'HEIGHT', '[CDATA[0.2]]');
        CreateXmlGeneric(Consgn_Det_Package, 'WIDTH', '[CDATA[0.3]]');
        CreateXmlGeneric(Consgn_Det_Package, 'WEIGHT', '[CDATA[0.4]]');

        //For Article
        if Temp_SalesHeader.FindSet() then begin
            repeat

            until Temp_SalesHeader.Next() = 0;
        end;

        /*  Consgn_Det_Package_Article := XmlElement.Create('ARTICLE');
          Consgn_Det_Package.Add(Consgn_Det_Package_Article);
          CreateXmlGeneric(Consgn_Det_Package_Article, 'ITEMS', '1');
          CreateXmlGeneric(Consgn_Det_Package_Article, 'DESCRIPTION', 'paperclips');
          CreateXmlGeneric(Consgn_Det_Package_Article, 'WEIGHT', '.03');
          CreateXmlGeneric(Consgn_Det_Package_Article, 'INVOICEVALUE', '2.30');
          CreateXmlGeneric(Consgn_Det_Package_Article, 'INVOICEDESC', 'metal paperclips');
          CreateXmlGeneric(Consgn_Det_Package_Article, 'HTS', 'ABC');
          CreateXmlGeneric(Consgn_Det_Package_Article, 'COUNTRY', 'GB');*/

        //For Testing Repeating Package and Article ++
        Consgn_Det_Package := XmlElement.Create('PACKAGE');
        Consign_Details.Add(Consgn_Det_Package);
        CreateXmlGeneric(Consgn_Det_Package, 'ITEMS', '[CDATA[1]]');
        CreateXmlGeneric(Consgn_Det_Package, 'DESCRIPTION', '[CDATA[box 1]]');
        CreateXmlGeneric(Consgn_Det_Package, 'LENGTH', '[CDATA[0.5]]');
        CreateXmlGeneric(Consgn_Det_Package, 'HEIGHT', '[CDATA[0.6]]');
        CreateXmlGeneric(Consgn_Det_Package, 'WIDTH', '[CDATA[0.7]]');
        CreateXmlGeneric(Consgn_Det_Package, 'WEIGHT', '[CDATA[0.8]]');

        Consgn_Det_Package_Article := XmlElement.Create('ARTICLE');
        Consgn_Det_Package.Add(Consgn_Det_Package_Article);
        CreateXmlGeneric(Consgn_Det_Package_Article, 'ITEMS', '[CDATA[1]]');
        CreateXmlGeneric(Consgn_Det_Package_Article, 'DESCRIPTION', '[CDATA[paperclips]]');
        CreateXmlGeneric(Consgn_Det_Package_Article, 'WEIGHT', '[CDATA[0.3]]');
        CreateXmlGeneric(Consgn_Det_Package_Article, 'INVOICEVALUE', '[CDATA[2.30]]');
        CreateXmlGeneric(Consgn_Det_Package_Article, 'INVOICEDESC', '[CDATA[metal paperclips]]');
        CreateXmlGeneric(Consgn_Det_Package_Article, 'HTS', '[CDATA[ABC]]');//optional
        CreateXmlGeneric(Consgn_Det_Package_Article, 'COUNTRY', '[CDATA[GB]]');
        //For Testing Repeating Package and Article --

        Activity := XmlElement.Create('ACTIVITY');
        L_XmlElement.Add(Activity);
        Activity_Create := XmlElement.Create('CREATE');
        Activity.Add(Activity_Create);
        CreateXmlGeneric(Activity_Create, 'CONREF', '[CDATA[ref05_012]]');

        Activity_Ship := XmlElement.Create('SHIP');
        Activity.Add(Activity_Ship);
        CreateXmlGeneric(Activity_Ship, 'CONREF', '[CDATA[ref05_012]]');

        Activity_Print := XmlElement.Create('PRINT');
        Activity.Add(Activity_Print);

        Print_Connote := XmlElement.Create('CONNOTE');
        Activity_Print.Add(Print_Connote);
        CreateXmlGeneric(Print_Connote, 'CONREF', '[CDATA[ref05_012]]');

        Print_Label := XmlElement.Create('LABEL');
        Activity_Print.Add(Print_Label);
        CreateXmlGeneric(Print_Label, 'CONREF', '[CDATA[ref05_012]]');

        Print_Manifest := XmlElement.Create('MANIFEST');
        Activity_Print.Add(Print_Manifest);
        CreateXmlGeneric(Print_Manifest, 'CONREF', '[CDATA[ref05_012]]');

        Print_Invoice := XmlElement.Create('INVOICE');
        Activity_Print.Add(Print_Invoice);
        CreateXmlGeneric(Print_Invoice, 'CONREF', '[CDATA[ref05_012]]');

        CreateXmlGeneric(Activity_Print, 'EMAILTO', '[CDATA[bob.hitchens@tnt.com]]');
        CreateXmlGeneric(Activity_Print, 'EMAILFROM', '[CDATA[bob.hitchens@tnt.com]]');

        L_XmlDocument.Add(L_XmlElement);
        //Message(Format(L_XmlDocument));
        exit(L_XmlDocument);
    end;


    local procedure CreateXmlGeneric(P_XmlElem: XmlElement; P_Key: Text; P_Value: Text)
    var
        Generic_Element: XmlElement;
    begin
        Clear(Generic_Element);
        Generic_Element := XmlElement.Create(P_Key);
        Generic_Element.Add(xmlText.Create(P_Value));
        P_XmlElem.Add(Generic_Element);
    end;

}