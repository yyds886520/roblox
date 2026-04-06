local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
local SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/SaveManager.lua"))()
local InterfaceManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/InterfaceManager.lua"))()

local Window = Fluent:CreateWindow({
    Title = "成为幸运方块Hub",
    SubTitle = "by.小梦",
    TabWidth = 160,
    Size = UDim2.fromOffset(550, 430),
    Acrylic = false,
    Theme = "Darker",
    MinimizeKey = Enum.KeyCode.LeftControl
})

local Tabs = {
    Main = Window:AddTab({ Title = "主要", Icon = "box" }),
    Upgrades = Window:AddTab({ Title = "升级", Icon = "gauge" }),
    Brainrots = Window:AddTab({ Title = "脑红", Icon = "bot" }),
    Stats = Window:AddTab({ Title = "属性", Icon = "chart-column" }),
    Settings = Window:AddTab({ Title = "设置", Icon = "settings" })
}

local Options = Fluent.Options

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

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(1, 0)
    corner.Parent = button

    local stroke = Instance.new("UIStroke")
    stroke.Thickness = 1
    stroke.Color = Color3.fromRGB(100, 100, 100)
    stroke.Transparency = 0.5
    stroke.Parent = button

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
        if Window.Root then
            Window.Root.Visible = not Window.Root.Visible
        end
    end)

    button.MouseEnter:Connect(function()
        button:TweenSize(UDim2.fromOffset(55, 55), Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0.2, true)
    end)
    button.MouseLeave:Connect(function()
        button:TweenSize(UDim2.fromOffset(50, 50), Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0.2, true)
    end)
end

