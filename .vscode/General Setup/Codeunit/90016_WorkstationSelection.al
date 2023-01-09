codeunit 90016 WorkstationSelection
{
    var
        G_GeneralSetup: Record "General Setup - Channels";

    trigger OnRun()
    begin
        UpdateWorkstation();
    end;

    procedure UpdateWorkstation()
    var
        L_Workstations: Record "Workstation Printer Selection";
        L_PrinterSelection: Record "Printer Selection";
        "Workstation Selection": Text;
        Workstations: List of [Text];
        "Workstation": Text;

    begin
        G_GeneralSetup.Get();
        if L_Workstations.FindSet() then begin
            repeat
                "Workstation Selection" += L_Workstations.Workstation + ',';
                Workstations.Add(L_Workstations.Workstation);
            until L_Workstations.Next() = 0;
        end;
        "Workstation" := Workstations.Get(StrMenu("Workstation Selection", 1, 'Please select your workstation'));
        L_Workstations.Reset();
        L_Workstations.SetFilter(Workstation, Workstation);
        if L_Workstations.FindFirst() then begin
            L_PrinterSelection.SetFilter("User ID", UserId());
            if L_PrinterSelection.FindSet() then begin
                repeat
                    if L_PrinterSelection."Report ID" = G_GeneralSetup."Label Report ID" then L_PrinterSelection."Printer Name" := L_Workstations."Label Printer";
                    if L_PrinterSelection."Report ID" = G_GeneralSetup."Despatch Note Report ID" then L_PrinterSelection."Printer Name" := L_Workstations."Despatch Note Printer";
                    if L_PrinterSelection."Report ID" = G_GeneralSetup."DPD Label Report ID" then L_PrinterSelection."Printer Name" := L_Workstations."DPD Label Printer";
                    L_PrinterSelection.Modify();
                until L_PrinterSelection.Next() = 0;
            end;
        end;


    end;
}
