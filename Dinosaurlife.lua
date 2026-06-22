_G.ESPStyle = {
    NameSize = 12,
    DistanceSize = 10,
    HealthTextSize = 9,
    BarWidth = 3,
    BarHeight = 24,
    NameOffset = Vector3.new(0, 4, 0),
    HealthOffset = Vector3.new(3.5, 0, 0),
    DistanceOffset = Vector3.new(0, -3.5, 0),
    ScaleEnabled = true,
    ScaleMinDist = 20,
    ScaleMaxDist = 300,
    ScaleMin = 0.7,
    ScaleMax = 1.3,
    FadeEnabled = false,
    FadeMinDist = 30,
    FadeMaxDist = 500,
}

local function safeLoadBuilder(url, retryCount)
    retryCount = retryCount or 3
    for i = 1, retryCount do
        local success, response = pcall(function()
            return game:HttpGet(url)
        end)
        if success and response then
            local f, err = loadstring(response)
            if f then return f end
        end
        task.wait(1)
    end
    return nil
end

local FluentBuilder = safeLoadBuilder("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua")
if not FluentBuilder then return end

local Fluent = FluentBuilder()

local Window = Fluent:CreateWindow({
    Title = "恐龙生活 Beta",
    SubTitle = "by.小梦",
    TabWidth = 160,
    Size = UDim2.fromOffset(550, 360),
    Acrylic = false,
    Theme = "Darker",
    MinimizeKey = Enum.KeyCode.LeftControl
})

local Tabs = {
    Home = Window:AddTab({ Title = "主页", Icon = "home" }),
    ESP = Window:AddTab({ Title = "ESP", Icon = "eye" }),
    Settings = Window:AddTab({ Title = "设置", Icon = "settings" })
}

do
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
    button.Image = "rbxassetid://10709791437"
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
            button.Position = UDim2.fromOffset(buttonStartPos.X.Offset + delta.X, buttonStartPos.Y.Offset + delta.Y)
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
local Workspace = game:GetService("Workspace")
local CoreGui = game:GetService("CoreGui")
local HttpService = game:GetService("HttpService")
local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

for _, v in ipairs(CoreGui:GetChildren()) do
    if v.Name:find("ESP_") then v:Destroy() end
end

local ESPConfig = {
    Enabled = false,
    ShowName = false,
    ShowDistance = false,
    ShowHealth = false,
    ShowBox = false,
    ItemESP = false,
    MaxDistance = math.huge
}

local playerESPs = {}
local itemESPs = {}

local function getDistance(part)
    local char = player.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    if not root then return 9999 end
    return (part.Position - root.Position).Magnitude
end

