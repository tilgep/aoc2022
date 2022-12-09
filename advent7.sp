#pragma newdecls required
#pragma semicolon 1
#pragma dynamic 131072

#include <sourcemod>

int usedSpace;
int unusedSpace;
int targetSize;
int g_total;
int bestdir = 99999999;

enum struct direct
{
    char name[32];
    int total;
    ArrayList children;

    void Init(const char[] name)
    {
        strcopy(this.name,32,name);
        this.children = new ArrayList(sizeof(this));
    }
    void Cleanup()
    {
        for(int i = 0; i < this.children.Length; i++)
        {
            direct d;
            this.children.GetArray(i, d, sizeof(d));
            d.Cleanup();
        }
        delete this.children;
    }

    bool HasChildren()
    {
        return this.children.Length > 0;
    }

    int GetTotal()
    {
        if(!this.HasChildren()) return this.total;

        int tot, len = this.children.Length;
        for(int i = 0; i < len; i++)
        {
            direct d;
            this.children.GetArray(i, d, sizeof(d));
            tot += d.GetTotal();
        }
        return tot + this.total;
    }

    void CheckTotal()
    {
        int tot = this.GetTotal();
        if(tot <= 100000)
        {
            g_total+=tot;
            //PrintToConsoleAll("TOTAL FOUND: %8d in section %s", tot, this.name);
        }

        if(!this.HasChildren()) return;
        int len = this.children.Length;
        for(int i = 0; i < len; i++)
        {
            direct d;
            this.children.GetArray(i, d, sizeof(d));
            d.CheckTotal();
        }
    }
    void Print(const char[] indent)
    {
        PrintToConsoleAll("%s%s - %d",indent,this.name,this.total);
        PrintToConsoleAll("%s{",indent);
        int len = this.children.Length;
        char newindent[64];
        Format(newindent,32,"%s  ",indent);
        for(int i = 0; i < len; i++)
        {
            direct d;
            this.children.GetArray(i,d,sizeof(d));
            d.Print(newindent);
        }
        PrintToConsoleAll("%s}",indent);
    }
    void ShowChildren()
    {
        int len = this.children.Length;
        for(int i = 0; i < len; i++)
        {
            direct d;
            this.children.GetArray(i,d,sizeof(d));
            PrintToConsoleAll("%s", d.name);
        }
    }
    void CheckDirectories()
    {
        int bigtot = this.GetTotal();
        if(bigtot > targetSize)
        {
            PrintToConsoleAll("%s - %d", this.name,bigtot);
            if(bigtot < bestdir) bestdir = bigtot;

            for(int i = 0; i < this.children.Length; i++)
            {
                direct d;
                this.children.GetArray(i,d,sizeof(d));
                d.CheckDirectories();
            }
        }
    }
}

public void OnPluginStart()
{
    ParseFile();

    GetTheTotal();
}

KeyValues kv;

void GetTheTotal()
{
    kv = new KeyValues("EEEEEEEEEEEEEEEEEEEEEEEE");
    if(!kv.ImportFromFile("addons/sourcemod/configs/advent/day7_output.cfg"))
        SetFailState("Failed to import?");


    StartDealing();
    delete kv;


    //  569995 is too low
    //
    // 1423358
    //
    // 1627845 is too high

    PrintToConsoleAll("PART 1 TOTAL: %d", g_total);
    LogMessage("PART 1 TOTAL: %d", g_total);
}

void StartDealing()
{
    direct d;
    d.Init("root");
    //d.total = FindSectionTotal();
    DealWithSection(d, "root");
    d.CheckTotal();
    //d.Print("");
    //d.ShowChildren();

    unusedSpace = 70000000-d.GetTotal();
    targetSize = 30000000-unusedSpace;
    PrintToConsoleAll("UNUSED DISK SPACE: %d", unusedSpace);
    PrintToConsoleAll("USED DISK SPACE:   %d", usedSpace);
    PrintToConsoleAll("TARGET SIZE: %d", targetSize);


    d.CheckDirectories();
    PrintToConsoleAll("BEST FOUND: %d", bestdir);
    d.Cleanup();

}

void DealWithSection(direct parent, const char[] name)
{
    bool keepgoing = true, first = true,entered;
    direct d;
    d.Init(name);

    do
    {
        if(first)
        {
            d.total = FindSectionTotal();
            entered = kv.GotoFirstSubKey();
            keepgoing = entered;
            first = false;
        }
        else keepgoing = kv.GotoNextKey();

        if(keepgoing)
        {
            char newname[32];
            kv.GetSectionName(newname, 32);
            DealWithSection(d,newname);
        }
    }
    while(keepgoing);


    if(entered)
        kv.GoBack();
    parent.children.PushArray(d);
}

int FindSectionTotal()
{
    int value = 1,total,val;
    char keyname[8],sectionname[64];

    kv.GetSectionName(sectionname, 64);
    Format(keyname, 8, "value1");
    val = kv.GetNum(keyname, -1);
    //PrintToConsoleAll("CALC TOTAL FOR %s", sectionname);
    //PrintToConsoleAll("  Found val %d", val);
    do
    {
        if(val!=-1)
        {
            total+=val;
        }
        value++;
        Format(keyname,8, "value%d", value);
        val = kv.GetNum(keyname, -1);
        //PrintToConsoleAll("  Found val %d", val);
    }
    while(val != -1);

    //PrintToConsoleAll("total from section '%s' is %d", sectionname, total);

    return total;
}

void ParseFile()
{
    char buffer[PLATFORM_MAX_PATH];
    BuildPath(Path_SM, buffer, PLATFORM_MAX_PATH, "configs/advent/day7_input.txt");
    File f = OpenFile(buffer, "r");
    if(f==null) SetFailState("Failed to open file");

    int line;
    int value = 1;

    kv = new KeyValues("root");

    while(f.ReadLine(buffer, sizeof(buffer)))
    {
        line++;
        if(buffer[0]=='\0') continue;
        strcopy(buffer, strlen(buffer)-1, buffer);
        if(buffer[0]=='$')
        {
            if(buffer[2]=='c') // cd
            {
                if(buffer[5]=='/') kv.Rewind();
                else if(buffer[5]=='.'&&buffer[6]=='.') kv.GoBack();
                else
                {
                    kv.JumpToKey(buffer[5], true);
                }
            }
            else
            {
                value = 1;
                kv.SetString("value0", "0");
            }

            // ls nothing needs doing?
            continue;
        }

        // part of an ls output
        if(buffer[0]=='d'&&buffer[1]=='i'&&buffer[2]=='r')
        {
            kv.JumpToKey(buffer[4], true);
            kv.GoBack();
        }
        else
        {
            char filesize[32], filename[32];
            SplitString(buffer, " ", filesize, 32);
            Format(filename, 32, "value%d", value);
            kv.SetString(filename, filesize);
            value++;
            usedSpace+=StringToInt(filesize);
        }
    }

    kv.Rewind();
    kv.ExportToFile("addons/sourcemod/configs/advent/day7_output.cfg");
    PrintToConsoleAll("Parsed file!");
    delete kv;
}