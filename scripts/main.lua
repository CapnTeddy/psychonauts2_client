local UEHelpers = require("UEHelpers")
local radar = require("radar")
Multiworld = require("multiworld")

print("[Psychonauts2 Randomizer Client] Mod Loaded\n")
radar.start()
-- Custom Commands
------------------
RegisterConsoleCommandHandler("radar", function(FullCommand, Parameters, OutputDevice)
    radar.start()
end)
-- AP CLIENT TESTING
------------------------------
-- conn for connection testing
RegisterConsoleCommandHandler("conn", function(FullCommand, Parameters, OutputDevice) 
    local host = Parameters[1]
    local slot_name = Parameters[2]
    local password = Parameters[3]

    if not host then
        OutputDevice:Log("Please specify a host")    end
    if not slot_name then
        OutputDevice:Log("Please specify a slot name")
    end
    Multiworld:Connect(host, slot_name, "")
    return true
end)

-- give for testing
RegisterConsoleCommandHandler("give", function(FullCommand, Parameters, OutputDevice)
    local Blueprint_Library = StaticFindObject("/Script/Psychonauts2.Default__P2BlueprintLibrary")
    if not Blueprint_Library:IsValid() then
        print("No instance of class 'Default__P2BlueprintLibrary' was found.")
        return
    end
    local Persistent_Level = UEHelpers:GetPersistentLevel()
    local Level_Script_Actor = Persistent_Level.LevelScriptActor

    local item = StaticFindObject(Parameters[1])
    if not item:IsValid() then
        OutputDevice:Log("Couldn' t find the specified item")
        return
    end
    Blueprint_Library:AddToRazInventory(Level_Script_Actor, item, Parameters[2] or 1)
end)

-- ap_give for testing ap lookup
RegisterConsoleCommandHandler("ap_give", function(FullCommand, Parameters, OutputDevice)
    -- assign parameter id to variable
    local ap_item_id = tonumber(Parameters[1])
    
    -- check validity of parameter
    if not ap_item_id then
        OutputDevice:Log("Please specify an AP item ID. Example: ap_give 1001")
        return
    end

    -- translate id to path
    local item_path = AP_Item_Map[ap_item_id]
    
    -- check validity of path
    if not item_path then
        OutputDevice:Log("ID " .. tostring(ap_item_id) .. " not found")
        return true
    end

    -- inject item
    local Blueprint_Library = StaticFindObject("/Script/Psychonauts2.Default__P2BlueprintLibrary")
    if not Blueprint_Library:IsValid() then
        print("No instance of class 'Default__P2BlueprintLibrary' was found.")
        return
    end
    local Persistent_Level = UEHelpers:GetPersistentLevel()
    local Level_Script_Actor = Persistent_Level.LevelScriptActor

    local item = StaticFindObject(item_path)
    if not item:IsValid() then
        OutputDevice:Log("Couldn' t find the specified item")
        return
    end
    Blueprint_Library:AddToRazInventory(Level_Script_Actor, item, Parameters[2] or 1)
end)


function addToRaz(item_path)
    local blueprint_library = StaticFindObject("/Script/Psychonauts2.Default__P2BlueprintLibrary")
    if not blueprint_library:IsValid() then
        print("No instance of class 'Default__P2BlueprintLibrary' was found.")
        return
    end

    local persistent_level = UEHelpers:GetPersistentLevel()
    local level_script_actor = persistent_level.LevelScriptActor

    local item = StaticFindObject(item_path)
    if not item:IsValid() then
        print("Couldn't find item at path: " .. item_path)
        return
    end

    blueprint_library:AddToRazInventory(level_script_actor, item, 1)
    print("Successfully added: " .. item_path)
