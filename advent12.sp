#pragma newdecls required
#pragma semicolon 1
#pragma dynamic 131072

#include <sourcemod>

enum direction
{
    dir_up,
    dir_down,
    dir_left,
    dir_right,
}

enum struct Tile
{
    int x;
    int y;
    char height;
    int up;
    int down;
    int left;
    int right;

    float f;
    int g;
    float h;

    int prevX;
    int prevY;
    int prevInd;

    void SetPrevious(int x, int y, int index)
    {
        this.prevX = x;
        this.prevY = y;
        this.prevInd = index;
    }

    bool CanMove(direction d)
    {
        if(IsPrevious(this.x,this.y,d)) return false;

        switch(d)
        {
            case dir_up: 
            {
                if(this.up<=1) 
                {
                    return true;
                }
                return false;
            }
            case dir_down:
            {
                if(this.down<=1) 
                {
                    return true;
                }
                return false;
            }
            case dir_left:
            {
                if(this.left<=1) 
                {
                    return true;
                }
                return false;
            }
            default:
            {
                if(this.right<=1) 
                {
                    return true;
                }
                return false;
            }
        }
    }

    void Print()
    {
        PrintToConsoleAll("TILE:: X:%4d Y:%4d H:%c U:%4d D:%4d L:%4d R:%4d",this.x,this.y,this.height,this.up,this.down,this.left,this.right);
    }
}

Tile tiles[162][41];
int startX;
int startY;
int endX;
int endY;

ArrayList open;
StringMap closed;
ArrayList closeda;

public void OnPluginStart()
{
    char buffer[PLATFORM_MAX_PATH];
    BuildPath(Path_SM, buffer, PLATFORM_MAX_PATH, "configs/advent/day12_input.txt");
    File f = OpenFile(buffer, "r");
    if(f==null) SetFailState("Failed to open file");

    int line;
    int y;

    while(f.ReadLine(buffer, sizeof(buffer)))
    {
        line++;
        if(buffer[0]=='\0') continue;
        strcopy(buffer, strlen(buffer)-1, buffer); // remove newline char
        if(buffer[0]=='\0') continue;

        int len = strlen(buffer);
        for(int x = 0; x < len; x++)
        {
            tiles[x][y].x = x;
            tiles[x][y].y = y;
            tiles[x][y].height = buffer[x];
            if(buffer[x]=='S')
            {
                PrintToConsoleAll("Found start at x%d y%d",x,y);
                startX = x;
                startY = y;
                tiles[x][y].SetPrevious(-1,-1, -1);
            }
            else if(buffer[x] == 'E')
            {
                PrintToConsoleAll("Found end at x%d y%d",x,y);
                endX = x;
                endY = y;
            }
        }
        y++;
    }
    delete f;

    open = new ArrayList(512);
    closeda = new ArrayList(512);
    
    closed = new StringMap();

    SetMovements();

    open.PushArray(tiles[startX][startY]);

    FindPath();
    ShowPath();

    
    delete closeda;
}

ArrayList path;
void ShowPath()
{
    path = new ArrayList(512);
    int ind = closeda.Length-1;
    int steps;
    do
    {
        Tile t;
        closeda.GetArray(ind,t,sizeof(t));
        path.PushArray(t);
        PrintToConsoleAll("Step%d: H:%c X:%d Y:%d",steps, t.height, t.x,t.y);
        steps++;
        if(t.x==startX&&t.y==startY) break;
        ind = t.prevInd;
    }
    while(ind!=-1);

    VisualisePath();
}

void VisualisePath()
{
    StringMap coords = new StringMap();
    char key[16];

    for(int i = 0; i < path.Length; i++)
    {
        Tile t;
        path.GetArray(i,t,sizeof(t));
        Format(key,16,"%dx%dy",t.x,t.y);
        coords.SetValue(key,i);
    }
    char line[256];
    for(int y = 0; y < sizeof(tiles[]); y++)
    {
        for(int x = 0; x < sizeof(tiles); x++)
        {
            Format(key,16,"%dx%dy",x,y);
            int v;
            if(coords.GetValue(key,v)&&v>-1)
            {
                if(v==0)StrCat(line,256,"E");
                else if(v==path.Length-1) StrCat(line,256,"S");
                else
                {
                    Tile t,a;
                    path.GetArray(v,t,sizeof(t));
                    path.GetArray(v-1,a,sizeof(a));
                    if(a.x<t.x) StrCat(line,256,"<");
                    else if(a.x>t.x) StrCat(line,256,">");
                    else if(a.y<t.y) StrCat(line,256,"^");
                    else if(a.y>t.y) StrCat(line,256,"v");
                }
            }
            else
            {
                StrCat(line,256,".");
            }
        }
        PrintToConsoleAll(line);
        line[0]='\0';
    }

    delete coords;
    delete path;
}