local function createESPBillboards(plr)
    local nameTag = Instance.new("BillboardGui")
    nameTag.Name = "ESP_NameTag"
    nameTag.Size = UDim2.new(0, 200, 0, 30)
    nameTag.AlwaysOnTop = true
    nameTag.MaxDistance = 9e9
    nameTag.StudsOffset = _G.ESPStyle.NameOffset
    nameTag.Parent = CoreGui

    local nameScale = Instance.new("UIScale")
    nameScale.Parent = nameTag

    local nameFrame = Instance.new("Frame")
    nameFrame.Size = UDim2.new(1, 0, 1, 0)
    nameFrame.BackgroundTransparency = 1
    nameFrame.Parent = nameTag

    local nameLabel = Instance.new("TextLabel")
    nameLabel.Size = UDim2.new(1, 0, 0, _G.ESPStyle.NameSize)
    nameLabel.Position = UDim2.new(0, 0, 0, 0)
    nameLabel.BackgroundTransparency = 1
    nameLabel.Text = plr.Name
    nameLabel.TextColor3 = Color3.new(1, 0, 0)
    nameLabel.TextSize = _G.ESPStyle.NameSize
    nameLabel.Font = Enum.Font.GothamBold
    nameLabel.TextXAlignment = Enum.TextXAlignment.Center
    nameLabel.Parent = nameFrame

    local healthTag = Instance.new("BillboardGui")
    healthTag.Name = "ESP_HealthTag"
    healthTag.Size = UDim2.new(0, 50, 0, 50)
    healthTag.AlwaysOnTop = true
    healthTag.MaxDistance = 9e9
    healthTag.StudsOffset = _G.ESPStyle.HealthOffset
    healthTag.Parent = CoreGui

    local healthScale = Instance.new("UIScale")
    healthScale.Parent = healthTag

    local healthFrame = Instance.new("Frame")
    healthFrame.Size = UDim2.new(1, 0, 1, 0)
    healthFrame.BackgroundTransparency = 1
    healthFrame.Parent = healthTag

    local percentLabel = Instance.new("TextLabel")
    percentLabel.Size = UDim2.new(1, 0, 0, 14)
    percentLabel.Position = UDim2.new(0, 0, 0, 2)
    percentLabel.BackgroundTransparency = 1
    percentLabel.Text = ""
    percentLabel.TextColor3 = Color3.new(0, 1, 0)
    percentLabel.TextSize = _G.ESPStyle.HealthTextSize
    percentLabel.Font = Enum.Font.GothamBold
    percentLabel.TextXAlignment = Enum.TextXAlignment.Center
    percentLabel.Parent = healthFrame

    local barHolder = Instance.new("Frame")
    barHolder.Size = UDim2.new(0, _G.ESPStyle.BarWidth, 0, _G.ESPStyle.BarHeight)
    barHolder.Position = UDim2.new(0.5, -_G.ESPStyle.BarWidth/2, 0, 18)
    barHolder.BackgroundColor3 = Color3.new(0.3, 0.3, 0.3)
    barHolder.BackgroundTransparency = 0.5
    barHolder.BorderSizePixel = 0
    barHolder.Parent = healthFrame

    local barFill = Instance.new("Frame")
    barFill.Size = UDim2.new(1, 0, 0, 0)
    barFill.Position = UDim2.new(0, 0, 1, 0)
    barFill.BackgroundColor3 = Color3.new(0, 1, 0)
    barFill.BorderSizePixel = 0
    barFill.Parent = barHolder

    local distanceTag = Instance.new("BillboardGui")
    distanceTag.Name = "ESP_DistanceTag"
    distanceTag.Size = UDim2.new(0, 100, 0, 20)
    distanceTag.AlwaysOnTop = true
    distanceTag.MaxDistance = 9e9
    distanceTag.StudsOffset = _G.ESPStyle.DistanceOffset
    distanceTag.Parent = CoreGui

    local distanceScale = Instance.new("UIScale")
    distanceScale.Parent = distanceTag

    local distanceFrame = Instance.new("Frame")
    distanceFrame.Size = UDim2.new(1, 0, 1, 0)
    distanceFrame.BackgroundTransparency = 1
    distanceFrame.Parent = distanceTag

    local distLabel = Instance.new("TextLabel")
    distLabel.Size = UDim2.new(1, 0, 1, 0)
    distLabel.BackgroundTransparency = 1
    distLabel.Text = ""
    distLabel.TextColor3 = Color3.new(1, 1, 1)
    distLabel.TextSize = _G.ESPStyle.DistanceSize
    distLabel.Font = Enum.Font.GothamBold
    distLabel.TextXAlignment = Enum.TextXAlignment.Center
    distLabel.Parent = distanceFrame

    local highlight = nil
    if ESPConfig.ShowBox then
        highlight = Instance.new("Highlight")
        highlight.Name = "ESP_Box"
        highlight.Adornee = plr.Character
        highlight.FillTransparency = 0.85
        highlight.OutlineTransparency = 0
        highlight.OutlineColor = Color3.new(1, 0, 0)
        highlight.Parent = plr.Character
    end

    return {
        nameTag = nameTag,
        nameLabel = nameLabel,
        nameScale = nameScale,
        healthTag = healthTag,
        percentLabel = percentLabel,
        barFill = barFill,
        healthScale = healthScale,
        distanceTag = distanceTag,
        distLabel = distLabel,
        distanceScale = distanceScale,
        highlight = highlight
    }
end

local function isBehindWall(targetPart)
    local camera = Workspace.CurrentCamera
    if not camera then return true end
    local camPos = camera.CFrame.Position
    local targetPos = targetPart.Position
    local direction = (targetPos - camPos)
    local dist = direction.Magnitude
    if dist <= 0.1 then return false end
    direction = direction / dist
    local rayParams = RaycastParams.new()
    rayParams.FilterDescendantsInstances = {player.Character, targetPart.Parent}
    rayParams.FilterType = Enum.RaycastFilterType.Blacklist
    local rayResult = Workspace:Raycast(camPos, direction * (dist - 0.1), rayParams)
    return rayResult ~= nil
