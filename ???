local TAB_NAME = "Auto Purchase" -- The name of your tab in the _G.Slapper UI

-- Roblox Services
local UIS = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local Player = Players.LocalPlayer
local TweenService = game:GetService("TweenService")

-- Custom Modules/Events (Assumed to be in ReplicatedStorage)
local DataService = require(ReplicatedStorage.Modules.DataService)
local BuySeedStockEvent = ReplicatedStorage.GameEvents.BuySeedStock
local BuyEventSeedStockEvent = ReplicatedStorage.GameEvents.BuyEventShopStock
local SeedData = require(ReplicatedStorage.Data.SeedData)
local EventData = require(ReplicatedStorage.Data.HoneyEventShopData)

-- UI Constants for easy customization - Refined Palette
local UI_COLORS = {
    BackgroundPrimary = Color3.fromRGB(28, 28, 38), -- Deeper dark background for elements
    BackgroundSecondary = Color3.fromRGB(40, 40, 55), -- For panels/sections and dropdown headers
    AccentGreen = Color3.fromRGB(0, 190, 100), -- Brighter, more vibrant green for active states
    AccentBlue = Color3.fromRGB(70, 150, 255), -- For highlights/secondary accents (not used directly in this version but good to have)
    TextPrimary = Color3.fromRGB(240, 240, 240), -- Main text color
    TextSecondary = Color3.fromRGB(180, 180, 180), -- Secondary text color (e.g., dropdown arrow)
    Border = Color3.fromRGB(60, 60, 75), -- Border color for frames
    DropdownOptionHover = Color3.fromRGB(60, 60, 80), -- Hover color for dropdown options
    ToggleOff = Color3.fromRGB(70, 70, 90), -- Background color for off toggle
}

local UI_SIZES = {
    MainPadding = 12,
    SectionSpacing = 10, -- Spacing between major UI sections (e.g., panels)
    ElementPadding = 5, -- Tighter padding within sections
    CornerRadius = UDim.new(0, 8), -- Standard corner radius for panels
    SmallCornerRadius = UDim.new(0, 5), -- Smaller corner radius for dropdown options
    HeaderHeight = 32, -- Height for dropdown headers
    DropdownOptionHeight = 26, -- Height for each option in a dropdown list
    DropdownMaxHeight = 150, -- Maximum height of a dropdown list before scrolling
    ToggleWidth = 46, -- Width of the auto-buy toggle switch
    ToggleHeight = 24, -- Height of the auto-buy toggle switch
    LabelHeight = 16, -- Explicit height for smaller labels (e.g., dropdown titles)
    TitleHeight = 25, -- Height for the main title label
}

-- Gradients for polished look
local UI_GRADIENTS = {
    Panel = {
        Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, UI_COLORS.BackgroundSecondary),
            ColorSequenceKeypoint.new(1, UI_COLORS.BackgroundPrimary)
        }),
        Rotation = 90
    },
    AccentButton = {
        Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, UI_COLORS.AccentGreen),
            ColorSequenceKeypoint.new(1, UI_COLORS.AccentGreen:lerp(Color3.new(0,0,0), 0.2)) -- Slightly darker green at bottom
        }),
        Rotation = 90
    }
}

-- Internal State Variables
local selectedNormalSeeds = {} -- Stores selected normal seeds (key = seedName, value = true/false)
local selectedEventSeeds = {} -- Stores selected event seeds (key = seedName, value = true/false)
local autoBuyEnabled = false -- Current state of the auto-buy toggle

-- List to keep track of all dropdowns for managing their visibility (e.g., closing others)
local AllDropdowns = {}

--===================================================================================================
-- HELPER FUNCTIONS (UI Creation)
--===================================================================================================

-- Function to create a standard UICorner
local function _createUICorner(parent, radius)
    local corner = Instance.new("UICorner")
    corner.CornerRadius = radius or UI_SIZES.CornerRadius
    corner.Parent = parent
    return corner
end

-- Function to create a standard UIStroke (border)
local function _createUIStroke(parent, color, thickness)
    local stroke = Instance.new("UIStroke")
    stroke.Color = color or UI_COLORS.Border
    stroke.Thickness = thickness or 1.5
    stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    stroke.LineJoinMode = Enum.LineJoinMode.Round -- Smoother corners for stroke
    stroke.Parent = parent
    return stroke
end

