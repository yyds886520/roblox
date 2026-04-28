local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
local SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/SaveManager.lua"))()
local InterfaceManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/InterfaceManager.lua"))()

local AUTHOR_IDS = {
    7483594265
}

local Window = Fluent:CreateWindow({
    Title = "我的世界Hub",
    SubTitle = "by.小梦",
    TabWidth = 160,
    Size = UDim2.fromOffset(580, 360),
    Acrylic = false,
    Theme = "Darker",
    MinimizeKey = Enum.KeyCode.LeftControl
})

local Tabs = {
    Info = Window:AddTab({ Title = "信息", Icon = "info" }),
    Main = Window:AddTab({ Title = "主要", Icon = "box" }),
    ESP = Window:AddTab({ Title = "ESP", Icon = "eye" }),
    PVP = Window:AddTab({ Title = "PVP", Icon = "swords" }),
    Other = Window:AddTab({ Title = "其他", Icon = "settings" })
}

do
    local CUSTOM_IMAGE = "rbxassetid://10709791437"
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "FluentFloatButton"
    screenGui.ResetOnSpawn = false
    screenGui.Parent = game:GetService("CoreGui")

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
    local dragStartPos, buttonStartPos
    local uis = game:GetService("UserInputService")

    button.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStartPos = input.Position
            buttonStartPos = button.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
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

Tabs.Info:AddParagraph({ Title = "您的用户昵称", Content = " " .. player.DisplayName })
Tabs.Info:AddParagraph({ Title = "您的用户名", Content = " " .. player.Name })
Tabs.Info:AddParagraph({ Title = "您的用户ID", Content = " " .. player.UserId })

local clientId = "未知"
pcall(function()
    if getclientid then
        clientId = getclientid()
    else
        clientId = game:GetService("RbxAnalyticsService"):GetClientId()
    end
end)
Tabs.Info:AddParagraph({ Title = "您的客户端ID", Content = " " .. clientId })

local region = "未知"
pcall(function()
    if getregion then
        region = getregion()
    else
        local success, result = pcall(function()
            return game:HttpGet("http://ip-api.com/json/")
        end)
        if success and result then
            local data = game:GetService("HttpService"):JSONDecode(result)
            if data and data.countryCode then
                region = data.countryCode
            end
        end
    end
end)
if region == "未知" then
    pcall(function()
        region = game:GetService("LocalizationService").RobloxLocaleId or "未知"
    end)
end
Tabs.Info:AddParagraph({ Title = "您的地区", Content = " " .. region })

local language = "未知"
pcall(function()
    language = player.LocaleId or "未知"
end)
Tabs.Info:AddParagraph({ Title = "您的语言", Content = " " .. language })

local accountAge = 0
pcall(function()
    accountAge = player.AccountAge
end)
Tabs.Info:AddParagraph({ Title = "您的账户年龄(天)", Content = " " .. accountAge })
Tabs.Info:AddParagraph({ Title = "您的账户年龄(年)", Content = " " .. string.format("%.1f", accountAge / 365) })

local executorName = "未知"
pcall(function()
    executorName = identifyexecutor() or "未知"
end)
Tabs.Info:AddParagraph({ Title = "您使用的注入器", Content = " " .. executorName })

Tabs.Info:AddParagraph({ Title = "您当前服务器的ID", Content = " " .. game.GameId })

local placeId = "未知"
pcall(function()
    placeId = game.PlaceId or game.GameId
end)
Tabs.Info:AddParagraph({ Title = "您当前的服务器位置ID", Content = " " .. placeId })

local playerCount = #Players:GetPlayers()
Tabs.Info:AddParagraph({ Title = "当前服务器总人数", Content = " " .. playerCount })

local pingParagraph = Tabs.Info:AddParagraph({ Title = "您的Ping", Content = " 加载中..." })
local fpsParagraph = Tabs.Info:AddParagraph({ Title = "您的FPS", Content = " 加载中..." })
local timeParagraph = Tabs.Info:AddParagraph({ Title = "时间", Content = " 加载中..." })

