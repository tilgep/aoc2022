#pragma newdecls required
#pragma semicolon 1

#include <sourcemod>



public void OnPluginStart()
{
    char buffer[PLATFORM_MAX_PATH];
    BuildPath(Path_SM, buffer, PLATFORM_MAX_PATH, "configs/advent/day6_input.txt");
    File f = OpenFile(buffer, "r");
    if(f==null) SetFailState("Failed to open file");

    bool first = true;
    int startIndex;
    char temp[15];
    bool duplicate;

    while(f.ReadString(temp, 15, 14) == 14)
    {
        temp[14] = '\0';
        startIndex++;
        if(!f.Seek(startIndex, SEEK_SET))
        {
            PrintToConsoleAll("Seek failed to pos %d", startIndex);
            break;
        }
        duplicate = false;
        if(first) PrintToConsoleAll("now checking '%s' after %d characters read.", temp, startIndex+18);

        char one;
        char two;

        for(int i = 0; i < 13; i++)
        {
            if(duplicate) break;
            one = temp[i];
            for(int j = i+1; j < 14; j++)
            {
                two = temp[j];
                if(one==two)
                {
                    duplicate = true;
                    break;
                }
            }
        }
        
        if(duplicate) continue;
        
        break;
    }
    
    if(!duplicate)
    {
        PrintToConsoleAll("Found 14 unique chars '%s' after %d characters read.", temp, startIndex+4);
        LogMessage("Found 14 unique chars '%s' after %d characters read.", temp, startIndex+4);
    }
    else PrintToConsoleAll("No unique 14 char substrings found?!");
    
}