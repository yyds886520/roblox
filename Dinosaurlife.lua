local WindUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/Footagesus/WindUI/main/dist/main.lua"))()
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local CoreGui = game:GetService("CoreGui")
local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Lighting = game:GetService("Lighting")

local icons = {"skull", "star", "heart", "crown", "shield", "wrench", "rocket", "fire", "bolt", "moon", "sun", "globe", "terminal", "gamepad", "dollar-sign", "gift", "plane", "ship", "car", "bicycle", "tree", "flower", "snowflake", "rainbow", "flask", "atom", "satellite", "wifi", "folder", "calendar", "clock", "alarm", "mail", "phone", "laptop", "play", "pause", "infinity", "thumbs-up", "pray", "yinyang", "earth-americas", "volcano", "campfire", "medkit", "ambulance", "wheelchair", "universal-access", "bug", "lightbulb", "coffee"}

local Window = WindUI:CreateWindow({
    Title = "恐龙生活",
    Icon = icons[math.random(#icons)],
    Author = "by.小梦",
    Folder = "DinoLife",
    Size = UDim2.fromOffset(480, 400),
    Theme = "Dark",
    SideBarWidth = 160,
    Transparent = true,
    BackgroundImageTransparency = 0.3,
    User = { Enabled = false },
})

Window:EditOpenButton({
    Title = "打开/关闭",
    Icon = icons[math.random(#icons)],
    CornerRadius = UDim.new(0, 8),
    StrokeThickness = 2.5,
    Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 0, 0)),
        ColorSequenceKeypoint.new(0.17, Color3.fromRGB(255, 255, 0)),
        ColorSequenceKeypoint.new(0.33, Color3.fromRGB(0, 255, 0)),
        ColorSequenceKeypoint.new(0.5, Color3.fromRGB(0, 255, 255)),
        ColorSequenceKeypoint.new(0.67, Color3.fromRGB(0, 0, 255)),
        ColorSequenceKeypoint.new(0.83, Color3.fromRGB(255, 0, 255)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 0, 0)),
    }),
    Draggable = true,
})

local globalResetCallbacks = {}

local CombatTab = Window:Tab({ Title = "战斗", Icon = "swords" })
local MoveTab = Window:Tab({ Title = "移动", Icon = "run" })
local ESPTab = Window:Tab({ Title = "ESP", Icon = "eye" })

local AttackHandlerEvent = ReplicatedStorage:WaitForChild("AttackHandlerRemoteEvent")
local SpecialRegularEvent = ReplicatedStorage:WaitForChild("SpecialAttackRemoteEvent_RegularAttack")
local auraEnabled = false
local auraThread = nil
local ATTACK_COOLDOWN = 0.5

local function getAttackEventForCurrentDino()
    local char = player.Character
    if not char then return nil end
    local animalName = char:GetAttribute("AnimalName")
    if not animalName then return nil end
    local success, configModule = pcall(function()
        return require(ReplicatedStorage.Shared.AnimalConfig)
    end)
    if not success or not configModule then return nil end
    for _, cat in ipairs({"LandDinos", "AquaticDinos", "FlyingDinos"}) do
        local category = configModule[cat]
        if category and category[animalName] then
            local dino = category[animalName]
            if dino.SpecialAttackConfig then
                local attackType = dino.SpecialAttackConfig.Type
                if attackType == "Regular" then
                    return SpecialRegularEvent
                else
                    return AttackHandlerEvent
                end
            else
                return AttackHandlerEvent
            end
        end
    end
    return nil
end

local function doAttack(target)
    local event = getAttackEventForCurrentDino()
    if event then
        pcall(function() event:FireServer(target) end)
    else
        pcall(function() AttackHandlerEvent:FireServer(target) end)
        pcall(function() SpecialRegularEvent:FireServer(target) end)
    end
end

