tableextension 90092 "Item Templ Ext" extends "Item Templ."
{
    procedure NewItemFromTemplate(var Item: Record Item): Boolean
    var
        ConfigTemplateHeader: Record "Config. Template Header";
        ConfigTemplates: Page "Config Templates";
    begin
        ConfigTemplateHeader.SetRange("Table ID", DATABASE::Item);
        ConfigTemplateHeader.SetRange(Enabled, true);

        if ConfigTemplateHeader.Count = 1 then begin
            ConfigTemplateHeader.FindFirst;
            InsertItemFromTemplate(ConfigTemplateHeader, Item);
            exit(true);
        end;

        if (ConfigTemplateHeader.Count > 1) and GuiAllowed then begin
            ConfigTemplates.SetTableView(ConfigTemplateHeader);
            ConfigTemplates.LookupMode(true);
            ConfigTemplates.SetNewMode;
            if ConfigTemplates.RunModal = ACTION::LookupOK then begin
                ConfigTemplates.GetRecord(ConfigTemplateHeader);
                InsertItemFromTemplate(ConfigTemplateHeader, Item);
                exit(true);
            end;
        end;

        exit(false);
    end;



    procedure InsertItemFromTemplate(ConfigTemplateHeader: Record "Config. Template Header"; var Item: Record Item)
    var
        DimensionsTemplate: Record "Dimensions Template";
        UnitOfMeasure: Record "Unit of Measure";
        ConfigTemplateMgt: Codeunit "Config. Template Management";
        RecRef: RecordRef;
        FoundUoM: Boolean;
    begin
        InitItemNo(Item, ConfigTemplateHeader);
        Item.Insert(true);
        RecRef.GetTable(Item);
        ConfigTemplateMgt.UpdateRecord(ConfigTemplateHeader, RecRef);
        RecRef.SetTable(Item);

        if Item."Base Unit of Measure" = '' then begin
            UnitOfMeasure.SetRange("International Standard Code", 'EA'); // 'Each' ~= 'PCS'
            FoundUoM := UnitOfMeasure.FindFirst;
            if not FoundUoM then begin
                UnitOfMeasure.SetRange("International Standard Code");
                FoundUoM := UnitOfMeasure.FindFirst;
            end;
            if FoundUoM then begin
                Item.Validate("Base Unit of Measure", UnitOfMeasure.Code);
                Item.Modify(true);
            end;
        end;

        DimensionsTemplate.InsertDimensionsFromTemplates(ConfigTemplateHeader, Item."No.", DATABASE::Item);
        Item.Find;

        OnAfterInsertItemFromTemplate(Rec, Item, ConfigTemplateHeader);
    end;

    local procedure InitItemNo(var Item: Record Item; ConfigTemplateHeader: Record "Config. Template Header")
    var
        //NoSeriesMgt: Codeunit NoSeriesManagement;
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeInitItemNo(Item, ConfigTemplateHeader, IsHandled);
        if IsHandled then
            exit;

        if ConfigTemplateHeader."Instance No. Series" = '' then
            exit;
        //NoSeriesMgt.InitSeries(ConfigTemplateHeader."Instance No. Series", '', 0D, Item."No.", Item."No. Series");
    end;

    local procedure OnBeforeInitItemNo(var Item: Record Item; ConfigTemplateHeader: Record "Config. Template Header"; var IsHandled: Boolean)
    begin
    end;

    local procedure OnAfterInsertItemFromTemplate(var ItemTemplate: Record "Item Templ."; var Item: Record Item; ConfigTemplateHeader: Record "Config. Template Header")
    begin
    end;
}