-- Function to apply a UIGradient to an element
local function _applyUIGradient(element, gradientData)
    local gradient = Instance.new("UIGradient")
    gradient.Color = gradientData.Color
    gradient.Rotation = gradientData.Rotation
    gradient.Parent = element
    return gradient
end

-- Function to create a section title label
local function _createSectionTitle(parent, text, layoutOrder, isMainTitle)
    local label = Instance.new("TextLabel")
    label.Text = text
    label.Font = Enum.Font.GothamBold
    label.TextSize = isMainTitle and 20 or 14 -- Larger for main title, smaller for sub-titles/labels
    label.TextColor3 = UI_COLORS.TextPrimary
    label.BackgroundTransparency = 1
    label.TextXAlignment = Enum.TextXAlignment.Left
    -- Size and Position adapted for being placed within a panel/frame
    label.Size = UDim2.new(1, -UI_SIZES.ElementPadding * 2, 0, isMainTitle and UI_SIZES.TitleHeight or UI_SIZES.LabelHeight)
    label.Position = UDim2.new(0, UI_SIZES.ElementPadding, 0, 0)
    label.LayoutOrder = layoutOrder
    label.Parent = parent
    return label
end

-- Function to create a generic UI panel with styling
local function _createPanel(parent, size, layoutOrder)
    local panel = Instance.new("Frame")
    panel.Size = size
    panel.BackgroundColor3 = UI_COLORS.BackgroundSecondary
    panel.BackgroundTransparency = 0
    panel.LayoutOrder = layoutOrder
    panel.Parent = parent
    _createUICorner(panel)
    _createUIStroke(panel)
    _applyUIGradient(panel, UI_GRADIENTS.Panel)
    return panel
end

-- Function to create the custom toggle switch UI elements
local function _createToggle(parent)
    local toggleWrapper = Instance.new("Frame")
    toggleWrapper.Size = UDim2.new(0, UI_SIZES.ToggleWidth, 0, UI_SIZES.ToggleHeight)
    toggleWrapper.BackgroundColor3 = UI_COLORS.ToggleOff -- Default off state
    toggleWrapper.Parent = parent
    _createUICorner(toggleWrapper, UDim.new(1, 0)) -- Fully rounded
    _createUIStroke(toggleWrapper, UI_COLORS.Border, 1)

    local toggleCircle = Instance.new("Frame")
    toggleCircle.Size = UDim2.new(0, UI_SIZES.ToggleHeight * 0.7, 0, UI_SIZES.ToggleHeight * 0.7)
    -- Initial position for 'off' state (left side)
    toggleCircle.Position = UDim2.new(0, UI_SIZES.ToggleHeight * 0.15, 0.5, -(UI_SIZES.ToggleHeight * 0.7) / 2)
    toggleCircle.BackgroundColor3 = UI_COLORS.TextPrimary
    toggleCircle.BorderSizePixel = 0
    toggleCircle.ZIndex = 2 -- Ensure circle is above wrapper
    toggleCircle.Parent = toggleWrapper
    _createUICorner(toggleCircle, UDim.new(1, 0)) -- Fully rounded
    _createUIStroke(toggleCircle, UI_COLORS.Border, 1)

    return toggleWrapper, toggleCircle
end

