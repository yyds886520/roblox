local player = game:GetService("Players").LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local runService = game:GetService("RunService")
local tweenService = game:GetService("TweenService")
local userInputService = game:GetService("UserInputService")
local workspace = game:GetService("Workspace")
local rs = game:GetService("ReplicatedStorage")

if playerGui:FindFirstChild("FlashUI") then
    playerGui.FlashUI:Destroy()
end

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "FlashUI"
screenGui.ResetOnSpawn = false
screenGui.Parent = playerGui

local expandedHeight = 295
local collapsedHeight = 38
local frameWidth = 200

local shadow = Instance.new("Frame")
shadow.Size = UDim2.new(0, frameWidth, 0, expandedHeight)
shadow.Position = UDim2.new(0, 120, 0, 52)
shadow.BackgroundColor3 = Color3.new(0, 0, 0)
shadow.BackgroundTransparency = 0.7
shadow.BorderSizePixel = 0
shadow.Parent = screenGui

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, frameWidth, 0, expandedHeight)
mainFrame.Position = UDim2.new(0, 120, 0, 50)
mainFrame.BackgroundColor3 = Color3.new(0, 0, 0)
mainFrame.BackgroundTransparency = 0.15
mainFrame.BorderSizePixel = 0
mainFrame.ClipsDescendants = true
mainFrame.Parent = screenGui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 8)
corner.Parent = mainFrame

local cornerShadow = Instance.new("UICorner")
cornerShadow.CornerRadius = UDim.new(0, 8)
cornerShadow.Parent = shadow

local titleBar = Instance.new("Frame")
titleBar.Size = UDim2.new(1, 0, 0, 38)
titleBar.BackgroundTransparency = 1
titleBar.BorderSizePixel = 0
titleBar.Parent = mainFrame

local titleText = Instance.new("TextLabel")
titleText.Size = UDim2.new(1, 0, 1, 0)
titleText.BackgroundTransparency = 1
titleText.Text = "踢一个幸运方块"
titleText.TextColor3 = Color3.new(1, 1, 1)
titleText.Font = Enum.Font.GothamBold
titleText.TextSize = 14
titleText.TextXAlignment = Enum.TextXAlignment.Center
titleText.TextYAlignment = Enum.TextYAlignment.Center
titleText.Parent = titleBar

local collapseBtn = Instance.new("TextButton")
collapseBtn.Size = UDim2.new(0, 24, 0, 24)
collapseBtn.Position = UDim2.new(1, -32, 0, 7)
collapseBtn.BackgroundTransparency = 1
collapseBtn.Text = "▼"
collapseBtn.TextColor3 = Color3.new(1, 1, 1)
collapseBtn.Font = Enum.Font.GothamBold
collapseBtn.TextSize = 14
collapseBtn.Parent = titleBar

local contentFrame = Instance.new("Frame")
contentFrame.Size = UDim2.new(1, 0, 1, -38)
contentFrame.Position = UDim2.new(0, 0, 0, 38)
contentFrame.BackgroundTransparency = 1
contentFrame.BorderSizePixel = 0
contentFrame.Parent = mainFrame

local paddingLeft = 12