task.spawn(function()
    while true do
        local pingValue = "N/A"
        pcall(function()
            local success, ping = pcall(function()
                return Players.LocalPlayer:GetNetworkPing()
            end)
            if success and ping then
                pingValue = math.floor(ping * 1000) .. " ms"
            else
                success, ping = pcall(function()
                    return game:GetService("Stats").PerformanceStats.NetworkPing
                end)
                if success and ping then
                    pingValue = math.floor(ping) .. " ms"
                else
                    success, ping = pcall(function()
                        return game:GetService("NetworkClient"):GetNetworkPing()
                    end)
                    if success and ping then
                        pingValue = math.floor(ping * 1000) .. " ms"
                    end
                end
            end
        end)
        local fpsValue = "N/A"
        pcall(function()
            fpsValue = math.floor(1 / RunService.Heartbeat:Wait()) .. " FPS"
        end)
        local timeString = os.date("%H:%M:%S")
        pcall(function()
            pingParagraph:SetDesc(" " .. pingValue)
            fpsParagraph:SetDesc(" " .. fpsValue)
            timeParagraph:SetDesc(" " .. timeString)
        end)
        task.wait(0.5)
    end
end)

local authorESPEnabled = false
local authorTags = {}
local authorNotificationGui

local function createAuthorTag(character, playerName)
    if authorTags[character] then return end
    local head = character:WaitForChild("HeadPart", 10)
    if not head then return end

    local billboard = Instance.new("BillboardGui")
    billboard.Adornee = head
    billboard.Size = UDim2.new(0, 200, 0, 50)
    billboard.StudsOffset = Vector3.new(0, 3, 0)
    billboard.AlwaysOnTop = true
    billboard.MaxDistance = 300
    billboard.Name = "AuthorTag"

    local background = Instance.new("Frame")
    background.Size = UDim2.new(0, 80, 0, 26)
    background.AnchorPoint = Vector2.new(0.5, 0.5)
    background.Position = UDim2.new(0.5, 0, 0.5, 0)
    background.BackgroundColor3 = Color3.fromRGB(255, 215, 0)
    background.BorderSizePixel = 0
    background.Parent = billboard

    Instance.new("UICorner", background).CornerRadius = UDim.new(0, 6)

    local stroke = Instance.new("UIStroke")
    stroke.Thickness = 2
    stroke.Color = Color3.fromRGB(255, 0, 0)
    stroke.Parent = background

    local textLabel = Instance.new("TextLabel")
    textLabel.Size = UDim2.fromScale(1, 1)
    textLabel.BackgroundTransparency = 1
    textLabel.Text = "作者"
    textLabel.TextColor3 = Color3.fromRGB(255, 0, 0)
    textLabel.TextStrokeTransparency = 0
    textLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
    textLabel.Font = Enum.Font.SourceSansBold
    textLabel.TextSize = 18
    textLabel.Parent = background

    billboard.Parent = game:GetService("CoreGui")

    authorTags[character] = {
        billboard = billboard,
        stroke = stroke,
        textLabel = textLabel
    }

    local hue = 0
    task.spawn(function()
        while authorTags[character] do
            hue = (hue + 0.02) % 1
            local color = Color3.fromHSV(hue, 1, 1)
            pcall(function()
                textLabel.TextColor3 = color
                stroke.Color = Color3.fromHSV((hue + 0.5) % 1, 1, 1)
            end)
            task.wait(0.05)
        end
    end)
end

local function removeAuthorTag(character)
    local tag = authorTags[character]
    if tag then
        tag.billboard:Destroy()
        authorTags[character] = nil
    end
end