-- Function to create a custom dropdown (Self-contained logic for its behavior)
local function _createDropdown(parentFrame, externalLabelText, data, selectionTable)
    local dropdownGroup = Instance.new("Frame")
    dropdownGroup.Name = externalLabelText:gsub(" ", "") .. "DropdownGroup"
    -- Initial size for the group; will be managed by AutomaticSize.Y
    dropdownGroup.Size = UDim2.new(0.49, 0, 0, UI_SIZES.HeaderHeight + UI_SIZES.ElementPadding / 2 + UI_SIZES.LabelHeight)
    dropdownGroup.BackgroundTransparency = 1
    dropdownGroup.AutomaticSize = Enum.AutomaticSize.Y -- Crucial for group to expand/collapse
    dropdownGroup.Parent = parentFrame

    local groupLayout = Instance.new("UIListLayout")
    groupLayout.FillDirection = Enum.FillDirection.Vertical
    groupLayout.HorizontalAlignment = Enum.HorizontalAlignment.Left
    groupLayout.Padding = UDim.new(0, UI_SIZES.ElementPadding / 2)
    groupLayout.Parent = dropdownGroup

    -- External label for the dropdown
    _createSectionTitle(dropdownGroup, externalLabelText, 1, false)

    -- Wrapper frame for the dropdown header and list
    local wrapper = Instance.new("Frame")
    wrapper.Name = externalLabelText:gsub(" ", "") .. "DropdownWrapper"
    wrapper.Size = UDim2.new(1, 0, 0, UI_SIZES.HeaderHeight) -- Start at header height
    wrapper.BackgroundColor3 = UI_COLORS.BackgroundSecondary
    wrapper.ClipsDescendants = true -- Important to hide list when collapsed
    wrapper.AutomaticSize = Enum.AutomaticSize.None -- Size controlled by tweens
    wrapper.Parent = dropdownGroup
    wrapper.LayoutOrder = 2
    _createUICorner(wrapper)
    _createUIStroke(wrapper)

    -- Dropdown Header Button (Clickable area)
    local headerButton = Instance.new("TextButton")
    headerButton.Name = "HeaderButton"
    headerButton.Size = UDim2.new(1, 0, 0, UI_SIZES.HeaderHeight)
    headerButton.BackgroundTransparency = 1
    headerButton.Text = ""
    headerButton.Parent = wrapper

    local headerListLayout = Instance.new("UIListLayout")
    headerListLayout.FillDirection = Enum.FillDirection.Horizontal
    headerListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    headerListLayout.VerticalAlignment = Enum.VerticalAlignment.Center
    headerListLayout.Padding = UDim.new(0, UI_SIZES.ElementPadding / 2)
    headerListLayout.Parent = headerButton

    local countLabel = Instance.new("TextLabel")
    countLabel.Name = "CountLabel"
    countLabel.Size = UDim2.new(1, -UI_SIZES.HeaderHeight * 0.7, 1, 0) -- Text fills most of header
    countLabel.BackgroundTransparency = 1
    countLabel.Text = "Select Items"
    countLabel.Font = Enum.Font.Gotham
    countLabel.TextSize = 14
    countLabel.TextColor3 = UI_COLORS.TextPrimary
    countLabel.TextXAlignment = Enum.TextXAlignment.Left
    countLabel.Parent = headerButton

    local dropdownArrow = Instance.new("ImageLabel")
    dropdownArrow.Name = "DropdownArrow"
    dropdownArrow.Size = UDim2.new(0, UI_SIZES.HeaderHeight * 0.6, 0, UI_SIZES.HeaderHeight * 0.6)
    dropdownArrow.Image = "rbxassetid://6031091002" -- Roblox asset for a down arrow
    dropdownArrow.ImageColor3 = UI_COLORS.TextSecondary
    dropdownArrow.BackgroundTransparency = 1
    dropdownArrow.Parent = headerButton
    dropdownArrow.ZIndex = 2
    dropdownArrow.Rotation = 0 -- Keep rotation at 0, no animation

    -- Dropdown List (ScrollingFrame)
    local listFrame = Instance.new("ScrollingFrame")
    listFrame.Name = "ListFrame"
    listFrame.Size = UDim2.new(1, 0, 0, 0) -- Start with height 0
    listFrame.Position = UDim2.new(0, 0, 0, UI_SIZES.HeaderHeight) -- Position directly below header
    listFrame.BackgroundColor3 = UI_COLORS.BackgroundSecondary
    listFrame.BackgroundTransparency = 0
    listFrame.ClipsDescendants = true
    listFrame.Visible = false -- Start invisible
    listFrame.CanvasSize = UDim2.new(0, 0, 0, 0) -- Will be updated dynamically
    listFrame.ScrollBarThickness = 6
    listFrame.ScrollBarImageColor3 = UI_COLORS.AccentGreen
    listFrame.Parent = wrapper
    _createUICorner(listFrame, UI_SIZES.SmallCornerRadius)
    _createUIStroke(listFrame, UI_COLORS.Border, 1)

    local listLayout = Instance.new("UIListLayout")
    listLayout.SortOrder = Enum.SortOrder.LayoutOrder
    listLayout.Padding = UDim.new(0, UI_SIZES.ElementPadding / 2)
    listLayout.Parent = listFrame

    -- Function to update the text in the header button
    local function updateCountLabelText()
        local count = 0
        for _, selected in pairs(selectionTable) do
            if selected then
                count = count + 1
            end
        end
        if count > 0 then
            countLabel.Text = count .. " Items Selected"
        else
            countLabel.Text = "Select Items"
        end
    end

    -- TweenInfo for smooth animations
    local expandTweenInfo = TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

    -- Functions to handle dropdown opening/closing
    local function closeDropdown()
        local listTween = TweenService:Create(listFrame, expandTweenInfo, {Size = UDim2.new(1, 0, 0, 0)})
        listTween:Play()

        listTween.Completed:Wait() -- Wait for the list to collapse before hiding
        listFrame.Visible = false

        -- Tween wrapper and group height back to header height
        TweenService:Create(wrapper, expandTweenInfo, {Size = UDim2.new(1, 0, 0, UI_SIZES.HeaderHeight)}):Play()
        TweenService:Create(dropdownGroup, expandTweenInfo, {Size = UDim2.new(dropdownGroup.Size.X.Scale, dropdownGroup.Size.X.Offset, 0, UI_SIZES.HeaderHeight + UI_SIZES.ElementPadding / 2 + UI_SIZES.LabelHeight)}):Play()
    end

    local function openDropdown()
        -- Close all other dropdowns before opening this one
        for _, dd in ipairs(AllDropdowns) do
            if dd.Wrapper ~= wrapper and dd.ListFrame.Visible then
                dd.CloseFunc()
            end
        end

        listFrame.Visible = true -- Make visible immediately
        -- Calculate content height dynamically based on number of options
        local numItems = #listFrame:GetChildren() - 1 -- Subtract 1 for the UIListLayout
        local contentHeight = numItems * UI_SIZES.DropdownOptionHeight + (numItems > 0 and (numItems - 1) * listLayout.Padding.Offset or 0)
        local targetListHeight = math.min(UI_SIZES.DropdownMaxHeight, contentHeight)

        -- Set CanvasSize to the *full* content height, allowing scrolling
        listFrame.CanvasSize = UDim2.new(0, 0, 0, contentHeight) -- Fix for scrollability

        -- Tween ListFrame height
        TweenService:Create(listFrame, expandTweenInfo, {Size = UDim2.new(1, 0, 0, targetListHeight)}):Play()

        -- Tween wrapper and group height to accommodate the list
        TweenService:Create(wrapper, expandTweenInfo, {Size = UDim2.new(1, 0, 0, UI_SIZES.HeaderHeight + targetListHeight)}):Play()
        TweenService:Create(dropdownGroup, expandTweenInfo, {Size = UDim2.new(dropdownGroup.Size.X.Scale, dropdownGroup.Size.X.Offset, 0, UI_SIZES.HeaderHeight + UI_SIZES.ElementPadding / 2 + UI_SIZES.LabelHeight + targetListHeight)}):Play()
    end

    -- Store dropdown info for global management
    table.insert(AllDropdowns, {
        Wrapper = wrapper,
        ListFrame = listFrame,
        Arrow = dropdownArrow,
        CloseFunc = closeDropdown,
        OpenFunc = openDropdown
    })

    -- Header Button Click Connection
    headerButton.MouseButton1Click:Connect(function()
        if listFrame.Visible then
            closeDropdown()
        else
            openDropdown()
        end
    end)

    -- Populate dropdown list with options
    local orderedItems = {}
    for itemName, itemInfo in pairs(data) do
        if itemInfo and itemInfo.DisplayInShop then -- Only display items marked for shop
            table.insert(orderedItems, {Name = itemName, Info = itemInfo})
        end
    end

    -- Sort items by LayoutOrder for consistent display
    table.sort(orderedItems, function(a, b)
        return (a.Info.LayoutOrder or 0) < (b.Info.LayoutOrder or 0)
    end)

    for _, item in ipairs(orderedItems) do
        local itemName = item.Name
        local option = Instance.new("TextButton")
        option.Size = UDim2.new(1, -UI_SIZES.ElementPadding * 2, 0, UI_SIZES.DropdownOptionHeight)
        option.Position = UDim2.new(0, UI_SIZES.ElementPadding, 0, 0)
        option.BackgroundColor3 = UI_COLORS.BackgroundPrimary
        option.TextColor3 = UI_COLORS.TextPrimary
        option.Text = item.Info.SeedName or itemName -- Use SeedName if available, else itemName
        option.Font = Enum.Font.Gotham
        option.TextSize = 14
        option.BorderSizePixel = 0
        option.TextXAlignment = Enum.TextXAlignment.Left
        option.TextWrapped = true
        option.Parent = listFrame
        _createUICorner(option, UI_SIZES.SmallCornerRadius)
        _createUIStroke(option, UI_COLORS.Border, 1)

        -- Function to update the visual state of an individual dropdown option
        local function updateOptionVisual()
            if selectionTable[itemName] then
                option.BackgroundColor3 = UI_COLORS.AccentGreen
                _applyUIGradient(option, UI_GRADIENTS.AccentButton)
                option.TextColor3 = Color3.new(1,1,1) -- White text on green
                option.TextStrokeTransparency = 0.8
                option.TextStrokeColor3 = Color3.new(0,0,0)
            else
                option.BackgroundColor3 = UI_COLORS.BackgroundPrimary
                -- Remove any gradients if unselected
                for _, g in ipairs(option:GetChildren()) do if g:IsA("UIGradient") then g:Destroy() end end
                option.TextColor3 = UI_COLORS.TextPrimary
                option.TextStrokeTransparency = 1
            end
        end

        option.MouseButton1Click:Connect(function()
            selectionTable[itemName] = not selectionTable[itemName] -- Toggle selection
            updateOptionVisual()
            updateCountLabelText()
        end)

        option.MouseEnter:Connect(function()
            if not selectionTable[itemName] then -- Only change color if not already selected
                option.BackgroundColor3 = UI_COLORS.DropdownOptionHover
            end
        end)

        option.MouseLeave:Connect(function()
            if not selectionTable[itemName] then
                updateOptionVisual() -- Revert to default if not selected
            end
        end)

        updateOptionVisual() -- Initial visual update for each option
    end

    updateCountLabelText() -- Initial text for header
    return dropdownGroup
