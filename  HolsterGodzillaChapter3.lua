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

local safeZonePosition = Vector3.new(-142.55, -450.12 + 3, 2303.20)
local chapter2Spawn = Vector3.new(291.00, 17.83 + 3, 2405.50)
local chapter1Spawn = Vector3.new(2099.25, -22.72 + 3, -1921.75)
local garagePosition = Vector3.new(2201.70, -22.72 + 3, -1950.17)

local monsterEspEnabled = false
local monsterHighlights = {}
local screenDistanceLabel

local monsterNames = {
    ["Jaguar"] = "美洲豹",
    ["Lunchlady"] = "午餐女士",
    ["ShadowGrin"] = "暗影狞笑",
    ["Soul_AI"] = "灵魂AI",
}

local function getDisplayName(modelName)
    return monsterNames[modelName] or modelName
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
        table.insert(parts, name .. ": " .. string.format("%.1f米", dist))
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
    local hrp = model:FindFirstChild("HumanoidRootPart", true)
    if not hrp then return end
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
                        local hum = model:FindFirstChild("Humanoid")
                        local hrp = model:FindFirstChild("HumanoidRootPart", true)
                        if hum and hum.Health > 0 and hrp then
                            if not monsterHighlights[model] then
                                createMonsterHighlight(model)
                            end
                            if root then
                                local dist = (hrp.Position - root.Position).Magnitude
                                local displayName = getDisplayName(model.Name)
                                if not distances[displayName] or dist < distances[displayName] then
                                    distances[displayName] = dist
                                end
                            end
                        end
                    end
                end
            end

            updateScreenDistances(distances)

            for model, _ in pairs(monsterHighlights) do
                local hum = model:FindFirstChild("Humanoid")
                if not hum or hum.Health <= 0 or not model:FindFirstChild("HumanoidRootPart", true) or not model.Parent then
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

local daylightEnabled = false
local daylightLoopThread = nil

local function setBrightLighting()
    pcall(function()
        local lighting = game:GetService("Lighting")
        lighting.Brightness = 2
        lighting.ClockTime = 14
        lighting.FogEnd = 100000
        lighting.FogStart = 0
        lighting.GlobalShadows = false
        lighting.Outlines = true
        lighting.EnvironmentSpecularScale = 1
        lighting.EnvironmentDiffuseScale = 1
    end)
end

local function destroyPostEffects()
    local effects = {"BlurEffect","BloomEffect","DepthOfFieldEffect","ColorCorrectionEffect","SunRaysEffect","Atmosphere"}
    for _, container in ipairs({game:GetService("Lighting"), workspace.CurrentCamera, workspace}) do
        if container then
            for _, obj in ipairs(container:GetDescendants()) do
                for _, ef in ipairs(effects) do
                    if obj:IsA(ef) then
                        obj:Destroy()
                    end
                end
            end
        end
    end
end

local function destroyNoiseUI()
    local noiseKeys = {"tvLines","Static","Noise","Grain","Scanline","CRT","VHS","nightVision","Vignette","Fade","flash","Gradient"}
    local playerGui = player:FindFirstChild("PlayerGui")
    if not playerGui then return end
    for _, gui in ipairs(playerGui:GetChildren()) do
        if gui:IsA("ScreenGui") or gui:IsA("LayerCollector") then
            for _, obj in ipairs(gui:GetDescendants()) do
                if obj:IsA("ImageLabel") or obj:IsA("Frame") then
                    local nameLower = obj.Name:lower()
                    for _, key in ipairs(noiseKeys) do
                        if nameLower:find(key:lower()) then
                            obj:Destroy()
                            break
                        end
                    end
                end
            end
        end
    end
end

local function destroyRedOverlay()
    local playerGui = player:FindFirstChild("PlayerGui")
    if not playerGui then return end
    for _, gui in ipairs(playerGui:GetChildren()) do
        if gui:IsA("ScreenGui") or gui:IsA("LayerCollector") then
            for _, obj in ipairs(gui:GetDescendants()) do
                if (obj:IsA("Frame") or obj:IsA("ImageLabel")) and obj.Size == UDim2.new(1,0,1,0) then
                    local color = obj:IsA("Frame") and obj.BackgroundColor3 or obj:IsA("ImageLabel") and obj.ImageColor3
                    local trans = obj:IsA("Frame") and obj.BackgroundTransparency or obj.ImageTransparency
                    if color and trans < 1 and (color.r > 0.7 or color.r > color.g + 0.3) and obj.Visible then
                        obj:Destroy()
                    end
                end
            end
        end
    end
end

local function daylightCleanup()
    setBrightLighting()
    destroyPostEffects()
    destroyNoiseUI()
    destroyRedOverlay()
end