end

local function updatePlayerESP(plr)
    local character = plr.Character
    if not character or not character:FindFirstChild("HumanoidRootPart") then
        if playerESPs[plr] then
            local espData = playerESPs[plr]
            espData.nameTag:Destroy()
            espData.healthTag:Destroy()
            espData.distanceTag:Destroy()
            if espData.highlight then espData.highlight:Destroy() end
            playerESPs[plr] = nil
        end
        return
    end

    local root = character:FindFirstChild("HumanoidRootPart")
    local playerRoot = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
    local dist = playerRoot and root and (root.Position - playerRoot.Position).Magnitude or 9999

    local scale = 1
    if _G.ESPStyle.ScaleEnabled then
        local minDist = _G.ESPStyle.ScaleMinDist
        local maxDist = _G.ESPStyle.ScaleMaxDist
        local minScale = _G.ESPStyle.ScaleMin
        local maxScale = _G.ESPStyle.ScaleMax
        if dist <= minDist then
            scale = maxScale
        elseif dist >= maxDist then
            scale = minScale
        else
            local t = (dist - minDist) / (maxDist - minDist)
            scale = maxScale - (maxScale - minScale) * t
        end
    end

    local fade = 0
    if _G.ESPStyle.FadeEnabled then
        local minD = _G.ESPStyle.FadeMinDist
        local maxD = _G.ESPStyle.FadeMaxDist
        fade = math.clamp((dist - minD) / (maxD - minD), 0, 1)
    end

    local blocked = isBehindWall(root)
    local nameColor = blocked and Color3.new(1, 0, 0) or Color3.new(0, 1, 0)

    if not playerESPs[plr] then
        local billboards = createESPBillboards(plr)
        billboards.nameTag.Adornee = root
        billboards.healthTag.Adornee = root
        billboards.distanceTag.Adornee = root
        playerESPs[plr] = billboards
    end

    local espData = playerESPs[plr]

    if espData.nameTag.Adornee ~= root then
        espData.nameTag.Adornee = root
        espData.healthTag.Adornee = root
        espData.distanceTag.Adornee = root
    end

    espData.nameTag.StudsOffset = _G.ESPStyle.NameOffset
    espData.healthTag.StudsOffset = _G.ESPStyle.HealthOffset
    espData.distanceTag.StudsOffset = _G.ESPStyle.DistanceOffset

    espData.nameScale.Scale = scale
    espData.healthScale.Scale = scale
    espData.distanceScale.Scale = scale

    espData.nameLabel.Text = ESPConfig.ShowName and plr.Name or ""
    espData.nameLabel.TextColor3 = nameColor
    espData.nameLabel.TextTransparency = fade

    espData.distLabel.Text = ESPConfig.ShowDistance and (math.floor(dist) .. "m") or ""
    espData.distLabel.TextTransparency = fade

    if ESPConfig.ShowHealth then
        local hum = character:FindFirstChildOfClass("Humanoid") or character:FindFirstChild("Humanoid")
        if hum then
            local hp = hum.Health
            local maxhp = hum.MaxHealth
            local hpPercent = math.clamp(hp / maxhp, 0, 1)

            local hpColor
            if hpPercent >= 0.8 then hpColor = Color3.new(0, 1, 0)
            elseif hpPercent >= 0.3 then hpColor = Color3.new(1, 1, 0)
            else hpColor = Color3.new(1, 0, 0) end

            espData.percentLabel.Text = string.format("%.0f%%", hpPercent * 100)
            espData.percentLabel.TextColor3 = hpColor
            espData.percentLabel.TextTransparency = fade
            espData.barFill.Size = UDim2.new(1, 0, hpPercent, 0)
            espData.barFill.Position = UDim2.new(0, 0, 1, -hpPercent * _G.ESPStyle.BarHeight)
            espData.barFill.BackgroundColor3 = hpColor
        else
            espData.percentLabel.Text = ""
            espData.barFill.Size = UDim2.new(1, 0, 0, 0)
        end
    else
        espData.percentLabel.Text = ""
        espData.barFill.Size = UDim2.new(1, 0, 0, 0)
    end

    if espData.highlight then
        espData.highlight.Enabled = ESPConfig.ShowBox
        espData.highlight.OutlineColor = nameColor
    end
