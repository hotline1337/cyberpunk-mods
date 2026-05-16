local mod_state = {
    version = "2.0.0",
    is_visible = false,
    current_idx = 1,
    cached_achievements = {},
}

local check_player_state = function()
    local entity = Game.GetPlayer()
    if entity then
        local pos = entity:GetWorldPosition()
        if math.floor(pos.z) ~= 0 then
            return true
        end
    end

    print("[achievement_unlocker] Load into the game before using this script (ERROR)")
    return false
end

local format_achievement_data = function(record_entry)
    local id_string = record_entry:EnumName().value
    local final_name = id_string
    
    local status, loc_text = pcall(function()
        return GetLocalizedText(Game.NameToString(record_entry:DisplayName()))
    end)
    
    if not status or type(loc_text) ~= "string" or string.find(loc_text, "ToCName") or string.find(loc_text, "LocKey") then
        status, loc_text = pcall(function()
            return Game.GetLocalizedTextByKey(record_entry:DisplayName())
        end)
    end
    
    if status and type(loc_text) == "string" and loc_text ~= "" and not string.find(loc_text, "ToCName") and not string.find(loc_text, "LocKey") then
        final_name = loc_text .. " (" .. id_string .. ")"
    end
    
    return { 
        obj = record_entry, 
        internal_id = id_string, 
        display_name = final_name 
    }
end

local init_achievement_database = function()
    mod_state.cached_achievements = {}

    local db_records = TweakDB:GetRecords("gamedataAchievement_Record")
    for _, rec in pairs(db_records) do
        table.insert(mod_state.cached_achievements, format_achievement_data(rec))
    end
    
    table.sort(mod_state.cached_achievements, function(left, right) 
        return left.internal_id < right.internal_id 
    end)
    
    mod_state.current_idx = 1
end

local unlock_specific_achievement = function(ach_record)
    if not check_player_state() then 
        return 
    end

    Game.GetAchievementSystem():UnlockAchievement(ach_record)
    print(string.format("[achievement_unlocker] Unlocked: %s", ach_record:EnumName().value))
end

local unlock_all_achievements = function()
    if not check_player_state() then 
        return 
    end
    
    local unlocked_count = 0
    for i = 1, #mod_state.cached_achievements do
        Game.GetAchievementSystem():UnlockAchievement(mod_state.cached_achievements[i].obj)
        unlocked_count = unlocked_count + 1
    end
    print(string.format("[achievement_unlocker] Unlocked all achievements (Total: %d)", unlocked_count))
end

registerForEvent("onInit", function()
    init_achievement_database()
    print(string.format("[achievement_unlocker] Successfully loaded - version: %s", mod_state.version))
end)

registerForEvent("onDraw", function()
    if not mod_state.is_visible then 
        return 
    end

    ImGui.PushStyleVar(ImGuiStyleVar.WindowMinSize, 320, 50)
    ImGui.Begin("Achievement Unlocker", ImGuiWindowFlags.AlwaysAutoResize)

    if ImGui.Button("Unlock All Achievements", 220, 30) then
        unlock_all_achievements()
    end

    ImGui.Separator()
    ImGui.Spacing()

    local dropdown_label = "Select an achievement..."
    if #mod_state.cached_achievements > 0 and mod_state.cached_achievements[mod_state.current_idx] then
        dropdown_label = mod_state.cached_achievements[mod_state.current_idx].display_name
    end

    if ImGui.BeginCombo("##AchDropdown", dropdown_label) then
        for idx, ach in ipairs(mod_state.cached_achievements) do
            local is_selected = (mod_state.current_idx == idx)
            if ImGui.Selectable(ach.display_name, is_selected) then
                mod_state.current_idx = idx
            end

            if is_selected then
                ImGui.SetItemDefaultFocus()
            end
        end
        ImGui.EndCombo()
    end
    
    ImGui.SameLine()
    
    if ImGui.Button("Unlock Selected") and #mod_state.cached_achievements > 0 then
        unlock_specific_achievement(mod_state.cached_achievements[mod_state.current_idx].obj)
    end

    ImGui.End()
    ImGui.PopStyleVar(1)
end)

registerForEvent("onOverlayOpen", function()
    mod_state.is_visible = true
end)

registerForEvent("onOverlayClose", function()
    mod_state.is_visible = false
end)
