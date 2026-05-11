local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
local SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/SaveManager.lua"))()
local InterfaceManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/InterfaceManager.lua"))()

local Window = Fluent:CreateWindow({
    Title = "篮球训练",
    SubTitle = "by.小梦",
    TabWidth = 160,
    Size = UDim2.fromOffset(550, 380),
    Acrylic = false,
    Theme = "Darker",
    MinimizeKey = Enum.KeyCode.LeftControl
})
Window.Root.Visible = true

local Tabs = {
    Keys = Window:AddTab({ Title = "刷钥匙", Icon = "star" }),
    Auto = Window:AddTab({ Title = "自动", Icon = "bot" }),
    Earth = Window:AddTab({ Title = "地球", Icon = "zap" }),
    Beach = Window:AddTab({ Title = "沙滩", Icon = "star" }),
    Winter = Window:AddTab({ Title = "冬天", Icon = "heart" }),
    Candy = Window:AddTab({ Title = "糖果", Icon = "fire" }),
    Ocean = Window:AddTab({ Title = "海洋", Icon = "cloud" }),
    Settings = Window:AddTab({ Title = "设置", Icon = "settings" })
}
local Options = Fluent.Options

-- 浮动按钮
do
    local CUSTOM_IMAGE = "rbxassetid://10709791437"
    local screenGui = Instance.new("ScreenGui", game:GetService("CoreGui"))
    screenGui.Name = "FluentFloatButton"
    screenGui.ResetOnSpawn = false
    screenGui.Enabled = true

    local button = Instance.new("ImageButton", screenGui)
    button.Size = UDim2.fromOffset(50, 50)
    button.Position = UDim2.fromOffset(100, 100)
    button.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    button.BackgroundTransparency = 0.2
    button.Image = CUSTOM_IMAGE
    button.ScaleType = Enum.ScaleType.Fit
    button.AutoButtonColor = false
    Instance.new("UICorner", button).CornerRadius = UDim.new(1, 0)
    local imgStroke = Instance.new("UIStroke", button)
    imgStroke.Thickness = 1
    imgStroke.Color = Color3.fromRGB(100, 100, 100)
    imgStroke.Transparency = 0.5

    local uis = game:GetService("UserInputService")
    local dragging, dragStartPos, buttonStartPos
    button.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStartPos = input.Position
            buttonStartPos = button.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then dragging = false end
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
        button:TweenSize(UDim2.fromOffset(55, 55), "Out", "Quad", 0.2, true)
    end)
    button.MouseLeave:Connect(function()
        button:TweenSize(UDim2.fromOffset(50, 50), "Out", "Quad", 0.2, true)
    end)
end

-- 地球力量需求表
local earthPowerRequirement = {
    "0力量", "500力量", "2.5千力量", "10千力量", "25千力量", "50千力量",
    "70千力量", "125千力量", "250千力量", "650千力量", "1.5百万力量", "2.5力量"
}

-- 沙滩力量需求表
local beachPowerRequirement = {
    "0力量", "2.5百万力量", "5百万力量", "25百万力量", "50百万力量", "100百万力量",
    "175百万力量", "250百万力量", "350百万力量", "500百万力量", "750百万力量", "1.25B力量"
}

-- 冬天力量需求表
local winterPowerRequirement = {
    "0力量", "1.5B力量", "3B力量", "9B力量", "18B力量", "35B力量",
    "55B力量", "90B力量", "150B力量", "250B力量", "400B力量", "750B力量"
}

-- 糖果力量需求表
local candyPowerRequirement = {
    "0力量", "7T力量", "15T力量", "30T力量", "45T力量", "57T力量",
    "85T力量", "125T力量", "175T力量", "285T力量", "500T力量", "1Qa力量"
}

-- 海洋力量需求表
local oceanPowerRequirement = {
    "0力量", "5Qa力量", "12.5Qa力量", "25Qa力量", "50Qa力量", "90Qa力量",
    "150Qa力量", "250Qa力量", "400Qa力量", "700Qa力量", "1.2Qi力量", "2Qi力量"
}

-- 批量生成章节功能
local function createChapter(tab, chapterNumber, prefix, powerTable)
    for level = 1, 12 do
        local args = { "Train", "Increment", level, chapterNumber }
        local running = false
        local desc = "需" .. powerTable[level]
        local toggle = tab:AddToggle(prefix .. "Shot" .. level, {
            Title = "快速投篮 " .. level,
            Description = desc,
            Default = false
        })
        toggle:OnChanged(function(state)
            running = state
            if not state then return end
            task.spawn(function()
                while running do
                    pcall(function()
                        game:GetService("ReplicatedStorage").Events.RequestServerAction:FireServer(unpack(args))
                    end)
                    task.wait(0.01)
                end
            end)
        end)
        Options[prefix .. "Shot" .. level]:SetValue(false)
    end
end

