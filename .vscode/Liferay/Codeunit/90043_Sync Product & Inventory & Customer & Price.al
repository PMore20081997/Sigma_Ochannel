codeunit 90043 "Sync Product/Inv./Cust./Price"
{
    TableNo = "Job Queue Entry";
    trigger OnRun()
    begin
        IF (STRPOS(Rec."Parameter String", ';')) > 0 THEN begin
            StartParameter := COPYSTR(Rec."Parameter String", 1, (STRPOS(Rec."Parameter String", ';') - 1));
            RunType := COPYSTR(Rec."Parameter String", (STRPOS(Rec."Parameter String", ';') + 1), (STRLEN(Rec."Parameter String") - STRPOS(Rec."Parameter String", ';')));
        end;

        case RunType of
            'Product':
                begin
                    SyncProductToLiferay('', StartParameter);
                end;
            'FullInventory':
                begin
                    SyncFullInventoryToLiferay(0, StartParameter);
                end;
            'DeltaInventory':
                begin
                    SyncDeltaInventoryToLiferay(0, StartParameter);
                end;
            'Customer':
                begin
                    SyncCustomerToLiferay('', StartParameter);
                end;
            'Price':
                begin
                    SyncPriceToLiferay('', 0, StartParameter);
                end;
        end;
    end;

    var
        myInt: Integer;
        G_Service_URL: Text[250];
        G_AccessKeyId: Text[100];
        StartParameter: Text;
        RunType: Text;
        G_Temp_InterimCustomer: Record "Interim Customer" temporary; //Dont remove temp property++
        G_Temp_ChannelItemListing: Record "Channel Item Listing" temporary; //Dont remove temp property++
        G_Temp_Full_LifeRayStock: Record "LifeRay Stock" temporary; //Dont remove temp property++
        G_Temp_Delta_LifeRayStock: Record "LifeRay Stock" temporary; //Dont remove temp property++
        G_Temp_ChannelPrice: Record "Channel Price" temporary; //Dont remove temp property++

    procedure SyncProductToLiferay(_ItemNo: Code[20]; _ChannelCode: Code[20])
    var
        L_ChannelItemListing: Record "Channel Item Listing";
        L_HttpHeaders: HttpHeaders;
        L_httpclient: HttpClient;
        L_httpcontent: HttpContent;
        L_URL: Text;
        G_Body: Text;
        L_httpResponseMessage: HttpResponseMessage;
        Response: Text;
        L_DocumentType: Option " ","Product",FullIventory,DeltaInventory,Customer,Price,Order;
        L_TradePartner: Record "Trade Partner";
        IsSyncSuccess: Boolean;
        RecordRef: RecordRef;
        jObject: JsonObject;
        CorrelationID: Code[50];
    begin
        Clear(IsSyncSuccess);

        #Region Check Mandatory fields++
        if _ChannelCode = '' then
            Error('Channel Code is missing in request parameter');
        CheckMadatoryfields(_ChannelCode);

        if L_TradePartner.Get(_ChannelCode) then
            if L_TradePartner."Sync Product" = false then
                Error('Sync Product should be TRUE for channel code %1', _ChannelCode);
        #EndRegion Check Mandatory fields++

        #Region Credential Check++
        GetCredentials(_ChannelCode);
        #EndRegion Credential Check++

        //Clear Variable++
        Clear(L_HttpHeaders);
        Clear(L_httpclient);
        Clear(L_httpcontent);
        Clear(L_httpResponseMessage);
        Clear(L_URL);

        //Get Body for API Request++
        Clear(G_Body);
        G_Body := GetProductBodyForAPIRequest(_ItemNo, _ChannelCode);
        if StrLen(G_Body) = 0 then begin
            if GuiAllowed = true then begin
                Error('Sync failed Error: The body content should not be blank');
            end else begin
                //InsertLiferayErrorLogs(L_DocumentType::Product, 'Batch Product', 0, _ChannelCode, 'Sync failed Error: The body content should not be blank');
                exit;
            end;
        end;


        //Process to call API++
        L_HttpHeaders := L_httpclient.DefaultRequestHeaders;
        L_URL := G_Service_URL + 'products/updates';
        L_HttpHeaders.Add('x-api-key', G_AccessKeyId);

        L_httpcontent.WriteFrom(G_Body);
        L_httpcontent.GetHeaders(L_httpheaders);
        L_httpheaders.Clear();
        L_httpheaders.Add('Content-Type', 'application/json');
        if L_httpclient.Post(L_URL, L_httpcontent, L_httpResponseMessage) then begin
            L_httpResponseMessage.Content.ReadAs(Response);

            if L_httpResponseMessage.HttpStatusCode = 200 then begin
                //Update Channel Item Listing++
                G_Temp_ChannelItemListing.Reset();
                if G_Temp_ChannelItemListing.FindSet() then begin
                    repeat
                        L_ChannelItemListing.Reset();
                        L_ChannelItemListing.SetRange("Channel Code", G_Temp_ChannelItemListing."Channel Code");
                        L_ChannelItemListing.SetRange("Item No.", G_Temp_ChannelItemListing."Item No.");
                        if L_ChannelItemListing.FindFirst() then begin
                            L_ChannelItemListing."Item Sync" := true;
                            L_ChannelItemListing."Listing Status" := L_ChannelItemListing."Listing Status"::Listed;
                            L_ChannelItemListing.Modify();

                            //Get the Correlation-id from response++
                            Clear(CorrelationID);
                            jObject.ReadFrom(Response);
                            if jObject.Contains('correlationId') then begin
                                CorrelationID := GetJsonvalue(jObject, 'correlationId').AsCode();
                            end;
                            if CorrelationID = '' then
                                CorrelationID := 'Failed-ID';
                            RecordRef.GetTable(L_ChannelItemListing);

                            //Insert Liferay Correlation ID tracking++
                            InsertLifeRayCorrelationID(RecordRef, L_DocumentType::Product, _ChannelCode, CorrelationID);

                        end;
                    until G_Temp_ChannelItemListing.Next() = 0;
                end;
                //After the first sync process, we are checking if there is any record which is not synced then we will run the function again to sync remaining records. Because based on batch size if there are more records then it will not sync in first go.++
                Commit();
                IsSyncSuccess := true;

                #region Run Function Again to sync remaining Records++
                L_ChannelItemListing.Reset();
                if _ItemNo <> '' then
                    L_ChannelItemListing.SetRange("Item No.", _ItemNo);
                L_ChannelItemListing.SetRange("Channel Code", _ChannelCode);
                L_ChannelItemListing.SetRange("Item Sync", false);
                if not L_ChannelItemListing.IsEmpty() then
                    SyncProductToLiferay(_ItemNo, _ChannelCode);
                #Endregion Run Function Again to sync remaining Records++
            end else
                if GuiAllowed = true then begin
                    Error('Sync failed Error: %1', Response);
                end else begin
                    InsertLiferayErrorLogs(L_DocumentType::Product, 'Batch Product', 0, _ChannelCode, StrSubstNo('Sync failed Error: %1', Response));
                end;
        end else begin
            if GuiAllowed = true then begin
                L_httpResponseMessage.Content.ReadAs(Response);
                Error('Sync failed Error: %1', Response);
            end else begin
                L_httpResponseMessage.Content.ReadAs(Response);
                InsertLiferayErrorLogs(L_DocumentType::Product, 'Batch Product', 0, _ChannelCode, StrSubstNo('Sync failed Error: %1', Response));
            end;
        end;
    end;

    local procedure GetProductBodyForAPIRequest(_ItemNo: Code[20]; _ChannelCode: Code[20]): Text
    var
        JsonObj: JsonObject;
        ItemLinesArray: JsonArray;
        LineObj: JsonObject;
        FinalTextRequest: Text;
        L_ItemReferece: Record "Item Reference";
        VariantPIPCodeLinesArray: JsonArray;
        VariantPIPCodeLineObj: JsonObject;
        L_ChannelItemListing: Record "Channel Item Listing";
        L_TradPartner: Record "Trade Partner";
        Loop: Integer;
        i: Integer;
        L_ItemVariant: Record "Item Variant";
        L_HasVariantSetup: Boolean;
        VariantCodesArray: JsonArray;
        PIPCodesArray: JsonArray;
    begin
        //Reset Temp table++
        G_Temp_ChannelItemListing.Reset();
        G_Temp_ChannelItemListing.DeleteAll();

        //Clear Variable++
        Clear(JsonObj);
        Clear(ItemLinesArray);
        Clear(LineObj);
        Clear(VariantPIPCodeLinesArray);
        Clear(VariantPIPCodeLineObj);

        //Get Total Loop
        Clear(Loop);
        L_TradPartner.Reset();
        L_TradPartner.SetRange(Code, _ChannelCode);
        if L_TradPartner.FindFirst() then
            Loop := L_TradPartner."Batch Size";

        //Start process to create Body Payload++
        L_ChannelItemListing.Reset();
        if _ItemNo <> '' then
            L_ChannelItemListing.SetRange("Item No.", _ItemNo);
        L_ChannelItemListing.SetRange("Channel Code", _ChannelCode);
        L_ChannelItemListing.SetRange("Item Sync", false);
        if L_ChannelItemListing.FindSet() then begin
            Clear(i);
            i := 1;

            Clear(JsonObj);
            Clear(ItemLinesArray);
            JsonObj.Add('items', ItemLinesArray);
            repeat
                //Check and break the loop++
                if Loop = 0 then
                    break;

                Clear(LineObj);
                LineObj.Add('channel_code', L_ChannelItemListing."Channel Code");
                LineObj.Add('asin_no', L_ChannelItemListing."ASIN No");
                LineObj.Add('listing_status_setting', Format(L_ChannelItemListing.Status));
                LineObj.Add('listing_status', Format(L_ChannelItemListing."Listing Status"));
                LineObj.Add('description', L_ChannelItemListing.Description);
                LineObj.Add('bc_item_no', L_ChannelItemListing."Item No.");
                LineObj.Add('rrp', L_ChannelItemListing.RRP);
                LineObj.Add('unit_price', L_ChannelItemListing."Unit Price");
                LineObj.Add('min_sell_price', L_ChannelItemListing."Min Sell Price");
                LineObj.Add('item_category_code', L_ChannelItemListing."Item Category Code");
                LineObj.Add('pack_size', L_ChannelItemListing."Pack Size");
                LineObj.Add('sales_blocked', L_ChannelItemListing."Sales Blocked");
                LineObj.Add('ops_sales_blocked', L_ChannelItemListing."Ops Sales Blocked");
                #Region Get Variant & PIP Code++
                // Clear(VariantPIPCodeLinesArray);
                // L_ItemReferece.Reset();
                // L_ItemReferece.SetRange("Reference Type", L_ItemReferece."Reference Type"::"PIP Code");
                // L_ItemReferece.SetRange("Item No.", L_ChannelItemListing."Item No.");
                // if L_ItemReferece.FindSet() then begin
                //     LineObj.Add('variants', VariantPIPCodeLinesArray);
                //     repeat
                //         Clear(VariantPIPCodeLineObj);
                //         VariantPIPCodeLineObj.Add('variant_code', L_ItemReferece."Variant Code");
                //         VariantPIPCodeLineObj.Add('pip_code', L_ItemReferece."Reference No.");
                //         VariantPIPCodeLinesArray.Add(VariantPIPCodeLineObj);
                //     until L_ItemReferece.Next() = 0;
                // end else
                //     LineObj.Add('variants', VariantPIPCodeLinesArray);
                #EndRegion Get Variant & PIP Code++

                #Region Get Variant Code
                //Check Variant Mandatory++
                Clear(L_HasVariantSetup);
                L_HasVariantSetup := GetVariantSetup(L_ChannelItemListing."Item No.");
                Clear(VariantCodesArray);
                if L_HasVariantSetup = true then begin
                    L_ItemVariant.Reset();
                    L_ItemVariant.SetRange("Item No.", L_ChannelItemListing."Item No.");
                    L_ItemVariant.SetRange("Blocked", false);
                    L_ItemVariant.SetRange("Sales Blocked", false);
                    if L_ItemVariant.FindSet() then begin
                        repeat
                            VariantCodesArray.Add(L_ItemVariant.Code);
                        until L_ItemVariant.Next() = 0;
                    end;
                end;
                LineObj.Add('variant_codes', VariantCodesArray);
                #EndRegion Get Variant Code

                #Region Get PIP Code
                Clear(PIPCodesArray);
                L_ItemReferece.Reset();
                L_ItemReferece.SetRange("Reference Type", L_ItemReferece."Reference Type"::"PIP Code");
                L_ItemReferece.SetRange("Item No.", L_ChannelItemListing."Item No.");
                if L_ItemReferece.FindSet() then
                    repeat
                        PIPCodesArray.Add(L_ItemReferece."Reference No.");
                    until L_ItemReferece.Next() = 0;
                LineObj.Add('pip_codes', PIPCodesArray);
                #EndRegion Get PIP Code

                LineObj.Add('lowstock_threshold', L_ChannelItemListing."Lowstock Threshold");
                ItemLinesArray.Add(LineObj);

                //Insert Temp record++
                G_Temp_ChannelItemListing.Init();
                G_Temp_ChannelItemListing.TransferFields(L_ChannelItemListing);
                //This transaction No nothing but Item Sequence and It is use for at the insert Error log when sync is failed
                if i = 1 then
                    G_Temp_ChannelItemListing."Transaction No." := 0
                else
                    G_Temp_ChannelItemListing."Transaction No." := G_Temp_ChannelItemListing."Transaction No." + 1;
                G_Temp_ChannelItemListing.Insert();

                //+++
                Loop := Loop - 1;
                i := i + 1;
            until L_ChannelItemListing.Next() = 0;
        end else begin
            //Exit Blank value If No record to sync++
            exit('');
        end;

        //Final body++
        Clear(FinalTextRequest);
        JsonObj.WriteTo(FinalTextRequest);
        exit(FinalTextRequest);
    end;

    procedure SyncFullInventoryToLiferay(_EntryNo: Integer; _ChannelCode: Code[20])
    var
        L_LiferayStock: Record "LifeRay Stock";
        L_HttpHeaders: HttpHeaders;
        L_httpclient: HttpClient;
        L_httpcontent: HttpContent;
        L_URL: Text;
        G_Body: Text;
        L_httpResponseMessage: HttpResponseMessage;
        Response: Text;
        L_DocumentType: Option " ","Product",FullInventory,DeltaInventory,Customer,Price,Order;
        L_TradePartner: Record "Trade Partner";
        IsSyncSuccess: Boolean;
        RecordRef: RecordRef;
        jObject: JsonObject;
        CorrelationID: Code[50];
    begin
        Clear(IsSyncSuccess);

        #Region Check Mandatory fields++
        if _ChannelCode = '' then
            Error('Channel Code is missing in request parameter');
        CheckMadatoryfields(_ChannelCode);

        if L_TradePartner.Get(_ChannelCode) then
            if L_TradePartner.SyncInventory = false then
                Error('Sync Inventory should be TRUE for channel code %1', _ChannelCode);
        #EndRegion Check Mandatory fields++

        #Region Credential Check++
        GetCredentials(_ChannelCode);
        #EndRegion Credential Check++

        //Clear Variable++
        Clear(L_HttpHeaders);
        Clear(L_httpclient);
        Clear(L_httpcontent);
        Clear(L_httpResponseMessage);
        Clear(L_URL);

        //Get Body for API Request++
        Clear(G_Body);
        G_Body := GetFullInventoryBodyForAPIRequest(_EntryNo, _ChannelCode);
        if StrLen(G_Body) = 0 then begin
            if GuiAllowed = true then begin
                Error('Sync failed Error: The body content should not be blank');
            end else begin
                //InsertLiferayErrorLogs(L_DocumentType::FullInventory, 'Batch FullInventory', 0, _ChannelCode, 'Sync failed Error: The body content should not be blank');
                exit;
            end;
        end;

        //Process to call API++
        L_HttpHeaders := L_httpclient.DefaultRequestHeaders;
        L_URL := G_Service_URL + 'inventory/full';
        L_HttpHeaders.Add('x-api-key', G_AccessKeyId);

        L_httpcontent.WriteFrom(G_Body);
        L_httpcontent.GetHeaders(L_httpheaders);
        L_httpheaders.Clear();
        L_httpheaders.Add('Content-Type', 'application/json');
        if L_httpclient.Post(L_URL, L_httpcontent, L_httpResponseMessage) then begin
            L_httpResponseMessage.Content.ReadAs(Response);

            if L_httpResponseMessage.HttpStatusCode = 200 then begin
                G_Temp_Full_LifeRayStock.Reset();
                if G_Temp_Full_LifeRayStock.FindSet() then begin
                    repeat
                        L_LiferayStock.Reset();
                        L_LiferayStock.SetRange("Entry No.", G_Temp_Full_LifeRayStock."Entry No.");
                        L_LiferayStock.SetRange("Channel Code", G_Temp_Full_LifeRayStock."Channel Code");
                        if L_LiferayStock.FindFirst() then begin
                            L_LiferayStock.Sync := true;
                            L_LiferayStock.Modify();


                            //Get the Correlation-id from response++
                            Clear(CorrelationID);
                            jObject.ReadFrom(Response);
                            if jObject.Contains('correlationId') then begin
                                CorrelationID := GetJsonvalue(jObject, 'correlationId').AsCode();
                            end;
                            if CorrelationID = '' then
                                CorrelationID := 'Failed-ID';
                            RecordRef.GetTable(L_LiferayStock);

                            //Insert Liferay Correlation ID tracking++
                            InsertLifeRayCorrelationID(RecordRef, L_DocumentType::FullInventory, _ChannelCode, CorrelationID);
                        end;
                    until G_Temp_Full_LifeRayStock.Next() = 0;
                end;
                //After the first sync process, we are checking if there is any record which is not synced then we will run the function again to sync remaining records. Because based on batch size if there are more records then it will not sync in first go.++
                Commit();
                IsSyncSuccess := true;


                #region Run Function Again to sync remaining Records++
                L_LifeRayStock.Reset();
                if _EntryNo <> 0 then
                    L_LifeRayStock.SetRange("Entry No.", _EntryNo);
                L_LifeRayStock.SetRange("Channel Code", _ChannelCode);
                L_LiferayStock.SetRange("Created On", WorkDate());
                L_LiferayStock.SetRange("Sync Type", L_LiferayStock."Sync Type"::Full);
                L_LiferayStock.SetRange(Sync, false);
                if not L_LiferayStock.IsEmpty() then
                    SyncFullInventoryToLiferay(_EntryNo, _ChannelCode);
                #Endregion Run Function Again to sync remaining Records++
            end else
                if GuiAllowed = true then begin
                    UpdateResponseMessage(Response, L_DocumentType::FullInventory);
                    Error('Sync failed Error: %1', Response);
                end else begin
                    UpdateResponseMessage(Response, L_DocumentType::FullInventory);
                    InsertLiferayErrorLogs(L_DocumentType::FullInventory, 'Batch FullInventory', 0, _ChannelCode, StrSubstNo('Sync failed Error: %1', Response));
                end;
        end else begin
            if GuiAllowed = true then begin
                L_httpResponseMessage.Content.ReadAs(Response);
                Error('Sync failed Error: %1', Response);
            end else begin
                L_httpResponseMessage.Content.ReadAs(Response);
                InsertLiferayErrorLogs(L_DocumentType::FullInventory, 'Batch FullInventory', 0, _ChannelCode, StrSubstNo('Sync failed Error: %1', Response));
            end;
        end;
    end;

    local procedure GetFullInventoryBodyForAPIRequest(_EntryNo: Integer; _ChannelCode: Code[20]): Text
    var
        JsonObj: JsonObject;
        FullInventoryArray: JsonArray;
        LineObj: JsonObject;
        FinalTextRequest: Text;
        L_LifeRayStock: Record "LifeRay Stock";
        Loop: Integer;
        i: Integer;
        L_TradPartner: Record "Trade Partner";
    begin
        //Reset Temp table++
        G_Temp_Full_LifeRayStock.Reset();
        G_Temp_Full_LifeRayStock.DeleteAll();

        //Clear Variable++
        Clear(JsonObj);
        Clear(FullInventoryArray);
        Clear(LineObj);

        //Get Total Loop
        Clear(Loop);
        L_TradPartner.Reset();
        L_TradPartner.SetRange(Code, _ChannelCode);
        if L_TradPartner.FindFirst() then
            Loop := L_TradPartner."Batch Size";

        //Start process to create Body Payload++
        L_LifeRayStock.Reset();
        if _EntryNo <> 0 then
            L_LifeRayStock.SetRange("Entry No.", _EntryNo);
        L_LifeRayStock.SetRange("Channel Code", _ChannelCode);
        L_LiferayStock.SetRange("Created On", WorkDate());
        L_LiferayStock.SetRange("Sync Type", L_LiferayStock."Sync Type"::Full);
        L_LiferayStock.SetRange(Sync, false);
        L_LiferayStock.SetCurrentKey("Item No.");
        L_LiferayStock.Ascending(true);
        if L_LifeRayStock.FindSet() then begin
            Clear(i);
            i := 1;

            Clear(JsonObj);
            Clear(FullInventoryArray);
            JsonObj.Add('items', FullInventoryArray);
            repeat
                //Check and break the loop++
                if Loop = 0 then
                    break;

                //++
                Clear(LineObj);
                LineObj.Add('bc_item_no', L_LifeRayStock."Item No.");
                LineObj.Add('variant_code', L_LifeRayStock."Variant Code");
                LineObj.Add('warehouse_id', L_LifeRayStock."Location Code");
                LineObj.Add('priority', L_LifeRayStock."Variant Priority");
                LineObj.Add('stock_qty', L_LifeRayStock.Inventory);
                FullInventoryArray.Add(LineObj);

                //Insert Temp record++
                G_Temp_Full_LifeRayStock.Init();
                G_Temp_Full_LifeRayStock.TransferFields(L_LifeRayStock);
                //This transaction No nothing but Inventory Sequence and It is use for at the insert Error log when sync is failed
                if i = 1 then
                    G_Temp_Full_LifeRayStock."Transaction No." := 0
                else
                    G_Temp_Full_LifeRayStock."Transaction No." := G_Temp_Full_LifeRayStock."Transaction No." + 1;
                G_Temp_Full_LifeRayStock.Insert();

                //+++
                Loop := Loop - 1;
                i := i + 1;
            until L_LifeRayStock.Next() = 0;
        end else begin
            //Exit Blank value If No record to sync++
            exit('');
        end;


        //Final body++
        Clear(FinalTextRequest);
        JsonObj.WriteTo(FinalTextRequest);
        exit(FinalTextRequest);
    end;

    procedure SyncDeltaInventoryToLiferay(_EntryNo: Integer; _ChannelCode: Code[20])
    var
        L_LiferayStock: Record "LifeRay Stock";
        L_HttpHeaders: HttpHeaders;
        L_httpclient: HttpClient;
        L_httpcontent: HttpContent;
        L_URL: Text;
        G_Body: Text;
        L_httpResponseMessage: HttpResponseMessage;
        Response: Text;
        L_DocumentType: Option " ","Product",FullIventory,DeltaInventory,Customer,Price,Order;
        L_TradePartner: Record "Trade Partner";
        IsSyncSuccess: Boolean;
        RecordRef: RecordRef;
        jObject: JsonObject;
        CorrelationID: Code[50];
    begin
        Clear(IsSyncSuccess);

        #Region Check Mandatory fields++
        if _ChannelCode = '' then
            Error('Channel Code is missing in request parameter');
        CheckMadatoryfields(_ChannelCode);

        if L_TradePartner.Get(_ChannelCode) then
            if L_TradePartner.SyncInventory = false then
                Error('Sync Inventory should be TRUE for channel code %1', _ChannelCode);
        #EndRegion Check Mandatory fields++

        #Region Credential Check++
        GetCredentials(_ChannelCode);
        #EndRegion Credential Check++

        //Clear Variable++
        Clear(L_HttpHeaders);
        Clear(L_httpclient);
        Clear(L_httpcontent);
        Clear(L_httpResponseMessage);
        Clear(L_URL);

        //Get Body for API Request++
        Clear(G_Body);
        G_Body := GetDeltaInventoryBodyForAPIRequest(_EntryNo, _ChannelCode);
        if StrLen(G_Body) = 0 then begin
            if GuiAllowed = true then begin
                Error('Sync failed Error: The body content should not be blank');
            end else begin
                //InsertLiferayErrorLogs(L_DocumentType::DeltaInventory, 'Batch DeltaInventory', 0, _ChannelCode, 'Sync failed Error: The body content should not be blank');
                exit;
            end;
        end;


        //Process to call API++
        L_HttpHeaders := L_httpclient.DefaultRequestHeaders;
        L_URL := G_Service_URL + 'inventory/delta';
        L_HttpHeaders.Add('x-api-key', G_AccessKeyId);

        L_httpcontent.WriteFrom(G_Body);
        L_httpcontent.GetHeaders(L_httpheaders);
        L_httpheaders.Clear();
        L_httpheaders.Add('Content-Type', 'application/json');
        if L_httpclient.Post(L_URL, L_httpcontent, L_httpResponseMessage) then begin
            L_httpResponseMessage.Content.ReadAs(Response);

            if L_httpResponseMessage.HttpStatusCode = 200 then begin
                G_Temp_Delta_LifeRayStock.Reset();
                if G_Temp_Delta_LifeRayStock.FindSet() then begin
                    repeat
                        L_LiferayStock.Reset();
                        L_LiferayStock.SetRange("Entry No.", G_Temp_Delta_LifeRayStock."Entry No.");
                        L_LiferayStock.SetRange("Channel Code", G_Temp_Delta_LifeRayStock."Channel Code");
                        if L_LiferayStock.FindFirst() then begin
                            L_LiferayStock.Sync := true;
                            L_LiferayStock.Modify();


                            //Get the Correlation-id from response++
                            Clear(CorrelationID);
                            jObject.ReadFrom(Response);
                            if jObject.Contains('correlationId') then begin
                                CorrelationID := GetJsonvalue(jObject, 'correlationId').AsCode();
                            end;
                            if CorrelationID = '' then
                                CorrelationID := 'Failed-ID';
                            RecordRef.GetTable(L_LiferayStock);

                            //Insert Liferay Correlation ID tracking++
                            InsertLifeRayCorrelationID(RecordRef, L_DocumentType::DeltaInventory, _ChannelCode, CorrelationID);
                        end;
                    until G_Temp_Delta_LifeRayStock.Next() = 0;
                end;
                //After the first sync process, we are checking if there is any record which is not synced then we will run the function again to sync remaining records. Because based on batch size if there are more records then it will not sync in first go.++
                Commit();
                IsSyncSuccess := true;


                #region Run Function Again to sync remaining Records++
                L_LiferayStock.Reset();
                if _EntryNo <> 0 then
                    L_LiferayStock.SetRange("Entry No.", _EntryNo);
                L_LiferayStock.SetRange("Channel Code", _ChannelCode);
                L_LiferayStock.SetRange("Created On", WorkDate());
                L_LiferayStock.SetRange("Sync Type", L_LiferayStock."Sync Type"::Delta);
                L_LiferayStock.SetRange(Sync, false);
                if not L_LiferayStock.IsEmpty() then
                    SyncDeltaInventoryToLiferay(_EntryNo, _ChannelCode);
                #Endregion Run Function Again to sync remaining Records++
            end else
                if GuiAllowed = true then begin
                    UpdateResponseMessage(Response, L_DocumentType::DeltaInventory);
                    Error('Sync failed Error: %1', Response);
                end else begin
                    UpdateResponseMessage(Response, L_DocumentType::DeltaInventory);
                    InsertLiferayErrorLogs(L_DocumentType::DeltaInventory, 'Batch DeltaInventory', 0, _ChannelCode, StrSubstNo('Sync failed Error: %1', Response));
                end;
        end else begin
            if GuiAllowed = true then begin
                L_httpResponseMessage.Content.ReadAs(Response);
                Error('Sync failed Error: %1', Response);
            end else begin
                L_httpResponseMessage.Content.ReadAs(Response);
                InsertLiferayErrorLogs(L_DocumentType::DeltaInventory, 'Batch DeltaInventory', 0, _ChannelCode, StrSubstNo('Sync failed Error: %1', Response));
            end;
        end;
    end;

    local procedure GetDeltaInventoryBodyForAPIRequest(_EntryNo: Integer; _ChannelCode: Code[20]): Text
    var
        JsonObj: JsonObject;
        FullInventoryArray: JsonArray;
        LineObj: JsonObject;
        FinalTextRequest: Text;
        L_LiferayStock: Record "LifeRay Stock";
        Loop: Integer;
        i: Integer;
        L_TradPartner: Record "Trade Partner";
    begin
        //Reset Temp table++
        G_Temp_Delta_LifeRayStock.Reset();
        G_Temp_Delta_LifeRayStock.DeleteAll();


        //Clear Variable++
        Clear(JsonObj);
        Clear(FullInventoryArray);
        Clear(LineObj);

        //Get Total Loop
        Clear(Loop);
        L_TradPartner.Reset();
        L_TradPartner.SetRange(Code, _ChannelCode);
        if L_TradPartner.FindFirst() then
            Loop := L_TradPartner."Batch Size";

        //Start process to create Body Payload++
        L_LiferayStock.Reset();
        if _EntryNo <> 0 then
            L_LiferayStock.SetRange("Entry No.", _EntryNo);
        L_LiferayStock.SetRange("Channel Code", _ChannelCode);
        L_LiferayStock.SetRange("Created On", WorkDate());
        L_LiferayStock.SetRange("Sync Type", L_LiferayStock."Sync Type"::Delta);
        L_LiferayStock.SetRange(Sync, false);
        L_LiferayStock.SetCurrentKey("Item No.");
        L_LiferayStock.Ascending(true);
        if L_LiferayStock.FindSet() then begin
            Clear(i);
            i := 1;

            Clear(JsonObj);
            Clear(FullInventoryArray);
            JsonObj.Add('items', FullInventoryArray);
            repeat
                //Check and break the loop++
                if Loop = 0 then
                    break;

                //++
                Clear(LineObj);
                LineObj.Add('bc_item_no', L_LiferayStock."Item No.");
                LineObj.Add('variant_code', L_LiferayStock."Variant Code");
                LineObj.Add('warehouse_id', L_LiferayStock."Location Code");
                LineObj.Add('priority', L_LiferayStock."Variant Priority");
                LineObj.Add('delta_stock', L_LiferayStock.Inventory);
                FullInventoryArray.Add(LineObj);

                //Insert Temp record++
                G_Temp_Delta_LifeRayStock.Init();
                G_Temp_Delta_LifeRayStock.TransferFields(L_LifeRayStock);
                //This transaction No nothing but Inventory Sequence and It is use for at the insert Error log when sync is failed
                if i = 1 then
                    G_Temp_Delta_LifeRayStock."Transaction No." := 0
                else
                    G_Temp_Delta_LifeRayStock."Transaction No." := G_Temp_Delta_LifeRayStock."Transaction No." + 1;
                G_Temp_Delta_LifeRayStock.Insert();

                //+++
                Loop := Loop - 1;
                i := i + 1;
            until L_LiferayStock.Next() = 0;
        end else begin
            //Exit Blank value If No record to sync++
            exit('');
        end;

        //Final body++
        Clear(FinalTextRequest);
        JsonObj.WriteTo(FinalTextRequest);
        exit(FinalTextRequest);
    end;

    procedure SyncPriceToLiferay(_PriceCode: Code[20]; _LineNo: Integer; _ChannelCode: Code[20])
    var
        L_HttpHeaders: HttpHeaders;
        L_httpclient: HttpClient;
        L_httpcontent: HttpContent;
        L_URL: Text;
        G_Body: Text;
        L_httpResponseMessage: HttpResponseMessage;
        Response: Text;
        L_DocumentType: Option " ","Product",FullIventory,DeltaInventory,Customer,Price,Order;
        IsSyncSuccess: Boolean;
        L_ChannelPrice: Record "Channel Price";
        L_LastSyncDateTime: DateTime;
        RecordRef: RecordRef;
        jObject: JsonObject;
        CorrelationID: Code[50];
        L_TradePartner: Record "Trade Partner";
    begin
        Clear(IsSyncSuccess);

        #Region Check Mandatory fields++
        if _ChannelCode = '' then
            Error('Channel Code is missing in request parameter');
        CheckMadatoryfields(_ChannelCode);

        if L_TradePartner.Get(_ChannelCode) then
            if L_TradePartner.SyncPrice = false then
                Error('Sync Price should be TRUE for channel code %1', _ChannelCode);
        #EndRegion Check Mandatory fields++

        #Region Credential Check++
        GetCredentials(_ChannelCode);
        #EndRegion Credential Check++

        //Clear Variable++
        Clear(L_HttpHeaders);
        Clear(L_httpclient);
        Clear(L_httpcontent);
        Clear(L_httpResponseMessage);
        Clear(L_URL);

        //Get Body for API Request++
        Clear(G_Body);
        G_Body := GetPriceBodyForAPIRequest(_PriceCode, _LineNo, _ChannelCode);
        if StrLen(G_Body) = 0 then begin
            if GuiAllowed = true then begin
                Error('Sync failed Error: The body content should not be blank');
            end else begin
                //InsertLiferayErrorLogs(L_DocumentType::Price, 'Batch Price', 0, _ChannelCode, 'Sync failed Error: The body content should not be blank');
                exit;
            end;
        end;



        //Process to call API++
        L_HttpHeaders := L_httpclient.DefaultRequestHeaders;
        L_URL := G_Service_URL + 'prices/updates';
        L_HttpHeaders.Add('x-api-key', G_AccessKeyId);

        L_httpcontent.WriteFrom(G_Body);
        L_httpcontent.GetHeaders(L_httpheaders);
        L_httpheaders.Clear();
        L_httpheaders.Add('Content-Type', 'application/json');
        if L_httpclient.Post(L_URL, L_httpcontent, L_httpResponseMessage) then begin
            L_httpResponseMessage.Content.ReadAs(Response);

            if L_httpResponseMessage.HttpStatusCode = 200 then begin
                //Update Web customer+++
                G_Temp_ChannelPrice.Reset();
                if G_Temp_ChannelPrice.FindSet() then begin
                    repeat
                        L_ChannelPrice.Reset();
                        L_ChannelPrice.SetRange("Channel Code", G_Temp_ChannelPrice."Channel Code");
                        L_ChannelPrice.SetRange("Price List Code", G_Temp_ChannelPrice."Price List Code");
                        L_ChannelPrice.SetRange("Line No.", G_Temp_ChannelPrice."Line No.");
                        if L_ChannelPrice.FindFirst() then begin
                            L_ChannelPrice."Sync Price" := true;
                            L_ChannelPrice."Listing Status" := L_ChannelPrice."Listing Status"::Listed;
                            L_ChannelPrice.Modify();

                            //Get the Correlation-id from response++
                            Clear(CorrelationID);
                            jObject.ReadFrom(Response);
                            if jObject.Contains('correlationId') then begin
                                CorrelationID := GetJsonvalue(jObject, 'correlationId').AsCode();
                            end;
                            if CorrelationID = '' then
                                CorrelationID := 'Failed-ID';
                            RecordRef.GetTable(L_ChannelPrice);

                            //Insert Liferay Correlation ID tracking++
                            InsertLifeRayCorrelationID(RecordRef, L_DocumentType::Price, _ChannelCode, CorrelationID);
                        end;
                    until G_Temp_ChannelPrice.Next() = 0;
                end;
                //After the first sync process, we are checking if there is any record which is not synced then we will run the function again to sync remaining records. Because based on batch size if there are more records then it will not sync in first go.++
                Commit();
                IsSyncSuccess := true;

                #region Run Function Again to sync remaining Records++
                L_ChannelPrice.Reset();
                L_ChannelPrice.SetRange("Channel Code", _ChannelCode);
                if _PriceCode <> '' then begin
                    L_ChannelPrice.SetRange("Price List Code", _PriceCode);
                    L_ChannelPrice.SetRange("Line No.", _LineNo);
                end;
                L_ChannelPrice.SetRange("Sync Price", false);
                if not L_ChannelPrice.IsEmpty() then
                    SyncPriceToLiferay(_PriceCode, _LineNo, _ChannelCode);
                #Endregion Run Function Again to sync remaining Records++
            end else
                if GuiAllowed = true then begin
                    UpdateResponseMessage(Response, L_DocumentType::Price);
                    Error('Sync failed Error: %1', Response);
                end else begin
                    UpdateResponseMessage(Response, L_DocumentType::Price);
                    InsertLiferayErrorLogs(L_DocumentType::Price, 'Batch Price', 0, _ChannelCode, StrSubstNo('Sync failed Error: %1', Response));
                end;
        end else begin
            if GuiAllowed = true then begin
                L_httpResponseMessage.Content.ReadAs(Response);
                Error('Sync failed Error: %1', Response)
            end else begin
                L_httpResponseMessage.Content.ReadAs(Response);
                InsertLiferayErrorLogs(L_DocumentType::Price, 'Batch Price', 0, _ChannelCode, StrSubstNo('Sync failed Error: %1', Response));
            end;
        end;
    end;

    local procedure GetPriceBodyForAPIRequest(_PriceCode: Code[20]; _LineNo: Integer; _ChannelCode: Code[20]): Text
    var
        JsonObj: JsonObject;
        PriceArray: JsonArray;
        LineObj: JsonObject;
        FinalTextRequest: Text;
        L_ChannelPrice: Record "Channel Price";
        L_TradPartner: Record "Trade Partner";
        Loop: Integer;
        i: Integer;
    begin
        //Reset Temp table++
        G_Temp_ChannelPrice.Reset();
        G_Temp_ChannelPrice.DeleteAll();

        //Clear Variable++
        Clear(JsonObj);
        Clear(PriceArray);
        Clear(LineObj);

        //Get Total Loop
        Clear(Loop);
        L_TradPartner.Reset();
        L_TradPartner.SetRange(Code, _ChannelCode);
        if L_TradPartner.FindFirst() then
            Loop := L_TradPartner."Batch Size";

        //Start process to create Body Payload++
        L_ChannelPrice.Reset();
        L_ChannelPrice.SetRange("Channel Code", _ChannelCode);
        if _PriceCode <> '' then begin
            L_ChannelPrice.SetRange("Price List Code", _PriceCode);
            L_ChannelPrice.SetRange("Line No.", _LineNo);
        end;
        L_ChannelPrice.SetRange("Sync Price", false);
        if L_ChannelPrice.FindSet() then begin
            Clear(i);
            i := 1;

            Clear(JsonObj);
            Clear(PriceArray);
            JsonObj.Add('items', PriceArray);
            repeat
                //Check and break the loop++
                if Loop = 0 then
                    break;


                Clear(LineObj);
                LineObj.Add('customer_group', L_ChannelPrice."Price List Code");
                LineObj.Add('line_no', L_ChannelPrice."Line No.");
                LineObj.Add('source_type', Format(L_ChannelPrice."Source Type"));
                LineObj.Add('item_no', L_ChannelPrice."Product No.");
                LineObj.Add('variant_code', L_ChannelPrice."Variant Code");
                LineObj.Add('unit_price', L_ChannelPrice."Unit Price");
                if L_ChannelPrice."Listing Status Setting" = L_ChannelPrice."Listing Status Setting"::Active then
                    LineObj.Add('listing_status_setting', 'Active')
                else
                    LineObj.Add('listing_status_setting', 'Inactive');

                if L_ChannelPrice."Listing Status" = L_ChannelPrice."Listing Status"::Listed then
                    LineObj.Add('listing_status', 'Listed')
                else
                    LineObj.Add('listing_status', 'Not Listed');
                LineObj.Add('base_volume', L_ChannelPrice."Base Volume");
                LineObj.Add('cost_unit_thereafter', L_ChannelPrice."Cost Unit Thereafter");
                PriceArray.Add(LineObj);


                //Insert Temp record++
                G_Temp_ChannelPrice.Init();
                G_Temp_ChannelPrice.TransferFields(L_ChannelPrice);
                //This transaction No nothing but Price Sequence and It is use for at the insert Error log when sync is failed
                if i = 1 then
                    G_Temp_ChannelPrice."Transaction No." := 0
                else
                    G_Temp_ChannelPrice."Transaction No." := G_Temp_ChannelPrice."Transaction No." + 1;
                G_Temp_ChannelPrice.Insert();

                //+++
                Loop := Loop - 1;
                i := i + 1;
            until L_ChannelPrice.Next() = 0;
        end else begin
            //Exit Blank value If No record to sync++
            exit('');
        end;

        //Final body++
        Clear(FinalTextRequest);
        JsonObj.WriteTo(FinalTextRequest);
        exit(FinalTextRequest);
    end;



    procedure SyncCustomerToLiferay(_CustomerNo: Code[20]; _ChannelCode: Code[20])
    var
        L_HttpHeaders: HttpHeaders;
        L_httpclient: HttpClient;
        L_httpcontent: HttpContent;
        L_URL: Text;
        G_Body: Text;
        L_httpResponseMessage: HttpResponseMessage;
        Response: Text;
        L_DocumentType: Option " ","Product",FullIventory,DeltaInventory,Customer,Price,Order;
        IsSyncSuccess: Boolean;
        L_LastSyncDateTime: DateTime;
        L_InterimCustomer: Record "Interim Customer";
        RecordRef: RecordRef;
        jObject: JsonObject;
        CorrelationID: Code[50];
        L_TradePartner: Record "Trade Partner";
    begin
        Clear(IsSyncSuccess);

        #Region Check Mandatory fields++
        if _ChannelCode = '' then
            Error('Channel Code is missing in request parameter');
        CheckMadatoryfields(_ChannelCode);

        if L_TradePartner.Get(_ChannelCode) then
            if L_TradePartner."Sync Customer" = false then
                Error('Sync Customer should be TRUE for channel code %1', _ChannelCode);
        #EndRegion Check Mandatory fields++

        #Region Credential Check++
        GetCredentials(_ChannelCode);
        #EndRegion Credential Check++


        //Clear Variable++
        Clear(L_HttpHeaders);
        Clear(L_httpclient);
        Clear(L_httpcontent);
        Clear(L_httpResponseMessage);
        Clear(L_URL);

        //Get Body for API Request++
        Clear(G_Body);
        G_Body := GetCustomerBodyForAPIRequest(_CustomerNo, _ChannelCode);
        if StrLen(G_Body) = 0 then begin
            if GuiAllowed = true then begin
                Error('Sync failed Error: The body content should not be blank');
            end else begin
                //InsertLiferayErrorLogs(L_DocumentType::Customer, 'Batch Customer', 0, _ChannelCode, 'Sync failed Error: The body content should not be blank');
                exit;
            end;
        end;


        //Process to call API++
        L_HttpHeaders := L_httpclient.DefaultRequestHeaders;
        L_URL := G_Service_URL + 'customers/updates';
        L_HttpHeaders.Add('x-api-key', G_AccessKeyId);

        L_httpcontent.WriteFrom(G_Body);
        L_httpcontent.GetHeaders(L_httpheaders);
        L_httpheaders.Clear();
        L_httpheaders.Add('Content-Type', 'application/json');
        if L_httpclient.Post(L_URL, L_httpcontent, L_httpResponseMessage) then begin
            L_httpResponseMessage.Content.ReadAs(Response);

            if L_httpResponseMessage.HttpStatusCode = 200 then begin
                //Update Web customer+++
                G_Temp_InterimCustomer.Reset();
                if G_Temp_InterimCustomer.FindSet() then begin
                    repeat
                        L_InterimCustomer.Reset();
                        L_InterimCustomer.SetRange("Customer No.", G_Temp_InterimCustomer."Customer No.");
                        L_InterimCustomer.SetRange("Channel Code", G_Temp_InterimCustomer."Channel Code");
                        if L_InterimCustomer.FindFirst() then begin
                            L_InterimCustomer."Customer Sync" := true;
                            L_InterimCustomer."Listing Status" := L_InterimCustomer."Listing Status"::Listed;
                            L_InterimCustomer.Modify();

                            //Get the Correlation-id from response++
                            Clear(CorrelationID);
                            jObject.ReadFrom(Response);
                            if jObject.Contains('correlationId') then begin
                                CorrelationID := GetJsonvalue(jObject, 'correlationId').AsCode();
                            end;
                            if CorrelationID = '' then
                                CorrelationID := 'Failed-ID';
                            RecordRef.GetTable(L_InterimCustomer);

                            //Insert Liferay Correlation ID tracking++
                            InsertLifeRayCorrelationID(RecordRef, L_DocumentType::Customer, _ChannelCode, CorrelationID);
                        end;
                    until G_Temp_InterimCustomer.Next() = 0;
                end;
                //After the first sync process, we are checking if there is any record which is not synced then we will run the function again to sync remaining records. Because based on batch size if there are more records then it will not sync in first go.++
                Commit();
                IsSyncSuccess := true;

                #region Run Function Again to sync remaining Records++
                L_InterimCustomer.Reset();
                if _CustomerNo <> '' then
                    L_InterimCustomer.SetRange("No.", _CustomerNo);
                L_InterimCustomer.SetRange("Channel Code", _ChannelCode);
                L_InterimCustomer.SetRange("Customer Sync", false);
                if not L_InterimCustomer.IsEmpty() then
                    SyncCustomerToLiferay(_CustomerNo, _ChannelCode);
                #Endregion Run Function Again to sync remaining Records++
            end else
                if GuiAllowed = true then begin
                    Error('Sync failed Error: %1', Response);
                end else begin
                    InsertLiferayErrorLogs(L_DocumentType::Customer, 'Batch Customers', 0, _ChannelCode, StrSubstNo('Sync failed Error: %1', Response));
                end;
        end else begin
            if GuiAllowed = true then begin
                L_httpResponseMessage.Content.ReadAs(Response);
                Error('Sync failed Error: %1', Response);
            end else begin
                L_httpResponseMessage.Content.ReadAs(Response);
                InsertLiferayErrorLogs(L_DocumentType::Customer, 'Batch Customer', 0, _ChannelCode, StrSubstNo('Sync failed Error: %1', Response));
            end;
        end;
    end;

    local procedure GetCustomerBodyForAPIRequest(_CustomerNo: Code[20]; _ChannelCode: Code[20]): Text
    var
        JsonObj: JsonObject;
        CustomerArray: JsonArray;
        LineObj: JsonObject;
        FinalTextRequest: Text;
        L_InterimCustomer: Record "Interim Customer";
        L_Customer: Record Customer;
        BilltoCreditLimit: Decimal;
        ShippingAddressObj: JsonObject;
        BillingAddressObj: JsonObject;
        Loop: Integer;
        L_TradPartner: Record "Trade Partner";
        i: Integer;
    begin
        //Reset Temp table++
        G_Temp_InterimCustomer.Reset();
        G_Temp_InterimCustomer.DeleteAll();

        //Clear Variables
        Clear(CustomerArray);
        Clear(JsonObj);
        Clear(LineObj);
        Clear(FinalTextRequest);

        //Get Total Loop
        Clear(Loop);
        L_TradPartner.Reset();
        L_TradPartner.SetRange(Code, _ChannelCode);
        if L_TradPartner.FindFirst() then
            Loop := L_TradPartner."Batch Size";

        //Start process to create Body Payload++
        L_InterimCustomer.Reset();
        if _CustomerNo <> '' then
            L_InterimCustomer.SetRange("No.", _CustomerNo);
        L_InterimCustomer.SetRange("Channel Code", _ChannelCode);
        L_InterimCustomer.SetRange("Customer Sync", false);
        if L_InterimCustomer.FindSet() then begin
            Clear(i);
            i := 1;

            Clear(JsonObj);
            Clear(CustomerArray);
            JsonObj.Add('items', CustomerArray);
            repeat
                L_Customer.Reset();
                L_Customer.SetRange("No.", L_InterimCustomer."Customer No.");
                if L_Customer.FindFirst() then begin
                    //Check and break the loop++
                    if Loop = 0 then
                        break;


                    Clear(LineObj);
                    LineObj.Add('channel_code', L_InterimCustomer."Channel Code");
                    LineObj.Add('sell_to_customer_no', L_InterimCustomer."Customer No.");
                    LineObj.Add('sell_to_customer_name', L_InterimCustomer.Name);
                    LineObj.Add('bill_to_customer_no', L_InterimCustomer."Bill to Customer No.");
                    LineObj.Add('bill_to_customer_name', L_InterimCustomer."Bill to Customer Name");
                    LineObj.Add('customer_group', L_InterimCustomer."Customer Price Group 1");
                    LineObj.Add('customer_group_2', L_InterimCustomer."Customer Price Group 2");
                    LineObj.Add('customer_group_3', L_InterimCustomer."Customer Price Group 3");
                    if L_InterimCustomer."Listing Status Setting" = L_InterimCustomer."Listing Status Setting"::Active then
                        LineObj.Add('listing_status_setting', 'Active')
                    else
                        LineObj.Add('listing_status_setting', 'Inactive');
                    LineObj.Add('shop_group', L_InterimCustomer."Customer Type");
                    LineObj.Add('shipping_agent_code', L_InterimCustomer."Shipping Agent Code");
                    LineObj.Add('shipping_agent_service_code', L_InterimCustomer."Shipping Agent Service Code");
                    LineObj.Add('credit_limit', L_InterimCustomer."Credit Limit (LCY)");
                    if L_InterimCustomer."Credit Limit Warning" = false then
                        LineObj.Add('credit_limit_warning', false)
                    else
                        LineObj.Add('credit_limit_warning', true);
                    if L_InterimCustomer.Blocked = L_InterimCustomer.Blocked::" " then
                        LineObj.Add('blocked', '')
                    else begin
                        LineObj.Add('blocked', UpperCase(Format(L_InterimCustomer.Blocked)));
                    end;
                    LineObj.Add('blocked_reason', Format(L_InterimCustomer."Block Reason"));

                    #Region Shipping Address++
                    Clear(ShippingAddressObj);
                    ShippingAddressObj.Add('line_1', L_InterimCustomer.Address);
                    ShippingAddressObj.Add('line_2', L_InterimCustomer."Address 2");
                    ShippingAddressObj.Add('city', L_InterimCustomer."City");
                    ShippingAddressObj.Add('country', L_InterimCustomer.Country);
                    ShippingAddressObj.Add('postcode', L_InterimCustomer."Post Code");
                    LineObj.Add('shipping_address', ShippingAddressObj);
                    #EndRegion Shipping Address++

                    #Region Billing Address++
                    if L_InterimCustomer."Bill to Customer No." <> '' then begin
                        Clear(BillingAddressObj);
                        BillingAddressObj.Add('line_1', L_InterimCustomer."Billing Address");
                        BillingAddressObj.Add('line_2', L_InterimCustomer."Billing Address 2");
                        BillingAddressObj.Add('city', L_InterimCustomer."Billing City");
                        BillingAddressObj.Add('country', L_InterimCustomer."Billing Country");
                        BillingAddressObj.Add('postcode', L_InterimCustomer."Billing Post Code");
                        LineObj.Add('billing_address', BillingAddressObj);
                    end;
                    #EndRegion Billing Address++
                    CustomerArray.Add(LineObj);

                    //Insert Temp record++
                    G_Temp_InterimCustomer.Init();
                    G_Temp_InterimCustomer.TransferFields(L_InterimCustomer);
                    //This transaction No nothing but Customer Sequence and It is use for at the insert Error log when sync is failed
                    if i = 1 then
                        G_Temp_InterimCustomer."Transaction No." := 0
                    else
                        G_Temp_InterimCustomer."Transaction No." := G_Temp_InterimCustomer."Transaction No." + 1;
                    G_Temp_InterimCustomer.Insert();

                    //+++
                    Loop := Loop - 1;
                    i := i + 1;
                end;
            until L_InterimCustomer.Next() = 0;
        end else begin
            //Exit Blank value If No record to sync++
            exit('');
        end;

        //Final body++
        Clear(FinalTextRequest);
        JsonObj.WriteTo(FinalTextRequest);
        exit(FinalTextRequest);
    end;




    procedure InsertLiferayErrorLogs(_DocumentType: Option " ","Product",FullIventory,DeltaInventory,Customer,Price,Order; _DocumentNo: Code[20]; _DocumentLineNo: Integer; _ChannelCode: Code[20]; _ErrorMessage: Text)
    var
        L_LiferayErrorlog: Record "LifeRay Error Log";
        Last_LiferayErrorlog: Record "LifeRay Error Log";
        OutStream: OutStream;
    begin
        L_LiferayErrorlog.Init();
        Last_LiferayErrorlog.Reset();
        if Last_LiferayErrorlog.FindLast() then
            L_LiferayErrorlog."Entry No." := Last_LiferayErrorlog."Entry No." + 1
        else
            L_LiferayErrorlog."Entry No." := 1;
        L_LiferayErrorlog."Document Type" := _DocumentType;
        L_LiferayErrorlog."Document No." := _DocumentNo;
        L_LiferayErrorlog."Document Line No." := _DocumentLineNo;
        //Convert text in blob datatype++
        Clear(L_LiferayErrorlog."Error Message");
        L_LiferayErrorlog."Error Message".CreateOutStream(OutStream, TEXTENCODING::UTF8);
        OutStream.WriteText(_ErrorMessage);
        L_LiferayErrorlog."Sync Date" := WorkDate();
        L_LiferayErrorlog."Channel Code" := _ChannelCode;
        L_LiferayErrorlog.Insert();
    end;

    procedure InsertLifeRayCorrelationID(_RecordRef: RecordRef; _DocumentType: Option " ","Product",FullIventory,DeltaInventory,Customer,Price; _ChannelCode: Code[20]; _Correlationid: Code[100])
    var
        L_CorrelationIDLifeRay: Record "correlation-id Tracking";
        Last_CorrelationIDLifeRay: Record "correlation-id Tracking";
        L_WebCustomer: Record "Interim Customer";
        L_ChannelItemListing: Record "Channel Item Listing";
        L_ItemReferece: Record "Item Reference";
        VariantCode: Code[2048];
        PIPCode: Code[2048];
        L_LifeRayStock: Record "LifeRay Stock";
        L_ItemVariant: Record "Item Variant";
        L_Data: Text;
        OutStream: OutStream;
        L_ChannelPrice: Record "Channel Price";
    begin
        Clear(L_Data);
        case _DocumentType of
            _DocumentType::Customer:
                begin
                    L_WebCustomer.Reset();
                    _RecordRef.SetTable(L_WebCustomer);
                    L_CorrelationIDLifeRay.Init();
                    L_CorrelationIDLifeRay.Reset();
                    if L_CorrelationIDLifeRay.FindLast() then
                        L_CorrelationIDLifeRay."Entry No." := L_CorrelationIDLifeRay."Entry No." + 1
                    else
                        L_CorrelationIDLifeRay."Entry No." := 1;
                    L_CorrelationIDLifeRay."Document Type" := _DocumentType;
                    L_CorrelationIDLifeRay."Correlation-Id" := _Correlationid;
                    L_CorrelationIDLifeRay."Channel Code" := _ChannelCode;
                    L_CorrelationIDLifeRay."Document No." := L_WebCustomer."Customer No.";
                    L_CorrelationIDLifeRay."Sync Date" := WorkDate();
                    L_CorrelationIDLifeRay."Data Sync Timestamp" := CurrentDateTime;

                    Clear(L_Data);
                    L_Data := 'CustomerNo:' + L_WebCustomer."Customer No." + ' |CustomerName:' + L_WebCustomer.Name +
                    ' |BilltoCustomerNo:' + L_WebCustomer."Bill to Customer No." + ' |BilltoCustomerName:' + L_WebCustomer."Bill to Customer Name" +
                    ' |CustomerGroup:' + L_WebCustomer."Customer Price Group 1" +
                    ' |CustomerGroup2:' + L_WebCustomer."Customer Price Group 2" +
                    ' |CustomerGroup3:' + L_WebCustomer."Customer Price Group 3" +
                    ' |ListingStatus:' + Format(L_WebCustomer."Listing Status Setting") +
                    ' |ShopGroup:' + L_WebCustomer."Customer Type" +
                    ' |ShippingAgentCode:' + L_WebCustomer."Shipping Agent Code" +
                    ' |ShippingAgentServiceCode:' + L_WebCustomer."Shipping Agent Service Code" +
                    ' |CreditLimit:' + Format(L_WebCustomer."Credit Limit (LCY)") +
                    ' |CreditLimitWarning:' + Format(L_WebCustomer."Credit Limit Warning") +
                    ' |Blocked:' + Format(L_WebCustomer.Blocked) +
                    ' |BlockReason:' + Format(L_WebCustomer."Block Reason") +
                    ' |ShiptoAddress:' + L_WebCustomer.Address + ' ;' + L_WebCustomer."Address 2" + ' ;' + L_WebCustomer."City" + ' ;' + L_WebCustomer.Country + ' ;' + L_WebCustomer."Post Code" +
                    ' |BilltoAddress:' + L_WebCustomer."Billing Address" + ' ;' + L_WebCustomer."Billing Address 2" + ' ;' + L_WebCustomer."Billing City" + ' ;' + L_WebCustomer."Billing Country" + ' ;' + L_WebCustomer."Billing Post Code";
                    //Convert text in blob datatype++
                    Clear(L_CorrelationIDLifeRay.Data);
                    L_CorrelationIDLifeRay.Data.CreateOutStream(OutStream, TEXTENCODING::UTF8);
                    OutStream.WriteText(L_Data);
                    L_CorrelationIDLifeRay.Insert();
                end;
            _DocumentType::Price:
                begin
                    L_ChannelPrice.Reset();
                    _RecordRef.SetTable(L_ChannelPrice);
                    L_CorrelationIDLifeRay.Init();
                    L_CorrelationIDLifeRay.Reset();
                    if L_CorrelationIDLifeRay.FindLast() then
                        L_CorrelationIDLifeRay."Entry No." := L_CorrelationIDLifeRay."Entry No." + 1
                    else
                        L_CorrelationIDLifeRay."Entry No." := 1;
                    L_CorrelationIDLifeRay."Document Type" := _DocumentType;
                    L_CorrelationIDLifeRay."Correlation-Id" := _Correlationid;
                    L_CorrelationIDLifeRay."Channel Code" := _ChannelCode;
                    L_CorrelationIDLifeRay."Document No." := L_ChannelPrice."Price List Code";
                    L_CorrelationIDLifeRay."Document Line No." := L_ChannelPrice."Line No.";
                    L_CorrelationIDLifeRay."Sync Date" := WorkDate();
                    L_CorrelationIDLifeRay."Data Sync Timestamp" := CurrentDateTime;

                    Clear(L_Data);
                    L_Data := 'PriceCode:' + L_ChannelPrice."Price List Code" +
                    ' |LineNo:' + Format(L_ChannelPrice."Line No.") +
                    ' |SourceType:' + Format(L_ChannelPrice."Source Type") +
                    ' |ItemNo:' + L_ChannelPrice."Product No." +
                    ' |VariantCode:' + L_ChannelPrice."Variant Code" +
                    ' |UnitPrice:' + Format(L_ChannelPrice."Unit Price") +
                    ' |ListingStatusSetting:' + Format(L_ChannelPrice."Listing Status Setting") +
                    ' |ListingStatus:' + Format(L_ChannelPrice."Listing Status");
                    //Convert text in blob datatype++
                    Clear(L_CorrelationIDLifeRay.Data);
                    L_CorrelationIDLifeRay.Data.CreateOutStream(OutStream, TEXTENCODING::UTF8);
                    OutStream.WriteText(L_Data);
                    L_CorrelationIDLifeRay.Insert();
                end;
            _DocumentType::Product:
                begin
                    L_ChannelItemListing.Reset();
                    _RecordRef.SetTable(L_ChannelItemListing);

                    L_CorrelationIDLifeRay.Init();
                    L_CorrelationIDLifeRay.Reset();
                    if L_CorrelationIDLifeRay.FindLast() then
                        L_CorrelationIDLifeRay."Entry No." := L_CorrelationIDLifeRay."Entry No." + 1
                    else
                        L_CorrelationIDLifeRay."Entry No." := 1;
                    L_CorrelationIDLifeRay."Document Type" := _DocumentType;
                    L_CorrelationIDLifeRay."Correlation-Id" := _Correlationid;
                    L_CorrelationIDLifeRay."Channel Code" := _ChannelCode;
                    L_CorrelationIDLifeRay."Document No." := L_ChannelItemListing."Item No.";
                    L_CorrelationIDLifeRay."Sync Date" := WorkDate();
                    L_CorrelationIDLifeRay."Data Sync Timestamp" := CurrentDateTime;
                    //Get Variant and PIP code from Item Reference table++
                    Clear(PIPCode);
                    L_ItemReferece.Reset();
                    L_ItemReferece.SetRange("Reference Type", L_ItemReferece."Reference Type"::"PIP Code");
                    L_ItemReferece.SetRange("Item No.", L_ChannelItemListing."Item No.");
                    if L_ItemReferece.FindSet() then begin
                        repeat
                            if PIPCode <> '' then begin
                                PIPCode := PIPCode + ';' + L_ItemReferece."Reference No.";
                            end else
                                PIPCode := L_ItemReferece."Reference No.";
                        until L_ItemReferece.Next() = 0;
                    end;
                    //++
                    Clear(VariantCode);
                    L_ItemVariant.Reset();
                    L_ItemVariant.SetRange("Item No.", L_ChannelItemListing."Item No.");
                    L_ItemVariant.SetRange("Blocked", false);
                    L_ItemVariant.SetRange("Sales Blocked", false);
                    if L_ItemVariant.FindSet() then begin
                        repeat
                            if VariantCode <> '' then begin
                                VariantCode := VariantCode + ';' + L_ItemVariant.Code;
                            end else
                                VariantCode := L_ItemVariant.Code;
                        until L_ItemVariant.Next() = 0;
                    end;

                    Clear(L_Data);
                    L_Data := 'ItemNo:' + L_ChannelItemListing."Item No." + ' |ASIN_No:' + L_ChannelItemListing."ASIN No" +
                    ' |ListingStting:' + Format(L_ChannelItemListing.Status) +
                    ' |ListingStatus:' + Format(L_ChannelItemListing."Listing Status") +
                    ' |Descrion:' + L_ChannelItemListing.Description +
                    ' |RRP:' + Format(L_ChannelItemListing.RRP) +
                    ' |UnitPrice:' + Format(L_ChannelItemListing."Unit Price") +
                    ' |CategoryCode:' + L_ChannelItemListing."Item Category Code" +
                    ' |PackSize:' + L_ChannelItemListing."Pack Size" +
                    ' |SalesBlocked:' + Format(L_ChannelItemListing."Sales Blocked") +
                    ' |OOPSSalesBlocked:' + Format(L_ChannelItemListing."Ops Sales Blocked") +
                    ' |LowStkthresholdQty:' + Format(L_ChannelItemListing."Lowstock Threshold") +
                    ' |Variants:' + VariantCode +
                    ' |PIPCode:' + PIPCode;

                    //Convert text in blob datatype++
                    Clear(L_CorrelationIDLifeRay.Data);
                    L_CorrelationIDLifeRay.Data.CreateOutStream(OutStream, TEXTENCODING::UTF8);
                    OutStream.WriteText(L_Data);
                    L_CorrelationIDLifeRay.Insert();
                end;
            _DocumentType::FullIventory:
                begin
                    L_LifeRayStock.Reset();
                    _RecordRef.SetTable(L_LifeRayStock);

                    L_CorrelationIDLifeRay.Init();
                    L_CorrelationIDLifeRay.Reset();
                    if L_CorrelationIDLifeRay.FindLast() then
                        L_CorrelationIDLifeRay."Entry No." := L_CorrelationIDLifeRay."Entry No." + 1
                    else
                        L_CorrelationIDLifeRay."Entry No." := 1;
                    L_CorrelationIDLifeRay."Document Type" := _DocumentType;
                    L_CorrelationIDLifeRay."Correlation-Id" := _Correlationid;
                    L_CorrelationIDLifeRay."Channel Code" := _ChannelCode;
                    L_CorrelationIDLifeRay."Document No." := Format(L_LifeRayStock."Entry No.");
                    L_CorrelationIDLifeRay."Sync Date" := WorkDate();
                    L_CorrelationIDLifeRay."Data Sync Timestamp" := CurrentDateTime;

                    Clear(L_Data);
                    L_Data := 'ItemNo:' + L_LifeRayStock."Item No." +
                    ' |Variantcode:' + L_LifeRayStock."Variant Code" +
                    ' |WarehouseID:' + L_LifeRayStock."Location Code" +
                    ' |Priority:' + Format(L_LifeRayStock."Variant Priority") +
                    ' |StockQty:' + Format(L_LifeRayStock.Inventory);

                    //Convert text in blob datatype++
                    Clear(L_CorrelationIDLifeRay.Data);
                    L_CorrelationIDLifeRay.Data.CreateOutStream(OutStream, TEXTENCODING::UTF8);
                    OutStream.WriteText(L_Data);
                    L_CorrelationIDLifeRay.Insert();
                end;
            _DocumentType::DeltaInventory:
                begin
                    L_LifeRayStock.Reset();
                    _RecordRef.SetTable(L_LifeRayStock);

                    L_CorrelationIDLifeRay.Init();
                    L_CorrelationIDLifeRay.Reset();
                    if L_CorrelationIDLifeRay.FindLast() then
                        L_CorrelationIDLifeRay."Entry No." := L_CorrelationIDLifeRay."Entry No." + 1
                    else
                        L_CorrelationIDLifeRay."Entry No." := 1;
                    L_CorrelationIDLifeRay."Document Type" := _DocumentType;
                    L_CorrelationIDLifeRay."Correlation-Id" := _Correlationid;
                    L_CorrelationIDLifeRay."Channel Code" := _ChannelCode;
                    L_CorrelationIDLifeRay."Document No." := Format(L_LifeRayStock."Entry No.");
                    L_CorrelationIDLifeRay."Sync Date" := WorkDate();
                    L_CorrelationIDLifeRay."Data Sync Timestamp" := CurrentDateTime;

                    Clear(L_Data);
                    L_Data := 'ItemNo:' + L_LifeRayStock."Item No." +
                    ' |Variantcode:' + L_LifeRayStock."Variant Code" +
                    ' |WarehouseID:' + L_LifeRayStock."Location Code" +
                    ' |Priority:' + Format(L_LifeRayStock."Variant Priority") +
                    ' |DeltaStock:' + Format(L_LifeRayStock.Inventory);

                    //Convert text in blob datatype++
                    Clear(L_CorrelationIDLifeRay.Data);
                    L_CorrelationIDLifeRay.Data.CreateOutStream(OutStream, TEXTENCODING::UTF8);
                    OutStream.WriteText(L_Data);
                    L_CorrelationIDLifeRay.Insert();
                end;
        end;
    end;

    local procedure CheckMadatoryfields(_ChannelCode: Code[20])
    var
        L_TradePartner: Record "Trade Partner";
    begin
        L_TradePartner.Reset();
        L_TradePartner.SetRange(Code, _ChannelCode);
        if L_TradePartner.FindFirst() then begin
            L_TradePartner.TestField("Sevice/API URL");
            L_TradePartner.TestField(SecretAccessKey);
            L_TradePartner.TestField("Batch Size");
        end else
            Error('Trade Partner setup missing for %1', _ChannelCode);
    end;

    procedure GetCredentials("ChannelCode": Code[20])
    var
        L_TradePartner: Record "Trade Partner";
    begin
        Clear(L_TradePartner);
        Clear(G_Service_URL);
        Clear(G_AccessKeyId);
        if L_TradePartner.Get(ChannelCode) then begin
            G_Service_URL := L_TradePartner."Sevice/API URL";
            G_AccessKeyId := L_TradePartner.SecretAccessKey;
        end;
    End;

    procedure GetJsonvalue(var aJsonObject: JsonObject; TokenKey: text) aJsonValue: JsonValue;
    var
        aJsonToken: JsonToken;
    begin
        if not aJsonObject.Get(TokenKey, aJsonToken) then
            Error('Could not find a token with key %1', TokenKey)
        Else
            aJsonValue := aJsonToken.AsValue();
    end;

    local procedure UpdateResponseMessage(var _Response: Text; _DocumentType: Option " ","Product",FullInventory,DeltaInventory,Customer,Price,Order)
    var
        ErrorIndices: List of [Integer];
        i: Integer;
        index: Integer;
        _AdditionMeesage: Text;
    begin
        // Extract indices from error response
        ErrorIndices := ExtractArrayIndicesFromErrorMessage(_Response);

        case _DocumentType of
            _DocumentType::Customer:
                begin
                    //Managed by liferay++
                end;
            _DocumentType::Price:
                begin
                    // Loop through the indices to identify problematic items
                    for i := 1 to ErrorIndices.Count() do begin
                        index := ErrorIndices.Get(i);

                        G_Temp_ChannelPrice.Reset();
                        G_Temp_ChannelPrice.SetRange("Transaction No.", index);
                        if G_Temp_ChannelPrice.FindFirst() then begin
                            if _AdditionMeesage <> '' then
                                _AdditionMeesage := _AdditionMeesage + '{' + 'Price List Code: ' + G_Temp_ChannelPrice."Price List Code" + ' |Line No.: ' + Format(G_Temp_ChannelPrice."Line No.") + ' |Item No.: ' + G_Temp_ChannelPrice."Product No." + '};'
                            else
                                _AdditionMeesage := '{' + 'Price List Code: ' + G_Temp_ChannelPrice."Price List Code" + ' |Line No.: ' + Format(G_Temp_ChannelPrice."Line No.") + ' |Item No.: ' + G_Temp_ChannelPrice."Product No." + '};';
                        end;
                    end;

                    if _AdditionMeesage <> '' then
                        _Response := _Response + ' ;BCDetails:[ ' + _AdditionMeesage + ' ]';
                end;
            _DocumentType::Product:
                begin
                    //Managed by liferay++
                end;
            _DocumentType::FullInventory:
                begin
                    // Loop through the indices to identify problematic items
                    for i := 1 to ErrorIndices.Count() do begin
                        index := ErrorIndices.Get(i);

                        G_Temp_Full_LifeRayStock.Reset();
                        G_Temp_Full_LifeRayStock.SetRange("Transaction No.", index);
                        if G_Temp_Full_LifeRayStock.FindFirst() then begin
                            if _AdditionMeesage <> '' then
                                _AdditionMeesage := _AdditionMeesage + '{' + 'EntryNo: ' + Format(G_Temp_Full_LifeRayStock."Entry No.") + ' |ItemNo: ' + G_Temp_Full_LifeRayStock."Item No." + ' |VariantCode: ' + G_Temp_Full_LifeRayStock."Variant Code" + ' |LocationCode:' + G_Temp_Full_LifeRayStock."Location Code" + '};'
                            else
                                _AdditionMeesage := '{' + 'EntryNo: ' + Format(G_Temp_Full_LifeRayStock."Entry No.") + ' |ItemNo: ' + G_Temp_Full_LifeRayStock."Item No." + ' |VariantCode: ' + G_Temp_Full_LifeRayStock."Variant Code" + ' |LocationCode:' + G_Temp_Full_LifeRayStock."Location Code" + '};';
                        end;
                    end;

                    if _AdditionMeesage <> '' then
                        _Response := _Response + ' ;BCDetails:[ ' + _AdditionMeesage + ' ]';
                end;
            _DocumentType::DeltaInventory:
                begin
                    // Loop through the indices to identify problematic items
                    for i := 1 to ErrorIndices.Count() do begin
                        index := ErrorIndices.Get(i);

                        G_Temp_Delta_LifeRayStock.Reset();
                        G_Temp_Delta_LifeRayStock.SetRange("Transaction No.", index);
                        if G_Temp_Delta_LifeRayStock.FindFirst() then begin
                            if _AdditionMeesage <> '' then
                                _AdditionMeesage := _AdditionMeesage + '{' + 'EntryNo: ' + Format(G_Temp_Delta_LifeRayStock."Entry No.") + ' |ItemNo: ' + G_Temp_Delta_LifeRayStock."Item No." + ' |VariantCode: ' + G_Temp_Delta_LifeRayStock."Variant Code" + ' |LocationCode:' + G_Temp_Delta_LifeRayStock."Location Code" + '};'
                            else
                                _AdditionMeesage := '{' + 'EntryNo: ' + Format(G_Temp_Delta_LifeRayStock."Entry No.") + ' |ItemNo: ' + G_Temp_Delta_LifeRayStock."Item No." + ' |VariantCode: ' + G_Temp_Delta_LifeRayStock."Variant Code" + ' |LocationCode:' + G_Temp_Delta_LifeRayStock."Location Code" + '};';
                        end;
                    end;

                    if _AdditionMeesage <> '' then
                        _Response := _Response + ' ;BCDetails:[ ' + _AdditionMeesage + ' ]';
                end;
            _DocumentType::Order:
                begin

                end;
        end;
    end;

    local procedure ExtractArrayIndicesFromErrorMessage(_ErrorResponse: Text): List of [Integer]
    var
        Indices: List of [Integer];
        startPos: Integer;
        endPos: Integer;
        indexStr: Text;
        indexValue: Integer;
        currentPos: Integer;
        pattern: Text;
    begin
        // Clear the list
        Clear(Indices);

        // Search for /items/ pattern and extract the number after it
        currentPos := 1;
        pattern := '/items/';

        repeat
            startPos := StrPos(CopyStr(_ErrorResponse, currentPos), pattern);
            if startPos > 0 then begin
                startPos := currentPos + startPos + StrLen(pattern) - 1;

                // Find the next slash or end of number
                endPos := startPos;
                while (endPos <= StrLen(_ErrorResponse)) and (_ErrorResponse[endPos] in ['0' .. '9']) do
                    endPos := endPos + 1;

                if endPos > startPos then begin
                    indexStr := CopyStr(_ErrorResponse, startPos, endPos - startPos);
                    if Evaluate(indexValue, indexStr) then begin
                        // Add only if not already in list
                        if Indices.IndexOf(indexValue) = 0 then
                            Indices.Add(indexValue);
                    end;
                end;

                currentPos := endPos;
            end else
                currentPos := 0;
        until currentPos = 0;

        exit(Indices);
    end;


    procedure GetVariantSetup(_ItemNo: Code[20]): Boolean
    var
        L_ItemVariant: Record "Item Variant";
        L_Item: Record Item;
    begin
        L_Item.Reset();
        L_Item.SetRange("No.", _ItemNo);
        if L_Item.FindFirst() then begin
            if L_Item."Variant Mandatory if Exists" <> L_Item."Variant Mandatory if Exists"::No then begin
                if L_Item."Variant Mandatory if Exists" = L_Item."Variant Mandatory if Exists"::Yes then
                    exit(true)
                else begin
                    L_ItemVariant.Reset();
                    L_ItemVariant.SetRange("Item No.", _ItemNo);
                    if L_ItemVariant.FindFirst() then
                        exit(true)
                    else
                        exit(false);
                end;
            end else
                exit(false);
        end;
    end;

}