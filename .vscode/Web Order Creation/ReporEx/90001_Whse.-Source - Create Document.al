reportextension 90001 "Create Doc Ext" extends "Whse.-Source - Create Document"
{
    dataset
    {
        modify("Whse. Internal Pick Line")
        {
            trigger OnBeforeAfterGetRecord()
            var
                CreatePick: Codeunit "Create Pick";
                //  NewCreatePick: Codeunit "Create Pick new";
                QtyToPick: Decimal;
                AllocatedQty: Decimal;
                QtyToPickBase: Decimal;
                WMSMgt: Codeunit "WMS Management";
                SkipProdOrderComp: Boolean;
                WhseWkshLine: Record "Whse. Worksheet Line";
                WhseWkshLineFound: Boolean;
            begin
                IF G_ZoneFilter <> '' THEN begin
                    WMSMgt.CheckInboundBlockedBin("Location Code", "To Bin Code", "Item No.", "Variant Code", "Unit of Measure Code");

                    CheckBin(FALSE);
                    WhseWkshLine.SETRANGE("Whse. Document Line No.", "Line No.");
                    IF NOT WhseWkshLine.FINDFIRST THEN BEGIN
                        TESTFIELD("Qty. per Unit of Measure");
                        CALCFIELDS("Pick Qty. (Base)");

                        //Chandan++270620
                        CLEAR(AllocatedQty);
                        AllocatedQty := 0;

                        QtyToPickBase := AllocatedQty - ("Qty. Picked (Base)" + "Pick Qty. (Base)");
                        QtyToPick :=
                          ROUND(
                            (AllocatedQty - ("Qty. Picked (Base)" + "Pick Qty. (Base)")) /
                            "Qty. per Unit of Measure", 0.00001);


                        IF QtyToPick > 0 THEN BEGIN
                            CreatePick.SetWhseInternalPickLine("Whse. Internal Pick Line", 1);
                            CreatePick.SetTempWhseItemTrkgLine(
                              "No.", DATABASE::"Whse. Internal Pick Line", '', 0, "Line No.", "Location Code");
                            //alok 100620 ++
                            IF ("Whse. Internal Pick Line"."Channel Code" <> '') AND (G_TrolleyNo = '') THEN
                                ERROR('Trolley no must not be blank');
                            //IF G_TrolleyNo <> '' THEN
                            //alok 100620 --
                            //       NewCreatePick.SetTrolleyNo(G_TrolleyNo);
                            // NewCreatePick.SetChannelCode("Whse. Internal Pick Line"."Channel Code");//Chandan+12/02/20

                            //Chandan++280520
                            // IF G_ZoneFilter <> '' THEN
                            //   NewCreatePick.CreateTempLineWithZone(
                            //  "Location Code", "Item No.", "Variant Code", "Unit of Measure Code",
                            //'', "To Bin Code", "Qty. per Unit of Measure", QtyToPick, QtyToPickBase, G_ZoneFilter);
                        END;
                    END ELSE
                        WhseWkshLineFound := TRUE;

                    CurrReport.Skip();
                end;


            end;

            trigger OnAfterAfterGetRecord()
            begin
                IF "G_TrolleyNo" <> '' THEN
                    UpdateTrolleyNo(G_TrolleyNo, "Whse. Internal Pick Line"."No.")
                ELSE
                    UpdateTrolleyNo("Whse. Internal Pick Line"."No.", "Whse. Internal Pick Line"."No.");


            end;
        }
    }
    requestpage
    {
        layout
        {
            addafter(PrintDoc)
            {
                field(G_location; G_location)
                {
                    ApplicationArea = All;
                    Caption = 'Location Code';
                    TableRelation = Location;
                }
                field(G_ZoneFilter; G_ZoneFilter)
                {
                    Caption = 'Zone Code';
                    ApplicationArea = All;
                    trigger OnLookup(var Text: Text): Boolean
                    var
                        PageZones: Page Zones;
                        Zone: Record Zone;
                    begin
                        CLEAR(G_ZoneFilter);
                        Zone.RESET;
                        if G_location <> '' then
                            Zone.SETRANGE("Location Code", G_location);
                        CLEAR(PageZones);
                        PageZones.SETRECORD(Zone);
                        PageZones.SETTABLEVIEW(Zone);
                        PageZones.LOOKUPMODE(TRUE);
                        IF PageZones.RUNMODAL = ACTION::LookupOK THEN BEGIN
                            PageZones.GETRECORD(Zone);
                            G_ZoneFilter := Zone.Code;
                        END;
                    end;
                }
                field("Trolley No."; G_TrolleyNo)
                {
                    ApplicationArea = All;
                    trigger OnValidate()
                    var
                        ProcessWebOrder: Codeunit "Process Web Order";
                    begin
                        ProcessWebOrder.TrolleyNoValidations(G_TrolleyNo, "Whse. Internal Pick Line"."No.");
                    end;
                }

            }

        }

    }


    var
        G_TrolleyNo: Code[20];
        G_ZoneFilter: Code[20];
        G_location: Code[20];
    /*    local procedure CalculatetrolleyforMultiline()
        var
        WIPL:Record "Whse. Internal Pick Line";

        begin
         WIPL.Reset();
         WIPL.SetRange("No.","Whse. Internal Pick Line"."No.");
         WIPL.SetRange("Line No.","Whse. Internal Pick Line"."Line No.");
         if WIPL.FindFirst() then begin
           WIPL."Trolley No." :=   GetTrolleyNo(WIPL);
           WIPL.Modify();
         end;
        end;

        procedure GetTrolleyNo(P_WIPL:record "Whse. Internal Pick Line"): Code[50]
        var
        WIPL:record "Whse. Internal Pick Line";
        WIPL2:record "Whse. Internal Pick Line";
        L_TrolleyNo:Code[10];
        begin
         WIPL.Reset();
         WIPL.SetRange("No.",P_WIPL."No.");
         WIPL.SetRange("Channel Order ID",P_WIPL."Channel Order ID");
         WIPL.SetFilter("Trolley No.",'<>%1','');
         if NOT WIPL.FindLast() then begin
           WIPL2.Reset();
           WIPL2.SetRange("No.",P_WIPL."No.");
           WIPL2.SetFilter("Trolley No.",'<>%1','');
           IF not WIPL2.FindLast() then
             L_TrolleyNo :=   '001'
           else
             L_TrolleyNo := IncStr(WIPL2."Trolley No.");

         end ELSE
           L_TrolleyNo := WIPL."Trolley No."; 

         exit(L_TrolleyNo);

        end;
    */

    local procedure UpdateTrolleyNo(P_TrolleyNo: Code[20]; P_PickNo: Code[20])
    var
        WIPH: Record "Whse. Internal Pick Header";
    begin
        WIPH.Reset();
        WIPH.SetRange("No.", P_PickNo);
        if WIPH.FindFirst() then begin
            if P_TrolleyNo <> '' then begin
                if WIPH."Trolley No." <> P_TrolleyNo then begin
                    WIPH.Validate("Trolley No.", P_TrolleyNo);
                    WIPH.Modify();
                end;
                //UpdateTrolleyNoForSingleLine(P_TrolleyNo);  
            end else begin
                //if WIPH."Order Line Type" = WIPH."Order Line Type"::"Single Line Orders"  then begin
                if WIPH."Trolley No." <> P_TrolleyNo then begin
                    WIPH.Validate("Trolley No.", P_PickNo);
                    WIPH.Modify();
                end;
                //UpdateTrolleyNoForSingleLine(P_PickNo);      
                // end else begin
                // CalculatetrolleyforMultiline(); 
                //end;
            end;
        end;
    end;

    /*   procedure UpdateTrolleyNoForSingleLine(P_TrolleyNo:Code[20])
       var
       WIPL:record "Whse. Internal Pick Line";
       begin
        WIPL.Reset();
        WIPL.SetRange("No.","Whse. Internal Pick Line"."No.");
        WIPL.SetRange("Line No.","Whse. Internal Pick Line"."Line No.");
        if WIPL.FindFirst() then begin
          WIPL."Trolley No." := P_TrolleyNo;
          WIPL.Modify();
        end;

       end;
   */
}