local function addToggleRow(y, text, callback)
    local row = Instance.new("Frame")
    row.Size = UDim2.new(1, -2 * paddingLeft, 0, 32)
    row.Position = UDim2.new(0, paddingLeft, 0, y)
    row.BackgroundTransparency = 1
    row.BorderSizePixel = 0
    row.Parent = contentFrame

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -40, 1, 0)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = Color3.new(1, 1, 1)
    label.Font = Enum.Font.Gotham
    label.TextSize = 14
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.TextYAlignment = Enum.TextYAlignment.Center
    label.Parent = row

    local checkboxFrame = Instance.new("Frame")
    checkboxFrame.Size = UDim2.new(0, 19, 0, 19)
    checkboxFrame.Position = UDim2.new(1, -19, 0.5, -9.5)
    checkboxFrame.BackgroundColor3 = Color3.new(0, 0, 0)
    checkboxFrame.BackgroundTransparency = 0.85
    checkboxFrame.BorderSizePixel = 1
    checkboxFrame.BorderColor3 = Color3.new(1, 1, 1)
    checkboxFrame.Parent = row

    local checkMark = Instance.new("TextLabel")
    checkMark.Size = UDim2.new(1, 0, 1, 0)
    checkMark.BackgroundTransparency = 1
    checkMark.Text = "✓"
    checkMark.TextColor3 = Color3.new(1, 1, 1)
    checkMark.Font = Enum.Font.GothamBold
    checkMark.TextSize = 14
    checkMark.TextXAlignment = Enum.TextXAlignment.Center
    checkMark.TextYAlignment = Enum.TextYAlignment.Center
    checkMark.Visible = false
    checkMark.Parent = checkboxFrame

    local enabled = false
    local touchStartPos = nil
    local touchMoved = false
    local moveThreshold = 10

    local function setState(state)
        enabled = state
        checkMark.Visible = state
        if callback then callback(state) end
    end

    row.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            touchStartPos = input.Position
            touchMoved = false
        end
    end)

    row.InputChanged:Connect(function(input)
        if touchStartPos and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = (input.Position - touchStartPos).Magnitude
            if delta > moveThreshold then
                touchMoved = true
            end
        end
    end)

    row.InputEnded:Connect(function(input)
        if (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) and not touchMoved then
            setState(not enabled)
        end
        touchStartPos = nil
        touchMoved = false
    end)

    return setState
end

local perfectKickEnabled = false
local kickHeartbeat
local canFire = false
local lastClick = 0
local BAR_PATH = "KickMinigame.Bar.MovingBar"
local THRESHOLD = 0.98

local function getMovingBar()
    local obj = playerGui
    for part in string.gmatch(BAR_PATH, "[^%.]+") do
        obj = obj and obj:FindFirstChild(part)
    end
    return obj
end

local function kickClick(x, y)
    local vim = game:GetService("VirtualInputManager")
    vim:SendMouseButtonEvent(x, y, 0, true, game, 0)
    task.wait(0.05)
    vim:SendMouseButtonEvent(x, y, 0, false, game, 0)
end

local function startPerfectKick()
    canFire = false
    lastClick = 0
    kickHeartbeat = runService.Heartbeat:Connect(function()
        local bar = getMovingBar()
        if not bar then
            canFire = false
            return
        end
        local scale = bar.Size.Y.Scale
        if scale < 0.3 then
            canFire = true
        end
        if scale >= THRESHOLD and canFire and tick() - lastClick > 0.5 then
            canFire = false
            lastClick = tick()
            local vp = workspace.CurrentCamera.ViewportSize
            kickClick(10, vp.Y - 10)
        end
    end)
end

local function stopPerfectKick()
    if kickHeartbeat then kickHeartbeat:Disconnect(); kickHeartbeat = nil end
end

local autoReturnEnabled = false
local followConn
local waveCheckConn
local waveRemoveConn
local charAddedConn
local wavesFolder = workspace:FindFirstChild("Waves")
local WAVE_OFFSET = Vector3.new(80, 5, 0)

local function stopFollowing()
    if followConn then
        followConn:Disconnect()
        followConn = nil
    end
end

local function startFollowing()
    if followConn then return end
    local root = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
    if not root then return end
    followConn = runService.RenderStepped:Connect(function()
        if not wavesFolder then stopFollowing(); return end
        local waveModel = wavesFolder:FindFirstChildWhichIsA("Model")
        if not waveModel then stopFollowing(); return end
        local wavePart = waveModel:FindFirstChildWhichIsA("BasePart")
        if not wavePart then stopFollowing(); return end
        local currentRoot = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
        if not currentRoot then stopFollowing(); return end
        currentRoot.CFrame = CFrame.new(wavePart.Position + WAVE_OFFSET, wavePart.Position)
    end)
