--// Services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")

--// Assets
local Assets = ServerStorage:FindFirstChild("Assets")
local HolsterAssets = Assets:FindFirstChild("Holsters")
local WeaponModelAssets = Assets:FindFirstChild("WeaponModelAssets")

local ZanpakutoModel = WeaponModelAssets:FindFirstChild("Zanpakuto")::Model
local ZanpakutoHolster = HolsterAssets:FindFirstChild("ZanpakutoAccessory")::Accessory

local AnimationsFolder = ReplicatedStorage:FindFirstChild("Animations")
local ZanpakutoEquipAnimation: Animation = AnimationsFolder:FindFirstChild("ZanpakutoAnimations"):FindFirstChild("EquipAnim")

--// Shared
local SharedUtils = ReplicatedStorage.Shared.SharedUtils

local PlayerStateUtils = SharedUtils.PlayerStateUtils
local CooldownUtils = SharedUtils.CooldownUtils
local AnimationUtils = SharedUtils.AnimationUtils

local AnimationHandler = require(AnimationUtils.AnimationHandler)
local PlayerStateController = require(PlayerStateUtils.PlayerStateController)
local CooldowHandler= require(CooldownUtils.CooldownHandler)

--// Connections
local Connections = ReplicatedStorage:FindFirstChild("Connections")
local ZanpakutoConnections = Connections:FindFirstChild("ZanpakutoConnections")
local WeaponEquipEvent : RemoteEvent = ZanpakutoConnections:FindFirstChild("WeaponEquipEvent")
local ZanpakutoEquippedEvent: RemoteEvent = ZanpakutoConnections:FindFirstChild("ZanpakutoEquippedEvent")

--// Main
local module = {}

local LastEquip: {} = {}
local PlayerWeapons: {} = {}
local PlayerHolsters: {} = {}

local function CreateWeapon(Player:Player, PlayerZanpakutoHolster:Accessory)
    local Character = Player.Character or Player.CharacterAdded:Wait()
    local Humanoid = Character:WaitForChild("Humanoid")::Humanoid
    local RightArm = Character:WaitForChild("Right Arm")

    local PlayerZanpakuto
    local IsCooldown: boolean = CooldowHandler.CheckCooldown(Player, 1.5, LastEquip)
    if IsCooldown then return end

    if PlayerZanpakutoHolster and PlayerZanpakutoHolster:IsA("Accessory") then
        PlayerZanpakutoHolster:Destroy()
        PlayerHolsters[Player] = nil
    end

    Humanoid.WalkSpeed = 0

    -- animation handler handles reaching keyframes and what to do next (animation events)
    AnimationHandler.LoadAnimation(Character, "EquipAnimation", ZanpakutoEquipAnimation.AnimationId, function(MarkerName)
        PlayerStateController.EnablePlayerState(Player, "Armed")
    
        PlayerZanpakuto = ZanpakutoModel:Clone()::Model
        PlayerZanpakuto.Name = "Zanpakuto"
        
        for _, part in pairs(PlayerZanpakuto:GetChildren()) do
            if not part:IsA("BasePart") then continue end
        
            part.CanCollide = false
        end
    
        local PlayerZanpakutoHandle = PlayerZanpakuto.PrimaryPart
        local HandleCframeValue = PlayerZanpakutoHandle:FindFirstChild("HandleCframeValue")::CFrameValue
        local Motor6D = PlayerZanpakutoHandle:FindFirstChild("Motor6D")::Motor6D
        Motor6D.Part0 = RightArm
        Motor6D.Part1 = PlayerZanpakutoHandle
        Motor6D.C1 = HandleCframeValue.Value -- Pos = CFrame.new(0, -1, 0), Orientation = CFrame.new(0, 90, 0)
    
        ZanpakutoEquippedEvent:FireClient(Player, PlayerZanpakuto)
    
        PlayerZanpakuto.Parent = Character
        PlayerWeapons[Player] = PlayerZanpakuto -- to destroy later
    
        Humanoid.WalkSpeed = 16
    end)
end

local function DestroyWeapon(Player:Player, PlayerZanpakuto:Model)
    local Character = Player.Character or Player.CharacterAdded:Wait()
    local Humanoid = Character:WaitForChild("Humanoid")::Humanoid

    local PlayerZanpakutoHolster:Accessory
    local IsCooldown: boolean = CooldowHandler.CheckCooldown(Player, 1.5, LastEquip)
    if IsCooldown then return end
    
    if PlayerZanpakuto and PlayerZanpakuto:IsA("Model") then
        PlayerZanpakuto:Destroy()
        PlayerWeapons[Player] = nil
    end

    PlayerStateController.EnablePlayerState(Player, "Unarmed")
    
    PlayerZanpakutoHolster = ZanpakutoHolster:Clone()
    Humanoid:AddAccessory(PlayerZanpakutoHolster)

    PlayerHolsters[Player] = PlayerZanpakutoHolster -- to destroy later
end

function module.Start() 
    
    WeaponEquipEvent.OnServerEvent:Connect(function(Player: Player, ...)
        -- if armed, create weapon & destroy holster
        -- if unarmed, destroy weapon & create holster
        -- other state = skip
        if PlayerStateController.GetPlayerState(Player, "Armed") == true then
            DestroyWeapon(Player, PlayerWeapons[Player])
        elseif PlayerStateController.GetPlayerState(Player, "Unarmed") == true then
            CreateWeapon(Player, PlayerHolsters[Player])
        else
            return
        end
    end)

    --// Cleanup
    Players.PlayerRemoving:Connect(function(Player:Player)
        PlayerHolsters[Player] = nil
        PlayerWeapons[Player] = nil
    end)
end

return module
