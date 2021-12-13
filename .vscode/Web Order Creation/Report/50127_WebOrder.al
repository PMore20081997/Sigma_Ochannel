report 90069 "Web Order"
{
    Caption = 'Web Order';
    DefaultLayout = Word;
    WordLayout = 'WebOrder.docx';
    RDLCLayout = 'WebOrder.rdlc';
    UsageCategory = Lists;
    ApplicationArea = All;

    dataset
    {
        dataitem("Interim Sales Header"; "Interim Sales Header")
        {
            DataItemTableView = sorting("No.");
            //RequestFilterFields = "Line Action";
            PrintOnlyIfDetail = True;
            column(Trade_Partner_Code; "Trade Partner Code")
            {

                IncludeCaption = true;
            }

            column(Order_Date; "Order Date")
            {
                IncludeCaption = true;
            }
            column(Tracking_No_; "Tracking No.")
            {
                IncludeCaption = true;
            }
            dataitem("Interim Sales Line"; "Interim Sales Line")
            {
                DataItemTableView = sorting("Line No.");


            }
        }
    }

    requestpage
    {
        SaveValues = true;//in order to save the values that the end-user enters on the request page
        layout
        {
            area(Content)
            {
                group(General)
                {
                    Caption = 'General';
                    field(LineAction; LineAction)
                    {
                        //OptionMembers = "No Action",Accept,Reject,Cancelled;
                        ApplicationArea = Basic, Suit;
                        Caption = 'Line Action';

                    }

                }
            }
        }

        actions
        {
            area(processing)
            {
                action(ActionName)
                {
                    ApplicationArea = All;

                }
            }
        }
        trigger OnOpenPage()
        begin

        end;
    }
    var
        myInt: Integer;
        LineAction: Option;
    // OptionMember="No Action",Accept,Reject,Cancelled;

}