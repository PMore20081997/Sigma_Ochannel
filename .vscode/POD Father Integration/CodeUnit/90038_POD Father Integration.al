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
            'NormalJob':
                begin
                    Job_OnPODFatherPortal('', StartParameter);
                end;
            'UpdateSalesInvoiceStatus':
                begin
                    GetJobAndUpdateSalesInvoice('', StartParameter, _Error);
                end;

        end;

        //Not required+++++++
        //Depot_OnPODFatherPortal('EPOD');
        //UpdateDepot_OnPODFatherPortal('EPOD');
    end;

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

    #Region Job++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    procedure Job_OnPODFatherPortal(_SalesInvoiceNumber: Code[20]; ChannelCode: Code[10])
    var
        L_SalesInvoiceHeader: Record "Sales Invoice Header";
        L_Customer: Record Customer;
        L_ShippingAgent: Record "Shipping Agent";
    begin
        //Clear All Variable +++
        ClearAll();

        //Check Mandatory fields+++
        CheckMandatoryfieldForJob(ChannelCode);

        L_SalesInvoiceHeader.Reset();
        if _SalesInvoiceNumber <> '' then
            L_SalesInvoiceHeader.SetRange("No.", _SalesInvoiceNumber);
        L_SalesInvoiceHeader.SetFilter("ePOD ID", '%1', 0);
        L_SalesInvoiceHeader.SetCurrentKey("Shipment Date");
        L_SalesInvoiceHeader.Ascending(true);
        if L_SalesInvoiceHeader.FindSet() then begin
            repeat
                L_Customer.Reset();
                L_Customer.SetRange("No.", L_SalesInvoiceHeader."Sell-to Customer No.");
                if L_Customer.FindFirst() then begin
                    if (L_Customer."ePOD ID" <> 0) AND (L_Customer."Customer Site ID" <> 0) AND (L_Customer."Podfather Customer" = true) then begin
                        if L_SalesInvoiceHeader."Weekend Shipping Agent Code" <> '' then begin
                            L_ShippingAgent.Reset();
                            L_ShippingAgent.SetRange(Code, L_SalesInvoiceHeader."Weekend Shipping Agent Code");
                            if L_ShippingAgent.FindFirst() then begin
                                if (L_ShippingAgent."Podfather Depot" = true) AND (L_ShippingAgent."ePOD ID" <> 0) then begin
                                    //Create Run If not Available + + +
                                    if PostRunToePOD(L_SalesInvoiceHeader."No.", ChannelCode) = true then begin
                                        //Create Job+++
                                        PostJobToePOD(L_SalesInvoiceHeader."No.", ChannelCode);
                                    end else begin
                                        if GuiAllowed = true then
                                            Error(GetLastErrorText);
                                    end;
                                end else begin
                                    if GuiAllowed = true then
                                        Error('Depot %1 is not linked with ePOD', L_ShippingAgent.Code);
                                end;
                            end else begin
                                if GuiAllowed = true then
                                    Error('Depot %1 is not linked with ePOD', L_ShippingAgent.Code);
                            end;
                        end else begin
                            L_ShippingAgent.Reset();
                            L_ShippingAgent.SetRange(Code, L_SalesInvoiceHeader."Shipping Agent Code");
                            if L_ShippingAgent.FindFirst() then begin
                                if (L_ShippingAgent."Podfather Depot" = true) AND (L_ShippingAgent."ePOD ID" <> 0) then begin
                                    //Create Run If not Available + + +
                                    if PostRunToePOD(L_SalesInvoiceHeader."No.", ChannelCode) = true then begin
                                        //Create Job+++
                                        PostJobToePOD(L_SalesInvoiceHeader."No.", ChannelCode);
                                    end else begin
                                        Error(GetLastErrorText);
                                    end;
                                end else begin
                                    if GuiAllowed = true then
                                        Error('Depot %1 is not linked with ePOD', L_ShippingAgent.Code);
                                end;
                            end else begin
                                if GuiAllowed = true then
                                    Error('Depot %1 is not linked with ePOD', L_ShippingAgent.Code);
                            end;
                        end;
                        // L_Location.Reset();
                        // L_Location.SetRange(Code, L_SalesInvoiceHeader."Location Code");
                        // if L_Location.FindFirst() then begin
                        //     if (L_Location."Podfather Depot" = true) AND (L_Location."ePOD ID" <> 0) then begin
                        //         //Create Run If not Available+++
                        //         if PostRunToePOD(L_SalesInvoiceHeader."No.", ChannelCode) = true then begin
                        //             //Create Job+++
                        //             PostJobToePOD(L_SalesInvoiceHeader."No.", ChannelCode);
                        //         end else begin
                        //             Error(GetLastErrorText);
                        //         end;
                        //     end;
                        // end;
                    end else begin
                        if GuiAllowed = true then
                            Error('Customer %1 is not linked with ePOD', L_Customer."No.");
                    end;
                end else begin
                    if GuiAllowed = true then
                        Error('Customer %1 is not linked with ePOD', L_Customer."No.");
                end;
            until L_SalesInvoiceHeader.Next() = 0;
        end else begin
            if GuiAllowed = true then
                Error('No job available for sync');
        end;
    end;

    local procedure PostRunToePOD(_SalesInvoiceNumber: Code[20]; ChannelCode: Code[10]): Boolean
    var
        L_SalesInvoiceHeader: Record "Sales Invoice Header";
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
        L_ePODRun: Record "ePOD Runs";
        L_RunID: Integer;
        L_ShippingAgent: Record "Shipping Agent";
    begin
        L_SalesInvoiceHeader.Reset();
        L_SalesInvoiceHeader.SetRange("No.", _SalesInvoiceNumber);
        if L_SalesInvoiceHeader.FindFirst() then begin
            //Check Run +++
            if IsRunAvailable(L_SalesInvoiceHeader."No.") = false then begin
                //Get Credential & URL Detail +++ 
                GetCredentials(ChannelCode);

                L_httpheaders := L_httpclient.DefaultRequestHeaders;
                L_URL := ServiceURL + 'runs';
                L_httpheaders.Add('Accept', 'application/json');
                L_httpheaders.Add('Authorization', 'Bearer ' + SecretAccessKey);

                //Create Body+++
                Clear(body);
                body := Run_Body(L_SalesInvoiceHeader."No.", ChannelCode);
                if StrLen(body) = 0 then
                    exit(false);

                //Post Order to POD portal++
                L_httpcontent.WriteFrom(body);
                L_httpcontent.GetHeaders(L_httpheaders);
                L_httpheaders.Clear();
                L_httpheaders.Add('Content-Type', 'application/json');
                if L_httpclient.Post(L_URL, L_httpcontent, L_httpResponseMessage) then begin
                    L_httpResponseMessage.Content.ReadAs(Response);

                    //Response 200 means Successful+++ 
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

                        //++
                        if InsertRequired = true then begin
                            L_ePODRun.Reset();
                            L_ePODRun.SetRange("Run ID", L_RunID);
                            L_ePODRun.SetRange(Date, L_SalesInvoiceHeader."Shipment Date");
                            if not L_ePODRun.FindFirst() then begin
                                L_ePODRun.Init();
                                L_ePODRun."Run ID" := L_RunID;
                                L_ePODRun.Date := L_SalesInvoiceHeader."Shipment Date";
                                //L_ePODRun."Location Code" := L_SalesInvoiceHeader."Location Code";
                                if L_SalesInvoiceHeader."Weekend Shipping Agent Code" <> '' then begin
                                    L_ePODRun."Agent Code" := L_SalesInvoiceHeader."Weekend Shipping Agent Code";
                                    L_ePODRun."Agent Service Code" := L_SalesInvoiceHeader."Weekend Ship. Agnt. Serv. Code";

                                    L_ShippingAgent.Reset();
                                    L_ShippingAgent.SetRange(Code, L_SalesInvoiceHeader."Weekend Shipping Agent Code");
                                    if L_ShippingAgent.FindFirst() then begin
                                        L_ePODRun."Depot ID" := L_ShippingAgent."ePOD ID";
                                    end;
                                end else begin
                                    L_ePODRun."Agent Code" := L_SalesInvoiceHeader."Shipping Agent Code";
                                    L_ePODRun."Agent Service Code" := L_SalesInvoiceHeader."Shipping Agent Service Code";

                                    L_ShippingAgent.Reset();
                                    L_ShippingAgent.SetRange(Code, L_SalesInvoiceHeader."Shipping Agent Code");
                                    if L_ShippingAgent.FindFirst() then begin
                                        L_ePODRun."Depot ID" := L_ShippingAgent."ePOD ID";
                                    end;
                                end;

                                if L_ePODRun.Insert() = true then begin
                                    L_SalesInvoiceHeader."ePOD RunID" := L_RunID;
                                    L_SalesInvoiceHeader.Modify();
                                end else
                                    Error(GetLastErrorText);
                                exit(true);
                            end;
                        end;
                    end;
                end;
            end else
                exit(true);
        end;

        //Run is not Synced++
        exit(false);
    end;

    local procedure Run_Body(_SalesInvoiceNumber: Code[20]; _ChannelCode: Code[50]): Text
    var
        L_SalesInvoiceHeader: Record "Sales Invoice Header";
        L_Customer: Record Customer;
        TradePartner: Record "Trade Partner";
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
    begin
        L_SalesInvoiceHeader.Reset();
        L_SalesInvoiceHeader.SetRange("No.", _SalesInvoiceNumber);
        if L_SalesInvoiceHeader.FindFirst() then begin
            //Get Name and Depot ID++
            Clear(L_Name);
            if L_SalesInvoiceHeader."Weekend Shipping Agent Code" <> '' then begin
                //Name++
                L_Name := L_SalesInvoiceHeader."Weekend Ship. Agnt. Serv. Code";

                //Depot ID++
                Clear(L_DepotID);
                L_ShippingAgent.Reset();
                L_ShippingAgent.SetRange(Code, L_SalesInvoiceHeader."Weekend Shipping Agent Code");
                if L_ShippingAgent.FindFirst() then begin
                    if L_ShippingAgent."ePOD ID" = 0 then
                        exit('');
                    L_DepotID := L_ShippingAgent."ePOD ID";
                end;
            end else begin
                //Name++
                L_Name := L_SalesInvoiceHeader."Shipping Agent Service Code";

                //Depot ID++
                Clear(L_DepotID);
                L_ShippingAgent.Reset();
                L_ShippingAgent.SetRange(Code, L_SalesInvoiceHeader."Shipping Agent Code");
                if L_ShippingAgent.FindFirst() then begin
                    if L_ShippingAgent."ePOD ID" = 0 then
                        exit('');
                    L_DepotID := L_ShippingAgent."ePOD ID";
                end;
            end;



            //Get Date+++
            if L_SalesInvoiceHeader."Shipment Date" = 0D then
                exit('');
            Clear(L_Date);
            L_Date := Format(L_SalesInvoiceHeader."Shipment Date", 0, '<Year4>-<Month,2>-<Day,2>');

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


            HeaderRequest := StrSubstNo('{"name":"%1","depot":%2,"date":"%3","driver":%4}', L_Name, L_DepotID, L_finalDate, 'null');
            exit(HeaderRequest);
        end;
    end;

    local procedure IsRunAvailable(_SalesInvoiceNumber: Code[20]): Boolean
    var
        L_SalesInvoiceHeader: Record "Sales Invoice Header";
        L_ePODRun: Record "ePOD Runs";
    begin
        L_SalesInvoiceHeader.Reset();
        L_SalesInvoiceHeader.SetRange("No.", _SalesInvoiceNumber);
        if L_SalesInvoiceHeader.FindFirst() then begin
            L_ePODRun.Reset();
            L_ePODRun.SetRange(Date, L_SalesInvoiceHeader."Shipment Date");
            //L_ePODRun.SetRange("Location Code", L_SalesInvoiceHeader."Location Code");
            if L_SalesInvoiceHeader."Weekend Shipping Agent Code" <> '' then begin
                L_ePODRun.SetRange("Agent Code", L_SalesInvoiceHeader."Weekend Shipping Agent Code");
                L_ePODRun.SetRange("Agent Service Code", L_SalesInvoiceHeader."Weekend Ship. Agnt. Serv. Code");
            end else begin
                L_ePODRun.SetRange("Agent Code", L_SalesInvoiceHeader."Shipping Agent Code");
                L_ePODRun.SetRange("Agent Service Code", L_SalesInvoiceHeader."Shipping Agent Service Code");
            end;
            L_ePODRun.SetFilter("Run ID", '<>%1', 0);
            L_ePODRun.SetFilter("Depot ID", '<>%1', 0);
            if L_ePODRun.FindFirst() then
                exit(true)
            else
                exit(false);
        end;
    end;


    local procedure PostJobToePOD(_SalesInvoiceNumber: Code[20]; ChannelCode: Code[10])
    var
        L_SalesInvoiceHeader: Record "Sales Invoice Header";
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
    begin
        L_SalesInvoiceHeader.Reset();
        L_SalesInvoiceHeader.SetRange("No.", _SalesInvoiceNumber);
        if L_SalesInvoiceHeader.FindFirst() then begin
            //Get Credential & URL Detail +++ 
            GetCredentials(ChannelCode);

            L_httpheaders := L_httpclient.DefaultRequestHeaders;
            L_URL := ServiceURL + 'jobs';
            L_httpheaders.Add('Accept', 'application/json');
            L_httpheaders.Add('Authorization', 'Bearer ' + SecretAccessKey);

            //Create Body+++
            Clear(body);
            body := Job_Body(L_SalesInvoiceHeader."No.", ChannelCode);
            if StrLen(body) = 0 then begin
                if GuiAllowed = true then
                    Error('Job is not synced');
                exit;
            end;

            //Post Order to POD portal++
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
                    JObject1 := GetJsonToken(jObject, 'job').AsObject();
                    JObject2 := GetJsonToken(jObject1, 'data').AsObject();

                    //Get ePOD ID+++
                    if JObject2.Contains('id') then begin
                        L_SalesInvoiceHeader."ePOD ID" := GetJsonvalue(JObject2, 'id').AsInteger();
                        ModificationRequired := true;
                    end else
                        ModificationRequired := false;

                    //Get ePOD ID+++
                    if JObject2.Contains('run') then begin
                        L_SalesInvoiceHeader."ePOD RunID" := GetJsonvalue(JObject2, 'run').AsInteger();
                        ModificationRequired := true;
                    end else
                        ModificationRequired := false;

                    //Get ePOD Status+++
                    Clear(L_Status);
                    L_Status := GetJsonvalue(JObject2, 'status').AsText();
                    if JObject2.Contains('status') then begin
                        if GetJsonvalue(JObject2, 'status').AsText() = 'allocated' then
                            L_SalesInvoiceHeader."ePOD Status" := L_SalesInvoiceHeader."ePOD Status"::Allocated
                        else
                            if GetJsonvalue(JObject2, 'status').AsText() = 'unallocated' then
                                L_SalesInvoiceHeader."ePOD Status" := L_SalesInvoiceHeader."ePOD Status"::Unallocated;
                        ModificationRequired := true;
                    end else
                        ModificationRequired := false;


                    //++
                    if ModificationRequired = true then begin
                        L_SalesInvoiceHeader.Modify();
                    end;
                end;
            end
        end;
    end;

    // local procedure Job_Body(_SalesInvoiceNumber: Code[20]; _ChannelCode: Code[50]): Text
    // var
    //     L_SalesInvoiceHeader: Record "Sales Invoice Header";
    //     L_Customer: Record Customer;
    //     L_CustomerSiteID: Code[50];
    //     L_CustomerePODID: Code[50];
    //     L_Location: Record Location;
    //     L_LocationePODID: Code[50];
    //     L_TemplateID: Code[50];
    //     TradePartner: Record "Trade Partner";
    //     L_SalesInvoiceLine: Record "Sales Invoice Line";
    //     FinalTextRequest: Text;
    //     HeaderRequest: Text;
    //     LineValue: Text;
    //     LineRequest: Text;

    // begin
    //     Clear(L_CustomerSiteID);
    //     Clear(L_CustomerePODID);
    //     Clear(L_LocationePODID);
    //     Clear(L_TemplateID);


    //     Clear(HeaderRequest);
    //     L_SalesInvoiceHeader.Reset();
    //     L_SalesInvoiceHeader.SetRange("No.", _SalesInvoiceNumber);
    //     if L_SalesInvoiceHeader.FindFirst() then begin
    //         //Get Site++
    //         Clear(L_CustomerSiteID);
    //         Clear(L_CustomerePODID);
    //         L_Customer.Reset();
    //         L_Customer.SetRange("No.", L_SalesInvoiceHeader."Sell-to Customer No.");
    //         if L_Customer.FindFirst() then begin
    //             L_CustomerePODID := L_Customer."ePOD ID";
    //             L_CustomerSiteID := L_Customer."Customer Site ID";
    //         end;

    //         //Get Location+++
    //         Clear(L_LocationePODID);
    //         L_Location.Reset();
    //         L_Location.SetRange(Code, L_SalesInvoiceHeader."Location Code");
    //         if L_Location.FindFirst() then begin
    //             L_LocationePODID := L_Location."ePOD ID";
    //         end;

    //         //Get Teplate ID
    //         Clear(L_TemplateID);
    //         TradePartner.RESET;
    //         if TradePartner.Get(_ChannelCode) then begin
    //             L_TemplateID := TradePartner."ePOD Template ID";
    //         end;

    //         //Create Header++
    //         HeaderRequest := StrSubstNo('{"site":"%1","customer":"%2","depot":"%3","template":"%4","run":%5,"dueByStart":"%6","dueBy":"%7"'
    //         + ',"instructions1":"%8","instructions2":"%9","provisional":%10,"dropTime":%11,"dropSequence":%12,"price":"%13",', L_CustomerSiteID, L_CustomerePODID, L_LocationePODID, L_TemplateID, 'null', CurrentDateTime, CurrentDateTime, '', '', 'true', '5', '12', L_SalesInvoiceHeader.Amount);


    //         Clear(LineValue);
    //         Clear(LineRequest);
    //         L_SalesInvoiceLine.Reset();
    //         L_SalesInvoiceLine.SetRange("Document No.", L_SalesInvoiceHeader."No.");
    //         L_SalesInvoiceLine.SetFilter(Quantity, '>%1', 0);
    //         L_SalesInvoiceLine.SetRange(Type, L_SalesInvoiceLine.Type::Item);
    //         if L_SalesInvoiceLine.FindSet() then begin
    //             repeat
    //                 if LineValue = '' then begin
    //                     LineValue := StrSubstNo('{"name":"%1","merchGroup":"%2","productCode":"%3","price":"%4","weight":"%5","quantity":"%6","qtyDecimalPlaces":"%7","productBarcode":"%8"}', L_SalesInvoiceLine.Description, 'Bags', L_SalesInvoiceLine."No.", L_SalesInvoiceLine.Amount, L_SalesInvoiceLine."Gross Weight", L_SalesInvoiceLine.Quantity, '1', '');
    //                 end else begin
    //                     LineValue := LineValue + ',' + StrSubstNo('{"name":"%1","merchGroup":"%2","productCode":"%3","price":"%4","weight":"%5","quantity":"%6","qtyDecimalPlaces":"%7","productBarcode":"%8"}', L_SalesInvoiceLine.Description, 'Bags', L_SalesInvoiceLine."No.", L_SalesInvoiceLine.Amount, L_SalesInvoiceLine."Gross Weight", L_SalesInvoiceLine.Quantity, '1', '')
    //                 end;
    //             until L_SalesInvoiceLine.Next() = 0;
    //             LineRequest := '"items":[' + LineValue + ']'
    //         end else
    //             exit('');

    //         Clear(FinalTextRequest);
    //         FinalTextRequest := HeaderRequest + LineRequest + '}';
    //         exit(FinalTextRequest);
    //     end;
    // End;
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
        L_Runs: Record "ePOD Runs";
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
    begin
        L_SalesInvoiceHeader.Reset();
        L_SalesInvoiceHeader.SetRange("No.", _SalesInvoiceNumber);
        if L_SalesInvoiceHeader.FindFirst() then begin
            L_SalesInvoiceHeader.CalcFields(Amount, "Weekend Drop Number", "Drop Number");

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
            if L_SalesInvoiceHeader."ePOD RunID" <> 0 then begin
                L_ePODRunID := L_SalesInvoiceHeader."ePOD RunID";
            end else begin
                L_Runs.Reset();
                //L_Runs.SetRange("Location Code", L_SalesInvoiceHeader."Location Code");
                IF L_SalesInvoiceHeader."Weekend Shipping Agent Code" <> '' then begin
                    L_Runs.SetRange("Agent Code", L_SalesInvoiceHeader."Weekend Shipping Agent Code");
                    L_Runs.SetRange("Agent Service Code", L_SalesInvoiceHeader."Weekend Ship. Agnt. Serv. Code");
                end ELSE begin
                    L_Runs.SetRange("Agent Code", L_SalesInvoiceHeader."Shipping Agent Code");
                    L_Runs.SetRange("Agent Service Code", L_SalesInvoiceHeader."Shipping Agent Service Code");
                end;
                L_Runs.SetRange(Date, L_SalesInvoiceHeader."Shipment Date");
                L_Runs.SetFilter("Run ID", '<>%1', 0);
                if L_Runs.FindFirst() then begin
                    L_ePODRunID := L_Runs."Run ID";
                end;
            end;

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
                        //Get No of Box++
                        Clear(L_NoOfBox);
                        L_ValueEntry.Reset();
                        L_ValueEntry.SetCurrentKey("Document No.");
                        L_ValueEntry.SetRange("Document No.", L_SalesInvoiceLine."Document No.");
                        L_ValueEntry.SetRange("Document Type", L_ValueEntry."Document Type"::"Sales Invoice");
                        L_ValueEntry.SetRange("Document Line No.", L_SalesInvoiceLine."Line No.");
                        if L_ValueEntry.FindFirst() then begin
                            repeat
                                if L_NoOfBox <> 0 then
                                    break;
                                L_ItemLedgEntry.Get(L_ValueEntry."Item Ledger Entry No.");
                                if L_ItemLedgEntry."Document Type" = L_ItemLedgEntry."Document Type"::"Sales Shipment" then
                                    if L_SalesShipmentHeader.Get(L_ItemLedgEntry."Document No.") then begin
                                        L_NoOfBox := L_SalesShipmentHeader."No of Boxes";
                                    end;
                            until L_ValueEntry.Next() = 0;
                        end;

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
                        LineObj.Add('quantity', L_NoOfBox);
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


    procedure GetJobAndUpdateSalesInvoice(_SalesInvoiceNumber: Code[20]; _ChannelCode: Code[50]; var _ErrorMessage: Text)
    var
        L_salesInvoiceHeader: Record "Sales Invoice Header";
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
        CheckMandatoryfieldForJob(_ChannelCode);

        L_salesInvoiceHeader.Reset();
        if _SalesInvoiceNumber <> '' then
            L_salesInvoiceHeader.SetRange("No.", _SalesInvoiceNumber);
        L_salesInvoiceHeader.SetFilter("ePOD ID", '<>%1', 0);
        L_SalesInvoiceHeader.SetCurrentKey("Shipment Date");
        L_SalesInvoiceHeader.Ascending(true);
        if L_salesInvoiceHeader.FindSet() then begin
            repeat
                //Get Credential & URL Detail +++ 
                GetCredentials(_ChannelCode);

                L_httpheaders := L_httpclient.DefaultRequestHeaders;
                L_URL := ServiceURL + 'jobs/' + Format(L_salesInvoiceHeader."ePOD ID");
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
                        if JObject1.Contains('status') then begin
                            if GetJsonvalue(JObject1, 'status').AsText() = 'allocated' then
                                L_SalesInvoiceHeader."ePOD Status" := L_SalesInvoiceHeader."ePOD Status"::Allocated
                            else
                                if GetJsonvalue(JObject1, 'status').AsText() = 'unallocated' then
                                    L_SalesInvoiceHeader."ePOD Status" := L_SalesInvoiceHeader."ePOD Status"::Unallocated
                                else
                                    if GetJsonvalue(JObject1, 'status').AsText() = 'pending' then
                                        L_SalesInvoiceHeader."ePOD Status" := L_SalesInvoiceHeader."ePOD Status"::Pending
                                    else
                                        if GetJsonvalue(JObject1, 'status').AsText() = 'deleted' then
                                            L_SalesInvoiceHeader."ePOD Status" := L_SalesInvoiceHeader."ePOD Status"::Deleted
                                        else
                                            if GetJsonvalue(JObject1, 'status').AsText() = 'cancelled' then
                                                L_SalesInvoiceHeader."ePOD Status" := L_SalesInvoiceHeader."ePOD Status"::Cancelled
                                            else
                                                if GetJsonvalue(JObject1, 'status').AsText() = 'on_run' then
                                                    L_SalesInvoiceHeader."ePOD Status" := L_SalesInvoiceHeader."ePOD Status"::On_Run
                                                else
                                                    if GetJsonvalue(JObject1, 'status').AsText() = 'on_handheld' then
                                                        L_SalesInvoiceHeader."ePOD Status" := L_SalesInvoiceHeader."ePOD Status"::On_Handheld
                                                    else
                                                        if GetJsonvalue(JObject1, 'status').AsText() = 'completed' then
                                                            L_SalesInvoiceHeader."ePOD Status" := L_SalesInvoiceHeader."ePOD Status"::Completed
                                                        else
                                                            if GetJsonvalue(JObject1, 'status').AsText() = 'unknown' then
                                                                L_SalesInvoiceHeader."ePOD Status" := L_SalesInvoiceHeader."ePOD Status"::Unknown;

                            ModificationRequired := true;
                        end else
                            ModificationRequired := false;


                        //++
                        if ModificationRequired = true then begin
                            if L_SalesInvoiceHeader."ePOD Status" = L_SalesInvoiceHeader."ePOD Status"::Deleted then begin
                                if L_SalesInvoiceHeader."ePOD Job Consolidated" = false then begin
                                    L_SalesInvoiceHeader."ePOD ID" := 0;
                                    L_SalesInvoiceHeader."ePOD RunID" := 0;
                                end else begin
                                    //Message('Job is deleted in ePOD Father but you cannot resend the Invoice %1 to POD Father because this invoice has already been consolidated and sent. To proceed, delete the Loading Job and try again.', L_SalesInvoiceHeader."No.")
                                    _ErrorMessage := 'Job is deleted in ePOD Father but you cannot resend the Invoice to POD Father because the invoice has already been consolidated and sent. To proceed, delete the Loading Job and try again.';
                                end;
                            end;
                            L_SalesInvoiceHeader.Modify();
                        end;
                    end;
                end;

            until L_salesInvoiceHeader.Next() = 0;
        end;
    end;


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
        CheckMandatoryfieldForJob(_ChannelCode);

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

    procedure UpdateePODJobConsolidatedFeild_PostedsalesInvoiceHeader(_InvoiceNumber: Code[20])
    var
        L_PostedSalesInvoiceHeader: Record "Sales Invoice Header";
    begin
        L_PostedSalesInvoiceHeader.Reset();
        L_PostedSalesInvoiceHeader.SetRange("No.", _InvoiceNumber);
        if L_PostedSalesInvoiceHeader.FindFirst() then begin
            L_PostedSalesInvoiceHeader."ePOD Job Consolidated" := false;
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
            if OrderFilter."Shipment Date" = 0D then
                Error('Please enter a valid Shipment Date');

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
            if Confirm(StrSubstNo('You have selected Shipment Date "%1" and Shipping Agent Code "%2" and Shipping Agent Service Code "%3" and Shipping Agent Service Code "%4". Are you sure you want to continue?', OrderFilter."Shipment Date", OrderFilter."Shipping Agent Code", OrderFilter."Shipping Agent Service Code")) then begin
                Windows.OPEN('Generating Orders..' + ' @1@@@@@@@@@@@@@\' + 'Please Wait..');

                Clear(L_SalesInvoiceHeader);
                L_SalesInvoiceHeader.Reset();
                L_SalesInvoiceHeader.SetRange("Shipment Date", OrderFilter."Shipment Date");
                L_SalesInvoiceHeader.SetRange("Customer Synced", OrderFilter."Customer Sync");
                L_SalesInvoiceHeader.SetRange("Route Synced", OrderFilter."Route Sync");
                L_SalesInvoiceHeader.SetFilter("ePOD ID", '%1', 0);
                if OrderFilter."Weekend Shipping Agent Code" <> '' then begin
                    L_SalesInvoiceHeader.SetRange("Weekend Shipping Agent Code", OrderFilter."Shipping Agent Code");
                    L_SalesInvoiceHeader.SetFilter("Weekend Ship. Agnt. Serv. Code", OrderFilter."Shipping Agent Service Code");
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
                        Job_OnPODFatherPortal(L_SalesInvoiceHeader."No.", 'EPOD')
                    until L_SalesInvoiceHeader.Next() = 0;

                    //Final Message++
                    Message('Process Completed');
                end;
            end;
        end;
    end;
    #EndRegion Job+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

    #Region Consolidated Job++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    procedure ConsolidatedJob_OnPODFatherPortal(ChannelCode: Code[20]; _ePODJobHeader: Record "ePOD Job Header");
    var
        L_ePODJobHeader: Record "ePOD Job Header";
    begin
        //Clear All Variable +++
        ClearAll();

        //Check Mandatory fields+++
        CheckMandatoryfieldForJob(ChannelCode);

        //Create Job+++
        L_ePODJobHeader.SetRange("No.", _ePODJobHeader."No.");
        if L_ePODJobHeader.FindFirst() then begin
            PostConsolidatedJobToePOD(L_ePODJobHeader."No.", ChannelCode);
        end;
    end;



    local procedure PostConsolidatedJobToePOD(_JobNo: Code[20]; ChannelCode: Code[10])
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
    begin
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
                if GuiAllowed = true then
                    Error('LoadingJob is not synced');
                exit;
            end;

            //Post Order to POD portal++
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
                end;
            end
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
        L_Runs: Record "ePOD Runs";
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
    #EndRegion Consolidated Job++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++



    #Region Common function++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    procedure CreateConsolidatedJob(_ePODRunID: Integer; _ShipmentDate: Date; _ShippingAgentCode: Code[20]; _ShippingAgentServiceCode: Code[20]; _HeaderRequired: Boolean)
    var
        L_SalesInvoiceHeader: Record "Sales Invoice Header";
    begin
        Clear(G_OrderNo);
        L_SalesInvoiceHeader.Reset();
        L_SalesInvoiceHeader.SetRange("ePOD Job Consolidated", false);
        L_SalesInvoiceHeader.SetRange("ePOD RunID", _ePODRunID);
        L_SalesInvoiceHeader.SetRange("Shipment Date", _ShipmentDate);
        L_SalesInvoiceHeader.SetFilter("ePOD ID", '>%1', 0);
        if L_SalesInvoiceHeader.FindSet() then begin
            repeat
                if L_SalesInvoiceHeader."Weekend Shipping Agent Code" <> '' then begin
                    if L_SalesInvoiceHeader."Weekend Shipping Agent Code" = _ShippingAgentCode then
                        CreateHeaderAndLine(L_SalesInvoiceHeader."No.", _ShippingAgentCode, _ShippingAgentServiceCode, _ShipmentDate, _ePODRunID, _HeaderRequired);
                end else begin
                    if L_SalesInvoiceHeader."Shipping Agent Code" = _ShippingAgentCode then
                        CreateHeaderAndLine(L_SalesInvoiceHeader."No.", _ShippingAgentCode, _ShippingAgentServiceCode, _ShipmentDate, _ePODRunID, _HeaderRequired);
                end;
                _HeaderRequired := false;
            until L_SalesInvoiceHeader.Next() = 0;
        end;
    end;


    local procedure CreateHeaderAndLine(_InvoiceNo: Code[20]; _ShippingAgentCode: Code[20]; _ShippingAgentServiceCode: Code[20]; _ShipmentDate: Date; _ePODRunID: Integer; _HeaderRequired: Boolean)
    var
        L_SalesInvoiceHeader: Record "Sales Invoice Header";
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
        L_SalesAndReceivablesSetup: Record "Sales & Receivables Setup";
        NoSeriesManagement: Codeunit "No. Series";
        L_Group: Text;
        L_Item: Record Item;
        L_WarhouseClass: Record "Warehouse Class";
    begin
        //Get No Seies Setup++
        L_SalesAndReceivablesSetup.Get();
        L_SalesAndReceivablesSetup.TestField("ePOD Job Nos");

        L_SalesInvoiceHeader.Reset();
        L_SalesInvoiceHeader.SetRange("No.", _InvoiceNo);
        if L_SalesInvoiceHeader.FindFirst() then begin
            //Create Header++
            if _HeaderRequired = true then begin
                L_ePODRunHeader.Init();
                L_ePODRunHeader."No." := NoSeriesManagement.GetNextNo(L_SalesAndReceivablesSetup."ePOD Job Nos", TODAY, TRUE);
                L_ePODRunHeader."ePOD RunID" := _ePODRunID;
                L_ePODRunHeader."Shipment Date" := _ShipmentDate;
                L_ePODRunHeader."Shipping Agent Code" := _ShippingAgentCode;
                L_ePODRunHeader."Shipping Agent Service Code" := _ShippingAgentServiceCode;
                L_ePODRunHeader."Customer PO" := 'SIGMA';
                L_ePODRunHeader."Consolidated Date & Time" := CurrentDateTime;
                L_ePODRunHeader."Synced to ePOD" := false;
                L_ePODRunHeader.Insert();
                G_OrderNo := L_ePODRunHeader."No.";
            end;
            L_SalesInvoiceHeader."ePOD Job Consolidated" := true;
            L_SalesInvoiceHeader.Modify();


            //Create Line++
            Clear(L_Group);
            L_ePODRunHeader.Reset();
            L_ePODRunHeader.SetRange("No.", G_OrderNo);
            if L_ePODRunHeader.FindFirst() then begin
                L_Location.Reset();
                L_Location.SetRange(Code, L_SalesInvoiceHeader."Location Code");
                if L_Location.FindFirst() then begin
                    //For Non KNAPP Lines+++
                    if L_Location."Knapp Location" = false then begin
                        L_SalesInvoiceLine.Reset();
                        L_SalesInvoiceLine.SetRange("Document No.", L_SalesInvoiceHeader."No.");
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
                            Clear(L_NoOfBox);
                            L_ValueEntry.Reset();
                            L_ValueEntry.SetCurrentKey("Document No.");
                            L_ValueEntry.SetRange("Document No.", L_SalesInvoiceLine."Document No.");
                            L_ValueEntry.SetRange("Document Type", L_ValueEntry."Document Type"::"Sales Invoice");
                            L_ValueEntry.SetRange("Document Line No.", L_SalesInvoiceLine."Line No.");
                            if L_ValueEntry.FindFirst() then begin
                                repeat
                                    if L_NoOfBox <> 0 then
                                        break;
                                    L_ItemLedgEntry.Get(L_ValueEntry."Item Ledger Entry No.");
                                    if L_ItemLedgEntry."Document Type" = L_ItemLedgEntry."Document Type"::"Sales Shipment" then
                                        if L_SalesShipmentHeader.Get(L_ItemLedgEntry."Document No.") then begin
                                            L_NoOfBox := L_SalesShipmentHeader."No of Boxes";
                                        end;
                                until L_ValueEntry.Next() = 0;
                            end;

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
                            L_ePODRunLine."BC Invoice Number" := L_SalesInvoiceHeader."No.";
                            L_ePODRunLine.Group := L_Group;
                            L_ePODRunLine."Product Code" := L_SalesInvoiceHeader."Order No.";
                            L_ePODRunLine.Description := L_Group;
                            L_ePODRunLine.Quantity := L_NoOfBox;
                            L_ePODRunLine.Insert();
                        end;
                    end else begin
                        //For KNAPP lines+++
                        L_SalesInvoiceLine.Reset();
                        L_SalesInvoiceLine.SetRange("Document No.", L_SalesInvoiceHeader."No.");
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
                                        L_ePODRunLine."BC Invoice Number" := L_SalesInvoiceHeader."No.";
                                        L_ePODRunLine.Group := '1TOTE';
                                        L_ePODRunLine."Product Code" := L_KnappOrderResponse."Load Unit";
                                        L_ePODRunLine.Description := '1TOTE';
                                        L_ePODRunLine.Quantity := 1;
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
    end;

    procedure GetJsonToken(var JsonObject: JsonObject; TokenKey: text) JsonToken: JsonToken;
    begin
        if not JsonObject.Get(TokenKey, JsonToken) then;
    end;

    procedure GetJsonvalue(var aJsonObject: JsonObject; TokenKey: text) aJsonValue: JsonValue;
    var
        aJsonToken: JsonToken;
    begin
        if not aJsonObject.Get(TokenKey, aJsonToken) then
            Error('Could not find a token with key %1', TokenKey)
        Else
            aJsonValue := aJsonToken.AsValue();
    end;


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

    local procedure CheckMandatoryfieldForJob(ChannelCode: Code[10])
    var
        TradePartner: Record "Trade Partner";
    begin
        TradePartner.RESET;
        if TradePartner.Get(ChannelCode) then begin
            TradePartner.TestField("ePOD Template ID");
            TradePartner.TestField(SecretAccessKey);
            TradePartner.TestField("Sevice/API URL");
        End else
            Error('Channel Partner Missing');
    end;

    #EndRegion Common function++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++




    var
        myInt: Integer;
        StartParameter: Text;
        RunType: Text;
        SecretAccessKey: text;
        ServiceURL: Text;
        G_OrderNo: Code[20];


}