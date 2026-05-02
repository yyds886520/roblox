local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
local SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/SaveManager.lua"))()
local InterfaceManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/InterfaceManager.lua"))()

local AUTHOR_IDS = {
    7483594265
}

task.spawn(function()
    local removedCount = 0

    local badColors = {
        Color3.fromRGB(239, 184, 56),
        Color3.fromRGB(255, 176, 0),
        Color3.fromRGB(52, 142, 64)
    }

    local function isBadColor(c)
        for _, bc in ipairs(badColors) do
            if c == bc then return true end
        end
        return false
    end

    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj.Name == "Deals" then
            pcall(function()
                obj:Destroy()
                removedCount = removedCount + 1
            end)
        end
    end

    local playerGui = game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui")
    if playerGui then
        local hudFolder = playerGui:FindFirstChild("HUD") or playerGui:FindFirstChild("Hud")
        if hudFolder then
            for _, obj in ipairs(hudFolder:GetDescendants()) do
                if obj.Name == "Deals" then
                    pcall(function()
                        obj:Destroy()
                        removedCount = removedCount + 1
                    end)
                end
            end
        end
    end

    for _, part in ipairs(workspace:GetDescendants()) do
        if part:IsA("BasePart") and part.Name == "Top" and isBadColor(part.Color) then
            pcall(function()
                part:Destroy()
                removedCount = removedCount + 1
            end)
        end
    end

    if removedCount > 0 then
        print(string.format("✅ 自动清理完成：删除 %d 个付费元素", removedCount))
    end
end)

local function ShowAnnouncement(callback)
    local announcementGui = Instance.new("ScreenGui")
    announcementGui.Name = "Announcement"
    announcementGui.ResetOnSpawn = false
    announcementGui.Parent = game:GetService("CoreGui")

    local overlay = Instance.new("Frame")
    overlay.Size = UDim2.fromScale(1, 1)
    overlay.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    overlay.BackgroundTransparency = 0.6
    overlay.BorderSizePixel = 0
    overlay.Parent = announcementGui

    local frame = Instance.new("Frame")
    frame.Size = UDim2.fromOffset(400, 240)
    frame.Position = UDim2.fromScale(0.5, 0.5)
    frame.AnchorPoint = Vector2.new(0.5, 0.5)
    frame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    frame.BorderSizePixel = 0
    frame.BackgroundTransparency = 1
    frame.Parent = announcementGui

    Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 12)
    local stroke = Instance.new("UIStroke", frame)
    stroke.Thickness = 2
    stroke.Color = Color3.fromRGB(255, 215, 0)
    stroke.Transparency = 0.3
    stroke.Parent = frame

    local title = Instance.new("TextLabel")
    title.Size = UDim2.fromScale(1, 0.15)
    title.Position = UDim2.fromOffset(0, 10)
    title.BackgroundTransparency = 1
    title.Text = "📢 拉取幸运方块助手 - 更新日志"
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.TextSize = 16
    title.Font = Enum.Font.SourceSansBold
    title.Parent = frame

    local line = Instance.new("Frame")
    line.Size = UDim2.fromScale(0.9, 0.005)
    line.Position = UDim2.fromOffset(20, 42)
    line.BackgroundColor3 = Color3.fromRGB(255, 215, 0)
    line.BorderSizePixel = 0
    line.Parent = frame

    local content = Instance.new("TextLabel")
    content.Size = UDim2.new(0.92, -40, 0.58, 0)
    content.Position = UDim2.fromOffset(18, 50)
    content.BackgroundTransparency = 1
    content.Text = [[此脚本由小梦制作

更新时间：]] .. os.date("%Y-%m-%d %H:%M:%S") .. [[

【本次更新内容】
• 新增：秒拉取功能（点击按钮生效）
• 移除：范围功能（兼容性问题）
• 优化：启动自动清理更全面
• 调整：公告尺寸优化

【现有功能】
自动：哑铃、购买哑铃、重生、升级房屋、升级拉动
功能：秒拉取、世界传送、移除VIP门、移除墙壁、自动清理付费元素

感谢使用！]]
    content.TextColor3 = Color3.fromRGB(220, 220, 220)
    content.TextSize = 12
    content.Font = Enum.Font.SourceSans
    content.TextWrapped = true
    content.TextXAlignment = Enum.TextXAlignment.Left
    content.LineHeight = 1.4
    content.Parent = frame

    local button = Instance.new("TextButton")
    button.Size = UDim2.fromOffset(90, 30)
    button.Position = UDim2.new(0.5, -45, 0.88, 0)
    button.BackgroundColor3 = Color3.fromRGB(255, 215, 0)
    button.Text = "我明白"
    button.TextColor3 = Color3.fromRGB(0, 0, 0)
    button.TextSize = 14
    button.Font = Enum.Font.SourceSansBold
    button.BorderSizePixel = 0
    button.Parent = frame
    Instance.new("UICorner", button).CornerRadius = UDim.new(0, 8)

    button.MouseEnter:Connect(function()
        button.BackgroundColor3 = Color3.fromRGB(255, 235, 100)
    end)
    button.MouseLeave:Connect(function()
        button.BackgroundColor3 = Color3.fromRGB(255, 215, 0)
    end)

    local TweenService = game:GetService("TweenService")
    frame.BackgroundTransparency = 1
    frame.Size = UDim2.fromOffset(0, 0)

    local tweenInfo = TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
    local goals = {
        BackgroundTransparency = 0,
        Size = UDim2.fromOffset(400, 240)
    }
    local tween = TweenService:Create(frame, tweenInfo, goals)
    tween:Play()

    button.MouseButton1Click:Connect(function()
        local closeTweenInfo = TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
        local closeGoals = {
            BackgroundTransparency = 1,
            Size = UDim2.fromOffset(0, 0)
        }
        local closeTween = TweenService:Create(frame, closeTweenInfo, closeGoals)
        closeTween:Play()
        closeTween.Completed:Connect(function()
            announcementGui:Destroy()
            callback()
        end)
    end)