end
-- Keybinds
----------------
-- Add TimeBubble
RegisterKeyBind(Key.F2, {ModifierKey.CONTROL}, function()
    local blueprint_library = StaticFindObject("/Script/Psychonauts2.Default__P2BlueprintLibrary")
    if not blueprint_library:IsValid() then
        print("No instance of class 'Default__P2BlueprintLibrary' was found.")
        return
    end
    local persistent_level = UEHelpers:GetPersistentLevel()
    local level_script_actor = persistent_level.LevelScriptActor

    local time_bubble = StaticFindObject("/Game/Gameplay/Inventory/Powers/POWERKEY_TimeBubble.POWERKEY_TimeBubble")
    if not time_bubble:IsValid() then
        print ("Couldn't find Thought Bubble Powerkey")
        return
    end
    blueprint_library:AddToRazInventory(level_script_actor, time_bubble, 1)
end)
-- Give yourself MentalConnection in case it's taken away
RegisterKeyBind(Key.F4, {ModifierKey.CONTROL}, function()
    local blueprint_library = StaticFindObject("/Script/Psychonauts2.Default__P2BlueprintLibrary")
    if not blueprint_library:IsValid() then
        print("No instance of class 'Default__P2BlueprintLibrary' was found.")
        return
    end
    local persistent_level = UEHelpers:GetPersistentLevel()
    local level_script_actor = persistent_level.LevelScriptActor

    local PK_Mconn = StaticFindObject("/Game/Gameplay/Inventory/Powers/POWERKEY_MConn.POWERKEY_MConn")
    if not PK_Mconn:IsValid() then
        print ("Couldn't find Mental Connection Powerkey")
        return
    end
    blueprint_library:AddToRazInventory(level_script_actor, PK_Mconn, 1)
end)
-- Add Levitation
RegisterKeyBind(Key.F5, {ModifierKey.CONTROL}, function()
    --- @class UP2BlueprintLibrary
    local blueprint_library = StaticFindObject("/Script/Psychonauts2.Default__P2BlueprintLibrary")
    if not blueprint_library:IsValid() then
        print("No instance of class 'Default__P2BlueprintLibrary' was found.")
        return
    end
    local persistent_level = UEHelpers:GetPersistentLevel()
    local level_script_actor = persistent_level.LevelScriptActor

    local levitation = StaticFindObject("/Game/Gameplay/Inventory/Powers/POWERKEY_Levitation.POWERKEY_Levitation")
    if not levitation:IsValid() then
        print ("Couldn't find Levitation Powerkey")
        return
    end
    blueprint_library:AddToRazInventory(level_script_actor, levitation, 1)
end)
-- Add TK
RegisterKeyBind(Key.F6, {ModifierKey.CONTROL}, function()
    --- @class UP2BlueprintLibrary
    local blueprint_library = StaticFindObject("/Script/Psychonauts2.Default__P2BlueprintLibrary")
    if not blueprint_library:IsValid() then
        print("No instance of class 'Default__P2BlueprintLibrary' was found.")
        return
    end
    local persistent_level = UEHelpers:GetPersistentLevel()
    local level_script_actor = persistent_level.LevelScriptActor

    local tk = StaticFindObject("/Game/Gameplay/Inventory/Powers/POWERKEY_Telekinesis.POWERKEY_Telekinesis")
    if not tk:IsValid() then
        print ("Couldn't find Telekinesis Powerkey")
        return
    end
    blueprint_library:AddToRazInventory(level_script_actor, tk, 1)
end)

-- Add Pyro
RegisterKeyBind(Key.F7, {ModifierKey.CONTROL}, function()
    --- @class UP2BlueprintLibrary
    local blueprint_library = StaticFindObject("/Script/Psychonauts2.Default__P2BlueprintLibrary")
    if not blueprint_library:IsValid() then
        print("No instance of class 'Default__P2BlueprintLibrary' was found.")
        return
    end
    local persistent_level = UEHelpers:GetPersistentLevel()
    local level_script_actor = persistent_level.LevelScriptActor

    local pyro = StaticFindObject("/Game/Gameplay/Inventory/Powers/POWERKEY_Pyrokinesis.POWERKEY_Pyrokinesis")
    if not pyro:IsValid() then
        print ("Couldn't find Pyrokinesis Powerkey")
        return
    end
    blueprint_library:AddToRazInventory(level_script_actor, pyro, 1)
end)

-- Add PSIBlast
RegisterKeyBind(Key.F8, {ModifierKey.CONTROL}, function()
    --- @class UP2BlueprintLibrary
    local blueprint_library = StaticFindObject("/Script/Psychonauts2.Default__P2BlueprintLibrary")
    if not blueprint_library:IsValid() then
        print("No instance of class 'Default__P2BlueprintLibrary' was found.")
        return
    end
    local persistent_level = UEHelpers:GetPersistentLevel()
    local level_script_actor = persistent_level.LevelScriptActor

    local psi_blast = StaticFindObject("/Game/Gameplay/Inventory/Powers/POWERKEY_PsiBlast.POWERKEY_PsiBlast")
    if not psi_blast:IsValid() then
        print ("Couldn't find PsiBlast Powerkey")
        return
    end
    blueprint_library:AddToRazInventory(level_script_actor, psi_blast, 1)
end)

-- Add Salts
RegisterKeyBind(Key.F9, {ModifierKey.CONTROL}, function()
    --- @class UP2BlueprintLibrary
    local blueprint_library = StaticFindObject("/Script/Psychonauts2.Default__P2BlueprintLibrary")
    if not blueprint_library:IsValid() then
        print("No instance of class 'Default__P2BlueprintLibrary' was found.")
        return
    end
    local persistent_level = UEHelpers:GetPersistentLevel()
    local level_script_actor = persistent_level.LevelScriptActor

    local smelling_salts = StaticFindObject("/Game/Gameplay/Inventory/INV_SmellingSalts.INV_SmellingSalts")
    if not smelling_salts:IsValid() then
        print("No item called 'INV_SmellingSalts' was found.")
        return
    end
    blueprint_library:AddToRazInventory(level_script_actor, smelling_salts, 1)
end)

-- Add Radial
RegisterKeyBind(Key.F10, {ModifierKey.CONTROL}, function()
    --- @class UP2BlueprintLibrary
    local blueprint_library = StaticFindObject("/Script/Psychonauts2.Default__P2BlueprintLibrary")
    if not blueprint_library:IsValid() then
        print("No instance of class 'Default__P2BlueprintLibrary' was found.")
        return
    end
    local persistent_level = UEHelpers:GetPersistentLevel()
    local level_script_actor = persistent_level.LevelScriptActor

    local ability_radial = StaticFindObject("/Game/Characters/Raz/Abilities/INV_AbilityRadialMenu.INV_AbilityRadialMenu")
    if not ability_radial:IsValid() then
        print("Couldn't find Ability Radial")
        return
    end
    blueprint_library:AddToRazInventory(level_script_actor, ability_radial, 1)
end)

