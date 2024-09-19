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