end

local function startAutoReturn()
    if not wavesFolder then return end
    waveCheckConn = runService.Heartbeat:Connect(function()
        if not autoReturnEnabled then return end
        if followConn then return end
        local model = wavesFolder:FindFirstChildWhichIsA("Model")
        if model and model:FindFirstChildWhichIsA("BasePart") then
            startFollowing()
        end
    end)
    waveRemoveConn = wavesFolder.ChildRemoved:Connect(function()
        if not wavesFolder:FindFirstChildWhichIsA("Model") then
            stopFollowing()
        end
    end)
    charAddedConn = player.CharacterAdded:Connect(function(char)
        task.wait(0.5)
        if not autoReturnEnabled then return end
        if followConn then return end
        if wavesFolder and wavesFolder:FindFirstChildWhichIsA("Model") then
            startFollowing()
        end
    end)
    if wavesFolder:FindFirstChildWhichIsA("Model") then
        startFollowing()
    end
end

local function stopAutoReturn()
    stopFollowing()
    if waveCheckConn then waveCheckConn:Disconnect(); waveCheckConn = nil end
    if waveRemoveConn then waveRemoveConn:Disconnect(); waveRemoveConn = nil end
    if charAddedConn then charAddedConn:Disconnect(); charAddedConn = nil end
end

local collectCoinsEnabled = false
local collectLoop

local function getPlayerPlot()
    local plots = workspace:FindFirstChild("Plots")
    if not plots then return nil end
    for _, item in ipairs(plots:GetChildren()) do
        if item:GetAttribute("Owner") == player.Name then
            return item
        end
    end
    return nil
end

local function claimCoins()
    local plot = getPlayerPlot()
    if not plot then return end
    local char = player.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    local buttons = plot:FindFirstChild("Buttons")
    if not buttons then return end
    for _, slot in ipairs(buttons:GetChildren()) do
        pcall(function()
            firetouchinterest(hrp, slot, 0)
            firetouchinterest(hrp, slot, 1)
        end)
    end
end

local function startCollectCoins()
    collectLoop = task.spawn(function()
        while collectCoinsEnabled do
            claimCoins()
            task.wait(1)
        end
    end)
end

local function stopCollectCoins()
    collectCoinsEnabled = false
    if collectLoop then
        task.cancel(collectLoop)
        collectLoop = nil
    end
end

local autoX2Enabled = false
local x2Loop

local function clickX2Buttons()
    local kupg = playerGui:FindFirstChild("KickUpgrades")
    if not kupg then return end
    for _, btn in ipairs(kupg:GetChildren()) do
        if btn:IsA("ImageButton") and btn.Name == "Bonus" and btn.Visible then
            for _, conn in ipairs(getconnections(btn.MouseButton1Click)) do
                pcall(conn.Function)
            end
            for _, conn in ipairs(getconnections(btn.Activated)) do
                pcall(conn.Function)
            end
            break
        end
    end
end

local function startAutoX2()
    x2Loop = task.spawn(function()
        while autoX2Enabled do
            clickX2Buttons()
            task.wait(0.01)
        end
    end)
end

local function stopAutoX2()
    autoX2Enabled = false
    if x2Loop then
        task.cancel(x2Loop)
        x2Loop = nil
    end
end

local genX2Enabled = false
local genX2Loop

local function useDumbbell()
    pcall(function()
        rs.Shared.Packages.Network.rev_TaviMishkal:FireServer()
    end)
end

local function startGenX2()
    genX2Loop = task.spawn(function()
        while genX2Enabled do
            useDumbbell()
            local char = player.Character
            if char then
                local hrp = char:FindFirstChild("HumanoidRootPart")
                if hrp and hrp.Anchored then
                    pcall(function()
                        hrp.Anchored = false
                    end)
                end
            end
            task.wait(0.5)
        end
    end)
end

