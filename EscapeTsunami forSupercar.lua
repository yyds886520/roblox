local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()

local Window = Fluent:CreateWindow({
    Title = "为超级跑车逃脱海啸",
    SubTitle = "by.小梦",
    TabWidth = 160,
    Size = UDim2.fromOffset(460, 400),  -- 扁平化窗口
    Acrylic = false,
    Theme = "Darker",
    MinimizeKey = Enum.KeyCode.LeftControl
})

-- ================== 悬浮按钮 ==================
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

-- ================== 标签页 ==================
local AutoTab = Window:AddTab({ Title = "自动功能", Icon = "rotate-cw" })
local TeleportTab = Window:AddTab({ Title = "传送", Icon = "map-pin" })

-- ================== 远程函数获取 ==================
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local netManaged = ReplicatedStorage:FindFirstChild("Modules"):FindFirstChild("RbxNet"):FindFirstChild("net"):FindFirstChild("_NetManaged")

local UpgradeCarRemote = netManaged and netManaged:FindFirstChild("UpgradeCarSlot")
local PickupRemote = netManaged and netManaged:FindFirstChild("PickupFromSlot")
local UpgradeBaseRemote = netManaged and netManaged:FindFirstChild("UpgradeBaseLevel")
local ClaimGiftRemote = netManaged and netManaged:FindFirstChild("ClaimPlaytimeGift")
local RebirthRemote = netManaged and netManaged:FindFirstChild("AttemptRebirth")
local UpgradeSpeedRemote = netManaged and netManaged:FindFirstChild("UpgradeSpeed")

if not UpgradeCarRemote then warn("未找到 UpgradeCarSlot") end
if not PickupRemote then warn("未找到 PickupFromSlot") end
if not UpgradeBaseRemote then warn("未找到 UpgradeBaseLevel") end
if not ClaimGiftRemote then warn("未找到 ClaimPlaytimeGift") end
if not RebirthRemote then warn("未找到 AttemptRebirth") end
if not UpgradeSpeedRemote then warn("未找到 UpgradeSpeed") end

-- ================== 在线奖励礼物ID列表 ==================
local GIFT_IDS = {
    "gift_1min",
    "gift_5min",
    "gift_10min",
    "gift_15min",
    "gift_30min",
    "gift_45min",
    "gift_1hr",
    "gift_1hr30min",
    "gift_2hr",
    "gift_3hr",
    "gift_4hr",
    "gift_5hr",
    "gift_6hr",
    "gift_12hr",
    "gift_1day"
}
-- ========================================================

-- ================== 核心操作 ==================
local function doUpgradeCar(slot)
    if not UpgradeCarRemote then return end
    pcall(function() UpgradeCarRemote:InvokeServer(slot) end)
end

local function doPickup(slot)
    if not PickupRemote then return end
    pcall(function() PickupRemote:InvokeServer(slot) end)
end

local function doUpgradeBase()
    if not UpgradeBaseRemote then return end
    pcall(function() UpgradeBaseRemote:InvokeServer() end)
end

local function doClaimGift(giftId)
    if not ClaimGiftRemote then return end
    pcall(function() ClaimGiftRemote:FireServer(giftId) end)
end

local function doRebirth()
    if not RebirthRemote then return end
    pcall(function() RebirthRemote:InvokeServer() end)
end

local function doUpgradeSpeed()
    if not UpgradeSpeedRemote then return end
    pcall(function() UpgradeSpeedRemote:InvokeServer(1) end)  -- 每次升1级
end

-- ================== 自动升级车库 ==================
local carUpgradeRunning = false
local carSlot = 0

AutoTab:AddToggle("AutoUpgradeCar", {
    Title = "自动升级车库",
    Description = "开启后无限循环 1→22 升级车辆槽位",
    Default = false
}):OnChanged(function(state)
    carUpgradeRunning = state
    if not state then
        Fluent:Notify({ Title = "自动升级车库已停止", Content = "当前进度: 槽位 " .. carSlot .. "/22", Duration = 3 })
        return
    end
    task.spawn(function()
        while carUpgradeRunning do
            for slot = 1, 22 do
                if not carUpgradeRunning then break end
                carSlot = slot
                doUpgradeCar(slot)
                task.wait(0.01)
            end
        end
    end)
end)

-- ================== 自动拾取车辆 ==================
local pickupRunning = false
local pickupSlot = 0

AutoTab:AddToggle("AutoPickup", {
    Title = "自动拾取车辆",
    Description = "开启后无限循环 1→22 拾取槽位车辆",
    Default = false
}):OnChanged(function(state)
    pickupRunning = state
    if not state then
        Fluent:Notify({ Title = "自动拾取已停止", Content = "当前进度: 槽位 " .. pickupSlot .. "/22", Duration = 3 })
        return
    end
    task.spawn(function()
        while pickupRunning do
            for slot = 1, 22 do
                if not pickupRunning then break end
                pickupSlot = slot
                doPickup(slot)
                task.wait(0.01)
            end
        end
    end)
end)

-- ================== 自动升级基地 ==================
local baseUpgradeRunning = false

AutoTab:AddToggle("AutoUpgradeBase", {
    Title = "自动升级基地",
    Description = "开启后无限循环点击升级基地",
    Default = false
}):OnChanged(function(state)
    baseUpgradeRunning = state
    if not state then
        Fluent:Notify({ Title = "自动升级基地已停止", Content = "已手动关闭", Duration = 3 })
        return
    end
    task.spawn(function()
        while baseUpgradeRunning do
            doUpgradeBase()
            task.wait(0.01)
        end
    end)
end)

-- ================== 自动领取在线奖励 ==================
local onlineRewardRunning = false