local function getNearestEnemy(range)
    local char = player.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    if not root then return nil end
    local nearest, nearestDist = nil, range
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr == player then continue end
        local c = plr.Character
        if c and c:FindFirstChild("HumanoidRootPart") and c:FindFirstChild("Humanoid") and c.Humanoid.Health > 0 then
            local d = (c.HumanoidRootPart.Position - root.Position).Magnitude
            if d < nearestDist then
                nearestDist = d
                nearest = c.Humanoid
            end
        end
    end
    return nearest
end

CombatTab:Toggle({
    Title = "杀戮光环",
    Default = false,
    Callback = function(v)
        auraEnabled = v
        if v then
            auraThread = task.spawn(function()
                while auraEnabled do
                    local target = getNearestEnemy(39)
                    if target then
                        doAttack(target)
                    end
                    task.wait(ATTACK_COOLDOWN)
                end
            end)
        else
            auraEnabled = false
            auraThread = nil
        end
    end,
})
table.insert(globalResetCallbacks, function() auraEnabled = false auraThread = nil end)

local latchEvent = ReplicatedStorage:WaitForChild("LatchedPlayersNotifyRemoteEvent")
local escapeEnabled = false
local escapeConnection = nil

local function isLatched()
    return playerGui:FindFirstChild("ExitLatchScreenGui") ~= nil
end

local function tryEscape()
    pcall(function() latchEvent:FireServer() end)
end

local function enableEscape()
    escapeEnabled = true
    if escapeConnection then escapeConnection:Disconnect() end
    escapeConnection = playerGui.DescendantAdded:Connect(function(desc)
        if desc.Name == "ExitLatchScreenGui" and desc:IsA("ScreenGui") then
            task.spawn(function()
                while isLatched() and escapeEnabled do
                    tryEscape()
                    task.wait(0.1)
                end
            end)
        end
    end)
    if isLatched() then
        task.spawn(function()
            while isLatched() and escapeEnabled do
                tryEscape()
                task.wait(0.1)
            end
        end)
    end
end

local function disableEscape()
    escapeEnabled = false
    if escapeConnection then
        escapeConnection:Disconnect()
        escapeConnection = nil
    end
end

CombatTab:Toggle({
    Title = "自动逃脱",
    Default = false,
    Callback = function(v)
        if v then enableEscape() else disableEscape() end
    end,
})
table.insert(globalResetCallbacks, disableEscape)

local infiniteStaminaEnabled = false
local staminaThread = nil
MoveTab:Toggle({
    Title = "无限体力",
    Default = false,
    Callback = function(v)
        infiniteStaminaEnabled = v
        if v then
            staminaThread = task.spawn(function()
                while infiniteStaminaEnabled do
                    local char = player.Character
                    if char then pcall(function() char:SetAttribute("Stamina", 100) end) end
                    task.wait(0.1)
                end
            end)
        else
            infiniteStaminaEnabled = false
            staminaThread = nil
        end
    end,
})
table.insert(globalResetCallbacks, function() infiniteStaminaEnabled = false staminaThread = nil end)

local sprintBoostEnabled = false
local sprintOrigCache = {}
local BOOST_MULTIPLIER = 1.5

local function applySprintBoostToConfig()
    local char = player.Character
    if not char then return end
    local animalName = char:GetAttribute("AnimalName")
    if not animalName then return end
    local configModule = ReplicatedStorage.Shared.AnimalConfig
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

MoveTab:Toggle({
    Title = "冲刺加速",
    Default = false,
    Callback = function(v)
        sprintBoostEnabled = v
        applySprintBoostToConfig()
    end,
})
table.insert(globalResetCallbacks, function() sprintBoostEnabled = false applySprintBoostToConfig() end)

local swimBoostEnabled = false
local SWIM_SPEED = 70

local function applySwimBoostToConfig()
    local char = player.Character
    if not char then return end
    local animalName = char:GetAttribute("AnimalName")
    if not animalName then return end
    local configModule = ReplicatedStorage.Shared.AnimalConfig
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

MoveTab:Toggle({
    Title = "游泳加速",
    Default = false,
    Callback = function(v)
        swimBoostEnabled = v
        if v then applySwimBoostToConfig() end
    end,
})
table.insert(globalResetCallbacks, function() swimBoostEnabled = false end)

