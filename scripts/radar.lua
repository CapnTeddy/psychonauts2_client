-- radar.lua
local Radar = {}
local componentBuffer = {}
local actorBuffer = {}
local playerBuffer = {}
local inventoryBuffer = {}
local radarActive = false
-- flag to stop raz from adding items picked up to inventory
-- Radar.BlockNextItem = false

require("ap_loc_map")
if type(AP_Loc_Map) ~= "table" then
    error("ap_loc_map not found or didn't load into memory!")
    return
end

require("ap_item_map")
if type(AP_Item_Map) ~= "table" then
    error("ap_item_map not found or didn't load into memory!")
    return
end

-- ==========================================
-- FILE SAVING (Retained for future mapping)
-- ==========================================
local comp_csv = "_Psy2_Captured_Components.csv"
local actor_csv = "_Psy2_Captured_Actors.csv"
local player_csv = "_Psy2_Captured_Players.csv"
local inventory_csv = "_Psy2_Captured_Inventory.csv"

local function AppendToCSV(fileName, recordValue)
    local file, err = io.open(fileName, "a")
    if not file then
        print(string.format("[RADAR ERROR] Could not write to %s: %s", fileName, tostring(err)))
        return
    end
    local timestamp = os.date("%Y-%m-%d %H:%M:%S")
    recordValue = string.gsub(recordValue, '"', '""')
    file:write(string.format('"%s","%s"\n', timestamp, recordValue))
    file:close()
end

function Radar.dumpRecords()
    print("[RADAR] Initiating file dump to CSV files...")
    for _, compName in ipairs(componentBuffer) do AppendToCSV(comp_csv, compName) end
    for _, actorName in ipairs(actorBuffer)    do AppendToCSV(actor_csv, actorName) end
    for _, playerName in ipairs(playerBuffer)  do AppendToCSV(player_csv, playerName) end
    for _, invData in ipairs(inventoryBuffer)  do AppendToCSV(inventory_csv, invData) end
    print("[RADAR DUMP COMPLETE] Processed new records. Clearing buffers...\n")
    componentBuffer, actorBuffer, playerBuffer, inventoryBuffer = {}, {}, {}, {}
end

-- ==========================================
-- AP Interception
-- ==========================================
local function SendPathToArchipelago(actor_or_component_path)

    if type(actor_or_component_path) ~= "string" or actor_or_component_path == "" then 
        return false 
    end
    if not AP_Loc_Map then return end
    local clean_path = string.match(actor_or_component_path, " (.*)$") or actor_or_component_path
    local ap_location_id = AP_Loc_Map[clean_path] 

    if ap_location_id then
        -- We just hand it silently to Multiworld, which handles the print confirmation
        if Multiworld then
            Multiworld:SendLocationCheck(ap_location_id)
        end
        return true
    else
        -- debug line: identify missing/broken IDs
        -- print("[AP RADAR] Unmapped location: " .. clean_path)
        return false
    end
end



-- ==========================================
-- ENGINE HOOKS
-- ==========================================
function Radar.start()
    if radarActive then
        print("[RADAR] Radar active\n")
        return
    end
    radarActive = true
    local collectableHook = "/Script/Psychonauts2.CoCollectable:OnCollectablePickedUp"
    local inMindHook = "/Script/Psychonauts2.CoCollectable:Collect"
    local amountHook = "/Script/Psychonauts2.P2UpgradeManager:OnInventoryItemAmountChanged"

    RegisterHook(collectableHook, function(Context, pPlayer)
        if Context then
            local actualComponent = Context:get()
            if actualComponent and actualComponent:IsValid() then
                table.insert(componentBuffer, "[PickedUp] " .. actualComponent:GetFullName())
                pcall(function()
                    local ownerActor = actualComponent:GetOwner()
                    if ownerActor and ownerActor:IsValid() then
                        table.insert(actorBuffer, "[PickedUp] " .. ownerActor:GetFullName())
                    end
                end)
            end
        end
    end)

    RegisterHook(inMindHook, function(Context, pPlayer)
        if Context then
            local actualComponent = Context:get()
            if actualComponent and actualComponent:IsValid() then
                table.insert(componentBuffer, "[Collect] " .. actualComponent:GetFullName())
                pcall(function()
                    local ownerActor = actualComponent:GetOwner()
                    if ownerActor and ownerActor:IsValid() then
                        table.insert(actorBuffer, "[Collect] " .. ownerActor:GetFullName())
                    end
                end)
            end
        end
    end)

    RegisterHook(amountHook, function(Context, pItem, iOldAmount, iNewAmount, FromLoad)
        local itemPath = "Unknown Item"
        if pItem then
            local actualItem = pItem:get()
            if actualItem and actualItem:IsValid() then
                itemPath = actualItem:GetFullName()
            end
        end

        local oldAmt, newAmt, wasLoaded = "0", "0", "false"
        pcall(function() oldAmt = tostring(iOldAmount:get()) end)
        pcall(function() newAmt = tostring(iNewAmount:get()) end)
        pcall(function() wasLoaded = tostring(FromLoad:get()) end)

        local logRow = string.format("%s, Change: %s->%s, FromLoad: %s", itemPath, oldAmt, newAmt, wasLoaded)
        table.insert(inventoryBuffer, logRow)
    end)

    print("[RADAR] Online. Background hooks active.")
