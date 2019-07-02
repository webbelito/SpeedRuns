SpeedRuns_EventHandler = CreateFrame("FRAME")
SpeedRuns_EventHandler:RegisterEvent("ADDON_LOADED")

local SpeedRuns_MaxLevel = 12
local SpeedRuns_CurrentLevel = nil

local SpeedRuns_LastLevel = nil
local SpeedRuns_ClassID = nil
local SpeedRuns_RaceID = nil

local SpeedRuns_TotalTime = 0
local SpeedRuns_LevelTime = 0
local SpeedRuns_DeltaTime = 0

local SpeedRuns_SplitsMax = nil
local SpeedRuns_SplitsMin = nil

local SpeedRuns_LevelSplit = {}

local SpeedRuns_HaveLeveledUp = nil

function SpeedRuns_GenerateLevelSplit()
    for level=1, SpeedRuns_MaxLevel, 1 do
        table.insert(SpeedRuns_LevelSplit, level)
    end
end

function SpeedRuns_SavePlayedForSpecificLevel(level, time)
    SpeedRuns_LevelSplit[level] = time
end

function SpeedRuns_GetPlayedForSpecificLevel(level)
    return SpeedRuns_LevelSplit[level]
end

local SpeedRuns_EventList = {
    "PLAYER_LEVEL_UP",
    "TIME_PLAYED_MSG",
    "PLAYER_LOGIN"
}

local SpeedRuns_Usage = [[
|cffffff8800## SpeedRuns Usage:

There are no current commands available for the SpeedRuns addon.
Your PB will be recorded individually per Race and Class combination.

    PB 1 = Troll Warrior
    PB 2 = Orc Warrior

These vill have different PB values depending on your recorded statistics.
Also of course it will be individually recorded for each class.

    PB 3 = Troll Mage
    PB 4 = Undead Priest

]]

function SpeedRuns_RegisterEvents()
    for _,e in SpeedRuns_EventList do
        SpeedRuns_EventHandler:RegisterEvent(e)
    end
end

function SpeedRuns_UnregisterEvents()
    for _,e in SpeedRuns_EventList do
        SpeedRuns_EventList:UnregisterEvents(e)
    end
end

function SpeedRuns_EventHandler.ADDON_LOADED()
    if arg1 == "SpeedRuns" then

        _, SpeedRuns_RaceID = UnitRace("player")
        _, SpeedRuns_ClassID = UnitClass("player")

        if SpeedRuns_PB == nil then
            SpeedRuns_PB = {}
        end

        if SpeedRuns_Gold == nil then
            SpeedRuns_Gold = {}
        end

        if (tContains(SpeedRuns_PB, SpeedRuns_RaceID) == false) then
            SpeedRuns_PB[SpeedRuns_RaceID] = {}
            SpeedRuns_Gold[SpeedRuns_RaceID] = {}

        end

        if tContains(SpeedRuns_PB[SpeedRuns_RaceID], SpeedRuns_ClassID) == false then
            SpeedRuns_PB[SpeedRuns_RaceID][SpeedRuns_ClassID] = {}
            SpeedRuns_PB[SpeedRuns_RaceID][SpeedRuns_ClassID][1] = 0
            SpeedRuns_Gold[SpeedRuns_RaceID][SpeedRuns_ClassID] = {}
            SpeedRuns_Gold[SpeedRuns_RaceID][SpeedRuns_ClassID][1] = 0
        end

        SpeedRuns_RegisterEvents()
        SpeedRuns_GenerateLevelSplit()

        SpeedRuns_EventHandler:UnregisterEvent("ADDON_LOADED")
        DEFAULT_CHAT_FRAME:AddMessage("|cffffff88SpeedRuns|r loaded. See /speedruns usage")
    end
end

function SpeedRuns_EventHandler.PLAYER_LOGIN()
    SpeedRuns_CurrentLevel = UnitLevel("player")

    if(SpeedRuns_Splits == nil or SpeedRuns_CurrentLevel == 1) then
        SpeedRuns_Splits = {}
        SpeedRuns_Splits[1] = 0
    end
end


function SpeedRuns_EventHandler.PLAYER_LEVEL_UP()

    -- Update the current level of the player, shouldn't be done with regular UnitLevel("player")
    SpeedRuns_CurrentLevel = arg1
    SpeedRuns_LastLevel = SpeedRuns_CurrentLevel - 1

    SpeedRuns_HaveLeveledUp = true

    RequestTimePlayed()
end

