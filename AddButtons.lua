local TAB_NAME = "Auto Buy"  -- with space to match TAB_NAMES

-- Get container or create it
local container = _G.SlapperTabContent[TAB_NAME]
if not container then
    container = Instance.new("Frame")
    container.Name = TAB_NAME .. "_Container"
    container.Size = UDim2.new(1, -40, 1, -60)
    container.Position = UDim2.new(0, 20, 0, 50)
    container.BackgroundTransparency = 1
    container.Visible = false
    container.Parent = _G.SlapperContent
    Instance.new("UIListLayout", container).Padding = UDim.new(0, 8)
    _G.SlapperTabContent[TAB_NAME] = container
end

-- Create toggle button inside container
local toggleButton = container:FindFirstChild("AutoBuyToggle")
if not toggleButton then
    toggleButton = Instance.new("TextButton")
    toggleButton.Name = "AutoBuyToggle"
    toggleButton.Size = UDim2.new(0, 160, 0, 36)
    toggleButton.Text = "Auto Buy: OFF"
    -- configure other properties...
    toggleButton.Parent = container
    -- add click handler etc
end

-- Find the tab button by removing spaces from TAB_NAME
local tabButton = _G.SlapperSidebar:FindFirstChild(TAB_NAME:gsub(" ", ""))
if tabButton then
    tabButton.MouseButton1Click:Connect(function()
        -- hide others, show container etc
        for _, v in pairs(_G.SlapperTabContent) do
            v.Visible = false
        end
        container.Visible = true
    end)
else
    warn("Tab button '" .. TAB_NAME:gsub(" ", "") .. "' not found in sidebar")
end
