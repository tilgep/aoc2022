#pragma newdecls required
#pragma semicolon 1

#include <sourcemod>

public void OnPluginStart()
{
    char buffer[PLATFORM_MAX_PATH];
    BuildPath(Path_SM, buffer, PLATFORM_MAX_PATH, "configs/advent/day1_input.txt");
    File f = OpenFile(buffer, "r");
    if(f==null) SetFailState("Failed to open file");

    int second, third;
    int first;
    int elf_total;
    while(f.ReadLine(buffer, PLATFORM_MAX_PATH))
    {
        TrimString(buffer);
        if(buffer[0]=='\0') 
        {
            if(elf_total > first)
            {
                third = second;
                second = first;
                first = elf_total;
            }
            else if(elf_total > second)
            {
                third = second;
                second = elf_total;
            }
            else if(elf_total > third)
            {
                third = elf_total;
            }
            elf_total = 0;
            continue;
        }

        int v = StringToInt(buffer);
        elf_total += v;
    }
    delete f;
    LogMessage("Highest: %d", first);
    LogMessage("Second:  %d", second);
    LogMessage("Third:   %d", third);
    LogMessage("Total:   %d", first+second+third);
}