end

--===================================================================================================
-- MAIN UI LAYOUT & CONSTRUCTION
--===================================================================================================

-- Function to set up the main container for the UI tab
local function _createMainContainer()
    local container = _G.Slapper.TabContent[TAB_NAME] -- Reference the global container
    if not container then
        -- If container doesn't exist, create it (handles initial setup)
        container = Instance.new("Frame")
        container.Name = TAB_NAME .. "_Container"
        container.Size = UDim2.new(1, -UI_SIZES.MainPadding * 2, 1, -UI_SIZES.MainPadding * 4) -- Adjusted for global UI
        container.Position = UDim2.new(0, UI_SIZES.MainPadding, 0, UI_SIZES.MainPadding * 2)
        container.BackgroundTransparency = 1
        container.Visible = false -- Hidden by default
        container.Parent = _G.Slapper.UI.Content -- Parent to the main content area
        _G.Slapper.TabContent[TAB_NAME] = container
    end

    -- Clear existing children to prevent duplicates on re-creation/refresh
    for _, child in ipairs(container:GetChildren()) do
        child:Destroy()
    end

    local layout = Instance.new("UIListLayout")
    layout.Padding = UDim.new(0, UI_SIZES.SectionSpacing)
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Parent = container

    return container
end

local container = _createMainContainer() -- Create/get the main container