end

local Window = Fluent:CreateWindow({
    Title = "拉取幸运方块助手",
    SubTitle = "by.小梦",
    TabWidth = 160,
    Size = UDim2.fromOffset(580, 360),
    Acrylic = false,
    Theme = "Darker",
    MinimizeKey = Enum.KeyCode.LeftControl
})

Window.Root.Visible = false

local Tabs = {
    Info = Window:AddTab({ Title = "信息", Icon = "info" }),
    Main = Window:AddTab({ Title = "主要", Icon = "box" }),
    Auto = Window:AddTab({ Title = "自动", Icon = "bot" }),
    Teleport = Window:AddTab({ Title = "世界传送", Icon = "map-pin" }),
    Other = Window:AddTab({ Title = "其他", Icon = "settings" })
}

do
    local CUSTOM_IMAGE = "rbxassetid://10709791437"
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "FluentFloatButton"
    screenGui.ResetOnSpawn = false
    screenGui.Parent = game:GetService("CoreGui")
    screenGui.Enabled = false

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

    ShowAnnouncement(function()
        screenGui.Enabled = true
        Window.Root.Visible = true
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
    if getclientid then clientId = getclientid()
    else clientId = game:GetService("RbxAnalyticsService"):GetClientId() end
end)
Tabs.Info:AddParagraph({ Title = "您的客户端ID", Content = " " .. clientId })

local region = "未知"
pcall(function()
    if getregion then region = getregion()
    else
        local success, result = pcall(function() return game:HttpGet("http://ip-api.com/json/") end)
        if success and result then
            local data = game:GetService("HttpService"):JSONDecode(result)
            if data and data.countryCode then region = data.countryCode end
        end
    end
end)
if region == "未知" then
    pcall(function() region = game:GetService("LocalizationService").RobloxLocaleId or "未知" end)
end
Tabs.Info:AddParagraph({ Title = "您的地区", Content = " " .. region })

local language = "未知"
pcall(function() language = player.LocaleId or "未知" end)
Tabs.Info:AddParagraph({ Title = "您的语言", Content = " " .. language })

local accountAge = 0
pcall(function() accountAge = player.AccountAge end)
Tabs.Info:AddParagraph({ Title = "您的账户年龄(天)", Content = " " .. accountAge })
Tabs.Info:AddParagraph({ Title = "您的账户年龄(年)", Content = " " .. string.format("%.1f", accountAge / 365) })

local executorName = "未知"
pcall(function() executorName = identifyexecutor() or "未知" end)
Tabs.Info:AddParagraph({ Title = "您使用的注入器", Content = " " .. executorName })

