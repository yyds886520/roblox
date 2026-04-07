local function checkServer()
    local swingEvent = game:GetService("ReplicatedStorage"):FindFirstChild("Shared")
    if swingEvent then
        swingEvent = swingEvent:FindFirstChild("Universe")
        if swingEvent then
            swingEvent = swingEvent:FindFirstChild("Network")
            if swingEvent then
                swingEvent = swingEvent:FindFirstChild("RemoteEvent")
                if swingEvent then
                    swingEvent = swingEvent:FindFirstChild("SwingMelee")
                end
            end
        end
    end
    if not swingEvent then
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
        text.Text = "您不在对应的服务器（死铁轨），无法执行此脚本"
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
local players = game:GetService("Players")
local localPlayer = players.LocalPlayer
local camera = workspace.CurrentCamera
local runService = game:GetService("RunService")
local uis = game:GetService("UserInputService")
local workspace = game:GetService("Workspace")

local Window = Fluent:CreateWindow({
    Title = "死铁轨PVP",
    SubTitle = "by.小梦",
    TabWidth = 160,
    Size = UDim2.fromOffset(450, 320),
    Acrylic = false,
    Theme = "Darker",
    MinimizeKey = Enum.KeyCode.LeftControl
})

local infoTab = Window:AddTab({ Title = "当前信息", Icon = "info" })
local basicTab = Window:AddTab({ Title = "基础功能", Icon = "sword" })
local espTab = Window:AddTab({ Title = "ESP 设置", Icon = "eye" })

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

