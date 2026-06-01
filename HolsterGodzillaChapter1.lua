local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
local SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/SaveManager.lua"))()
local InterfaceManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/InterfaceManager.lua"))()

local Window = Fluent:CreateWindow({
    Title = "哥斯拉皮套Hub - 第一夜",
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
local uis = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local safeZonePosition = Vector3.new(-171.49, -451.59, -153.56)
local generatorRoomPosition = Vector3.new(-12.83, -9.90, -143.77)
local spawnPosition = Vector3.new(-6.98, -9.84, -0.95)

-- ==================== 怪物透视（高亮轮廓） ====================
local monsterEspEnabled = false
local monsterHighlights = {}
local screenDistanceLabel

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

local function updateScreenDistance(dist)
    if not screenDistanceLabel then return end
    if dist == math.huge or dist <= 0 then
        screenDistanceLabel.Text = "哥斯拉: --米"
    else
        screenDistanceLabel.Text = "哥斯拉: " .. string.format("%.1f", dist) .. "米"
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
            local closestDist = math.huge

            if kitFolder then
                for _, model in ipairs(kitFolder:GetChildren()) do
                    if model:IsA("Model") and model.Name:lower() == "ai" and model ~= char then
                        local hum = model:FindFirstChild("Humanoid")
                        local hrp = model:FindFirstChild("HumanoidRootPart")
                        if hum and hum.Health > 0 and hrp then
                            if root then
                                local dist = (hrp.Position - root.Position).Magnitude
                                if dist < closestDist then
                                    closestDist = dist
                                end
                            end
                            if not monsterHighlights[model] then
                                createMonsterHighlight(model)
                            end
                        end
                    end
                end
            end

            updateScreenDistance(closestDist)

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

-- ==================== 传送点 ====================
Tabs.Teleport:AddButton({
    Title = "传送安全区",
    Callback = function()
        local char = player.Character
        if char and char:FindFirstChild("HumanoidRootPart") then
            pcall(function() char.HumanoidRootPart.CFrame = CFrame.new(safeZonePosition) end)
            Fluent:Notify({ Title = "传送", Content = "已传送到安全区", Duration = 2 })
        end
    end
})

Tabs.Teleport:AddButton({
    Title = "传送发电室",
    Callback = function()
        local char = player.Character
        if char and char:FindFirstChild("HumanoidRootPart") then
            pcall(function() char.HumanoidRootPart.CFrame = CFrame.new(generatorRoomPosition) end)
            Fluent:Notify({ Title = "传送", Content = "已传送到发电室", Duration = 2 })
        end
    end
})

Tabs.Teleport:AddButton({
    Title = "传送出生点(看监控)",
    Callback = function()
        local char = player.Character
        if char and char:FindFirstChild("HumanoidRootPart") then
            pcall(function() char.HumanoidRootPart.CFrame = CFrame.new(spawnPosition) end)
            Fluent:Notify({ Title = "传送", Content = "已传送到出生点(看监控)", Duration = 2 })
        end
    end
})

-- ==================== 半自动收集报纸 ====================
Tabs.Main:AddButton({
    Title = "半自动收集报纸",
    Callback = function()
        local char = player.Character
        if not char or not char:FindFirstChild("HumanoidRootPart") then return end
        local root = char.HumanoidRootPart
        local camera = workspace.CurrentCamera

        local postersFolder = workspace:FindFirstChild("Map") and workspace.Map:FindFirstChild("Posters")
        if not postersFolder then return end

        local function scanPosters()
            local list = {}
            for _, part in ipairs(postersFolder:GetDescendants()) do
                if part:IsA("BasePart") and part.Name == "Poster" then
                    table.insert(list, part)
                end
            end
            return list
        end

        local posters = scanPosters()
        if #posters == 0 then
            Fluent:Notify({ Title = "收集完成", Content = "当前没有报纸", Duration = 2 })
            return
        end

        table.sort(posters, function(a, b) return (a.Position - root.Position).Magnitude < (b.Position - root.Position).Magnitude end)

        for _, poster in ipairs(posters) do
            root.CFrame = CFrame.new(poster.Position + Vector3.new(0, 3, 0))
            task.wait(0.8)

            for _, part in ipairs(workspace:GetPartBoundsInRadius(poster.Position, 15)) do
                local model = part.Parent
                if model then
                    for _, child in ipairs(model:GetDescendants()) do
                        if child:IsA("ProximityPrompt") then pcall(function() child.HoldDuration = 0.01 end) end
                    end
                end
            end

            if camera.CameraType ~= Enum.CameraType.Scriptable then camera.CameraType = Enum.CameraType.Scriptable end
            local lookTarget = poster.Position
            task.spawn(function()
                while poster.Parent do
                    camera.CFrame = CFrame.new(root.Position + Vector3.new(0, 1.5, 0), lookTarget)
                    task.wait()
                end
            end)

            Fluent:Notify({ Title = "请狂点屏幕", Content = "视角已锁定，撕完自动下一张", Duration = 2 })

            repeat task.wait(0.3) until not poster.Parent or not poster:IsDescendantOf(workspace)
        end

        camera.CameraType = Enum.CameraType.Custom
        root.CFrame = CFrame.new(spawnPosition)
        Fluent:Notify({ Title = "收集完成", Content = "全部报纸已处理，回到出生点", Duration = 3 })
    end
})

-- ==================== 自动逃生 ====================
local autoEscapeEnabled = false

Tabs.Main:AddToggle("AutoEscape", {
    Title = "自动逃生",
    Default = false,
    Callback = function(state)
        autoEscapeEnabled = state
        if state then
            task.spawn(function()
                while autoEscapeEnabled do
                    local char = player.Character
                    if char then
                        local root = char:FindFirstChild("HumanoidRootPart")
                        if root then
                            local kitFolder = workspace:FindFirstChild("kit")
                            if kitFolder then
                                for _, model in ipairs(kitFolder:GetChildren()) do
                                    if model:IsA("Model") and model.Name:lower() == "ai" then
                                        local hum = model:FindFirstChild("Humanoid")
                                        local hrp = model:FindFirstChild("HumanoidRootPart")
                                        if hum and hum.Health > 0 and hrp then
                                            if (hrp.Position - root.Position).Magnitude < 20 then
                                                pcall(function() root.CFrame = CFrame.new(safeZonePosition) end)
                                                Fluent:Notify({ Title = "⚠️ 自动逃生", Content = "怪物接近！已传送到安全区", Duration = 2 })
                                                break
                                            end
                                        end
                                    end
                                end
                            end
                        end
                    end
                    task.wait(0.3)
                end
            end)
        end
    end
})

-- ==================== 自动降低焦虑（智能版） ====================
local autoLowerAnxietyEnabled = false
local monitorPrompt = nil
local holdThread = nil
local reduceThread = nil

local function stopAnxietyControl()
    if holdThread then task.cancel(holdThread) holdThread = nil end
    if reduceThread then task.cancel(reduceThread) reduceThread = nil end
    if monitorPrompt then
        pcall(function()
            monitorPrompt:InputHoldEnd()
            task.wait(0.2)
            ReplicatedStorage:WaitForChild("CloseCameras"):FireServer(player)
            ReplicatedStorage:WaitForChild("InduceAnxiety"):FireServer(player)
        end)
        monitorPrompt = nil
    end
end

Tabs.Main:AddToggle("AutoLowerAnxiety", {
    Title = "自动降低焦虑",
    Default = false,
    Callback = function(state)
        autoLowerAnxietyEnabled = state
        if state then
            task.spawn(function()
                while autoLowerAnxietyEnabled do
                    local anxietyValue = 0
                    local playerGui = player:WaitForChild("PlayerGui")
                    local flashlightGui = playerGui:FindFirstChild("FlashLightGui")
                    if flashlightGui then
                        local percentageLabel = flashlightGui:FindFirstChild("Percentage")
                        if not percentageLabel then
                            local frame = flashlightGui:FindFirstChild("Frame")
                            if frame then
                                percentageLabel = frame:FindFirstChild("Percentage")
                            end
                        end
                        if percentageLabel and percentageLabel:IsA("TextLabel") then
                            local text = percentageLabel.Text
                            local num = tonumber(text:match("%d+"))
                            if num then anxietyValue = num end
                        end
                    end

                    if anxietyValue >= 80 then
                        local char = player.Character
                        if char and char:FindFirstChild("HumanoidRootPart") then
                            if not monitorPrompt then
                                char.HumanoidRootPart.CFrame = CFrame.new(spawnPosition)
                                task.wait(1)
                                for _, part in ipairs(workspace:GetPartBoundsInRadius(spawnPosition, 10)) do
                                    local model = part.Parent
                                    if model then
                                        local prompt = model:FindFirstChildWhichIsA("ProximityPrompt")
                                        if prompt then
                                            monitorPrompt = prompt
                                            break
                                        end
                                    end
                                end
                                if monitorPrompt then
                                    pcall(function() monitorPrompt.HoldDuration = 0 end)
                                    pcall(function() monitorPrompt:InputHoldBegin() end)
                                    reduceThread = task.spawn(function()
                                        while autoLowerAnxietyEnabled and monitorPrompt do
                                            pcall(function()
                                                ReplicatedStorage:WaitForChild("ReduceAnxiety"):FireServer(player)
                                            end)
                                            task.wait(1)
                                        end
                                    end)
                                end
                            end
                        end
                    else
                        if monitorPrompt then
                            stopAnxietyControl()
                        end
                    end
                    task.wait(2)
                end
                stopAnxietyControl()
            end)
        else
            autoLowerAnxietyEnabled = false
            stopAnxietyControl()
        end
    end
})

-- ==================== 远程修电 ====================
local repairActive = false

local function findGeneratorPrompt()
    local generator = workspace:FindFirstChild("Map") and workspace.Map:FindFirstChild("Generator")
    if not generator then return nil end
    for _, obj in ipairs(generator:GetDescendants()) do
        if obj:IsA("ProximityPrompt") then
            return obj
        end
    end
    return nil
end

local function getProgress()
    local batteryLabel = workspace:FindFirstChild("Map")
        and workspace.Map:FindFirstChild("Generator")
        and workspace.Map.Generator:FindFirstChild("Inside")
        and workspace.Map.Generator.Inside:FindFirstChild("SurfaceGui")
        and workspace.Map.Generator.Inside.SurfaceGui:FindFirstChild("BatteryLabel")
    if batteryLabel and batteryLabel:IsA("TextLabel") then
        local num = tonumber(batteryLabel.Text:match("%d+"))
        return num
    end
    return 0
end

local function startRepairLoop()
    task.spawn(function()
        local prompt = findGeneratorPrompt()
        if not prompt then
            Fluent:Notify({ Title = "错误", Content = "未找到发电机按钮", Duration = 3 })
            repairActive = false
            return
        end

        prompt.MaxActivationDistance = 500
        pcall(function() prompt:InputHoldBegin() end)

        while repairActive do
            local progress = getProgress()
            if progress >= 100 then
                pcall(function() prompt:InputHoldEnd() end)
                Fluent:Notify({ Title = "修电完成", Content = "发电机已修好", Duration = 3 })
                repairActive = false
                break
            end
            task.wait(0.3)
        end
    end)
end

Tabs.Main:AddToggle("AutoRepair", {
    Title = "远程修电",
    Default = false,
    Callback = function(state)
        repairActive = state
        if state then
            startRepairLoop()
        else
            local prompt = findGeneratorPrompt()
            if prompt then
                pcall(function() prompt:InputHoldEnd() end)
            end
        end
    end
})

-- ==================== 显示电量 ====================
local batteryDisplayGui = nil
local batteryLabelGlobal = nil

local function updateBatteryDisplay()
    local percent = getProgress()
    if batteryLabelGlobal then
        batteryLabelGlobal.Text = "电量: " .. tostring(percent) .. "%"
    end
end

local function createBatteryDisplay()
    if batteryDisplayGui then return end
    batteryDisplayGui = Instance.new("ScreenGui")
    batteryDisplayGui.Name = "BatteryDisplay"
    batteryDisplayGui.ResetOnSpawn = false
    batteryDisplayGui.Parent = game:GetService("CoreGui")

    batteryLabelGlobal = Instance.new("TextLabel")
    batteryLabelGlobal.Size = UDim2.fromOffset(120, 24)
    batteryLabelGlobal.Position = UDim2.new(0.02, 0, 0.94, 0)
    batteryLabelGlobal.BackgroundTransparency = 1
    batteryLabelGlobal.TextColor3 = Color3.fromRGB(0, 255, 100)
    batteryLabelGlobal.TextStrokeTransparency = 0.5
    batteryLabelGlobal.Font = Enum.Font.SourceSansBold
    batteryLabelGlobal.TextSize = 14
    batteryLabelGlobal.Text = "电量: --%"
    batteryLabelGlobal.Parent = batteryDisplayGui
end

local function destroyBatteryDisplay()
    if batteryDisplayGui then
        batteryDisplayGui:Destroy()
        batteryDisplayGui = nil
        batteryLabelGlobal = nil
    end
end

local batteryDisplayEnabled = false
local batteryUpdateConnection = nil

Tabs.Main:AddToggle("ShowBattery", {
    Title = "显示电量",
    Default = false,
    Callback = function(state)
        batteryDisplayEnabled = state
        if state then
            createBatteryDisplay()
            batteryUpdateConnection = RunService.Heartbeat:Connect(function()
                if batteryDisplayEnabled then
                    updateBatteryDisplay()
                end
            end)
        else
            if batteryUpdateConnection then
                batteryUpdateConnection:Disconnect()
                batteryUpdateConnection = nil
            end
            destroyBatteryDisplay()
        end
    end
})

SaveManager:SetLibrary(Fluent)
InterfaceManager:SetLibrary(Fluent)
SaveManager:IgnoreThemeSettings()
SaveManager:SetIgnoreIndexes({})
InterfaceManager:SetFolder("FluentScriptHub")
SaveManager:SetFolder("FluentScriptHub/godzilla-chapter1")
InterfaceManager:BuildInterfaceSection(Tabs.Other)
SaveManager:BuildConfigSection(Tabs.Other)

Window:SelectTab(1)
SaveManager:LoadAutoloadConfig()