do
    local ReplicatedStorage = game:GetService("ReplicatedStorage")
    local claimGift = ReplicatedStorage:WaitForChild("Packages"):WaitForChild("_Index"):WaitForChild("sleitnick_knit@1.7.0"):WaitForChild("knit"):WaitForChild("Services"):WaitForChild("PlaytimeRewardService"):WaitForChild("RF"):WaitForChild("ClaimGift")
    local autoClaiming = false
    local toggle = Tabs.Main:AddToggle("ACPR", { Title = "自动领取在线时长奖励", Default = false })
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
    local toggle = Tabs.Main:AddToggle("AR", { Title = "自动重生", Default = false })
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
    local Players = game:GetService("Players")
    local player = Players.LocalPlayer
    local claim = ReplicatedStorage:WaitForChild("Packages"):WaitForChild("_Index"):WaitForChild("sleitnick_knit@1.7.0"):WaitForChild("knit"):WaitForChild("Services"):WaitForChild("SeasonPassService"):WaitForChild("RF"):WaitForChild("ClaimPassReward")
    local running = false
    local toggle = Tabs.Main:AddToggle("ACEPR", { Title = "自动领取活动通行证奖励", Default = false })
    toggle:OnChanged(function(state)
        running = state
        if not state then return end
        task.spawn(function()
            while running do
                local gui = player:WaitForChild("PlayerGui"):WaitForChild("Windows"):WaitForChild("Event"):WaitForChild("Frame"):WaitForChild("Frame"):WaitForChild("Windows"):WaitForChild("Pass"):WaitForChild("Main"):WaitForChild("ScrollingFrame")
                for i = 1, 10 do
                    if not running then break end
                    local item = gui:FindFirstChild(tostring(i))
                    if item and item:FindFirstChild("Frame") and item.Frame:FindFirstChild("Free") then
                        local free = item.Frame.Free
                        local locked = free:FindFirstChild("Locked")
                        local claimed = free:FindFirstChild("Claimed")
                        while running and locked and locked.Visible do task.wait(0.2) end
                        if running and claimed and claimed.Visible then continue end
                        if running and locked and not locked.Visible then
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
    local redeem = ReplicatedStorage:WaitForChild("Packages"):WaitForChild("_Index"):WaitForChild("sleitnick_knit@1.7.0"):WaitForChild("knit"):WaitForChild("Services"):WaitForChild("CodesService"):WaitForChild("RF"):WaitForChild("RedeemCode")
    local codes = { "GOD", "DEVIL", "ZEUS", "RELEASE", "APRILFOOL" }
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
    local ReplicatedStorage = game:GetService("ReplicatedStorage")
    local Players = game:GetService("Players")
    local player = Players.LocalPlayer
    local buy = ReplicatedStorage:WaitForChild("Packages"):WaitForChild("_Index"):WaitForChild("sleitnick_knit@1.7.0"):WaitForChild("knit"):WaitForChild("Services"):WaitForChild("SkinService"):WaitForChild("RF"):WaitForChild("BuySkin")
    local skins = {
        "prestige_mogging_luckyblock", "mogging_luckyblock", "colossus _luckyblock",
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
    local toggle = Tabs.Main:AddToggle("ABL", { Title = "自动购买最佳幸运方块", Default = false })
    toggle:OnChanged(function(state)
        running = state
        if not state then return end
        task.spawn(function()
            while running do
                local gui = player.PlayerGui:FindFirstChild("Windows")
                if not gui then task.wait(1) continue end
                local pickaxeShop = gui:FindFirstChild("PickaxeShop")
                if not pickaxeShop then task.wait(1) continue end
                local shopContainer = pickaxeShop:FindFirstChild("ShopContainer")
                if not shopContainer then task.wait(1) continue end
                local scrollingFrame = shopContainer:FindFirstChild("ScrollingFrame")
                if not scrollingFrame then task.wait(1) continue end
                local cash = player.leaderstats.Cash.Value
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
                task.wait(0.5)
            end
        end)
    end)
    Options.ABL:SetValue(false)
end

do
    Tabs.Upgrades:AddSection("速度升级")
    local ReplicatedStorage = game:GetService("ReplicatedStorage")
    local upgrade = ReplicatedStorage:WaitForChild("Packages"):WaitForChild("_Index"):WaitForChild("sleitnick_knit@1.7.0"):WaitForChild("knit"):WaitForChild("Services"):WaitForChild("UpgradesService"):WaitForChild("RF"):WaitForChild("Upgrade")
    local amount = 1
    local delayTime = 0.5
    local running = false

    local input = Tabs.Upgrades:AddInput("IMS", { Title = "每次升级点数", Default = "1", Placeholder = "数字", Numeric = true, Finished = false })
    input:OnChanged(function(v) amount = tonumber(v) or 1 end)

    local slider = Tabs.Upgrades:AddSlider("SMS", { Title = "升级间隔(秒)", Default = 1, Min = 0, Max = 5, Rounding = 1 })
    slider:OnChanged(function(v) delayTime = v end)

    local toggle = Tabs.Upgrades:AddToggle("AMS", { Title = "自动升级速度", Default = false })
    toggle:OnChanged(function(state)
        running = state
        if not state then return end
        task.spawn(function()
            while running do
                pcall(function() upgrade:InvokeServer("MovementSpeed", amount) end)
                task.wait(delayTime)
            end
        end)
    end)
    Options.AMS:SetValue(false)
end

do
    local storedParts = {}
    local folder = workspace:WaitForChild("BossTouchDetectors")
    local selectedBosses = {}
    
    local bossOptions = {}
    for i = 1, 15 do
        table.insert(bossOptions, "base" .. i)
    end
    
    local dropdown = Tabs.Brainrots:AddDropdown("SelectBosses", {
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
    
    local toggle = Tabs.Brainrots:AddToggle("RBTD", { 
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
    Tabs.Brainrots:AddSection("自动获取终点脑红")
    local running = false
    local toggle = Tabs.Brainrots:AddToggle("AutoFarmToggle", { Title = "自动刷最佳脑红", Default = false })
    toggle:OnChanged(function(state)
        running = state
        if state then
            task.spawn(function()
                while running do
                    local player = game.Players.LocalPlayer
                    local character = player.Character or player.CharacterAdded:Wait()
                    local root = character:WaitForChild("HumanoidRootPart")
                    local humanoid = character:WaitForChild("Humanoid")
                    local userId = player.UserId
                    local modelsFolder = workspace:WaitForChild("RunningModels")
                    local target = workspace:WaitForChild("CollectZones"):WaitForChild("base15")

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

                    local oldCharacter = player.Character
                    repeat
                        task.wait(0.2)
                    until not running or (player.Character ~= oldCharacter and player.Character ~= nil)
                    if not running then break end

                    task.wait(0.4)
                    local newChar = player.Character
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
    local Players = game:GetService("Players")
    local player = Players.LocalPlayer
    local running = false
    local sliderValue = 1000
    local originalSpeed = nil
    local currentModel = nil

    local function getMyModel()
        local folder = workspace:FindFirstChild("RunningModels")
        if not folder then return nil end
        for _, model in ipairs(folder:GetChildren()) do
            if model:GetAttribute("OwnerId") == player.UserId then
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

    local toggle = Tabs.Stats:AddToggle("MovementToggle", { Title = "启用自定义幸运方块速度", Default = false })
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

    local slider = Tabs.Stats:AddSlider("MovementSlider", { Title = "幸运方块移动速度", Default = 1000, Min = 50, Max = 3000, Rounding = 0 })
    slider:OnChanged(function(v) sliderValue = v end)
end

do
    Tabs.Main:AddButton({
        Title = "拾取所有你的脑红",
        Callback = function()
            Window:Dialog({
                Title = "确认拾取",
                Content = "要拾取所有脑红吗？",
                Buttons = {
                    {
                        Title = "确认",
                        Callback = function()
                            local player = game:GetService("Players").LocalPlayer
                            local username = player.Name
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

Window.Root.Visible = true
