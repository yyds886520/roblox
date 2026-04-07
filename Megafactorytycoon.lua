local function checkServer()
    local tycoons = workspace:FindFirstChild("Tycoons")
    local collectEvent = game:GetService("ReplicatedStorage"):FindFirstChild("Events") and game:GetService("ReplicatedStorage").Events:FindFirstChild("CollectMoney")
    if not tycoons or not collectEvent then
        local screenGui = Instance.new("ScreenGui")
        screenGui.Name = "ErrorNotify"
        screenGui.ResetOnSpawn = false
        screenGui.Parent = game:GetService("CoreGui")
        
        local frame = Instance.new("Frame")
        frame.Size = UDim2.fromOffset(300, 60)
        frame.AnchorPoint = Vector2.new(1, 1)
        frame.Position = UDim2.new(1, 50, 1, -70)
        frame.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
        frame.BackgroundTransparency = 1
        frame.BorderSizePixel = 0
        frame.Parent = screenGui
        
        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(0, 8)
        corner.Parent = frame
        
        local text = Instance.new("TextLabel")
        text.Size = UDim2.new(1, -20, 1, 0)
        text.Position = UDim2.fromOffset(10, 0)
        text.BackgroundTransparency = 1
        text.Text = "您不在对应的服务器（超级工厂大亨），无法执行此脚本"
        text.TextColor3 = Color3.fromRGB(255, 255, 255)
        text.TextSize = 14
        text.Font = Enum.Font.GothamBold
        text.TextWrapped = true
        text.Parent = frame
        
        local TweenService = game:GetService("TweenService")
        
        local slideIn = TweenService:Create(frame, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            Position = UDim2.new(1, -20, 1, -70),
            BackgroundTransparency = 0.1
        })
        slideIn:Play()
        
        task.wait(8)
        
        local slideOut = TweenService:Create(frame, TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
            Position = UDim2.new(1, 50, 1, -70),
            BackgroundTransparency = 1
        })
        slideOut:Play()
        slideOut.Completed:Wait()
        
        screenGui:Destroy()
        return false
    end
    return true
end

if not checkServer() then return end

local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()

local Window = Fluent:CreateWindow({
    Title = "超级工厂大亨助手",
    SubTitle = "by.小梦",
    TabWidth = 160,
    Size = UDim2.fromOffset(450, 420),
    Acrylic = false,
    Theme = "Darker",
    MinimizeKey = Enum.KeyCode.LeftControl
})

local moneyTab = Window:AddTab({ Title = "拾取金钱", Icon = "dollar-sign" })
local infoTab = Window:AddTab({ Title = "信息", Icon = "info" })

do
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "FluentFloatButton"
    screenGui.ResetOnSpawn = false
    screenGui.Parent = game:GetService("CoreGui")

    local button = Instance.new("ImageButton")
    button.Size = UDim2.fromOffset(50, 50)
    button.Position = UDim2.fromOffset(100, 100)
    button.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    button.BackgroundTransparency = 0.2
    button.Image = "rbxassetid://10709791437"
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

local toggle = moneyTab:AddToggle("AutoCollect", {
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

infoTab:AddSection("玩家与服务器信息")

local namePara = infoTab:AddParagraph({ Title = "用户名", Content = game.Players.LocalPlayer.Name })
local displayNamePara = infoTab:AddParagraph({ Title = "昵称", Content = game.Players.LocalPlayer.DisplayName })
local userIdPara = infoTab:AddParagraph({ Title = "ID", Content = tostring(game.Players.LocalPlayer.UserId) })
local accountAgePara = infoTab:AddParagraph({ Title = "账号年龄", Content = game.Players.LocalPlayer.AccountAge .. " 天" })

local executorName = "Unknown"
pcall(function()
    executorName = identifyexecutor()
end)
local executorPara = infoTab:AddParagraph({ Title = "注入器", Content = executorName })

local fpsPara = infoTab:AddParagraph({ Title = "FPS", Content = "计算中..." })
local pingPara = infoTab:AddParagraph({ Title = "Ping", Content = "计算中..." })
local playerCountPara = infoTab:AddParagraph({ Title = "服务器玩家数", Content = #game:GetService("Players"):GetPlayers() .. "/" .. game:GetService("Players").MaxPlayers })
local jobIdPara = infoTab:AddParagraph({ Title = "JobId", Content = game.JobId })
local placeIdPara = infoTab:AddParagraph({ Title = "PlaceId", Content = tostring(game.PlaceId) })

task.spawn(function()
    while true do
        local fps = workspace:GetRealPhysicsFPS()
        fpsPara:SetDesc(string.format("%.1f", fps))
        
        local ping = game:GetService("Stats").Network.ServerStatsItem["Data Ping"]:GetValueString()
        pingPara:SetDesc(ping)
        
        playerCountPara:SetDesc(#game:GetService("Players"):GetPlayers() .. "/" .. game:GetService("Players").MaxPlayers)
        
        task.wait(1)
    end
end)

Window.Root.Visible = true
