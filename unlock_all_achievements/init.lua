local variables = {
    version = "1.0.0",
    last_achievement_index = 58
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
    print("[unlock_all_achievements] Load into the game before using this script")
    return false
end

local unlock_all_achievements = function()
    if local_player() then
        for key, value in pairs(TweakDB:GetRecords("gamedataAchievement_Record")) do
            Game.GetAchievementSystem():UnlockAchievement(value)
        end
        print("[unlock_all_achievements] Successfully unlocked all achievements")
    end
end

local unlock_achievement_index = function(index)
    if local_player() then
        for key, value in pairs(TweakDB:GetRecords("gamedataAchievement_Record")) do
            if key == index then
                Game.GetAchievementSystem():UnlockAchievement(value)
            end
        end
        print("[unlock_all_achievements] Successfully unlocked achievement at index: " .. index)
    end
end

registerForEvent("onDraw", function()
    if not settings.is_overlay_open then 
        return
    end

    ImGui.PushStyleVar(ImGuiStyleVar.WindowMinSize, 300, 40)
    ImGui.Begin("Unlock All Achievements", ImGuiWindowFlags.AlwaysAutoResize)

    local unlock_all_toggled = ImGui.Button("Unlock All Achievements")
    if unlock_all_toggled then
        unlock_all_achievements()
    end

    ImGui.Spacing()
    ImGui.Separator()
    local unlock_specific_toggled = ImGui.Button("Unlock Achievement")
    local achievement_index = ImGui.SliderInt("Achievement Index", settings.achievement_index, 1, variables.last_achievement_index)
    if achievement_index ~= settings.achievement_index then
        settings.achievement_index = achievement_index
    end
    
    if unlock_specific_toggled then
        unlock_achievement_index(achievement_index)
    end

    ImGui.End()
    ImGui.PopStyleVar(1)
end)

registerForEvent("onInit", function()
    print("[unlock_all_achievements] Successfully loaded - version: " .. variables.version)
end)

registerForEvent("onOverlayOpen", function()
    settings.is_overlay_open = true
end)

registerForEvent("onOverlayClose", function()
    settings.is_overlay_open = false
end)