-- Unified Controls Panel (Holds all primary UI elements)
local unifiedControlsPanel = _createPanel(container, UDim2.new(1, 0, 0, 0), 1) -- Height 0, will auto-size
unifiedControlsPanel.ClipsDescendants = true
unifiedControlsPanel.AutomaticSize = Enum.AutomaticSize.Y -- Panel dynamically sizes vertically

local unifiedControlsLayout = Instance.new("UIListLayout")
unifiedControlsLayout.FillDirection = Enum.FillDirection.Vertical
unifiedControlsLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center -- Center all contents
unifiedControlsLayout.VerticalAlignment = Enum.VerticalAlignment.Top
unifiedControlsLayout.SortOrder = Enum.SortOrder.LayoutOrder
unifiedControlsLayout.Padding = UDim.new(0, UI_SIZES.ElementPadding * 1.5) -- Spacing between internal sections
unifiedControlsLayout.Parent = unifiedControlsPanel

-- Main Title within the panel
_createSectionTitle(unifiedControlsPanel, "Seed Auto Purchaser", 1, true)

-- Dropdowns Row (Holds both dropdown groups horizontally)
local dropdownsRow = Instance.new("Frame")
dropdownsRow.Name = "DropdownsRow"
dropdownsRow.Size = UDim2.new(1, -UI_SIZES.ElementPadding * 2, 0, 0) -- Width takes panel width, height automatic
dropdownsRow.BackgroundTransparency = 1
dropdownsRow.LayoutOrder = 2
dropdownsRow.Parent = unifiedControlsPanel
dropdownsRow.AutomaticSize = Enum.AutomaticSize.Y -- This row will size itself based on its children