function SpeedRuns_EventHandler.TIME_PLAYED_MSG()

    SpeedRuns_TotalTime = arg1
    SpeedRuns_LevelTime = arg2
    SpeedRuns_Splits[SpeedRuns_CurrentLevel] = arg1 - arg2

    local SpeedRuns_SplitsColor = "|cffffff88"
    local SpeedRuns_LevelTimeDiff = SpeedRuns_Splits[SpeedRuns_CurrentLevel] - SpeedRuns_Splits[SpeedRuns_LastLevel]


    -- Check if player is above level 1
    if (SpeedRuns_CurrentLevel > 1 and SpeedRuns_HaveLeveledUp == true) then

    -- Check if player has a PB for the Race and Class
        if (tContains(SpeedRuns_PB[SpeedRuns_RaceID][SpeedRuns_ClassID], SpeedRuns_CurrentLevel) == false) then
            SpeedRuns_PB[SpeedRuns_RaceID][SpeedRuns_ClassID][SpeedRuns_CurrentLevel] = SpeedRuns_Splits[SpeedRuns_CurrentLevel]
            DEFAULT_CHAT_FRAME:AddMessage("|cffffff88SpeedRuns|r Congratulations, You've reaced a new PB: You didn't have any previous PB...")
            DEFAULT_CHAT_FRAME:AddMessage("|cffffff88SpeedRuns|r Your new PB for Level "..SpeedRuns_CurrentLevel.." is: ")
            DEFAULT_CHAT_FRAME:AddMessage("|cffffff88SpeedRuns|r Total Played: |cFF00FF00"..convertTime(SpeedRuns_Splits[SpeedRuns_CurrentLevel]).."|r")
            DEFAULT_CHAT_FRAME:AddMessage("|cffffff88SpeedRuns|r Level up time: |cFF00FF00"..convertTime(SpeedRuns_LevelTimeDiff).."|r")
        elseif (tContains(SpeedRuns_PB[SpeedRuns_RaceID][SpeedRuns_ClassID], SpeedRuns_CurrentLevel) == true) then
            if(SpeedRuns_Splits[SpeedRuns_CurrentLevel] < SpeedRuns_PB[SpeedRuns_RaceID][SpeedRuns_ClassID][SpeedRuns_CurrentLevel]) then

                local oldPB = SpeedRuns_PB[SpeedRuns_RaceID][SpeedRuns_ClassID][SpeedRuns_CurrentLevel]

                SpeedRuns_PB[SpeedRuns_RaceID][SpeedRuns_ClassID][SpeedRuns_CurrentLevel] = SpeedRuns_Splits[SpeedRuns_CurrentLevel]
                DEFAULT_CHAT_FRAME:AddMessage("|cffffff88SpeedRuns|r Congratulations, You've reaced a new PB: Previous PB was: "..convertTime(oldPB))
                DEFAULT_CHAT_FRAME:AddMessage("|cffffff88SpeedRuns|r Your new PB for Level "..SpeedRuns_CurrentLevel.." is: ")
                DEFAULT_CHAT_FRAME:AddMessage("|cffffff88SpeedRuns|r Total Played: |cFF00FF00"..convertTime(SpeedRuns_Splits[SpeedRuns_CurrentLevel]).."|r")
                DEFAULT_CHAT_FRAME:AddMessage("|cffffff88SpeedRuns|r Level up time: |cFF00FF00"..convertTime(SpeedRuns_LevelTimeDiff).."|r")
                DEFAULT_CHAT_FRAME:AddMessage("|cffffff88SpeedRuns|r You beat your Previous PB with: |cFF00FF00"..convertTime(oldPB-SpeedRuns_Splits[SpeedRuns_CurrentLevel]).."|r")
            else
                DEFAULT_CHAT_FRAME:AddMessage("|cffffff88SpeedRuns|r OH NOEWS, You've failed: PB is still standing strong: "..convertTime(SpeedRuns_PB[SpeedRuns_RaceID][SpeedRuns_ClassID][SpeedRuns_CurrentLevel]))
                DEFAULT_CHAT_FRAME:AddMessage("|cffffff88SpeedRuns|r Your current time for Level "..SpeedRuns_CurrentLevel.." is: ")
                DEFAULT_CHAT_FRAME:AddMessage("|cffffff88SpeedRuns|r Total Played: |cFFFF0000"..convertTime(SpeedRuns_Splits[SpeedRuns_CurrentLevel]).."|r")
                DEFAULT_CHAT_FRAME:AddMessage("|cffffff88SpeedRuns|r Level up time: |cFFFF0000"..convertTime(SpeedRuns_LevelTimeDiff).."|r")
                DEFAULT_CHAT_FRAME:AddMessage("|cffffff88SpeedRuns|r You lost against your PB with: |cFFFF0000"..convertTime(SpeedRuns_Splits[SpeedRuns_CurrentLevel]-SpeedRuns_PB[SpeedRuns_RaceID][SpeedRuns_ClassID][SpeedRuns_CurrentLevel]).."|r")
            end
        end

        SpeedRuns_HaveLeveledUp = false

    end
end

SpeedRuns_EventHandler:SetScript("OnEvent",
    function ()
        if SpeedRuns_EventHandler[event] then
            SpeedRuns_EventHandler[event]()
        end
    end
)

function SpeedRuns_SplitsRange(range, level)
    SpeedRuns_SplitsMax = level+1
    if SpeedRuns_SplitsMax > 60 then
        SpeedRuns_SplitsMax = 60
    elseif SpeedRuns_SplitsMax < range+2 then
        SpeedRuns_SplitsMax = range+2
    end
    SpeedRuns_SplitsMin = SpeedRuns_SplitsMax-range
end

-- Function to check if item exists in a table, returns TRUE/FALSE
function tContains(table, index)
	for key,_ in pairs(table) do
		if key == index then
			return true
		end
	end
	return false
end

-- Function to convert time from seconds to human readable format HH:MM:SS
function convertTime(time)
    local h = floor(time/60/60)
    local m = floor((time-h*60*60)/60)
    local s = floor(time-h*60*60-m*60)

    if(h < 10) then
        h = "0"..tostring(h)
    else
        h = tostring(h)
    end

    if(m < 10) then
        m = "0"..tostring(m)
    else
        m = tostring(m)
    end

    if(s < 10) then
        s = "0"..tostring(s)
    else
        s = tostring(s)
    end

    return h..":"..m..":"..s
end

local function CommandParser(msg, editbox)
    local _,_,command, rest = string.find(msg,"^(%S*)%s*(.-)$")
    if command == "usage" then
        DEFAULT_CHAT_FRAME:AddMessage(SpeedRuns_Usage)
    end
end
SLASH_SPEEDRUNS1 = "/speedruns"
SLASH_SPEEDRUNS2 = "/sruns"
SLASH_SPEEDRUNS3 = "/sr"
SlashCmdList["SPEEDRUNS"] = CommandParser