Tabs.Info:AddParagraph({ Title = "您当前服务器的ID", Content = " " .. game.GameId })
Tabs.Info:AddParagraph({ Title = "您当前的服务器位置ID", Content = " " .. (game.PlaceId or game.GameId) })
Tabs.Info:AddParagraph({ Title = "当前服务器总人数", Content = " " .. #Players:GetPlayers() })

local pingParagraph = Tabs.Info:AddParagraph({ Title = "您的Ping", Content = " 加载中..." })
local fpsParagraph = Tabs.Info:AddParagraph({ Title = "您的FPS", Content = " 加载中..." })
local timeParagraph = Tabs.Info:AddParagraph({ Title = "时间", Content = " 加载中..." })

task.spawn(function()
    while true do
        local pingValue = "N/A"
        pcall(function()
            local s, p = pcall(function() return player:GetNetworkPing() end)
            if s and p then pingValue = math.floor(p * 1000) .. " ms"
            else
                s, p = pcall(function() return game:GetService("Stats").PerformanceStats.NetworkPing end)
                if s and p then pingValue = math.floor(p) .. " ms"
                else
                    s, p = pcall(function() return game:GetService("NetworkClient"):GetNetworkPing() end)
                    if s and p then pingValue = math.floor(p * 1000) .. " ms" end
                end
            end
        end)
        local fpsValue = "N/A"
        pcall(function() fpsValue = math.floor(1 / RunService.Heartbeat:Wait()) .. " FPS" end)
        local timeString = os.date("%H:%M:%S")
        pcall(function()
            pingParagraph:SetDesc(" " .. pingValue)
            fpsParagraph:SetDesc(" " .. fpsValue)
            timeParagraph:SetDesc(" " .. timeString)
        end)
        task.wait(0.5)
    end
end)

local HEAD_PART_NAME = "Head"
local authorESPEnabled = false
local authorTags = {}
local authorNotificationGui

local function createAuthorTag(character, playerName)
    if authorTags[character] then return end
    local head = character:WaitForChild(HEAD_PART_NAME, 10)
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
    textLabel.Text = "小梦"
    textLabel.TextColor3 = Color3.fromRGB(255, 0, 0)
    textLabel.TextStrokeTransparency = 0
    textLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
    textLabel.Font = Enum.Font.SourceSansBold
    textLabel.TextSize = 18
    textLabel.Parent = background

    billboard.Parent = game:GetService("CoreGui")
    authorTags[character] = { billboard = billboard, stroke = stroke, textLabel = textLabel }

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
    if tag then tag.billboard:Destroy(); authorTags[character] = nil end
end

local function showAuthorNotification()
    if authorNotificationGui then authorNotificationGui:Destroy() end
    local gui = Instance.new("ScreenGui"); gui.Name = "AuthorNotification"
    gui.ResetOnSpawn = false; gui.Parent = game:GetService("CoreGui")
    authorNotificationGui = gui
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 280, 0, 60)
    frame.Position = UDim2.new(1, -290, 1, -80)
    frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    frame.BackgroundTransparency = 0.2; frame.BorderSizePixel = 0; frame.Parent = gui
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 8)
    local stroke = Instance.new("UIStroke"); stroke.Thickness = 1
    stroke.Color = Color3.fromRGB(255, 215, 0); stroke.Parent = frame
    local textLabel = Instance.new("TextLabel")
    textLabel.Size = UDim2.fromScale(1, 1); textLabel.BackgroundTransparency = 1
    textLabel.Text = "检测到作者进入游戏"
    textLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    textLabel.Font = Enum.Font.SourceSansBold; textLabel.TextSize = 16; textLabel.Parent = frame
    task.delay(5, function()
        if authorNotificationGui == gui then gui:Destroy(); authorNotificationGui = nil end
    end)
end

local function isAuthor(p) for _, id in ipairs(AUTHOR_IDS) do if p.UserId == id then return true end end return false end

local function onAuthorAdded(p)
    if not authorESPEnabled or p == player then return end
    if isAuthor(p) then
        showAuthorNotification()
        if p.Character then createAuthorTag(p.Character, p.Name) end
        p.CharacterAdded:Connect(function(char) createAuthorTag(char, p.Name) end)
    end
end

Players.PlayerAdded:Connect(onAuthorAdded)
Players.PlayerRemoving:Connect(function(p) if authorTags[p.Character] then removeAuthorTag(p.Character) end end)

