report 90090 "Send Email Template"
{
    DefaultLayout = Word;
    WordLayout = 'EmailTemplate.docx';
    EnableHyperlinks = true;
    dataset
    {
        dataitem("Handled Interim Sales Header"; "Handled Interim Sales Header")
        {
            column(StartriteLink; StartriteLink)
            {

            }
            column(HeaderText; HeaderText)
            {

            }
            column(HeaderText2; HeaderText2)
            {

            }
            column(HeaderText3; HeaderText3)
            {

            }
            column(HeaderText4; HeaderText4)
            {

            }
            column(HeaderText5; HeaderText5)
            {

            }
            column(HeaderText6; HeaderText6)
            {

            }
            column(HeaderText7; HeaderText7)
            {

            }
            column(HeaderText8; HeaderText8)
            {

            }
            column(HeaderText9; HeaderText9)
            {

            }
            column(HeaderText10; HeaderText10)
            {

            }
            column(HeaderText11; HeaderText11)
            {

            }
            column(HeaderText12; HeaderText12)
            {

            }
            column(HeaderText13; HeaderText13)
            {

            }
            column(HeaderText14; HeaderText14)
            {

            }
            column(HeaderText15; HeaderText15)
            {

            }
            column(Picture; G_CompanyInfo.Picture)
            {

            }

            dataitem("Handled Interim Sales Line"; "Handled Interim Sales Line")
            {
                DataItemLink = "Document Type" = field("Document Type"), "Document No" = field("No.");
                DataItemTableView = where(Type = filter(Item));
                column(Document_No; "Handled Interim Sales Line"."Channel Order ID")
                {

                }
                column(No_; "Handled Interim Sales Line".Description)
                {

                }
                column(Quantity; Quantity)
                {

                }
            }
            trigger OnPreDataItem()
            begin
                G_CompanyInfo.Get();
                G_CompanyInfo.CalcFields(Picture);
            end;

            trigger OnAfterGetRecord()

            begin

                Clear(StartriteLink);
                StartriteLink := 'https://www.startriteshoes.com/';

                Clear(HeaderText);
                HeaderText := 'Toes at the ready - we are on our way...';

                Clear(HeaderText2);
                HeaderText2 := 'Great news - some shiny new shoes are speeding to your door and payment has now been taken.';

                Clear(HeaderText3);
                HeaderText3 := 'Your parcel has been sent with ' + "Handled Interim Sales Header"."Shipping Agent Code" + '. If you had like to track their journey please use the details below:';

                Clear(HeaderText4);
                HeaderText4 := 'Click the link below to track your order';

                Clear(HeaderText5);
                HeaderText5 := 'https://www.royalmail.com/track-your-item?trackNumber=' + "Handled Interim Sales Header"."Package Tracking No.";

                Clear(HeaderText6);
                HeaderText6 := 'Please note that tracking may not display immediately.';

                Clear(HeaderText7);
                HeaderText7 := 'How to check the fit';

                Clear(HeaderText8);
                HeaderText8 := 'https://www.startriteshoes.com/check-the-fit';

                Clear(HeaderText9);
                HeaderText9 := 'As measuring is only a guide it is important to check the fit of your mini explorer is shoes once they arrive. You will find a handy check the fit leaflet enclosed in your parcel, ';

                Clear(HeaderText10);
                HeaderText10 := 'but if you want to get a head start you will find a quick and easy guide - together with a short video - on our website. Just click ' + HeaderText8;

                Clear(HeaderText11);
                HeaderText11 := 'Please do not reply to this email as this mailbox is not monitored. Should you need contact us our email address is ';

                Clear(HeaderText12);
                HeaderText12 := 'mailto:customer.services@startriteshoes.com';

                Clear(HeaderText13);
                HeaderText13 := 'Registered no. 00066027 Registered office: Peachman Way, Broadland Business Park, Norwich, NR7 0WF';

                Clear(HeaderText14);
                HeaderText14 := 'Disclaimer: This message may contain confidential and proprietary information and is intended only for the individual named. Any review or ';

                Clear(HeaderText15);
                HeaderText15 := 'distribution by others is strictly prohibited. If you are not the named addressee, please contact the sender and delete all copies.';
            end;

        }
    }
    var
        StartriteLink: Text[250];
        HeaderText: Text[250];
        HeaderText2: Text[250];
        HeaderText3: Text[250];
        HeaderText4: Text[250];
        HeaderText5: Text[250];
        HeaderText6: Text[250];
        HeaderText7: Text[250];
        HeaderText8: Text[250];
        HeaderText9: Text[250];
        HeaderText10: Text[250];
        HeaderText11: Text[250];
        HeaderText12: Text[250];
        HeaderText13: Text[250];
        HeaderText14: Text[250];
        HeaderText15: Text[250];
        G_CompanyInfo: Record "Company Information";
}