#pragma newdecls required
#pragma semicolon 1

#include <sourcemod>



public void OnPluginStart()
{
    char buffer[PLATFORM_MAX_PATH];
    BuildPath(Path_SM, buffer, PLATFORM_MAX_PATH, "configs/advent/day4_input.txt");
    File f = OpenFile(buffer, "r");
    if(f==null) SetFailState("Failed to open file");

    int line;
    int total;

    char areas[2][32];
    char numbers[2][32];
    char numbers2[2][32];
    int startL, endL, startR, endR;

    while(f.ReadLine(buffer, sizeof(buffer)))
    {
        line++;
        if(buffer[0]=='\0') continue;

        int com = FindCharInString(buffer, ',');
        if(com == -1)
        {
            PrintToConsoleAll("No comma found on line %d", line);
            continue;
        }

        strcopy(areas[0], com+1, buffer);
        strcopy(areas[1], (strlen(buffer)-1)-com, buffer[com+1]);

        if(line==2) PrintToConsoleAll("AREAS[0]: '%s' AREAS[1]: '%s'", areas[0], areas[1]);
        
        int dash = FindCharInString(areas[0], '-');
        if(dash == -1)
        {
            PrintToConsoleAll("No dash found in areas[0] on line %d", line);
            continue;
        }

        strcopy(numbers[0], dash+1, areas[0]);

        int len = strlen(areas[0]);

        if(line==2) PrintToConsoleAll("dash=%d  strlen(areas)=%d", dash, len);
        strcopy(numbers[1], (len-dash), areas[0][dash+1]);

        dash = FindCharInString(areas[1], '-');
        if(dash == -1)
        {
            PrintToConsoleAll("No dash found in areas[1] on line %d", line);
            continue;
        }
        strcopy(numbers2[0], dash+1, areas[1]);
        strcopy(numbers2[1], strlen(areas[1])-dash, areas[1][dash+1]);

        if(line==2) 
        {
            PrintToConsoleAll("numbers[0]: '%s' numbers[1]: '%s'", numbers[0], numbers[1]);
            PrintToConsoleAll("numbers2[0]: '%s' numbers2[1]: '%s'", numbers2[0], numbers2[1]);
        }

        startL = StringToInt(numbers[0]);
        endL = StringToInt(numbers[1]);

        startR = StringToInt(numbers2[0]);
        endR = StringToInt(numbers2[1]);

        if(startL >= startR && startL <= endR)
        {
            total++;
            continue;
        }
        if(startR >= startL && startR <= endL)
        {
            total++;
            continue;
        }
        
        if(endL >= startR && endL <= endR)
        {
            total++;
            continue;
        }
        if(endR >= startL && endR <= endL)
        {
            total++;
            continue;
        }
    }

    PrintToConsoleAll("Advent4 :: Total is: %d", total);
    LogMessage("Total is: %d", total);

    delete f;
}