local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
local SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/SaveManager.lua"))()
local InterfaceManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/InterfaceManager.lua"))()

local Window = Fluent:CreateWindow({
    Title = "哥斯拉皮套Hub - 第3章",
    SubTitle = "by.小梦",
    TabWidth = 160,
    Size = UDim2.fromOffset(580, 360),
    Acrylic = false,
    Theme = "Darker",
    MinimizeKey = Enum.KeyCode.LeftControl
})

Window.Root.Visible = true

local Tabs = {
    ESP = Window:AddTab({ Title = "透视", Icon = "eye" }),
    Other = Window:AddTab({ Title = "其他", Icon = "settings" })
}

do
    local CUSTOM_IMAGE = "rbxassetid://10709791437"
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "FluentFloatButton"
    screenGui.ResetOnSpawn = false
    screenGui.Parent = game:GetService("CoreGui")
    screenGui.Enabled = true

    local button = Instance.new("ImageButton")
    button.Size = UDim2.fromOffset(50, 50)
    button.Position = UDim2.fromOffset(100, 100)
    button.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    button.BackgroundTransparency = 0.2
    button.Image = CUSTOM_IMAGE
    button.ImageColor3 = Color3.fromRGB(255, 255, 255)
    button.ScaleType = Enum.ScaleType.Fit
    button.AutoButtonColor = false
    button.Parent = screenGui

    Instance.new("UICorner", button).CornerRadius = UDim.new(1, 0)
    local stroke = Instance.new("UIStroke", button)
    stroke.Thickness = 1
    stroke.Color = Color3.fromRGB(100, 100, 100)
    stroke.Transparency = 0.5

    local dragging = false
    local dragStartPos = nil
    local buttonStartPos = nil
    local uis = game:GetService("UserInputService")

    button.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStartPos = input.Position
            buttonStartPos = button.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                    dragStartPos = nil
                    buttonStartPos = nil
                end
            end)
        end
    end)

    uis.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStartPos
            button.Position = UDim2.fromOffset(
                buttonStartPos.X.Offset + delta.X,
                buttonStartPos.Y.Offset + delta.Y
            )
        end
    end)

    button.MouseButton1Click:Connect(function()
        if Window.Root then Window.Root.Visible = not Window.Root.Visible end
    end)

    button.MouseEnter:Connect(function()
        button:TweenSize(UDim2.fromOffset(55, 55), Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0.2, true)
    end)
    button.MouseLeave:Connect(function()
        button:TweenSize(UDim2.fromOffset(50, 50), Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0.2, true)
    end)
end

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local player = Players.LocalPlayer

-- ==================== 怪物透视 ====================
local monsterEspEnabled = false
local monsterHighlights = {}
local screenDistanceLabel

local monsterNames = {
    ["lunchlady"] = "午餐女士",
    ["jaguar"] = "美洲豹",
    ["ai"] = "AI守卫"
}

local function getMonsterDisplayName(actualName)
    local key = actualName:lower()
    return monsterNames[key] or actualName
end

local function createScreenGui()
    if screenDistanceLabel then return end
    local gui = Instance.new("ScreenGui")
    gui.Name = "MonsterDistances"
    gui.ResetOnSpawn = false
    gui.Parent = game:GetService("CoreGui")

    screenDistanceLabel = Instance.new("TextLabel")
    screenDistanceLabel.Size = UDim2.fromScale(1, 0)
    screenDistanceLabel.Position = UDim2.fromScale(0.5, 0.92)
    screenDistanceLabel.AnchorPoint = Vector2.new(0.5, 0)
    screenDistanceLabel.BackgroundTransparency = 1
    screenDistanceLabel.TextColor3 = Color3.fromRGB(255, 80, 80)
    screenDistanceLabel.TextStrokeTransparency = 0.5
    screenDistanceLabel.Font = Enum.Font.SourceSansBold
    screenDistanceLabel.TextSize = 14
    screenDistanceLabel.Text = ""
    screenDistanceLabel.Parent = gui
end

local function destroyScreenGui()
    if screenDistanceLabel then
        screenDistanceLabel.Parent:Destroy()
        screenDistanceLabel = nil
    end
end

local function updateScreenDistances(distances)
    if not screenDistanceLabel then return end
    local parts = {}
    for name, dist in pairs(distances) do
        table.insert(parts, name .. ": " .. string.format("%.1fm", dist))
    end
    if #parts == 0 then
        screenDistanceLabel.Text = "无怪物"
    else
        table.sort(parts)
        screenDistanceLabel.Text = table.concat(parts, "  |  ")
    end
end

local function createMonsterHighlight(model)
    if monsterHighlights[model] then return end
    local highlight = Instance.new("Highlight")
    highlight.Name = "MonsterOutline"
    highlight.FillTransparency = 1
    highlight.OutlineTransparency = 0
    highlight.OutlineColor = Color3.fromRGB(255, 0, 0)
    highlight.Parent = model
    monsterHighlights[model] = highlight
end