end

return Radar

--===============OLD RADAR
-- function Radar.start()
--     local collectableHook = "/Script/Psychonauts2.CoCollectable:OnCollectablePickedUp"
--     local inMindHook = "/Script/Psychonauts2.CoCollectable:Collect"
--     local amountHook = "/Script/Psychonauts2.P2UpgradeManager:OnInventoryItemAmountChanged"

--     -- ---------------------------------------------------------
--     -- 1. STANDARD COLLECTABLE HOOK
--     -- ---------------------------------------------------------
--     RegisterHook(collectableHook, function(Context, pPlayer)
--         if Context then
--             local actualComponent = Context:get()
--             if actualComponent and actualComponent:IsValid() then
--                 table.insert(componentBuffer, "[PickedUp] " .. actualComponent:GetFullName())
                
--                 local success, err = pcall(function()
--                     local ownerActor = actualComponent:GetOwner()
--                     if ownerActor and ownerActor:IsValid() then
--                         local currentActor = ownerActor:GetFullName()
--                         table.insert(actorBuffer, "[PickedUp] " .. currentActor)
--                         if currentActor and currentActor ~= "" then
--                             local is_ap_check = SendPathToArchipelago(currentActor)
--                             if is_ap_check then
--                                 Radar.BlockNextItem = true
--                             end
--                         end
--                     end
--                 end)
--                 if not success then
--                     print("[RADAR ERROR] Standard Collectible Hook Failed: " .. tostring(err) .. "\n")
--                 end
--             end
--         end

--         if pPlayer then
--             local actualPlayer = pPlayer:get()
--             if actualPlayer and actualPlayer:IsValid() then
--                 table.insert(playerBuffer, "[PickedUp] " .. actualPlayer:GetFullName())
--             end
--         end
--     end)

--     -- ---------------------------------------------------------
--     -- 2. IN-MIND COLLECTABLE HOOK
--     -- ---------------------------------------------------------
--     RegisterHook(inMindHook, function(Context, pPlayer)
--         if Context then
--             local actualComponent = Context:get()
--             if actualComponent and actualComponent:IsValid() then
--                 table.insert(componentBuffer, "[Collect] " .. actualComponent:GetFullName())
                
--                 local success, err = pcall(function()
--                     local ownerActor = actualComponent:GetOwner()
--                     if ownerActor and ownerActor:IsValid() then
--                         local currentActor = ownerActor:GetFullName()
--                         table.insert(actorBuffer, "[Collect] " .. currentActor)
--                         if currentActor and currentActor ~= "" then
--                             local is_ap_check = SendPathToArchipelago(currentActor)
--                             if is_ap_check then
--                                 Radar.BlockNextItem = true
--                             end
--                         end
--                     end
--                 end)
--                 if not success then
--                     print("[RADAR ERROR] In-Mind Collectible Hook Failed: " .. tostring(err) .. "\n")
--                 end
--             end
--         end

--         if pPlayer then
--             local actualPlayer = pPlayer:get()
--             if actualPlayer and actualPlayer:IsValid() then
--                 table.insert(playerBuffer, "[Collect] " .. actualPlayer:GetFullName())
--             end
--         end
--     end)

--     -- ---------------------------------------------------------
--     -- 3. INVENTORY & UPGRADE HOOK
--     -- ---------------------------------------------------------
--     RegisterHook(amountHook, function(Context, pItem, iOldAmount, iNewAmount, FromLoad)
--         local itemPath = "Unknown Item"
--         if pItem then
--             local actualItem = pItem:get()
--             if actualItem and actualItem:IsValid() then
--                 itemPath = actualItem:GetFullName()
--             end
--         end

--         local oldAmt, newAmt, wasLoaded = "0", "0", "false"
--         pcall(function() oldAmt = tostring(iOldAmount:get()) end)
--         pcall(function() newAmt = tostring(iNewAmount:get()) end)
--         pcall(function() wasLoaded = tostring(FromLoad:get()) end)

--         local logRow = string.format("%s, Change: %s->%s, FromLoad: %s", itemPath, oldAmt, newAmt, wasLoaded)
--         table.insert(inventoryBuffer, logRow)
        
--         if itemPath and itemPath ~= "" then
--             local is_ap_check = SendPathToArchipelago(itemPath)
--             if is_ap_check then
--                 Radar.BlockNextItem = true
--             end
--         end
--     end)
--     -----------------------------------------------------------
--     -- AP INTERCEPTION
--     -----------------------------------------------------------
--     -- RegisterHook("/Script/Psychonauts2.P2BlueprintLibrary:AddToRazInventory", function(Context, pLevelScriptActor, pItem, pAmount)
--     --     -- If Raz just touched an AP item, AND the server isn't the one giving it...
--     --     if Radar.BlockNextItem and not Multiworld.IsReceivingItem then
            
--     --         print("[AP INTERCEPTOR] Blocked native game logic from giving vanilla item\n")
            
--     --         -- nullify amount change
--     --         pAmount:set(0) 
            
--     --         -- set flag to false
--     --         Radar.BlockNextItem = false 
--     --     end
--     -- end)
--     print("[RADAR] Online. Background hooks active.")
-- end

-- return Radar