Tabs.Main:AddToggle("Daylight", {
    Title = "天亮",
    Description = "没有黑暗 只有光明",
    Default = false,
    Callback = function(state)
        daylightEnabled = state
        if state then
            daylightCleanup()
            daylightLoopThread = task.spawn(function()
                while daylightEnabled do
                    daylightCleanup()
                    task.wait(2)
                end
            end)
            Fluent:Notify({ Title = "天亮", Content = "画面已净化", Duration = 2 })
        else
            if daylightLoopThread then
                task.cancel(daylightLoopThread)
                daylightLoopThread = nil
            end
            Fluent:Notify({ Title = "天亮", Content = "已关闭", Duration = 2 })
        end
    end
})

local autoEscapeEnabled = false

Tabs.Main:AddToggle("AutoEscape", {
    Title = "自动逃生",
    Description = "怪物靠近25米时自动传送到安全区",
    Default = false,
    Callback = function(state)
        autoEscapeEnabled = state
        if state then
            task.spawn(function()
                while autoEscapeEnabled do
                    local char = player.Character
                    if char and char:FindFirstChild("HumanoidRootPart") then
                        local root = char.HumanoidRootPart
                        local kitFolder = workspace:FindFirstChild("kit")
                        if kitFolder then
                            for _, model in ipairs(kitFolder:GetChildren()) do
                                if model:IsA("Model") then
                                    local hrp = model:FindFirstChild("HumanoidRootPart", true)
                                    if hrp and (hrp.Position - root.Position).Magnitude < 25 then
                                        pcall(function()
                                            root.CFrame = CFrame.new(safeZonePosition)
                                        end)
                                        Fluent:Notify({ Title = "自动逃生", Content = "怪物接近！已传送到安全区", Duration = 2 })
                                        break
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

Tabs.Teleport:AddButton({
    Title = "安全区",
    Callback = function()
        local char = player.Character
        if char and char:FindFirstChild("HumanoidRootPart") then
            pcall(function() char.HumanoidRootPart.CFrame = CFrame.new(safeZonePosition) end)
            Fluent:Notify({ Title = "传送", Content = "已传送到安全区", Duration = 2 })
        end
    end
})

Tabs.Teleport:AddButton({
    Title = "第2关出生点",
    Callback = function()
        local char = player.Character
        if char and char:FindFirstChild("HumanoidRootPart") then
            pcall(function() char.HumanoidRootPart.CFrame = CFrame.new(chapter2Spawn) end)
            Fluent:Notify({ Title = "传送", Content = "已传送到第2关出生点", Duration = 2 })
        end
    end
})

Tabs.Teleport:AddButton({
    Title = "第1关出生点",
    Callback = function()
        local char = player.Character
        if char and char:FindFirstChild("HumanoidRootPart") then
            pcall(function() char.HumanoidRootPart.CFrame = CFrame.new(chapter1Spawn) end)
            Fluent:Notify({ Title = "传送", Content = "已传送到第1关出生点", Duration = 2 })
        end
    end
})

Tabs.Teleport:AddButton({
    Title = "车库",
    Callback = function()
        local char = player.Character
        if char and char:FindFirstChild("HumanoidRootPart") then
            pcall(function() char.HumanoidRootPart.CFrame = CFrame.new(garagePosition) end)
            Fluent:Notify({ Title = "传送", Content = "已传送到车库", Duration = 2 })
        end
    end
})

Tabs.Teleport:AddButton({
    Title = "传送到逃生门",
    Callback = function()
        local function findEscapeDoor()
            for _, obj in ipairs(workspace:GetDescendants()) do
                if obj:IsA("BasePart") and obj.Name == "EscapeDoor" then
                    for _, child in ipairs(obj:GetChildren()) do
                        if child:IsA("TouchTransmitter") then
                            return obj
                        end
                    end
                elseif obj:IsA("Model") and obj.Name == "EscapeDoor" then
                    local part = obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart")
                    if part then
                        for _, child in ipairs(part:GetChildren()) do
                            if child:IsA("TouchTransmitter") then
                                return part
                            end
                        end
                    end
                end
            end
            return nil
        end

        local targetPart = findEscapeDoor()
        if not targetPart then
            Fluent:Notify({ Title = "未触发", Content = "还未触发逃生门，请您尽快吃完豆子", Duration = 3 })
            return
        end

        local char = player.Character
        if char and char:FindFirstChild("HumanoidRootPart") then
            char.HumanoidRootPart.CFrame = CFrame.new(targetPart.Position + Vector3.new(0, 2, 0))
            Fluent:Notify({ Title = "传送", Content = "已传送到逃生门", Duration = 2 })
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
SaveManager:SetFolder("FluentScriptHub/godzilla-chapter2")
InterfaceManager:BuildInterfaceSection(Tabs.Other)
SaveManager:BuildConfigSection(Tabs.Other)

Window:SelectTab(1)
SaveManager:LoadAutoloadConfig()