infoTab:AddSection("玩家与服务器信息")
local namePara = infoTab:AddParagraph({ Title = "用户名", Content = localPlayer.Name })
local displayNamePara = infoTab:AddParagraph({ Title = "昵称", Content = localPlayer.DisplayName })
local userIdPara = infoTab:AddParagraph({ Title = "ID", Content = tostring(localPlayer.UserId) })
local accountAgePara = infoTab:AddParagraph({ Title = "账号年龄", Content = localPlayer.AccountAge .. " 天" })
local executorName = "Unknown"
pcall(function() executorName = identifyexecutor() end)
local executorPara = infoTab:AddParagraph({ Title = "注入器", Content = executorName })
local fpsPara = infoTab:AddParagraph({ Title = "FPS", Content = "计算中..." })
local pingPara = infoTab:AddParagraph({ Title = "Ping", Content = "计算中..." })
local playerCountPara = infoTab:AddParagraph({ Title = "服务器玩家数", Content = #players:GetPlayers() .. "/" .. players.MaxPlayers })
local jobIdPara = infoTab:AddParagraph({ Title = "JobId", Content = game.JobId })
local placeIdPara = infoTab:AddParagraph({ Title = "PlaceId", Content = tostring(game.PlaceId) })

task.spawn(function()
    while true do
        fpsPara:SetDesc(string.format("%.1f", workspace:GetRealPhysicsFPS()))
        pingPara:SetDesc(game:GetService("Stats").Network.ServerStatsItem["Data Ping"]:GetValueString())
        playerCountPara:SetDesc(#players:GetPlayers() .. "/" .. players.MaxPlayers)
        task.wait(1)
    end
end)

local swingEvent = game:GetService("ReplicatedStorage"):FindFirstChild("Shared"):FindFirstChild("Universe"):FindFirstChild("Network"):FindFirstChild("RemoteEvent"):FindFirstChild("SwingMelee")
if not swingEvent then warn("未找到 SwingMelee 远程事件") end

local function getCurrentWeapon()
    local char = localPlayer.Character
    if not char then return nil end
    for _, tool in ipairs(char:GetChildren()) do
        if tool:IsA("Tool") and (tool.Name:lower():find("sword") or tool.Name:lower():find("剑")) then
            return tool
        end
    end
    for _, tool in ipairs(char:GetChildren()) do
        if tool:IsA("Tool") then return tool end
    end
    return nil
end

local function getAttackDirection()
    local cam = workspace.CurrentCamera
    local look = cam.CFrame.LookVector
    return Vector3.new(look.X, look.Y - 0.3, look.Z).Unit
end

local function swing()
    if not swingEvent then return end
    local weapon = getCurrentWeapon()
    if not weapon then return end
    local id = tick() * 1000
    local dir = getAttackDirection()
    local args = { weapon, id, dir }
    pcall(function()
        swingEvent:FireServer(unpack(args))
    end)
end

local attackRunning = false
basicTab:AddSection("剑自动攻击")
local attackToggle = basicTab:AddToggle("AutoSwing", {
    Title = "剑无间隔自动攻击",
    Description = "开启后以最快速度无限循环挥剑",
    Default = false
})

local function attackLoop()
    while attackRunning do
        swing()
        task.wait()
    end
end

attackToggle:OnChanged(function(state)
    attackRunning = state
    if state then task.spawn(attackLoop) end
end)

local weaponPara = basicTab:AddParagraph({ Title = "当前武器", Content = "未检测到" })
task.spawn(function()
    while true do
        local weapon = getCurrentWeapon()
        if weapon then weaponPara:SetDesc("武器: " .. weapon.Name)
        else weaponPara:SetDesc("未检测到武器，请手持剑") end
        task.wait(1)
    end
end)

local espData = {}
local espEnabled = false
local showBox = true
local showName = true
local showHealth = true
local showDist = true
local healthMode = "bar"
local useCover = true
local rayOrigin = "both"
local maxDist = 2000

local function getCharInfo(char)
    if not char then return nil, nil, nil end
    local hum = char:FindFirstChildWhichIsA("Humanoid")
    if not hum then return nil, nil, nil end
    local root = char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("Torso") or char:FindFirstChild("UpperTorso")
    if not root then return nil, nil, nil end
    local head = char:FindFirstChild("Head")
    local height = 5
    if head and root then
        height = (head.Position - root.Position).Magnitude * 1.5
    elseif hum then
        height = hum.HipHeight * 2
    end
    return root, hum, height
end

local function isVisibleFromPoint(startPos, targetPos)
    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Blacklist
    params.FilterDescendantsInstances = {localPlayer.Character, camera}
    local res = workspace:Raycast(startPos, (targetPos - startPos), params)
    if not res then return true end
    local hitChar = res.Instance:FindFirstAncestorWhichIsA("Model")
    if hitChar and hitChar:IsA("Model") and hitChar:FindFirstChildWhichIsA("Humanoid") then return true end
    return false
end

local function isVisibleCombined(targetPos)
    local charPos = nil
    local lc = localPlayer.Character
    if lc then
        local r = lc:FindFirstChild("HumanoidRootPart")
        if r then charPos = r.Position end
    end
    local camPos = camera.CFrame.Position
    if rayOrigin == "character" then
        return charPos and isVisibleFromPoint(charPos, targetPos)
    elseif rayOrigin == "camera" then
        return isVisibleFromPoint(camPos, targetPos)
    else
        local a = charPos and isVisibleFromPoint(charPos, targetPos)
        local b = isVisibleFromPoint(camPos, targetPos)
        return a and b
    end
end

local function removePlayerESP(plr)
    if espData[plr] then
        for _, obj in pairs(espData[plr]) do
            if obj and obj.Remove then obj:Remove() end
        end
        espData[plr] = nil
    end
end

local function updatePlayer(plr)
    if plr == localPlayer then return end
    local char = plr.Character
    if not char then removePlayerESP(plr) return end
    local root, hum, height = getCharInfo(char)
    if not root or not hum or hum.Health <= 0 then removePlayerESP(plr) return end
    local visible = true
    if useCover then
        local head = char:FindFirstChild("Head")
        local checkPos = head and head.Position or root.Position
        visible = isVisibleCombined(checkPos)
    end
    local color = visible and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 0, 0)
    local localRoot = localPlayer.Character and localPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not localRoot then return end
    local dist = (root.Position - localRoot.Position).Magnitude
    if dist > maxDist then removePlayerESP(plr) return end
    local screenPos, onScreen = camera:WorldToViewportPoint(root.Position)
    if not onScreen then
        if espData[plr] then
            for _, obj in pairs(espData[plr]) do if obj then obj.Visible = false end end
        end
        return
    end
    local scale = 150 / dist
    local boxH = math.clamp(height * scale, 20, 150)
    local boxW = boxH * 0.6
    local x, y = screenPos.X, screenPos.Y
    local top = y - boxH / 2
    local left = x - boxW / 2
    local data = espData[plr]
    if not data then
        data = {
            box = Drawing.new("Square"),
            name = Drawing.new("Text"),
            health = Drawing.new("Text"),
            distText = Drawing.new("Text")
        }
        data.box.Thickness = 1
        data.box.Filled = false
        data.name.Size = 14
        data.name.Color = Color3.fromRGB(255, 255, 255)
        data.name.Center = true
        data.name.Outline = true
        data.health.Size = 12
        data.health.Color = Color3.fromRGB(0, 255, 0)
        data.health.Center = true
        data.distText.Size = 12
        data.distText.Color = Color3.fromRGB(200, 200, 200)
        data.distText.Center = true
        espData[plr] = data
    end
    if showBox then
        data.box.Visible = true
        data.box.Position = Vector2.new(left, top)
        data.box.Size = Vector2.new(boxW, boxH)
        data.box.Color = color
    else
        data.box.Visible = false
    end
    if showName then
        data.name.Visible = true
        data.name.Position = Vector2.new(x, top - 15)
        data.name.Text = plr.Name
    else
        data.name.Visible = false
    end
    if showHealth then
        data.health.Visible = true
        local percent = hum.Health / hum.MaxHealth
        if healthMode == "bar" then
            local healthColor = percent > 0.6 and Color3.fromRGB(0,255,0) or (percent > 0.3 and Color3.fromRGB(255,255,0) or Color3.fromRGB(255,0,0))
            data.health.Color = healthColor
            data.health.Text = string.format("%.0f%%", percent * 100)
        else
            data.health.Text = string.format("%.0f/%.0f", hum.Health, hum.MaxHealth)
        end
        data.health.Position = Vector2.new(x, top + boxH + 5)
    else
        data.health.Visible = false
    end
    if showDist then
        data.distText.Visible = true
        data.distText.Text = string.format("%.1fm", dist)
        data.distText.Position = Vector2.new(x, top + boxH + 20)
    else
        data.distText.Visible = false
    end
end

local function updateAll()
    if not espEnabled then return end
    for _, p in ipairs(players:GetPlayers()) do updatePlayer(p) end
end

local function clearAll()
    for _, d in pairs(espData) do
        if d.box then d.box:Remove() end
        if d.name then d.name:Remove() end
        if d.health then d.health:Remove() end
        if d.distText then d.distText:Remove() end
    end
    espData = {}
end

players.PlayerRemoving:Connect(removePlayerESP)

local espConn = nil
local function startEspLoop()
    if espConn then espConn:Disconnect() end
    espConn = runService.RenderStepped:Connect(updateAll)
end

espTab:AddSection("显示设置")
local espMainToggle = espTab:AddToggle("MainESP", { Title = "启用玩家 ESP", Default = false })
espMainToggle:OnChanged(function(state)
    espEnabled = state
    if state then
        clearAll()
        startEspLoop()
    else
        if espConn then espConn:Disconnect(); espConn = nil end
        clearAll()
    end
end)

local espBoxToggle = espTab:AddToggle("BoxToggle", { Title = "显示方框", Default = true })
espBoxToggle:OnChanged(function(v) showBox = v end)

local espNameToggle = espTab:AddToggle("NameToggle", { Title = "显示名字", Default = true })
espNameToggle:OnChanged(function(v) showName = v end)

local espHealthToggle = espTab:AddToggle("HealthToggle", { Title = "显示血量", Default = true })
espHealthToggle:OnChanged(function(v) showHealth = v end)

local espHealthMode = espTab:AddDropdown("HealthMode", {
    Title = "血量显示方式",
    Values = { "百分比", "数值" },
    Default = "百分比",
    Callback = function(v) healthMode = (v == "百分比") and "bar" or "text" end
})

local espDistToggle = espTab:AddToggle("DistToggle", { Title = "显示距离", Default = true })
espDistToggle:OnChanged(function(v) showDist = v end)

local espCoverToggle = espTab:AddToggle("CoverToggle", {
    Title = "掩体判断",
    Description = "绿色可见，红色遮挡",
    Default = true
})
espCoverToggle:OnChanged(function(v) useCover = v end)

local espOrigin = espTab:AddDropdown("RayOrigin", {
    Title = "掩体判断起点",
    Values = { "角色位置", "镜头位置", "两者都需要" },
    Default = "两者都需要",
    Callback = function(v)
        if v == "角色位置" then rayOrigin = "character"
        elseif v == "镜头位置" then rayOrigin = "camera"
        else rayOrigin = "both" end
    end
})

local espDistSlider = espTab:AddSlider("MaxDist", {
    Title = "最大显示距离",
    Default = 2000,
    Min = 100,
    Max = 10000,
    Rounding = 0,
    Callback = function(v) maxDist = v end
})

Window.Root.Visible = true
