local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
local SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/SaveManager.lua"))()
local InterfaceManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/InterfaceManager.lua"))()

local Window = Fluent:CreateWindow({
    Title = "哥斯拉皮套Hub - 第二章",
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
    Teleport = Window:AddTab({ Title = "传送", Icon = "map-pin" }),
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

local espEnabled = false
local billboards = {}
local screenDistanceLabel

local monsterNames = {
    ["ai"] = "哥斯拉",
    ["ai_anguirus"] = "安吉拉斯",
    ["ai_anguirus2"] = "安吉拉斯2"
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

local function createBillboard(model, displayName)
    if billboards[model] then return end
    local billboard = Instance.new("BillboardGui")
    billboard.Name = "MonsterESP"
    billboard.Adornee = model:FindFirstChild("Head") or model:FindFirstChild("HumanoidRootPart")
    billboard.Size = UDim2.new(0, 200, 0, 60)
    billboard.StudsOffset = Vector3.new(0, 3, 0)
    billboard.AlwaysOnTop = true
    billboard.MaxDistance = 500
    billboard.Parent = model

    local label = Instance.new("TextLabel")
    label.Size = UDim2.fromScale(1, 1)
    label.BackgroundTransparency = 1
    label.TextColor3 = Color3.fromRGB(255, 80, 80)
    label.TextStrokeTransparency = 0
    label.Font = Enum.Font.SourceSansBold
    label.TextSize = 14
    label.Parent = billboard

    billboards[model] = { billboard = billboard, label = label, displayName = displayName }
end

local function removeBillboard(model)
    if billboards[model] then
        billboards[model].billboard:Destroy()
        billboards[model] = nil
    end
    for _, obj in ipairs(model:GetChildren()) do
        if obj.Name == "MonsterESP" and obj:IsA("BillboardGui") then
            obj:Destroy()
        end
    end
end

local function updateESP()
    task.spawn(function()
        while espEnabled do
            local char = player.Character
            local root = char and char:FindFirstChild("HumanoidRootPart")
            local kitFolder = workspace:FindFirstChild("kit")
            local distances = {}

            if kitFolder then
                for _, model in ipairs(kitFolder:GetChildren()) do
                    if model:IsA("Model") then
                        local lowerName = model.Name:lower()
                        if lowerName == "ai" or lowerName == "ai_anguirus" or lowerName == "ai_anguirus2" then
                            local hum = model:FindFirstChild("Humanoid")
                            local hrp = model:FindFirstChild("HumanoidRootPart")
                            if hum and hum.Health > 0 and hrp then
                                local displayName = getMonsterDisplayName(model.Name)
                                if not billboards[model] then
                                    createBillboard(model, displayName)
                                end
                                local bData = billboards[model]
                                if bData and root then
                                    local dist = (hrp.Position - root.Position).Magnitude
                                    bData.label.Text = displayName .. "\n[" .. string.format("%.1f", dist) .. "米]"

                                    if not distances[displayName] or dist < distances[displayName] then
                                        distances[displayName] = dist
                                    end
                                end
                            end
                        end
                    end
                end
            end

            for model, _ in pairs(billboards) do
                if not model:FindFirstChild("Humanoid") or model.Humanoid.Health <= 0 or not model:FindFirstChild("HumanoidRootPart") then
                    removeBillboard(model)
                end
            end

            updateScreenDistances(distances)
            task.wait(0.5)
        end
    end)
end

local function clearESP()
    for model, _ in pairs(billboards) do
        removeBillboard(model)
    end
    billboards = {}
    destroyScreenGui()
end

Tabs.ESP:AddToggle("EnableESP", {
    Title = "透视怪物",
    Default = false,
    Callback = function(state)
        espEnabled = state
        if state then
            createScreenGui()
            updateESP()
        else
            clearESP()
        end
    end
})

local safeZonePosition = Vector3.new(-171.49, -451.59, -153.56)
local generatorRoomPosition = Vector3.new(-12.83, -9.90, -143.77)
local spawnPosition = Vector3.new(-6.98, -9.84, -0.95)

Tabs.Teleport:AddButton({
    Title = "传送安全区",
    Callback = function()
        local char = player.Character
        if char and char:FindFirstChild("HumanoidRootPart") then
            pcall(function()
                char.HumanoidRootPart.CFrame = CFrame.new(safeZonePosition)
            end)
            Fluent:Notify({ Title = "传送", Content = "已传送到安全区", Duration = 2 })
        else
            Fluent:Notify({ Title = "传送失败", Content = "角色未加载", Duration = 2 })
        end
    end
})

Tabs.Teleport:AddButton({
    Title = "传送发电室",
    Callback = function()
        local char = player.Character
        if char and char:FindFirstChild("HumanoidRootPart") then
            pcall(function()
                char.HumanoidRootPart.CFrame = CFrame.new(generatorRoomPosition)
            end)
            Fluent:Notify({ Title = "传送", Content = "已传送到发电室", Duration = 2 })
        else
            Fluent:Notify({ Title = "传送失败", Content = "角色未加载", Duration = 2 })
        end
    end
})

Tabs.Teleport:AddButton({
    Title = "传送出生点(看监控)",
    Callback = function()
        local char = player.Character
        if char and char:FindFirstChild("HumanoidRootPart") then
            pcall(function()
                char.HumanoidRootPart.CFrame = CFrame.new(spawnPosition)
            end)
            Fluent:Notify({ Title = "传送", Content = "已传送到出生点(看监控)", Duration = 2 })
        else
            Fluent:Notify({ Title = "传送失败", Content = "角色未加载", Duration = 2 })
        end
    end
})

SaveManager:SetLibrary(Fluent)
InterfaceManager:SetLibrary(Fluent)
SaveManager:IgnoreThemeSettings()
SaveManager:SetIgnoreIndexes({})
InterfaceManager:SetFolder("FluentScriptHub")
SaveManager:SetFolder("FluentScriptHub/godzilla-chapter2")
InterfaceManager:BuildInterfaceSection(Tabs.Other)
SaveManager:BuildConfigSection(Tabs.Other)

Window:SelectTab(1)
SaveManager:LoadAutoloadConfig()
