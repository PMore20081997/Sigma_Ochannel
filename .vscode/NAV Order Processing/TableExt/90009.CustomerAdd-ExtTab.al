tableextension 90009 "CustomerAdd" extends Customer
{
    fields
    {
        field(90000; "Payment Service Code"; Code[20])
        {
        }
        field(90001; "Web Customer No. 2"; Code[20])
        {
            DataClassification = ToBeClassified;
            Caption = 'Web Customer No.';
        }
        field(90002; "Customer type 2"; Option)
        {
            DataClassification = ToBeClassified;
            OptionMembers = NAV,Web,Both;
            OptionCaptionML = ENU = 'BC,Web,Both', ENG = 'BC,Web,Both';
        }
        field(90003; "Company Reg. No. 3"; Text[20])
        {
            CaptionML = ENU = 'Company Reg. No.';
        }
        field(90004; "EDI Invoice/Credit"; Boolean)
        {
            DataClassification = ToBeClassified;
            Caption = 'EDI Customer/Vendor';
        }
        modify(Name)
        {
            trigger OnAfterValidate()
            begin
                #Region only for SIGCONNECT++
                if Rec.Name <> xRec.Name then begin
                    G_InterimCustomer.Reset();
                    G_InterimCustomer.SetRange("Channel Code", 'SIGCONNECT');
                    G_InterimCustomer.SetRange("Customer No.", Rec."No.");
                    if G_InterimCustomer.FindFirst() then begin
                        G_InterimCustomer.Name := Rec.Name;
                        G_InterimCustomer."Customer Sync" := false;
                        G_InterimCustomer.Modify();
                    end;
                end;
                #EndRegion only for SIGCONNECT++
            end;
        }

        modify("Customer Price Group")
        {
            trigger OnAfterValidate()
            begin
                #Region only for SIGCONNECT++
                if Rec."Customer Price Group" <> xRec."Customer Price Group" then begin
                    G_InterimCustomer.Reset();
                    G_InterimCustomer.SetRange("Channel Code", 'SIGCONNECT');
                    G_InterimCustomer.SetRange("Customer No.", Rec."No.");
                    if G_InterimCustomer.FindFirst() then begin
                        G_InterimCustomer."Customer Price Group 1" := Rec."Customer Price Group";
                        G_InterimCustomer."Customer Sync" := false;
                        G_InterimCustomer.Modify();
                    end;
                end;
                #EndRegion only for SIGCONNECT++
            end;
        }
        modify("Customer Price Group 2")
        {
            trigger OnAfterValidate()
            begin
                #Region only for SIGCONNECT++
                if Rec."Customer Price Group 2" <> xRec."Customer Price Group 2" then begin
                    G_InterimCustomer.Reset();
                    G_InterimCustomer.SetRange("Channel Code", 'SIGCONNECT');
                    G_InterimCustomer.SetRange("Customer No.", Rec."No.");
                    if G_InterimCustomer.FindFirst() then begin
                        G_InterimCustomer."Customer Price Group 2" := Rec."Customer Price Group 2";
                        G_InterimCustomer."Customer Sync" := false;
                        G_InterimCustomer.Modify();
                    end;
                end;
                #EndRegion only for SIGCONNECT++
            end;
        }
        modify("Customer Price Group 3")
        {
            trigger OnAfterValidate()
            begin
                #Region only for SIGCONNECT++
                if Rec."Customer Price Group 3" <> xRec."Customer Price Group 3" then begin
                    G_InterimCustomer.Reset();
                    G_InterimCustomer.SetRange("Channel Code", 'SIGCONNECT');
                    G_InterimCustomer.SetRange("Customer No.", Rec."No.");
                    if G_InterimCustomer.FindFirst() then begin
                        G_InterimCustomer."Customer Price Group 3" := Rec."Customer Price Group 3";
                        G_InterimCustomer."Customer Sync" := false;
                        G_InterimCustomer.Modify();
                    end;
                end;
                #EndRegion only for SIGCONNECT++
            end;
        }
        modify("Customer Price Group 4")
        {
            trigger OnAfterValidate()
            begin
                #Region only for SIGCONNECT++
                if Rec."Customer Price Group 4" <> xRec."Customer Price Group 4" then begin
                    G_InterimCustomer.Reset();
                    G_InterimCustomer.SetRange("Channel Code", 'SIGCONNECT');
                    G_InterimCustomer.SetRange("Customer No.", Rec."No.");
                    if G_InterimCustomer.FindFirst() then begin
                        G_InterimCustomer."Customer Price Group 4" := Rec."Customer Price Group 4";
                        G_InterimCustomer."Customer Sync" := false;
                        G_InterimCustomer.Modify();
                    end;
                end;
                #EndRegion only for SIGCONNECT++
            end;
        }
        modify("Customer Price Group 5")
        {
            trigger OnAfterValidate()
            begin
                #Region only for SIGCONNECT++
                if Rec."Customer Price Group 5" <> xRec."Customer Price Group 5" then begin
                    G_InterimCustomer.Reset();
                    G_InterimCustomer.SetRange("Channel Code", 'SIGCONNECT');
                    G_InterimCustomer.SetRange("Customer No.", Rec."No.");
                    if G_InterimCustomer.FindFirst() then begin
                        G_InterimCustomer."Customer Price Group 5" := Rec."Customer Price Group 5";
                        G_InterimCustomer."Customer Sync" := false;
                        G_InterimCustomer.Modify();
                    end;
                end;
                #EndRegion only for SIGCONNECT++
            end;
        }
        modify("Customer Price Group 6")
        {
            trigger OnAfterValidate()
            begin
                #Region only for SIGCONNECT++
                if Rec."Customer Price Group 6" <> xRec."Customer Price Group 6" then begin
                    G_InterimCustomer.Reset();
                    G_InterimCustomer.SetRange("Channel Code", 'SIGCONNECT');
                    G_InterimCustomer.SetRange("Customer No.", Rec."No.");
                    if G_InterimCustomer.FindFirst() then begin
                        G_InterimCustomer."Customer Price Group 6" := Rec."Customer Price Group 6";
                        G_InterimCustomer."Customer Sync" := false;
                        G_InterimCustomer.Modify();
                    end;
                end;
                #EndRegion only for SIGCONNECT++
            end;
        }
        modify("Customer Price Group 7")
        {
            trigger OnAfterValidate()
            begin
                #Region only for SIGCONNECT++
                if Rec."Customer Price Group 7" <> xRec."Customer Price Group 7" then begin
                    G_InterimCustomer.Reset();
                    G_InterimCustomer.SetRange("Channel Code", 'SIGCONNECT');
                    G_InterimCustomer.SetRange("Customer No.", Rec."No.");
                    if G_InterimCustomer.FindFirst() then begin
                        G_InterimCustomer."Customer Price Group 7" := Rec."Customer Price Group 7";
                        G_InterimCustomer."Customer Sync" := false;
                        G_InterimCustomer.Modify();
                    end;
                end;
                #EndRegion only for SIGCONNECT++
            end;
        }
        modify("Customer Price Group 8")
        {
            trigger OnAfterValidate()
            begin
                #Region only for SIGCONNECT++
                if Rec."Customer Price Group 8" <> xRec."Customer Price Group 8" then begin
                    G_InterimCustomer.Reset();
                    G_InterimCustomer.SetRange("Channel Code", 'SIGCONNECT');
                    G_InterimCustomer.SetRange("Customer No.", Rec."No.");
                    if G_InterimCustomer.FindFirst() then begin
                        G_InterimCustomer."Customer Price Group 8" := Rec."Customer Price Group 8";
                        G_InterimCustomer."Customer Sync" := false;
                        G_InterimCustomer.Modify();
                    end;
                end;
                #EndRegion only for SIGCONNECT++
            end;
        }
        modify("Customer Price Group 9")
        {
            trigger OnAfterValidate()
            begin
                #Region only for SIGCONNECT++
                if Rec."Customer Price Group 9" <> xRec."Customer Price Group 9" then begin
                    G_InterimCustomer.Reset();
                    G_InterimCustomer.SetRange("Channel Code", 'SIGCONNECT');
                    G_InterimCustomer.SetRange("Customer No.", Rec."No.");
                    if G_InterimCustomer.FindFirst() then begin
                        G_InterimCustomer."Customer Price Group 9" := Rec."Customer Price Group 9";
                        G_InterimCustomer."Customer Sync" := false;
                        G_InterimCustomer.Modify();
                    end;
                end;
                #EndRegion only for SIGCONNECT++
            end;
        }
        modify("Customer Price Group 10")
        {
            trigger OnAfterValidate()
            begin
                #Region only for SIGCONNECT++
                if Rec."Customer Price Group 10" <> xRec."Customer Price Group 10" then begin
                    G_InterimCustomer.Reset();
                    G_InterimCustomer.SetRange("Channel Code", 'SIGCONNECT');
                    G_InterimCustomer.SetRange("Customer No.", Rec."No.");
                    if G_InterimCustomer.FindFirst() then begin
                        G_InterimCustomer."Customer Price Group 10" := Rec."Customer Price Group 10";
                        G_InterimCustomer."Customer Sync" := false;
                        G_InterimCustomer.Modify();
                    end;
                end;
                #EndRegion only for SIGCONNECT++
            end;
        }

    }

    var
        G_InterimCustomer: Record "Interim Customer";

    trigger OnDelete()
    var
        L_WebCustomer: Record "Interim Customer";
    begin
        L_WebCustomer.Reset();
        L_WebCustomer.SetRange("Customer No.", Rec."No.");
        //L_WebCustomer.SetRange("Channel Code", 'LIFERAY');
        if L_WebCustomer.FindFirst() then begin
            if not Confirm(StrSubstNo('Customer No. “%1” is linked to the PMR channel customer. If you delete this item, it will be marked as inactive in the PMR channel customer listing. Do you want to continue?', Rec."No."), true) then
                exit;

            //++Update++
            repeat
                L_WebCustomer."Listing Status Setting" := L_WebCustomer."Listing Status Setting"::Inactive;
                L_WebCustomer."Customer Sync" := false;
                L_WebCustomer.Modify();
            until L_WebCustomer.Next() = 0;
        end;
    end;
}