void FindPath()
{
    char key[16];

    ArrayList children = new ArrayList(512);

    while(open.Length > 0)
    {
        children.Clear();

        Tile t;
        open.GetArray(0,t,sizeof(t));
        //t.Print();
        int closeIndex = closeda.PushArray(t);
        
        Format(key,16,"%dx%dy",t.x,t.y);
        int v;
        if(closed.GetValue(key,v)&&v==1) 
        {
            closeda.PushArray(t);
            open.Erase(0);
            continue;
        }
        closed.SetValue(key,1);
        if(t.x==endX && t.y==endY)
        {
            closeda.PushArray(t);
            PrintToConsoleAll("END FOUND!!!!!!!!!!!!!! prevx:%d prevy:%d",t.prevX,t.prevY);
            break;
        }

        // Get children
        if(t.CanMove(dir_up)) children.PushArray(tiles[t.x][t.y-1]);
        if(t.CanMove(dir_down)) children.PushArray(tiles[t.x][t.y+1]);
        if(t.CanMove(dir_left)) children.PushArray(tiles[t.x-1][t.y]);
        if(t.CanMove(dir_right)) children.PushArray(tiles[t.x+1][t.y]);

        for(int i = 0; i < children.Length; i++)
        {
            Tile c;
            children.GetArray(i,c,sizeof(c));

            c.g = t.g + 1;
            bool alreadyThere;
            for(int j = 1; j < open.Length; j++) //0 is current so start from 1
            {
                Tile d;
                open.GetArray(i,d,sizeof(d));
                if(d.x==c.x&&d.y==c.y)
                {
                    if(d.g <= c.g) alreadyThere = true;
                    else open.Erase(j);
                    break;
                }
            }
            if(alreadyThere) continue;
            c.h = SquareRoot(Pow(float(abs(endX-c.x)),2.0) + Pow(float(abs(endY-c.y)),2.0));
            c.f = float(c.g) + c.h;
            c.SetPrevious(t.x,t.y,closeIndex);
            tiles[c.x][c.y].SetPrevious(t.x,t.y,closeIndex);
            open.PushArray(c);
        }
        
        open.Erase(0);
        SortADTArrayCustom(open,SortChildren);
    }

    delete open;
    delete closed;
    delete children;
}

int SortChildren(int index1, int index2, Handle array, Handle hndl)
{
    Tile t1,t2;
    view_as<ArrayList>(array).GetArray(index1, t1,sizeof(t1));
    view_as<ArrayList>(array).GetArray(index2, t2,sizeof(t2));

    if(t1.f < t2.f) return -1;
    else if(t2.f > t1.f) return 1;

    return 0;
}

int abs(int x)
{
    if(x<0) return -x;
    return x;
}

void SetMovements()
{
    for(int x = 0; x < sizeof(tiles); x++)
    {
        for(int y = 0; y < sizeof(tiles[]); y++)
        {
            tiles[x][y].up = 0;
            tiles[x][y].down = 0;
            tiles[x][y].left = 0;
            tiles[x][y].right = 0;

            //harcode cuz lazy
            if(x==startX&&y==startY)
            {
                tiles[x][y].up = 0;
                tiles[x][y].down = 0;
                tiles[x][y].left = 999;
                tiles[x][y].right = 1;
                tiles[x][y].Print();
                continue;
            }
            if(x==endX&&y==endY)
            {
                tiles[x][y].up = -3;
                tiles[x][y].down = -3;
                tiles[x][y].left = -3;
                tiles[x][y].right = -1;
                continue;
            }
            
            //up
            if(y==0) 
                tiles[x][y].up = 999;
            else if(x==startX && y-1==startY) 
                tiles[x][y].up = 'a'-tiles[x][y].height;
            else if(x==endX && y-1==endY) 
                tiles[x][y].up = ('z'+1)-tiles[x][y].height;
            else 
                tiles[x][y].up = tiles[x][y-1].height - tiles[x][y].height;
            
            //down
            if(y==sizeof(tiles[])-1) 
                tiles[x][y].down = 999;
            else if(x==startX && y+1==startY) 
                tiles[x][y].down = 'a'-tiles[x][y].height;
            else if(x==endX && y+1==endY) 
                tiles[x][y].down = ('z'+1)-tiles[x][y].height;
            else 
                tiles[x][y].down = tiles[x][y+1].height - tiles[x][y].height;

            //left
            if(x==0) 
                tiles[x][y].left = 999;
            else if(x-1==startX && y==startY) 
                tiles[x][y].left = 'a'-tiles[x][y].height;
            else if(x-1==endX && y==endY) 
                tiles[x][y].left = ('z'+1)-tiles[x][y].height;
            else 
                tiles[x][y].left = tiles[x-1][y].height - tiles[x][y].height;
            
            //right
            if(x==sizeof(tiles)-1) 
                tiles[x][y].right = 999;
            else if(x+1==endX && y==endY) 
                tiles[x][y].right = ('z'+1)-tiles[x][y].height;
            else tiles[x][y].right = tiles[x+1][y].height - tiles[x][y].height;

            //tiles[x][y].Print();
        }
    }
}

bool IsPrevious(int thisX,int thisY,direction dir)
{
    switch(dir)
    {
        case dir_up:
        {
            if(tiles[thisX][thisY].prevX == thisX)
            {
                if(tiles[thisX][thisY].prevY == thisY-1)
                {
                    return true;
                }
            }
        }
        case dir_down:
        {
            if(tiles[thisX][thisY].prevX == thisX)
            {
                if(tiles[thisX][thisY].prevY == thisY+1)
                {
                    return true;
                }
            }
        }
        case dir_left:
        {
            if(tiles[thisX][thisY].prevX == thisX-1)
            {
                if(tiles[thisX][thisY].prevY == thisY)
                {
                    return true;
                }
            }
        }
        default: //right
        {
            if(tiles[thisX][thisY].prevX == thisX+1)
            {
                if(tiles[thisX][thisY].prevY == thisY)
                {
                    return true;
                }
            }
        }
    }
    return false;
}