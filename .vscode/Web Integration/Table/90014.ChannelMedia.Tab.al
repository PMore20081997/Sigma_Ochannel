table 90014 "Channel Media"
{
    fields
    {
        field(1; "Entry No"; Integer)
        {
            AutoIncrement = true;
        }
        field(2; "Channel Code"; Code[20])
        {
        }
        field(3; "Channel Order ID"; Code[250])
        {
        }
        field(4; Amount; Decimal)
        {
        }
        field(5; Status; Option)
        {
            OptionCaption = 'Not Created,Created,Posted';
            OptionMembers = "Not Created",Created,Posted;
        }
        field(6; "Transaction ID"; Code[50])
        {
        }
        field(7; "Payment Method"; Text[50])
        {
        }
        field(8; "Web Order No."; Code[20])
        {
        }
        field(9; "Entry Type"; Option)
        {
            OptionCaption = ',Payment,Refund';
            OptionMembers = ,Payment,Refund;
        }
        field(10; "Transaction Date"; Date)
        {
        }
        field(11; "Transaction Reference no"; Text[40])
        {
        }
        field(12; "Nav Payment Method"; Code[10])
        {
        }
        field(13; "Currency Factor"; Decimal)
        {
        }
        field(14; "Currency Code"; Code[10])
        {
        }
        field(15; "Amount(FCY)"; Decimal)
        {
        }
        field(16; Debit; Decimal)
        {
        }
        field(17; Credit; Decimal)
        {
        }
        field(18; "Payment Status"; Code[20])
        {
            Description = 'Only for Shopify Orders';
        }
        field(19; "Customer No."; Code[20])
        {
        }
        field(20; "Invoice No."; Code[20])
        {
        }
        field(22; "Gift Card"; Boolean)
        {
        }
        field(21; "Parent Transaction ID"; Code[50])
        {
        }
    }

    keys
    {
        key(Key1; "Entry No")
        {
        }
        key(key2; "Payment Method")
        {
        }
    }


    procedure ShowPaymentDetails(ChannelOrderId: Text; OrderID: Code[50]; Source: Option "Interim Sales header","Sales Order","Handelled Incoming"; ChannelCode: Code[20])
    var
        ChannelMedia: Record "Channel Media";
        PaymentDetails: Page "Payment Details";
    begin
        Case Source of
            Source::"Interim Sales header", Source::"Handelled Incoming":
                BEGIN
                    ChannelMedia.Reset();
                    ChannelMedia.SetFilter("Channel Order ID", ChannelOrderId);
                    ChannelMedia.SetRange("Channel Code", ChannelCode);
                    If ChannelMedia.FindSet then begin
                        PaymentDetails.SetTableView(ChannelMedia);
                        PaymentDetails.SetRecord(ChannelMedia);
                        PaymentDetails.Run();
                    end;
                End;
            Source::"Sales Order":
                begin
                    ChannelMedia.Reset();
                    ChannelMedia.SetFilter("Channel Order ID", ChannelOrderId);
                    If ChannelMedia.FindSet then begin
                        PaymentDetails.SetTableView(ChannelMedia);
                        PaymentDetails.SetRecord(ChannelMedia);
                        PaymentDetails.Run();
                    end;
                end;
        end;
    end;
}