AutoTab:AddToggle("AutoClaimOnlineReward", {
    Title = "自动领取在线奖励",
    Description = "开启后循环领取所有在线时长礼物",
    Default = false
}):OnChanged(function(state)
    onlineRewardRunning = state
    if not state then
        Fluent:Notify({ Title = "自动领取已停止", Content = "已手动关闭", Duration = 3 })
        return
    end
    task.spawn(function()
        while onlineRewardRunning do
            for _, giftId in ipairs(GIFT_IDS) do
                if not onlineRewardRunning then break end
                doClaimGift(giftId)
                task.wait(1)
            end
            task.wait(30)
        end
    end)
end)

-- ================== 自动重生 ==================
local rebirthRunning = false

AutoTab:AddToggle("AutoRebirth", {
    Title = "自动重生",
    Description = "开启后无限循环执行重生（获取金币加成）",
    Default = false
}):OnChanged(function(state)
    rebirthRunning = state
    if not state then
        Fluent:Notify({ Title = "自动重生已停止", Content = "已手动关闭", Duration = 3 })
        return
    end
    task.spawn(function()
        while rebirthRunning do
            doRebirth()
            task.wait(1)
        end
    end)
end)

-- ================== 自动升级速度 ==================
local speedUpgradeRunning = false

AutoTab:AddToggle("AutoUpgradeSpeed", {
    Title = "自动升级速度",
    Description = "开启后无限循环升级速度（每次1级）",
    Default = false
}):OnChanged(function(state)
    speedUpgradeRunning = state
    if not state then
        Fluent:Notify({ Title = "自动升级速度已停止", Content = "已手动关闭", Duration = 3 })
        return
    end
    task.spawn(function()
        while speedUpgradeRunning do
            doUpgradeSpeed()
            task.wait(0.01)
        end
    end)
end)

-- ================== 穿墙功能（传送标签页顶部） ==================
local Players = game:GetService("Players")
local player = Players.LocalPlayer
local RunService = game:GetService("RunService")

local noclipEnabled = false
local noclipConnection = nil

local function enableNoclip()
    if noclipConnection then return end
    noclipConnection = RunService.Stepped:Connect(function()
        local char = player.Character
        if char then
            for _, part in ipairs(char:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CanCollide = false
                end
            end
        end
    end)
end

local function disableNoclip()
    if noclipConnection then
        noclipConnection:Disconnect()
        noclipConnection = nil
    end
    local char = player.Character
    if char then
        for _, part in ipairs(char:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = true
            end
        end
    end
end

player.CharacterAdded:Connect(function(char)
    if noclipEnabled then
        task.wait(0.1)
        enableNoclip()
    end
end)

-- ================== 传送标签页控件 ==================

-- 1. 穿墙开关
TeleportTab:AddToggle("Noclip", {
    Title = "🚧 穿墙模式",
    Description = "开启后角色可穿透所有墙体（传送必备）",
    Default = false
}):OnChanged(function(state)
    noclipEnabled = state
    if state then
        enableNoclip()
    else
        disableNoclip()
    end
end)

-- 2. 传送点
local POSITIONS = {
    Home = Vector3.new(53.48, 12.58, 31.96),           -- 家
    Secret = Vector3.new(-2108.85, 12.41, 74.10),      -- 秘密区（最高级车）
    Sacred = Vector3.new(-1547.77, 12.41, 56.34),      -- 神圣区
    Legend = Vector3.new(-992.37, 20.54, 77.12)        -- 传奇区
}

local function teleportTo(position, name)
    local char = player.Character
    if not char then
        Fluent:Notify({ Title = "传送失败", Content = "角色尚未加载", Duration = 2 })
        return
    end
    local root = char:FindFirstChild("HumanoidRootPart")
    if root then
        root.CFrame = CFrame.new(position)
        Fluent:Notify({ Title = "传送成功", Content = "已到达 " .. name, Duration = 2 })
    else
        Fluent:Notify({ Title = "传送失败", Content = "未找到 HumanoidRootPart", Duration = 2 })
    end
end

TeleportTab:AddButton({
    Title = "🏠 瞬移回家",
    Description = "传送至家中",
    Callback = function()
        teleportTo(POSITIONS.Home, "家")
    end
})

TeleportTab:AddButton({
    Title = "🚗 瞬移到秘密区",
    Description = "传送至最高级车生产区",
    Callback = function()
        teleportTo(POSITIONS.Secret, "秘密区")
    end
})

TeleportTab:AddButton({
    Title = "✨ 瞬移到神圣区",
    Description = "传送至神圣区",
    Callback = function()
        teleportTo(POSITIONS.Sacred, "神圣区")
    end
})

TeleportTab:AddButton({
    Title = "🌟 瞬移到传奇区",
    Description = "传送至传奇区",
    Callback = function()
        teleportTo(POSITIONS.Legend, "传奇区")
    end
})

TeleportTab:AddParagraph({
    Title = "坐标信息",
    Content = string.format(
        "家: %.2f, %.2f, %.2f\n秘密区: %.2f, %.2f, %.2f\n神圣区: %.2f, %.2f, %.2f\n传奇区: %.2f, %.2f, %.2f",
        POSITIONS.Home.X, POSITIONS.Home.Y, POSITIONS.Home.Z,
        POSITIONS.Secret.X, POSITIONS.Secret.Y, POSITIONS.Secret.Z,
        POSITIONS.Sacred.X, POSITIONS.Sacred.Y, POSITIONS.Sacred.Z,
        POSITIONS.Legend.X, POSITIONS.Legend.Y, POSITIONS.Legend.Z
    )
})

Window.Root.Visible = false  -- 默认隐藏，由悬浮按钮控制
