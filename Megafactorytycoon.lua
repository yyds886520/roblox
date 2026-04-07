local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()

local Window = Fluent:CreateWindow({
    Title = "超级工厂大亨助手",
    SubTitle = "by.小梦",
    TabWidth = 160,
    Size = UDim2.fromOffset(420, 150),
    Acrylic = false,
    Theme = "Darker",
    MinimizeKey = Enum.KeyCode.LeftControl
})

local MainTab = Window:AddTab({ Title = "拾取金钱", Icon = "dollar-sign" })

local function getCollectPart()
    local player = game.Players.LocalPlayer
    local tycoons = workspace:FindFirstChild("Tycoons")
    if not tycoons then return nil end
    
    for _, tycoon in ipairs(tycoons:GetChildren()) do
        local billboard = tycoon:FindFirstChild("BillboardGui")
        if billboard and billboard:FindFirstChild("Name") then
            local text = billboard.Name:IsA("TextLabel") and billboard.Name.Text or billboard.Name
            if text == player.Name then
                local build = tycoon:FindFirstChild("Build")
                if build then return build:FindFirstChild("Collect") end
            end
        end
        if tycoon:GetAttribute("Owner") == player.Name or tycoon:GetAttribute("OwnerId") == player.UserId then
            local build = tycoon:FindFirstChild("Build")
            if build then return build:FindFirstChild("Collect") end
        end
    end
    local greenTycoon = tycoons:FindFirstChild("Green")
    if greenTycoon then
        local build = greenTycoon:FindFirstChild("Build")
        if build then return build:FindFirstChild("Collect") end
    end
    return nil
end

local collectPart = getCollectPart()
if collectPart then
    print("已找到 Collect 部件:", collectPart:GetFullName())
else
    print("未找到 Collect 部件，自动拾取将无法工作")
end

local collectEvent = game:GetService("ReplicatedStorage"):FindFirstChild("Events"):FindFirstChild("CollectMoney")
if not collectEvent then
    warn("未找到 CollectMoney 远程事件")
end

local running = false
local interval = 0.1

local toggle = MainTab:AddToggle("AutoCollect", {
    Title = "自动拾取金钱",
    Description = "开启后无限循环触发拾取",
    Default = false
})

local function doCollect()
    if not collectEvent or not collectPart then return end
    local args = { collectPart }
    pcall(function()
        collectEvent:FireServer(unpack(args))
    end)
end

toggle:OnChanged(function(state)
    running = state
    if not state then return end
    task.spawn(function()
        while running do
            doCollect()
            task.wait(interval)
        end
    end)
end)

Window.Root.Visible = true
