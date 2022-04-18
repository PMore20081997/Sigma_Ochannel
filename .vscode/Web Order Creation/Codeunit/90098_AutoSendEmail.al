codeunit 90098 "Auto Send Email"
{
    TableNo = "Job Queue Entry";
    SingleInstance = true;
    trigger OnRun()
    var
        TradePartner: Record "Trade Partner";
    begin
        TradePartner.Reset();
        TradePartner.SetRange("Send Email To Customer", true);
        if TradePartner.FindSet() then begin
            repeat
                G_HISH.Reset();
                G_HISH.SetRange("Document Type", G_HISH."Document Type"::Order);
                G_HISH.SetRange("Email Send", false);
                G_HISH.SetFilter("Ship-to Email", '<>%1', '');
                G_HISH.SetRange(status, G_HISH.status::Dispatched);
                G_HISH.SetRange("Trade Partner Code", TradePartner.Code);
                if Rec."Parameter String" <> '' then
                    G_HISH.SetFilter("No.", Rec."Parameter String");
                if G_HISH.FindSet() then begin
                    repeat
                        InitTempCustomerEmail(G_HISH);
                        SendEmail(G_HISH);
                        G_HISH.Validate("Email Send", true);
                        G_HISH.Modify(true);
                    until G_HISH.Next() = 0;
                end;
            until TradePartner.Next() = 0;
        end;
    end;

    local procedure SendEmail(P_HISH: Record "Handled Interim Sales Header")
    var
        HISH: Record "Handled Interim Sales Header";
        ReportSelections: Record "Report Selections";
    begin
        HISH.Reset();
        HISH.SetRange("Document Type", P_HISH."Document Type");
        HISH.SetRange("No.", P_HISH."No.");
        if HISH.FindFirst() then
            ReportSelections.SendEmailToCust(
                           90090, HISH, HISH."Channel Order ID", 'Confirmation of Despatch', true, TempCustomer."No.");

    end;

    local procedure InitTempCustomerEmail(P_HISH: Record "Handled Interim Sales Header")
    begin
        TempCustomer.DeleteAll();
        TempCustomer.Init();
        TempCustomer."No." := P_HISH."Sell-to Customer No.";
        TempCustomer."E-Mail" := P_HISH."Ship-to Email";
        TempCustomer."Search Name" := 'Email Executed';
        TempCustomer.Insert();
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Document-Mailing", 'OnBeforeEmailFileInternal', '', false, false)]
    local procedure OnBeforeEmailFileInternal(var TempEmailItem: Record "Email Item" temporary; var HtmlBodyFilePath: Text[250]; var EmailSubject: Text[250]; var ToEmailAddress: Text[250]; var PostedDocNo: Code[20]; var EmailDocName: Text[250]; var HideDialog: Boolean; var ReportUsage: Integer; var IsFromPostedDoc: Boolean; var SenderUserID: Code[50]; var EmailScenario: Enum "Email Scenario")
    begin
        if ReportUsage = 90090 then begin
            ToEmailAddress := TempCustomer."E-Mail";
            HideDialog := true;
        end;

    end;

    var
        G_HISH: Record "Handled Interim Sales Header";
        TempCustomer: Record Customer temporary;
}