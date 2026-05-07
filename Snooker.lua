local Players = game:GetService("Players")
local player = Players.LocalPlayer
while not player do wait(0.5); player = Players.LocalPlayer end
local pGui = player:WaitForChild("PlayerGui")
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

local EXT_COLOR = Color3.new(1, 1, 1)
local DEFAULT_MULT = 3
local TWEEN_TIME = 0.25
local NOTIFY_TWEEN_IN = 0.4
local NOTIFY_TWEEN_OUT = 0.3
local NOTIFY_STAY = 3

local extendPart = nil
local multiplier = DEFAULT_MULT
local railsList = {}
local tablePart = nil
local uiCollapsed = false
local main, contentFrame, sliderFrame, knob, label, foldBtn, foldTriangle
local statusLabel

local function initTableRef()
    local tables = workspace:FindFirstChild("Tables")
    if tables and tables:FindFirstChild("Table1") then
        local table1 = tables.Table1
        tablePart = table1:FindFirstChild("Table")
        if tablePart then
            local coll = table1:FindFirstChild("Collision")
            if coll then
                local railsFolder = coll:FindFirstChild("Rails")
                if railsFolder then
                    railsList = {}
                    for _, v in ipairs(railsFolder:GetChildren()) do
                        if v:IsA("BasePart") then
                            table.insert(railsList, v)
                        end
                    end
                    return true
                end
            end
        end
    end
    return false
end

local function getHitData()
    for _, guides in ipairs(workspace:GetDescendants()) do
        if guides.Name == "Guides" and guides:FindFirstChild("HitTrajectory") then
            local part = guides.HitTrajectory
            if part:IsA("BasePart") and part.Size.Z > 0.001 then
                local cf = part.CFrame
                local half = part.Size.Z / 2
                local dir = cf.LookVector
                local back = cf.Position - dir * half
                local thick = Vector2.new(part.Size.X, part.Size.Y)
                return back, dir, part.Size.Z, thick
            end
        end
    end
    return nil
end

local function createLinePart(parent)
    local p = Instance.new("Part")
    p.Name = "ExtendLine"
    p.Anchored = true
    p.CanCollide = false
    p.Color = EXT_COLOR
    p.Material = Enum.Material.SmoothPlastic
    p.Size = Vector3.new(0.05, 0.05, 1)
    p.Transparency = 1
    p.Parent = parent
    return p
end

local function initExtendPart()
    if extendPart then extendPart:Destroy() end
    if tablePart then
        extendPart = createLinePart(tablePart)
    end
end

local function raycastToRails(origin, direction, maxDist)
    if #railsList == 0 then return nil, nil end
    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Whitelist
    params.FilterDescendantsInstances = railsList
    local result = workspace:Raycast(origin, direction * maxDist, params)
    if result then
        return result.Position, result.Normal
    end
    return nil, nil
end

local function updateLine()
    local backEnd, dir, origLen, thick = getHitData()
    if not backEnd then
        if extendPart then extendPart.Transparency = 1 end
        return
    end
    local desiredLen = origLen * multiplier
    local hitPos, _ = raycastToRails(backEnd, dir, desiredLen)
    local extendLen = desiredLen
    if hitPos then
        extendLen = (hitPos - backEnd).Magnitude
    end
    if extendPart then
        local center = backEnd + dir * (extendLen / 2)
        extendPart.Size = Vector3.new(thick.X, thick.Y, extendLen)
        extendPart.CFrame = CFrame.new(center, center + dir)
        extendPart.Transparency = 0
    end
end