end

local function createItemESP(part, displayName)
    if itemESPs[part] then return end

    local billboard = Instance.new("BillboardGui")
    billboard.Name = "ESP_Item"
    billboard.Size = UDim2.new(0, 150, 0, 40)
    billboard.AlwaysOnTop = true
    billboard.MaxDistance = 9e9
    billboard.StudsOffset = Vector3.new(0, 1, 0)
    billboard.Adornee = part
    billboard.Parent = CoreGui

    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 1, 0)
    frame.BackgroundTransparency = 1
    frame.Parent = billboard

    local nameLabel = Instance.new("TextLabel")
    nameLabel.Size = UDim2.new(1, 0, 0, 18)
    nameLabel.Position = UDim2.new(0, 0, 0, 0)
    nameLabel.BackgroundTransparency = 1
    nameLabel.Text = displayName
    nameLabel.TextColor3 = Color3.new(1, 0.6, 0)
    nameLabel.TextSize = 12
    nameLabel.Font = Enum.Font.GothamBold
    nameLabel.TextXAlignment = Enum.TextXAlignment.Center
    nameLabel.Parent = frame

    local distLabel = Instance.new("TextLabel")
    distLabel.Size = UDim2.new(1, 0, 0, 14)
    distLabel.Position = UDim2.new(0, 0, 0, 20)
    distLabel.BackgroundTransparency = 1
    distLabel.Text = "0m"
    distLabel.TextColor3 = Color3.new(1, 1, 1)
    distLabel.TextSize = 11
    distLabel.Font = Enum.Font.Gotham
    distLabel.TextXAlignment = Enum.TextXAlignment.Center
    distLabel.Parent = frame

    itemESPs[part] = {billboard = billboard, distLabel = distLabel}
end

local function refreshItemESP()
    for part, data in pairs(itemESPs) do
        if not part or not part.Parent then
            data.billboard:Destroy()
            itemESPs[part] = nil
        else
            local root = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
            local dist = root and (part.Position - root.Position).Magnitude or 9999
            data.distLabel.Text = math.floor(dist) .. "m"
        end
    end

    if not ESPConfig.ItemESP then
        for part, data in pairs(itemESPs) do
            data.billboard:Destroy()
            itemESPs[part] = nil
        end
        return
    end

    local meatFolder = Workspace:FindFirstChild("PickupableItemsFolder")
    if meatFolder then
        for _, model in ipairs(meatFolder:GetChildren()) do
            if model:IsA("Model") then
                local mainPart = model:FindFirstChild(model.Name) or model.PrimaryPart
                if mainPart and not itemESPs[mainPart] then
                    createItemESP(mainPart, "肉")
                end
            end
        end
    end

    local carcassFolder = Workspace:FindFirstChild("CarcassesStorageModel")
    if carcassFolder then
        for _, model in ipairs(carcassFolder:GetChildren()) do
            if model:IsA("Model") then
                local mainPart = model:FindFirstChild("Body") or model.PrimaryPart
                if mainPart and not itemESPs[mainPart] then
                    createItemESP(mainPart, "尸体")
                end
            end
        end
    end
end

local function removePlayerESP(plr)
    if playerESPs[plr] then
        local espData = playerESPs[plr]
        espData.nameTag:Destroy()
        espData.healthTag:Destroy()
        espData.distanceTag:Destroy()
        if espData.highlight then espData.highlight:Destroy() end
        playerESPs[plr] = nil
    end
end

function refreshAllESP()
    for plr, _ in pairs(playerESPs) do
        if not plr.Parent or plr == player then
            removePlayerESP(plr)
        end
    end

    if not ESPConfig.Enabled then
        for plr, _ in pairs(playerESPs) do
            removePlayerESP(plr)
        end
    else
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr ~= player then
                updatePlayerESP(plr)
            end
        end
    end

    refreshItemESP()
end

Players.PlayerAdded:Connect(function(plr)
    if plr ~= player then
        if ESPConfig.Enabled then updatePlayerESP(plr) end
        plr.CharacterAdded:Connect(function()
            if ESPConfig.Enabled then updatePlayerESP(plr) end
        end)
    end
end)
Players.PlayerRemoving:Connect(function(plr) removePlayerESP(plr) end)

