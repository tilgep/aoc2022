#pragma newdecls required
#pragma semicolon 1

#include <sourcemod>

StringMap rocks;
int highX, highY, lowX=999;

// I cheated and added another line to the input file to add the *infinite* floor
// so this technically only solves part 1
public void OnPluginStart()
{
    char buffer[512];
    BuildPath(Path_SM, buffer, sizeof(buffer), "configs/advent/day14_input.txt");
    File f = OpenFile(buffer, "r");
    if(f==null) SetFailState("Failed to open file");

    rocks = new StringMap();
    int line;
    char num[8];
    char sx[8],sy[8];
    int x,y, px,py;

    while(f.ReadLine(buffer, sizeof(buffer)))
    {
        line++;
        if(buffer[0]=='\0') continue;
        strcopy(buffer, strlen(buffer)-1, buffer); // remove newline char

        x=-1;y=-1;
        int len = strlen(buffer);

        for(int i = 0; i < len; i++)
        {
            if(IsCharNumeric(buffer[i]))
            {
                Format(num,8,"%s%c",num,buffer[i]);
                continue;
            }

            if(buffer[i] == ',') // save x val
            {
                px=x;
                strcopy(sx,8,num);
                x = StringToInt(sx);
                if(x > highX) highX = x;
                if(x < lowX) lowX = x;
                num[0]='\0';
                continue;
            }
            
            if(buffer[i] == '-') // add the rock line
            {
                py=y;
                strcopy(sy,8,num);
                y = StringToInt(sy);
                if(y > highY) 
                {
                    //PrintToConsoleAll("line%d char%d highY: %d",line, i, y);
                    highY = y;
                }
                num[0]='\0';

                SetRocks(x,y,px,py);
            }
        }

        py=y;
        strcopy(sy,8,num);
        y = StringToInt(sy);
        if(y > highY) 
        {
            //PrintToConsoleAll("line%d end sy:%s highY: %d",line, sy, y);
            highY = y;
        }
        num[0]='\0';

        SetRocks(x,y,px,py);
        
    }
    delete f;

    ShowRocks(true);

    StartSand();
}

void StartSand()
{
    int tot;
    while(CheckPos(500,0) != 1)
    {
        TickSand();
        tot++;
    }
    
    PrintToConsoleAll("%d grains", tot);
}

int TickSand()
{
    int x = 500, y = 0;
    if(CheckPos(x,y)==1) return -1;
    
    bool moving = true;
    while(moving)
    {
        //Check below
        int state = CheckPos(x,y+1);
        if(state == -1)
        {
            // below is in the void
            ShowRocks(true);
            return 0;
        }
        else if(state == 0)
        {
            // below is empty, move on
            y++;
        }
        else
        {
            // below is filled, check down left
            state = CheckPos(x-1,y+1);
            if(state == -1)
            {
                // down left is in the void
                ShowRocks(true);
                return 0;
            }
            else if(state == 0)
            {
                // down left is empty, move on
                x--;
                y++;
            }
            else
            {
                // down left is filled, check down right
                state = CheckPos(x+1,y+1);
                if(state == -1)
                {
                    // down right is in the void
                    ShowRocks(true);
                    return false;
                }
                else if(state == 0)
                {
                    // down right is empty, move on
                    x++;
                    y++;
                }
                else
                {
                    // down right is filled, sand has settled
                    moving = false;
                    char pos[16];
                    Format(pos,sizeof(pos),"%d,%d",x,y);
                    rocks.SetValue(pos,2);
                }
            }
        }
    }
    
    return true;
}

/**
 * Checks if a given x,y coord is valid for sand
 * 
 * @param x      x position to check
 * @param y      y postition to check
 * 
 * @return      -1 = out of bounds.
 *               0 = pos empty.
 *               1 = pos filled.
 */
int CheckPos(int x, int y)
{
    if((x < lowX || x > highX || y > highY) )return -1;
    char pos[16];
    Format(pos,sizeof(pos), "%d,%d",x,y);
    int b;
    if(rocks.GetValue(pos,b)&&b>0)
    {
        return 1;
    }
    else return 0;
}

void ShowRocks(bool draw)
{
    LogMessage("lowX:%d  highX:%d  highY:%d", lowX,highX,highY);
    PrintToConsoleAll("lowX:%d  highX:%d  highY:%d", lowX,highX,highY);
    
    if(!draw) return;

    char row[2048];
    char pos[16];
    for(int y = 0; y <= highY; y++)
    {
        if(y==0)
        {
            char r[5];
            for(int i = 0; i < 3; i++)
            {
                Format(row,sizeof(row),"     ");
                for(int x = lowX; x <= highX; x++)
                {
                    IntToString(x,r,5);
                    Format(row,sizeof(row),"%s%c",row,r[i]);
                }
                PrintToConsoleAll(row);
            }
            PrintToConsoleAll("");
        }

        Format(row,sizeof(row),"%4d ",y);
        for(int x = lowX; x <= highX; x++)
        {
            Format(pos,16,"%d,%d",x,y);
            int b;
            if(y==0&&x==500)
            {
                StrCat(row,sizeof(row),"+");
                continue;
            }

            if(rocks.GetValue(pos,b))
            {
                if(b==1) StrCat(row,sizeof(row),"#");
                else if(b==2) StrCat(row,sizeof(row),"o");
            }
            else
            {
                StrCat(row,sizeof(row),".");
            }
        }
        PrintToConsoleAll(row);
        row[0]='\0';

        if(y==highY)
        {
            PrintToConsoleAll(row);
            char r[5];
            for(int i = 0; i < 3; i++)
            {
                Format(row,sizeof(row),"     ");
                for(int x = lowX; x <= highX; x++)
                {
                    IntToString(x,r,5);
                    Format(row,sizeof(row),"%s%c",row,r[i]);
                }
                PrintToConsoleAll(row);
            }
        }
    }

    PrintToConsoleAll("lowX:%d  highX:%d  highY:%d", lowX,highX,highY);
}

void SetRocks(int x, int y, int px, int py)
{
    if(px == -1 && py == -1) return; // first number
    
    
    char pos[16];
    if(x != px) // horizontal line
    {
        //PrintToConsoleAll("Horizontal rocks (%d,%d) -> (%d,%d)", px,py,x,y);
        int dx = x - px;
        int start = dx < 0 ? x : px;
        int end = dx < 0 ? px : x;

        for(int i = start; i <= end; i++)
        {
            Format(pos,16,"%d,%d",i,y);
            rocks.SetValue(pos,1);
        }
        return;
    }

    //PrintToConsoleAll("Vertical rocks (%d,%d) -> (%d,%d)", px,py,x,y);
    int dy = y - py;
    int start = dy < 0 ? y : py, end = dy < 0 ? py : y;

    for(int i = start; i <= end; i++)
    {
        Format(pos,16,"%d,%d",x,i);
        rocks.SetValue(pos,1);
    }
}