-- 生成各章节
createChapter(Tabs.Earth, 1, "Earth", earthPowerRequirement)
createChapter(Tabs.Beach, 2, "Beach", beachPowerRequirement)
createChapter(Tabs.Winter, 3, "Winter", winterPowerRequirement)
createChapter(Tabs.Candy, 4, "Candy", candyPowerRequirement)
createChapter(Tabs.Ocean, 5, "Ocean", oceanPowerRequirement)

-- 刷钥匙：白金
do
    local args = { "DunkBattle", "DunkBattleWin", "Aquaman" }
    local running = false
    local toggle = Tabs.Keys:AddToggle("PlatinumKey", {
        Title = "刷钥匙(白金)",
        Description = "循环获取白金钥匙",
        Default = false
    })
    toggle:OnChanged(function(state)
        running = state
        if not state then return end
        task.spawn(function()
            while running do
                pcall(function()
                    game:GetService("ReplicatedStorage").Events.RequestServerAction:FireServer(unpack(args))
                end)
                task.wait(0.01)
            end
        end)
    end)
    Options.PlatinumKey:SetValue(false)
end

-- 刷钥匙：钻石
do
    local args = { "DunkBattle", "DunkBattleWin", "Wizard" }
    local running = false
    local toggle = Tabs.Keys:AddToggle("DiamondKey", {
        Title = "刷钻石钥匙",
        Description = "循环获取钻石钥匙",
        Default = false
    })
    toggle:OnChanged(function(state)
        running = state
        if not state then return end
        task.spawn(function()
            while running do
                pcall(function()
                    game:GetService("ReplicatedStorage").Events.RequestServerAction:FireServer(unpack(args))
                end)
                task.wait(0.01)
            end
        end)
    end)
    Options.DiamondKey:SetValue(false)
end

-- 刷钥匙：黄金
do
    local args = { "DunkBattle", "DunkBattleWin", "Snow Gentleman" }
    local running = false
    local toggle = Tabs.Keys:AddToggle("GoldKey", {
        Title = "刷钥匙(黄金)",
        Description = "循环获取黄金钥匙",
        Default = false
    })
    toggle:OnChanged(function(state)
        running = state
        if not state then return end
        task.spawn(function()
            while running do
                pcall(function()
                    game:GetService("ReplicatedStorage").Events.RequestServerAction:FireServer(unpack(args))
                end)
                task.wait(0.01)
            end
        end)
    end)
    Options.GoldKey:SetValue(false)
end

-- 刷钥匙：白银
do
    local args = { "DunkBattle", "DunkBattleWin", "Korblox Deathspeaker" }
    local running = false
    local toggle = Tabs.Keys:AddToggle("SilverKey", {
        Title = "刷钥匙(白银)",
        Description = "循环获取白银钥匙",
        Default = false
    })
    toggle:OnChanged(function(state)
        running = state
        if not state then return end
        task.spawn(function()
            while running do
                pcall(function()
                    game:GetService("ReplicatedStorage").Events.RequestServerAction:FireServer(unpack(args))
                end)
                task.wait(0.01)
            end
        end)
    end)
    Options.SilverKey:SetValue(false)
end

-- 刷钥匙：青铜
do
    local args = { "DunkBattle", "DunkBattleWin", "Punk Kid" }
    local running = false
    local toggle = Tabs.Keys:AddToggle("BronzeKey", {
        Title = "刷钥匙(青铜)",
        Description = "循环获取青铜钥匙",
        Default = false
    })
    toggle:OnChanged(function(state)
        running = state
        if not state then return end
        task.spawn(function()
            while running do
                pcall(function()
                    game:GetService("ReplicatedStorage").Events.RequestServerAction:FireServer(unpack(args))
                end)
                task.wait(0.01)
            end
        end)
    end)
    Options.BronzeKey:SetValue(false)
end

-- 自动：自动领取在线礼物
do
    local running = false
    local toggle = Tabs.Auto:AddToggle("AutoPlaytimeReward", {
        Title = "自动领取在线礼物",
        Description = "循环领取全部12个奖励",
        Default = false
    })
    toggle:OnChanged(function(state)
        running = state
        if not state then return end
        task.spawn(function()
            while running do
                for reward = 1, 12 do
                    if not running then break end
                    pcall(function()
                        game:GetService("ReplicatedStorage").Events.InvokeServerAction:InvokeServer("PlaytimeRewards", "Request", reward)
                    end)
                    task.wait(0.01)
                end
                task.wait(0.01)
            end
        end)
    end)
    Options.AutoPlaytimeReward:SetValue(false)
end

-- 自动：自动重生
do
    local running = false
    local toggle = Tabs.Auto:AddToggle("AutoRebirth", {
        Title = "自动重生",
        Description = "重生后收益翻倍",
        Default = false
    })
    toggle:OnChanged(function(state)
        running = state
        if not state then return end
        task.spawn(function()
            while running do
                pcall(function()
                    game:GetService("ReplicatedStorage").Events.InvokeServerAction:InvokeServer("Rebirths", "Request")
                end)
                task.wait(0.01)
            end
        end)
    end)
    Options.AutoRebirth:SetValue(false)
end

-- 设置
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
