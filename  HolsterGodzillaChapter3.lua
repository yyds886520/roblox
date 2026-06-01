local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
local SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/SaveManager.lua"))()
local InterfaceManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/InterfaceManager.lua"))()

local Window = Fluent:CreateWindow({
    Title = "哥斯拉皮套Hub - 第2章",
    SubTitle = "by.小梦",
    TabWidth = 160,
    Size = UDim2.fromOffset(580, 360),
    Acrylic = false,
    Theme = "Darker",
    MinimizeKey = Enum.KeyCode.LeftControl
})

Window.Root.Visible = true

local Tabs = {
    Main = Window:AddTab({ Title = "主要", Icon = "box" }),
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

local monsterEspEnabled = false
local monsterHighlights = {}
local screenDistanceLabel

local monsterPaths = {
    { path = {"kit", "Jaguar"}, name = "美洲豹" },
    { path = {"kit", "Lunchlady"}, name = "午餐女士" },
    { path = {"kit", "ShadowGrin"}, name = "暗影狞笑" },
    { path = {"kit", "Soul_AI"}, name = "灵魂AI" },
}

local function getDynamicMonster()
    local kit = workspace:FindFirstChild("kit")
    if kit then
        local children = kit:GetChildren()
        local target = children[7]
        if target and target:IsA("Model") then
            return target, target.Name
        end
    end
    return nil, nil
end

local function isModelTracked(model)
    for _, data in ipairs(monsterPaths) do
        local m = workspace:FindFirstChild(data.path[1])
        for i = 2, #data.path do
            m = m and m:FindFirstChild(data.path[i])
        end
        if m == model then
            return true
        end
    end
    return false
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

local function findMonsterByPath(pathTable)
    local current = workspace
    for _, name in ipairs(pathTable) do
        current = current:FindFirstChild(name)
        if not current then return nil end
    end
    if current:IsA("Model") then return current end
    return nil
end

local function updateMonsterESP()
    task.spawn(function()
        while monsterEspEnabled do
            local char = player.Character
            local root = char and char:FindFirstChild("HumanoidRootPart")
            local distances = {}

            for _, target in ipairs(monsterPaths) do
                local model = findMonsterByPath(target.path)
                if model and model:IsA("Model") then
                    local hum = model:FindFirstChild("Humanoid")
                    local hrp = model:FindFirstChild("HumanoidRootPart")
                    if hum and hum.Health > 0 and hrp then
                        if not monsterHighlights[model] then
                            createMonsterHighlight(model)
                        end
                        if root then
                            local dist = (hrp.Position - root.Position).Magnitude
                            if not distances[target.name] or dist < distances[target.name] then
                                distances[target.name] = dist
                            end
                        end
                    end
                end
            end

            local dynModel, dynName = getDynamicMonster()
            if dynModel and not isModelTracked(dynModel) then
                local hum = dynModel:FindFirstChild("Humanoid")
                local hrp = dynModel:FindFirstChild("HumanoidRootPart")
                if hum and hum.Health > 0 and hrp then
                    if not monsterHighlights[dynModel] then
                        createMonsterHighlight(dynModel)
                    end
                    if root then
                        local dist = (hrp.Position - root.Position).Magnitude
                        local displayName = "第7怪物(" .. dynName .. ")"
                        if not distances[displayName] or dist < distances[displayName] then
                            distances[displayName] = dist
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

local soulEspEnabled = false
local soulBillboards = {}

local function updateSoulESP()
    task.spawn(function()
        while soulEspEnabled do
            local char = player.Character
            local root = char and char:FindFirstChild("HumanoidRootPart")

            local soulsFolder = workspace:FindFirstChild("Map") and workspace.Map:FindFirstChild("Souls")
            if soulsFolder then
                for _, obj in ipairs(soulsFolder:GetDescendants()) do
                    if obj:IsA("BasePart") and obj.Name == "SoulPart" then
                        if not soulBillboards[obj] then
                            local billboard = Instance.new("BillboardGui")
                            billboard.Name = "SoulESP"
                            billboard.Adornee = obj
                            billboard.Size = UDim2.new(0, 200, 0, 40)
                            billboard.StudsOffset = Vector3.new(0, 2, 0)
                            billboard.AlwaysOnTop = true
                            billboard.MaxDistance = 300
                            billboard.Parent = obj
                            local label = Instance.new("TextLabel")
                            label.Size = UDim2.fromScale(1, 1)
                            label.BackgroundTransparency = 1
                            label.TextColor3 = Color3.fromRGB(0, 150, 255)
                            label.TextStrokeTransparency = 0
                            label.Font = Enum.Font.SourceSansBold
                            label.TextSize = 14
                            label.Parent = billboard
                            soulBillboards[obj] = billboard
                        end
                        local billboard = soulBillboards[obj]
                        if billboard and root then
                            local label = billboard:FindFirstChildWhichIsA("TextLabel")
                            if label then
                                local dist = (obj.Position - root.Position).Magnitude
                                label.Text = "豆子\n[" .. string.format("%.1f", dist) .. "米]"
                            end
                        end
                    end
                end
            end

            for obj, billboard in pairs(soulBillboards) do
                if not obj:IsDescendantOf(workspace) then
                    billboard:Destroy()
                    soulBillboards[obj] = nil
                end
            end

            task.wait(0.5)
        end
    end)
end

local function clearSoulESP()
    for obj, billboard in pairs(soulBillboards) do
        billboard:Destroy()
    end
    soulBillboards = {}
end

local nightVisionEnabled = false

local function enableNightVision()
    nightVisionEnabled = true
    task.spawn(function()
        while nightVisionEnabled do
            pcall(function()
                local lighting = game:GetService("Lighting")
                lighting.Ambient = Color3.fromRGB(255, 255, 255)
                lighting.Brightness = 2
                lighting.ClockTime = 14
                lighting.FogEnd = 100000
                lighting.GlobalShadows = false
            end)
            task.wait(0.5)
        end
    end)
end

local function disableNightVision()
    nightVisionEnabled = false
    pcall(function()
        local lighting = game:GetService("Lighting")
        lighting.Ambient = Color3.fromRGB(0, 0, 0)
        lighting.Brightness = 1
        lighting.FogEnd = 1000
        lighting.GlobalShadows = true
    end)
end

local noclipEnabled = false
local noclipConnection = nil

local function setNoclip(enabled)
    if enabled then
        if noclipConnection then return end
        noclipConnection = RunService.Stepped:Connect(function()
            local char = player.Character
            if char then
                for _, part in ipairs(char:GetDescendants()) do
                    if part:IsA("BasePart") then
                        part.CanCollide = false
                    end
                end
            end
        end)
    else
        if noclipConnection then
            noclipConnection:Disconnect()
            noclipConnection = nil
        end
        local char = player.Character
        if char then
            for _, part in ipairs(char:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CanCollide = true
                end
            end
        end
    end
end

local function stripTouchTransmitters(part)
    for _, child in ipairs(part:GetChildren()) do
        if child:IsA("TouchTransmitter") then
            child:Destroy()
        end
    end
end

local function processModel(model)
    for _, part in ipairs(model:GetDescendants()) do
        if part:IsA("BasePart") then
            stripTouchTransmitters(part)
        end
    end
end

local ignoreMonsterConnection = nil

Tabs.Main:AddToggle("IgnoreMonster", {
    Title = "无视怪物",
    Default = false,
    Callback = function(state)
        if state then
            for _, obj in ipairs(workspace:GetDescendants()) do
                if obj:IsA("BasePart") then
                    stripTouchTransmitters(obj)
                elseif obj:IsA("Model") then
                    processModel(obj)
                end
            end
            ignoreMonsterConnection = workspace.DescendantAdded:Connect(function(desc)
                if desc:IsA("BasePart") then
                    stripTouchTransmitters(desc)
                elseif desc:IsA("Model") then
                    task.wait(0.1)
                    processModel(desc)
                end
            end)
        else
            if ignoreMonsterConnection then
                ignoreMonsterConnection:Disconnect()
                ignoreMonsterConnection = nil
            end
        end
    end
})

Tabs.Main:AddButton({
    Title = "一键吃豆",
    Callback = function()
        local char = player.Character
        if not char or not char:FindFirstChild("HumanoidRootPart") then
            Fluent:Notify({ Title = "失败", Content = "角色未加载", Duration = 2 })
            return
        end
        local root = char.HumanoidRootPart

        local SAFE_DISTANCE = 25

        local function isNearMonster(pos)
            local kit = workspace:FindFirstChild("kit")
            if not kit then return false end
            for _, model in ipairs(kit:GetChildren()) do
                if model:IsA("Model") then
                    local hrp = model:FindFirstChild("HumanoidRootPart")
                    if hrp and (hrp.Position - pos).Magnitude < SAFE_DISTANCE then
                        return true
                    end
                end
            end
            return false
        end

        local function scanSouls()
            local positions = {}
            local soulsFolder = workspace:FindFirstChild("Map") and workspace.Map:FindFirstChild("Souls")
            if soulsFolder then
                for _, part in ipairs(soulsFolder:GetDescendants()) do
                    if part:IsA("BasePart") and part.Name == "SoulPart" then
                        table.insert(positions, part.Position)
                    end
                end
            end
            return positions
        end

        local totalCount = 0

        for round = 1, 3 do
            local visitedPositions = {}
            local positions = scanSouls()
            if #positions == 0 then break end

            while #positions > 0 do
                table.sort(positions, function(a, b)
                    return (a - root.Position).Magnitude < (b - root.Position).Magnitude
                end)

                local safeFound = false
                for _, targetPos in ipairs(positions) do
                    if not visitedPositions[targetPos] and not isNearMonster(targetPos) then
                        root.CFrame = CFrame.new(targetPos + Vector3.new(0, 3, 0))
                        task.wait(0.05)
                        visitedPositions[targetPos] = true
                        totalCount = totalCount + 1
                        safeFound = true
                        break
                    end
                end

                if not safeFound then
                    Fluent:Notify({ Title = "警告", Content = "第" .. round .. "轮：剩余豆子太接近怪物，已跳过", Duration = 3 })
                    break
                end

                local allPositions = scanSouls()
                positions = {}
                for _, p in ipairs(allPositions) do
                    if not visitedPositions[p] then
                        table.insert(positions, p)
                    end
                end
            end
        end

        Fluent:Notify({ Title = "吃豆完成", Content = "共安全吃掉 " .. totalCount .. " 个豆", Duration = 3 })
    end
})

Tabs.Main:AddToggle("NightVision", {
    Title = "夜视",
    Default = false,
    Callback = function(state)
        if state then enableNightVision() else disableNightVision() end
    end
})

Tabs.Main:AddToggle("NoClip", {
    Title = "穿墙",
    Default = false,
    Callback = function(state)
        noclipEnabled = state
        setNoclip(state)
    end
})

local garagePosition = Vector3.new(2201.70, -22.72, -1950.17)

Tabs.Teleport:AddButton({
    Title = "车库",
    Callback = function()
        local char = player.Character
        if char and char:FindFirstChild("HumanoidRootPart") then
            pcall(function() char.HumanoidRootPart.CFrame = CFrame.new(garagePosition) end)
            Fluent:Notify({ Title = "传送", Content = "已传送到车库", Duration = 2 })
        else
            Fluent:Notify({ Title = "传送失败", Content = "角色未加载", Duration = 2 })
        end
    end
})

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

Tabs.ESP:AddToggle("EnableSoulESP", {
    Title = "透视豆子",
    Default = false,
    Callback = function(state)
        soulEspEnabled = state
        if state then
            updateSoulESP()
        else
            clearSoulESP()
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