local function startAuthorESP()
    authorESPEnabled = true
    for _, p in ipairs(Players:GetPlayers()) do onAuthorAdded(p) end
end

local function stopAuthorESP()
    authorESPEnabled = false
    for c, _ in pairs(authorTags) do removeAuthorTag(c) end
end

Tabs.Info:AddToggle("AuthorESP", {
    Title = "作者头街",
    Default = true,
    Callback = function(state)
        if state then startAuthorESP() else stopAuthorESP() end
    end
})

task.spawn(startAuthorESP)

local Remotes = game:GetService("ReplicatedStorage").SharedModules.Network.Remotes
local DumbellRemote = Remotes:FindFirstChild("Activate Dumbell")
local BuyDumbellRemote = Remotes:FindFirstChild("Buy Dumbell")
local RebirthRemote = Remotes:FindFirstChild("Rebirth")
local PurchaseFloorRemote = Remotes:FindFirstChild("Purchase Floor")
local UpgradeCarryLimitRemote = Remotes:FindFirstChild("Upgrade Carry Limit")
local TeleportToSpawnRemote = Remotes:FindFirstChild("Teleport To Spawn")
local TeleportToWorldRemote = Remotes:FindFirstChild("Teleport To World")

local autoDumbellEnabled = false
local dumbellConnection = nil

local function startAutoDumbell()
    if dumbellConnection then dumbellConnection:Disconnect() end
    dumbellConnection = RunService.Heartbeat:Connect(function()
        if not autoDumbellEnabled then return end
        pcall(function() DumbellRemote:FireServer() end)
    end)
end

local function stopAutoDumbell()
    autoDumbellEnabled = false
    if dumbellConnection then dumbellConnection:Disconnect() dumbellConnection = nil end
end

local autoBuyDumbellEnabled = false
local buyDumbellRunning = false

local function startAutoBuyDumbell()
    if buyDumbellRunning then return end
    buyDumbellRunning = true
    task.spawn(function()
        for i = 1, 45 do
            if not autoBuyDumbellEnabled then break end
            pcall(function() BuyDumbellRemote:FireServer("Dumbell_" .. i) end)
            task.wait(0.1)
        end
        buyDumbellRunning = false
        autoBuyDumbellEnabled = false
        Fluent:Notify({ Title = "自动购买哑铃", Content = "购买完成 (1-45)", Duration = 3 })
    end)
end

local autoRebirthEnabled = false
local rebirthConnection = nil

local function startAutoRebirth()
    if rebirthConnection then rebirthConnection:Disconnect() end
    rebirthConnection = RunService.Heartbeat:Connect(function()
        if not autoRebirthEnabled then return end
        pcall(function() RebirthRemote:FireServer() end)
        task.wait(0.5)
    end)
end

local function stopAutoRebirth()
    autoRebirthEnabled = false
    if rebirthConnection then rebirthConnection:Disconnect() rebirthConnection = nil end
end

local autoUpgradeFloorEnabled = false
local upgradeFloorConnection = nil

local function startAutoUpgradeFloor()
    if upgradeFloorConnection then upgradeFloorConnection:Disconnect() end
    upgradeFloorConnection = RunService.Heartbeat:Connect(function()
        if not autoUpgradeFloorEnabled then return end
        for i = 1, 999 do
            if not autoUpgradeFloorEnabled then break end
            pcall(function() PurchaseFloorRemote:InvokeServer(i) end)
            task.wait(0.1)
        end
    end)
end

local function stopAutoUpgradeFloor()
    autoUpgradeFloorEnabled = false
    if upgradeFloorConnection then upgradeFloorConnection:Disconnect() upgradeFloorConnection = nil end
end

local autoUpgradeCarryEnabled = false
local upgradeCarryConnection = nil

local function startAutoUpgradeCarry()
    if upgradeCarryConnection then upgradeCarryConnection:Disconnect() end
    upgradeCarryConnection = RunService.Heartbeat:Connect(function()
        if not autoUpgradeCarryEnabled then return end
        pcall(function() UpgradeCarryLimitRemote:FireServer() end)
    end)
end

local function stopAutoUpgradeCarry()
    autoUpgradeCarryEnabled = false
    if upgradeCarryConnection then upgradeCarryConnection:Disconnect() upgradeCarryConnection = nil end
