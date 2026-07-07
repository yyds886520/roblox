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

local expandedHeight = 270
local collapsedHeight = 38
local frameWidth = 240

local shadow = Instance.new("Frame")
shadow.Size = UDim2.new(0, frameWidth, 0, expandedHeight)
shadow.Position = UDim2.new(0, 100, 0, 52)
shadow.BackgroundColor3 = Color3.new(0, 0, 0)
shadow.BackgroundTransparency = 0.7
shadow.BorderSizePixel = 0
shadow.Parent = screenGui

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, frameWidth, 0, expandedHeight)
mainFrame.Position = UDim2.new(0, 100, 0, 50)
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
titleText.Text = "奔跑🧠红"
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

local autoRunEnabled = false
local autoRunHeartbeat, childRemovedCon, charAddedCon
local lastEquipTime = 0
local equipCooldown = 1.0

local function fireConnections(obj)
    if not obj then return end
    for _, conn in ipairs(getconnections(obj.Activated)) do pcall(conn.Function) end
    for _, conn in ipairs(getconnections(obj.MouseButton1Click)) do pcall(conn.Function) end
end

local function isHoldingTreadmill()
    local char = player.Character
    if not char then return false end
    local humanoid = char:FindFirstChild("Humanoid")
    if not humanoid then return false end
    local tool = humanoid:FindFirstChildOfClass("Tool")
    return tool and tool.Name == "Treadmill"
end

local function getTreadmillTool()
    local char = player.Character
    if not char then return nil end
    local tool = char:FindFirstChild("Treadmill")
    if tool and tool:IsA("Tool") then return tool end
    return player.Backpack:FindFirstChild("Treadmill")
end

local function equipTreadmill()
    if isHoldingTreadmill() then return end
    local now = os.clock()
    if now - lastEquipTime < equipCooldown then return end
    lastEquipTime = now
    local tool = getTreadmillTool()
    if not tool then return end
    local char = player.Character
    if not char then return end
    local humanoid = char:FindFirstChild("Humanoid")
    if not humanoid then return end
    pcall(function() humanoid:EquipTool(tool) end)
end

local function setupCharacterListeners(char)
    if childRemovedCon then childRemovedCon:Disconnect() end
    childRemovedCon = char.ChildRemoved:Connect(function(child)
        if not autoRunEnabled then return end
        if child:IsA("Tool") and child.Name == "Treadmill" then
            equipTreadmill()
        end
    end)
end

local function startAutoRun()
    equipTreadmill()
    charAddedCon = player.CharacterAdded:Connect(function(char)
        setupCharacterListeners(char)
        task.wait(0.5)
        if autoRunEnabled then equipTreadmill() end
    end)
    if player.Character then setupCharacterListeners(player.Character) end
    autoRunHeartbeat = runService.Heartbeat:Connect(function()
        if not autoRunEnabled then return end
        local qteIcon = playerGui:FindFirstChild("TreadmillQTE_Icon")
        if qteIcon then
            local frame = qteIcon:FindFirstChild("Frame")
            if frame then
                local btn = frame:FindFirstChild("ImageButton")
                if btn and btn.Visible then fireConnections(btn) end
            end
        end
        local char = player.Character
        if char then
            local humanoid = char:FindFirstChild("Humanoid")
            if humanoid then
                humanoid.WalkSpeed = 32
                humanoid.JumpPower = 50
            end
        end
    end)
end

local function stopAutoRun()
    if childRemovedCon then childRemovedCon:Disconnect(); childRemovedCon = nil end
    if charAddedCon then charAddedCon:Disconnect(); charAddedCon = nil end
    if autoRunHeartbeat then autoRunHeartbeat:Disconnect(); autoRunHeartbeat = nil end
    local char = player.Character
    if char then
        local humanoid = char:FindFirstChild("Humanoid")
        if humanoid then pcall(function() humanoid:UnequipTools() end) end
    end
end

local autoAttributeEnabled = false
local autoAttributeHeartbeat
local lastClickedBtn = nil
local lastClickTime = 0

local function startAutoAttribute()
    autoAttributeHeartbeat = runService.Heartbeat:Connect(function()
        if not autoAttributeEnabled then return end
        
        local bifrost = playerGui:FindFirstChild("BifrostImageQTE")
        if bifrost then
            for _, child in ipairs(bifrost:GetChildren()) do
                if child:IsA("Frame") or child:IsA("ImageLabel") then
                    local btn = child:FindFirstChild("ImageButton")
                    if btn and btn.Visible then
                        local btnPath = btn:GetFullName()
                        local now = os.clock()
                        if btnPath ~= lastClickedBtn or (now - lastClickTime > 0.3) then
                            lastClickedBtn = btnPath
                            lastClickTime = now
                            fireConnections(btn)
                        end
                    end
                end
            end
        end
        
        local staminaBtn = playerGui:FindFirstChild("BifrostImageQTE") and playerGui.BifrostImageQTE:FindFirstChild("StaminaBoost")
        if staminaBtn then
            local btn = staminaBtn:FindFirstChild("ImageButton")
            if btn and btn.Visible then
                local btnPath = btn:GetFullName()
                local now = os.clock()
                if btnPath ~= lastClickedBtn or (now - lastClickTime > 0.3) then
                    lastClickedBtn = btnPath
                    lastClickTime = now
                    fireConnections(btn)
                end
            end
        end
        
        local promptBtn = playerGui:FindFirstChild("ProximityPrompts") and playerGui.ProximityPrompts:FindFirstChild("Prompt")
        if promptBtn then
            local btn = promptBtn:FindFirstChild("TextButton")
            if btn and btn.Visible then
                local btnPath = btn:GetFullName()
                local now = os.clock()
                if btnPath ~= lastClickedBtn or (now - lastClickTime > 0.05) then
                    lastClickedBtn = btnPath
                    lastClickTime = now
                    fireConnections(btn)
                end
            end
        end
    end)
