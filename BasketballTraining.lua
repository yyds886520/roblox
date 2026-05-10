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
    Main = Window:AddTab({ Title = "主要", Icon = "star" }),
    Earth = Window:AddTab({ Title = "地球", Icon = "zap" }),
    Beach = Window:AddTab({ Title = "沙滩", Icon = "star" }),
    Chapter3 = Window:AddTab({ Title = "海洋", Icon = "heart" }),
    Chapter4 = Window:AddTab({ Title = "火山", Icon = "fire" }),
    Chapter5 = Window:AddTab({ Title = "天空", Icon = "cloud" }),
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

-- 批量生成章节功能的函数
local function createChapter(tab, chapterNumber, prefix)
    for level = 1, 12 do
        local args = { "Train", "Increment", level, chapterNumber }
        local running = false
        local toggle = tab:AddToggle(prefix .. "Shot" .. level, {
            Title = "快速投篮 " .. level,
            Description = "间隔0.01秒 Train/Increment (" .. level .. ", " .. chapterNumber .. ")",
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
createChapter(Tabs.Earth, 1, "Earth")
createChapter(Tabs.Beach, 2, "Beach")
createChapter(Tabs.Chapter3, 3, "Ch3")
createChapter(Tabs.Chapter4, 4, "Ch4")
createChapter(Tabs.Chapter5, 5, "Ch5")

-- 主要：刷钻石钥匙
do
    local args = { "DunkBattle", "DunkBattleWin", "Wizard" }
    local running = false
    local toggle = Tabs.Main:AddToggle("DiamondKey", {
        Title = "刷钻石钥匙",
        Description = "间隔0.01秒循环发送",
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

-- 主要：自动开宝箱(钻石)
do
    local args = { "Crates", "OpenOne", "Diamond", {} }
    local running = false
    local toggle = Tabs.Main:AddToggle("AutoCrate", {
        Title = "自动开宝箱(钻石)",
        Description = "间隔0.01秒打开钻石宝箱",
        Default = false
    })
    toggle:OnChanged(function(state)
        running = state
        if not state then return end
        task.spawn(function()
            while running do
                pcall(function()
                    game:GetService("ReplicatedStorage").Events.InvokeServerAction:InvokeServer(unpack(args))
                end)
                task.wait(0.01)
            end
        end)
    end)
    Options.AutoCrate:SetValue(false)
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