end

local function removeVIPDoors()
    local removedCount = 0
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj.Name == "VIPDoors" then
            pcall(function() obj:Destroy() removedCount = removedCount + 1 end)
        end
    end
    Fluent:Notify({ Title = "移除VIP门", Content = "已移除 " .. removedCount .. " 个VIP门", Duration = 3 })
end

local function removeWalls()
    local mapPartsFolder = workspace:FindFirstChild("MAPPARTS")
    if not mapPartsFolder then
        Fluent:Notify({ Title = "错误", Content = "未找到 MAPPARTS 文件夹", Duration = 3 })
        return
    end
    local targetColor = Color3.fromRGB(173, 90, 44)
    local removedCount = 0
    for _, part in ipairs(mapPartsFolder:GetDescendants()) do
        if part:IsA("BasePart") and part.Name == "Part" and part.Color == targetColor then
            pcall(function() part:Destroy() removedCount = removedCount + 1 end)
        end
    end
    Fluent:Notify({ Title = "移除墙壁", Content = "已移除 " .. removedCount .. " 个墙壁", Duration = 3 })
end

Tabs.Main:AddSection("功能")
Tabs.Main:AddButton({
    Title = "秒拉取",
    Callback = function()
        for _, prompt in ipairs(workspace:GetDescendants()) do
            if prompt:IsA("ProximityPrompt") then
                pcall(function()
                    prompt.HoldDuration = 0.01
                end)
            end
        end
        Fluent:Notify({ Title = "秒拉取", Content = "已将所有互动时间设为0.01秒", Duration = 2 })
    end
})

Tabs.Auto:AddSection("自动锻炼")
Tabs.Auto:AddToggle("AutoDumbell", { Title = "自动哑铃", Default = false, Callback = function(state) autoDumbellEnabled = state; if state then startAutoDumbell() else stopAutoDumbell() end end })
Tabs.Auto:AddSection("自动购买")
Tabs.Auto:AddToggle("AutoBuyDumbell", { Title = "自动购买哑铃", Default = false, Callback = function(state) autoBuyDumbellEnabled = state; if state then startAutoBuyDumbell() end end })
Tabs.Auto:AddSection("自动重生")
Tabs.Auto:AddToggle("AutoRebirth", { Title = "自动重生", Default = false, Callback = function(state) autoRebirthEnabled = state; if state then startAutoRebirth() else stopAutoRebirth() end end })
Tabs.Auto:AddSection("自动升级")
Tabs.Auto:AddToggle("AutoUpgradeFloor", { Title = "自动升级房屋", Default = false, Callback = function(state) autoUpgradeFloorEnabled = state; if state then startAutoUpgradeFloor() else stopAutoUpgradeFloor() end end })
Tabs.Auto:AddToggle("AutoUpgradeCarry", { Title = "自动升级拉动", Default = false, Callback = function(state) autoUpgradeCarryEnabled = state; if state then startAutoUpgradeCarry() else stopAutoUpgradeCarry() end end })

Tabs.Main:AddSection("VIP工具")
Tabs.Main:AddButton({ Title = "移除VIP门", Callback = removeVIPDoors })
Tabs.Main:AddSection("地图控制")
Tabs.Main:AddButton({ Title = "移除墙壁", Callback = removeWalls })

Tabs.Teleport:AddSection("世界传送")

Tabs.Teleport:AddButton({
    Title = "初始之地",
    Callback = function()
        pcall(function() TeleportToSpawnRemote:FireServer() end)
        Fluent:Notify({ Title = "世界传送", Content = "已传送到初始之地", Duration = 2 })
    end
})

local worlds = {
    { name = "糖果", worldName = "Candy" },
    { name = "冰冻", worldName = "Frozen" },
    { name = "霓虹灯", worldName = "Neon" },
    { name = "银河系", worldName = "Galaxy" },
    { name = "故障", worldName = "Glitch" },
    { name = "天堂", worldName = "Heaven" },
    { name = "地狱", worldName = "Hell" },
}

for _, world in ipairs(worlds) do
    Tabs.Teleport:AddButton({
        Title = world.name,
        Callback = function()
            pcall(function() TeleportToWorldRemote:FireServer(world.worldName) end)
            Fluent:Notify({ Title = "世界传送", Content = "已传送到" .. world.name, Duration = 2 })
        end
    })
end

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
