local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
local SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/SaveManager.lua"))()
local InterfaceManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/InterfaceManager.lua"))()

local Window = Fluent:CreateWindow({
    Title = "吃凝胶治疗脑萎缩",
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
local workspace = game:GetService("Workspace")

local function getMyPlot()
    local plotsFolder = workspace:FindFirstChild("Plots")
    if not plotsFolder then return nil end
    local displayName = player.DisplayName
    local playerName = player.Name

    for _, plotPart in ipairs(plotsFolder:GetChildren()) do
        if plotPart:IsA("BasePart") and tonumber(plotPart.Name) then
            local playerDisplay = plotPart:FindFirstChild("PlayerDisplay")
            if playerDisplay then
                local surfaceGui = playerDisplay:FindFirstChild("SurfaceGui")
                if surfaceGui then
                    local nameLabel = surfaceGui:FindFirstChild("PlayerName")
                    if nameLabel and nameLabel:IsA("TextLabel") then
                        local text = nameLabel.Text
                        if text == displayName or text == playerName or text:find(playerName) then
                            return plotPart
                        end
                    end
                end
            end
        end
    end
    return nil
end

local function getMyHomePosition()
    local plot = getMyPlot()
    if not plot then return nil end
    return plot.Position + Vector3.new(0, 5, 0)
end

Tabs.Teleport:AddButton({
    Title = "回家",
    Callback = function()
        local char = player.Character
        if char and char:FindFirstChild("HumanoidRootPart") then
            local homePos = getMyHomePosition()
            if homePos then
                pcall(function() char.HumanoidRootPart.CFrame = CFrame.new(homePos) end)
            else
                Fluent:Notify({ Title = "回不去", Content = "没找到你的家在哪", Duration = 2 })
            end
        else
            Fluent:Notify({ Title = "飞不了", Content = "角色还没加载好", Duration = 2 })
        end
    end
})

Tabs.Teleport:AddSection("品质区")

local regions = {
    { name = "远古区", pos = Vector3.new(1948, -54, 0) },
    { name = "全能区", pos = Vector3.new(1788, -54, 0) },
    { name = "不朽区", pos = Vector3.new(1628, -54, 0) },
    { name = "无限区", pos = Vector3.new(1468, -54, 0) },
    { name = "天穹区", pos = Vector3.new(1308, -54, 0) },
    { name = "神圣区", pos = Vector3.new(1148, -54, 0) },
    { name = "精英区", pos = Vector3.new(1008, -54, 0) },
    { name = "至尊区", pos = Vector3.new(888, -54, 0) },
    { name = "欧米伽区", pos = Vector3.new(768, -54, 0) },
    { name = "极限区", pos = Vector3.new(648, -54, 0) },
    { name = "隐秘区", pos = Vector3.new(528, -54, 0) },
    { name = "异域区", pos = Vector3.new(408, -54, 0) },
    { name = "神话区", pos = Vector3.new(308, -54, 0) },
    { name = "传说区", pos = Vector3.new(228, -54, 0) },
    { name = "史诗区", pos = Vector3.new(158, -54, 0) },
    { name = "稀有区", pos = Vector3.new(98, -54, 0) },
    { name = "非凡区", pos = Vector3.new(38, -54, 0) },
    { name = "普通区", pos = Vector3.new(-22, -54, 0) },
}

for _, region in ipairs(regions) do
    Tabs.Teleport:AddButton({
        Title = region.name,
        Callback = function()
            local char = player.Character
            if char and char:FindFirstChild("HumanoidRootPart") then
                pcall(function() char.HumanoidRootPart.CFrame = CFrame.new(region.pos) end)
                Fluent:Notify({ Title = "传送成功", Content = "已经飞到" .. region.name .. "了", Duration = 2 })
            else
                Fluent:Notify({ Title = "飞不了", Content = "角色还没加载好", Duration = 2 })
            end
        end
    })
end

local noClipEnabled = false
local noClipConnection = nil

Tabs.Main:AddToggle("NoClip", {
    Title = "穿墙",
    Default = false,
    Callback = function(state)
        noClipEnabled = state
        if state then
            noClipConnection = RunService.Stepped:Connect(function()
                local char = player.Character
                if char then
                    for _, part in ipairs(char:GetChildren()) do
                        if part:IsA("BasePart") then part.CanCollide = false end
                    end
                end
            end)
        else
            if noClipConnection then
                noClipConnection:Disconnect()
                noClipConnection = nil
            end
        end
    end
})

Tabs.Main:AddButton({
    Title = "移除凝胶",
    Callback = function()
        local jellyFolder = workspace:FindFirstChild("JellyGrid")
        if jellyFolder then
            pcall(function()
                jellyFolder:Destroy()
                Fluent:Notify({ Title = "清理完成", Content = "所有凝胶都清理干净了，随便走吧", Duration = 3 })
            end)
        else
            Fluent:Notify({ Title = "没啥可清理的", Content = "路上已经没有凝胶了", Duration = 2 })
        end
    end
})

local moneyCollectEnabled = false
local moneyCollectThread = nil

local function getMyMoneyButtons()
    local plot = getMyPlot()
    if not plot then return {} end
    local buttons = {}
    for _, slotPart in ipairs(plot:GetChildren()) do
        if slotPart:IsA("BasePart") and tonumber(slotPart.Name) then
            local moneyCollect = slotPart:FindFirstChild("MoneyCollect")
            if moneyCollect and moneyCollect:IsA("BasePart") then
                local button = moneyCollect:FindFirstChild("Button")
                if button and button:IsA("BasePart") and button:FindFirstChild("TouchInterest") then
                    table.insert(buttons, button)
                end
            end
        end
    end
    return buttons
end

local function triggerMoneyCollect()
    local char = player.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return end
    local root = char.HumanoidRootPart
    local buttons = getMyMoneyButtons()
    for _, button in ipairs(buttons) do
        pcall(function()
            firetouchinterest(root, button, 0)
            firetouchinterest(root, button, 1)
        end)
    end
end

Tabs.Main:AddToggle("MoneyCollect", {
    Title = "拾取金钱",
    Default = false,
    Callback = function(state)
        moneyCollectEnabled = state
        if state then
            moneyCollectThread = task.spawn(function()
                while moneyCollectEnabled do
                    triggerMoneyCollect()
                    task.wait(0.01)
                end
            end)
        else
            if moneyCollectThread then
                task.cancel(moneyCollectThread)
                moneyCollectThread = nil
            end
        end
    end
})

local upgradeEnabled = false
local upgradeThread = nil

local function getMyClickDetectors()
    local plot = getMyPlot()
    if not plot then return {} end
    local detectors = {}
    for _, slotPart in ipairs(plot:GetChildren()) do
        if slotPart:IsA("BasePart") and tonumber(slotPart.Name) then
            local upgradePart = slotPart:FindFirstChild("UpgradePart")
            if upgradePart and upgradePart:IsA("BasePart") then
                local clickDetector = upgradePart:FindFirstChildWhichIsA("ClickDetector")
                if clickDetector then
                    table.insert(detectors, clickDetector)
                end
            end
        end
    end
    return detectors
end

local function triggerUpgrade()
    local detectors = getMyClickDetectors()
    for _, detector in ipairs(detectors) do
        pcall(function()
            fireclickdetector(detector)
        end)
    end
end

Tabs.Main:AddToggle("AutoUpgrade", {
    Title = "自动升级宠物",
    Default = false,
    Callback = function(state)
        upgradeEnabled = state
        if state then
            upgradeThread = task.spawn(function()
                while upgradeEnabled do
                    triggerUpgrade()
                    task.wait(0.01)
                end
            end)
        else
            if upgradeThread then
                task.cancel(upgradeThread)
                upgradeThread = nil
            end
        end
    end
})

SaveManager:SetLibrary(Fluent)
InterfaceManager:SetLibrary(Fluent)
SaveManager:IgnoreThemeSettings()
SaveManager:SetIgnoreIndexes({})
InterfaceManager:SetFolder("FluentScriptHub")
SaveManager:SetFolder("FluentScriptHub/brainrot-gel")
InterfaceManager:BuildInterfaceSection(Tabs.Other)
SaveManager:BuildConfigSection(Tabs.Other)

Window:SelectTab(1)
SaveManager:LoadAutoloadConfig()
