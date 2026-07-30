--// Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

--// Connections
local Connections = ReplicatedStorage.Connections
local PlayerStateConnections = Connections.PlayerStateConnections
local StateEnabledEvent: RemoteEvent = PlayerStateConnections.StateEnabledEvent

--// Animations
local AnimationsFolder = ReplicatedStorage.Animations
local ZanpakutoAnimations = AnimationsFolder.ZanpakutoAnimations
local IdleAnim: Animation = ZanpakutoAnimations.IdleAnim
local WalkAnim: Animation = ZanpakutoAnimations.WalkAnim

--// Main
local module = {}

local Player = Players.LocalPlayer

function module.Start()
    local Character = Player.Character or Player.CharacterAdded:Wait()
    local AnimateScript = Character:WaitForChild("Animate", 5) -- this is where default walk, idle, swim, etc Roblox anims are located
    
    if not AnimateScript then 
        warn("Animate script not found in Character!") 
        return 
    end

    -- the normal ids if aren't armed
    local DefaultWalkId = AnimateScript.walk.WalkAnim.AnimationId
    local DefaultIdleId = AnimateScript.idle.Animation1.AnimationId

    StateEnabledEvent.OnClientEvent:Connect(function(StateName: string)
        local TargetWalkId, TargetIdleId

        if StateName == "Armed" then
            -- make the sure that our anims should be our custom ones
            TargetWalkId = WalkAnim.AnimationId
            TargetIdleId = IdleAnim.AnimationId
        elseif StateName == "Unarmed" then
            -- make suer they are normal
            TargetWalkId = DefaultWalkId
            TargetIdleId = DefaultIdleId
        else
            return 
        end

        -- make the anims the targetted ones
        AnimateScript.walk.WalkAnim.AnimationId = TargetWalkId
        AnimateScript.idle.Animation1.AnimationId = TargetIdleId

        -- delay for swaps
        local Humanoid = Character:FindFirstChildOfClass("Humanoid")
        if Humanoid then
            local Animator = Humanoid:FindFirstChildOfClass("Animator")
            if Animator then
                for _, Track in ipairs(Animator:GetPlayingAnimationTracks()) do
                    if Track.Name == "WalkAnim" or Track.Name == "Animation1" or Track.Name == "Idle" or Track.Name == "Walk" then
                        Track:Stop(0.1)
                    end
                end
            end
        end
    end)

end

return module