local function showAuthorNotification(playerName)
    if authorNotificationGui then
        authorNotificationGui:Destroy()
    end
    local gui = Instance.new("ScreenGui")
    gui.Name = "AuthorNotification"
    gui.ResetOnSpawn = false
    gui.Parent = game:GetService("CoreGui")
    authorNotificationGui = gui

    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 280, 0, 60)
    frame.Position = UDim2.new(1, -290, 1, -80)
    frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    frame.BackgroundTransparency = 0.2
    frame.BorderSizePixel = 0
    frame.Parent = gui

    Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 8)

    local stroke = Instance.new("UIStroke")
    stroke.Thickness = 1
    stroke.Color = Color3.fromRGB(255, 215, 0)
    stroke.Parent = frame

    local textLabel = Instance.new("TextLabel")
    textLabel.Size = UDim2.fromScale(1, 1)
    textLabel.BackgroundTransparency = 1
    textLabel.Text = "检测到作者 " .. playerName .. " 进入游戏"
    textLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    textLabel.Font = Enum.Font.SourceSansBold
    textLabel.TextSize = 16
    textLabel.Parent = frame

    task.delay(5, function()
        if authorNotificationGui == gui then
            gui:Destroy()
            authorNotificationGui = nil
        end
    end)
end

local function isAuthor(player)
    for _, id in ipairs(AUTHOR_IDS) do
        if player.UserId == id then
            return true
        end
    end
    return false
end

local function onAuthorAdded(player)
    if not authorESPEnabled then return end
    if player == Players.LocalPlayer then return end
    if isAuthor(player) then
        showAuthorNotification(player.Name)
        if player.Character then
            createAuthorTag(player.Character, player.Name)
        end
        player.CharacterAdded:Connect(function(character)
            createAuthorTag(character, player.Name)
        end)
    end
end

local function onPlayerAdded(player)
    onAuthorAdded(player)
end

local function onPlayerRemoving(player)
    if authorTags[player.Character] then
        removeAuthorTag(player.Character)
    end
end

local function startAuthorESP()
    authorESPEnabled = true
    for _, p in ipairs(Players:GetPlayers()) do
        onAuthorAdded(p)
    end
    Players.PlayerAdded:Connect(onPlayerAdded)
    Players.PlayerRemoving:Connect(onPlayerRemoving)
end

local function stopAuthorESP()
    authorESPEnabled = false
    for character, _ in pairs(authorTags) do
        removeAuthorTag(character)
    end
end

Tabs.Info:AddToggle("AuthorESP", {
    Title = "开启/关闭作者头衔绘制",
    Default = true,
    Callback = function(state)
        if state then
            startAuthorESP()
        else
            stopAuthorESP()
        end
    end
})

task.spawn(function()
    startAuthorESP()
end)

local highlightFolder = Instance.new("Folder")
highlightFolder.Name = "ESP_Highlights"
highlightFolder.Parent = nil

local tagCache = {}

local COLOR_POOL = {
    { text = Color3.fromRGB(255, 80, 80), stroke = Color3.fromRGB(255, 255, 255) },
    { text = Color3.fromRGB(80, 255, 80), stroke = Color3.fromRGB(0, 0, 0) },
    { text = Color3.fromRGB(80, 80, 255), stroke = Color3.fromRGB(255, 255, 255) },
    { text = Color3.fromRGB(255, 255, 0), stroke = Color3.fromRGB(0, 0, 0) },
    { text = Color3.fromRGB(255, 0, 255), stroke = Color3.fromRGB(255, 255, 255) },
    { text = Color3.fromRGB(0, 255, 255), stroke = Color3.fromRGB(0, 0, 0) },
    { text = Color3.fromRGB(255, 128, 0), stroke = Color3.fromRGB(0, 0, 0) },
    { text = Color3.fromRGB(128, 0, 255), stroke = Color3.fromRGB(255, 255, 255) },
}

local usedColorIndices = {}

local function isAliveModel(model)
    return model:FindFirstChildOfClass("Humanoid") ~= nil
end

local function getSheepColorText(model)
    local woolFolder = model:FindFirstChild("Wool")
    local woolParts = {}
    
    if woolFolder then
        for _, part in ipairs(woolFolder:GetDescendants()) do
            if part:IsA("BasePart") then
                table.insert(woolParts, part)
            end
        end
    else
        for _, part in ipairs(model:GetDescendants()) do
            if part:IsA("BasePart") and part.Name:lower():find("wool") then
                table.insert(woolParts, part)
            end
        end
    end

    if #woolParts == 0 then return "羊" end

    local firstWool = woolParts[1]
    local r, g, b = math.floor(firstWool.Color.R * 255), math.floor(firstWool.Color.G * 255), math.floor(firstWool.Color.B * 255)

    if r >= 100 and r <= 200 and g >= 60 and g <= 150 and b >= 40 and b <= 120 and r > g and r > b then
        return "羊(棕色)"
    elseif r > 220 and g > 220 and b > 220 then
        return "羊(白色)"
    elseif r < 50 and g < 50 and b < 50 then
        return "羊(黑色)"
    else
        return "羊"
    end
