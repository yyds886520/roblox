-- ==================== 我的世界Hub（死亡点精准传送修复版）====================
local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
local SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/SaveManager.lua"))()
local InterfaceManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/InterfaceManager.lua"))()

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
    Developer = Window:AddTab({ Title = "开发者", Icon = "settings" })
}

-- ==================== 悬浮按钮（可拖动）====================
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

-- ==================== 信息标签页（完整版）====================
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local player = Players.LocalPlayer

Tabs.Info:AddParagraph({ Title = "您的用户昵称", Content = " " .. player.DisplayName })
Tabs.Info:AddParagraph({ Title = "您的用户名", Content = " " .. player.Name })
Tabs.Info:AddParagraph({ Title = "您的用户ID", Content = " " .. player.UserId })

local clientId = "未知"
pcall(function()
    if getclientid then clientId = getclientid() end
end)
Tabs.Info:AddParagraph({ Title = "您的客户端ID", Content = " " .. clientId })

local region = "未知"
pcall(function()
    region = game:GetService("LocalizationService").RobloxLocaleId or "未知"
end)
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
            pingValue = math.floor(game:GetService("NetworkClient"):GetNetworkPing() * 1000) .. " ms"
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

-- ==================== 动物透视系统（ESP）====================
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
    Deer = { text = "鹿哥", dynamicText = nil },
    Turkey = { text = "坤哥", dynamicText = nil },
    Sheep = { text = "羊", dynamicText = getSheepColorText },
    Cow = { text = "牛", dynamicText = nil },
    Pig = { text = "屁股尬的", dynamicText = nil }
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

Tabs.ESP:AddToggle("DeerESP", { Title = "鹿", Default = false, Callback = function(s) onToggle("Deer", s) end })
Tabs.ESP:AddToggle("TurkeyESP", { Title = "火鸡", Default = false, Callback = function(s) onToggle("Turkey", s) end })
Tabs.ESP:AddToggle("SheepESP", { Title = "羊", Default = false, Callback = function(s) onToggle("Sheep", s) end })
Tabs.ESP:AddToggle("CowESP", { Title = "牛", Default = false, Callback = function(s) onToggle("Cow", s) end })
Tabs.ESP:AddToggle("PigESP", { Title = "猪", Default = false, Callback = function(s) onToggle("Pig", s) end })

-- ==================== 无坠落伤害（主要）====================
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

-- ==================== 夜视（主要）====================
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

-- ==================== 无限跳（主要）====================
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

-- ==================== 返回死亡点（主要）精准射线版 ====================
local lastDeathPosition = nil

-- 监听死亡，记录坐标
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

        -- 使用射线检测找到最近实体表面
        local rayOrigin = lastDeathPosition + Vector3.new(0, 20, 0)  -- 从死亡点上方20格开始向下探测
        local rayDir = Vector3.new(0, -50, 0)  -- 向下探测50格
        local rayParams = RaycastParams.new()
        rayParams.FilterType = Enum.RaycastFilterType.Exclude
        rayParams.FilterDescendantsInstances = {character}

        local rayResult = workspace:Raycast(rayOrigin, rayDir, rayParams)
        local safePos
        if rayResult then
            -- 找到地面，传送至地表上方3格
            safePos = rayResult.Position + Vector3.new(0, 3, 0)
        else
            -- 如果射线没有命中，退而求其次，使用死亡点上方10格
            safePos = lastDeathPosition + Vector3.new(0, 10, 0)
        end

        -- 强制移动并冻结速度
        root.CFrame = CFrame.new(safePos)
        root.AssemblyLinearVelocity = Vector3.zero
        root.AssemblyAngularVelocity = Vector3.zero

        Fluent:Notify({ Title = "返回死亡点", Content = "已精准传送", Duration = 3 })
    end
})

-- 主要开关
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

-- ==================== 开发者工具 ====================
Tabs.Developer:AddButton({
    Title = "打开 Dex 资源管理器",
    Callback = function()
        local success, result = pcall(function() return game:HttpGet("https://raw.githubusercontent.com/infyiff/backup/main/dex.lua") end)
        if not success then
            success, result = pcall(function() return game:HttpGet("https://raw.githubusercontent.com/peyton2465/developer/main/Dex%20Explorer") end)
        end
        if success then loadstring(result)() Fluent:Notify({ Title = "Dex", Content = "已打开", Duration = 3 })
        else Fluent:Notify({ Title = "失败", Content = "加载失败", Duration = 5 }) end
    end
})

local errorMessages = {}
game:GetService("LogService").MessageOut:Connect(function(msg, msgType)
    if msgType == Enum.MessageType.MessageError then
        table.insert(errorMessages, tostring(msg))
        if #errorMessages > 10 then table.remove(errorMessages, 1) end
    end
end)

local function setClipboard(text)
    if syn and syn.set_clipboard then syn.set_clipboard(text)
    elseif writeclipboard then writeclipboard(text)
    else pcall(function() game:GetService("ClipboardService"):SetClipboard(text) end) end
end

Tabs.Developer:AddButton({
    Title = "复制最新报错",
    Callback = function()
        local err = #errorMessages > 0 and errorMessages[#errorMessages] or "无报错"
        setClipboard(err)
        Window:Dialog({
            Title = "已复制",
            Content = err,
            Buttons = { { Title = "确定", Callback = function() end } }
        })
    end
})

SaveManager:SetLibrary(Fluent)
InterfaceManager:SetLibrary(Fluent)
SaveManager:IgnoreThemeSettings()
SaveManager:SetIgnoreIndexes({})
InterfaceManager:SetFolder("FluentScriptHub")
SaveManager:SetFolder("FluentScriptHub/specific-game")
InterfaceManager:BuildInterfaceSection(Tabs.Developer)
SaveManager:BuildConfigSection(Tabs.Developer)

Window:SelectTab(1)
SaveManager:LoadAutoloadConfig()
Window.Root.Visible = true
