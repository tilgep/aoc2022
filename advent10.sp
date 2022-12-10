#pragma newdecls required
#pragma semicolon 1
#pragma dynamic 131072

#include <sourcemod>

int total;
char output[64];

public void OnPluginStart()
{
    char buffer[PLATFORM_MAX_PATH];
    BuildPath(Path_SM, buffer, PLATFORM_MAX_PATH, "configs/advent/day10_input.txt");
    File f = OpenFile(buffer, "r");
    if(f==null) SetFailState("Failed to open file");

    int line;
    int x = 1;
    int cycle = 1;

    while(f.ReadLine(buffer, sizeof(buffer)))
    {
        line++;
        if(buffer[0]=='\0') continue;
        strcopy(buffer, strlen(buffer)-1, buffer); // remove newline char

        if(buffer[0]=='n')
        {
            checkcycle(cycle,x);
            cycle++;
        }
        else // addx
        {
            checkcycle(cycle,x);
            cycle++;
            checkcycle(cycle,x);
            cycle++;
            x+=StringToInt(buffer[5]);
        }
    }
    PrintToConsoleAll(output);

    //Part 1
    PrintToConsoleAll("Total: %d", total);
    LogMessage("Total: %d", total);
}

void checkcycle(int cycle, int x)
{
    if(cycle%40==1 && cycle!=1)
    {
        PrintToConsoleAll(output);
        output[0] = '\0';
    }

    int xpos = cycle-1;
    xpos = xpos%40;
    
    if(xpos >= x-1)
    {
        if(xpos <= x+1)
        {
            StrCat(output,64,"#");
        }
        else StrCat(output,64,".");
    }
    else StrCat(output,64,".");

    //PART 1
    //20th, 60th, 100th, 140th, 180th, and 220th
    if(cycle==20||cycle==60||cycle==100||cycle==140||cycle==180||cycle==220)
    {
        total+=(cycle*x);
    }
}