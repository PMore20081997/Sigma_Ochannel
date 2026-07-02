codeunit 90028 "OC Event & Subscriber"
{
    trigger OnRun()
    begin

    end;

    var
        myInt: Integer;


    [EventSubscriber(ObjectType::Codeunit, Codeunit::ArchiveManagement, 'OnAfterStoreSalesDocument', '', false, false)]
    local procedure OnAfterStoreSalesDocument(var SalesHeader: Record "Sales Header"; var SalesHeaderArchive: Record "Sales Header Archive")
    begin
        if SalesHeader."Document Type" = SalesHeader."Document Type"::Order then begin
            SalesHeaderArchive."Web Order" := SalesHeader."Web Order";
            SalesHeaderArchive."Sales Order Created By" := GetUserName(SalesHeader.SystemCreatedBy);
            SalesHeaderArchive.Modify();
        end;
    end;


    #Region SBB-713+++++++++++++++++++++++++++
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Release Purchase Document", 'OnBeforeReleasePurchaseDoc', '', false, false)]
    local procedure OnBeforeReleasePurchaseDoc(var PurchaseHeader: Record "Purchase Header")
    begin
        if PurchaseHeader."Document Type" = PurchaseHeader."Document Type"::Order then begin
            if PurchaseHeader.Status <> PurchaseHeader.Status::Released then begin
                if PurchaseHeader."Your Reference" = '' then
                    Error('Your Reference cannot be blank in Purchase Order %1', PurchaseHeader."No.");
            end;
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Approvals Mgmt.", 'OnBeforeCheckPurchaseApprovalPossible', '', false, false)]

    local procedure OnBeforeCheckPurchaseApprovalPossible(var PurchaseHeader: Record "Purchase Header"; var Result: Boolean; var IsHandled: Boolean)

    var
        P_Line: Record "Purchase Line";
    begin
        if PurchaseHeader."Document Type" = PurchaseHeader."Document Type"::Order then begin
            if PurchaseHeader.Status <> PurchaseHeader.Status::Released then begin
                if PurchaseHeader."Your Reference" = '' then
                    Error('Your Reference cannot be blank in Purchase Order %1', PurchaseHeader."No.");
            end;
        end;
    end;
    #EndRegion SBB-713+++++++++++++++++++++++++++


    procedure GetUserName(UserSecurityId: Code[50]): Text[100]
    var
        Users: Record User;
    begin
        Users.Reset();
        Users.SetRange("User Security ID", UserSecurityId);
        if Users.FindFirst() then
            exit(Users."User Name");
    end;
}