local function showNotification(title, text, accentColor)
    local notifGui = Instance.new("ScreenGui", pGui)
    notifGui.ResetOnSpawn = false
    notifGui.Name = "Notification"

    local card = Instance.new("Frame", notifGui)
    card.Size = UDim2.new(0, 260, 0, 70)
    card.Position = UDim2.new(1, 20, 1, 20)
    card.AnchorPoint = Vector2.new(0, 0)
    card.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    card.BorderSizePixel = 0
    Instance.new("UICorner", card).CornerRadius = UDim.new(0, 10)

    local colorBar = Instance.new("Frame", card)
    colorBar.Size = UDim2.new(0, 4, 1, -16)
    colorBar.Position = UDim2.new(0, 8, 0, 8)
    colorBar.BackgroundColor3 = accentColor or Color3.fromRGB(96, 205, 255)
    Instance.new("UICorner", colorBar).CornerRadius = UDim.new(0, 2)

    local titleLabel = Instance.new("TextLabel", card)
    titleLabel.Text = title or ""
    titleLabel.Font = Enum.Font.SourceSansBold
    titleLabel.TextSize = 14
    titleLabel.TextColor3 = accentColor or Color3.new(1, 1, 1)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Size = UDim2.new(1, -30, 0, 18)
    titleLabel.Position = UDim2.new(0, 18, 0, 10)

    local textLabel = Instance.new("TextLabel", card)
    textLabel.Text = text or ""
    textLabel.Font = Enum.Font.SourceSans
    textLabel.TextSize = 12
    textLabel.TextColor3 = Color3.new(0.8, 0.8, 0.8)
    textLabel.BackgroundTransparency = 1
    textLabel.Size = UDim2.new(1, -30, 0, 0)
    textLabel.Position = UDim2.new(0, 18, 0, 32)
    textLabel.TextWrapped = true

    local targetPos = UDim2.new(1, -280, 1, -90)
    local tweenIn = TweenService:Create(card, TweenInfo.new(NOTIFY_TWEEN_IN, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Position = targetPos})
    tweenIn:Play()
    tweenIn.Completed:Wait()

    wait(NOTIFY_STAY)

    local tweenOut = TweenService:Create(card, TweenInfo.new(NOTIFY_TWEEN_OUT, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {Position = UDim2.new(1, 20, 1, 20)})
    tweenOut:Play()
    tweenOut.Completed:Wait()

    notifGui:Destroy()
end

local function toggleCollapse()
    uiCollapsed = not uiCollapsed
    local targetHeight = uiCollapsed and 28 or 115
    local tweenInfo = TweenInfo.new(TWEEN_TIME, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    local sizeTween = TweenService:Create(main, tweenInfo, {Size = UDim2.new(0, 220, 0, targetHeight)})
    sizeTween:Play()

    if uiCollapsed then
        foldTriangle.Text = "▶"
        task.delay(TWEEN_TIME, function()
            contentFrame.Visible = false
        end)
    else
        contentFrame.Visible = true
        foldTriangle.Text = "▼"
    end
end

local function buildUI()
    local screen = Instance.new("ScreenGui", pGui)
    screen.ResetOnSpawn = false
    screen.Name = "BilliardHelper"

    main = Instance.new("Frame", screen)
    main.Size = UDim2.new(0, 220, 0, 115)
    main.Position = UDim2.new(0, 20, 0, 100)
    main.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    main.BorderSizePixel = 0
    main.ClipsDescendants = true
    Instance.new("UICorner", main).CornerRadius = UDim.new(0, 8)

    local titleBar = Instance.new("Frame", main)
    titleBar.Size = UDim2.new(1, 0, 0, 28)
    titleBar.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    Instance.new("UICorner", titleBar).CornerRadius = UDim.new(0, 8)

    local titleLabel = Instance.new("TextLabel", titleBar)
    titleLabel.Text = "台球小助手 by.小梦"
    titleLabel.Font = Enum.Font.SourceSansBold
    titleLabel.TextSize = 13
    titleLabel.TextColor3 = Color3.new(1, 1, 1)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Size = UDim2.new(1, -30, 1, 0)
    titleLabel.Position = UDim2.new(0, 8, 0, 0)

    foldBtn = Instance.new("TextButton", titleBar)
    foldBtn.Size = UDim2.new(0, 24, 0, 24)
    foldBtn.Position = UDim2.new(1, -26, 0, 2)
    foldBtn.Text = ""
    foldBtn.BackgroundTransparency = 1
    foldTriangle = Instance.new("TextLabel", foldBtn)
    foldTriangle.Text = "▼"
    foldTriangle.Font = Enum.Font.SourceSansBold
    foldTriangle.TextSize = 14
    foldTriangle.TextColor3 = Color3.new(1, 1, 1)
    foldTriangle.BackgroundTransparency = 1
    foldTriangle.Size = UDim2.new(1, 0, 1, 0)
    foldTriangle.AnchorPoint = Vector2.new(0.5, 0.5)
    foldTriangle.Position = UDim2.new(0.5, 0, 0.5, 0)

    local drag, dragStart, startPos
    titleBar.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.Touch or i.UserInputType == Enum.UserInputType.MouseButton1 then
            drag = true
            dragStart = i.Position
            startPos = main.Position
            i.Changed:Connect(function()
                if i.UserInputState == Enum.UserInputState.End then drag = false end
            end)
        end
    end)
    titleBar.InputChanged:Connect(function(i)
        if drag and (i.UserInputType == Enum.UserInputType.Touch or i.UserInputType == Enum.UserInputType.MouseMovement) then
            local delta = i.Position - dragStart
            main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)

    foldBtn.MouseButton1Click:Connect(toggleCollapse)

    contentFrame = Instance.new("Frame", main)
    contentFrame.Size = UDim2.new(1, 0, 1, -28)
    contentFrame.Position = UDim2.new(0, 0, 0, 28)
    contentFrame.BackgroundTransparency = 1
    contentFrame.BorderSizePixel = 0

    sliderFrame = Instance.new("Frame", contentFrame)
    sliderFrame.Size = UDim2.new(1, -20, 0, 6)
    sliderFrame.Position = UDim2.new(0, 10, 1, -28)
    sliderFrame.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    sliderFrame.BorderSizePixel = 0
    Instance.new("UICorner", sliderFrame).CornerRadius = UDim.new(0, 3)

    knob = Instance.new("TextButton", sliderFrame)
    knob.Size = UDim2.new(0, 16, 0, 16)
    knob.Position = UDim2.new(0, -8, 0, -5)
    knob.BackgroundColor3 = Color3.fromRGB(100, 200, 255)
    knob.Text = ""
    knob.BorderSizePixel = 0
    Instance.new("UICorner", knob).CornerRadius = UDim.new(0, 8)

    label = Instance.new("TextLabel", contentFrame)
    label.Size = UDim2.new(1, -20, 0, 16)
    label.Position = UDim2.new(0, 10, 1, -46)
    label.Font = Enum.Font.SourceSansSemibold
    label.TextSize = 12
    label.TextColor3 = Color3.new(1, 1, 1)
    label.BackgroundTransparency = 1
    label.Text = "长度 x" .. DEFAULT_MULT

    local knbDown = false
    knob.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.Touch or i.UserInputType == Enum.UserInputType.MouseButton1 then
            knbDown = true
        end
    end)
    UIS.InputEnded:Connect(function(i)
        knbDown = false
    end)
    UIS.InputChanged:Connect(function(i)
        if knbDown and (i.UserInputType == Enum.UserInputType.Touch or i.UserInputType == Enum.UserInputType.MouseMovement) then
            local pos = math.clamp((i.Position.X - sliderFrame.AbsolutePosition.X) / sliderFrame.AbsoluteSize.X, 0, 1)
            knob.Position = UDim2.new(pos, -8, 0, -5)
            multiplier = 1 + pos * 19
            label.Text = "长度 x" .. string.format("%.1f", multiplier)
        end
    end)

    local initBtn = Instance.new("TextButton", contentFrame)
    initBtn.Text = "初始化"
    initBtn.Size = UDim2.new(0, 80, 0, 26)
    initBtn.Position = UDim2.new(0.5, -40, 1, -70)
    initBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    initBtn.TextColor3 = Color3.new(1, 1, 1)
    initBtn.Font = Enum.Font.SourceSansBold
    initBtn.TextSize = 12
    initBtn.BorderSizePixel = 0
    Instance.new("UICorner", initBtn).CornerRadius = UDim.new(0, 5)
    initBtn.MouseButton1Click:Connect(function()
        initTableRef()
        initExtendPart()
    end)

    statusLabel = Instance.new("TextLabel", contentFrame)
    statusLabel.Size = UDim2.new(1, -20, 0, 16)
    statusLabel.Position = UDim2.new(0, 10, 1, -90)
    statusLabel.Font = Enum.Font.SourceSans
    statusLabel.TextSize = 11
    statusLabel.TextColor3 = Color3.new(0.8, 0.8, 0.8)
    statusLabel.BackgroundTransparency = 1
    statusLabel.Text = ""
end

buildUI()

spawn(function()
    local found = false
    while not found do
        if initTableRef() then
            found = true
            initExtendPart()
            showNotification("台球小助手", "检测到游戏开始，已初始化", Color3.fromRGB(96, 205, 255))
        else
            wait(1)
        end
    end
end)

spawn(function()
    while true do
        if tablePart then
            statusLabel.Text = "Rails: " .. #railsList
        else
            statusLabel.Text = "等待球桌..."
        end
        wait(0.5)
    end
end)

RunService.RenderStepped:Connect(updateLine)
