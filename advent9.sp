#pragma newdecls required
#pragma semicolon 1
#pragma dynamic 131072

#include <sourcemod>

enum direction
{
    Up = 0,
    Down = 1,
    Right = 2,
    Left = 3,
}

enum struct pos
{
    int x;
    int y;
    void Init(int x, int y)
    {
        this.x = x;
        this.y = y;
    }
    void Print()
    {
        PrintToConsoleAll("pos[x:%d y:%d]",this.x,this.y);
    }
}


pos knots[10];
ArrayList positions[sizeof(knots)];

public void OnPluginStart()
{
    char buffer[PLATFORM_MAX_PATH];
    BuildPath(Path_SM, buffer, PLATFORM_MAX_PATH, "configs/advent/day9_input.txt");
    File f = OpenFile(buffer, "r");
    if(f==null) SetFailState("Failed to open file");

    int line;
    
    for(int i=0;i<sizeof(knots);i++)
    {
        positions[i] = new ArrayList(sizeof(knots[]));
        knots[i].Init(0,0);
    }

    while(f.ReadLine(buffer, sizeof(buffer)))
    {
        line++;
        if(buffer[0]=='\0') continue;
        strcopy(buffer, strlen(buffer)-1, buffer); // remove newline char

        direction dir;
        if(buffer[0]=='U') dir = Up;
        else if(buffer[0]=='D') dir = Down;
        else if(buffer[0]=='R') dir = Right;
        else dir = Left;

        int amount = StringToInt(buffer[2]);

        for(int i = 1; i <= amount; i++)
        {
            switch(dir)
            {
                case Up:knots[0].y--;
                case Down:knots[0].y++;
                case Left:knots[0].x--;
                case Right:knots[0].x++;
            }
            
            for(int j = 1; j < sizeof(knots); j++)
            {
                MoveTail(j);
                positions[j].PushArray(knots[j]);
            }
        }
    }

    for(int i = 1; i < sizeof(knots); i++)
    {
        int visted = GetNumVisited(i);
        PrintToConsoleAll("Total visited [%d]: %d",i,visted);
        LogMessage("Total visited: %d",visted);
    }
}

void MoveTail(int tail)
{
    int dx = knots[tail-1].x - knots[tail].x;
    int dy = knots[tail-1].y - knots[tail].y;

    switch(dx)
    {
        case -2:
        {
            knots[tail].x--;
            if(dy>0)knots[tail].y++;
            else if(dy<0)knots[tail].y--;
            return;
        }
        case 2:
        {
            knots[tail].x++;
            if(dy>0)knots[tail].y++;
            else if(dy<0)knots[tail].y--;
            return;
        }
    }
    switch(dy)
    {
        case -2:
        {
            knots[tail].y--;
            if(dx>0)knots[tail].x++;
            else if(dx<0)knots[tail].x--;
            return;
        }
        case 2:
        {
            knots[tail].y++;
            if(dx>0)knots[tail].x++;
            else if(dx<0)knots[tail].x--;
            return;
        }
    }
}

int GetNumVisited(int index)
{
    int total;
    StringMap counted = CreateTrie();
    char key[32];int v;
    for(int i = 0; i < positions[index].Length; i++)
    {
        pos p;
        positions[index].GetArray(i, p);//p.Print();
        Format(key,32,"x%dy%d",p.x,p.y);
        if(counted.Size>0&&counted.GetValue(key,v)&&v!=0)
        {
            // already counted
        }
        else
        {
            // first time seeing this coord
            counted.SetValue(key,1);
            total++;
        }
        v=0;
    }

    delete counted;
    return total;
}

stock int Abs(int val)
{
    return (val < 0) ? -val : val;
}  