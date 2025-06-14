-- Noclip Toggle Script

-- Local player and services
local player = game.Players.LocalPlayer
local runService = game:GetService("RunService")

-- Toggle state and connection variable
local noclipEnabled = _G.noclipEnabled or false
local noclipConnection = _G.noclipConnection

-- Function to handle noclip
local function onNoclip()
    if noclipEnabled and player and player.Character then
        for _, part in ipairs(player.Character:GetDescendants()) do
            if part:IsA("BasePart") and part.CanCollide then
                part.CanCollide = false
            end
        end
    end
end

-- Toggle noclip state
if noclipEnabled then
    -- Disable noclip
    if noclipConnection then
        noclipConnection:Disconnect()
        noclipConnection = nil
    end
    for _, part in ipairs(player.Character:GetDescendants()) do
        if part:IsA("BasePart") then
            part.CanCollide = true
        end
    end
    noclipEnabled = false
else
    -- Enable noclip
    noclipConnection = runService.Stepped:Connect(onNoclip)
    noclipEnabled = true
end

-- Store the state and connection globally
_G.noclipEnabled = noclipEnabled
_G.noclipConnection = noclipConnection