local dropdownsRowLayout = Instance.new("UIListLayout")
dropdownsRowLayout.FillDirection = Enum.FillDirection.Horizontal
dropdownsRowLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
dropdownsRowLayout.VerticalAlignment = Enum.VerticalAlignment.Top -- Align dropdown groups to top
dropdownsRowLayout.SortOrder = Enum.SortOrder.LayoutOrder
dropdownsRowLayout.Padding = UDim.new(0, UI_SIZES.ElementPadding * 2) -- Spacing between dropdown groups
dropdownsRowLayout.Parent = dropdownsRow

-- Create and add Normal Seeds dropdown
_createDropdown(dropdownsRow, "Normal Seeds", SeedData, selectedNormalSeeds)
-- Create and add Event Seeds dropdown
_createDropdown(dropdownsRow, "Event Seeds", EventData, selectedEventSeeds)

-- Auto Buy Toggle Row (Placed at the bottom-left of the panel)
local toggleRow = Instance.new("Frame")
toggleRow.Name = "AutoBuyToggleRow"
toggleRow.Size = UDim2.new(1, -UI_SIZES.ElementPadding * 2, 0, UI_SIZES.ToggleHeight) -- Fixed height for the toggle
toggleRow.BackgroundTransparency = 1
toggleRow.LayoutOrder = 3
toggleRow.Parent = unifiedControlsPanel

local toggleRowLayout = Instance.new("UIListLayout")
toggleRowLayout.FillDirection = Enum.FillDirection.Horizontal
toggleRowLayout.HorizontalAlignment = Enum.HorizontalAlignment.Left -- Align content to the left
toggleRowLayout.VerticalAlignment = Enum.VerticalAlignment.Center
toggleRowLayout.Padding = UDim.new(0, UI_SIZES.ElementPadding)
toggleRowLayout.Parent = toggleRow

local toggleLabel = Instance.new("TextLabel")
toggleLabel.Text = "Auto-Buy"
toggleLabel.Font = Enum.Font.GothamBold
toggleLabel.TextSize = 16
toggleLabel.TextColor3 = UI_COLORS.TextPrimary
toggleLabel.BackgroundTransparency = 1
toggleLabel.Size = UDim2.new(0, 80, 1, 0) -- Fixed width for label
toggleLabel.TextXAlignment = Enum.TextXAlignment.Left
toggleLabel.Parent = toggleRow

-- Create the toggle switch UI
local toggleWrapper, toggleCircle = _createToggle(toggleRow)

-- Function to update the visual state of the toggle
local function _updateToggleVisual(state)
    toggleWrapper.BackgroundColor3 = state and UI_COLORS.AccentGreen or UI_COLORS.ToggleOff
    -- Remove any existing gradients before applying a new one
    for _, g in ipairs(toggleWrapper:GetChildren()) do if g:IsA("UIGradient") then g:Destroy() end end
    if state then
        _applyUIGradient(toggleWrapper, UI_GRADIENTS.AccentButton)
    end
    -- Tween the circle's position
    local targetPosition = state and UDim2.new(1, -(UI_SIZES.ToggleHeight * 0.7 + UI_SIZES.ToggleHeight * 0.15), 0.5, -(UI_SIZES.ToggleHeight * 0.7) / 2) or UDim2.new(0, UI_SIZES.ToggleHeight * 0.15, 0.5, -(UI_SIZES.ToggleHeight * 0.7) / 2)
    TweenService:Create(toggleCircle, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Position = targetPosition}):Play()
end

-- Toggle switch click handler
toggleWrapper.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        -- Only allow toggling if at least one item type is selected
        if next(selectedNormalSeeds) or next(selectedEventSeeds) then
            autoBuyEnabled = not autoBuyEnabled
            _updateToggleVisual(autoBuyEnabled)
            if autoBuyEnabled then
                _G.Slapper:Notify("Auto-Buy Enabled!", "Items will now be automatically purchased.", 3, "Success")
            else
                _G.Slapper:Notify("Auto-Buy Disabled!", "Automatic item purchase has been stopped.", 3, "Warning")
            end
        else
            _G.Slapper:Notify("Error", "Please select at least one item type to enable auto-buy.", 3, "Warning")
        end
    end
