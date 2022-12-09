#pragma newdecls required
#pragma semicolon 1
#pragma dynamic 131072

#include <sourcemod>

int heights[99][99];
bool visible[99][99];

public void OnPluginStart()
{
    char buffer[PLATFORM_MAX_PATH];
    BuildPath(Path_SM, buffer, PLATFORM_MAX_PATH, "configs/advent/day8_input.txt");
    File f = OpenFile(buffer, "r");
    if(f==null) SetFailState("Failed to open file");

    int line;

    while(f.ReadLine(buffer, sizeof(buffer)))
    {
        line++;
        if(buffer[0]=='\0' || line > 99) continue;
        strcopy(buffer, strlen(buffer)-1, buffer); // remove newline char

        char c[2];
        for(int i = 0; i < 99; i++)
        {
            strcopy(c,2,buffer[i]);
            heights[line-1][i] = StringToInt(c);
            if(line-1==0||line-1==98) visible[line-1][i] = true;
        }
        visible[line-1][0] = true;
        visible[line-1][98] = true;
    }
    delete f;

    CheckFromLeft();
    CheckFromRight();

    //VisualiseVisible(true);
    //PrintToConsoleAll("  ");
    VisualiseHeight();

    FindScenicScore();
}

void FindScenicScore()
{
    int highest, highi,highk;
    int score;
    int left,right,up,down;
    for(int i = 0; i < 99; i++)
    {
        for(int k = 0; k < 99; k++)
        {
            right = GetScenicRight(i, k);
            down = GetScenicDown(i,k);
            
            left = GetScenicLeft(i,k);
            up = GetScenicUp(i,k);

            score = left*right*up*down;
            if(score > highest) 
            {
                highest = score;
            }
        }
    }
    PrintToConsoleAll("HIGHEST SCENIC: %d", highi,highk,highest);
}

int GetScenicRight(int row, int col)
{
    if(col==98)return 0;
    if(col==97)return 1;
    int column = col+1;
    
    while(column < 98)
    {
        if(heights[row][column] < heights[row][col]) column++;
        else break;
    }

    return column-col;
}

int GetScenicDown(int row, int col)
{
    if(row==98)return 0;
    if(row==97)return 1;
    int roww = row+1;

    while(roww < 98)
    {
        if(heights[roww][col] < heights[row][col]) roww++;
        else break;
    }
    return roww-row;
}

int GetScenicLeft(int row, int col)
{
    if(col==0)return 0;
    if(col==1)return 1;
    int column = col-1;

    while(column > 0)
    {
        if(heights[row][column] < heights[row][col]) column--;
        else break;
    }
    return col-column;
}

int GetScenicUp(int row, int col)
{
    if(row==0)return 0;
    if(row==1)return 1;
    int roww = row-1;
    while(roww > 0)
    {
        if(heights[roww][col] < heights[row][col]) roww--;
        else break;
    }
    return row-roww;
}

void CheckFromRight()
{
    int highestFromRight, highestFromBottom;
    for(int i = 98; i >=0; i--)
    {
        highestFromRight = heights[i][98];
        highestFromBottom = heights[98][i];
        for(int j = 98; j >=0; j--)
        {
            if(heights[i][j] > highestFromRight)
            {
                visible[i][j] = true;
                highestFromRight = heights[i][j];
            }

            if(heights[j][i] > highestFromBottom)
            {
                visible[j][i] = true;
                highestFromBottom = heights[j][i];
            }
        }
    }
}

void CheckFromLeft()
{
    int highestFromLeft, highestFromTop;
    for(int i = 0; i < 99; i++)
    {
        highestFromLeft = heights[i][0];
        highestFromTop = heights[0][i];
        for(int j = 1; j < 99; j++)
        {
            if(heights[i][j] > highestFromLeft)
            {
                visible[i][j] = true;
                highestFromLeft = heights[i][j];
            }

            if(heights[j][i] > highestFromTop)
            {
                visible[j][i] = true;
                highestFromTop = heights[j][i];
            }
        }
    }
}

void VisualiseVisible(bool printAll)
{
    int total;
    for(int i = 0; i < 99; i++)
    {
        char line[101];
        for(int j = 0; j < 99; j++)
        {
            if(visible[i][j]) total++;
            Format(line, 101,"%s%b",line,visible[i][j]);
        }
        if(printAll) PrintToConsoleAll(line);
    }
    PrintToConsoleAll("Total visible: %d", total);
}

void VisualiseHeight()
{
    for(int i = 0; i < 99; i++)
    {
        char line[101];
        for(int j = 0; j < 99; j++)
        {
            Format(line, 101,"%s%d",line,heights[i][j]);
        }
        PrintToConsoleAll(line);
    }
}