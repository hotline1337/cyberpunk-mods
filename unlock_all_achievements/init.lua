local variables = {
    version = "1.1.0",
    achievement_list = {
        "All The President's Men",
        "City Lights",
        "To Bad Decisions!",
        "Breathtaking",
        "Bushido and Chill",
        "Full Body Conversion",
        "Right Back At Ya",
        "Dirty Deeds",
        "The APB is Not Enough",
        "Easy Come, Easy Go",
        "To Protect and Serve",
        "The Wandering Fool",
        "Autojock",
        "Frequent Flyer",
        "Gun Fu",
        "Gunslinger",
        "Master Crafter",
        "Judgment Day",
        "I Am The Law",
        "Arachnophobia",
        "King of Cups",
        "King of Pentacles",
        "King of Swords",
        "King of Wands",
        "Spin Doctor",
        "Mean Streets",
        "Little Tokyo",
        "Christmas Tree Attack",
        "The Quick and the Dead",
        "Must Be Rats",
        "Never Fade Away",
        "The Wasteland",
        "Daemon In The Shell",
        "Life of the Road",
        "Relic Ruler",
        "Stanislavski's Method",
        "Ten out of Ten",
        "Temperance",
        "Rough Landing",
        "The Devil",
        "The Fool",
        "The Hermit",
        "The High Priestess",
        "The Lovers",
        "The Star",
        "The Sun",
        "The Tower",
        "The Wheel of Fortune",
        "The World",
        "Greetings from Pacifica!",
        "The Jungle",
        "True Soldier",
        "True Warrior",
        "Two Heads, One Bullet",
        "Judy vs Night City",
        "V for Vendetta",
        "It's Elementary",
        "Legend of The Afterlife"
    } -- Dumped from TweakDB
}

local settings = {
    is_overlay_open = false,
    achievement_index = 1
}

local local_player = function()
    local player = Game.GetPlayer()
    if player then
        local player_position = player:GetWorldPosition()
        if math.floor(player_position.z) ~= 0 then
            return true
        end
    end
    print("[achievement_unlocker] Load into the game before using this script")
    return false
end

local unlock_all_achievements = function()
    if local_player() then
        for key, value in pairs(TweakDB:GetRecords("gamedataAchievement_Record")) do
            Game.GetAchievementSystem():UnlockAchievement(value)
        end
        print("[achievement_unlocker] Successfully unlocked all achievements")
    end
end

local unlock_achievement_index = function(index)
    if local_player() then
        for key, value in pairs(TweakDB:GetRecords("gamedataAchievement_Record")) do
            if key == index then
                Game.GetAchievementSystem():UnlockAchievement(value)
            end
        end
        print("[achievement_unlocker] Successfully unlocked achievement: " .. variables.achievement_list[index])
    end
end

registerForEvent("onDraw", function()
    if not settings.is_overlay_open then 
        return
    end

    ImGui.PushStyleVar(ImGuiStyleVar.WindowMinSize, 300, 40)
    ImGui.Begin("Achievement Unlocker", ImGuiWindowFlags.AlwaysAutoResize)

    local unlock_all_toggled = ImGui.Button("Unlock All Achievements")
    if unlock_all_toggled then
        unlock_all_achievements()
    end

    ImGui.Spacing()
    ImGui.Separator()
    local unlock_specific_toggled = ImGui.Button("Unlock Achievement")
    if unlock_specific_toggled then
        unlock_achievement_index(settings.achievement_index)
    end

    if ImGui.BeginCombo("Achievement Name", variables.achievement_list[settings.achievement_index]) then
        for index, achievement in ipairs(variables.achievement_list) do
            local is_selected = (settings.achievement_index == index)
            if ImGui.Selectable(achievement, is_selected) then
                settings.achievement_index = index
            end
            if is_selected then
                ImGui.SetItemDefaultFocus()
            end
        end
        ImGui.EndCombo()
    end

    ImGui.End()
    ImGui.PopStyleVar(1)
end)

registerForEvent("onInit", function()
    print("[achievement_unlocker] Successfully loaded - version: " .. variables.version)
end)

registerForEvent("onOverlayOpen", function()
    settings.is_overlay_open = true
end)

registerForEvent("onOverlayClose", function()
    settings.is_overlay_open = false
end)