for _, plr in ipairs(Players:GetPlayers()) do
    if plr ~= player then
        plr.CharacterAdded:Connect(function()
            if ESPConfig.Enabled then updatePlayerESP(plr) end
        end)
    end
end

local lastRefresh = 0
local REFRESH_INTERVAL = 0.3
RunService.Heartbeat:Connect(function()
    if ESPConfig.Enabled or ESPConfig.ItemESP then
        if (tick() - lastRefresh >= REFRESH_INTERVAL) then
            lastRefresh = tick()
            refreshAllESP()
        end
    end
end)

Tabs.ESP:AddToggle("ESPEnabled", {
    Title = "ESP总开关",
    Default = false,
    Callback = function(v)
        ESPConfig.Enabled = v
        if not v then
            for plr, _ in pairs(playerESPs) do removePlayerESP(plr) end
        end
    end
})
Tabs.ESP:AddToggle("ESPShowName", { Title = "显示名称", Default = false, Callback = function(v) ESPConfig.ShowName = v end })
Tabs.ESP:AddToggle("ESPShowDistance", { Title = "显示距离", Default = false, Callback = function(v) ESPConfig.ShowDistance = v end })
Tabs.ESP:AddToggle("ESPShowHealth", { Title = "显示血量", Default = false, Callback = function(v) ESPConfig.ShowHealth = v end })
Tabs.ESP:AddToggle("ESPShowBox", { Title = "显示方框", Default = false, Callback = function(v) ESPConfig.ShowBox = v end })
Tabs.ESP:AddToggle("ESPItemESP", { Title = "肉/尸体透视", Default = false, Callback = function(v) ESPConfig.ItemESP = v end })

local infiniteStaminaEnabled = false
Tabs.Home:AddToggle("InfiniteStamina", {
    Title = "无限体力",
    Default = false,
    Callback = function(v)
        infiniteStaminaEnabled = v
        if v then
            task.spawn(function()
                while infiniteStaminaEnabled do
                    local char = player.Character
                    if char then pcall(function() char:SetAttribute("Stamina", 100) end) end
                    task.wait(0.1)
                end
            end)
        end
    end
})

local sprintBoostEnabled = false
local BOOST_MULTIPLIER = 1.5
local sprintOrigCache = {}

local function applySprintBoostToConfig()
    local char = player.Character
    if not char then return end
    local animalName = char:GetAttribute("AnimalName")
    if not animalName then return end

    local configModule = game:GetService("ReplicatedStorage").Shared.AnimalConfig
    if not configModule or not configModule:IsA("ModuleScript") then return end
    local config = require(configModule)
    if not config then return end

    local dinoConfig
    for _, cat in ipairs({"LandDinos", "AquaticDinos", "FlyingDinos"}) do
        if config[cat] and config[cat][animalName] then
            dinoConfig = config[cat][animalName]
            break
        end
    end
    if not dinoConfig or not dinoConfig.MaleStats or not dinoConfig.MaleStats.MovementSpeeds then return end

    local speeds = dinoConfig.MaleStats.MovementSpeeds
    local divider = dinoConfig.BabySpeedReductionDivider

    if sprintBoostEnabled then
        if not sprintOrigCache[animalName] then
            sprintOrigCache[animalName] = {
                sprint = speeds.Sprinting,
                divider = divider
            }
        end
        speeds.Sprinting = sprintOrigCache[animalName].sprint * BOOST_MULTIPLIER
        if divider then
            dinoConfig.BabySpeedReductionDivider = sprintOrigCache[animalName].divider / BOOST_MULTIPLIER
        end
    else
        if sprintOrigCache[animalName] then
            speeds.Sprinting = sprintOrigCache[animalName].sprint
            if divider then
                dinoConfig.BabySpeedReductionDivider = sprintOrigCache[animalName].divider
            end
            sprintOrigCache[animalName] = nil
        end
    end
end

local function enableSprintBoost()
    sprintBoostEnabled = true
    applySprintBoostToConfig()
    player.CharacterAdded:Connect(function()
        if sprintBoostEnabled then
            task.wait(0.5)
            applySprintBoostToConfig()
        end
    end)
end

