report 90004 "Print Manifest"
{
    DefaultLayout = RDLC;
    RDLCLayout = './Print Manifest.rdlc';

    dataset
    {
        dataitem(Integer; Integer)
        {
            DataItemTableView = SORTING(Number);
            MaxIteration = 1;
            column(TotalWebOrders; TotalWebOrders)
            {
            }
            column(G_ChannelCode; G_ChannelCode)
            {
            }
            column(NewManifestNumber; NewManifestNumber)
            {
            }

            trigger OnAfterGetRecord()
            var
                //Handled: Record "90012";
                Handled: Record "Handled Interim Sales Header";
            begin
                IF NOT Reprint THEN BEGIN //reprint+
                    //Commented Not Required++++++++++
                    /*Handled_ISH.RESET;
                    Handled_ISH.SETCURRENTKEY("Manifest No.");
                    Handled_ISH.SETFILTER("Manifest No.", '<>%1', '');
                    IF Handled_ISH.FIND('+') THEN BEGIN
                        NewManifestNumber := Handled_ISH."Manifest No." + 1;
                        //LastManifestNo:=Handled_ISH."Manifest No.";
                    END
                    ELSE BEGIN
                        //Commented By Abdul
                        InterimSalesHeader.RESET;
                        InterimSalesHeader.SETFILTER(ManifestNo, '>%1', 0);
                        IF InterimSalesHeader.FIND('+') THEN
                            NewManifestNumber := InterimSalesHeader.ManifestNo;
                        //Commented By Abdul
                        //NewManifestNumber := 1;
                    END;*/
                    //Commented Not Required-------------
                    //NewManifestNumber := NoSeriesManagement.GetNextNo(GenralSetupChannel."Manifest Nos", 0D, false); //New Code 02/11/2021
                    TradePartner.RESET;
                    IF TradePartner.GET(G_ChannelCode) THEN BEGIN //**2-
                        IF TradePartner.Manifest THEN BEGIN
                            Handled.RESET;
                            Handled.SETCURRENTKEY("Manifest No.");
                            Handled.SETFILTER("Manifest No.", '<>%1', '');
                            Handled.SETRANGE("Trade Partner Code", G_ChannelCode);
                            IF Handled.FIND('+') THEN
                                NewManifestNumber := Handled."Manifest No.";

                            HandledWebOrder.RESET;
                            HandledWebOrder.SETRANGE("Trade Partner Code", G_ChannelCode);
                            HandledWebOrder.SETRANGE("Document Type", HandledWebOrder."Document Type"::Order);
                            HandledWebOrder.SETRANGE(Status, HandledWebOrder.Status::Dispatched);
                            HandledWebOrder.SETFILTER("Scanned Date", '>%1', CREATEDATETIME(20210102D, TIME)); //010221D
                            HandledWebOrder.SETFILTER("Manifest No.", '%1', NewManifestNumber);
                            IF HandledWebOrder.FINDSET THEN BEGIN
                                TotalWebOrders := HandledWebOrder.COUNT;
                                REPEAT
                                    HandledWebOrder."Manifest Print Date" := CURRENTDATETIME;
                                    //NewManifestNumber:=HandledWebOrder."Manifest No.";
                                    HandledWebOrder.MODIFY(TRUE);
                                UNTIL HandledWebOrder.NEXT = 0;
                            END;

                        END //
                        ELSE //if not manifest
                         BEGIN //**1+
                            //New Code +++++++ 11/02/2021
                            NewManifestNumber := NoSeriesManagement.GetNextNo(GenralSetupChannel."Manifest Nos", 0D, false);
                            //New Code ------- 11/02/2021
                            HandledWebOrder.RESET;
                            HandledWebOrder.SETRANGE("Trade Partner Code", G_ChannelCode);
                            HandledWebOrder.SETRANGE("Document Type", HandledWebOrder."Document Type"::Order);
                            HandledWebOrder.SETRANGE(Status, HandledWebOrder.Status::Dispatched);
                            HandledWebOrder.SETFILTER("Scanned Date", '>%1', CREATEDATETIME(20210102D, TIME));
                            HandledWebOrder.SETFILTER("Manifest No.", '%1', '');
                            HandledWebOrder.SETFILTER("Manifest Print Date", '%1', 0DT);
                            IF HandledWebOrder.FINDSET THEN BEGIN
                                TotalWebOrders := HandledWebOrder.COUNT;
                                REPEAT
                                    HandledWebOrder."Manifest Print Date" := CURRENTDATETIME;
                                    HandledWebOrder."Manifest No." := NewManifestNumber;
                                    HandledWebOrder.MODIFY(TRUE);
                                UNTIL HandledWebOrder.NEXT = 0;
                            END;
                        END;//**1-

                    END; //**2-

                    /*HandledWebOrder.RESET;
                    HandledWebOrder.SETRANGE("Trade Partner Code",G_ChannelCode);
                    HandledWebOrder.SETRANGE("Document Type",HandledWebOrder."Document Type"::Order);
                    HandledWebOrder.SETRANGE(Status,HandledWebOrder.Status::Dispatched);
                    HandledWebOrder.SETFILTER("Scanned Date",'>%1',CREATEDATETIME(020121D,TIME));
                    HandledWebOrder.SETFILTER("Manifest No.",'%1',0);
                    HandledWebOrder.SETFILTER("Manifest Print Date",'%1',0DT);
                    IF HandledWebOrder.FINDSET THEN BEGIN
                      TotalWebOrders := HandledWebOrder.COUNT;
                      REPEAT
                       //MESSAGE(FORMAT(InterimSalesHeader."No."));

                    HandledWebOrder."Manifest Print Date":= CURRENTDATETIME;
                    HandledWebOrder."Manifest No.":=NewManifestNumber;
                    HandledWebOrder.MODIFY(TRUE);
                    //MESSAGE(FORMAT(InterimSalesHeader.ManifestNo));

                        UNTIL HandledWebOrder.NEXT=0;
                    END;*/
                END //reprint-
                ELSE BEGIN  //**Reprint+
                    HandledWebOrder.RESET;
                    HandledWebOrder.SETRANGE("Trade Partner Code", G_ChannelCode);
                    HandledWebOrder.SETRANGE("Document Type", HandledWebOrder."Document Type"::Order);
                    HandledWebOrder.SETRANGE(Status, HandledWebOrder.Status::Dispatched);
                    HandledWebOrder.SETFILTER("Scanned Date", '>%1', CREATEDATETIME(20210201D, TIME)); //010221D
                    HandledWebOrder.SETFILTER("Manifest No.", '%1', ManifestNumberFilter);
                    IF HandledWebOrder.FINDSET THEN BEGIN
                        TotalWebOrders := HandledWebOrder.COUNT;
                        REPEAT
                            HandledWebOrder."Manifest Print Date" := CURRENTDATETIME;
                            NewManifestNumber := HandledWebOrder."Manifest No.";
                            HandledWebOrder.MODIFY(TRUE);
                        UNTIL HandledWebOrder.NEXT = 0;
                    END;

                END; //**Reprint-
                /*
                IF NOT Reprint THEN
                BEGIN
                ISH.RESET;
                ISH.SETFILTER(ManifestNo,'>0');
                IF ISH.FIND('+') THEN
                 NewManifestNumber := ISH.ManifestNo + 1
                ELSE
                  NewManifestNumber := 1;
                
                InterimSalesHeader.RESET;
                InterimSalesHeader.SETRANGE("Trade Partner Code",G_ChannelCode);
                InterimSalesHeader.SETRANGE("Document Type",InterimSalesHeader."Document Type"::Order);
                InterimSalesHeader.SETRANGE(Status,InterimSalesHeader.Status::Dispatched);
                //InterimSalesHeader.SETRANGE(Status,InterimSalesHeader.Status::"Ready To Dispatch");
                InterimSalesHeader.SETFILTER(ManifestNo,'%1',0);
                InterimSalesHeader.SETFILTER(PrintManifest,'%1',0DT);
                IF InterimSalesHeader.FINDSET THEN BEGIN
                  TotalWebOrders := InterimSalesHeader.COUNT;
                  REPEAT
                   //MESSAGE(FORMAT(InterimSalesHeader."No."));
                
                InterimSalesHeader.PrintManifest:= CURRENTDATETIME;
                InterimSalesHeader.ManifestNo:=NewManifestNumber;
                InterimSalesHeader.MODIFY(TRUE);
                
                //MESSAGE(FORMAT(InterimSalesHeader.ManifestNo));
                
                    UNTIL InterimSalesHeader.NEXT=0;
                END;
                END ELSE
                BEGIN
                InterimSalesHeader.RESET;
                InterimSalesHeader.SETRANGE("Trade Partner Code",G_ChannelCode);
                InterimSalesHeader.SETRANGE("Document Type",InterimSalesHeader."Document Type"::Order);
                InterimSalesHeader.SETRANGE(Status,InterimSalesHeader.Status::Dispatched);
                InterimSalesHeader.SETFILTER(ManifestNo,'%1',ManifestNumberFilter);
                IF InterimSalesHeader.FINDSET THEN BEGIN
                  TotalWebOrders := InterimSalesHeader.COUNT;
                  REPEAT
                    InterimSalesHeader.PrintManifest:= CURRENTDATETIME;
                    NewManifestNumber:=InterimSalesHeader.ManifestNo;
                    InterimSalesHeader.MODIFY(TRUE);
                  UNTIL InterimSalesHeader.NEXT=0;
                END;
                END;
                */

            end;
        }
    }

    requestpage
    {

        layout
        {
            area(content)
            {
                field("Re-Print"; Reprint)
                {
                    ApplicationArea = All;
                }
                field("Manifest No."; ManifestNumberFilter)
                {
                    //BlankZero = true;
                    Editable = Reprint;
                    ApplicationArea = All;
                }
            }
        }

        actions
        {
        }

        trigger OnQueryClosePage(CloseAction: Action): Boolean
        begin
            IF NOT (CloseAction = ACTION::Cancel) THEN
                IF Reprint THEN
                    IF ManifestNumberFilter = '' THEN
                        ERROR('Please enter manifest no to Re-Print');
        end;
    }

    labels
    {
    }


    trigger OnPreReport()
    begin
        GenralSetupChannel.Get();
    end;


    var
        NoSeriesManagement: Codeunit NoSeriesManagement;
        GenralSetupChannel: record "General Setup - Channels";
        G_ChannelCode: Code[10];
        InterimSalesHeader: Record "Interim Sales Header";
        TotalWebOrders: Integer;
        ISH: Record "Interim Sales Header";
        [InDataSet]
        //NewManifestNumber: Integer;
        NewManifestNumber: Code[20];
        InterimSalesHeaderRec: Record "Interim Sales Header";
        ISL: Record "Interim Sales Line";
        [InDataSet]
        Reprint: Boolean;
        //ManifestNumberFilter: Integer;
        ManifestNumberFilter: Code[20];
        //Handled_ISH: Record "90012";
        Handled_ISH: Record "Handled Interim Sales Header";
        Handled_ISL: Record "Handled Interim Sales Line";
        //HandledWebOrder: Record "90012";
        HandledWebOrder: Record "Handled Interim Sales Header";
        LastManifestNo: Integer;
        TradePartner: Record "Trade Partner";

    procedure GetChannelCode(L_ChannelCode: Code[10])
    begin
        G_ChannelCode := L_ChannelCode;
    end;
}

