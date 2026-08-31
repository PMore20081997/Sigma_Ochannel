codeunit 90038 "POD Father Integration"
{
    TableNo = "Job Queue Entry";
    Permissions = tabledata 112 = m;

    trigger OnRun()
    var
        _Error: Text;
    begin
        Clear(StartParameter);
        Clear(RunType);
        IF (STRPOS(Rec."Parameter String", ';')) > 0 THEN begin
            StartParameter := COPYSTR(Rec."Parameter String", 1, (STRPOS(Rec."Parameter String", ';') - 1));
            RunType := COPYSTR(Rec."Parameter String", (STRPOS(Rec."Parameter String", ';') + 1), (STRLEN(Rec."Parameter String") - STRPOS(Rec."Parameter String", ';')));
        end;

        case RunType of
            'CustomerAndSiteSync':
                begin
                    CustomerAndSite_OnPODFatherPortal('', StartParameter);
                end;
            'UpdatecustomerAndSiteSync':
                begin
                    UpdateCustomerAndSites_OnPODFatherPortal('', StartParameter);
                end;
        // 'NormalJob':
        //     begin
        //         Job_OnPODFatherPortal('', StartParameter);
        //     end;
        // 'UpdateSalesInvoiceStatus':
        //     begin
        //         GetJobAndUpdateSalesInvoice('', StartParameter, _Error);
        //     end;

        end;

        //Not required+++++++
        //Depot_OnPODFatherPortal('EPOD');
        //UpdateDepot_OnPODFatherPortal('EPOD');
    end;

    // procedure UpdateShipmentDate(var _SalesInvoiceHeader: Record "Sales Invoice Header")
    // begin
    //     if _SalesInvoiceHeader.FindSet() then begin
    //         repeat
    //             _SalesInvoiceHeader."Shipment Date" := 20230106D;
    //             _SalesInvoiceHeader.Modify();
    //         until _SalesInvoiceHeader.Next() = 0;
    //     end;
    // end;

    #Region Depots +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    // procedure Depot_OnPODFatherPortal(_LocationCode: Code[20]; ChannelCode: Code[10])
    // var
    //     L_Location: Record Location;
    // begin
    //     //Clear All Variable +++
    //     ClearAll();

    //     //Check Mandatory fields+++
    //     CheckMandatoryfield(ChannelCode);

    //     L_Location.Reset();
    //     L_Location.SetFilter("ePOD ID", '%1', 0);
    //     L_Location.SetRange("Depot Synced", false);
    //     L_Location.SetRange("Podfather Depot", true);
    //     L_Location.SetRange(Code, _LocationCode);
    //     if L_Location.FindSet() then begin
    //         repeat
    //             PostDepotToePOD(L_Location.Code, ChannelCode)
    //         until L_Location.Next() = 0;
    //     end;
    // end;

    // local procedure PostDepotToePOD(_LocationCode: Code[20]; _ChannelCode: Code[10])
    // var
    //     L_httpheaders: HttpHeaders;
    //     L_httpclient: HttpClient;
    //     L_URL: Text;
    //     body: Text;
    //     L_httpcontent: HttpContent;
    //     L_httpResponseMessage: HttpResponseMessage;
    //     L_Location: Record Location;
    //     Response: Text;
    //     jObject: JsonObject;
    //     JObject1: JsonObject;
    //     ModificationRequired: Boolean;
    // begin
    //     //Clear All Variable +++
    //     ClearAll();

    //     L_Location.Reset();
    //     L_Location.SetRange(Code, _LocationCode);
    //     if L_Location.FindFirst() then begin
    //         //Get Credential & URL Detail +++ 
    //         GetCredentials(_ChannelCode);

    //         L_httpheaders := L_httpclient.DefaultRequestHeaders;
    //         L_URL := ServiceURL + 'depots';
    //         L_httpheaders.Add('Accept', 'application/json');
    //         L_httpheaders.Add('Authorization', 'Bearer ' + SecretAccessKey);

    //         //Create Body+++
    //         Clear(body);
    //         body := Depot_Body(L_Location.Code);
    //         if StrLen(body) = 0 then
    //             exit;

    //         //Post Order to POD portal++
    //         Clear(Response);
    //         Clear(jObject);
    //         Clear(JObject1);
    //         Clear(ModificationRequired);
    //         L_httpcontent.WriteFrom(body);
    //         L_httpcontent.GetHeaders(L_httpheaders);
    //         L_httpheaders.Clear();
    //         L_httpheaders.Add('Content-Type', 'application/json');
    //         if L_httpclient.Post(L_URL, L_httpcontent, L_httpResponseMessage) then begin
    //             L_httpResponseMessage.Content.ReadAs(Response);
    //             //Response 201 means Successful+++ 
    //             if L_httpResponseMessage.HttpStatusCode = 201 then begin

    //                 //Read the response in JObject+++
    //                 JObject.ReadFrom(Response);
    //                 JObject1 := GetJsonToken(jObject, 'data').AsObject();


    //                 //Get ePOD ID+++
    //                 if JObject1.Contains('id') then begin
    //                     L_Location."ePOD ID" := GetJsonvalue(JObject1, 'id').AsInteger();
    //                     ModificationRequired := true;
    //                 end else
    //                     ModificationRequired := false;


    //                 //Get ePOD Status+++
    //                 if JObject1.Contains('active') then begin
    //                     if GetJsonvalue(JObject1, 'active').AsBoolean() = true then
    //                         L_Location."ePOD Status" := L_Location."ePOD Status"::Active
    //                     else
    //                         if GetJsonvalue(JObject1, 'active').AsBoolean() = false then
    //                             L_Location."ePOD Status" := L_Location."ePOD Status"::Inactive;
    //                     ModificationRequired := true;
    //                 end else
    //                     ModificationRequired := false;

    //                 if ModificationRequired = true then begin
    //                     L_Location."Depot Synced" := true;
    //                     L_Location.Modify();
    //                 end;
    //             end;
    //         end else
    //             Error(GetLastErrorText);
    //     end;
    // end;

    // procedure UpdateDepot_OnPODFatherPortal(_LocationCode: Code[20]; ChannelCode: Code[10])
    // var
    //     L_Location: Record Location;
    // begin
    //     //Clear All Variable +++
    //     ClearAll();

    //     //Check Mandatory fields+++
    //     CheckMandatoryfield(ChannelCode);

    //     L_Location.Reset();
    //     L_Location.SetFilter("ePOD ID", '<>%1', 0);
    //     L_Location.SetRange("Depot Synced", false);
    //     L_Location.SetRange("Podfather Depot", true);
    //     L_Location.SetRange(Code, _LocationCode);
    //     if L_Location.FindSet() then begin
    //         repeat
    //             UpdateDepotToePOD(L_Location.Code, ChannelCode)
    //         until L_Location.Next() = 0;
    //     end;
    // end;

    // local procedure UpdateDepotToePOD(_LocationCode: Code[20]; _ChannelCode: Code[10])
    // var
    //     L_httpheaders: HttpHeaders;
    //     L_httpclient: HttpClient;
    //     L_URL: Text;
    //     body: Text;
    //     L_httpcontent: HttpContent;
    //     L_httpResponseMessage: HttpResponseMessage;
    //     L_Location: Record Location;
    //     Response: Text;
    //     jObject: JsonObject;
    //     JObject1: JsonObject;
    //     ModificationRequired: Boolean;
    // begin
    //     //Clear All Variable +++
    //     ClearAll();

    //     L_Location.Reset();
    //     L_Location.SetRange(Code, _LocationCode);
    //     if L_Location.FindFirst() then begin
    //         //Get Credential & URL Detail +++ 
    //         GetCredentials(_ChannelCode);

    //         L_httpheaders := L_httpclient.DefaultRequestHeaders;
    //         L_URL := ServiceURL + 'depots/' + Format(L_Location."ePOD ID");
    //         L_httpheaders.Add('Accept', 'application/json');
    //         L_httpheaders.Add('Authorization', 'Bearer ' + SecretAccessKey);

    //         //Create Body+++
    //         Clear(body);
    //         body := Depot_Body(L_Location.Code);
    //         if StrLen(body) = 0 then
    //             exit;

    //         //Post Order to POD portal++
    //         Clear(Response);
    //         Clear(jObject);
    //         Clear(JObject1);
    //         Clear(ModificationRequired);
    //         L_httpcontent.WriteFrom(body);
    //         L_httpcontent.GetHeaders(L_httpheaders);
    //         L_httpheaders.Clear();
    //         L_httpheaders.Add('Content-Type', 'application/json');
    //         if L_httpclient.Put(L_URL, L_httpcontent, L_httpResponseMessage) then begin
    //             L_httpResponseMessage.Content.ReadAs(Response);
    //             //Response 200 means Successful+++ 
    //             if L_httpResponseMessage.HttpStatusCode = 200 then begin
    //                 L_Location."Depot Synced" := true;
    //                 L_Location.Modify();
    //             end;
    //         end;
    //     end;
    // end;

    // local procedure Depot_Body(_LocationCode: Code[20]): Text
    // var
    //     L_Location: Record Location;
    //     HeaderRequest: Text;
    //     L_country: Code[20];
    //     L_ListingStatus: Text;
    //     L_Address2: Text;
    // begin
    //     Clear(HeaderRequest);
    //     L_Location.Reset();
    //     L_Location.SetRange(Code, _LocationCode);
    //     if L_Location.FindFirst() then begin
    //         //+++++
    //         Clear(L_country);
    //         if L_Location."Country/Region Code" = '' then
    //             L_country := 'GB'
    //         else
    //             L_country := L_Location."Country/Region Code";

    //         //+++++
    //         Clear(L_ListingStatus);
    //         if L_Location."ePOD Status" = L_Location."ePOD Status"::Active then
    //             L_ListingStatus := 'true'
    //         else
    //             if L_Location."ePOD Status" = L_Location."ePOD Status"::Inactive then
    //                 L_ListingStatus := 'false';

    //         //++++
    //         Clear(L_Address2);
    //         if L_Location."Address 2" <> '' then
    //             L_Address2 := L_Location."Address 2"
    //         else
    //             L_Address2 := L_Location.Address;

    //         //++++
    //         // HeaderRequest := StrSubstNo('{"name":"%1","active":%2,"address1":"%3","address2":"%4","address3":"%5","city":"%6","region":"%7","postcode":"%8"'
    //         // + ',"phone":"%9","email":"%10"}', L_Location.Code, L_ListingStatus, L_Location.Address, L_Location."Address 2", ',', L_Location.City, L_country, L_Location."Post Code", L_Location."Phone No.", L_Location."E-Mail");

    //         HeaderRequest := StrSubstNo('{"name":"%1","active":%2,"address1":"%3","address2":"%4","city":"%5","region":"%6","postcode":"%7"'
    //        + ',"phone":"%8"}', L_Location.Code, L_ListingStatus, L_Location.Address, L_Address2, L_Location.City, L_country, L_Location."Post Code", L_Location."Phone No.");
    //     end;

    //     exit(HeaderRequest);
    // End;

    // [EventSubscriber(ObjectType::Table, Database::Location, OnAfterValidateEvent, 'Code', false, false)]
    // local procedure LocationCode_OnAfterValidateEvent(var Rec: Record Location; var xRec: Record Location)
    // begin
    //     if Rec.Code <> xRec.Code then begin
    //         Rec."Depot Synced" := false;
    //         Rec.Modify();
    //     end;
    // end;

    // [EventSubscriber(ObjectType::Table, Database::Location, OnAfterValidateEvent, 'Address', false, false)]
    // local procedure LocationAddress_OnAfterValidateEvent(var Rec: Record Location; var xRec: Record Location)
    // begin
    //     if Rec.Address <> xRec.Address then begin
    //         Rec."Depot Synced" := false;
    //         Rec.Modify();
    //     end;
    // end;

    // [EventSubscriber(ObjectType::Table, Database::Location, OnAfterValidateEvent, 'Address 2', false, false)]
    // local procedure LocationAddress2_OnAfterValidateEvent(var Rec: Record Location; var xRec: Record Location)
    // begin
    //     if Rec."Address 2" <> xRec."Address 2" then begin
    //         Rec."Depot Synced" := false;
    //         Rec.Modify();
    //     end;
    // end;

    // [EventSubscriber(ObjectType::Table, Database::Location, OnAfterValidateEvent, 'City', false, false)]
    // local procedure LocationCity_OnAfterValidateEvent(var Rec: Record Location; var xRec: Record Location)
    // begin
    //     if Rec.City <> xRec.City then begin
    //         Rec."Depot Synced" := false;
    //         Rec.Modify();
    //     end;
    // end;

    // [EventSubscriber(ObjectType::Table, Database::Location, OnAfterValidateEvent, 'Post Code', false, false)]
    // local procedure LocationPostCode_OnAfterValidateEvent(var Rec: Record Location; var xRec: Record Location)
    // begin
    //     if Rec."Post Code" <> xRec."Post Code" then begin
    //         Rec."Depot Synced" := false;
    //         Rec.Modify();
    //     end;
    // end;

    // [EventSubscriber(ObjectType::Table, Database::Location, OnAfterValidateEvent, 'Country/Region Code', false, false)]
    // local procedure LocationCountryRegionCode_OnAfterValidateEvent(var Rec: Record Location; var xRec: Record Location)
    // begin
    //     if Rec."Country/Region Code" <> xRec."Country/Region Code" then begin
    //         Rec."Depot Synced" := false;
    //         Rec.Modify();
    //     end;
    // end;

    // [EventSubscriber(ObjectType::Table, Database::Location, OnAfterValidateEvent, 'E-Mail', false, false)]
    // local procedure LocationEmail_OnAfterValidateEvent(var Rec: Record Location; var xRec: Record Location)
    // begin
    //     if Rec."E-Mail" <> xRec."E-Mail" then begin
    //         Rec."Depot Synced" := false;
    //         Rec.Modify();
    //     end;
    // end;

    // [EventSubscriber(ObjectType::Table, Database::Location, OnAfterValidateEvent, 'ePOD Status', false, false)]
    // local procedure LocationePODStatus_OnAfterValidateEvent(var Rec: Record Location; var xRec: Record Location)
    // begin
    //     if Rec."ePOD Status" <> xRec."ePOD Status" then begin
    //         Rec."Depot Synced" := false;
    //         Rec.Modify();
    //     end;
    // end;
    #EndRegion Depots +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

    #Region Customer & Site+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    procedure CustomerAndSite_OnPODFatherPortal(_CustomerNumber: Code[20]; ChannelCode: Code[10])
    var
        L_Customer: Record Customer;
        L_Sitesrequired: Boolean;
        L_Synced: Boolean;
        L_Customer1: Record Customer;
        Test: Page 6630;
    begin
        //Clear All Variable +++
        ClearAll();

        //Check Mandatory fields+++
        CheckMandatoryfield(ChannelCode);

        //Create Customer & Site on POD father portal+++
        L_Customer.Reset();
        if _CustomerNumber <> '' then
            L_Customer.SetRange("No.", _CustomerNumber);
        L_Customer.SetRange("Podfather Customer", true);
        L_Customer.SetFilter("ePOD ID", '%1', 0);
        L_Customer.SetRange("Customer Synced", false);
        L_Customer.SetFilter("Customer Site ID", '%1', 0);
        L_Customer.SetFilter(Status, '%1', L_Customer.Status::Released);
        if L_Customer.FindSet() then begin
            repeat
                //Customer+++
                Clear(L_Sitesrequired);
                L_Sitesrequired := PostCustomerToePOD(L_Customer."No.", ChannelCode);

                //Sites+++++
                if L_Sitesrequired = true then
                    L_Synced := PostSitestoePOD(L_Customer."No.", ChannelCode);

                //Update Customer+++
                if L_Synced = true then begin
                    L_Customer1.Reset();
                    L_Customer1.SetRange("No.", L_Customer."No.");
                    if L_Customer1.FindFirst() then begin
                        L_Customer1."Customer Synced" := true;
                        L_Customer1.Modify();
                    end;
                end else begin
                    L_Customer1.Reset();
                    L_Customer1.SetRange("No.", L_Customer."No.");
                    if L_Customer1.FindFirst() then begin
                        L_Customer1."Customer Synced" := false;
                        L_Customer1."ePOD ID" := 0;
                        L_Customer1."Customer Site ID" := 0;
                        L_Customer1.Modify();
                    end;
                end;

            until L_Customer.Next() = 0;
        end;
    end;

    local procedure PostCustomerToePOD(_CustomerNumber: Code[20]; _ChannelCode: Code[10]) SitesRequired: Boolean
    var
        L_httpheaders: HttpHeaders;
        L_httpclient: HttpClient;
        L_URL: Text;
        body: Text;
        L_httpcontent: HttpContent;
        L_httpResponseMessage: HttpResponseMessage;
        L_Customer: Record Customer;
        Response: Text;
        jObject: JsonObject;
        JObject1: JsonObject;
        ModificationRequired: Boolean;
    begin
        //Clear All Variable +++
        ClearAll();

        L_Customer.Reset();
        L_Customer.SetRange("No.", _CustomerNumber);
        if L_Customer.FindFirst() then begin
            //Get Credential & URL Detail +++ 
            GetCredentials(_ChannelCode);

            L_httpheaders := L_httpclient.DefaultRequestHeaders;
            L_URL := ServiceURL + 'customers';
            L_httpheaders.Add('Accept', 'application/json');
            L_httpheaders.Add('Authorization', 'Bearer ' + SecretAccessKey);

            //Create Body+++
            Clear(body);
            body := Customer_Body(L_Customer."No.");
            if StrLen(body) = 0 then
                exit;

            //Post Order to POD portal++
            Clear(Response);
            Clear(jObject);
            Clear(JObject1);
            Clear(ModificationRequired);
            L_httpcontent.WriteFrom(body);
            L_httpcontent.GetHeaders(L_httpheaders);
            L_httpheaders.Clear();
            L_httpheaders.Add('Content-Type', 'application/json');
            if L_httpclient.Post(L_URL, L_httpcontent, L_httpResponseMessage) then begin
                L_httpResponseMessage.Content.ReadAs(Response);
                //Response 201 means Successful+++ 
                if L_httpResponseMessage.HttpStatusCode = 201 then begin

                    //Read the response in JObject+++
                    JObject.ReadFrom(Response);
                    JObject1 := GetJsonToken(jObject, 'data').AsObject();


                    //Get ePOD ID+++
                    if JObject1.Contains('id') then begin
                        L_Customer."ePOD ID" := GetJsonvalue(JObject1, 'id').AsInteger();
                        ModificationRequired := true;
                    end else
                        ModificationRequired := false;


                    //Get ePOD Status+++
                    if JObject1.Contains('active') then begin
                        if GetJsonvalue(JObject1, 'active').AsBoolean() = true then
                            L_Customer."ePOD Status" := L_Customer."ePOD Status"::Active
                        else
                            if GetJsonvalue(JObject1, 'active').AsBoolean() = false then
                                L_Customer."ePOD Status" := L_Customer."ePOD Status"::Inactive;
                        ModificationRequired := true;
                    end else
                        ModificationRequired := false;

                    if ModificationRequired = true then begin
                        // L_Customer."Customer Synced" := true;
                        L_Customer.Modify();
                    end;

                    exit(true);
                end else begin
                    exit(false)
                end;
            end else
                exit(false);
        end else
            exit(false);
    end;


    local procedure PostSitestoePOD(_CustomerNumber: Code[20]; _ChannelCode: Code[10]) Synced: Boolean
    var
        L_httpheaders: HttpHeaders;
        L_httpclient: HttpClient;
        L_URL: Text;
        body: Text;
        L_httpcontent: HttpContent;
        L_httpResponseMessage: HttpResponseMessage;
        L_Customer: Record Customer;
        Response: Text;
        jObject: JsonObject;
        JObject1: JsonObject;
        ModificationRequired: Boolean;
    begin
        //Clear All Variable +++
        ClearAll();

        L_Customer.Reset();
        L_Customer.SetRange("No.", _CustomerNumber);
        if L_Customer.FindFirst() then begin
            //Get Credential & URL Detail +++ 
            GetCredentials(_ChannelCode);

            L_httpheaders := L_httpclient.DefaultRequestHeaders;
            L_URL := ServiceURL + 'sites';
            L_httpheaders.Add('Accept', 'application/json');
            L_httpheaders.Add('Authorization', 'Bearer ' + SecretAccessKey);

            //Create Body+++
            Clear(body);
            body := Site_Body(L_Customer."No.", L_Customer."ePOD ID");
            if StrLen(body) = 0 then
                exit;

            //Post Order to POD portal++
            Clear(Response);
            Clear(jObject);
            Clear(JObject1);
            Clear(ModificationRequired);
            L_httpcontent.WriteFrom(body);
            L_httpcontent.GetHeaders(L_httpheaders);
            L_httpheaders.Clear();
            L_httpheaders.Add('Content-Type', 'application/json');
            if L_httpclient.Post(L_URL, L_httpcontent, L_httpResponseMessage) then begin
                L_httpResponseMessage.Content.ReadAs(Response);
                //Response 201 means Successful+++ 
                if L_httpResponseMessage.HttpStatusCode = 201 then begin

                    //Read the response in JObject+++
                    JObject.ReadFrom(Response);
                    JObject1 := GetJsonToken(jObject, 'data').AsObject();


                    //Get ePOD ID+++
                    if JObject1.Contains('id') then begin
                        L_Customer."Customer Site ID" := GetJsonvalue(JObject1, 'id').AsInteger();
                        ModificationRequired := true;
                    end;

                    if ModificationRequired = true then begin
                        //L_Customer."Customer Synced" := true;
                        L_Customer.Modify();
                    end;

                    //+++
                    exit(true);
                end else
                    exit(false);
            end else
                exit(false)
        end else
            exit(false)
    end;

    procedure UpdateCustomerAndSites_OnPODFatherPortal(_CustomerNumber: Code[20]; ChannelCode: Code[10])
    var
        L_httpheaders: HttpHeaders;
        L_httpclient: HttpClient;
        L_URL: Text;
        body: Text;
        L_httpcontent: HttpContent;
        L_httpResponseMessage: HttpResponseMessage;
        L_Customer: Record Customer;
        Response: Text;
        jObject: JsonObject;
        JObject1: JsonObject;
        ModificationRequired: Boolean;
    begin
        //Clear All Variable +++
        ClearAll();

        //Check Mandatory fields+++
        CheckMandatoryfield(ChannelCode);

        //Update Customer on POD father portal+++
        L_Customer.Reset();
        L_Customer.SetRange("Podfather Customer", true);
        L_Customer.SetFilter("ePOD ID", '<>%1', 0);
        L_Customer.SetRange("Customer Synced", false);
        L_Customer.SetFilter("Customer Site ID", '<>%1', 0);
        L_Customer.SetFilter(Status, '%1', L_Customer.Status::Released);
        if _CustomerNumber <> '' then
            L_Customer.SetRange("No.", _CustomerNumber);
        if L_Customer.FindSet() then begin
            repeat
                //Customer+++
                UpdateCustomerToePOD(L_Customer."No.", ChannelCode);

                //Sites+++++
                UpdateSiteToePOD(L_Customer."No.", ChannelCode)
            until L_Customer.Next() = 0;
        end;

    end;


    local procedure UpdateCustomerToePOD(_CustomerNumber: Code[20]; _ChannelCode: Code[10])
    var
        L_httpheaders: HttpHeaders;
        L_httpclient: HttpClient;
        L_URL: Text;
        body: Text;
        L_httpcontent: HttpContent;
        L_httpResponseMessage: HttpResponseMessage;
        L_Customer: Record Customer;
        Response: Text;
        jObject: JsonObject;
        JObject1: JsonObject;
        ModificationRequired: Boolean;
    begin
        //Clear All Variable +++
        ClearAll();

        L_Customer.Reset();
        L_Customer.SetRange("No.", _CustomerNumber);
        if L_Customer.FindFirst() then begin
            //Get Credential & URL Detail +++ 
            GetCredentials(_ChannelCode);

            //++++
            L_httpheaders := L_httpclient.DefaultRequestHeaders;
            L_URL := ServiceURL + 'customers/' + Format(L_Customer."ePOD ID");
            L_httpheaders.Add('Accept', 'application/json');
            L_httpheaders.Add('Authorization', 'Bearer ' + SecretAccessKey);

            //Create Body+++
            Clear(body);
            body := Customer_Body(L_Customer."No.");
            if StrLen(body) = 0 then
                exit;

            //Post Order to POD portal++
            Clear(Response);
            Clear(jObject);
            Clear(JObject1);
            Clear(ModificationRequired);
            L_httpcontent.WriteFrom(body);
            L_httpcontent.GetHeaders(L_httpheaders);
            L_httpheaders.Clear();
            L_httpheaders.Add('Content-Type', 'application/json');
            if L_httpclient.Put(L_URL, L_httpcontent, L_httpResponseMessage) then begin
                L_httpResponseMessage.Content.ReadAs(Response);
                //Response 200 means Successful+++ 
                if L_httpResponseMessage.HttpStatusCode = 200 then begin
                    L_Customer."Customer Synced" := true;
                    L_Customer.Modify();
                end;
            end;
        end;
    end;

    local procedure UpdateSiteToePOD(_CustomerNumber: Code[20]; _ChannelCode: Code[10])
    var
        L_httpheaders: HttpHeaders;
        L_httpclient: HttpClient;
        L_URL: Text;
        body: Text;
        L_httpcontent: HttpContent;
        L_httpResponseMessage: HttpResponseMessage;
        L_Customer: Record Customer;
        Response: Text;
        jObject: JsonObject;
        JObject1: JsonObject;
        ModificationRequired: Boolean;
    begin
        //Clear All Variable +++
        ClearAll();

        L_Customer.Reset();
        L_Customer.SetRange("No.", _CustomerNumber);
        if L_Customer.FindFirst() then begin
            //Get Credential & URL Detail +++ 
            GetCredentials(_ChannelCode);

            //++++
            L_httpheaders := L_httpclient.DefaultRequestHeaders;
            L_URL := ServiceURL + 'sites/' + Format(L_Customer."Customer Site ID");
            L_httpheaders.Add('Accept', 'application/json');
            L_httpheaders.Add('Authorization', 'Bearer ' + SecretAccessKey);

            //Create Body+++
            Clear(body);
            body := Site_Body(L_Customer."No.", L_Customer."ePOD ID");
            if StrLen(body) = 0 then
                exit;

            //Post Order to POD portal++
            Clear(Response);
            Clear(jObject);
            Clear(JObject1);
            Clear(ModificationRequired);
            L_httpcontent.WriteFrom(body);
            L_httpcontent.GetHeaders(L_httpheaders);
            L_httpheaders.Clear();
            L_httpheaders.Add('Content-Type', 'application/json');
            if L_httpclient.Put(L_URL, L_httpcontent, L_httpResponseMessage) then begin
                L_httpResponseMessage.Content.ReadAs(Response);
                //Response 200 means Successful+++ 
                if L_httpResponseMessage.HttpStatusCode = 200 then begin
                    L_Customer."Customer Synced" := true;
                    L_Customer.Modify();
                end;
            end;
        end;
    end;


    local procedure Customer_Body(_CustomerNo: Code[20]): Text
    var
        L_Customer: Record Customer;
        HeaderRequest: Text;
        L_country: Code[20];
        L_ListingStatus: Text;
    begin
        Clear(HeaderRequest);
        L_Customer.Reset();
        L_Customer.SetRange("No.", _CustomerNo);
        if L_Customer.FindFirst() then begin
            //+++++
            Clear(L_country);
            if L_Customer."Country/Region Code" = '' then
                L_country := 'GB'
            else
                L_country := L_Customer."Country/Region Code";

            //+++++
            Clear(L_ListingStatus);
            if L_Customer."ePOD Status" = L_Customer."ePOD Status"::Active then
                L_ListingStatus := 'true'
            else
                if L_Customer."ePOD Status" = L_Customer."ePOD Status"::Inactive then
                    L_ListingStatus := 'false';

            //++++
            HeaderRequest := StrSubstNo('{"name":"%1","address1":"%2","address2":"%3","address3":"%4","city":"%5","region":"%6","postcode":"%7","country":"%8"'
            + ',"phone":"%9","email":"%10","accountNumber":"%11","accountNumber2":"%12","autoEmail":%13,"active":%14}', L_Customer."No.", L_Customer.Name, L_Customer.Address, L_Customer."Address 2", L_Customer.City, '', L_Customer."Post Code", L_country, L_Customer."Phone No.", L_Customer."E-Mail", L_Customer."No.", '', 'false', L_ListingStatus);
        end;

        exit(HeaderRequest);
    End;

    local procedure Site_Body(_CustomerNo: Code[20]; _ePODId: Integer): Text
    var
        L_Customer: Record Customer;
        HeaderRequest: Text;
        L_country: Code[20];
        L_ListingStatus: Text;
        L_CoordinateArry: Text;
        L_openingHours: Text;
    begin
        Clear(HeaderRequest);
        L_Customer.Reset();
        L_Customer.SetRange("No.", _CustomerNo);
        if L_Customer.FindFirst() then begin
            //+++++
            Clear(L_country);
            if L_Customer."Country/Region Code" = '' then
                L_country := 'GB'
            else
                L_country := L_Customer."Country/Region Code";

            //+++++
            Clear(L_ListingStatus);
            if L_Customer."ePOD Status" = L_Customer."ePOD Status"::Active then
                L_ListingStatus := 'true'
            else
                if L_Customer."ePOD Status" = L_Customer."ePOD Status"::Inactive then
                    L_ListingStatus := 'false';

            //++++
            Clear(L_CoordinateArry);
            L_CoordinateArry := StrSubstNo('"coordinate":{"latitude":%1,"longitude":%2}', 0, 0);

            // //++++
            // Clear(L_openingHours);
            // L_openingHours := StrSubstNo('"openingHours":{"monday":{"opens":"%1","closes":"%2"}}', '07:00:00', '18:30:00');

            //     //++++
            //     HeaderRequest := StrSubstNo('{"customer":"%1","name":"%2","address1":"%2","address2":"%3","address3":"%4","city":"%5","region":"%6","postcode":"%7","country":"%8",' + L_CoordinateArry
            //    + ',"contact":"%9","phone":"%9","email":"%10","active":%13,"autoEmail":%14,"jobCreatedEmailNotifications":"%15","jobCreatedSmsNotifications":"%16","etaEmailNotifications":"%17","etaSmsNotifications":"%18","jobCompletedSmsNotifications":"%19","notes":"%20",' + L_openingHours + '}', L_Customer.Name, L_Customer.Address, L_Customer."Address 2", '', L_Customer.City, L_country, L_Customer."Post Code", L_country, L_Customer."Phone No.", L_Customer."E-Mail", L_Customer."No.", '', 'false', L_ListingStatus);

            //++++
            HeaderRequest := StrSubstNo('{"customer":%1,"name":"%2","address1":"%3","address2":"%4","address3":"%5","city":"%6","region":"%7","postcode":"%8","country":"%9",' + L_CoordinateArry
           + ',"contact":"%10","phone":"%11","email":"%12","active":%13,"autoEmail":%14,"jobCreatedEmailNotifications":%15,"jobCreatedSmsNotifications":%16,"etaEmailNotifications":%17,"etaSmsNotifications":%18,"jobCompletedSmsNotifications":%19,"notes":"%20"}', _ePODId, L_Customer."No.", L_Customer.Name, L_Customer.Address, L_Customer."Address 2", L_Customer.City, '', L_Customer."Post Code", L_country, L_Customer.Contact, L_Customer."Phone No.", L_Customer."E-Mail", L_ListingStatus, 'false', 'false', 'false', 'false', 'false', 'false', L_Customer.Comment);

        end;

        exit(HeaderRequest);
    End;


    [EventSubscriber(ObjectType::Table, Database::Customer, OnAfterValidateEvent, 'Name', false, false)]
    local procedure Name_OnAfterValidateEvent(var Rec: Record Customer; var xRec: Record Customer)
    begin
        if Rec.Name <> xRec.Name then begin
            Rec."Customer Synced" := false;
            Rec.Modify();
        end;
    end;

    [EventSubscriber(ObjectType::Table, Database::Customer, OnAfterValidateEvent, 'Address', false, false)]
    local procedure Address_OnAfterValidateEvent(var Rec: Record Customer; var xRec: Record Customer)
    begin
        if Rec.Address <> xRec.Address then begin
            Rec."Customer Synced" := false;
            Rec.Modify();
        end;
    end;

    [EventSubscriber(ObjectType::Table, Database::Customer, OnAfterValidateEvent, 'Address 2', false, false)]
    local procedure Address2_OnAfterValidateEvent(var Rec: Record Customer; var xRec: Record Customer)
    begin
        if Rec."Address 2" <> xRec."Address 2" then begin
            Rec."Customer Synced" := false;
            Rec.Modify();
        end;
    end;

    [EventSubscriber(ObjectType::Table, Database::Customer, OnAfterValidateEvent, 'City', false, false)]
    local procedure City_OnAfterValidateEvent(var Rec: Record Customer; var xRec: Record Customer)
    begin
        if Rec.City <> xRec.City then begin
            Rec."Customer Synced" := false;
            Rec.Modify();
        end;
    end;

    [EventSubscriber(ObjectType::Table, Database::Customer, OnAfterValidateEvent, 'Country/Region Code', false, false)]
    local procedure CountryRegion_OnAfterValidateEvent(var Rec: Record Customer; var xRec: Record Customer)
    begin
        if Rec."Country/Region Code" <> xRec."Country/Region Code" then begin
            Rec."Customer Synced" := false;
            Rec.Modify();
        end;
    end;

    [EventSubscriber(ObjectType::Table, Database::Customer, OnAfterValidateEvent, 'Post Code', false, false)]
    local procedure PostCode_OnAfterValidateEvent(var Rec: Record Customer; var xRec: Record Customer)
    begin
        if Rec."Post Code" <> xRec."Post Code" then begin
            Rec."Customer Synced" := false;
            Rec.Modify();
        end;
    end;

    [EventSubscriber(ObjectType::Table, Database::Customer, OnAfterValidateEvent, 'Phone No.', false, false)]
    local procedure Phone_OnAfterValidateEvent(var Rec: Record Customer; var xRec: Record Customer)
    begin
        if Rec."Phone No." <> xRec."Phone No." then begin
            Rec."Customer Synced" := false;
            Rec.Modify();
        end;
    end;

    [EventSubscriber(ObjectType::Table, Database::Customer, OnAfterValidateEvent, 'E-Mail', false, false)]
    local procedure Email_OnAfterValidateEvent(var Rec: Record Customer; var xRec: Record Customer)
    begin
        if Rec."E-Mail" <> xRec."E-Mail" then begin
            Rec."Customer Synced" := false;
            Rec.Modify();
        end;
    end;

    [EventSubscriber(ObjectType::Table, Database::Customer, OnAfterValidateEvent, 'ePOD Status', false, false)]
    local procedure ListingStatus_OnAfterValidateEvent(var Rec: Record Customer; var xRec: Record Customer)
    begin
        if Rec."ePOD Status" <> xRec."ePOD Status" then begin
            Rec."Customer Synced" := false;
            Rec.Modify();
        end;
    end;

    #EndRegion Customer & Site++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

    #Region DeliveryJob++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    procedure DeliveryJob_SynctoPOD(_SalesInvoiceNumber: Code[20]; ChannelCode: Code[10])
    var
        L_SalesInvoiceHeader: Record "Sales Invoice Header";
        L_Customer: Record Customer;
        L_ShippingAgent: Record "Shipping Agent";
        L_SalesInvoiceLine: Record "Sales Invoice Line";
        L_ePODJobHeader: Record "ePOD Job Header";
        L_ShippingAgentCode: Code[30];
        L_ShippingAgentServiceCode: Code[10];
    begin
        //Clear All Variable +++
        ClearAll();

        //Check Mandatory fields+++
        CheckMandatoryfieldForJob(ChannelCode, G_JobType::Delivery);

        #Region Start Process to sync +++
        L_SalesInvoiceHeader.Reset();
        if _SalesInvoiceNumber <> '' then
            L_SalesInvoiceHeader.SetRange("No.", _SalesInvoiceNumber);
        L_SalesInvoiceHeader.SetCurrentKey("Shipment Date");
        L_SalesInvoiceHeader.Ascending(true);
        if L_SalesInvoiceHeader.FindSet() then begin
            repeat
                //Check If Posting in Progress so Ignore to the Invoice and wait for sencond session++
                L_SalesInvoiceHeader.CalcFields("No of Boxes");
                if L_SalesInvoiceHeader."Knapp Order" = false then
                    if L_SalesInvoiceHeader."No of Boxes" = 0 then
                        break;


                //Check & Get Shipping Agents Details++
                Clear(L_ShippingAgentCode);
                Clear(L_ShippingAgentServiceCode);
                if L_SalesInvoiceHeader."Weekend Shipping Agent Code" <> '' then begin
                    L_ShippingAgentCode := L_SalesInvoiceHeader."Weekend Shipping Agent Code";
                    L_ShippingAgentServiceCode := L_SalesInvoiceHeader."Weekend Ship. Agnt. Serv. Code";
                end else begin
                    L_ShippingAgentCode := L_SalesInvoiceHeader."Shipping Agent Code";
                    L_ShippingAgentServiceCode := L_SalesInvoiceHeader."Shipping Agent Service Code";
                end;


                //Running...........................................................................
                L_SalesInvoiceLine.Reset();
                L_SalesInvoiceLine.SetRange("Document No.", L_SalesInvoiceHeader."No.");
                L_SalesInvoiceLine.SetFilter(Quantity, '>%1', 0);
                L_SalesInvoiceLine.SetRange(Type, L_SalesInvoiceLine.Type::Item);
                if L_SalesInvoiceLine.FindFirst() then begin
                    L_Customer.Reset();
                    L_Customer.SetRange("No.", L_SalesInvoiceHeader."Sell-to Customer No.");
                    if L_Customer.FindFirst() then begin
                        if (L_Customer."ePOD ID" <> 0) AND (L_Customer."Customer Site ID" <> 0) AND (L_Customer."Podfather Customer" = true) then begin
                            L_ShippingAgent.Reset();
                            L_ShippingAgent.SetRange(Code, L_ShippingAgentCode);
                            if L_ShippingAgent.FindFirst() then begin
                                if (L_ShippingAgent."Podfather Depot" = true) AND (L_ShippingAgent."ePOD ID" <> 0) then begin
                                    //Create Run details and Loding job HeaderIf not Available + + +
                                    if PostRunToePOD(L_ShippingAgentCode, L_ShippingAgentServiceCode, L_SalesInvoiceHeader."Shipment Date", ChannelCode) = true then begin
                                        //Create Job and Loading job line+++
                                        PostJobToePODNew(L_SalesInvoiceHeader, ChannelCode);
                                    end;
                                end else begin
                                    //Manage Error++
                                    if GuiAllowed = true then begin
                                        Error('Job sync failed. Error: Depot %1 is not linked with ePOD System', L_ShippingAgent.Code);
                                    end else begin
                                        InsertErrorLog(Database::"Sales Invoice Header", L_SalesInvoiceHeader."No.", StrSubstNo('Job sync failed. Error: Depot %1 is not linked with ePOD System', L_ShippingAgent.Code));
                                    end;
                                end;
                            end else begin
                                //Manage Error++
                                if GuiAllowed = true then begin
                                    Error('Job sync failed. Error: Depot %1 is not found in Shipping Agent table', L_ShippingAgent.Code);
                                end else begin
                                    InsertErrorLog(Database::"Sales Invoice Header", L_SalesInvoiceHeader."No.", StrSubstNo('Job sync failed. Error: Depot %1 is not found in Shipping Agent table', L_ShippingAgent.Code))
                                end;
                            end;
                        end else begin
                            //Manage Error++
                            if GuiAllowed = true then begin
                                Error('Job sync failed. Error: Customer %1 is not linked with ePOD System', L_Customer."No.");
                            end else begin
                                InsertErrorLog(Database::"Sales Invoice Header", L_SalesInvoiceHeader."No.", StrSubstNo('Job sync failed. Error: Customer %1 is not linked with ePOD System', L_Customer."No."))
                            end;
                        end;
                    end else begin
                        //Manage Error++
                        if GuiAllowed = true then begin
                            Error('Job sync failed. Error: Customer %1 is not found in customer table', L_Customer."No.");
                        end else begin
                            InsertErrorLog(Database::"Sales Invoice Header", L_SalesInvoiceHeader."No.", StrSubstNo('Job sync failed. Error: Customer %1 is not found in customer table', L_Customer."No."))
                        end;
                    end;
                end else begin
                    //Manage Error++
                    if GuiAllowed = true then begin
                        Error('Job sync failed. Error: Lines not exist for the Document No.: %1.', L_SalesInvoiceHeader."No.");
                    end else begin
                        InsertErrorLog(Database::"Sales Invoice Header", L_SalesInvoiceHeader."No.", StrSubstNo('Job sync failed. Error: Lines not exist for the Document No.: %1.', L_SalesInvoiceHeader."No."))
                    end;
                end;
            until L_SalesInvoiceHeader.Next() = 0;
        end else begin
            //Manage Error++
            if GuiAllowed = true then
                Error('Job sync failed. Error: Invoice not exist')
            else
                InsertErrorLog(Database::"Sales Invoice Header", '', 'Job sync failed. Error: Invoice not exist')
        end;
        #EndRegion Start Process to sync +++
    end;

    local procedure PostJobToePODNew(_SalesInvoiceHeader: Record "Sales Invoice Header"; ChannelCode: Code[10])
    var
        L_httpheaders: HttpHeaders;
        L_httpclient: HttpClient;
        L_URL: Text;
        body: Text;
        L_httpcontent: HttpContent;
        L_httpResponseMessage: HttpResponseMessage;
        jObject: JsonObject;
        JObject1: JsonObject;
        JObject2: JsonObject;
        Response: Text;
        ModificationRequired: Boolean;
        L_Status: Text;
        L_ePODJobHeader: Record "ePOD Job Header";
        SyncFailed: Boolean;

        //Collection
        Collection_httpheaders: HttpHeaders;
        Collection_httpclient: HttpClient;
        Collection_URL: Text;
        Collection_body: Text;
        Collection_httpcontent: HttpContent;
        collection_httpResponseMessage: HttpResponseMessage;
        Collection_Response: Text;
        Collection_jObject: JsonObject;
        Collection_JObject1: JsonObject;
        Collection_JObject2: JsonObject;

        //Deletion
        Deletion_httpheaders: HttpHeaders;
        Deletion_httpclient: HttpClient;
        Deletion_URL: Text;
        Deletion_httpcontent: HttpContent;
        Deletion_httpResponseMessage: HttpResponseMessage;
        Deletion_Response: Text;
        L_epodJobLine: Record "ePOD Job Line";
    begin
        //Get Credential & URL Detail +++ 
        Clear(SyncFailed);
        GetCredentials(ChannelCode);

        //++
        L_httpheaders := L_httpclient.DefaultRequestHeaders;
        L_URL := ServiceURL + 'jobs';
        L_httpheaders.Add('Accept', 'application/json');
        L_httpheaders.Add('Authorization', 'Bearer ' + SecretAccessKey);

        //Create Body for normal job+++
        Clear(body);
        body := Job_Body(_SalesInvoiceHeader."No.", ChannelCode);
        if StrLen(body) = 0 then begin
            if GuiAllowed = true then
                Error('Job sync failed Error: Job body is empty');
            exit;
        end;

        //Sync to POD +++
        L_httpcontent.WriteFrom(body);
        L_httpcontent.GetHeaders(L_httpheaders);
        L_httpheaders.Clear();
        L_httpheaders.Add('Content-Type', 'application/json');
        if L_httpclient.Post(L_URL, L_httpcontent, L_httpResponseMessage) then begin
            L_httpResponseMessage.Content.ReadAs(Response);

            //Response 201 Successful for only Normal Job+++ 
            if L_httpResponseMessage.HttpStatusCode = 201 then begin
                //Read the response in JObject+++
                JObject.ReadFrom(Response);
                JObject1 := GetJsonToken(jObject, 'job').AsObject();
                JObject2 := GetJsonToken(jObject1, 'data').AsObject();

                //Insert into epodJob list+++
                L_ePODJobHeader.Reset();
                L_ePODJobHeader.SetRange("Shipment Date", _SalesInvoiceHeader."Shipment Date");
                L_ePODJobHeader.SetRange("ePOD RunID", GetJsonvalue(JObject2, 'run').AsInteger());
                if _SalesInvoiceHeader."Weekend Shipping Agent Code" <> '' then begin
                    L_ePODJobHeader.SetRange("Shipping Agent Code", _SalesInvoiceHeader."Weekend Shipping Agent Code");
                    L_ePODJobHeader.SetRange("Shipping Agent Service Code", _SalesInvoiceHeader."Weekend Ship. Agnt. Serv. Code");
                end else begin
                    L_ePODJobHeader.SetRange("Shipping Agent Code", _SalesInvoiceHeader."Shipping Agent Code");
                    L_ePODJobHeader.SetRange("Shipping Agent Service Code", _SalesInvoiceHeader."Shipping Agent Service Code");
                end;
                if L_ePODJobHeader.FindFirst() then begin
                    //Create epod Loading job Details in BC++
                    CreateLineNew(_SalesInvoiceHeader, L_ePODJobHeader, GetJsonvalue(JObject2, 'id').AsInteger(), 0);

                    //Start syncing to podfather++
                    if L_ePODJobHeader."Synced to ePOD" = false then begin
                        //create new Loading Job in podfather 
                        SyncFailed := PostConsolidatedJobToePOD(L_ePODJobHeader."No.", ChannelCode, _SalesInvoiceHeader);
                    end else begin
                        //Update Normal Job in to existing loading job in podfather
                        SyncFailed := UpdateConsolidatedJobToePOD(L_ePODJobHeader."No.", ChannelCode, _SalesInvoiceHeader);
                    end;

                end;

                #Region Delete the normal job if Consolidation Job sync failed created in POD Father System+++
                if SyncFailed = true then begin
                    //Delete the normal job in POD Father System+++
                    L_epodJobLine.Reset();
                    L_epodJobLine.SetRange("BC Invoice Number", _SalesInvoiceHeader."No.");
                    L_epodJobLine.SetRange("Shipment Date", _SalesInvoiceHeader."Shipment Date");
                    L_epodJobLine.SetFilter("ePOD ID", '<>%1', 0);
                    if L_epodJobLine.FindFirst() then begin
                        // Delete Normal Job
                        Deletion_httpheaders := Deletion_httpclient.DefaultRequestHeaders;
                        Deletion_URL := ServiceURL + 'jobs/' + Format(L_epodJobLine."ePOD ID");
                        Deletion_httpheaders.Add('Accept', 'application/json');
                        Deletion_httpheaders.Add('Authorization', 'Bearer ' + SecretAccessKey);
                        //Deletion_httpheaders.Add('Content-Type', 'application/json');

                        if Deletion_httpclient.Delete(Deletion_URL, Deletion_httpResponseMessage) then begin
                            Deletion_httpResponseMessage.Content.ReadAs(Deletion_Response);

                            //++
                            if Deletion_httpResponseMessage.HttpStatusCode = 204 then begin
                                //Once the jobs are deleted from ePOD system. Now deleting the epod Job Line in BC++
                                L_epodJobLine.Reset();
                                L_epodJobLine.SetRange("BC Invoice Number", _SalesInvoiceHeader."No.");
                                L_epodJobLine.SetRange("Shipment Date", _SalesInvoiceHeader."Shipment Date");
                                if L_epodJobLine.FindSet() then
                                    L_epodJobLine.DeleteAll();
                            end;
                        end;
                    end;
                end;
                #EndRegion Delete the normal job if collection job sync failed created in POD Father System+++
            end else begin
                //Manage Error
                if GuiAllowed = true then begin
                    Error('Job sync failed Error: %1', Response);
                end else begin
                    InsertErrorLog(Database::"Sales Invoice Header", _SalesInvoiceHeader."No.", StrSubstNo('Job sync failed Error: %1', Response));
                end;
            end;
        end else begin
            //Manage Error
            if GuiAllowed = true then begin
                L_httpResponseMessage.Content.ReadAs(Response);
                Error('Job sync failed Error: %1', Response);
            end else begin
                L_httpResponseMessage.Content.ReadAs(Response);
                InsertErrorLog(Database::"Sales Invoice Header", _SalesInvoiceHeader."No.", StrSubstNo('Job sync failed Error: %1', Response));
            end;
        end;
    end;

    local procedure Job_Body(_SalesInvoiceNumber: Code[20]; _ChannelCode: Code[50]): Text
    var
        L_SalesInvoiceHeader: Record "Sales Invoice Header";
        L_Customer: Record Customer;
        L_CustomerSiteID: Integer;
        L_CustomerePODID: Integer;
        L_Location: Record Location;
        L_LocationePODID: Integer;
        L_TemplateID: Integer;
        TradePartner: Record "Trade Partner";
        L_SalesInvoiceLine: Record "Sales Invoice Line";
        JsonObj: JsonObject;
        JsonValue: JsonValue;
        LinesArray: JsonArray;
        LineObj: JsonObject;
        FieldObj: JsonObject;
        FinalTextRequest: Text;
        L_Hour: Code[20];
        L_Minut: Code[20];
        L_Second: Code[20];
        L_finalStartDate: Text;
        L_finalEndDate: Text;
        L_Date: Text;
        L_Time: Text;
        L_ePODRunID: Integer;
        L_DropNumber: Integer;
        L_KnappOrderResponse: Record "Knapp Order Response";
        L_ItemReference: Record "Item Reference";
        L_ToteNo: Code[20];
        L_NoOfBox: Integer;
        L_ValueEntry: Record "Value Entry";
        L_ItemLedgEntry: Record "Item Ledger Entry";
        L_SalesShipmentHeader: Record "Sales Shipment Header";
        L_ShippingAgent: Record "Shipping Agent";
        L_Group: Text;
        L_Item: Record Item;
        L_WarhouseClass: Record "Warehouse Class";
        ShippingAgentCodeFilter: Code[20];
        ShippingAgentServiceCodeFilter: Code[20];
        L_ePODJobHeader: Record "ePOD Job Header";
    begin
        L_SalesInvoiceHeader.Reset();
        L_SalesInvoiceHeader.SetRange("No.", _SalesInvoiceNumber);
        if L_SalesInvoiceHeader.FindFirst() then begin
            L_SalesInvoiceHeader.CalcFields(Amount, "Weekend Drop Number", "Drop Number", "No of Boxes");

            //Get Site++
            Clear(L_CustomerSiteID);
            Clear(L_CustomerePODID);
            L_Customer.Reset();
            L_Customer.SetRange("No.", L_SalesInvoiceHeader."Sell-to Customer No.");
            if L_Customer.FindFirst() then begin
                L_CustomerePODID := L_Customer."ePOD ID";
                L_CustomerSiteID := L_Customer."Customer Site ID";
            end;

            //Get Depot ID+++
            Clear(L_LocationePODID);
            if L_SalesInvoiceHeader."Weekend Shipping Agent Code" <> '' then begin
                L_ShippingAgent.Reset();
                L_ShippingAgent.SetRange(Code, L_SalesInvoiceHeader."Weekend Shipping Agent Code");
                if L_ShippingAgent.FindFirst() then begin
                    L_LocationePODID := L_ShippingAgent."ePOD ID";
                end;
            end else begin
                L_ShippingAgent.Reset();
                L_ShippingAgent.SetRange(Code, L_SalesInvoiceHeader."Shipping Agent Code");
                if L_ShippingAgent.FindFirst() then begin
                    L_LocationePODID := L_ShippingAgent."ePOD ID";
                end;
            end;


            //Get Teplate ID
            Clear(L_TemplateID);
            TradePartner.RESET;
            if TradePartner.Get(_ChannelCode) then begin
                L_TemplateID := TradePartner."ePOD Template ID";
            end;

            //Get the start Date+++
            //Get Date+++
            Clear(L_Date);
            L_Date := Format(L_SalesInvoiceHeader."Shipment Date", 0, '<Year4>-<Month,2>-<Day,2>');

            Clear(L_Hour);
            L_Hour := Format(9);
            if StrLen(Format(L_Hour)) = 1 then
                L_Hour := '0' + L_Hour;

            Clear(L_Minut);
            L_Minut := Format(00);
            if StrLen(Format(L_Minut)) = 1 then
                L_Minut := '0' + L_Minut;

            Clear(L_Second);
            L_Second := Format(0);
            if StrLen(Format(L_Second)) = 1 then
                L_Second := '0' + L_Second;

            Clear(L_finalStartDate);
            //L_finalStartDate := Format(L_Date) + 'T' + Format(L_Hour) + ':' + Format(L_Minut) + ':' + Format(L_Second) + 'Z';
            L_finalStartDate := Format(L_Date) + 'T' + Format(L_Hour) + ':' + Format(L_Minut) + ':' + Format(L_Second) + '+01:00';


            //Get the End Date+++
            //Get Date+++
            Clear(L_Date);
            L_Date := Format(L_SalesInvoiceHeader."Shipment Date", 0, '<Year4>-<Month,2>-<Day,2>');

            Clear(L_Hour);
            L_Hour := Format(17);
            if StrLen(Format(L_Hour)) = 1 then
                L_Hour := '0' + L_Hour;

            Clear(L_Minut);
            L_Minut := Format(00);
            if StrLen(Format(L_Minut)) = 1 then
                L_Minut := '0' + L_Minut;

            Clear(L_Second);
            L_Second := Format(0);
            if StrLen(Format(L_Second)) = 1 then
                L_Second := '0' + L_Second;

            Clear(L_finalEndDate);
            //L_finalEndDate := Format(L_Date) + 'T' + Format(L_Hour) + ':' + Format(L_Minut) + ':' + Format(L_Second) + 'Z';
            L_finalEndDate := Format(L_Date) + 'T' + Format(L_Hour) + ':' + Format(L_Minut) + ':' + Format(L_Second) + '+01:00';

            //Get RunID+++
            Clear(L_ePODRunID);
            Clear(ShippingAgentCodeFilter);
            Clear(ShippingAgentServiceCodeFilter);
            IF L_SalesInvoiceHeader."Weekend Shipping Agent Code" <> '' then begin
                ShippingAgentCodeFilter := L_SalesInvoiceHeader."Weekend Shipping Agent Code";
                ShippingAgentServiceCodeFilter := L_SalesInvoiceHeader."Weekend Ship. Agnt. Serv. Code";
            end ELSE begin
                ShippingAgentCodeFilter := L_SalesInvoiceHeader."Shipping Agent Code";
                ShippingAgentServiceCodeFilter := L_SalesInvoiceHeader."Shipping Agent Service Code";
            end;
            L_ePODJobHeader.Reset();
            L_ePODJobHeader.SetRange("Shipment Date", L_SalesInvoiceHeader."Shipment Date");
            L_ePODJobHeader.SetRange("Shipping Agent Code", ShippingAgentCodeFilter);
            L_ePODJobHeader.SetRange("Shipping Agent Service Code", ShippingAgentServiceCodeFilter);
            if L_ePODJobHeader.FindFirst() then
                L_ePODRunID := L_ePODJobHeader."ePOD RunID";

            //Get Drop Number+++
            Clear(L_DropNumber);
            IF L_SalesInvoiceHeader."Weekend Shipping Agent Code" <> '' then begin
                if L_SalesInvoiceHeader."Weekend Drop Number" <> '' then
                    Evaluate(L_DropNumber, L_SalesInvoiceHeader."Weekend Drop Number")
                else
                    L_DropNumber := 0;
            end else begin
                if L_SalesInvoiceHeader."Drop Number" <> '' then
                    Evaluate(L_DropNumber, L_SalesInvoiceHeader."Drop Number")
                else
                    L_DropNumber := 0;
            end;
            if L_DropNumber = 0 then
                L_DropNumber := 0001;

            //Check Mandatory fields++
            if (L_CustomerSiteID = 0) AND (L_CustomerePODID = 0) AND (L_LocationePODID = 0) AND (L_TemplateID = 0) AND (L_SalesInvoiceHeader."Shipment Date" = 0D) AND (L_ePODRunID = 0) AND (L_DropNumber = 0) then
                exit('');


            //Create Header++
            Clear(JsonObj);
            Clear(JsonValue);
            JsonObj.Add('site', L_CustomerSiteID);
            JsonObj.Add('customer', L_CustomerePODID);
            JsonObj.Add('depot', L_LocationePODID);
            JsonObj.Add('template', L_TemplateID);
            JsonObj.Add('run', L_ePODRunID);
            JsonObj.Add('dueByStart', L_finalStartDate);
            JsonObj.Add('dueBy', L_finalEndDate);
            JsonObj.Add('instructions1', L_SalesInvoiceHeader.GetWorkDescription());
            JsonObj.Add('instructions2', L_SalesInvoiceHeader.GetWorkDescription());
            JsonObj.Add('provisional', true);
            JsonObj.Add('dropTime', 7);
            JsonObj.Add('dropSequence', L_DropNumber);
            JsonObj.Add('price', L_SalesInvoiceHeader.Amount);

            //Create Fields Object++
            Clear(FieldObj);
            JsonObj.Add('fields', FieldObj);
            FieldObj.Add('Customer PO', L_SalesInvoiceHeader."No.");
            FieldObj.Add('Internal Job Ref', L_SalesInvoiceHeader."Order No.");


            //Create Line++++
            Clear(L_ToteNo);
            L_Location.Reset();
            L_Location.SetRange(Code, L_SalesInvoiceHeader."Location Code");
            if L_Location.FindFirst() then begin
                if L_Location."Knapp Location" = false then begin
                    // //Item lines For Non-KNAPP Orders+++++++
                    // Clear(LinesArray);
                    // Clear(LineObj);
                    // L_SalesInvoiceLine.Reset();
                    // L_SalesInvoiceLine.SetRange("Document No.", L_SalesInvoiceHeader."No.");
                    // L_SalesInvoiceLine.SetFilter(Quantity, '>%1', 0);
                    // L_SalesInvoiceLine.SetRange(Type, L_SalesInvoiceLine.Type::Item);
                    // if L_SalesInvoiceLine.FindSet() then begin
                    //     JsonObj.Add('items', LinesArray);
                    //     repeat
                    //         Clear(LineObj);
                    //         LineObj.Add('name', 'Box');
                    //         LineObj.Add('merchGroup', 'Box');
                    //         LineObj.Add('productCode', L_SalesInvoiceLine."No.");
                    //         LineObj.Add('price', L_SalesInvoiceLine."Amount Including VAT");
                    //         LineObj.Add('weight', L_SalesInvoiceLine."Gross Weight");
                    //         LineObj.Add('quantity', L_SalesInvoiceLine.Quantity);
                    //         LineObj.Add('qtyDecimalPlaces', 1);
                    //         L_ItemReference.Reset();
                    //         L_ItemReference.SetRange("Reference Type", L_ItemReference."Reference Type"::"Bar Code");
                    //         L_ItemReference.SetRange("Item No.", L_SalesInvoiceLine."No.");
                    //         if L_ItemReference.FindFirst() then
                    //             LineObj.Add('productBarcode', L_ItemReference."Reference No.")
                    //         else
                    //             LineObj.Add('productBarcode', ',');
                    //         LinesArray.Add(LineObj);
                    //     until L_SalesInvoiceLine.Next() = 0;
                    // end else
                    //     Error('No sales invoice line found');

                    #region New Code+++
                    //Item lines For Non-KNAPP Orders+++++++
                    Clear(LinesArray);
                    Clear(LineObj);
                    L_SalesInvoiceLine.Reset();
                    L_SalesInvoiceLine.SetRange("Document No.", L_SalesInvoiceHeader."No.");
                    L_SalesInvoiceLine.SetFilter(Quantity, '>%1', 0);
                    L_SalesInvoiceLine.SetRange(Type, L_SalesInvoiceLine.Type::Item);
                    if L_SalesInvoiceLine.FindFirst() then begin
                        // //Get No of Box++
                        // Clear(L_NoOfBox);
                        // L_SalesShipmentHeader.Reset();
                        // L_SalesShipmentHeader.SetRange("Inv. Pick No.", L_SalesInvoiceHeader."Inv. Pick No.");
                        // if L_SalesShipmentHeader.FindFirst() then begin
                        //     L_NoOfBox := L_SalesShipmentHeader."No of Boxes";
                        // end;

                        //  Clear(L_NoOfBox);
                        // L_ValueEntry.Reset();
                        // L_ValueEntry.SetCurrentKey("Document No.");
                        // L_ValueEntry.SetRange("Document No.", L_SalesInvoiceLine."Document No.");
                        // L_ValueEntry.SetRange("Document Type", L_ValueEntry."Document Type"::"Sales Invoice");
                        // L_ValueEntry.SetRange("Document Line No.", L_SalesInvoiceLine."Line No.");
                        // if L_ValueEntry.FindFirst() then begin
                        //     repeat
                        //         if L_NoOfBox <> 0 then
                        //             break;
                        //         L_ItemLedgEntry.Get(L_ValueEntry."Item Ledger Entry No.");
                        //         if L_ItemLedgEntry."Document Type" = L_ItemLedgEntry."Document Type"::"Sales Shipment" then
                        //             if L_SalesShipmentHeader.Get(L_ItemLedgEntry."Document No.") then begin
                        //                 L_NoOfBox := L_SalesShipmentHeader."No of Boxes";
                        //             end;
                        //     until L_ValueEntry.Next() = 0;
                        // end;


                        //Get Group++
                        Clear(L_Group);
                        L_Item.Reset();
                        L_Item.SetRange("No.", L_SalesInvoiceLine."No.");
                        if L_Item.FindFirst() then begin
                            L_WarhouseClass.Reset();
                            L_WarhouseClass.SetRange(Code, L_Item."Warehouse Class Code");
                            if L_WarhouseClass.FindFirst() then begin
                                if L_WarhouseClass.Fridge = true then
                                    L_Group := 'CC';

                                if L_WarhouseClass.CD = true then
                                    L_Group := 'SFCD';

                                if L_WarhouseClass.Specials = true then
                                    L_Group := 'Specials';

                                if (L_WarhouseClass.Fridge = false) AND (L_WarhouseClass.CD = false) AND (L_WarhouseClass.Specials = false) then
                                    L_Group := 'Box';
                            end else
                                L_Group := 'Box'
                        end;

                        JsonObj.Add('items', LinesArray);
                        Clear(LineObj);
                        LineObj.Add('name', L_Group);
                        LineObj.Add('merchGroup', L_Group);
                        LineObj.Add('productCode', L_SalesInvoiceHeader."Order No.");
                        LineObj.Add('price', 0);
                        LineObj.Add('weight', 0);
                        LineObj.Add('quantity', L_SalesInvoiceHeader."No of Boxes");
                        LineObj.Add('qtyDecimalPlaces', 1);
                        LineObj.Add('productBarcode', L_SalesInvoiceHeader."Order No.");
                        LinesArray.Add(LineObj);
                    end else
                        Error('No sales invoice line found');
                    #Endregion New Code+++
                end else begin
                    // //Item lines for KNAPP Orders+++++++
                    // Clear(LinesArray);
                    // Clear(LineObj);
                    // L_SalesInvoiceLine.Reset();
                    // L_SalesInvoiceLine.SetRange("Document No.", L_SalesInvoiceHeader."No.");
                    // L_SalesInvoiceLine.SetFilter(Quantity, '>%1', 0);
                    // L_SalesInvoiceLine.SetRange(Type, L_SalesInvoiceLine.Type::Item);
                    // if L_SalesInvoiceLine.FindSet() then begin
                    //     JsonObj.Add('items', LinesArray);
                    //     repeat
                    //         Clear(LineObj);
                    //         LineObj.Add('name', L_SalesInvoiceLine.Description);
                    //         LineObj.Add('merchGroup', 'Item');
                    //         LineObj.Add('productCode', L_SalesInvoiceLine."No.");
                    //         LineObj.Add('price', L_SalesInvoiceLine."Amount Including VAT");
                    //         LineObj.Add('weight', L_SalesInvoiceLine."Gross Weight");
                    //         LineObj.Add('quantity', L_SalesInvoiceLine.Quantity);
                    //         LineObj.Add('qtyDecimalPlaces', 1);
                    //         L_ItemReference.Reset();
                    //         L_ItemReference.SetRange("Reference Type", L_ItemReference."Reference Type"::"Bar Code");
                    //         L_ItemReference.SetRange("Item No.", L_SalesInvoiceLine."No.");
                    //         if L_ItemReference.FindFirst() then
                    //             LineObj.Add('productBarcode', L_ItemReference."Reference No.")
                    //         else
                    //             LineObj.Add('productBarcode', ',');
                    //         LinesArray.Add(LineObj);
                    //     until L_SalesInvoiceLine.Next() = 0;
                    // end else
                    //     Error('No sales invoice line found');


                    // //Tote Lines KNAPP Orders+++++++++++++++
                    // Clear(L_ToteNo);
                    // L_SalesInvoiceLine.Reset();
                    // L_SalesInvoiceLine.SetRange("Document No.", L_SalesInvoiceHeader."No.");
                    // L_SalesInvoiceLine.SetFilter(Quantity, '>%1', 0);
                    // L_SalesInvoiceLine.SetRange(Type, L_SalesInvoiceLine.Type::Item);
                    // if L_SalesInvoiceLine.FindFirst() then begin //Only For Get the Sale order number++
                    //     L_KnappOrderResponse.Reset();
                    //     L_KnappOrderResponse.SetRange("Document Type", L_KnappOrderResponse."Document Type"::Order);
                    //     L_KnappOrderResponse.SetRange("Document No.", L_SalesInvoiceLine."Order No.");
                    //     // L_KnappOrderResponse.SetRange("Line No.", L_SalesInvoiceLine."Order Line No.");
                    //     // L_KnappOrderResponse.SetRange("Item No.", L_SalesInvoiceLine."No.");
                    //     L_KnappOrderResponse.SetCurrentKey("Load Unit");
                    //     L_KnappOrderResponse.Ascending(true);
                    //     if L_KnappOrderResponse.FindSet() then begin
                    //         repeat
                    //             if L_ToteNo <> L_KnappOrderResponse."Load Unit" then begin
                    //                 Clear(LineObj);
                    //                 LineObj.Add('name', 'TOTE');
                    //                 LineObj.Add('merchGroup', 'Tote');
                    //                 LineObj.Add('productCode', L_KnappOrderResponse."Load Unit");
                    //                 LineObj.Add('price', 0);
                    //                 LineObj.Add('weight', 0);
                    //                 LineObj.Add('quantity', 1);
                    //                 LineObj.Add('qtyDecimalPlaces', 1);
                    //                 LineObj.Add('productBarcode', L_KnappOrderResponse."Load Unit");
                    //                 LinesArray.Add(LineObj);
                    //             end;
                    //             L_ToteNo := L_KnappOrderResponse."Load Unit";
                    //         until L_KnappOrderResponse.Next() = 0;
                    //     end else
                    //         Error('No sales invoice line found');
                    // end;


                    #Region New code+++
                    //Item lines for KNAPP Orders+++++++
                    Clear(LinesArray);
                    Clear(LineObj);
                    L_SalesInvoiceLine.Reset();
                    L_SalesInvoiceLine.SetRange("Document No.", L_SalesInvoiceHeader."No.");
                    L_SalesInvoiceLine.SetFilter(Quantity, '>%1', 0);
                    L_SalesInvoiceLine.SetRange(Type, L_SalesInvoiceLine.Type::Item);
                    if L_SalesInvoiceLine.FindFirst() then begin
                        JsonObj.Add('items', LinesArray);

                        //Tote Lines KNAPP Orders+++++++++++++++
                        Clear(L_ToteNo);
                        L_KnappOrderResponse.Reset();
                        L_KnappOrderResponse.SetRange("Document Type", L_KnappOrderResponse."Document Type"::Order);
                        L_KnappOrderResponse.SetRange("Document No.", L_SalesInvoiceLine."Order No.");
                        L_KnappOrderResponse.SetFilter(Quantity, '<>%1', 0);
                        L_KnappOrderResponse.SetCurrentKey("Load Unit");
                        L_KnappOrderResponse.Ascending(true);
                        if L_KnappOrderResponse.FindSet() then begin
                            repeat
                                if L_ToteNo <> L_KnappOrderResponse."Load Unit" then begin
                                    Clear(LineObj);
                                    LineObj.Add('name', 'TOTE');
                                    LineObj.Add('merchGroup', 'TOTE');
                                    LineObj.Add('productCode', L_KnappOrderResponse."Load Unit");
                                    LineObj.Add('price', 0);
                                    LineObj.Add('weight', 0);
                                    LineObj.Add('quantity', 1);
                                    LineObj.Add('qtyDecimalPlaces', 1);
                                    LineObj.Add('productBarcode', L_KnappOrderResponse."Load Unit");
                                    LinesArray.Add(LineObj);
                                end;
                                L_ToteNo := L_KnappOrderResponse."Load Unit";
                            until L_KnappOrderResponse.Next() = 0;
                        end else
                            Error('No sales invoice line found');

                    end else
                        Error('No sales invoice line found');
                    #EndRegion New Code+++
                end;
            end;

            Clear(FinalTextRequest);
            JsonObj.WriteTo(FinalTextRequest);
            exit(FinalTextRequest)
        end;
    End;

    procedure CheckDeleteJobinPODFather(_ePODID: Integer; _ChannelCode: Code[50]): Boolean
    var
        L_httpheaders: HttpHeaders;
        L_httpclient: HttpClient;
        L_URL: Text;
        body: Text;
        L_httpcontent: HttpContent;
        L_httpResponseMessage: HttpResponseMessage;
        jObject: JsonObject;
        JObject1: JsonObject;
        //JObject2: JsonObject;
        Response: Text;
        ModificationRequired: Boolean;
        L_Status: Text;
    begin
        //Clear All Variable +++
        ClearAll();

        //Check Mandatory fields+++
        CheckMandatoryfieldForJob(_ChannelCode, G_JobType::Delivery);

        //Get Credential & URL Detail +++ 
        GetCredentials(_ChannelCode);

        L_httpheaders := L_httpclient.DefaultRequestHeaders;
        L_URL := ServiceURL + 'jobs/' + Format(_ePODID);
        L_httpheaders.Add('Accept', 'application/json');
        L_httpheaders.Add('Authorization', 'Bearer ' + SecretAccessKey);

        if L_httpclient.Get(L_URL, L_httpResponseMessage) then begin
            L_httpResponseMessage.Content.ReadAs(Response);

            //Response 200 means Successful+++ 
            if L_httpResponseMessage.HttpStatusCode = 200 then begin
                //Read the response in JObject+++
                JObject.ReadFrom(Response);
                JObject1 := GetJsonToken(jObject, 'data').AsObject();
                //JObject2 := GetJsonToken(jObject1, 'data').AsObject();

                //Get ePOD Status+++
                Clear(L_Status);
                L_Status := GetJsonvalue(JObject1, 'status').AsText();
                if GetJsonvalue(JObject1, 'status').AsText() = 'deleted' then
                    exit(true)
                else
                    exit(false);
            end else
                exit(true); // It mean Job Is not avaible in POD so let sysntem delete the Loading job++
        end else begin
            Error('Not able to proceed. Please check with Admin');
            //exit(true); // It mean Job Is not avaible in POD so let sysntem delete the Loading job++
        end;
    end;

    procedure UpdateStatus_PostedsalesInvoiceHeader(_InvoiceNumber: Code[20])
    var
        L_PostedSalesInvoiceHeader: Record "Sales Invoice Header";
    begin
        L_PostedSalesInvoiceHeader.Reset();
        L_PostedSalesInvoiceHeader.SetRange("No.", _InvoiceNumber);
        if L_PostedSalesInvoiceHeader.FindFirst() then begin
            L_PostedSalesInvoiceHeader."ePOD Status" := L_PostedSalesInvoiceHeader."ePOD Status"::" ";
            L_PostedSalesInvoiceHeader.Modify();
        end;
    end;

    procedure OpenRequestPageForePODjobSync()
    var
        OrderFilter: Record "Sync ePODJob Table" temporary;
        Windows: Dialog;
        L_SalesInvoiceHeader: Record "Sales Invoice Header";
        ProgressCount: Integer;
        NoOfRecs: Integer;
        Count: Integer;
        AgentCode: Code[10];
        AgentServiceCode: Code[100];
    begin
        #Region Creating a Temporary Entry for Filter Popup Page
        OrderFilter.DeleteAll();
        OrderFilter.Init();
        OrderFilter."Primary key" := 'ePOD';
        OrderFilter."Shipment Date" := 0D;
        OrderFilter."Shipping Agent Code" := '';
        OrderFilter."Shipping Agent Service Code" := '';
        OrderFilter."Customer Sync" := true;
        OrderFilter."Route Sync" := true;
        OrderFilter.Insert();
        #endregion

        //Clear Variable++
        Clear(ProgressCount);
        Clear(NoOfRecs);

        if Page.RunModal(90048, OrderFilter) = Action::LookupOK then begin
            //Check Shipment Date value++
            if OrderFilter."Shipment Date" = 0D then
                Error('Shipment Date should not be blank');

            #Region Check Shipping details++++
            if OrderFilter."Weekend Shipping Agent Code" = '' then begin
                if OrderFilter."Shipping Agent Code" = '' then
                    Error('Please choose a valid Shipping Agent Code');
                if OrderFilter."Shipping Agent Service Code" = '' then
                    Error('Please choose a valid Shipping Agent Service Code');
            end else begin
                if OrderFilter."Weekend Shipping Agent Code" = '' then
                    Error('Please choose a valid Weekend Shipping Agent Code');
                if OrderFilter."Weekend Shipping Service Code" = '' then
                    Error('Please choose a valid Weekend Shipping Agent Service Code');
            end;
            #EndRegion Check Shipping details++++


            //Confirmation message before process++
            Clear(AgentCode);
            Clear(AgentServiceCode);
            if OrderFilter."Weekend Shipping Agent Code" = '' then begin
                AgentCode := OrderFilter."Shipping Agent Code";
                AgentServiceCode := OrderFilter."Shipping Agent Service Code"
            end else begin
                AgentCode := OrderFilter."Weekend Shipping Agent Code";
                AgentServiceCode := OrderFilter."Weekend Shipping Service Code";
            end;
            if Confirm(StrSubstNo('You have selected Shipment Date "%1" and Agent Code "%2" and Agent Service Code "%3". Are you sure you want to continue?', OrderFilter."Shipment Date", AgentCode, AgentServiceCode)) then begin
                Windows.OPEN('Generating Orders..' + ' @1@@@@@@@@@@@@@\' + 'Please Wait..');

                Clear(L_SalesInvoiceHeader);
                L_SalesInvoiceHeader.Reset();
                L_SalesInvoiceHeader.SetRange("Shipment Date", OrderFilter."Shipment Date");
                L_SalesInvoiceHeader.SetRange("Customer Synced", OrderFilter."Customer Sync");
                L_SalesInvoiceHeader.SetRange("Route Synced", OrderFilter."Route Sync");
                L_SalesInvoiceHeader.SetRange("ePOD Sync", false);
                if OrderFilter."Weekend Shipping Agent Code" <> '' then begin
                    L_SalesInvoiceHeader.SetRange("Weekend Shipping Agent Code", OrderFilter."Weekend Shipping Agent Code");
                    L_SalesInvoiceHeader.SetFilter("Weekend Ship. Agnt. Serv. Code", OrderFilter."Weekend Shipping Service Code");
                end else begin
                    L_SalesInvoiceHeader.SetRange("Shipping Agent Code", OrderFilter."Shipping Agent Code");
                    L_SalesInvoiceHeader.SetFilter("Shipping Agent Service Code", OrderFilter."Shipping Agent Service Code");
                end;
                if L_SalesInvoiceHeader.FindSet() then begin
                    NoOfRecs := L_SalesInvoiceHeader.Count;
                    repeat
                        ProgressCount += 1;
                        if NoOfRecs > 0 then begin
                            if NoOfRecs <= 100 then begin
                                Windows.UPDATE(1, (ProgressCount / NoOfRecs * 10000) DIV 1)
                            end else begin
                                IF Count MOD (NoOfRecs DIV 100) = 0 THEN BEGIN
                                    Windows.UPDATE(1, (ProgressCount / NoOfRecs * 10000) DIV 1)
                                END;
                            end;
                        end;

                        //Process to sync job
                        DeliveryJob_SynctoPOD(L_SalesInvoiceHeader."No.", 'EPOD')
                    until L_SalesInvoiceHeader.Next() = 0;

                    //Final Message++
                    Message('Process Completed..');
                end;
            end;
        end;
    end;

    local procedure CreateLineNew(_InvoiceHeader: Record "Sales Invoice Header"; _ePODJobHeader: Record "ePOD Job Header"; _ePODID: Integer; _ePODIDForCollection: Integer)
    var
        L_ePODRunHeader: Record "ePOD Job Header";
        L_ePODRunLine: Record "ePOD Job Line";
        L_Location: Record Location;
        L_SalesInvoiceLine: Record "Sales Invoice Line";
        L_NoOfBox: Integer;
        L_ValueEntry: Record "Value Entry";
        L_ItemLedgEntry: Record "Item Ledger Entry";
        L_SalesShipmentHeader: Record "Sales Shipment Header";
        Last_ePODRunLine: Record "ePOD Job Line";
        L_KnappOrderResponse: Record "Knapp Order Response";
        L_ItemReference: Record "Item Reference";
        L_ToteNo: Code[20];
        L_Group: Text;
        L_Item: Record Item;
        L_WarhouseClass: Record "Warehouse Class";
    begin
        //Create Line++
        Clear(L_Group);
        L_ePODRunHeader.Reset();
        L_ePODRunHeader.SetRange("No.", _ePODJobHeader."No.");
        if L_ePODRunHeader.FindFirst() then begin
            L_Location.Reset();
            L_Location.SetRange(Code, _InvoiceHeader."Location Code");
            if L_Location.FindFirst() then begin
                //For Non KNAPP Lines+++
                if L_Location."Knapp Location" = false then begin
                    L_SalesInvoiceLine.Reset();
                    L_SalesInvoiceLine.SetRange("Document No.", _InvoiceHeader."No.");
                    L_SalesInvoiceLine.SetFilter(Quantity, '>%1', 0);
                    L_SalesInvoiceLine.SetRange(Type, L_SalesInvoiceLine.Type::Item);
                    if L_SalesInvoiceLine.FindFirst() then begin
                        //Get Group++
                        Clear(L_Group);
                        L_Item.Reset();
                        L_Item.SetRange("No.", L_SalesInvoiceLine."No.");
                        if L_Item.FindFirst() then begin
                            L_WarhouseClass.Reset();
                            L_WarhouseClass.SetRange(Code, L_Item."Warehouse Class Code");
                            if L_WarhouseClass.FindFirst() then begin
                                if L_WarhouseClass.Fridge = true then
                                    L_Group := '3CC';

                                if L_WarhouseClass.CD = true then
                                    L_Group := '4SFCD';

                                if L_WarhouseClass.Specials = true then
                                    L_Group := '5Specials';

                                if (L_WarhouseClass.Fridge = false) AND (L_WarhouseClass.CD = false) AND (L_WarhouseClass.Specials = false) then
                                    L_Group := '2Box';
                            end else
                                L_Group := '2Box'
                        end;


                        //Get No of Box++
                        // Clear(L_NoOfBox);
                        // L_SalesShipmentHeader.Reset();
                        // L_SalesShipmentHeader.SetRange("Inv. Pick No.", _InvoiceHeader."Inv. Pick No.");
                        // if L_SalesShipmentHeader.FindFirst() then begin
                        //     L_NoOfBox := L_SalesShipmentHeader."No of Boxes";
                        // end;
                        // Clear(L_NoOfBox);
                        // L_ValueEntry.Reset();
                        // L_ValueEntry.SetCurrentKey("Document No.");
                        // L_ValueEntry.SetRange("Document No.", L_SalesInvoiceLine."Document No.");
                        // L_ValueEntry.SetRange("Document Type", L_ValueEntry."Document Type"::"Sales Invoice");
                        // L_ValueEntry.SetRange("Document Line No.", L_SalesInvoiceLine."Line No.");
                        // if L_ValueEntry.FindFirst() then begin
                        //     repeat
                        //         if L_NoOfBox <> 0 then
                        //             break;
                        //         L_ItemLedgEntry.Get(L_ValueEntry."Item Ledger Entry No.");
                        //         if L_ItemLedgEntry."Document Type" = L_ItemLedgEntry."Document Type"::"Sales Shipment" then
                        //             if L_SalesShipmentHeader.Get(L_ItemLedgEntry."Document No.") then begin
                        //                 L_NoOfBox := L_SalesShipmentHeader."No of Boxes";
                        //             end;
                        //     until L_ValueEntry.Next() = 0;
                        // end;

                        //++
                        L_ePODRunLine.Init();
                        L_ePODRunLine."Document No." := L_ePODRunHeader."No.";
                        L_ePODRunLine."ePOD RunID" := L_ePODRunHeader."ePOD RunID";
                        Last_ePODRunLine.Reset();
                        Last_ePODRunLine.SetRange("ePOD RunID", L_ePODRunHeader."ePOD RunID");
                        Last_ePODRunLine.SetRange("Shipment Date", L_ePODRunHeader."Shipment Date");
                        if Last_ePODRunLine.FindLast() then
                            L_ePODRunLine."Line Number" := Last_ePODRunLine."Line Number" + 10000
                        else
                            L_ePODRunLine."Line Number" := 10000;

                        L_ePODRunLine."Customer PO" := 'SIGMA';
                        L_ePODRunLine."Shipping Agent Code" := L_ePODRunHeader."Shipping Agent Code";
                        L_ePODRunLine."Shipping Agent Service Code" := L_ePODRunHeader."Shipping Agent Service Code";
                        L_ePODRunLine."Shipment Date" := L_ePODRunHeader."Shipment Date";
                        L_ePODRunLine."BC Invoice Number" := _InvoiceHeader."No.";
                        L_ePODRunLine.Group := L_Group;
                        L_ePODRunLine."Product Code" := _InvoiceHeader."Order No.";
                        L_ePODRunLine.Description := L_Group;
                        _InvoiceHeader.CalcFields("No of Boxes");
                        L_ePODRunLine.Quantity := _InvoiceHeader."No of Boxes";
                        L_ePODRunLine."ePOD ID" := _ePODID;
                        L_ePODRunLine."Collection ePOD ID" := _ePODIDForCollection;
                        L_ePODRunLine."Synced to ePOD" := true;
                        L_ePODRunLine."Job Type" := L_ePODRunLine."Job Type"::Delivery;
                        L_ePODRunLine.Insert();
                    end;
                end else begin
                    //For KNAPP lines+++
                    L_SalesInvoiceLine.Reset();
                    L_SalesInvoiceLine.SetRange("Document No.", _InvoiceHeader."No.");
                    L_SalesInvoiceLine.SetFilter(Quantity, '>%1', 0);
                    L_SalesInvoiceLine.SetRange(Type, L_SalesInvoiceLine.Type::Item);
                    if L_SalesInvoiceLine.FindFirst() then begin
                        Clear(L_ToteNo);
                        L_KnappOrderResponse.Reset();
                        L_KnappOrderResponse.SetRange("Document Type", L_KnappOrderResponse."Document Type"::Order);
                        L_KnappOrderResponse.SetRange("Document No.", L_SalesInvoiceLine."Order No.");
                        L_KnappOrderResponse.SetFilter(Quantity, '<>%1', 0);
                        L_KnappOrderResponse.SetCurrentKey("Load Unit");
                        L_KnappOrderResponse.Ascending(true);
                        if L_KnappOrderResponse.FindSet() then begin
                            repeat
                                if L_ToteNo <> L_KnappOrderResponse."Load Unit" then begin
                                    L_ePODRunLine.Init();
                                    L_ePODRunLine."Document No." := L_ePODRunHeader."No.";
                                    L_ePODRunLine."ePOD RunID" := L_ePODRunHeader."ePOD RunID";
                                    Last_ePODRunLine.Reset();
                                    Last_ePODRunLine.SetRange("ePOD RunID", L_ePODRunHeader."ePOD RunID");
                                    Last_ePODRunLine.SetRange("Shipment Date", L_ePODRunHeader."Shipment Date");
                                    if Last_ePODRunLine.FindLast() then
                                        L_ePODRunLine."Line Number" := Last_ePODRunLine."Line Number" + 10000
                                    else
                                        L_ePODRunLine."Line Number" := 10000;

                                    L_ePODRunLine."Customer PO" := 'SIGMA';
                                    L_ePODRunLine."Shipping Agent Code" := L_ePODRunHeader."Shipping Agent Code";
                                    L_ePODRunLine."Shipping Agent Service Code" := L_ePODRunHeader."Shipping Agent Service Code";
                                    L_ePODRunLine."Shipment Date" := L_ePODRunHeader."Shipment Date";
                                    L_ePODRunLine."BC Invoice Number" := _InvoiceHeader."No.";
                                    L_ePODRunLine.Group := '1TOTE';
                                    L_ePODRunLine."Product Code" := L_KnappOrderResponse."Load Unit";
                                    L_ePODRunLine.Description := '1TOTE';
                                    L_ePODRunLine.Quantity := 1;
                                    L_ePODRunLine."ePOD ID" := _ePODID;
                                    L_ePODRunLine."Collection ePOD ID" := _ePODIDForCollection;
                                    L_ePODRunLine."Synced to ePOD" := true;
                                    L_ePODRunLine."Job Type" := L_ePODRunLine."Job Type"::Delivery;
                                    L_ePODRunLine.Insert();
                                end;
                                L_ToteNo := L_KnappOrderResponse."Load Unit";
                            until L_KnappOrderResponse.Next() = 0;
                        end;
                    end;
                end;
            end;
        end;
    end;

    #EndRegion DeliveryJob+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

    #Region Consolidated Job++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    local procedure PostConsolidatedJobToePOD(_JobNo: Code[20]; ChannelCode: Code[10]; _SalesInvoiceHeader: Record "Sales Invoice Header"): Boolean
    var
        L_ePODJobHeader: Record "ePOD Job Header";
        L_httpheaders: HttpHeaders;
        L_httpclient: HttpClient;
        L_URL: Text;
        body: Text;
        L_httpcontent: HttpContent;
        L_httpResponseMessage: HttpResponseMessage;
        jObject: JsonObject;
        JObject1: JsonObject;
        JObject2: JsonObject;
        Response: Text;
        ModificationRequired: Boolean;
        L_ePODJobLine: Record "ePOD Job Line";
        L_ConsolidatedJob_SyncFailed: Boolean;
    begin
        //Clear All Variable +++
        ClearAll();

        //Check Mandatory fields+++
        CheckMandatoryfieldForJob(ChannelCode, G_JobType::Delivery);

        //++
        L_ePODJobHeader.Reset();
        L_ePODJobHeader.SetRange("No.", _JobNo);
        if L_ePODJobHeader.FindFirst() then begin
            //Get Credential & URL Detail +++ 
            GetCredentials(ChannelCode);

            L_httpheaders := L_httpclient.DefaultRequestHeaders;
            L_URL := ServiceURL + 'jobs';
            L_httpheaders.Add('Accept', 'application/json');
            L_httpheaders.Add('Authorization', 'Bearer ' + SecretAccessKey);

            //Create Body+++
            Clear(body);
            body := ConsolidatedJob_Body(L_ePODJobHeader."No.", ChannelCode);
            if StrLen(body) = 0 then begin
                if GuiAllowed = true then begin
                    Message('Loading Job sync failed Error: Loading job body is empty');
                    L_ConsolidatedJob_SyncFailed := true;
                    exit(L_ConsolidatedJob_SyncFailed);
                end else begin
                    InsertErrorLog(Database::"Sales Invoice Header", _SalesInvoiceHeader."No.", 'Loading Job sync failed Error: Loading job body is empty');
                    L_ConsolidatedJob_SyncFailed := true;
                    exit(L_ConsolidatedJob_SyncFailed);
                end;
            end;

            //Post Order to POD portal++
            L_httpcontent.WriteFrom(body);
            L_httpcontent.GetHeaders(L_httpheaders);
            L_httpheaders.Clear();
            L_httpheaders.Add('Content-Type', 'application/json');
            if L_httpclient.Post(L_URL, L_httpcontent, L_httpResponseMessage) then begin
                L_httpResponseMessage.Content.ReadAs(Response);

                //Response 201 Successful+++ 
                if L_httpResponseMessage.HttpStatusCode = 201 then begin
                    //Read the response in JObject+++
                    JObject.ReadFrom(Response);
                    JObject1 := GetJsonToken(jObject, 'job').AsObject();
                    JObject2 := GetJsonToken(jObject1, 'data').AsObject();

                    //Get ePOD ID+++
                    if JObject2.Contains('id') then begin
                        L_ePODJobHeader."ePOD ID" := GetJsonvalue(JObject2, 'id').AsInteger();
                        ModificationRequired := true;
                    end else
                        ModificationRequired := false;


                    //++
                    if ModificationRequired = true then begin
                        L_ePODJobHeader."Synced to ePOD" := true;
                        L_ePODJobHeader.Modify();
                    end;

                    L_ePODJobLine.Reset();
                    L_ePODJobLine.SetRange("Document No.", L_ePODJobHeader."No.");
                    L_ePODJobLine.SetRange("Consolidated to Loading Job", false);
                    if L_ePODJobLine.FindSet() then begin
                        L_ePODJobLine.ModifyAll("Consolidated to Loading Job", true);
                    end;

                    L_ConsolidatedJob_SyncFailed := false;
                    exit(L_ConsolidatedJob_SyncFailed);
                end else begin
                    //Manage Error
                    if GuiAllowed = true then begin
                        Message('Loading Job Sync Failed Error: %1', Response);
                        L_ConsolidatedJob_SyncFailed := true;
                        exit(L_ConsolidatedJob_SyncFailed);
                    end else begin
                        InsertErrorLog(Database::"Sales Invoice Header", _SalesInvoiceHeader."No.", StrSubstNo('Loading Job Sync Failed Error: %1', Response));
                        L_ConsolidatedJob_SyncFailed := true;
                        exit(L_ConsolidatedJob_SyncFailed);
                    end;
                end;
            end else begin
                //Manage Error
                if GuiAllowed = true then begin
                    L_httpResponseMessage.Content.ReadAs(Response);
                    Message('Loading Job Sync Failed Error: %1', Response);
                    L_ConsolidatedJob_SyncFailed := true;
                    exit(L_ConsolidatedJob_SyncFailed);
                end else begin
                    L_httpResponseMessage.Content.ReadAs(Response);
                    InsertErrorLog(Database::"Sales Invoice Header", _SalesInvoiceHeader."No.", StrSubstNo('Loading Job Sync Failed Error: %1', Response));
                    L_ConsolidatedJob_SyncFailed := true;
                    exit(L_ConsolidatedJob_SyncFailed);
                end;
            end;
        end else begin
            L_ConsolidatedJob_SyncFailed := true;
            exit(L_ConsolidatedJob_SyncFailed);
        end;
    end;

    local procedure ConsolidatedJob_Body(_JobNo: Code[20]; _ChannelCode: Code[50]): Text
    var
        L_ePODJobHeader: Record "ePOD Job Header";
        L_ePODJobLine: Record "ePOD Job Line";
        L_Customer: Record Customer;
        L_CustomerSiteID: Integer;
        L_CustomerePODID: Integer;
        L_Location: Record Location;
        L_LocationePODID: Integer;
        L_TemplateID: Integer;
        TradePartner: Record "Trade Partner";
        L_SalesInvoiceLine: Record "Sales Invoice Line";
        JsonObj: JsonObject;
        JsonValue: JsonValue;
        LinesArray: JsonArray;
        LineObj: JsonObject;
        FieldObj: JsonObject;
        FinalTextRequest: Text;
        L_Hour: Code[20];
        L_Minut: Code[20];
        L_Second: Code[20];
        L_finalStartDate: Text;
        L_finalEndDate: Text;
        L_Date: Text;
        L_Time: Text;

        L_ePODRunID: Integer;
        L_DropNumber: Integer;
        L_KnappOrderResponse: Record "Knapp Order Response";
        L_ItemReference: Record "Item Reference";
        L_SalesShipmentHeader: Record "Sales Shipment Header";
        L_ShippingAgent: Record "Shipping Agent";
        L_ShippingAgentServiceCode: Record "Shipping Agent Services";
        L_DepartureTime: Time;
        L_StartHour: Integer;
        L_EndHour: Integer;
    begin
        L_ePODJobHeader.Reset();
        L_ePODJobHeader.SetRange("No.", _JobNo);
        if L_ePODJobHeader.FindFirst() then begin

            //Get Site++
            Clear(L_CustomerSiteID);
            Clear(L_CustomerePODID);
            L_Customer.Reset();
            L_Customer.SetRange("Loading ePOD Customer", true);
            L_Customer.SetRange("Shipping Agent Code", L_ePODJobHeader."Shipping Agent Code");
            if L_Customer.FindFirst() then begin
                L_CustomerePODID := L_Customer."ePOD ID";
                L_CustomerSiteID := L_Customer."Customer Site ID";
            end;

            //Get Depot ID+++
            Clear(L_LocationePODID);
            L_ShippingAgent.Reset();
            L_ShippingAgent.SetRange(Code, L_ePODJobHeader."Shipping Agent Code");
            if L_ShippingAgent.FindFirst() then begin
                L_LocationePODID := L_ShippingAgent."ePOD ID";
            end;


            //Get Teplate ID
            Clear(L_TemplateID);
            TradePartner.RESET;
            if TradePartner.Get(_ChannelCode) then begin
                L_TemplateID := TradePartner."ePOD Template ID";
            end;


            //Get Start Date+++
            //Get Date+++
            Clear(L_Date);
            L_Date := Format(L_ePODJobHeader."Shipment Date", 0, '<Year4>-<Month,2>-<Day,2>');

            //Get Departure Time++
            Clear(L_DepartureTime);
            L_ShippingAgentServiceCode.Reset();
            L_ShippingAgentServiceCode.SetRange("Shipping Agent Code", L_ePODJobHeader."Shipping Agent Code");
            L_ShippingAgentServiceCode.SetRange(Code, L_ePODJobHeader."Shipping Agent Service Code");
            if L_ShippingAgentServiceCode.FindFirst() then begin
                L_DepartureTime := L_ShippingAgentServiceCode."Departure Time";
            end else
                L_DepartureTime := Time;

            Clear(L_Hour);
            Clear(L_StartHour);
            //L_StartHour := L_DepartureTime.Hour - 1;
            L_StartHour := L_DepartureTime.Hour;
            L_Hour := Format(L_StartHour);
            if StrLen(Format(L_Hour)) = 1 then
                L_Hour := '0' + L_Hour;

            Clear(L_Minut);
            L_Minut := Format(L_DepartureTime.Minute);
            if StrLen(Format(L_Minut)) = 1 then
                L_Minut := '0' + L_Minut;

            Clear(L_Second);
            L_Second := Format(L_DepartureTime.Second);
            if StrLen(Format(L_Second)) = 1 then
                L_Second := '0' + L_Second;

            Clear(L_finalStartDate);
            //L_finalStartDate := Format(L_Date) + 'T' + Format(L_Hour) + ':' + Format(L_Minut) + ':' + Format(L_Second) + 'Z';
            L_finalStartDate := Format(L_Date) + 'T' + Format(L_Hour) + ':' + Format(L_Minut) + ':' + Format(L_Second) + '+01:00';


            //Get End Date
            //Get Date+++
            Clear(L_Date);
            L_Date := Format(L_ePODJobHeader."Shipment Date", 0, '<Year4>-<Month,2>-<Day,2>');

            //Get Departure Time++
            Clear(L_DepartureTime);
            L_ShippingAgentServiceCode.Reset();
            L_ShippingAgentServiceCode.SetRange("Shipping Agent Code", L_ePODJobHeader."Shipping Agent Code");
            L_ShippingAgentServiceCode.SetRange(Code, L_ePODJobHeader."Shipping Agent Service Code");
            if L_ShippingAgentServiceCode.FindFirst() then begin
                L_DepartureTime := L_ShippingAgentServiceCode."Departure Time";
            end else
                L_DepartureTime := Time;

            Clear(L_Hour);
            Clear(L_EndHour);
            L_EndHour := L_DepartureTime.Hour + 1;
            L_Hour := Format(L_EndHour);
            if StrLen(Format(L_Hour)) = 1 then
                L_Hour := '0' + L_Hour;

            Clear(L_Minut);
            L_Minut := Format(L_DepartureTime.Minute);
            if StrLen(Format(L_Minut)) = 1 then
                L_Minut := '0' + L_Minut;

            Clear(L_Second);
            L_Second := Format(L_DepartureTime.Second);
            if StrLen(Format(L_Second)) = 1 then
                L_Second := '0' + L_Second;

            Clear(L_finalEndDate);
            //L_finalEndDate := Format(L_Date) + 'T' + Format(L_Hour) + ':' + Format(L_Minut) + ':' + Format(L_Second) + 'Z';
            L_finalEndDate := Format(L_Date) + 'T' + Format(L_Hour) + ':' + Format(L_Minut) + ':' + Format(L_Second) + '+01:00';


            //Get RunID+++
            Clear(L_ePODRunID);
            L_ePODRunID := L_ePODJobHeader."ePOD RunID";

            //Get Drop Number+++
            Clear(L_DropNumber);
            // if L_DropNumber = 0 then
            //     L_DropNumber := 12;
            L_DropNumber := 0;

            //Check Mandatory fields++
            if (L_CustomerSiteID = 0) AND (L_CustomerePODID = 0) AND (L_LocationePODID = 0) AND (L_TemplateID = 0) AND (L_ePODJobHeader."Shipment Date" = 0D) AND (L_ePODRunID = 0) AND (L_DropNumber = 0) then
                exit('');



            //Create Header++
            Clear(JsonObj);
            Clear(JsonValue);
            JsonObj.Add('site', L_CustomerSiteID);
            JsonObj.Add('customer', L_CustomerePODID);
            JsonObj.Add('depot', L_LocationePODID);
            JsonObj.Add('template', L_TemplateID);
            JsonObj.Add('run', L_ePODRunID);
            JsonObj.Add('dueByStart', L_finalStartDate);
            JsonObj.Add('dueBy', L_finalEndDate);
            JsonObj.Add('instructions1', '');
            JsonObj.Add('instructions2', '');
            JsonObj.Add('provisional', true);
            JsonObj.Add('dropTime', 60);
            JsonObj.Add('dropSequence', L_DropNumber);
            JsonObj.Add('price', 0);

            //Create Fields Object++
            Clear(FieldObj);
            JsonObj.Add('fields', FieldObj);
            FieldObj.Add('Customer PO', L_ePODJobHeader."Customer PO");
            FieldObj.Add('Internal Job Ref', L_ePODJobHeader."Customer PO");


            //Create Line++++
            Clear(LinesArray);
            Clear(LineObj);
            L_ePODJobLine.Reset();
            L_ePODJobLine.SetRange("Document No.", L_ePODJobHeader."No.");
            L_ePODJobLine.SetRange("Consolidated to Loading Job", false);
            L_ePODJobLine.SetRange("Job Type", L_ePODJobLine."Job Type"::Delivery);
            L_ePODJobLine.SetCurrentKey(Group);
            L_ePODJobLine.Ascending(true);
            if L_ePODJobLine.FindSet() then begin
                JsonObj.Add('items', LinesArray);
                repeat
                    Clear(LineObj);
                    LineObj.Add('name', L_ePODJobLine.Group);
                    LineObj.Add('merchGroup', L_ePODJobLine.Group);
                    LineObj.Add('productCode', L_ePODJobLine."Product Code");
                    LineObj.Add('price', 0);
                    LineObj.Add('weight', 0);
                    LineObj.Add('quantity', L_ePODJobLine.Quantity);
                    LineObj.Add('qtyDecimalPlaces', 1);
                    LineObj.Add('productBarcode', L_ePODJobLine."Product Code");
                    LinesArray.Add(LineObj);
                // if UpperCase(L_ePODJobLine.Group) = UpperCase('BOX') then begin
                //     Clear(LineObj);
                //     LineObj.Add('name', 'Box');
                //     LineObj.Add('merchGroup', 'Box');
                //     LineObj.Add('productCode', L_ePODJobLine."Product Code");
                //     LineObj.Add('price', 0);
                //     LineObj.Add('weight', 0);
                //     LineObj.Add('quantity', L_ePODJobLine.Quantity);
                //     LineObj.Add('qtyDecimalPlaces', 1);
                //     LineObj.Add('productBarcode', L_ePODJobLine."Product Code");
                //     LinesArray.Add(LineObj);
                // end else begin
                //     Clear(LineObj);
                //     LineObj.Add('name', 'TOTE');
                //     LineObj.Add('merchGroup', 'Tote');
                //     LineObj.Add('productCode', L_ePODJobLine."Product Code");
                //     LineObj.Add('price', 0);
                //     LineObj.Add('weight', 0);
                //     LineObj.Add('quantity', L_ePODJobLine.Quantity);
                //     LineObj.Add('qtyDecimalPlaces', 1);
                //     LineObj.Add('productBarcode', L_ePODJobLine."Product Code");
                //     LinesArray.Add(LineObj);
                // end;
                until L_ePODJobLine.Next() = 0;
            end;
            Clear(FinalTextRequest);
            JsonObj.WriteTo(FinalTextRequest);
            exit(FinalTextRequest)
        end;
    End;

    local procedure UpdateConsolidatedJobToePOD(_JobNo: Code[20]; ChannelCode: Code[10]; _SalesInvoiceHeader: Record "Sales Invoice Header"): Boolean
    var
        L_ePODJobHeader: Record "ePOD Job Header";
        L_httpheaders: HttpHeaders;
        L_httpclient: HttpClient;
        L_URL: Text;
        body: Text;
        L_httpcontent: HttpContent;
        L_httpResponseMessage: HttpResponseMessage;
        jObject: JsonObject;
        JObject1: JsonObject;
        JObject2: JsonObject;
        Response: Text;
        ModificationRequired: Boolean;
        L_ePODJobLine: Record "ePOD Job Line";
        L_ConsolidatedJob_SyncFailed: Boolean;
    begin
        //Clear All Variable +++
        ClearAll();

        //Check Mandatory fields+++
        CheckMandatoryfieldForJob(ChannelCode, G_JobType::Delivery);

        //++
        L_ePODJobHeader.Reset();
        L_ePODJobHeader.SetRange("No.", _JobNo);
        if L_ePODJobHeader.FindFirst() then begin
            //Get Credential & URL Detail +++ 
            GetCredentials(ChannelCode);

            L_httpheaders := L_httpclient.DefaultRequestHeaders;
            L_URL := ServiceURL + 'jobs' + '/' + Format(L_ePODJobHeader."ePOD ID");
            L_httpheaders.Add('Accept', 'application/json');
            L_httpheaders.Add('Authorization', 'Bearer ' + SecretAccessKey);

            //Create Body+++
            Clear(body);
            body := UpdateConsolidatedJob_Body(L_ePODJobHeader."No.", ChannelCode);
            if StrLen(body) = 0 then begin
                if GuiAllowed = true then begin
                    Message('Loading Job sync failed Error: Loading job body is empty');
                    L_ConsolidatedJob_SyncFailed := true;
                    exit(L_ConsolidatedJob_SyncFailed);
                end else begin
                    InsertErrorLog(Database::"Sales Invoice Header", _SalesInvoiceHeader."No.", 'Loading Job sync failed Error: Loading job body is empty');
                    L_ConsolidatedJob_SyncFailed := true;
                    exit(L_ConsolidatedJob_SyncFailed);
                end;
            end;

            //Post Order to POD portal++
            L_httpcontent.WriteFrom(body);
            L_httpcontent.GetHeaders(L_httpheaders);
            L_httpheaders.Clear();
            L_httpheaders.Add('Content-Type', 'application/json');
            if L_httpclient.Put(L_URL, L_httpcontent, L_httpResponseMessage) then begin
                L_httpResponseMessage.Content.ReadAs(Response);

                //Response 200 means Successful+++ 
                if L_httpResponseMessage.HttpStatusCode = 200 then begin
                    L_ePODJobLine.Reset();
                    L_ePODJobLine.SetRange("Document No.", L_ePODJobHeader."No.");
                    L_ePODJobLine.SetRange("Consolidated to Loading Job", false);
                    if L_ePODJobLine.FindSet() then begin
                        L_ePODJobLine.ModifyAll("Consolidated to Loading Job", true);
                    end;

                    L_ConsolidatedJob_SyncFailed := false;
                    exit(L_ConsolidatedJob_SyncFailed);
                end else begin
                    //Manage Error
                    if GuiAllowed = true then begin
                        Message('Loading Job Sync Failed Error: %1', Response);
                        L_ConsolidatedJob_SyncFailed := true;
                        exit(L_ConsolidatedJob_SyncFailed);
                    end else begin
                        InsertErrorLog(Database::"Sales Invoice Header", _SalesInvoiceHeader."No.", StrSubstNo('Loading Job Sync Failed Error: %1', Response));
                        L_ConsolidatedJob_SyncFailed := true;
                        exit(L_ConsolidatedJob_SyncFailed);
                    end;
                end;
            end else begin
                //Manage Error
                if GuiAllowed = true then begin
                    L_httpResponseMessage.Content.ReadAs(Response);
                    Message('Loading Job Sync Failed Error: %1', Response);
                    L_ConsolidatedJob_SyncFailed := true;
                    exit(L_ConsolidatedJob_SyncFailed);
                end else begin
                    L_httpResponseMessage.Content.ReadAs(Response);
                    InsertErrorLog(Database::"Sales Invoice Header", _SalesInvoiceHeader."No.", StrSubstNo('Loading Job Sync Failed Error: %1', Response));
                    L_ConsolidatedJob_SyncFailed := true;
                    exit(L_ConsolidatedJob_SyncFailed);
                end;
            end;
        end else begin
            L_ConsolidatedJob_SyncFailed := true;
            exit(L_ConsolidatedJob_SyncFailed);
        end;
    end;

    local procedure UpdateConsolidatedJob_Body(_JobNo: Code[20]; _ChannelCode: Code[50]): Text
    var
        L_ePODJobHeader: Record "ePOD Job Header";
        L_ePODJobLine: Record "ePOD Job Line";
        L_Customer: Record Customer;
        L_CustomerSiteID: Integer;
        L_CustomerePODID: Integer;
        L_Location: Record Location;
        L_LocationePODID: Integer;
        L_TemplateID: Integer;
        TradePartner: Record "Trade Partner";
        L_SalesInvoiceLine: Record "Sales Invoice Line";
        JsonObj: JsonObject;
        JsonValue: JsonValue;
        LinesArray: JsonArray;
        LineObj: JsonObject;
        FieldObj: JsonObject;
        FinalTextRequest: Text;
        L_Hour: Code[20];
        L_Minut: Code[20];
        L_Second: Code[20];
        L_finalStartDate: Text;
        L_finalEndDate: Text;
        L_Date: Text;
        L_Time: Text;

        L_ePODRunID: Integer;
        L_DropNumber: Integer;
        L_KnappOrderResponse: Record "Knapp Order Response";
        L_ItemReference: Record "Item Reference";
        L_SalesShipmentHeader: Record "Sales Shipment Header";
        L_ShippingAgent: Record "Shipping Agent";
        L_ShippingAgentServiceCode: Record "Shipping Agent Services";
        L_DepartureTime: Time;
        L_StartHour: Integer;
        L_EndHour: Integer;
    begin
        L_ePODJobHeader.Reset();
        L_ePODJobHeader.SetRange("No.", _JobNo);
        if L_ePODJobHeader.FindFirst() then begin

            //Get Site++
            Clear(L_CustomerSiteID);
            Clear(L_CustomerePODID);
            L_Customer.Reset();
            L_Customer.SetRange("Loading ePOD Customer", true);
            L_Customer.SetRange("Shipping Agent Code", L_ePODJobHeader."Shipping Agent Code");
            if L_Customer.FindFirst() then begin
                L_CustomerePODID := L_Customer."ePOD ID";
                L_CustomerSiteID := L_Customer."Customer Site ID";
            end;

            //Get Depot ID+++
            Clear(L_LocationePODID);
            L_ShippingAgent.Reset();
            L_ShippingAgent.SetRange(Code, L_ePODJobHeader."Shipping Agent Code");
            if L_ShippingAgent.FindFirst() then begin
                L_LocationePODID := L_ShippingAgent."ePOD ID";
            end;


            //Get Teplate ID
            Clear(L_TemplateID);
            TradePartner.RESET;
            if TradePartner.Get(_ChannelCode) then begin
                L_TemplateID := TradePartner."ePOD Template ID";
            end;


            //Get Start Date+++
            //Get Date+++
            Clear(L_Date);
            L_Date := Format(L_ePODJobHeader."Shipment Date", 0, '<Year4>-<Month,2>-<Day,2>');

            //Get Departure Time++
            Clear(L_DepartureTime);
            L_ShippingAgentServiceCode.Reset();
            L_ShippingAgentServiceCode.SetRange("Shipping Agent Code", L_ePODJobHeader."Shipping Agent Code");
            L_ShippingAgentServiceCode.SetRange(Code, L_ePODJobHeader."Shipping Agent Service Code");
            if L_ShippingAgentServiceCode.FindFirst() then begin
                L_DepartureTime := L_ShippingAgentServiceCode."Departure Time";
            end else
                L_DepartureTime := Time;

            Clear(L_Hour);
            Clear(L_StartHour);
            //L_StartHour := L_DepartureTime.Hour - 1;
            L_StartHour := L_DepartureTime.Hour;
            L_Hour := Format(L_StartHour);
            if StrLen(Format(L_Hour)) = 1 then
                L_Hour := '0' + L_Hour;

            Clear(L_Minut);
            L_Minut := Format(L_DepartureTime.Minute);
            if StrLen(Format(L_Minut)) = 1 then
                L_Minut := '0' + L_Minut;

            Clear(L_Second);
            L_Second := Format(L_DepartureTime.Second);
            if StrLen(Format(L_Second)) = 1 then
                L_Second := '0' + L_Second;

            Clear(L_finalStartDate);
            //L_finalStartDate := Format(L_Date) + 'T' + Format(L_Hour) + ':' + Format(L_Minut) + ':' + Format(L_Second) + 'Z';
            L_finalStartDate := Format(L_Date) + 'T' + Format(L_Hour) + ':' + Format(L_Minut) + ':' + Format(L_Second) + '+01:00';


            //Get End Date
            //Get Date+++
            Clear(L_Date);
            L_Date := Format(L_ePODJobHeader."Shipment Date", 0, '<Year4>-<Month,2>-<Day,2>');

            //Get Departure Time++
            Clear(L_DepartureTime);
            L_ShippingAgentServiceCode.Reset();
            L_ShippingAgentServiceCode.SetRange("Shipping Agent Code", L_ePODJobHeader."Shipping Agent Code");
            L_ShippingAgentServiceCode.SetRange(Code, L_ePODJobHeader."Shipping Agent Service Code");
            if L_ShippingAgentServiceCode.FindFirst() then begin
                L_DepartureTime := L_ShippingAgentServiceCode."Departure Time";
            end else
                L_DepartureTime := Time;

            Clear(L_Hour);
            Clear(L_EndHour);
            L_EndHour := L_DepartureTime.Hour + 1;
            L_Hour := Format(L_EndHour);
            if StrLen(Format(L_Hour)) = 1 then
                L_Hour := '0' + L_Hour;

            Clear(L_Minut);
            L_Minut := Format(L_DepartureTime.Minute);
            if StrLen(Format(L_Minut)) = 1 then
                L_Minut := '0' + L_Minut;

            Clear(L_Second);
            L_Second := Format(L_DepartureTime.Second);
            if StrLen(Format(L_Second)) = 1 then
                L_Second := '0' + L_Second;

            Clear(L_finalEndDate);
            //L_finalEndDate := Format(L_Date) + 'T' + Format(L_Hour) + ':' + Format(L_Minut) + ':' + Format(L_Second) + 'Z';
            L_finalEndDate := Format(L_Date) + 'T' + Format(L_Hour) + ':' + Format(L_Minut) + ':' + Format(L_Second) + '+01:00';


            //Get RunID+++
            Clear(L_ePODRunID);
            L_ePODRunID := L_ePODJobHeader."ePOD RunID";

            //Get Drop Number+++
            Clear(L_DropNumber);
            // if L_DropNumber = 0 then
            //     L_DropNumber := 12;
            L_DropNumber := 0;

            //Check Mandatory fields++
            if (L_CustomerSiteID = 0) AND (L_CustomerePODID = 0) AND (L_LocationePODID = 0) AND (L_TemplateID = 0) AND (L_ePODJobHeader."Shipment Date" = 0D) AND (L_ePODRunID = 0) AND (L_DropNumber = 0) then
                exit('');



            //Create Header++
            Clear(JsonObj);
            Clear(JsonValue);
            JsonObj.Add('site', L_CustomerSiteID);
            JsonObj.Add('customer', L_CustomerePODID);
            JsonObj.Add('depot', L_LocationePODID);
            JsonObj.Add('template', L_TemplateID);
            JsonObj.Add('run', L_ePODRunID);
            JsonObj.Add('dueByStart', L_finalStartDate);
            JsonObj.Add('dueBy', L_finalEndDate);
            JsonObj.Add('instructions1', '');
            JsonObj.Add('instructions2', '');
            JsonObj.Add('provisional', true);
            JsonObj.Add('dropTime', 60);
            JsonObj.Add('dropSequence', L_DropNumber);
            JsonObj.Add('price', 0);

            //Create Fields Object++
            Clear(FieldObj);
            JsonObj.Add('fields', FieldObj);
            FieldObj.Add('Customer PO', L_ePODJobHeader."Customer PO");
            FieldObj.Add('Internal Job Ref', L_ePODJobHeader."Customer PO");


            //Create Line++++
            Clear(LinesArray);
            Clear(LineObj);
            L_ePODJobLine.Reset();
            L_ePODJobLine.SetRange("Document No.", L_ePODJobHeader."No.");
            //L_ePODJobLine.SetRange("Consolidated to Loading Job", false);
            L_ePODJobLine.SetCurrentKey(Group);
            L_ePODJobLine.Ascending(true);
            if L_ePODJobLine.FindSet() then begin
                JsonObj.Add('items', LinesArray);
                repeat
                    Clear(LineObj);
                    LineObj.Add('name', L_ePODJobLine.Group);
                    LineObj.Add('merchGroup', L_ePODJobLine.Group);
                    LineObj.Add('productCode', L_ePODJobLine."Product Code");
                    LineObj.Add('price', 0);
                    LineObj.Add('weight', 0);
                    LineObj.Add('quantity', L_ePODJobLine.Quantity);
                    LineObj.Add('qtyDecimalPlaces', 1);
                    LineObj.Add('productBarcode', L_ePODJobLine."Product Code");
                    LinesArray.Add(LineObj);
                until L_ePODJobLine.Next() = 0;
            end;
            Clear(FinalTextRequest);
            JsonObj.WriteTo(FinalTextRequest);
            exit(FinalTextRequest)
        end;
    End;
    #EndRegion Consolidated Job++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++


    #Region Collection Job [Sales Return Order] ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    procedure CollectionJob_SynctoPOD(_SalesReturnNo: Code[20]; _DateFilter: Date; ChannelCode: Code[10])
    var
        L_SalesHeader: Record "Sales Header";
        L_SalesLine: Record "Sales Line";
        L_Customer: Record Customer;
        L_ShippingAgent: Record "Shipping Agent";
        L_ePODJobHeader: Record "ePOD Job Header";
        L_Count: Integer;

        L_ShippingAgentCode: Code[30];
        L_ShippingAgentServiceCode: Code[10];
    begin
        //Check Date filter++
        if _DateFilter = 0D then
            Error('Date filter is missing...');

        //Clear All Variable +++
        ClearAll();

        //Check Mandatory fields+++
        CheckMandatoryfieldForJob(ChannelCode, G_JobType::Collection);

        #Region Start Process to sync +++
        L_SalesHeader.Reset();
        if _SalesReturnNo <> '' then
            L_SalesHeader.SetRange("No.", _SalesReturnNo);
        L_SalesHeader.SetRange("Document Type", L_SalesHeader."Document Type"::"Return Order");
        L_SalesHeader.SetRange(Status, L_SalesHeader.Status::Released);
        L_SalesHeader.SetRange("Sigma Driver Collection", true);
        //L_SalesHeader.SetRange(synced,false);
        if L_SalesHeader.FindSet() then begin
            repeat
                //Get Shipping Agent Code+++
                Clear(L_ShippingAgent);
                Clear(L_ShippingAgentCode);
                if L_SalesHeader."Weekend Shipping Agent Code" <> '' then begin
                    L_ShippingAgentCode := L_SalesHeader."Weekend Shipping Agent Code";
                    L_ShippingAgentServiceCode := L_SalesHeader."Weekend Ship. Agnt. Serv. Code";
                end else begin
                    L_ShippingAgentCode := L_SalesHeader."Shipping Agent Code";
                    L_ShippingAgentServiceCode := L_SalesHeader."Shipping Agent Service Code";
                end;


                //Satrt Process+++++++
                L_SalesLine.Reset();
                L_SalesLine.SetRange("Document Type", L_SalesHeader."Document Type");
                L_SalesLine.SetRange("Document No.", L_SalesHeader."No.");
                L_SalesLine.SetRange(Type, L_SalesLine.Type::Item);
                if L_SalesLine.FindFirst() then begin
                    L_Customer.Reset();
                    L_Customer.SetRange("No.", L_SalesHeader."Sell-to Customer No.");
                    if L_Customer.FindFirst() then begin
                        if (L_Customer."ePOD ID" <> 0) AND (L_Customer."Customer Site ID" <> 0) AND (L_Customer."Podfather Customer" = true) then begin
                            L_ShippingAgent.Reset();
                            L_ShippingAgent.SetRange(Code, L_ShippingAgentCode);
                            if L_ShippingAgent.FindFirst() then begin
                                if (L_ShippingAgent."Podfather Depot" = true) AND (L_ShippingAgent."ePOD ID" <> 0) then begin
                                    //Create ePOD job list (Header) & Sync Run to POD Father System if require+++
                                    if PostRunToePOD(L_ShippingAgentCode, L_ShippingAgentServiceCode, _DateFilter, ChannelCode) = true then begin
                                        //Create ePOD Job (Lines) & Sync Collection Job to POD Father System if require+++
                                        PostCollectionJobToePOD(L_SalesHeader, _DateFilter, ChannelCode);
                                    end;
                                end else begin
                                    //Manage Error++
                                    if GuiAllowed = true then begin
                                        Error('Collection Job sync failed. Error: Depot %1 is not linked with ePOD System', L_ShippingAgent.Code);
                                    end else begin
                                        InsertErrorLog(Database::"Sales Invoice Header", L_SalesHeader."No.", StrSubstNo('Collection Job sync failed. Error: Depot %1 is not linked with ePOD System', L_ShippingAgent.Code));
                                    end;
                                end;
                            end else begin
                                //Manage Error++
                                if GuiAllowed = true then begin
                                    Error('Collection Job sync failed. Error: Depot %1 is not found in Shipping Agent table', L_ShippingAgent.Code);
                                end else begin
                                    InsertErrorLog(Database::"Sales Header", L_SalesHeader."No.", StrSubstNo('Collection Job sync failed. Error: Depot %1 is not found in Shipping Agent table', L_ShippingAgent.Code))
                                end;
                            end;
                        end else begin
                            //Manage Error++
                            if GuiAllowed = true then begin
                                Error('Collection Job sync failed. Error: Customer %1 is not linked with ePOD System', L_Customer."No.");
                            end else begin
                                InsertErrorLog(Database::"Sales Header", L_SalesHeader."No.", StrSubstNo('Collection Job sync failed. Error: Customer %1 is not linked with ePOD System', L_Customer."No."))
                            end;
                        end;
                    end else begin
                        //Manage Error++
                        if GuiAllowed = true then begin
                            Error('Collection Job sync failed. Error: Customer %1 is not found in customer table', L_Customer."No.");
                        end else begin
                            InsertErrorLog(Database::"Sales Header", L_SalesHeader."No.", StrSubstNo('Collection Job sync failed. Error: Customer %1 is not found in customer table', L_Customer."No."))
                        end;
                    end;
                end else begin
                    //Manage Error++
                    if GuiAllowed = true then begin
                        Error('Collection Job sync failed. Error: Lines not exist for the Document No.: %1.', L_SalesHeader."No.");
                    end else begin
                        InsertErrorLog(Database::"Sales Header", L_SalesHeader."No.", StrSubstNo('Collection Job sync failed. Error: Lines not exist for the Document No.: %1.', L_SalesHeader."No."))
                    end;
                end;
            until L_SalesHeader.Next() = 0;
        end else begin
            //Manage Error++
            if GuiAllowed = true then
                Error('Collection Job sync failed. Error: Return Order not exist')
            else
                InsertErrorLog(Database::"Sales Header", '', 'Collection Job sync failed. Error: Return Order not exist');
        end;
        #EndRegion Start Process to sync +++
    end;

    local procedure PostCollectionJobToePOD(_SalesHeader: Record "Sales Header"; _DateFilter: Date; ChannelCode: Code[10])
    var
        L_httpheaders: HttpHeaders;
        L_httpclient: HttpClient;
        L_URL: Text;
        body: Text;
        L_httpcontent: HttpContent;
        L_httpResponseMessage: HttpResponseMessage;
        jObject: JsonObject;
        JObject1: JsonObject;
        JObject2: JsonObject;
        Response: Text;
        ModificationRequired: Boolean;
        L_Status: Text;
        L_ePODJobHeader: Record "ePOD Job Header";
        SyncFailed: Boolean;
        //Deletion
        Deletion_httpheaders: HttpHeaders;
        Deletion_httpclient: HttpClient;
        Deletion_URL: Text;
        Deletion_httpcontent: HttpContent;
        Deletion_httpResponseMessage: HttpResponseMessage;
        Deletion_Response: Text;
        L_epodJobLine: Record "ePOD Job Line";
    begin
        //Get Credential & URL Detail +++ 
        Clear(SyncFailed);
        GetCredentials(ChannelCode);

        //++
        L_httpheaders := L_httpclient.DefaultRequestHeaders;
        L_URL := ServiceURL + 'jobs';
        L_httpheaders.Add('Accept', 'application/json');
        L_httpheaders.Add('Authorization', 'Bearer ' + SecretAccessKey);

        //Create Body for normal job+++
        Clear(body);
        body := CollectionJobForReturnOrder_Body(_SalesHeader, _DateFilter, ChannelCode);
        if StrLen(body) = 0 then begin
            if GuiAllowed = true then
                Error('Job sync failed Error: Job body is empty');
            exit;
        end;

        //Sync to POD +++
        L_httpcontent.WriteFrom(body);
        L_httpcontent.GetHeaders(L_httpheaders);
        L_httpheaders.Clear();
        L_httpheaders.Add('Content-Type', 'application/json');
        if L_httpclient.Post(L_URL, L_httpcontent, L_httpResponseMessage) then begin
            L_httpResponseMessage.Content.ReadAs(Response);

            //Response 201 Successful
            if L_httpResponseMessage.HttpStatusCode = 201 then begin
                //Read the response in JObject+++
                JObject.ReadFrom(Response);
                JObject1 := GetJsonToken(jObject, 'job').AsObject();
                JObject2 := GetJsonToken(jObject1, 'data').AsObject();

                //Insert into epodJob list+++
                L_ePODJobHeader.Reset();
                L_ePODJobHeader.SetRange("Shipment Date", _DateFilter);
                L_ePODJobHeader.SetRange("ePOD RunID", GetJsonvalue(JObject2, 'run').AsInteger());
                if _SalesHeader."Weekend Shipping Agent Code" <> '' then begin
                    L_ePODJobHeader.SetRange("Shipping Agent Code", _SalesHeader."Weekend Shipping Agent Code");
                    L_ePODJobHeader.SetRange("Shipping Agent Service Code", _SalesHeader."Weekend Ship. Agnt. Serv. Code");
                end else begin
                    L_ePODJobHeader.SetRange("Shipping Agent Code", _SalesHeader."Shipping Agent Code");
                    L_ePODJobHeader.SetRange("Shipping Agent Service Code", _SalesHeader."Shipping Agent Service Code");
                end;
                if L_ePODJobHeader.FindFirst() then begin
                    //Create epod Loading job Details in BC++
                    Create_ePODLine_ReturnOrder(_SalesHeader, L_ePODJobHeader, GetJsonvalue(JObject2, 'id').AsInteger(), 0);
                end;
            end else begin
                //Manage Error
                if GuiAllowed = true then begin
                    Error('Collection Job sync failed Error: %1', Response);
                end else begin
                    InsertErrorLog(Database::"Sales Header", _SalesHeader."No.", StrSubstNo('Collection Job sync failed Error: %1', Response));
                end;
            end;
        end else begin
            //Manage Error
            if GuiAllowed = true then begin
                L_httpResponseMessage.Content.ReadAs(Response);
                Error('Collection Job sync failed Error: %1', Response);
            end else begin
                L_httpResponseMessage.Content.ReadAs(Response);
                InsertErrorLog(Database::"Sales Header", _SalesHeader."No.", StrSubstNo('Collection Job sync failed Error: %1', Response));
            end;
        end;
    end;

    local procedure CollectionJobForReturnOrder_Body(_SalesHeader: Record "Sales Header"; _DateFilter: Date; _ChannelCode: Code[50]): Text
    var
        L_SalesHeader: Record "Sales Header";
        L_Customer: Record Customer;
        L_CustomerSiteID: Integer;
        L_CustomerePODID: Integer;
        L_Location: Record Location;
        L_LocationePODID: Integer;
        L_CollectionTemplateID: Integer;
        TradePartner: Record "Trade Partner";
        L_SalesInvoiceLine: Record "Sales Invoice Line";
        JsonObj: JsonObject;
        JsonValue: JsonValue;
        LinesArray: JsonArray;
        LineObj: JsonObject;
        FieldObj: JsonObject;
        FinalTextRequest: Text;
        L_Hour: Code[20];
        L_Minut: Code[20];
        L_Second: Code[20];
        L_finalStartDate: Text;
        L_finalEndDate: Text;
        L_Date: Text;
        L_Time: Text;
        L_ePODRunID: Integer;
        L_DropNumber: Integer;
        L_ShippingAgent: Record "Shipping Agent";
        ShippingAgentCodeFilter: Code[30];
        ShippingAgentServiceCodeFilter: Code[10];
        L_ePODJobHeader: Record "ePOD Job Header";
    begin
        L_SalesHeader.Reset();
        L_SalesHeader.SetRange("No.", _SalesHeader."No.");
        L_SalesHeader.SetRange("Document Type", L_SalesHeader."Document Type"::"Return Order");
        if L_SalesHeader.FindFirst() then begin
            L_SalesHeader.CalcFields(Amount, "Weekend Drop Number", "Drop Number");

            //Get Shipping agent Details+++
            Clear(ShippingAgentCodeFilter);
            Clear(ShippingAgentServiceCodeFilter);
            IF L_SalesHeader."Weekend Shipping Agent Code" <> '' then begin
                ShippingAgentCodeFilter := L_SalesHeader."Weekend Shipping Agent Code";
                ShippingAgentServiceCodeFilter := L_SalesHeader."Weekend Ship. Agnt. Serv. Code";
            end ELSE begin
                ShippingAgentCodeFilter := L_SalesHeader."Shipping Agent Code";
                ShippingAgentServiceCodeFilter := L_SalesHeader."Shipping Agent Service Code";
            end;


            //Get Site Details++
            Clear(L_CustomerSiteID);
            Clear(L_CustomerePODID);
            L_Customer.Reset();
            L_Customer.SetRange("No.", L_SalesHeader."Sell-to Customer No.");
            if L_Customer.FindFirst() then begin
                L_CustomerePODID := L_Customer."ePOD ID";
                L_CustomerSiteID := L_Customer."Customer Site ID";
            end;

            //Get Depot ID+++
            Clear(L_LocationePODID);
            L_ShippingAgent.Reset();
            L_ShippingAgent.SetRange(Code, ShippingAgentCodeFilter);
            if L_ShippingAgent.FindFirst() then begin
                L_LocationePODID := L_ShippingAgent."ePOD ID";
            end;


            //Get Teplate ID
            Clear(L_CollectionTemplateID);
            TradePartner.RESET;
            if TradePartner.Get(_ChannelCode) then begin
                L_CollectionTemplateID := TradePartner."ePOD Collection Template ID";
            end;

            //Get the start Date+++
            //Get Date+++
            Clear(L_Date);
            L_Date := Format(_DateFilter, 0, '<Year4>-<Month,2>-<Day,2>');

            Clear(L_Hour);
            L_Hour := Format(9);
            if StrLen(Format(L_Hour)) = 1 then
                L_Hour := '0' + L_Hour;

            Clear(L_Minut);
            L_Minut := Format(00);
            if StrLen(Format(L_Minut)) = 1 then
                L_Minut := '0' + L_Minut;

            Clear(L_Second);
            L_Second := Format(0);
            if StrLen(Format(L_Second)) = 1 then
                L_Second := '0' + L_Second;

            Clear(L_finalStartDate);
            //L_finalStartDate := Format(L_Date) + 'T' + Format(L_Hour) + ':' + Format(L_Minut) + ':' + Format(L_Second) + 'Z';
            L_finalStartDate := Format(L_Date) + 'T' + Format(L_Hour) + ':' + Format(L_Minut) + ':' + Format(L_Second) + '+01:00';


            //Get the End Date+++
            //Get Date+++
            Clear(L_Date);
            L_Date := Format(_DateFilter, 0, '<Year4>-<Month,2>-<Day,2>');

            Clear(L_Hour);
            L_Hour := Format(17);
            if StrLen(Format(L_Hour)) = 1 then
                L_Hour := '0' + L_Hour;

            Clear(L_Minut);
            L_Minut := Format(00);
            if StrLen(Format(L_Minut)) = 1 then
                L_Minut := '0' + L_Minut;

            Clear(L_Second);
            L_Second := Format(0);
            if StrLen(Format(L_Second)) = 1 then
                L_Second := '0' + L_Second;

            Clear(L_finalEndDate);
            //L_finalEndDate := Format(L_Date) + 'T' + Format(L_Hour) + ':' + Format(L_Minut) + ':' + Format(L_Second) + 'Z';
            L_finalEndDate := Format(L_Date) + 'T' + Format(L_Hour) + ':' + Format(L_Minut) + ':' + Format(L_Second) + '+01:00';



            //Get RunID+++
            Clear(L_ePODRunID);
            L_ePODJobHeader.Reset();
            L_ePODJobHeader.SetRange("Shipment Date", _DateFilter);
            L_ePODJobHeader.SetRange("Shipping Agent Code", ShippingAgentCodeFilter);
            L_ePODJobHeader.SetRange("Shipping Agent Service Code", ShippingAgentServiceCodeFilter);
            if L_ePODJobHeader.FindFirst() then
                L_ePODRunID := L_ePODJobHeader."ePOD RunID";

            //Get Drop Number+++
            Clear(L_DropNumber);
            IF L_SalesHeader."Weekend Shipping Agent Code" <> '' then begin
                if L_SalesHeader."Weekend Drop Number" <> '' then
                    Evaluate(L_DropNumber, L_SalesHeader."Weekend Drop Number")
                else
                    L_DropNumber := 0;
            end else begin
                if L_SalesHeader."Drop Number" <> '' then
                    Evaluate(L_DropNumber, L_SalesHeader."Drop Number")
                else
                    L_DropNumber := 0;
            end;
            if L_DropNumber = 0 then
                L_DropNumber := 0001;

            //Check Mandatory fields++
            if (L_CustomerSiteID = 0) AND (L_CustomerePODID = 0) AND (L_LocationePODID = 0) AND (L_CollectionTemplateID = 0) AND (_DateFilter = 0D) AND (L_ePODRunID = 0) AND (L_DropNumber = 0) then
                exit('');


            //Create Header++
            Clear(JsonObj);
            Clear(JsonValue);
            JsonObj.Add('site', L_CustomerSiteID);
            JsonObj.Add('customer', L_CustomerePODID);
            JsonObj.Add('depot', L_LocationePODID);
            JsonObj.Add('template', L_CollectionTemplateID);
            JsonObj.Add('run', L_ePODRunID);
            JsonObj.Add('dueByStart', L_finalStartDate);
            JsonObj.Add('dueBy', L_finalEndDate);
            JsonObj.Add('instructions1', L_SalesHeader."Sigma Driver Collection Instr.");
            JsonObj.Add('instructions2', '');
            JsonObj.Add('provisional', true);
            JsonObj.Add('dropTime', 1);
            JsonObj.Add('dropSequence', L_DropNumber);
            JsonObj.Add('price', 0);

            //Create Fields Object++
            Clear(FieldObj);
            JsonObj.Add('fields', FieldObj);
            FieldObj.Add('Customer PO', L_SalesHeader."No.");
            FieldObj.Add('Internal Job Ref', L_SalesHeader."No.");

            //Line Array++
            JsonObj.Add('items', LinesArray);


            Clear(FinalTextRequest);
            JsonObj.WriteTo(FinalTextRequest);
            exit(FinalTextRequest)
        end;
    End;

    local procedure Create_ePODLine_ReturnOrder(_SalesHeader: Record "Sales Header"; _ePODJobHeader: Record "ePOD Job Header"; _ePODID: Integer; _ePODIDForCollection: Integer)
    var
        L_ePODRunHeader: Record "ePOD Job Header";
        L_ePODRunLine: Record "ePOD Job Line";
        Last_ePODRunLine: Record "ePOD Job Line";
    begin
        //Create Line++
        L_ePODRunHeader.Reset();
        L_ePODRunHeader.SetRange("No.", _ePODJobHeader."No.");
        if L_ePODRunHeader.FindFirst() then begin
            L_ePODRunLine.Init();
            L_ePODRunLine."Document No." := L_ePODRunHeader."No.";
            L_ePODRunLine."ePOD RunID" := L_ePODRunHeader."ePOD RunID";
            Last_ePODRunLine.Reset();
            Last_ePODRunLine.SetRange("ePOD RunID", L_ePODRunHeader."ePOD RunID");
            Last_ePODRunLine.SetRange("Shipment Date", L_ePODRunHeader."Shipment Date");
            if Last_ePODRunLine.FindLast() then
                L_ePODRunLine."Line Number" := Last_ePODRunLine."Line Number" + 10000
            else
                L_ePODRunLine."Line Number" := 10000;
            L_ePODRunLine."Customer PO" := 'SIGMA';
            L_ePODRunLine."Shipping Agent Code" := L_ePODRunHeader."Shipping Agent Code";
            L_ePODRunLine."Shipping Agent Service Code" := L_ePODRunHeader."Shipping Agent Service Code";
            L_ePODRunLine."Shipment Date" := L_ePODRunHeader."Shipment Date";
            L_ePODRunLine."Product Code" := _SalesHeader."No.";
            L_ePODRunLine.Description := StrSubstNo('Collection Job for SRO - %1', _SalesHeader."No.");
            L_ePODRunLine."BC Invoice Number" := _SalesHeader."No.";
            L_ePODRunLine.Group := '';
            L_ePODRunLine.Quantity := 0;
            L_ePODRunLine."ePOD ID" := _ePODID;
            // L_ePODRunLine."Collection ePOD ID" := _ePODID;
            L_ePODRunLine."Synced to ePOD" := true;
            L_ePODRunLine."Job Type" := L_ePODRunLine."Job Type"::Collection;
            L_ePODRunLine.Insert();
        end;
    end;
    #EndRegion Collection Job [Sales Return Order] ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++


    #Region Common function++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    local procedure PostRunToePOD(_ShippingAgentCode: Code[20]; _ShippingAgentServiceCode: Code[20]; _DateFilter: Date; ChannelCode: Code[10]): Boolean

    var
        L_httpheaders: HttpHeaders;
        L_httpclient: HttpClient;
        L_URL: Text;
        body: Text;
        L_httpcontent: HttpContent;
        L_httpResponseMessage: HttpResponseMessage;
        jObject: JsonObject;
        JObject1: JsonObject;
        Response: Text;
        InsertRequired: Boolean;
        L_ePODJobHeader: Record "ePOD Job Header";
        L_RunID: Integer;
        L_ShippingAgent: Record "Shipping Agent";
        L_SalesAndReceivablesSetup: Record "Sales & Receivables Setup";
        NoSeriesManagement: Codeunit "No. Series";
    begin
        //Get No Seies Setup++
        L_SalesAndReceivablesSetup.Get();
        L_SalesAndReceivablesSetup.TestField("ePOD Job Nos");

        //Check & create Run details +++
        if IsRunAvailable(_ShippingAgentCode, _ShippingAgentServiceCode, _DateFilter) = false then begin
            //Get Credential & URL Detail +++ 
            GetCredentials(ChannelCode);

            //++
            L_httpheaders := L_httpclient.DefaultRequestHeaders;
            L_URL := ServiceURL + 'runs';
            L_httpheaders.Add('Accept', 'application/json');
            L_httpheaders.Add('Authorization', 'Bearer ' + SecretAccessKey);

            //Create Body+++
            Clear(body);
            body := Run_Body(_ShippingAgentCode, _ShippingAgentServiceCode, _DateFilter, ChannelCode);
            if StrLen(body) = 0 then
                exit(false);

            //Sync Run to ePOD
            L_httpcontent.WriteFrom(body);
            L_httpcontent.GetHeaders(L_httpheaders);
            L_httpheaders.Clear();
            L_httpheaders.Add('Content-Type', 'application/json');
            if L_httpclient.Post(L_URL, L_httpcontent, L_httpResponseMessage) then begin
                L_httpResponseMessage.Content.ReadAs(Response);

                //Response 200 Successful+++ 
                if L_httpResponseMessage.HttpStatusCode = 200 then begin
                    //Read the response in JObject+++
                    JObject.ReadFrom(Response);
                    JObject1 := GetJsonToken(jObject, 'data').AsObject();

                    //Get ePOD ID+++
                    Clear(L_RunID);
                    if JObject1.Contains('id') then begin
                        L_RunID := GetJsonvalue(JObject1, 'id').AsInteger();
                        InsertRequired := true;
                    end else
                        InsertRequired := false;

                    //Insert Run Details and Loading Header details+++
                    if InsertRequired = true then begin
                        L_ePODJobHeader.Reset();
                        L_ePODJobHeader.SetRange("ePOD RunID", L_RunID);
                        L_ePODJobHeader.SetRange("Shipment Date", _DateFilter);
                        L_ePODJobHeader.SetRange("Shipping Agent Code", _ShippingAgentCode);
                        L_ePODJobHeader.SetRange("Shipping Agent Service Code", _ShippingAgentServiceCode);
                        if not L_ePODJobHeader.FindFirst() then begin
                            L_ePODJobHeader.Init();
                            L_ePODJobHeader."No." := NoSeriesManagement.GetNextNo(L_SalesAndReceivablesSetup."ePOD Job Nos", TODAY, TRUE);
                            L_ePODJobHeader."ePOD RunID" := L_RunID;
                            L_ePODJobHeader."Shipment Date" := _DateFilter;
                            L_ePODJobHeader."Shipping Agent Code" := _ShippingAgentCode;
                            L_ePODJobHeader."Shipping Agent Service Code" := _ShippingAgentServiceCode;
                            L_ShippingAgent.Reset();
                            L_ShippingAgent.SetRange(Code, _ShippingAgentCode);
                            if L_ShippingAgent.FindFirst() then begin
                                L_ePODJobHeader."Depot ID" := L_ShippingAgent."ePOD ID";
                            end;
                            L_ePODJobHeader."Customer PO" := 'SIGMA';
                            L_ePODJobHeader."Synced to ePOD" := false;
                            L_ePODJobHeader."Consolidated Date & Time" := CurrentDateTime;
                            L_ePODJobHeader.Insert();

                            //Used Commit method to ignore duplicate record in POD father system++
                            Commit();
                            exit(true);
                        end;
                    end;
                end else begin
                    //Manage Error++
                    if GuiAllowed = true then begin
                        Error('Run sync failed. Error: %1', Response);
                    end else begin
                        InsertErrorLog(Database::"Sales Header", _ShippingAgentCode + '/' + _ShippingAgentServiceCode, StrSubstNo('Run sync failed. Error: %1', Response));
                    end;
                end;
            end else begin
                //Manage Error++
                if GuiAllowed = true then begin
                    Error('Run sync failed. Error: %1', L_httpResponseMessage.Content.ReadAs(Response));
                end else begin
                    InsertErrorLog(Database::"Sales Header", _ShippingAgentCode + '/' + _ShippingAgentServiceCode, StrSubstNo('Run sync failed. Error: %1', L_httpResponseMessage.Content.ReadAs(Response)));
                end;
            end;
        end else
            exit(true);

        //If Run Syncing is failed
        exit(false);
    end;

    local procedure Run_Body(_ShippingAgentCode: Code[20]; _ShippingAgentServiceCode: Code[20]; _DateFilter: Date; _ChannelCode: Code[50]): Text
    var
        HeaderRequest: Text;
        L_Name: Text;
        L_ShippingAgent: Record "Shipping Agent";
        L_DepotID: Integer;
        L_Hour: Code[20];
        L_Minut: Code[20];
        L_Second: Code[20];
        L_finalDate: Text;
        L_Date: Text;
        L_Time: Text;
        L_DriverID: Integer;
        L_ShippingAgentServiceCode: Record "Shipping Agent Services";
    begin
        //Name++
        Clear(L_Name);
        L_Name := _ShippingAgentServiceCode;

        //Depot ID++
        Clear(L_DepotID);
        L_ShippingAgent.Reset();
        L_ShippingAgent.SetRange(Code, _ShippingAgentCode);
        if L_ShippingAgent.FindFirst() then begin
            if L_ShippingAgent."ePOD ID" = 0 then
                exit('');
            L_DepotID := L_ShippingAgent."ePOD ID";
        end;

        //Driver ID+++
        Clear(L_DriverID);
        L_ShippingAgentServiceCode.Reset();
        L_ShippingAgentServiceCode.SetRange("Shipping Agent Code", _ShippingAgentCode);
        L_ShippingAgentServiceCode.SetRange(Code, _ShippingAgentServiceCode);
        if L_ShippingAgentServiceCode.FindFirst() then
            L_DriverID := L_ShippingAgentServiceCode."Driver ePOD ID";


        //Get Date+++
        if _DateFilter = 0D then
            exit('');

        Clear(L_Date);
        L_Date := Format(_DateFilter, 0, '<Year4>-<Month,2>-<Day,2>');

        Clear(L_Hour);
        L_Hour := Format(CurrentDateTime.Time.Hour);
        if StrLen(Format(L_Hour)) = 1 then
            L_Hour := '0' + L_Hour;

        Clear(L_Minut);
        L_Minut := Format(CurrentDateTime.Time.Minute);
        if StrLen(Format(L_Minut)) = 1 then
            L_Minut := '0' + L_Minut;

        Clear(L_Second);
        L_Second := Format(CurrentDateTime.Time.Second);
        if StrLen(Format(L_Second)) = 1 then
            L_Second := '0' + L_Second;

        Clear(L_finalDate);
        //L_finalDate := Format(L_Date) + 'T' + Format(L_Hour) + ':' + Format(L_Minut) + ':' + Format(L_Second) + 'Z';
        L_finalDate := Format(L_Date) + 'T' + '07' + ':' + '00' + ':' + '00' + 'Z';


        //FinalBody
        if L_DriverID <> 0 then
            HeaderRequest := StrSubstNo('{"name":"%1","depot":%2,"date":"%3","driver":%4}', L_Name, L_DepotID, L_finalDate, L_DriverID)
        else
            HeaderRequest := StrSubstNo('{"name":"%1","depot":%2,"date":"%3","driver":%4}', L_Name, L_DepotID, L_finalDate, 'null');

        exit(HeaderRequest);

    end;

    local procedure IsRunAvailable(_ShippingAgentCode: Code[20]; _ShippingAgentServiceCode: Code[20]; _DateFilter: Date): Boolean
    var
        L_eJobHeader: Record "ePOD Job Header";
    begin
        L_eJobHeader.Reset();
        L_eJobHeader.SetRange("Shipment Date", _DateFilter);
        L_eJobHeader.SetRange("Shipping Agent Code", _ShippingAgentCode);
        L_eJobHeader.SetRange("Shipping Agent Service Code", _ShippingAgentServiceCode);
        L_eJobHeader.SetFilter("ePOD RunID", '<>%1', 0);
        if L_eJobHeader.FindFirst() then
            exit(true)
        else
            exit(false);
    end;

    //Read Json Value++
    procedure GetJsonToken(var JsonObject: JsonObject; TokenKey: text) JsonToken: JsonToken;
    begin
        if not JsonObject.Get(TokenKey, JsonToken) then;
    end;

    //Read Json Value++
    procedure GetJsonvalue(var aJsonObject: JsonObject; TokenKey: text) aJsonValue: JsonValue;
    var
        aJsonToken: JsonToken;
    begin
        if not aJsonObject.Get(TokenKey, aJsonToken) then
            Error('Could not find a token with key %1', TokenKey)
        Else
            aJsonValue := aJsonToken.AsValue();
    end;

    //Credential details++
    local procedure GetCredentials(ChannelCode: Code[10])
    var
        TradePartner: Record "Trade Partner";
    begin
        TradePartner.RESET;
        if TradePartner.Get(ChannelCode) then begin
            SecretAccessKey := TradePartner.SecretAccessKey;
            ServiceURL := TradePartner."Sevice/API URL";
        End;
    end;

    //Check Mandatory Fields for Master (Customer/Route)++
    local procedure CheckMandatoryfield(ChannelCode: Code[10])
    var
        TradePartner: Record "Trade Partner";
    begin
        TradePartner.RESET;
        if TradePartner.Get(ChannelCode) then begin
            TradePartner.TestField(SecretAccessKey);
            TradePartner.TestField("Sevice/API URL");
        End else
            Error('Channel Partner Missing');
    end;

    //Check Mandatory Fields+++
    procedure CheckMandatoryfieldForJob(ChannelCode: Code[10]; _JobType: Option Delivery,Collection)
    var
        TradePartner: Record "Trade Partner";
    begin
        TradePartner.RESET;
        if TradePartner.Get(ChannelCode) then begin
            if _JobType = _JobType::Delivery then
                TradePartner.TestField("ePOD Template ID");
            if _JobType = _JobType::Collection then
                TradePartner.TestField("ePOD Collection Template ID");
            TradePartner.TestField(SecretAccessKey);
            TradePartner.TestField("Sevice/API URL");
        End else
            Error('Channel Partner Missing');
    end;

    //InsertError Logs++
    local procedure InsertErrorLog(_Type: Integer; _DocumentNo: Code[2048]; _Error: Text[2048])
    var
        L_PODFatherErrorLog: Record "PODFather Error Management";
        Last_PODFatherErrorLog: Record "PODFather Error Management";
        LastVersion: Integer;
    begin
        Clear(LastVersion);
        L_PODFatherErrorLog.Reset();
        L_PODFatherErrorLog.SetRange("Document Type", _Type);
        L_PODFatherErrorLog.SetRange("Document No.", _DocumentNo);
        if L_PODFatherErrorLog.FindLast() then
            LastVersion := L_PODFatherErrorLog."Version No." + 1
        else
            LastVersion := 1;


        L_PODFatherErrorLog.Init();
        Last_PODFatherErrorLog.Reset();
        IF Last_PODFatherErrorLog.FindLast() then
            L_PODFatherErrorLog."Entry No." := Last_PODFatherErrorLog."Entry No." + 1
        else
            L_PODFatherErrorLog."Entry No." := 1;
        if _Type = 112 then
            L_PODFatherErrorLog."Document Type" := L_PODFatherErrorLog."Document Type"::"Sales Invoice"
        else
            L_PODFatherErrorLog."Document Type" := L_PODFatherErrorLog."Document Type"::"Sales Return";
        L_PODFatherErrorLog."Document No." := _DocumentNo;
        L_PODFatherErrorLog."Version No." := LastVersion;
        L_PODFatherErrorLog.Error := _Error;
        L_PODFatherErrorLog.Insert();
    end;

    #EndRegion Common function++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    var
        myInt: Integer;
        StartParameter: Text;
        RunType: Text;
        SecretAccessKey: text;
        ServiceURL: Text;
        G_OrderNo: Code[20];
        G_JobType: Option Delivery,Collection;


}