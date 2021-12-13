tableextension 90095 "Gen Journal Ext" extends "Gen. Journal Line"
{
    fields
    {
        modify(Amount)
        {
            Caption = 'Net Amount to Bank';
        }
        field(90000; Reconciled; Boolean)
        {
            ObsoleteState = Removed;
            ObsoleteReason = 'Not In Use';
        }
        field(90001; "Order Amount (System)"; Decimal)
        {
            Editable = false;
            ObsoleteState = Removed;
            ObsoleteReason = 'Not In Use';
        }
        field(90002; Diffrance; Decimal)
        {
            Editable = false;
            ObsoleteState = Removed;
            ObsoleteReason = 'Not In Use';
        }
        field(90003; Fees; Decimal)
        {
            Editable = false;
            ObsoleteState = Removed;
            ObsoleteReason = 'Not In Use';
        }
    }
    trigger OnAfterDelete()
    var
        L_ChannelLines: Record "Channel Payment Line";
    begin
        L_ChannelLines.Reset();
        L_ChannelLines.SetRange("External Document No.", Rec."External Document No.");
        if L_ChannelLines.FindSet() then begin
            repeat
                L_ChannelLines.Validate("Journal Created", false);
                L_ChannelLines.Modify(true);
            until L_ChannelLines.Next() = 0;
        end;
    end;
}