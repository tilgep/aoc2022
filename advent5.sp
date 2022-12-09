#pragma newdecls required
#pragma semicolon 1

#include <sourcemod>

#define NUMTOMOVESTART 5

ArrayStack stacks[11];

/*
[B]                     [N]     [H]
[V]         [P] [T]     [V]     [P]
[W]     [C] [T] [S]     [H]     [N]
[T]     [J] [Z] [M] [N] [F]     [L]
[Q]     [W] [N] [J] [T] [Q] [R] [B]
[N] [B] [Q] [R] [V] [F] [D] [F] [M]
[H] [W] [S] [J] [P] [W] [L] [P] [S]
[D] [D] [T] [F] [G] [B] [B] [H] [Z]
 1   2   3   4   5   6   7   8   9 
*/

public void OnPluginStart()
{
    char buffer[PLATFORM_MAX_PATH];
    BuildPath(Path_SM, buffer, PLATFORM_MAX_PATH, "configs/advent/day5_input.txt");
    File f = OpenFile(buffer, "r");
    if(f==null) SetFailState("Failed to open file");

    // Initialise stacks
    for(int i = 0; i < 11; i++) stacks[i] = new ArrayStack();

    LoadStacks();

    char final[16];
    int line;
    bool first = true;

    char stemp[8];
    char temp[4];
    int numtomove;
    int movefrom;
    int moveto;

    while(f.ReadLine(buffer, sizeof(buffer)))
    {
        line++;
        if(buffer[0]=='\0') continue;

        if(buffer[0] != 'm' || buffer[1] != 'o') continue;

        int end = NUMTOMOVESTART;
        while(IsCharNumeric(buffer[end])) end++;
        strcopy(stemp, end-(NUMTOMOVESTART-1), buffer[NUMTOMOVESTART]);
        if(first) PrintToConsoleAll("Found string number to move: '%s'", stemp);
        numtomove = StringToInt(stemp);
        if(first) PrintToConsoleAll("Found number to move: '%d'", numtomove);

        int movefromend =  end + 6; // move to the next number
        while(IsCharNumeric(buffer[movefromend])) movefromend++;
        strcopy(stemp, movefromend-(end+5), buffer[end+6]);
        if(first) PrintToConsoleAll("Found string stack to move from: '%s'", stemp);
        movefrom = StringToInt(stemp);
        if(first) PrintToConsoleAll("Found number stack to move from: '%d'", movefrom);

        int movetoend =  movefromend + 4; // move to the next number
        while(IsCharNumeric(buffer[movetoend])) movetoend++;
        strcopy(stemp, movetoend-(movefromend+3), buffer[movefromend+4]);
        if(first) PrintToConsoleAll("Found string stack to move to: '%s'", stemp);
        moveto = StringToInt(stemp);
        if(first) PrintToConsoleAll("Found number stack to move to: '%d'", moveto);

        for(int i = 0; i < numtomove; i++)
        {
            stacks[movefrom].PopString(temp, 4);
            stacks[0].PushString(temp);
        }

        for(int i = 0; i < numtomove; i++)
        {
            stacks[0].PopString(temp, 4);
            stacks[moveto].PushString(temp);
        }

        first = false;
    }

    char shit[8];
    for(int i = 1; i < 10; i++)
    {
        stacks[i].PopString(shit, sizeof(shit));
        Format(final, sizeof(final), "%s%s", final, shit);
    }

    PrintToConsoleAll("Final Top: '%s'", final);
    LogMessage("Final Top: '%s'", final);

    delete f;
}

void LoadStacks()
{
    stacks[9].PushString("Z");
    stacks[9].PushString("S");
    stacks[9].PushString("M");
    stacks[9].PushString("B");
    stacks[9].PushString("L");
    stacks[9].PushString("N");
    stacks[9].PushString("P");
    stacks[9].PushString("H");

    stacks[8].PushString("D");
    stacks[8].PushString("P");
    stacks[8].PushString("F");
    stacks[8].PushString("R");

    stacks[7].PushString("B");
    stacks[7].PushString("L");
    stacks[7].PushString("D");
    stacks[7].PushString("Q");
    stacks[7].PushString("F");
    stacks[7].PushString("H");
    stacks[7].PushString("V");
    stacks[7].PushString("N");

    stacks[6].PushString("B");
    stacks[6].PushString("W");
    stacks[6].PushString("F");
    stacks[6].PushString("T");
    stacks[6].PushString("N");

    stacks[5].PushString("G");
    stacks[5].PushString("P");
    stacks[5].PushString("V");
    stacks[5].PushString("J");
    stacks[5].PushString("M");
    stacks[5].PushString("S");
    stacks[5].PushString("T");

    stacks[4].PushString("F");
    stacks[4].PushString("J");
    stacks[4].PushString("R");
    stacks[4].PushString("N");
    stacks[4].PushString("Z");
    stacks[4].PushString("T");
    stacks[4].PushString("P");

    stacks[3].PushString("T");
    stacks[3].PushString("S");
    stacks[3].PushString("Q");
    stacks[3].PushString("W");
    stacks[3].PushString("J");
    stacks[3].PushString("C");

    stacks[2].PushString("D");
    stacks[2].PushString("W");
    stacks[2].PushString("B");

    stacks[1].PushString("D");
    stacks[1].PushString("H");
    stacks[1].PushString("N");
    stacks[1].PushString("Q");
    stacks[1].PushString("T");
    stacks[1].PushString("W");
    stacks[1].PushString("V");
    stacks[1].PushString("B");
}