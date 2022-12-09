#pragma newdecls required
#pragma semicolon 1

#include <sourcemod>



public void OnPluginStart()
{
    char buffer[PLATFORM_MAX_PATH];
    BuildPath(Path_SM, buffer, PLATFORM_MAX_PATH, "configs/advent/day3_input.txt");
    File f = OpenFile(buffer, "r");
    if(f==null) SetFailState("Failed to open file");

    int line;
    int total;

    char first[255];
    char second[255];
    char third[255];

    while(f.ReadLine(buffer, sizeof(buffer)))
    {
        line++;
        if(buffer[0]=='\0') continue;
    
        if(first[0]=='\0') 
        {
            strcopy(first, 255, buffer);
            continue;
        }
        else if(second[0]=='\0')
        {
            strcopy(second, 255, buffer);
            continue;
        }
        else strcopy(third, 255, buffer);

        char same;
        bool found = false;
        int len1 = strlen(first), len2 = strlen(second), len3 = strlen(buffer);
        
        for(int i = 0; i < len1; i++)
        {
            if(found) break;
            for(int j = 0; j < len2; j++)
            {
                if(found) break;
                if(first[i]!=second[j]) continue;

                // Only loop third string if first 2 are the same
                for(int k = 0; k < len3; k++)
                {
                    if(first[i]==third[k])
                    {
                        same = first[i];
                        found = true;
                        break;
                    }
                }
            }
        }
        first[0] = '\0';
        second[0] = '\0';
        third[0] = '\0';
        total += GetPriority(same);
        if(line<5) LogMessage("Found same character: '%c' ... Total now: %d", same, total);
    }

    LogMessage("Total priority score: %d", total);

    delete f;
}

int GetPriority(char c)
{
    int score;
    char clower = CharToLower(c);
    switch(clower)
    {
        case 'a': score = 1;
        case 'b': score = 2;
        case 'c': score = 3;
        case 'd': score = 4;
        case 'e': score = 5;

        case 'f': score = 6;
        case 'g': score = 7;
        case 'h': score = 8;
        case 'i': score = 9;
        case 'j': score = 10;

        case 'k': score = 11;
        case 'l': score = 12;
        case 'm': score = 13;
        case 'n': score = 14;
        case 'o': score = 15;

        case 'p': score = 16;
        case 'q': score = 17;
        case 'r': score = 18;
        case 's': score = 19;
        case 't': score = 20;

        case 'u': score = 21;
        case 'v': score = 22;
        case 'w': score = 23;
        case 'x': score = 24;
        case 'y': score = 25;

        case 'z': score = 26;
    }
    if(IsCharUpper(c)) score += 26;
    return score;
}