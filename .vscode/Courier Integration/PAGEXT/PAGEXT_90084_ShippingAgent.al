pageextension 90084 "Shipping Agent Ext" extends "Shipping Agents"
{
    layout
    {
        addafter("Internet Address")
        {
            field("API URL"; Rec."API URL")
            {
                ApplicationArea = All;
            }
            field("Access Key"; Rec."Access Key")
            {
                ApplicationArea = All;
            }
            field("Secret Key"; Rec."Secret Key")
            {
                ApplicationArea = All;
            }
            field("Business Account No"; Rec."Business Account No")
            {
                ApplicationArea = All;
            }
            field("Access Token"; Rec."Access Token")
            {
                ApplicationArea = All;
            }
            field("Refresh Token"; Rec."Refresh Token")
            {
                ApplicationArea = All;
            }
            field("Client Id"; Rec."Client Id")
            {
                ApplicationArea = All;
            }
            field("Client Secret"; Rec."Client Secret")
            {
                ApplicationArea = All;
            }
            field("Procesing Codeunit"; Rec."Procesing Codeunit")
            {
                ApplicationArea = All;
            }
            field(New_AuthDate; Rec.New_AuthDate)
            {
                Caption = 'AuthDate';
                ApplicationArea = All;
            }
            field("Shipping G/L No."; Rec."Shipping G/L No.")
            {
                ApplicationArea = All;
            }

        }
    }
}