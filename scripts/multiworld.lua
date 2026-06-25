Multiworld = {}

local UEHelpers = require("UEHelpers")
local AP = require "lua-apclientpp"

if AP == nil then
    error("lua-apclientpp not found!")
    return
end

local ap = nil
local LocWaiting = {}
-- local IsAPGrant = false
local ItemsReceivedIndex = 0 -- tracks items received

function Multiworld:Connect(host, slot, password)
    if ap then
        print("[AP] Already connected or connection in progress\n")
        ap = nil
        return
    end

    ap = AP("", "Psychonauts 2", host)
    print("[AP] Attempting connection to server as " .. slot .. "\n")

    ap:set_socket_connected_handler(function() print("[AP] Socket connected\n") end)
    ap:set_socket_disconnected_handler(function() print("[AP] Socket disconnected\n"); ap = nil end)
    ap:set_socket_error_handler(function(msg) print("[AP] Socket error: " .. msg .. "\n") end)

    ap:set_room_info_handler(function()
        print("[AP] Room info received. Authenticating\n")
        -- 7 tells the server we want to both Send and Receive items
        ap:ConnectSlot(slot, password or "", 7, {"Psychonauts 2 Client"}, {0, 6, 7})
    end)

    ap:set_slot_connected_handler(function(slot_data)
        print("[AP] Connected to slot successfully!\n")
    end)

    ap:set_slot_refused_handler(function(reasons)
        print("[AP ERROR] Slot refused: " .. table.concat(reasons, ", ") .. "\n")
        ap = nil
    end)

    -- Handle INCOMING items from the server
    ap:set_items_received_handler(function(items)
        -- only process new ones
        for i, item in ipairs(items) do
            -- if i > ItemsReceivedIndex then
            print("[AP] Received item from server: " .. item.item .. "\n")
            Multiworld:ReceiveItem(item.item)
            ItemsReceivedIndex = ItemsReceivedIndex + 1
        end
        
        -- debugging
        print("[AP] Received: " .. tostring(#items) .. " from server\n")
        for _, item in ipairs(items) do 
            print("[AP] Received item from server: " .. tostring(item.item) .. "\n")
        end
    end)
end

-- function Multiworld:SendLocationCheck(location_id)
--     if ap then
--         table.insert(LocWaiting, location_id)
--         print("[AP] Location Check ID: " .. tostring(location_id) .. "\n")
--     end
-- end



-- ==========================================
-- Polling engine 
-- ==========================================
-- polls 20 times a second
LoopAsync(50, function()
    ExecuteInGameThread(function()
        if ap then
            -- Wrap the polling in a protected call to prevent silent thread crashes
            local success, err = pcall(function()
                ap:poll()
                if #LocWaiting > 0 then
                    ap:LocationsChecks(LocWaiting)
                    LocWaiting = {}
                end
            end)
            
            -- If the network loop crashes, YELL at us in the console
            if not success then
                print("[AP POLLING ERROR] " .. tostring(err) .. "\n")
            end
        end
    end)
    -- Returning false keeps the loop running 
    return false
end)

function Multiworld:SendLocationCheck(location_id)
    if not ap then return end
    print("[AP] Sending location ID " .. tostring(location_id) .. "\n")
    if ap then
        local success, err = pcall(function()
            -- Send the check immediately as a table
            ap:LocationChecks({location_id})
        end)

        if success then
            print("[AP] Packet successfully left the client!\n")
        else
            print("[AP ERROR] Failed to send packet: " .. tostring(err) .. "\n")
        end
    end
end
--================================
--INTERCEPT ITEMS
--================================
local function HandleCollectable(ContextWrapper)
    local Context = ContextWrapper:get()
    if not Context or not Context:IsValid() then return end

    local OwnerActor = Context:GetOwner()
    if not OwnerActor or not OwnerActor:IsValid() then return end

    local fullName = OwnerActor:GetFullName()
    local _, path = fullName:match("([^ ]+) (.+)")
    local caller_path = path or fullName

    local location_id = AP_Loc_Map[caller_path]

    if location_id then
        print("[AP] Physical check picked up! Sending to server: " .. tostring(location_id) .. "\n")
        Multiworld:SendLocationCheck(location_id)
        
        -- Destroy the actor to remove it from the world
        pcall(function()
            OwnerActor:K2_DestroyActor()
        end)
        
        -- Cancel the vanilla C++ collectable function
        return true
    end
end

RegisterHook("/Script/Psychonauts2.CoCollectable:OnCollectablePickedUp", function(ContextWrapper)
    return HandleCollectable(ContextWrapper)
end)

RegisterHook("/Script/Psychonauts2.CoCollectable:Collect", function(ContextWrapper)
    return HandleCollectable(ContextWrapper)
end)

function Multiworld:ReceiveItem(item_id)
    print(item_id)
    local item_path = AP_Item_Map[item_id]
    if not item_path then
        print("[AP ERROR] Unknown Item ID received: " .. tostring(item_id) .. "\n")
        return
    end

    local Blueprint_Library = StaticFindObject("/Script/Psychonauts2.Default__P2BlueprintLibrary")
    local Persistent_Level = UEHelpers:GetPersistentLevel()
    
    if Blueprint_Library:IsValid() and Persistent_Level:IsValid() then
        local Level_Script_Actor = Persistent_Level.LevelScriptActor
        local item = StaticFindObject(item_path)
        
        if item and item:IsValid() then
            -- IsAPGrant = true
            Blueprint_Library:AddToRazInventory(Level_Script_Actor, item, 1)
            print("[AP] Granted Item from Server: " .. item_path .. "\n")
            -- IsAPGrant = false
        else
            print("[AP ERROR] UE Object invalid for path: " .. item_path .. "\n")
        end
    end
end

return Multiworld