local function stopGenX2()
    genX2Enabled = false
    if genX2Loop then
        task.cancel(genX2Loop)
        genX2Loop = nil
    end
end

addToggleRow(0, "完美踢击", function(state)
    perfectKickEnabled = state
    if state then startPerfectKick() else stopPerfectKick() end
end)

addToggleRow(32, "自动回家", function(state)
    autoReturnEnabled = state
    if state then startAutoReturn() else stopAutoReturn() end
end)

addToggleRow(64, "收集金💰", function(state)
    collectCoinsEnabled = state
    if state then startCollectCoins() else stopCollectCoins() end
end)

addToggleRow(96, "自动×2力量", function(state)
    autoX2Enabled = state
    if state then startAutoX2() else stopAutoX2() end
end)

addToggleRow(128, "生成×2按钮", function(state)
    genX2Enabled = state
    if state then startGenX2() else stopGenX2() end
end)

local tipLabel = Instance.new("TextLabel")
tipLabel.Size = UDim2.new(1, -2 * paddingLeft, 0, 36)
tipLabel.Position = UDim2.new(0, paddingLeft, 0, 170)
tipLabel.BackgroundTransparency = 1
tipLabel.Text = "⚠️ 完美踢击开启后，重量商店会断触，重进游戏才恢复"
tipLabel.TextColor3 = Color3.fromRGB(255, 200, 0)
tipLabel.Font = Enum.Font.Gotham
tipLabel.TextSize = 11
tipLabel.TextWrapped = true
tipLabel.TextXAlignment = Enum.TextXAlignment.Left
tipLabel.TextYAlignment = Enum.TextYAlignment.Top
tipLabel.Parent = contentFrame

local authorRow = Instance.new("Frame")
authorRow.Size = UDim2.new(1, -2 * paddingLeft, 0, 32)
authorRow.Position = UDim2.new(0, paddingLeft, 0, 210)
authorRow.BackgroundTransparency = 1
authorRow.BorderSizePixel = 0
authorRow.Parent = contentFrame

local authorLabel = Instance.new("TextLabel")
authorLabel.Size = UDim2.new(1, 0, 1, 0)
authorLabel.BackgroundTransparency = 1
authorLabel.Text = "by.小梦"
authorLabel.TextColor3 = Color3.fromRGB(0, 150, 255)
authorLabel.Font = Enum.Font.GothamBold
authorLabel.TextSize = 15
authorLabel.TextXAlignment = Enum.TextXAlignment.Left
authorLabel.TextYAlignment = Enum.TextYAlignment.Center
authorLabel.Parent = authorRow

local dragging = false
local dragOffsetX = 0
local dragOffsetY = 0

titleBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragOffsetX = input.Position.X - mainFrame.AbsolutePosition.X
        dragOffsetY = input.Position.Y - mainFrame.AbsolutePosition.Y
    end
end)

userInputService.InputChanged:Connect(function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local newX = input.Position.X - dragOffsetX
        local newY = input.Position.Y - dragOffsetY
        mainFrame.Position = UDim2.new(0, newX, 0, newY)
        shadow.Position = UDim2.new(0, newX + 2, 0, newY + 2)
    end
end)

userInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = false
    end
end)

local isCollapsed = false
local function setCollapsed(collapsed)
    if collapsed == isCollapsed then return end
    isCollapsed = collapsed
    local targetHeight = collapsed and collapsedHeight or expandedHeight
    local tweenInfo = TweenInfo.new(0.3, Enum.EasingStyle.Linear)
    local goal = {Size = UDim2.new(0, frameWidth, 0, targetHeight)}
    local tween = tweenService:Create(mainFrame, tweenInfo, goal)
    tween:Play()
    local tweenShadow = tweenService:Create(shadow, tweenInfo, goal)
    tweenShadow:Play()
    collapseBtn.Text = collapsed and "▲" or "▼"
end

collapseBtn.MouseButton1Click:Connect(function()
    setCollapsed(not isCollapsed)
end)

setCollapsed(false)
