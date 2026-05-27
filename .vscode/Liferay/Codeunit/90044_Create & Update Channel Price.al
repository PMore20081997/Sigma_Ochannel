codeunit 90044 "Create & Update Channel Price"
{
    TableNo = "Job Queue Entry";
    trigger OnRun()
    begin
        StartParameter := Rec."Parameter String";
        if StartParameter <> '' then
            Create_Update_ChannelPrice(StartParameter)
        else
            Error('Parameter String is missing');

    end;

    var
        myInt: Integer;
        StartParameter: Text;
        RunType: Text;

    procedure Create_Update_ChannelPrice(_ChannelCode: Code[50])
    var
        L_TradePartner: Record "Trade Partner";
        L_PriceListLine: Record "Price List Line";
        L_ChannelPrice: Record "Channel Price";
        L_PriceListHeader: Record "Price List Header";
    begin
        #Region Check Mandatory fields++
        if _ChannelCode = '' then
            Error('Channel Code is missing in request parameter');

        if L_TradePartner.Get(_ChannelCode) then
            if L_TradePartner.SyncPrice = false then
                Error('Sync Price should be TRUE for channel code %1', _ChannelCode);
        #EndRegion Check Mandatory fields++


        L_TradePartner.Reset();
        L_TradePartner.SetRange(SyncPrice, true);
        L_TradePartner.SetFilter(Code, _ChannelCode);
        if L_TradePartner.FindSet() then begin
            repeat
                #Region For Existing Price+++
                L_PriceListLine.Reset();
                L_PriceListLine.SetRange("Source Group", L_PriceListLine."Source Group"::Customer);
                L_PriceListLine.SetRange("Price Type", L_PriceListLine."Price Type"::Sale);
                if L_TradePartner.Code = 'LIFERAY' then
                    L_PriceListLine.SetRange("Master LifeRay", true);
                if L_TradePartner.Code = 'DC' then
                    L_PriceListLine.SetRange("Master DC", true);
                if L_PriceListLine.FindSet() then begin
                    repeat
                        L_ChannelPrice.Reset();
                        L_ChannelPrice.SetFilter("Channel Code", L_TradePartner.Code);
                        L_ChannelPrice.SetRange("Price Exist", true);
                        L_ChannelPrice.SetRange("Price List Code", L_PriceListLine."Price List Code");
                        L_ChannelPrice.SetRange("Line No.", L_PriceListLine."Line No.");
                        if not L_ChannelPrice.FindFirst() then begin
                            L_ChannelPrice.Init();
                            L_ChannelPrice.TransferFields(L_PriceListLine);
                            L_ChannelPrice."Channel Code" := L_TradePartner.Code;
                            L_ChannelPrice."Listing Status" := L_PriceListLine."Listing Status";
                            L_ChannelPrice."Listing Status Setting" := L_PriceListLine."Listing Status Setting";
                            L_ChannelPrice."Base Volume" := L_PriceListLine."Base Volume";
                            L_ChannelPrice."Cost Unit Thereafter" := L_PriceListLine."Cost Unit Thereafter";
                            L_ChannelPrice."Sync Price" := false;
                            L_ChannelPrice.Insert();
                        end else begin
                            if L_ChannelPrice."Listing Status Setting" = L_ChannelPrice."Listing Status Setting"::Inactive then begin
                                if L_ChannelPrice.SystemModifiedAt < L_PriceListLine.SystemModifiedAt then begin
                                    L_ChannelPrice.TransferFields(L_PriceListLine);
                                    L_ChannelPrice."Channel Code" := L_TradePartner.Code;
                                    L_ChannelPrice."Listing Status" := L_PriceListLine."Listing Status";
                                    L_ChannelPrice."Listing Status Setting" := L_PriceListLine."Listing Status Setting";
                                    L_ChannelPrice."Base Volume" := L_PriceListLine."Base Volume";
                                    L_ChannelPrice."Cost Unit Thereafter" := L_PriceListLine."Cost Unit Thereafter";
                                    L_ChannelPrice."Sync Price" := false;
                                    L_ChannelPrice.Modify();
                                end;
                            end;
                        end;
                    until L_PriceListLine.Next() = 0;
                end;
                #EndRegion For Existing Price+++

                #Region For Delete Price from Price table++
                Commit();
                L_ChannelPrice.Reset();
                L_ChannelPrice.SetRange("Price Exist", false);
                L_ChannelPrice.SetRange("Channel Code", L_TradePartner.Code);
                if L_ChannelPrice.FindSet() then begin
                    repeat
                        L_ChannelPrice."Sync Price" := false;
                        L_ChannelPrice."Listing Status Setting" := L_ChannelPrice."Listing Status Setting"::Inactive;
                        L_ChannelPrice.Modify();
                    until L_ChannelPrice.Next() = 0;
                end;
            #EndRegion For Delete Price from Price table++
            until L_TradePartner.Next() = 0;
        end;

    end;

    procedure Update_ChannelPrice(_ChannelPrice: Record "Channel Price")
    var
        L_PriceListLine: Record "Price List Line";
        L_ChannelPrice: Record "Channel Price";
    begin
        L_PriceListLine.Reset();
        L_PriceListLine.SetRange("Source Group", L_PriceListLine."Source Group"::Customer);
        L_PriceListLine.SetRange("Price Type", L_PriceListLine."Price Type"::Sale);
        L_PriceListLine.SetRange("Price List Code", _ChannelPrice."Price List Code");
        L_PriceListLine.SetRange("Line No.", _ChannelPrice."Line No.");
        if L_PriceListLine.FindSet() then begin
            repeat
                L_ChannelPrice.Reset();
                L_ChannelPrice.SetFilter("Channel Code", _ChannelPrice."Channel Code");
                L_ChannelPrice.SetRange("Price List Code", L_PriceListLine."Price List Code");
                L_ChannelPrice.SetRange("Line No.", L_PriceListLine."Line No.");
                L_ChannelPrice.SetRange("Listing Status Setting", L_ChannelPrice."Listing Status Setting"::Inactive);
                if L_ChannelPrice.FindFirst() then begin
                    if L_ChannelPrice.SystemModifiedAt < L_PriceListLine.SystemModifiedAt then begin
                        L_ChannelPrice.TransferFields(L_PriceListLine);
                        L_ChannelPrice."Channel Code" := _ChannelPrice."Channel Code";
                        L_ChannelPrice."Listing Status" := L_PriceListLine."Listing Status";
                        L_ChannelPrice."Listing Status Setting" := L_PriceListLine."Listing Status Setting";
                        L_ChannelPrice."Base Volume" := L_PriceListLine."Base Volume";
                        L_ChannelPrice."Cost Unit Thereafter" := L_PriceListLine."Cost Unit Thereafter";
                        L_ChannelPrice."Sync Price" := false;
                        L_ChannelPrice.Modify();
                    end;
                end;
            until L_PriceListLine.Next() = 0;
        end;
    end;
}