codeunit 90075 "Big Commerce"
{
    TableNo = "Job Queue Entry";

    trigger OnRun()
    begin
        IF (STRPOS(Rec."Parameter String", ';')) > 0 THEN begin
            StartParameter := COPYSTR(Rec."Parameter String", 1, (STRPOS(Rec."Parameter String", ';') - 1));
            RunType := COPYSTR(Rec."Parameter String", (STRPOS(Rec."Parameter String", ';') + 1), (STRLEN(Rec."Parameter String") - STRPOS(Rec."Parameter String", ';')));
        end;

        CASE RunType OF
            SyncOrderLabel:
                BEGIN

                End;
            SyncItemLabel:
                Begin
                    SyncBigCommerceItems(StartParameter, '');
                    SyncBigCommerceItemsOnPortal(StartParameter);
                    //UpdateStocksLevel(StartParameter);
                End;
            UpdateInventoryLabel:
                begin
                    //To Update Channel Item Listings From Item 
                    //UpdateChannelItemListing(StartParameter);
                    //Update Inventory and Price
                    UpdateInventoryPrice(StartParameter);
                end;
        end;
    end;

    var
        StartParameter: Text;
        RunType: Text;
        SyncItemLabel: Label 'SyncItem';
        SyncOrderLabel: Label 'SyncOrder';
        UpdateInventoryLabel: Label 'UpdateInventory';
        ServiceURL: Text;
        AccessToken: Text;
        SKU: Text;
        VariantSKU: Text;
        ItemId: Integer;
        VariantId: Integer;
        VariantBody: Text;


    local procedure GetCredentials(ChannelCode: Code[10])
    var
        TradePartner: Record "Trade Partner";
    begin
        if TradePartner.Get(ChannelCode) then begin
            ServiceURL := TradePartner."Sevice/API URL";
            AccessToken := TradePartner.SecretAccessKey;
        end;
    end;


    procedure SyncBigCommerceItems(ChannelCode: Code[10]; NextURL: Text)
    var
        inventoryClient: HttpClient;
        inventoryHeaders: HttpHeaders;
        inventoryContent: HttpContent;
        inventoryResponseMessage: HttpResponseMessage;
        response: Text;
        JObject: JsonObject;
        DataArray: JsonArray;
        MetaObject: JsonObject;
        Meta_PaginationObject: JsonObject;
        Meta_Pagination_LinkObject: JsonObject;
        InventoryCount: Integer;
        i: Integer;
        InventoryToken: JsonToken;
        InventoryObject: JsonObject;
        ChannelItemListing: Record "Channel Item Listing";
        L_TradePartner: Record "Trade Partner";
        //Variant Related Variables
        VariantClient: HttpClient;
        VariantHeaders: HttpHeaders;
        VariantContent: HttpContent;
        VariantResponseMessage: HttpResponseMessage;
        Variantresponse: Text;
        VariantURL: Text;
        VariantJObject: JsonObject;
        VariantDataArray: JsonArray;
        VariantJToken: JsonToken;
        VariantdataObject: JsonObject;
        j: Integer;
        L_ChannelItemListing: Record "Channel Item Listing";
    begin
        GetCredentials(ChannelCode);

        inventoryHeaders := inventoryClient.DefaultRequestHeaders;
        inventoryHeaders.Add('X-Auth-Token', AccessToken);
        inventoryContent.GetHeaders(inventoryHeaders);
        inventoryHeaders.Clear();
        inventoryHeaders.Add('Content-Type', 'application/json');

        if NextURL <> '' then begin
            ServiceURL := ServiceURL + '/v3/catalog/products' + NextURL;
        end
        else begin
            ServiceURL := ServiceURL + '/v3/catalog/products';
        end;

        if inventoryClient.Get(ServiceURL, inventoryResponseMessage) then begin
            if inventoryResponseMessage.HttpStatusCode = 200 then begin
                inventoryResponseMessage.Content.ReadAs(response);
                JObject.ReadFrom(response);

                //Getting Inventory Data Array
                DataArray := GetJsonToken(JObject, 'data').AsArray();

                //Getting Next URL Data Object
                MetaObject := GetJsonToken(JObject, 'meta').AsObject();
                Meta_PaginationObject := GetJsonToken(MetaObject, 'pagination').AsObject();
                Meta_Pagination_LinkObject := GetJsonToken(Meta_PaginationObject, 'links').AsObject();

                //Checking if Next URL is Available or not
                //If Available Retrieving it
                if Meta_Pagination_LinkObject.Contains('next') then begin
                    if GetJsonvalue(Meta_Pagination_LinkObject, 'next').IsNull = false then begin
                        NextURL := GetJsonvalue(Meta_Pagination_LinkObject, 'next').AsText();
                    end;
                end
                else begin
                    NextURL := '';
                end;

                //Getting Count of Inventories For Current Page
                if GetJsonvalue(Meta_PaginationObject, 'count').IsNull = false then begin
                    InventoryCount := GetJsonvalue(Meta_PaginationObject, 'count').AsInteger();
                end;

                if InventoryCount > 0 then begin
                    for i := 0 to InventoryCount - 1 do begin
                        DataArray.Get(i, InventoryToken);
                        InventoryObject := InventoryToken.AsObject();

                        //Getting SKU
                        if GetJsonvalue(InventoryObject, 'sku').IsNull = false then begin
                            Clear(SKU);
                            SKU := GetJsonvalue(InventoryObject, 'sku').AsText();
                        end;

                        if GetJsonvalue(InventoryObject, 'id').IsNull = false then begin
                            Clear(ItemId);
                            ItemId := GetJsonvalue(InventoryObject, 'id').AsInteger();
                        end;

                        ChannelItemListing.Reset();
                        ChannelItemListing.SetRange("Channel Code", ChannelCode);
                        ChannelItemListing.SetRange("ASIN No", Format(ItemId));
                        if ChannelItemListing.FindFirst() then begin
                            //Update Existing Channel Item Listing
                            CreateMainChannelItemListing(false, InventoryObject, ChannelCode);
                        end
                        else begin
                            //Create New Channel Item Listing
                            CreateMainChannelItemListing(true, InventoryObject, ChannelCode);
                        end;

                        //Variant Syncing Code
                        if ItemId <> 0 then begin
                            GetCredentials(ChannelCode);

                            Clear(VariantHeaders);
                            Clear(VariantClient);
                            Clear(VariantContent);

                            VariantHeaders := VariantClient.DefaultRequestHeaders;
                            VariantHeaders.Add('X-Auth-Token', AccessToken);
                            VariantContent.GetHeaders(VariantHeaders);
                            VariantHeaders.Clear();
                            VariantHeaders.Add('Content-Type', 'application/json');

                            VariantURL := StrSubstNo('%1/v3/catalog/products/%2/variants', ServiceURL, ItemId);

                            if VariantClient.Get(VariantURL, VariantResponseMessage) then begin
                                if VariantResponseMessage.HttpStatusCode = 200 then begin
                                    VariantResponseMessage.Content.ReadAs(Variantresponse);
                                    VariantJObject.ReadFrom(Variantresponse);
                                    VariantDataArray := GetJsonToken(VariantJObject, 'data').AsArray();
                                    if VariantDataArray.Count > 0 then begin
                                        for j := 0 to VariantDataArray.Count - 1 do begin
                                            VariantDataArray.Get(j, VariantJToken);
                                            VariantdataObject := VariantJToken.AsObject();

                                            if GetJsonvalue(VariantdataObject, 'id').IsNull = false then begin
                                                Clear(VariantId);
                                                VariantId := GetJsonvalue(VariantdataObject, 'id').AsInteger();
                                            end;

                                            L_ChannelItemListing.Reset();
                                            L_ChannelItemListing.SetRange("Channel Code", ChannelCode);
                                            L_ChannelItemListing.SetRange("ASIN No", Format(VariantId));
                                            if L_ChannelItemListing.FindFirst() then begin
                                                //Update Existing Variant Channel Item Listing
                                                CreateVariantChannelItemListing(false, VariantdataObject, ChannelCode);
                                            end
                                            else begin
                                                //Insert New Variant Channel Item Listing
                                                CreateVariantChannelItemListing(true, VariantdataObject, ChannelCode);
                                            end;
                                        end;
                                    end;
                                end;
                            end;
                        end;
                    end;
                end;
            end
            else begin
                inventoryResponseMessage.Content.ReadAs(response);
                Message(response);
            end;
        end;

        if NextURL <> '' then
            SyncBigCommerceItems(ChannelCode, NextURL);

        if NextURL = '' then begin
            L_TradePartner.Reset();
            L_TradePartner.SetRange(Code, ChannelCode);
            if L_TradePartner.FindFirst() then begin
                L_TradePartner.Validate("Last Product Sync", CreateDateTime(WorkDate, Time));
                L_TradePartner.Modify(true);
            end;
            Message('Inventory Sync Complete');
        end;
    end;


    local procedure CreateMainChannelItemListing(Bool: Boolean; var InventoryObject: JsonObject; ChannelCode: Code[10])
    var
        ChannelItemListing: Record "Channel Item Listing";
        Description: Text;
        Weight: Decimal;
        Price: Decimal;
        Inventory: Integer;
    begin
        Clear(Description);
        Clear(Weight);
        Clear(Price);
        Clear(Inventory);

        if GetJsonvalue(InventoryObject, 'name').IsNull = false then begin
            Description := GetJsonvalue(InventoryObject, 'name').AsText();
        end;

        if GetJsonvalue(InventoryObject, 'weight').IsNull = false then begin
            Weight := GetJsonvalue(InventoryObject, 'weight').AsDecimal();
        end;

        if GetJsonvalue(InventoryObject, 'price').IsNull = false then begin
            Price := GetJsonvalue(InventoryObject, 'price').AsDecimal();
        end;

        if GetJsonvalue(InventoryObject, 'inventory_level').IsNull = false then begin
            Inventory := GetJsonvalue(InventoryObject, 'inventory_level').AsInteger();
        end;

        ChannelItemListing.Init();
        ChannelItemListing.Validate("Channel Code", ChannelCode);
        ChannelItemListing.Validate("Channel SKU", CopyStr(SKU, 1, 50));
        ChannelItemListing.Validate(Description, Description);
        ChannelItemListing.Validate("Unit Price", Price);
        ChannelItemListing.Validate("ASIN No", Format(ItemId));
        ChannelItemListing.Validate("Channel Inventory", Inventory);

        if Bool = true then begin
            ChannelItemListing.Validate("Created On", CurrentDateTime);
            ChannelItemListing.Validate("Listing Status", ChannelItemListing."Listing Status"::Listed);
            ChannelItemListing.Insert(true);
        end
        else begin
            ChannelItemListing.Validate("Modified On", CurrentDateTime);
            ChannelItemListing.Validate("Listing Status", ChannelItemListing."Listing Status"::Listed);
            ChannelItemListing.Modify(true);
        end;
    end;


    local procedure CreateVariantChannelItemListing(Bool: Boolean; var InventoryObject: JsonObject; ChannelCode: Code[10])
    var
        ChannelItemListing: Record "Channel Item Listing";
        Weight: Decimal;
        Price: Decimal;
        Inventory: Integer;
        UpdatedVariantId: Text;
        MainProductId: Integer;
    begin
        Clear(Weight);
        Clear(Price);
        Clear(Inventory);
        Clear(VariantSKU);
        Clear(MainProductId);

        if GetJsonvalue(InventoryObject, 'sku').IsNull = false then begin
            VariantSKU := GetJsonvalue(InventoryObject, 'sku').AsText();
        end;

        if StrLen(VariantSKU) = 10 then
            UpdatedVariantId := VariantSKU.Substring(7, 4);

        if GetJsonvalue(InventoryObject, 'weight').IsNull = false then begin
            Weight := GetJsonvalue(InventoryObject, 'weight').AsDecimal();
        end;

        if GetJsonvalue(InventoryObject, 'calculated_price').IsNull = false then begin
            Price := GetJsonvalue(InventoryObject, 'calculated_price').AsDecimal();
        end;

        if GetJsonvalue(InventoryObject, 'inventory_level').IsNull = false then begin
            Inventory := GetJsonvalue(InventoryObject, 'inventory_level').AsInteger();
        end;

        if GetJsonvalue(InventoryObject, 'product_id').IsNull = false then begin
            MainProductId := GetJsonvalue(InventoryObject, 'product_id').AsInteger();
        end;

        ChannelItemListing.Init();
        ChannelItemListing.Validate("Channel Code", ChannelCode);
        ChannelItemListing.Validate("Channel SKU", CopyStr(VariantSKU, 1, 50));
        ChannelItemListing.Validate("Unit Price", Price);
        ChannelItemListing.Validate("ASIN No", Format(VariantId));
        ChannelItemListing.Validate("Channel Variant", UpdatedVariantId);
        ChannelItemListing.Validate("Channel Inventory", Inventory);
        ChannelItemListing.Validate("Feed Submission ID", Format(MainProductId));

        if Bool = true then begin
            ChannelItemListing.Validate("Created On", CurrentDateTime);
            ChannelItemListing.Validate("Listing Status", ChannelItemListing."Listing Status"::Listed);
            ChannelItemListing.Insert(true);
        end
        else begin
            ChannelItemListing.Validate("Modified On", CurrentDateTime);
            ChannelItemListing.Validate("Listing Status", ChannelItemListing."Listing Status"::Listed);
            ChannelItemListing.Modify(true);
        end;
    end;


    //Upload Not Listed Channel Items Listing on Portal
    procedure SyncBigCommerceItemsOnPortal(ChannelCode: Code[10])
    var
        Client: HttpClient;
        Headers: HttpHeaders;
        Content: HttpContent;
        ResponseMessage: HttpResponseMessage;
        Request: Text;
        response: Text;
        MainProductRequest: Text;
        i: Integer;
        JObject: JsonObject;
        dataObject: JsonObject;
        variantsArray: JsonArray;
        variantToken: JsonToken;
        variantObject: JsonObject;
        variantSKU: Text;
        variantID: Integer;
        MainProductSKU: Text;
        MainProductId: Integer;
        RecCount: Integer;
        ErrorObject: JsonObject;
        L_ChannelItemListing: Record "Channel Item Listing";
        L_ChannelItemList: Record "Channel Item Listing";
        ChannelItemListing: Record "Channel Item Listing";
    begin
        //Getting List of Channel Items With BigCommerce Channel Code and Listing Status as Not Listed
        L_ChannelItemListing.Reset();
        L_ChannelItemListing.SetRange("Channel Code", ChannelCode);
        L_ChannelItemListing.SetRange("Listing Status", L_ChannelItemListing."Listing Status"::"Not Listed");
        if L_ChannelItemListing.FindSet() then begin
            repeat
                ClearAll();
                Clear(VariantBody);
                GetCredentials(ChannelCode);

                //Getting List of all Variants Channel Items With Current Records Item No.
                //L_ChannelItemList.Reset();
                L_ChannelItemList.SetRange("Item No.", L_ChannelItemListing."Item No.");
                //L_ChannelItemListing.SetRange("Item No.", '0115_0');
                L_ChannelItemListing.SetRange("Listing Status", L_ChannelItemListing."Listing Status"::"Not Listed");
                if L_ChannelItemListing.FindSet() then begin
                    RecCount := L_ChannelItemListing.Count;
                    repeat
                        //Main Product Request Body
                        if ((L_ChannelItemListing."NAV Variant" = '') and (L_ChannelItemListing."Channel Variant" = '')) then begin
                            Clear(MainProductRequest);
                            MainProductRequest := StrSubstNo('"name": "%1","price": "%2","categories": [],"weight": 1, "sku":"%3"', L_ChannelItemListing.Description, L_ChannelItemListing."Unit Price", L_ChannelItemListing."Channel SKU");
                        end;

                        //Variant Product Request Body
                        if ((L_ChannelItemListing."NAV Variant" <> '') and (L_ChannelItemListing."Channel Variant" <> '')) then begin
                            VariantBody += StrSubstNo('{"sku": "%1","option_values": [{"option_display_name": "Variant","label": "%2"}]},',
                            L_ChannelItemListing."Channel SKU", L_ChannelItemListing."NAV Variant");
                        end;
                    until L_ChannelItemListing.Next() = 0;

                    VariantBody := VariantBody.TrimEnd(',');
                    Headers := Client.DefaultRequestHeaders;
                    Headers.Add('X-Auth-Token', AccessToken);
                    Request := StrSubstNo('{%1,"type": "physical","variants": [%2]}', MainProductRequest, VariantBody);
                    Content.WriteFrom(Request);
                    Content.GetHeaders(Headers);
                    Headers.Clear();
                    Headers.Add('Content-Type', 'application/json');

                    ServiceURL := ServiceURL + '/v3/catalog/products';

                    if Client.Post(ServiceURL, Content, ResponseMessage) then begin
                        if ResponseMessage.HttpStatusCode = 200 then begin
                            ResponseMessage.Content.ReadAs(response);
                            JObject.ReadFrom(response);
                            dataObject := GetJsonToken(JObject, 'data').AsObject();

                            Clear(MainProductId);
                            if GetJsonvalue(dataObject, 'id').IsNull = false then begin
                                MainProductId := GetJsonvalue(dataObject, 'id').AsInteger();
                            end;

                            Clear(MainProductSKU);
                            if GetJsonvalue(dataObject, 'sku').IsNull = false then begin
                                MainProductSKU := GetJsonvalue(dataObject, 'sku').AsText();
                            end;

                            variantsArray := GetJsonToken(dataObject, 'variants').AsArray();
                            for i := 0 to variantsArray.Count - 1 do begin
                                variantsArray.Get(i, variantToken);
                                variantObject := variantToken.AsObject();

                                if GetJsonvalue(variantObject, 'sku').IsNull = false then begin
                                    Clear(variantSKU);
                                    variantSKU := GetJsonvalue(variantObject, 'sku').AsText();
                                end;

                                if GetJsonvalue(variantObject, 'id').IsNull = false then begin
                                    Clear(variantID);
                                    variantID := GetJsonvalue(variantObject, 'id').AsInteger();
                                end;

                                //Updating Variant ID on Channel Item Listing
                                ChannelItemListing.Reset();
                                ChannelItemListing.SetRange("Channel Code", ChannelCode);
                                ChannelItemListing.SetRange("Channel SKU", variantSKU);
                                if ChannelItemListing.FindFirst() then begin
                                    ChannelItemListing.Validate("Listing Status", ChannelItemListing."Listing Status"::Listed);
                                    ChannelItemListing.Validate("Listing Date", CurrentDateTime);
                                    ChannelItemListing.Remarks := '';
                                    ChannelItemListing.Modify(true);
                                    ChannelItemListing.Rename(ChannelCode, variantSKU, variantID, ChannelItemListing."Channel Variant");
                                end;

                                //Updating Main Product ID on Channel Item Listing
                                if i = variantsArray.Count - 1 then begin
                                    if MainProductSKU <> '' then begin
                                        ChannelItemListing.Reset();
                                        ChannelItemListing.SetRange("Channel Code", ChannelCode);
                                        ChannelItemListing.SetRange("Channel SKU", MainProductSKU);
                                        if ChannelItemListing.FindFirst() then begin
                                            ChannelItemListing.Validate("Listing Status", ChannelItemListing."Listing Status"::Listed);
                                            ChannelItemListing.Validate("Listing Date", CurrentDateTime);
                                            ChannelItemListing.Remarks := '';
                                            ChannelItemListing.Modify(true);
                                            ChannelItemListing.Rename(ChannelCode, MainProductSKU, MainProductId, '');
                                        end;
                                    end;
                                end;
                            end;
                        end
                        else begin
                            //Error Handling 
                            //Added Error Message to All the Main and Variant Products as well.
                            ResponseMessage.Content.ReadAs(response);
                            ErrorObject.ReadFrom(response);
                            if ErrorObject.Contains('title') then begin
                                L_ChannelItemList.Reset();
                                L_ChannelItemList.SetRange("Channel Code", ChannelCode);
                                L_ChannelItemList.SetRange("Item No.", L_ChannelItemListing."Item No.");
                                if L_ChannelItemList.FindSet() then begin
                                    repeat
                                        L_ChannelItemList.Remarks := StrSubstNo('%1 For %2', CopyStr(GetJsonvalue(ErrorObject, 'title').AsText(), 1, 100), L_ChannelItemList."Channel SKU");
                                        L_ChannelItemList.Modify();
                                    until L_ChannelItemList.Next() = 0;
                                end;
                            end;
                        end;
                    end;
                end;
            until L_ChannelItemListing.Next() = 0;
        end;
    end;


    procedure UpdateInventoryPrice(ChannelCode: Code[10])
    var
        StocksClient: HttpClient;
        StocksHeaders: HttpHeaders;
        StocksContent: HttpContent;
        StocksResponseMessage: HttpResponseMessage;
        StocksRequest: Text;
        Stocksresponse: Text;
        StocksURL: Text;
        L_ChannelItemListing: Record "Channel Item Listing";
        PriceClient: HttpClient;
        PriceHeaders: HttpHeaders;
        PriceContent: HttpContent;
        PriceResponseMessage: HttpResponseMessage;
        PriceRequest: Text;
        PriceResponse: Text;
        PriceURL: Text;
    begin
        L_ChannelItemListing.Reset();
        L_ChannelItemListing.SetRange("Channel Code", ChannelCode);
        L_ChannelItemListing.SetRange("Listing Status", L_ChannelItemListing."Listing Status"::Listed);
        L_ChannelItemListing.SetFilter("ASIN No", '<>%1', '');
        //L_ChannelItemListing.SetFilter("Item No.", '2779_7');
        if L_ChannelItemListing.FindSet() then begin
            repeat
                //Variant Update Inventory Code
                if L_ChannelItemListing."Channel Variant" <> '' then begin
                    Clear(StocksHeaders);
                    Clear(StocksClient);
                    Clear(StocksContent);
                    Clear(StocksRequest);
                    GetCredentials(ChannelCode);

                    StocksHeaders := StocksClient.DefaultRequestHeaders;
                    StocksHeaders.Add('X-Auth-Token', AccessToken);
                    StocksRequest := StrSubstNo('{"inventory_level": %1,"inventory_warning_level": 0}', L_ChannelItemListing."Channel Inventory");
                    StocksContent.WriteFrom(StocksRequest);
                    StocksContent.GetHeaders(StocksHeaders);
                    StocksHeaders.Clear();
                    StocksHeaders.Add('Content-Type', 'application/json');

                    Clear(StocksURL);
                    StocksURL := ServiceURL + '/v3/catalog/products/' + L_ChannelItemListing."Feed Submission ID" + '/variants/' + L_ChannelItemListing."ASIN No";

                    if StocksClient.Put(StocksURL, StocksContent, StocksResponseMessage) then begin
                        if StocksResponseMessage.HttpStatusCode = 200 then begin
                            L_ChannelItemListing.Remarks := StrSubstNo('Stocks Updated to %1 on %2', L_ChannelItemListing."Channel Inventory", CurrentDateTime);
                            L_ChannelItemListing."Modified On" := CurrentDateTime;
                            L_ChannelItemListing.Modify(true);
                        end
                        else begin
                            StocksResponseMessage.Content.ReadAs(Stocksresponse);
                            L_ChannelItemListing.Remarks := CopyStr(Stocksresponse, 1, 100);
                            L_ChannelItemListing."Modified On" := CurrentDateTime;
                            L_ChannelItemListing.Modify(true);
                        end;
                    end;
                end
                else begin
                    //Main Product Update Unit Price
                    Clear(PriceHeaders);
                    Clear(PriceClient);
                    Clear(PriceContent);
                    Clear(PriceRequest);
                    GetCredentials(ChannelCode);

                    PriceHeaders := PriceClient.DefaultRequestHeaders;
                    PriceHeaders.Add('X-Auth-Token', AccessToken);
                    PriceRequest := StrSubstNo('{"price": %1,"cost_price": %1,"retail_price": %1,"sale_price": %1}', L_ChannelItemListing."Unit Price");
                    PriceContent.WriteFrom(PriceRequest);
                    PriceContent.GetHeaders(PriceHeaders);
                    PriceHeaders.Clear();
                    PriceHeaders.Add('Content-Type', 'application/json');

                    Clear(PriceURL);
                    PriceURL := ServiceURL + '/v3/catalog/products/' + L_ChannelItemListing."ASIN No";

                    if PriceClient.Put(PriceURL, PriceContent, PriceResponseMessage) then begin
                        if PriceResponseMessage.HttpStatusCode = 200 then begin
                            L_ChannelItemListing.Remarks := StrSubstNo('Price Updated to %1 on %2', L_ChannelItemListing."Unit Price", CurrentDateTime);
                            L_ChannelItemListing."Modified On" := CurrentDateTime;
                            L_ChannelItemListing.Modify(true);
                        end
                        else begin
                            PriceResponseMessage.Content.ReadAs(PriceResponse);
                            L_ChannelItemListing.Remarks := CopyStr(PriceResponse, 1, 100);
                            L_ChannelItemListing."Modified On" := CurrentDateTime;
                            L_ChannelItemListing.Modify(true);
                        end;
                    end;
                end;

            until L_ChannelItemListing.Next() = 0;
        end;
        Message('Stocks and Prices Updated Successfully');
    end;


    local procedure UpdateChannelItemListing(ChannelCode: Code[10])
    var
        L_Item: Record Item;
        L_ChannelItemListing: Record "Channel Item Listing";
    begin
        L_ChannelItemListing.Reset();
        L_ChannelItemListing.SetRange("Channel Code", ChannelCode);
        if L_ChannelItemListing.FindSet() then begin
            repeat
                if L_ChannelItemListing."Item No." <> '' then begin
                    L_Item.Reset();
                    L_Item.SetRange("No.", L_ChannelItemListing."Item No.");
                    if L_Item.FindFirst() then begin
                        L_ChannelItemListing.Validate("Channel Inventory", L_Item.Inventory);
                        L_ChannelItemListing.Validate("Unit Price", L_Item."Unit Price");
                        L_ChannelItemListing.Modify(true);
                    end;
                end;
            until L_ChannelItemListing.Next() = 0;
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
}