page 90028 "Ochannel RoleCenter Headlines"
{
    PageType = HeadlinePart;

    layout
    {
        area(Content)
        {
           field(Headline1; GetHeadlineText(1))
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
    local procedure GetHeadlineText(HeadlineNo : Integer) : Text
    begin
     case HeadlineNo of  
       1:
        exit(StrSubstNo(HeadLine1,100)); 

     end;
    end;
    var
        HeadLine1: Label '<qualifier>Todays Statistics</qualifier><payload>Total sales <emphasize>%1</emphasize>.</payload>';
        HeadLine2: Label 'Headline 2'; 
        HeadLine3: Label 'Headline 3';
        HeadLine4: Label 'Headline 4';
        pageCDS: page "Assisted Company Setup Wizard";
        CUAssited : Codeunit "Guided Experience";
        
}