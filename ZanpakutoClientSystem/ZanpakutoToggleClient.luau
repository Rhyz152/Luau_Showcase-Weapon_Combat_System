--// Services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterPlayer = game:GetService("StarterPlayer")

--// Shared Utils
local SharedUtils = ReplicatedStorage.Shared.SharedUtils

local SFXUtils = SharedUtils.SFXUtils
local VFXUtils = SharedUtils.VFXUtils

local SFXHandler = require(SFXUtils.SFXHandler)
local VFXHandler = require(VFXUtils.VFXHandler)

--// Assets
local Assets = ReplicatedStorage.ClientAssets
local VfxAssets = Assets.VFX
local SfxAssets = Assets.SFX

local Effects = SfxAssets.Effects
local LoudSwooshSfx = Effects.LoudSwooshSFX

local ZanpakutoVFX = VfxAssets.ZanpakutoVFX
local SpawnVFX = ZanpakutoVFX.SpawnVFX

--// Client Utils
local ClientUtils = StarterPlayer.StarterPlayerScripts.Client.ClientUtils
local InputUtils = ClientUtils.InputUtils
local InputDetectionHandler = require(InputUtils.InputDetectionHandler)

--// Connections
local Connections = ReplicatedStorage.Connections
local ZanpakutoConnections = Connections.ZanpakutoConnections
local WeaponEquipEvent: RemoteEvent = ZanpakutoConnections.WeaponEquipEvent
local ZanpakutoEquippedEvent: RemoteEvent = ZanpakutoConnections.ZanpakutoEquippedEvent

--// Main
local module = {}

local Player = Players.LocalPlayer
local Character = Player.Character or Player.CharacterAdded:Wait()

function module.Start()
    InputDetectionHandler.KeycodeDetection(Enum.KeyCode.X, function()
        WeaponEquipEvent:FireServer()
    end)
    
    ZanpakutoEquippedEvent.OnClientEvent:Connect(function(Player, PlayerZanpakuto)
        if not PlayerZanpakuto then
            PlayerZanpakuto = Character.Zanpakuto
        end
        SFXHandler.LoadSFX(LoudSwooshSfx, PlayerZanpakuto.PrimaryPart)
        VFXHandler.LoadVFX(SpawnVFX, PlayerZanpakuto.PrimaryPart, 1)
    end)
end

return module