end

local function stopAutoAttribute()
    if autoAttributeHeartbeat then
        autoAttributeHeartbeat:Disconnect()
        autoAttributeHeartbeat = nil
    end
    lastClickedBtn = nil
    lastClickTime = 0
end

local function getMyHomeRoot()
    local myName = player.Name
    local myDisplayName = player.DisplayName
    
    local plotsFolder = workspace:FindFirstChild("Plots")
    if not plotsFolder then return nil end
    
    for _, basePart in ipairs(plotsFolder:GetChildren()) do
        local attPlayer = basePart:FindFirstChild("Att_Player")
        if attPlayer then
            local billboard = attPlayer:FindFirstChild("Billboard")
            if billboard and billboard:IsA("BillboardGui") then
                for _, child in ipairs(billboard:GetDescendants()) do
                    if child:IsA("TextLabel") then
                        local text = child.Text
                        if text == myName or text == myDisplayName then
                            return basePart
                        end
                    end
                end
            end
        end
    end
    return nil
end

local collectCashEnabled = false
local collectCashHeartbeat

local function collectMyCash()
    local char = player.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return end
    local root = char.HumanoidRootPart
    
    local homeRoot = getMyHomeRoot()
    if not homeRoot then return end
    
    for _, obj in ipairs(homeRoot:GetDescendants()) do
        if obj:IsA("BasePart") and obj.Name == "StandClaimHitbox" then
            local hasTouch = false
            for _, child in ipairs(obj:GetChildren()) do
                if child:IsA("TouchTransmitter") then
                    hasTouch = true
                    break
                end
            end
            if hasTouch then
                pcall(function()
                    firetouchinterest(root, obj, 0)
                    firetouchinterest(root, obj, 1)
                end)
            end
        end
    end
end

local function startCollectCash()
    collectCashHeartbeat = runService.Heartbeat:Connect(function()
        if not collectCashEnabled then return end
        collectMyCash()
    end)
end

local function stopCollectCash()
    if collectCashHeartbeat then
        collectCashHeartbeat:Disconnect()
        collectCashHeartbeat = nil
    end
end

local antiAFKEnabled = false
local antiAFKThread = nil

local function antiAFKMove()
    local P = player
    local C = P.Character or P.CharacterAdded:Wait()
    local H = C:FindFirstChildOfClass("Humanoid")
    local R = C:FindFirstChild("HumanoidRootPart")
    if H and R and H.Health > 0 then
        H:MoveTo(R.Position + Vector3.new(math.random(-10,10), 0, math.random(-10,10)))
    end
end

local function startAntiAFK()
    if antiAFKThread then return end
    local char = player.Character
    if char then
        local root = char:FindFirstChild("HumanoidRootPart")
        if root then
            root.CFrame = CFrame.new(7.91, 3.00, -14801.50)
        end
    end
    antiAFKThread = coroutine.create(function()
        while antiAFKEnabled do
            antiAFKMove()
            wait(10)
        end
    end)
    coroutine.resume(antiAFKThread)
end

local function stopAntiAFK()
    antiAFKEnabled = false
    if antiAFKThread then
        antiAFKThread = nil
    end
end

addToggleRow(0, "跑步机自动x2", function(state)
    autoRunEnabled = state
    if state then startAutoRun() else stopAutoRun() end
end)

addToggleRow(32, "自动点击属性", function(state)
    autoAttributeEnabled = state
    if state then startAutoAttribute() else stopAutoAttribute() end
end)

addToggleRow(64, "收集现金", function(state)
    collectCashEnabled = state
    if state then startCollectCash() else stopCollectCash() end
end)

addToggleRow(96, "防挂机", function(state)
    antiAFKEnabled = state
    if state then
        startAntiAFK()
    else
        stopAntiAFK()
    end
end)

local tipRow = Instance.new("Frame")
tipRow.Size = UDim2.new(1, -2 * paddingLeft, 0, 20)
tipRow.Position = UDim2.new(0, paddingLeft, 0, 128)
tipRow.BackgroundTransparency = 1
tipRow.BorderSizePixel = 0
tipRow.Parent = contentFrame

local tipLabel = Instance.new("TextLabel")
tipLabel.Size = UDim2.new(1, 0, 1, 0)
tipLabel.BackgroundTransparency = 1
tipLabel.Text = "💡 搭配自动连点器使用，防挂机效果更佳"
tipLabel.TextColor3 = Color3.fromRGB(180, 180, 180)
tipLabel.Font = Enum.Font.Gotham
tipLabel.TextSize = 12
tipLabel.TextXAlignment = Enum.TextXAlignment.Left
tipLabel.TextYAlignment = Enum.TextYAlignment.Center
tipLabel.Parent = tipRow

local authorRow = Instance.new("Frame")
authorRow.Size = UDim2.new(1, -2 * paddingLeft, 0, 32)
authorRow.Position = UDim2.new(0, paddingLeft, 0, 152)
authorRow.BackgroundTransparency = 1
authorRow.BorderSizePixel = 0
authorRow.Parent = contentFrame

local authorLabel = Instance.new("TextLabel")
authorLabel.Size = UDim2.new(1, 0, 1, 0)
authorLabel.BackgroundTransparency = 1
authorLabel.Text = "作者 by小梦"
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
