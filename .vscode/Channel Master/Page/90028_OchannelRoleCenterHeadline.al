page 90028 "Ochannel RoleCenter Headlines"
{
    PageType = HeadlinePart;

    layout
    {
        area(Content)
        {
           field(Headline1; HeadLine1)
           {
            ApplicationArea = All;
           }
           field(Headline2; HeadLine2)
           {
            ApplicationArea = All;
           }
           field(Headline3; HeadLine3)
           {
            ApplicationArea = All;
           }
           field(Headline4; HeadLine4)
           {
            ApplicationArea = All;
           }
        }
    }
    
    actions
    {
        area(Processing)
        {
            action(ActionName)
            {
                ApplicationArea = All;
                
                trigger OnAction()
                begin
                    
                end;
            }
        }
    }
    
    var
        HeadLine1: Label 'Headline 1';
        HeadLine2: Label 'Headline 2'; 
        HeadLine3: Label 'Headline 3';
        HeadLine4: Label 'Headline 4';
}