local noFallEnabled = false
local fallOrigCache = {}

local function applyNoFallDamage()
    local configModule = ReplicatedStorage.Shared.AnimalConfig
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

MoveTab:Toggle({
    Title = "无摔落伤害",
    Default = false,
    Callback = function(v)
        noFallEnabled = v
        applyNoFallDamage()
    end,
})
table.insert(globalResetCallbacks, function() noFallEnabled = false applyNoFallDamage() end)

local clearVisionEnabled = false
MoveTab:Toggle({
    Title = "一键清晰",
    Default = false,
    Callback = function(v)
        clearVisionEnabled = v
        if v then
            Lighting.Ambient = Color3.new(1, 1, 1)
            Lighting.Brightness = 2
            Lighting.FogEnd = 100000
            Lighting.GlobalShadows = false
            for _, effect in ipairs(Lighting:GetDescendants()) do
                if effect:IsA("PostEffect") then
                    effect.Enabled = false
                end
                if effect:IsA("Atmosphere") then
                    effect:Destroy()
                end
            end
        else
            Lighting.Ambient = Color3.new(0, 0, 0)
            Lighting.Brightness = 1
            Lighting.FogEnd = 100000
            Lighting.GlobalShadows = true
        end
    end,
})
table.insert(globalResetCallbacks, function()
    clearVisionEnabled = false
    Lighting.Ambient = Color3.new(0, 0, 0)
    Lighting.Brightness = 1
    Lighting.FogEnd = 100000
    Lighting.GlobalShadows = true
end)

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

for _, v in ipairs(CoreGui:GetChildren()) do
    if v.Name:find("ESP_") then v:Destroy() end
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

    local blocked = (dist > 150) or isBehindWall(root)
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

    if not ESPConfig.ItemESP or not ESPConfig.Enabled then
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

local function clearAllESP()
    for plr, _ in pairs(playerESPs) do
        removePlayerESP(plr)
    end
    for part, data in pairs(itemESPs) do
        data.billboard:Destroy()
        itemESPs[part] = nil
    end
end

function refreshAllESP()
    for plr, _ in pairs(playerESPs) do
        if not plr.Parent or plr == player then
            removePlayerESP(plr)
        end
    end

    if not ESPConfig.Enabled then
        clearAllESP()
    else
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr ~= player then
                updatePlayerESP(plr)
            end
        end
        refreshItemESP()
    end
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
local REFRESH_INTERVAL = 1.0
RunService.Heartbeat:Connect(function()
    if ESPConfig.Enabled or ESPConfig.ItemESP then
        if (tick() - lastRefresh >= REFRESH_INTERVAL) then
            lastRefresh = tick()
            refreshAllESP()
        end
    end
end)

ESPTab:Toggle({
    Title = "ESP总开关",
    Default = false,
    Callback = function(v)
        ESPConfig.Enabled = v
        if not v then
            clearAllESP()
            ESPConfig.ItemESP = false
        end
    end
})
ESPTab:Toggle({ Title = "显示名称", Default = false, Callback = function(v) ESPConfig.ShowName = v end })
ESPTab:Toggle({ Title = "显示距离", Default = false, Callback = function(v) ESPConfig.ShowDistance = v end })
ESPTab:Toggle({ Title = "显示血量", Default = false, Callback = function(v) ESPConfig.ShowHealth = v end })
ESPTab:Toggle({ Title = "显示方框", Default = false, Callback = function(v) ESPConfig.ShowBox = v end })
ESPTab:Toggle({ Title = "肉/尸体透视", Default = false, Callback = function(v) ESPConfig.ItemESP = v end })

table.insert(globalResetCallbacks, function()
    ESPConfig.Enabled = false
    ESPConfig.ItemESP = false
    clearAllESP()
end)

task.spawn(function()
    while true do
        task.wait(0.5)
        local folder = CoreGui:FindFirstChild("DinoLife")
        if not folder or not folder.Parent then
            for _, reset in ipairs(globalResetCallbacks) do
                pcall(reset)
            end
            break
        end
    end
end)

Window:SelectTab(1)