local function disableSprintBoost()
    sprintBoostEnabled = false
    applySprintBoostToConfig()
end

Tabs.Home:AddToggle("SprintBoost", {
    Title = "冲刺加速",
    Default = false,
    Callback = function(v)
        if v then enableSprintBoost() else disableSprintBoost() end
    end
})

local swimBoostEnabled = false
local SWIM_SPEED = 70

local function applySwimBoostToConfig()
    local char = player.Character
    if not char then return end
    local animalName = char:GetAttribute("AnimalName")
    if not animalName then return end
    
    local configModule = game:GetService("ReplicatedStorage").Shared.AnimalConfig
    if not configModule or not configModule:IsA("ModuleScript") then return end
    local config = require(configModule)
    if not config then return end
    
    local categories = {"LandDinos", "AquaticDinos", "FlyingDinos"}
    for _, cat in ipairs(categories) do
        local category = config[cat]
        if category and category[animalName] then
            local dinoConfig = category[animalName]
            if dinoConfig.MaleStats and dinoConfig.MaleStats.MovementSpeeds then
                dinoConfig.MaleStats.MovementSpeeds.Swimming = SWIM_SPEED
            end
            if dinoConfig.FreeDiveSwimmingConfig then
                dinoConfig.FreeDiveSwimmingConfig.SlowSwimSpeed = SWIM_SPEED
                dinoConfig.FreeDiveSwimmingConfig.FastSwimSpeed = SWIM_SPEED
            end
            break
        end
    end
end

local function enableSwimBoost()
    swimBoostEnabled = true
    applySwimBoostToConfig()
    player.CharacterAdded:Connect(function()
        if swimBoostEnabled then
            task.wait(0.5)
            applySwimBoostToConfig()
        end
    end)
end

local function disableSwimBoost()
    swimBoostEnabled = false
end

Tabs.Home:AddToggle("SwimBoost", {
    Title = "游泳加速",
    Default = false,
    Callback = function(v)
        if v then enableSwimBoost() else disableSwimBoost() end
    end
})

local noFallEnabled = false
local fallOrigCache = {}

local function applyNoFallDamage()
    local configModule = game:GetService("ReplicatedStorage").Shared.AnimalConfig
    if not configModule or not configModule:IsA("ModuleScript") then return end
    local config = require(configModule)
    if not config then return end

    for _, cat in ipairs({"LandDinos", "AquaticDinos", "FlyingDinos"}) do
        local category = config[cat]
        if category then
            for name, dino in pairs(category) do
                if dino.FallDamageHeights then
                    if not fallOrigCache[name] then
                        fallOrigCache[name] = {
                            min = dino.FallDamageHeights.Min,
                            max = dino.FallDamageHeights.Max
                        }
                    end
                    if noFallEnabled then
                        dino.FallDamageHeights.Min = 1e9
                        dino.FallDamageHeights.Max = 1e9
                    else
                        local orig = fallOrigCache[name]
                        if orig then
                            dino.FallDamageHeights.Min = orig.min
                            dino.FallDamageHeights.Max = orig.max
                        end
                    end
                end
            end
        end
    end
end

Tabs.Home:AddToggle("NoFallDamage", {
    Title = "无摔落伤害",
    Default = false,
    Callback = function(v)
        noFallEnabled = v
        applyNoFallDamage()
    end
})

pcall(function()
    local SaveManagerBuilder = safeLoadBuilder("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/SaveManager.lua")
    local InterfaceManagerBuilder = safeLoadBuilder("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/InterfaceManager.lua")
    if SaveManagerBuilder and InterfaceManagerBuilder then
        local SaveManager = SaveManagerBuilder()
        local InterfaceManager = InterfaceManagerBuilder()
        SaveManager:SetLibrary(Fluent)
        InterfaceManager:SetLibrary(Fluent)
        SaveManager:IgnoreThemeSettings()
        SaveManager:SetIgnoreIndexes({})
        InterfaceManager:SetFolder("FluentScriptHub")
        SaveManager:SetFolder("FluentScriptHub/specific-game")
        InterfaceManager:BuildInterfaceSection(Tabs.Settings)
        SaveManager:BuildConfigSection(Tabs.Settings)
        Window:SelectTab(1)
        SaveManager:LoadAutoloadConfig()
    end
end)
