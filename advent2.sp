#pragma newdecls required
#pragma semicolon 1

#include <sourcemod>

enum RPS
{
    Invalid = 0,
    Rock = 1,
    Paper = 2,
    Scissors = 3,
}

enum Outcome
{
    Bad = 0,
    Loss = 1,
    Draw = 2,
    Win = 3,
}

public void OnPluginStart()
{
    char buffer[PLATFORM_MAX_PATH];
    BuildPath(Path_SM, buffer, PLATFORM_MAX_PATH, "configs/advent/day2_input.txt");
    File f = OpenFile(buffer, "r");
    if(f==null) SetFailState("Failed to open file");

    int line;
    RPS them;
    Outcome out;

    int total;
    int round_score;

    while(f.ReadLine(buffer, sizeof(buffer)))
    {
        line++;
        if(buffer[0]=='\0') continue;

        them = GetMoveFromChar(buffer[0]);
        out = GetOutcomeFromChar(buffer[2]);

        if(them==Invalid)
        {
            LogMessage("Invalid 'them' on line %d", line);
            continue;
        }
        if(out==Bad)
        {
            LogMessage("Invalid 'out' on line %d", line);
            continue;
        }

        round_score += GetMyMove(them, out);
        
        if(out==Win) round_score+=6;
        else if(out==Draw) round_score+=3;

        total += round_score;
        round_score = 0;
    }

    LogMessage("Total score: %d", total);
    delete f;
}

int GetMyMove(RPS them, Outcome out)
{
    if(out==Win)
    {
        if(them==Rock) return 2;
        if(them==Paper) return 3;
        return 1;
    }
    else if(out==Draw)
    {
        if(them==Rock) return 1;
        if(them==Paper) return 2;
        return 3;
    }
    else // out==loss
    {
        if(them==Rock) return 3;
        if(them==Paper) return 1;
        return 2;
    }
}

RPS GetMoveFromChar(char c)
{
    switch(c)
    {
        case 'A': return Rock;
        case 'B': return Paper;
        case 'C': return Scissors;
    }
    return Invalid;
}

Outcome GetOutcomeFromChar(char c)
{
    switch(c)
    {
        case 'X': return Loss;
        case 'Y': return Draw;
        case 'Z': return Win;
    }
    return Bad;
}