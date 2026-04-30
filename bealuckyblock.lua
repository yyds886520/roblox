local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
local SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/SaveManager.lua"))()
local InterfaceManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/InterfaceManager.lua"))()

local AUTHOR_IDS = {
    7483594265
}

-- ==================== 公告窗口 ====================
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
    frame.Size = UDim2.fromOffset(320, 300)
    frame.Position = UDim2.fromScale(0.5, 0.5)
    frame.AnchorPoint = Vector2.new(0.5, 0.5)
    frame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    frame.BorderSizePixel = 0
    frame.BackgroundTransparency = 1
    frame.Parent = announcementGui

    Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 12)

    local stroke = Instance.new("UIStroke")
    stroke.Thickness = 2
    stroke.Color = Color3.fromRGB(255, 215, 0)
    stroke.Transparency = 0.3
    stroke.Parent = frame

    local title = Instance.new("TextLabel")
    title.Size = UDim2.fromScale(1, 0.15)
    title.Position = UDim2.fromOffset(0, 15)
    title.BackgroundTransparency = 1
    title.Text = "📢 成为幸运方块Hub"
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.TextSize = 20
    title.Font = Enum.Font.SourceSansBold
    title.Parent = frame

    local line = Instance.new("Frame")
    line.Size = UDim2.fromScale(0.85, 0.005)
    line.Position = UDim2.fromOffset(24, 50)
    line.BackgroundColor3 = Color3.fromRGB(255, 215, 0)
    line.BorderSizePixel = 0
    line.Parent = frame

    local content = Instance.new("TextLabel")
    content.Size = UDim2.new(0.85, 0, 0.6, 0)
    content.Position = UDim2.fromOffset(24, 62)
    content.BackgroundTransparency = 1
    content.Text = [[此脚本由小梦制作

【更新日志 - 2026年04月25日 周六】
游戏更新了以下内容：
• 新Boss基地：base16
• 新怪物：Slayer

脚本已经同步更新啦
之前自动刷脑红只支持到base15
现在已经改成base16了
Slayer怪物也安排上了

放心使用吧！]]
    content.TextColor3 = Color3.fromRGB(220, 220, 220)
    content.TextSize = 13
    content.Font = Enum.Font.SourceSans
    content.TextWrapped = true
    content.TextXAlignment = Enum.TextXAlignment.Left
    content.LineHeight = 1.4
    content.Parent = frame

    local button = Instance.new("TextButton")
    button.Size = UDim2.fromOffset(110, 34)
    button.Position = UDim2.new(0.5, -55, 0.86, 0)
    button.BackgroundColor3 = Color3.fromRGB(255, 215, 0)
    button.Text = "我明白"
    button.TextColor3 = Color3.fromRGB(0, 0, 0)
    button.TextSize = 15
    button.Font = Enum.Font.SourceSansBold
    button.BorderSizePixel = 0
    button.Parent = frame
    Instance.new("UICorner", button).CornerRadius = UDim.new(0, 8)

    local buttonStroke = Instance.new("UIStroke")
    buttonStroke.Thickness = 1
    buttonStroke.Color = Color3.fromRGB(255, 255, 255)
    buttonStroke.Transparency = 0.5
    buttonStroke.Parent = button

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
        Size = UDim2.fromOffset(320, 300)
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

-- ==================== 主窗口 ====================
local Window = Fluent:CreateWindow({
    Title = "成为幸运方块Hub",
    SubTitle = "by.小梦",
    TabWidth = 160,
    Size = UDim2.fromOffset(550, 360),
    Acrylic = false,
    Theme = "Darker",
    MinimizeKey = Enum.KeyCode.LeftControl
})

Window.Root.Visible = false

local Tabs = {
    Info = Window:AddTab({ Title = "信息", Icon = "info" }),
    Main = Window:AddTab({ Title = "主要", Icon = "box" }),
    Auto = Window:AddTab({ Title = "自动", Icon = "bot" }),
    Easter = Window:AddTab({ Title = "彩蛋", Icon = "egg" }),
    Speed = Window:AddTab({ Title = "速度", Icon = "gauge" }),
    Settings = Window:AddTab({ Title = "设置", Icon = "settings" })
}

local Options = Fluent.Options

