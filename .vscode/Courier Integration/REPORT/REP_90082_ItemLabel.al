report 90082 "Item label"
{
    DefaultLayout = RDLC;
    RDLCLayout = './ItemLabel.rdl';
    UsageCategory = ReportsAndAnalysis;
    ApplicationArea = All;
    dataset
    {
        dataitem("Warehouse Receipt Line"; "Warehouse Receipt Line")
        {
            RequestFilterFields = "No.";
            DataItemTableView = sorting("No.");

            dataitem(Item; Item)
            {
                //RequestFilterFields = "No.";
                DataItemLinkReference = "Warehouse Receipt Line";
                DataItemLink = "No." = field("Item No.");

                column(No_Item; Item."No.")
                {
                }
                column(Description_Item; Item.Description)
                {
                }
                column(logo; CompanyInformation.Picture)
                {
                }
                column(ItemBarcode; ItemBarcode)
                {
                }
                column(SalesUnitofMeasure_Item; Item."Sales Unit of Measure")
                {
                }
                column(recTmpBlob3_Blob; recTmpBlob3."Value BLOB")
                {
                }

                trigger OnPreDataItem()
                begin
                    CompanyInformation.GET;
                    CompanyInformation.CALCFIELDS(Picture);
                end;

                trigger OnAfterGetRecord()
                begin
                    CLEAR(ItemBarcode);
                    Clear(recTmpBlob3);
                    //     Clear(cduBarcodeMgt);
                    ItemCrossReference.RESET;
                    ItemCrossReference.SETRANGE("Item No.", Item."No.");
                    ItemCrossReference.SETRANGE("Reference Type", ItemCrossReference."Reference Type"::"Bar Code");
                    IF ItemCrossReference.FINDFIRST THEN begin
                        ItemBarcode := ItemCrossReference."Reference No.";
                        // cduBarcodeMgt.EncodeCode39(ItemBarcode, 1, false, false, recTmpBlob3);
                        //  cduBarcodeMgt.EncodeCode128(ItemBarcode, 1, false, recTmpBlob3);
                    end;

                end;
            }

        }

    }

    var
        CompanyInformation: Record 79;
        ItemCrossReference: Record "Item Reference";
        ItemBarcode: Code[20];
        //     cduBarcodeMgt: Codeunit "Barcode Mgt.";
        recTmpBlob3: Record "Name/Value Buffer" temporary;
}