end

local targets = {
    Deer = { text = "鹿", dynamicText = nil },
    Turkey = { text = "火鸡", dynamicText = nil },
    Sheep = { text = "羊", dynamicText = getSheepColorText },
    Cow = { text = "牛", dynamicText = nil },
    Pig = { text = "猪", dynamicText = nil }
}

local activeColors = {}

local function getUniqueColorIndex()
    local available = {}
    for i, _ in ipairs(COLOR_POOL) do
        if not usedColorIndices[i] then table.insert(available, i) end
    end
    if #available == 0 then return math.random(1, #COLOR_POOL) end
    return available[math.random(1, #available)]
end

local function assignColor(animalKey)
    if activeColors[animalKey] then return end
    local idx = getUniqueColorIndex()
    usedColorIndices[idx] = true
    activeColors[animalKey] = {
        textColor = COLOR_POOL[idx].text,
        strokeColor = COLOR_POOL[idx].stroke,
        poolIndex = idx
    }
end

local function releaseColor(animalKey)
    local data = activeColors[animalKey]
    if data then
        usedColorIndices[data.poolIndex] = nil
        activeColors[animalKey] = nil
    end
end

local function createAnimalTag(model, animalKey, cfg)
    if tagCache[model] then return end
    local displayText = cfg.dynamicText and cfg.dynamicText(model) or cfg.text
    local colors = activeColors[animalKey]
    if not colors then return end

    local billboard = Instance.new("BillboardGui")
    billboard.Adornee = model
    billboard.Size = UDim2.new(0, 200, 0, 30)
    billboard.StudsOffset = Vector3.new(0, 3, 0)
    billboard.AlwaysOnTop = true
    billboard.Name = "ESPTag"

    local label = Instance.new("TextLabel")
    label.Size = UDim2.fromScale(1, 1)
    label.BackgroundTransparency = 1
    label.TextColor3 = colors.textColor
    label.TextStrokeTransparency = 0
    label.TextStrokeColor3 = colors.strokeColor
    label.TextSize = 16
    label.Font = Enum.Font.SourceSansBold
    label.Text = displayText
    label.Parent = billboard

    billboard.Parent = highlightFolder
    tagCache[model] = billboard
end

local function processObject(obj)
    if obj:IsA("Model") and isAliveModel(obj) then
        local animalKey = obj.Name
        if targets[animalKey] and activeColors[animalKey] then
            createAnimalTag(obj, animalKey, targets[animalKey])
        end
    end
end

local function removeTag(instance)
    local billboard = tagCache[instance]
    if billboard then
        billboard:Destroy()
        tagCache[instance] = nil
    end
end

local function clearAllTags()
    for instance, billboard in pairs(tagCache) do
        billboard:Destroy()
    end
    table.clear(tagCache)
    highlightFolder.Parent = nil
end

local function initialScan()
    for _, obj in ipairs(workspace:GetDescendants()) do
        processObject(obj)
    end
end

local descendantAddedConn, descendantRemovingConn

local function ensureEvents()
    if not descendantAddedConn then
        descendantAddedConn = workspace.DescendantAdded:Connect(function(obj)
            processObject(obj)
        end)
    end
    if not descendantRemovingConn then
        descendantRemovingConn = workspace.DescendantRemoving:Connect(function(obj)
            removeTag(obj)
        end)
    end
end

local function disconnectEvents()
    if descendantAddedConn then
        descendantAddedConn:Disconnect()
        descendantAddedConn = nil
    end
    if descendantRemovingConn then
        descendantRemovingConn:Disconnect()
        descendantRemovingConn = nil
    end
end

local function refreshESP()
    clearAllTags()
    local anyActive = false
    for _ in pairs(activeColors) do anyActive = true break end
    if anyActive then
        highlightFolder.Parent = game:GetService("CoreGui")
        ensureEvents()
        initialScan()
    else
        disconnectEvents()
        highlightFolder.Parent = nil
    end
end

local function onToggle(animalKey, state)
    if state then assignColor(animalKey) else releaseColor(animalKey) end
    refreshESP()
end

Tabs.ESP:AddSection("动物透视")

Tabs.ESP:AddToggle("DeerESP", { Title = "鹿", Default = false, Callback = function(s) onToggle("Deer", s) end })
Tabs.ESP:AddToggle("TurkeyESP", { Title = "火鸡", Default = false, Callback = function(s) onToggle("Turkey", s) end })
Tabs.ESP:AddToggle("SheepESP", { Title = "羊", Default = false, Callback = function(s) onToggle("Sheep", s) end })
Tabs.ESP:AddToggle("CowESP", { Title = "牛", Default = false, Callback = function(s) onToggle("Cow", s) end })
Tabs.ESP:AddToggle("PigESP", { Title = "猪", Default = false, Callback = function(s) onToggle("Pig", s) end })

local AttackRemote = game:GetService("ReplicatedStorage").Systems.ActionsSystem.Network.Attack
local autoAttackEnabled = false
local MAX_ATTACK_DISTANCE = 6
local ATTACK_INTERVAL = 0.01

local function getPlayerFromRay()
    local camera = workspace.CurrentCamera
    if not camera then return nil end
    local character = Players.LocalPlayer.Character
    if not character then return nil end

    local ray = camera:ScreenPointToRay(camera.ViewportSize.X / 2, camera.ViewportSize.Y / 2)
    local rayParams = RaycastParams.new()
    rayParams.FilterType = Enum.RaycastFilterType.Exclude
    rayParams.FilterDescendantsInstances = {character}
    
    local rayResult = workspace:Raycast(ray.Origin, ray.Direction * MAX_ATTACK_DISTANCE, rayParams)
    if not rayResult then return nil end

    local hitPart = rayResult.Instance
    local model = hitPart
    while model do
        if model:IsA("Model") and model:FindFirstChildOfClass("Humanoid") then
            return model
        end
        model = model.Parent
    end
    return nil
end

local function startAutoAttack()
    task.spawn(function()
        while autoAttackEnabled do
            if autoAttackEnabled then
                local targetModel = getPlayerFromRay()
                if targetModel and targetModel ~= Players.LocalPlayer.Character then
                    pcall(function()
                        AttackRemote:InvokeServer(targetModel, "4")
                    end)
                end
            end
            task.wait(ATTACK_INTERVAL)
        end
    end)
end

Tabs.PVP:AddToggle("AutoAttack", {
    Title = "自动攻击",
    Default = false,
    Callback = function(state)
        autoAttackEnabled = state
        if state then
            startAutoAttack()
        end
    end
})

local FallDamageRemote = game:GetService("ReplicatedStorage").Systems.CombatSystem.Network.FallDamage
local noFallEnabled = false
local oldNamecall

local function enableNoFall()
    if noFallEnabled then return end
    noFallEnabled = true
    if not oldNamecall then
        local mt = getrawmetatable(FallDamageRemote)
        oldNamecall = mt.__namecall
        setreadonly(mt, false)
        mt.__namecall = function(self, ...)
            local method = getnamecallmethod()
            local args = {...}
            if method == "FireServer" and self == FallDamageRemote and noFallEnabled then
                return oldNamecall(self, 0)
            end
            return oldNamecall(self, ...)
        end
        setreadonly(mt, true)
    end
end

local function disableNoFall()
    noFallEnabled = false
end

game:GetService("Players").LocalPlayer.CharacterAdded:Connect(function()
    if noFallEnabled then
        disableNoFall()
        task.wait(0.1)
        enableNoFall()
    end
end)

local nightVisionEnabled = false

local function enableNightVision()
    if nightVisionEnabled then return end
    nightVisionEnabled = true
    game:GetService("Lighting").Ambient = Color3.new(1, 1, 1)
end

local function disableNightVision()
    nightVisionEnabled = false
    game:GetService("Lighting").Ambient = Color3.new(0, 0, 0)
end

local infiniteJumpEnabled = false
local jumpConn = nil

local function enableInfiniteJump()
    if infiniteJumpEnabled then return end
    infiniteJumpEnabled = true
    jumpConn = game:GetService("UserInputService").JumpRequest:Connect(function()
        local humanoid = game.Players.LocalPlayer.Character and
                         game.Players.LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if humanoid then
            humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
        end
    end)
end

local function disableInfiniteJump()
    infiniteJumpEnabled = false
    if jumpConn then
        jumpConn:Disconnect()
        jumpConn = nil
    end
end

local lastDeathPosition = nil

game:GetService("Players").LocalPlayer.CharacterAdded:Connect(function(character)
    local humanoid = character:WaitForChild("Humanoid")
    humanoid.Died:Connect(function()
        lastDeathPosition = character:GetPivot().Position
    end)
end)

if game.Players.LocalPlayer.Character then
    local humanoid = game.Players.LocalPlayer.Character:FindFirstChild("Humanoid")
    if humanoid then
        humanoid.Died:Connect(function()
            lastDeathPosition = game.Players.LocalPlayer.Character:GetPivot().Position
        end)
    end
end

Tabs.Main:AddButton({
    Title = "返回死亡点",
    Callback = function()
        if not lastDeathPosition then
            Fluent:Notify({ Title = "返回死亡点", Content = "尚未记录死亡位置", Duration = 5 })
            return
        end
        local character = game.Players.LocalPlayer.Character
        if not character then
            Fluent:Notify({ Title = "返回死亡点", Content = "角色不存在", Duration = 5 })
            return
        end
        local root = character:FindFirstChild("HumanoidRootPart")
        if not root then
            Fluent:Notify({ Title = "返回死亡点", Content = "找不到 HumanoidRootPart", Duration = 5 })
            return
        end

        local rayOrigin = lastDeathPosition + Vector3.new(0, 20, 0)
        local rayDir = Vector3.new(0, -50, 0)
        local rayParams = RaycastParams.new()
        rayParams.FilterType = Enum.RaycastFilterType.Exclude
        rayParams.FilterDescendantsInstances = {character}

        local rayResult = workspace:Raycast(rayOrigin, rayDir, rayParams)
        local safePos
        if rayResult then
            safePos = rayResult.Position + Vector3.new(0, 3, 0)
        else
            safePos = lastDeathPosition + Vector3.new(0, 10, 0)
        end

        root.CFrame = CFrame.new(safePos)
        root.AssemblyLinearVelocity = Vector3.zero
        root.AssemblyAngularVelocity = Vector3.zero
    end
})

Tabs.Main:AddToggle("NoFall", {
    Title = "无伤害落地",
    Default = false,
    Callback = function(state)
        if state then enableNoFall() else disableNoFall() end
    end
})

Tabs.Main:AddToggle("NightVision", {
    Title = "夜视",
    Default = false,
    Callback = function(state)
        if state then enableNightVision() else disableNightVision() end
    end
})

Tabs.Main:AddToggle("InfiniteJump", {
    Title = "无限跳",
    Default = false,
    Callback = function(state)
        if state then enableInfiniteJump() else disableInfiniteJump() end
    end
})

SaveManager:SetLibrary(Fluent)
InterfaceManager:SetLibrary(Fluent)
SaveManager:IgnoreThemeSettings()
SaveManager:SetIgnoreIndexes({})
InterfaceManager:SetFolder("FluentScriptHub")
SaveManager:SetFolder("FluentScriptHub/specific-game")
InterfaceManager:BuildInterfaceSection(Tabs.Other)
SaveManager:BuildConfigSection(Tabs.Other)

Window:SelectTab(1)
SaveManager:LoadAutoloadConfig()
Window.Root.Visible = true