-- ==================== 悬浮按钮 ====================
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
    local userInputService = game:GetService("UserInputService")

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

    userInputService.InputChanged:Connect(function(input)
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

-- ==================== 信息页 ====================
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

-- ==================== 作者头街 ====================
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

-- ==================== 原有功能完整保留 ====================
do
    local ReplicatedStorage = game:GetService("ReplicatedStorage")
    local claimGift = ReplicatedStorage:WaitForChild("Packages"):WaitForChild("_Index"):WaitForChild("sleitnick_knit@1.7.0"):WaitForChild("knit"):WaitForChild("Services"):WaitForChild("PlaytimeRewardService"):WaitForChild("RF"):WaitForChild("ClaimGift")
    local autoClaiming = false
    local toggle = Tabs.Auto:AddToggle("ACPR", { Title = "自动领取在线时长奖励", Default = false })
    toggle:OnChanged(function(state)
        autoClaiming = state
        if not state then return end
        task.spawn(function()
            while autoClaiming do
                for reward = 1, 12 do
                    if not autoClaiming then break end
                    pcall(function() claimGift:InvokeServer(reward) end)
                    task.wait(0.25)
                end
                task.wait(1)
            end
        end)
    end)
    Options.ACPR:SetValue(false)
end

do
    local ReplicatedStorage = game:GetService("ReplicatedStorage")
    local rebirth = ReplicatedStorage:WaitForChild("Packages"):WaitForChild("_Index"):WaitForChild("sleitnick_knit@1.7.0"):WaitForChild("knit"):WaitForChild("Services"):WaitForChild("RebirthService"):WaitForChild("RF"):WaitForChild("Rebirth")
    local running = false
    local toggle = Tabs.Auto:AddToggle("AR", { Title = "自动重生", Default = false })
    toggle:OnChanged(function(state)
        running = state
        if not state then return end
        task.spawn(function()
            while running do
                pcall(function() rebirth:InvokeServer() end)
                task.wait(1)
            end
        end)
    end)
    Options.AR:SetValue(false)
end

do
    local ReplicatedStorage = game:GetService("ReplicatedStorage")
    local Players2 = game:GetService("Players")
    local player2 = Players2.LocalPlayer
    local claim = ReplicatedStorage:WaitForChild("Packages"):WaitForChild("_Index"):WaitForChild("sleitnick_knit@1.7.0"):WaitForChild("knit"):WaitForChild("Services"):WaitForChild("SeasonPassService"):WaitForChild("RF"):WaitForChild("ClaimPassReward")
    local running = false
    local toggle = Tabs.Auto:AddToggle("ACEPR", { Title = "自动领取活动通行证奖励", Default = false })
    toggle:OnChanged(function(state)
        running = state
        if not state then return end
        task.spawn(function()
            while running do
                local gui = player2:WaitForChild("PlayerGui"):WaitForChild("Windows"):WaitForChild("Event"):WaitForChild("Frame"):WaitForChild("Frame"):WaitForChild("Windows"):WaitForChild("Pass"):WaitForChild("Main"):WaitForChild("ScrollingFrame")
                for i = 1, 10 do
                    if not running then break end
                    local item = gui:FindFirstChild(tostring(i))
                    if item and item:FindFirstChild("Frame") and item.Frame:FindFirstChild("Free") then
                        local free = item.Frame.Free
                        local locked = free:FindFirstChild("Locked")
                        local claimed = free:FindFirstChild("Claimed")
                        while running and locked and locked.Visible do task.wait(0.2) end
                        if running and claimed and claimed.Visible then
                        elseif running and locked and not locked.Visible then
                            pcall(function() claim:InvokeServer("Free", i) end)
                        end
                    end
                end
                task.wait(0.5)
            end
        end)
    end)
    Options.ACEPR:SetValue(false)
end

do
    local ReplicatedStorage = game:GetService("ReplicatedStorage")
    local Players2 = game:GetService("Players")
    local player2 = Players2.LocalPlayer
    local buy = ReplicatedStorage:WaitForChild("Packages"):WaitForChild("_Index"):WaitForChild("sleitnick_knit@1.7.0"):WaitForChild("knit"):WaitForChild("Services"):WaitForChild("SkinService"):WaitForChild("RF"):WaitForChild("BuySkin")
    local skins = {
        "prestige_mogging_luckyblock", "mogging_luckyblock", "colossus_luckyblock",
        "inferno_luckyblock", "divine_luckyblock", "spirit_luckyblock", "cyborg_luckyblock",
        "void_luckyblock", "gliched_luckyblock", "lava_luckyblock", "freezy_luckyblock", "fairy_luckyblock"
    }
    local suffix = { K = 1e3, M = 1e6, B = 1e9, T = 1e12, Qa = 1e15, Qi = 1e18, Sx = 1e21, Sp = 1e24, Oc = 1e27, No = 1e30, Dc = 1e33 }
    local function parseCash(text)
        text = text:gsub("%$", ""):gsub(",", ""):gsub("%s+", "")
        local num = tonumber(text:match("[%d%.]+"))
        local suf = text:match("%a+")
        if not num then return 0 end
        if suf and suffix[suf] then return num * suffix[suf] end
        return num
    end
    local running = false
    local toggle = Tabs.Auto:AddToggle("ABL", { Title = "自动购买最佳幸运方块", Default = false })
    toggle:OnChanged(function(state)
        running = state
        if not state then return end
        task.spawn(function()
            while running do
                local gui = player2.PlayerGui:FindFirstChild("Windows")
                if gui then
                    local pickaxeShop = gui:FindFirstChild("PickaxeShop")
                    if pickaxeShop then
                        local shopContainer = pickaxeShop:FindFirstChild("ShopContainer")
                        if shopContainer then
                            local scrollingFrame = shopContainer:FindFirstChild("ScrollingFrame")
                            if scrollingFrame then
                                local cash = player2.leaderstats.Cash.Value
                                local bestSkin = nil
                                local bestPrice = 0
                                for i = 1, #skins do
                                    local name = skins[i]
                                    local item = scrollingFrame:FindFirstChild(name)
                                    if item then
                                        local main = item:FindFirstChild("Main")
                                        if main then
                                            local buyFolder = main:FindFirstChild("Buy")
                                            if buyFolder then
                                                local buyButton = buyFolder:FindFirstChild("BuyButton")
                                                if buyButton and buyButton.Visible then
                                                    local cashLabel = buyButton:FindFirstChild("Cash")
                                                    if cashLabel then
                                                        local price = parseCash(cashLabel.Text)
                                                        if cash >= price and price > bestPrice then
                                                            bestSkin = name
                                                            bestPrice = price
                                                        end
                                                    end
                                                end
                                            end
                                        end
                                    end
                                end
                                if bestSkin then
                                    pcall(function() buy:InvokeServer(bestSkin) end)
                                end
                            end
                        end
                    end
                end
                task.wait(0.5)
            end
        end)
    end)
    Options.ABL:SetValue(false)
end

do
    Tabs.Auto:AddButton({
        Title = "拾取所有你的脑红",
        Callback = function()
            Window:Dialog({
                Title = "确认拾取",
                Content = "要拾取所有脑红吗？",
                Buttons = {
                    {
                        Title = "确认",
                        Callback = function()
                            local player3 = game:GetService("Players").LocalPlayer
                            local username = player3.Name
                            local plotsFolder = workspace:WaitForChild("Plots")
                            local myPlot
                            for i = 1, 5 do
                                local plot = plotsFolder:FindFirstChild(tostring(i))
                                if plot and plot:FindFirstChild(tostring(i)) then
                                    local inner = plot[tostring(i)]
                                    for _, v in pairs(inner:GetDescendants()) do
                                        if v:IsA("BillboardGui") and string.find(v.Name, username) then
                                            myPlot = inner
                                            break
                                        end
                                    end
                                end
                                if myPlot then break end
                            end
                            if not myPlot then return end
                            local containers = myPlot:FindFirstChild("Containers")
                            if not containers then return end
                            for i = 1, 30 do
                                local containerFolder = containers:FindFirstChild(tostring(i))
                                if containerFolder and containerFolder:FindFirstChild(tostring(i)) then
                                    local container = containerFolder[tostring(i)]
                                    local innerModel = container:FindFirstChild("InnerModel")
                                    if innerModel and #innerModel:GetChildren() > 0 then
                                        local args = { tostring(i) }
                                        game:GetService("ReplicatedStorage"):WaitForChild("Packages"):WaitForChild("_Index"):WaitForChild("sleitnick_knit@1.7.0"):WaitForChild("knit"):WaitForChild("Services"):WaitForChild("ContainerService"):WaitForChild("RF"):WaitForChild("PickupBrainrot"):InvokeServer(unpack(args))
                                        task.wait(0.1)
                                    end
                                end
                            end
                            Fluent:Notify({ Title = "完成", Content = "已拾取所有脑红", Duration = 5 })
                        end
                    },
                    { Title = "取消", Callback = function() end }
                }
            })
        end
    })
end

do
    Tabs.Auto:AddSection("速度升级")
    local ReplicatedStorage = game:GetService("ReplicatedStorage")
    local upgrade = ReplicatedStorage:WaitForChild("Packages"):WaitForChild("_Index"):WaitForChild("sleitnick_knit@1.7.0"):WaitForChild("knit"):WaitForChild("Services"):WaitForChild("UpgradesService"):WaitForChild("RF"):WaitForChild("Upgrade")
    local running = false

    local toggle = Tabs.Auto:AddToggle("AMS", { Title = "自动升级速度", Default = false })
    toggle:OnChanged(function(state)
        running = state
        if not state then return end
        task.spawn(function()
            while running do
                pcall(function() upgrade:InvokeServer("MovementSpeed", 1) end)
                task.wait(0.5)
            end
        end)
    end)
    Options.AMS:SetValue(false)
end

do
    local ReplicatedStorage = game:GetService("ReplicatedStorage")
    local redeem = ReplicatedStorage:WaitForChild("Packages"):WaitForChild("_Index"):WaitForChild("sleitnick_knit@1.7.0"):WaitForChild("knit"):WaitForChild("Services"):WaitForChild("CodesService"):WaitForChild("RF"):WaitForChild("RedeemCode")
    local codes = { "GOD", "ZEUS", "RELEASE", "CORALUKE", "TR9MP1238", "M2ZF4KYR", "FIX31", "MAGIA" }
    Tabs.Main:AddButton({
        Title = "兑换所有礼包码",
        Callback = function()
            for _, code in ipairs(codes) do
                pcall(function() redeem:InvokeServer(code) end)
                task.wait(1)
            end
            Fluent:Notify({ Title = "完成", Content = "已尝试兑换所有码", Duration = 3 })
        end
    })
end

do
    local storedParts = {}
    local folder = workspace:WaitForChild("BossTouchDetectors")
    local selectedBosses = {}
    
    local bossOptions = {}
    for i = 1, 16 do
        table.insert(bossOptions, "base" .. i)
    end
    
    local dropdown = Tabs.Main:AddDropdown("SelectBosses", {
        Title = "选择不让抓你的Boss",
        Description = "可多选，选中的Boss将无法抓你",
        Values = bossOptions,
        Multi = true,
        Default = {},
        Callback = function(value)
            selectedBosses = {}
            for name, selected in pairs(value) do
                if selected then
                    table.insert(selectedBosses, name)
                end
            end
        end
    })
    
    local toggle = Tabs.Main:AddToggle("RBTD", { 
        Title = "启用自选Boss免疫", 
        Description = "开启后，上方选中的Boss无法抓你（其他Boss正常）", 
        Default = false 
    })
    toggle:OnChanged(function(state)
        if state then
            storedParts = {}
            for _, obj in ipairs(folder:GetChildren()) do
                local shouldRemove = false
                for _, name in ipairs(selectedBosses) do
                    if obj.Name == name then
                        shouldRemove = true
                        break
                    end
                end
                if shouldRemove then
                    table.insert(storedParts, obj)
                    obj.Parent = nil
                end
            end
        else
            for _, obj in ipairs(storedParts) do
                if obj then obj.Parent = folder end
            end
            storedParts = {}
        end
    end)
    Options.RBTD:SetValue(false)
end

do
    Tabs.Main:AddSection("自动获取终点脑红")
    local running = false
    local toggle = Tabs.Main:AddToggle("AutoFarmToggle", { Title = "自动刷最佳脑红", Default = false })
    toggle:OnChanged(function(state)
        running = state
        if state then
            task.spawn(function()
                while running do
                    local player4 = game.Players.LocalPlayer
                    local character = player4.Character or player4.CharacterAdded:Wait()
                    local root = character:WaitForChild("HumanoidRootPart")
                    local humanoid = character:WaitForChild("Humanoid")
                    local userId = player4.UserId
                    local modelsFolder = workspace:WaitForChild("RunningModels")
                    local target = workspace:WaitForChild("CollectZones"):WaitForChild("base16")

                    root.CFrame = CFrame.new(715, 39, -2122)
                    task.wait(0.3)
                    humanoid:MoveTo(Vector3.new(710, 39, -2122))

                    local ownedModel = nil
                    repeat
                        task.wait(0.3)
                        for _, obj in ipairs(modelsFolder:GetChildren()) do
                            if obj:IsA("Model") and obj:GetAttribute("OwnerId") == userId then
                                ownedModel = obj
                                break
                            end
                        end
                    until ownedModel ~= nil or not running
                    if not running then break end

                    if ownedModel.PrimaryPart then
                        ownedModel:SetPrimaryPartCFrame(target.CFrame)
                    else
                        local part = ownedModel:FindFirstChildWhichIsA("BasePart")
                        if part then part.CFrame = target.CFrame end
                    end
                    task.wait(0.7)

                    if ownedModel and ownedModel.Parent == modelsFolder then
                        if ownedModel.PrimaryPart then
                            ownedModel:SetPrimaryPartCFrame(target.CFrame * CFrame.new(0, -5, 0))
                        else
                            local part = ownedModel:FindFirstChildWhichIsA("BasePart")
                            if part then part.CFrame = target.CFrame * CFrame.new(0, -5, 0) end
                        end
                    end

                    repeat
                        task.wait(0.3)
                    until not running or (ownedModel == nil or ownedModel.Parent ~= modelsFolder)
                    if not running then break end

                    local oldCharacter = player4.Character
                    repeat
                        task.wait(0.2)
                    until not running or (player4.Character ~= oldCharacter and player4.Character ~= nil)
                    if not running then break end

                    task.wait(0.4)
                    local newChar = player4.Character
                    local newRoot = newChar:WaitForChild("HumanoidRootPart")
                    newRoot.CFrame = CFrame.new(737, 39, -2118)
                    task.wait(2.1)
                end
            end)
        end
    end)
    Options.AutoFarmToggle:SetValue(false)
end

do
    local Players2 = game:GetService("Players")
    local player2 = Players2.LocalPlayer
    local ReplicatedStorage = game:GetService("ReplicatedStorage")
    local Workspace = game:GetService("Workspace")
    local RunService2 = game:GetService("RunService")

    local CollectEggRemote = ReplicatedStorage:WaitForChild("Packages"):WaitForChild("_Index"):WaitForChild("sleitnick_knit@1.7.0"):WaitForChild("knit"):WaitForChild("Services"):WaitForChild("EventService"):WaitForChild("RF"):WaitForChild("CollectEgg")
    local BossFolder = Workspace:WaitForChild("BossTouchDetectors")

    local TELEPORT_CFRAME = CFrame.new(715, 39, -2122)
    local WALK_TO_POSITION = Vector3.new(707, 39, -2122)
    local TELEPORT_DELAY = 2
    local COLLECT_INTERVAL = 0.3
    local COLLECT_DURATION = 7

    local autoEnabled = false
    local suppressConnection = nil
    local speedSetConnection = nil

    local function suppressBossesExceptBase2()
        for i = 1, 16 do
            if i == 2 or i == 16 then
                local boss = BossFolder:FindFirstChild("base" .. i)
                if boss then
                    boss.Parent = BossFolder
                    for _, part in ipairs(boss:GetDescendants()) do
                        if part:IsA("BasePart") then
                            part.CanCollide = true
                            part.CanTouch = true
                        end
                    end
                end
            else
                local boss = BossFolder:FindFirstChild("base" .. i)
                if boss then
                    for _, part in ipairs(boss:GetDescendants()) do
                        if part:IsA("BasePart") then
                            part.CanCollide = false
                            part.CanTouch = false
                        end
                    end
                    local touchInterest = boss:FindFirstChild("TouchInterest", true)
                    if touchInterest then touchInterest:Destroy() end
                    boss.Parent = nil
                end
            end
        end
    end

    local function startSuppressLoop()
        if suppressConnection then return end
        suppressConnection = RunService2.Heartbeat:Connect(function()
            if autoEnabled then suppressBossesExceptBase2() end
        end)
    end

    local function stopSuppressLoop()
        if suppressConnection then
            suppressConnection:Disconnect()
            suppressConnection = nil
        end
    end

    local function setSpeedLoop()
        local runningModels = Workspace:WaitForChild("RunningModels")
        while autoEnabled do
            for _, model in ipairs(runningModels:GetChildren()) do
                if model:IsA("Model") and model:GetAttribute("OwnerId") == player2.UserId then
                    model:SetAttribute("MovementSpeed", 550)
                end
            end
            task.wait(0.2)
        end
    end

    local function startSpeedSetter()
        if speedSetConnection then return end
        speedSetConnection = task.spawn(setSpeedLoop)
    end

    local function stopSpeedSetter()
        if speedSetConnection then
            task.cancel(speedSetConnection)
            speedSetConnection = nil
        end
    end

    local function onCharacterAdded(character)
        if not autoEnabled then return end

        local root = character:WaitForChild("HumanoidRootPart")
        local humanoid = character:WaitForChild("Humanoid")

        task.wait(TELEPORT_DELAY)

        root.CFrame = TELEPORT_CFRAME
        humanoid:MoveTo(WALK_TO_POSITION)

        startSuppressLoop()

        local startTime = tick()
        local collectThread = task.spawn(function()
            while autoEnabled and (tick() - startTime < COLLECT_DURATION) do
                pcall(function() CollectEggRemote:InvokeServer() end)
                task.wait(COLLECT_INTERVAL)
            end
        end)

        repeat task.wait(0.1) until (tick() - startTime >= COLLECT_DURATION) or (not autoEnabled)
        task.cancel(collectThread)

        stopSuppressLoop()

        if character and character:FindFirstChild("Humanoid") then
            character.Humanoid.Died:Wait()
        end
    end

    local charAddedConn
    local function startListening()
        if charAddedConn then charAddedConn:Disconnect() end
        charAddedConn = player2.CharacterAdded:Connect(onCharacterAdded)
        if player2.Character then
            task.spawn(onCharacterAdded, player2.Character)
        end
        startSpeedSetter()
    end

    local function stopListening()
        if charAddedConn then
            charAddedConn:Disconnect()
            charAddedConn = nil
        end
        stopSuppressLoop()
        stopSpeedSetter()
    end

    local toggle = Tabs.Easter:AddToggle("AutoEggFarm", {
        Title = "自动刷彩蛋",
        Description = "全程无需操作",
        Default = false
    })

    toggle:OnChanged(function(state)
        autoEnabled = state
        if state then
            startListening()
            Fluent:Notify({ Title = "彩蛋", Content = "开始自动刷取", Duration = 2 })
        else
            stopListening()
            Fluent:Notify({ Title = "彩蛋", Content = "已停止", Duration = 2 })
        end
    end)
    Options.AutoEggFarm:SetValue(false)
end

do
    local Players2 = game:GetService("Players")
    local player2 = Players2.LocalPlayer
    local running = false
    local sliderValue = 1000
    local originalSpeed = nil
    local currentModel = nil

    local function getMyModel()
        local folder = workspace:FindFirstChild("RunningModels")
        if not folder then return nil end
        for _, model in ipairs(folder:GetChildren()) do
            if model:GetAttribute("OwnerId") == player2.UserId then
                return model
            end
        end
        return nil
    end

    local function applySpeed()
        local model = getMyModel()
        if not model then currentModel = nil return end
        if model ~= currentModel then
            currentModel = model
            originalSpeed = model:GetAttribute("MovementSpeed")
        end
        if running then
            if originalSpeed == nil then originalSpeed = model:GetAttribute("MovementSpeed") end
            model:SetAttribute("MovementSpeed", sliderValue)
        end
    end

    task.spawn(function()
        while true do
            if running then applySpeed() end
            task.wait(0.2)
        end
    end)

    local toggle = Tabs.Speed:AddToggle("MovementToggle", { Title = "启用自定义幸运方块速度", Default = false })
    toggle:OnChanged(function()
        running = Options.MovementToggle.Value
        if not running then
            local model = getMyModel()
            if model and originalSpeed ~= nil then
                model:SetAttribute("MovementSpeed", originalSpeed)
            end
            originalSpeed = nil
            currentModel = nil
        end
    end)

    local slider = Tabs.Speed:AddSlider("MovementSlider", { Title = "幸运方块移动速度", Default = 1000, Min = 50, Max = 3000, Rounding = 0 })
    slider:OnChanged(function(v) sliderValue = v end)
end

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