end)

_updateToggleVisual(autoBuyEnabled) -- Initialize toggle visual state on script start

--===================================================================================================
-- CORE LOGIC
--===================================================================================================

-- Auto-Buy Loop
spawn(function()
    while task.wait(0.25) do -- Efficient loop
        if autoBuyEnabled then
            local success, data = pcall(DataService.GetData, DataService) -- Safely call DataService
            if success and data then
                local itemsBoughtThisCycle = false

                -- Purchase Normal Seeds
                for seedName, stockInfo in pairs(data.SeedStock and data.SeedStock.Stocks or {}) do
                    if selectedNormalSeeds[seedName] and stockInfo.Stock > 0 then
                        for i = 1, stockInfo.Stock do -- Attempt to buy all available stock
                            BuySeedStockEvent:FireServer(seedName)
                            itemsBoughtThisCycle = true
                            task.wait(0.05) -- Small delay between purchases
                        end
                    end
                end

                -- Purchase Event Seeds
                for seedName, stockInfo in pairs(data.EventShopStock and data.EventShopStock.Stocks or {}) do
                    if selectedEventSeeds[seedName] and stockInfo.Stock > 0 then
                        for i = 1, stockInfo.Stock do -- Attempt to buy all available stock
                            BuyEventSeedStockEvent:FireServer(seedName)
                            itemsBoughtThisCycle = true
                            task.wait(0.05) -- Small delay between purchases
                        end
                    end
                end

                -- Optional: Notification if items were bought (can be noisy, disabled by default)
                -- if itemsBoughtThisCycle then
                -- _G.Slapper:Notify("Items Acquired!", "New stock of selected items purchased.", 1, "Success")
                -- end
            else
                warn("Failed to get data from DataService. Auto-buy might be interrupted.")
            end
        end
    end
end)

-- Global click handler to close dropdowns when clicking outside
UIS.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end -- Ignore if game UI already handled it
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        local mousePos = UIS:GetMouseLocation()
        for _, dd in ipairs(AllDropdowns) do
            if dd.ListFrame.Visible then
                local headerButton = dd.Wrapper:FindFirstChild("HeaderButton")
                -- Get absolute screen positions for hit-testing
                local headerBoundsMin = headerButton.AbsolutePosition
                local headerBoundsMax = headerButton.AbsolutePosition + headerButton.AbsoluteSize
                local listBoundsMin = dd.ListFrame.AbsolutePosition
                local listBoundsMax = dd.ListFrame.AbsolutePosition + dd.ListFrame.AbsoluteSize

                local clickedInsideHeader = (mousePos.X >= headerBoundsMin.X and mousePos.X <= headerBoundsMax.X and
                                             mousePos.Y >= headerBoundsMin.Y and mousePos.Y <= headerBoundsMax.Y)
                local clickedInsideList = (mousePos.X >= listBoundsMin.X and mousePos.X <= listBoundsMax.X and
                                           mousePos.Y >= listBoundsMin.Y and mousePos.Y <= listBoundsMax.Y)

                if not clickedInsideHeader and not clickedInsideList then
                    dd.CloseFunc() -- Call the stored close function
                end
            end
        end
    end
end)

-- Hook up the tab button in _G.Slapper framework
local tabButton = _G.Slapper.UI.Sidebar:FindFirstChild(TAB_NAME:gsub(" ", ""))
if tabButton then
    tabButton.MouseButton1Click:Connect(function()
        -- Close all dropdowns when switching tabs
        for _, dd in ipairs(AllDropdowns) do
            if dd.ListFrame.Visible then
                dd.CloseFunc()
            end
        end
        -- Hide all other tab content
        for _, v in pairs(_G.Slapper.TabContent) do
            v.Visible = false
        end
        _G.Slapper.UI.Info.Visible = false -- Assuming this is another info panel
        container.Visible = true -- Make this tab's content visible
    end)
else
    warn("Tab button '" .. TAB_NAME:gsub(" ", "") .. "' not found in sidebar. Ensure _G.Slapper UI setup is correct.")
end