local function removeMonsterHighlight(model)
    if monsterHighlights[model] then
        monsterHighlights[model]:Destroy()
        monsterHighlights[model] = nil
    end
end

local function updateMonsterESP()
    task.spawn(function()
        while monsterEspEnabled do
            local char = player.Character
            local root = char and char:FindFirstChild("HumanoidRootPart")
            local kitFolder = workspace:FindFirstChild("kit")
            local distances = {}

            if kitFolder then
                for _, model in ipairs(kitFolder:GetChildren()) do
                    if model:IsA("Model") then
                        local lowerName = model.Name:lower()
                        if monsterNames[lowerName] then
                            local hum = model:FindFirstChild("Humanoid")
                            local hrp = model:FindFirstChild("HumanoidRootPart")
                            if hum and hum.Health > 0 and hrp then
                                local displayName = getMonsterDisplayName(model.Name)
                                if not monsterHighlights[model] then
                                    createMonsterHighlight(model)
                                end
                                if root then
                                    local dist = (hrp.Position - root.Position).Magnitude
                                    if not distances[displayName] or dist < distances[displayName] then
                                        distances[displayName] = dist
                                    end
                                end
                            end
                        end
                    end
                end
            end

            updateScreenDistances(distances)

            for model, _ in pairs(monsterHighlights) do
                local hum = model:FindFirstChild("Humanoid")
                if not hum or hum.Health <= 0 or not model:FindFirstChild("HumanoidRootPart") or not model.Parent then
                    removeMonsterHighlight(model)
                end
            end

            task.wait(0.5)
        end
    end)
end

local function clearMonsterESP()
    for model, _ in pairs(monsterHighlights) do
        removeMonsterHighlight(model)
    end
    monsterHighlights = {}
    destroyScreenGui()
end

-- ==================== 透视钥匙 ====================
local keyEspEnabled = false
local keyBillboard = nil

local function updateKeyESP()
    task.spawn(function()
        while keyEspEnabled do
            local char = player.Character
            local root = char and char:FindFirstChild("HumanoidRootPart")
            local keyModel = workspace:FindFirstChild("Map")
                and workspace.Map:FindFirstChild("Fence")
                and workspace.Map.Fence:FindFirstChild("Keys")
                and workspace.Map.Fence.Keys:FindFirstChild("Key")

            if keyModel and keyModel:IsA("Model") then
                local mainPart = keyModel.PrimaryPart or keyModel:FindFirstChildWhichIsA("BasePart")
                if mainPart then
                    if not keyBillboard or not keyBillboard.Parent then
                        local billboard = Instance.new("BillboardGui")
                        billboard.Name = "KeyESP"
                        billboard.Adornee = mainPart
                        billboard.Size = UDim2.new(0, 200, 0, 40)
                        billboard.StudsOffset = Vector3.new(0, 2, 0)
                        billboard.AlwaysOnTop = true
                        billboard.MaxDistance = 500
                        billboard.Parent = mainPart
                        local label = Instance.new("TextLabel")
                        label.Size = UDim2.fromScale(1, 1)
                        label.BackgroundTransparency = 1
                        label.TextColor3 = Color3.fromRGB(0, 255, 255)
                        label.TextStrokeTransparency = 0
                        label.Font = Enum.Font.SourceSansBold
                        label.TextSize = 14
                        label.Parent = billboard
                        keyBillboard = billboard
                    end
                    if keyBillboard and root then
                        local label = keyBillboard:FindFirstChildWhichIsA("TextLabel")
                        if label then
                            local dist = (mainPart.Position - root.Position).Magnitude
                            label.Text = "钥匙\n[" .. string.format("%.1f", dist) .. "米]"
                        end
                    end
                end
            else
                if keyBillboard then
                    keyBillboard:Destroy()
                    keyBillboard = nil
                end
            end
            task.wait(0.5)
        end
    end)
end

local function clearKeyESP()
    if keyBillboard then
        keyBillboard:Destroy()
        keyBillboard = nil
    end
end

-- ==================== ESP 标签页 ====================
Tabs.ESP:AddToggle("EnableMonsterESP", {
    Title = "透视怪物",
    Default = false,
    Callback = function(state)
        monsterEspEnabled = state
        if state then
            createScreenGui()
            updateMonsterESP()
        else
            clearMonsterESP()
        end
    end
})

Tabs.ESP:AddToggle("EnableKeyESP", {
    Title = "透视钥匙",
    Default = false,
    Callback = function(state)
        keyEspEnabled = state
        if state then
            updateKeyESP()
        else
            clearKeyESP()
        end
    end
})

SaveManager:SetLibrary(Fluent)
InterfaceManager:SetLibrary(Fluent)
SaveManager:IgnoreThemeSettings()
SaveManager:SetIgnoreIndexes({})
InterfaceManager:SetFolder("FluentScriptHub")
SaveManager:SetFolder("FluentScriptHub/godzilla-chapter3")
InterfaceManager:BuildInterfaceSection(Tabs.Other)
SaveManager:BuildConfigSection(Tabs.Other)

Window:SelectTab(1)
SaveManager:LoadAutoloadConfig()
