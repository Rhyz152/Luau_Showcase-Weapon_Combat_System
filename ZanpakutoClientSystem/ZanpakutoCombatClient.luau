--// Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterPlayer = game:GetService("StarterPlayer")
local Players = game:GetService("Players")

--// Connections
local Connections = ReplicatedStorage.Connections
local CombatConnections = Connections.CombatConnections
local ClientMeleeRequest: RemoteFunction = CombatConnections.ClientMeleeRequest
local HitboxDetectionRequest: RemoteFunction = CombatConnections.HitboxDetectionRequest

--// Animations
local AnimationsFolder = ReplicatedStorage.Animations
local ZanpakutoAnimations = AnimationsFolder.ZanpakutoAnimations
local StunAnim: Animation = ZanpakutoAnimations.StunAnim

--// Client Utils
local ClientUtils = StarterPlayer.StarterPlayerScripts.Client.ClientUtils
local HitboxUtils = ClientUtils.HitboxCreationUtils
local InputUtils = ClientUtils.InputUtils

local HitboxCreationHandler = require(HitboxUtils.HitboxCreationHandler)
local InputDetectionHandler = require(InputUtils.InputDetectionHandler)

--// Shared
local Shared = ReplicatedStorage.Shared
local SharedUtils = Shared.SharedUtils
local VFXUtils = SharedUtils.VFXUtils
local SFXUtils = SharedUtils.SFXUtils
local AnimationUtils = SharedUtils.AnimationUtils
local VFXHandler = require(VFXUtils.VFXHandler)
local SFXHandler = require(SFXUtils.SFXHandler)
local AnimationHandler = require(AnimationUtils.AnimationHandler)
local SharedDataModules = Shared.SharedDataModules
local CombatData = require(SharedDataModules.CombatDataModules.CombatData)

--// Main
local module = {}

function module.Start()
    --// Player Variables
    local Player: Player = Players.LocalPlayer
    local Character: Model = Player.Character or Player.CharacterAdded:Wait()
    local Humanoid = Character:WaitForChild("Humanoid")::Humanoid

    -- handles input, obv
    InputDetectionHandler.InputTypeDetection(Enum.UserInputType.MouseButton1, function()
        local ServerValidation: boolean, CombatDataKey = ClientMeleeRequest:InvokeServer(Player)
            
        -- isn't it obvious
        if not ServerValidation then
            return
        end
        
        -- basically, if there is no data
        if typeof(CombatDataKey) ~= "table" then
            return
        end

        -- Hitbox properties - making it a type so they have some required props
        type HitboxProps = {
            Size: Vector3,
            Cframe: CFrame,
            Transparency: number,
            Color: Color3,
            LifeTime: number,
        }
        local NormalHitboxProps: HitboxProps = {
            Size = Vector3.new(5, 6, 5),
            Cframe = CFrame.new(0, 0, -3),
            Transparency = 0.5,
            Color = Color3.fromRGB(255, 0, 0),
            LifeTime = 0.65,
        }
        local FinisherHitboxProps: HitboxProps = {
            Size = Vector3.new(7, 6, 7),
            Cframe = CFrame.new(0, 0, -3),
            Transparency = 0.5,
            Color = Color3.fromRGB(255, 0, 0),
            LifeTime = 0.65,
        }

        -- calback if an animation event is reached
        AnimationHandler.LoadAnimation(Character, "Combat-Swing", CombatDataKey.AnimationId, function(MarkerName)
            Humanoid.WalkSpeed = 0

            -- decide whether its the last swing or not, create hitbox with its props to the hitbox props specified (if its a finisher swing then it applies finisher hitbox props, else is obvious)
            local Hitbox: BasePart
            if CombatDataKey.Name ~= CombatData.FinisherSwing.Name then
                Hitbox = HitboxCreationHandler.Construct(NormalHitboxProps.Size, NormalHitboxProps.Cframe, NormalHitboxProps.Transparency, NormalHitboxProps.Color, NormalHitboxProps.LifeTime)
            else
                Hitbox = HitboxCreationHandler.Construct(FinisherHitboxProps.Size, FinisherHitboxProps.Cframe, FinisherHitboxProps.Transparency, FinisherHitboxProps.Color, FinisherHitboxProps.LifeTime)
            end

            -- lets everything else runs
            task.delay(0.5, function()
                Humanoid.WalkSpeed = 16
            end)

            local SlashVfx: BasePart = CombatDataKey.VFXPart
            local SlashSfx: Sound = CombatDataKey.SlashSound
            local HitVfx: BasePart = CombatDataKey.HitVFX
            local HitSfx: Sound = CombatDataKey.HitSound
    
            print(SlashVfx, SlashSfx) -- debug

            -- handles cloning and parenting and playing vfx and sfx (but isn't the best thing to do)
            VFXHandler.LoadVFX(SlashVfx, Hitbox, 1)
            SFXHandler.LoadSFX(SlashSfx, Hitbox)

            local Offset = (CombatDataKey.Name ~= CombatData.FinisherSwing.Name) and NormalHitboxProps.Cframe or FinisherHitboxProps.Cframe
            local TargetSize = (CombatDataKey.Name ~= CombatData.FinisherSwing.Name) and NormalHitboxProps.Size or FinisherHitboxProps.Size

            local RootPart = Character:FindFirstChild("HumanoidRootPart")::BasePart
            if not RootPart then return end

            local WorldCFrame = RootPart.CFrame * Offset

            local HitPart = HitboxDetectionRequest:InvokeServer(WorldCFrame, TargetSize)
            if not HitPart then return end
            
            local OtherChar = HitPart.Parent
            if not OtherChar then return end
            
            AnimationHandler.LoadAnimation(OtherChar, "StunAnim", StunAnim.AnimationId, nil)

            VFXHandler.LoadVFX(HitVfx, HitPart, 20)
            SFXHandler.LoadSFX(HitSfx, HitPart)

        end)
    end)
end

return module
