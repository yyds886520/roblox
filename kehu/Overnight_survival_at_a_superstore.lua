local HttpService = game:GetService("HttpService")
local translationCache = {}

local function detectLanguage(text)
    local cjk = 0
    local en = 0
    for _, code in utf8.codes(text) do
        local char = utf8.char(code)
        if char:match("[\228-\233][\128-\191][\128-\191]") or char:match("[\227][\128-\191][\128-\191]") then
            cjk = cjk + 1
        elseif char:match("[%a]") then
            en = en + 1
        end
    end
    if cjk > 3 then return "zh-CN" end
    return "en"
end

local function translateGoogle(text, fromLang, toLang)
    local url = "https://translate.googleapis.com/translate_a/single?client=gtx&sl=" .. fromLang .. "&tl=" .. toLang .. "&dt=t&q=" .. HttpService:UrlEncode(text)
    local ok, body = pcall(game.HttpGet, game, url)
    if not ok or not body then return nil end
    local ok2, data = pcall(HttpService.JSONDecode, HttpService, body)
    if not ok2 or not data or not data[1] then return nil end
    local result = ""
    for _, part in ipairs(data[1]) do
        if part[1] then result = result .. part[1] end
    end
    return result ~= "" and result or nil
end

local function translateText(text)
    if translationCache[text] then return translationCache[text] end
    local detected = detectLanguage(text)
    if detected == "zh-CN" then
        translationCache[text] = text
        return text
    end
    local translated = translateGoogle(text, detected, "zh-CN")
    if translated then
        translationCache[text] = translated
        return translated
    end
    return text
end

local function loadWindUI()
    local ok, result = pcall(function()
        return loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()
    end)
    if ok and result then return result end
    local ok2, result2 = pcall(function()
        return loadstring(game:HttpGet("https://raw.githubusercontent.com/Footagesus/WindUI/main/dist/main.lua"))()
    end)
    if ok2 and result2 then return result2 end
    return nil
end

local WindUI = loadWindUI()
if not WindUI then print("WindUI加载失败，请检查网络权限") return end

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Lighting = game:GetService("Lighting")
local UserInputService = game:GetService("UserInputService")
local ProximityPromptService = game:GetService("ProximityPromptService")
local player = Players.LocalPlayer

local iconUrl = "https://i.ibb.co/fYdF9KCn/douyin-img-1783071831074.jpg"
local Folder = "超市生存"
local iconFileName = "float_icon.jpg"
local iconPath = "WindUI/" .. Folder .. "/assets/" .. iconFileName

local function ensureIcon()
    if not isfile or not isfolder or not makefolder or not writefile or not getcustomasset then return false end
    if isfile(iconPath) then return true end
    local assetsDir = "WindUI/" .. Folder .. "/assets"
    if not isfolder(assetsDir) then makefolder(assetsDir) end
    local success, data = pcall(game.HttpGet, game, iconUrl)
    if success and data then writefile(iconPath, data) return true end
    return false
end

local iconAsset
if ensureIcon() then iconAsset = getcustomasset(iconPath) else iconAsset = "rbxassetid://10709791437" end

local icons = {"skull","star","heart","crown","shield","wrench","rocket","fire","bolt","moon","sun","globe","terminal","gamepad","dollar-sign","gift","plane","ship","car","bicycle","tree","flower","snowflake","rainbow","flask","atom","satellite","wifi","folder","calendar","clock","alarm","mail","phone","laptop","play","pause","infinity","thumbs-up","pray","yinyang","earth-americas","volcano","campfire","medkit","ambulance","wheelchair","universal-access","bug","lightbulb","coffee"}

local Window = WindUI:CreateWindow({
    Title = "超市生存 Hub V2.0.3",
    Icon = icons[math.random(#icons)],
    Author = "by.小梦",
    Folder = Folder,
    Size = UDim2.fromOffset(540, 460),
    Theme = "Dark",
    SideBarWidth = 170,
    Transparent = true,
    BackgroundImageTransparency = 0.3,
    User = { Enabled = false },
})

WindUI:SetNotificationLower(true)

Window:EditOpenButton({
    Title = "打开/关闭",
    Icon = iconAsset,
    CornerRadius = UDim.new(0, 8),
    StrokeThickness = 2.5,
    Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 0, 0)),
        ColorSequenceKeypoint.new(0.17, Color3.fromRGB(255, 255, 0)),
        ColorSequenceKeypoint.new(0.33, Color3.fromRGB(0, 255, 0)),
        ColorSequenceKeypoint.new(0.5, Color3.fromRGB(0, 255, 255)),
        ColorSequenceKeypoint.new(0.67, Color3.fromRGB(0, 0, 255)),
        ColorSequenceKeypoint.new(0.83, Color3.fromRGB(255, 0, 255)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 0, 0)),
    }),
    Draggable = true,
})

local MainTab = Window:Tab({ Title = "主要", Icon = "shopping-cart" })
local MoveTab = Window:Tab({ Title = "移动", Icon = "running" })
local ESPTab = Window:Tab({ Title = "透视", Icon = "eye" })
local FarmTab = Window:Tab({ Title = "挂机", Icon = "clock" })

local sprintEnabled = false
local sprintSpeed = 50
local staminaConnection, speedConnection

local selectedChinese = "全部"
local itemStatusParagraph = nil

local function createItemListGui()
    local existingGui = player.PlayerGui:FindFirstChild("ItemSelector")
    if existingGui then existingGui:Destroy() end

    local itemListGui = Instance.new("ScreenGui")
    itemListGui.Name = "ItemSelector"
    itemListGui.ResetOnSpawn = false
    itemListGui.Parent = player:WaitForChild("PlayerGui")

    local frame = Instance.new("Frame")
    frame.BackgroundColor3 = Color3.fromRGB(30,30,30)
    frame.BorderSizePixel = 0
    frame.Size = UDim2.new(0, 180, 0, 240)
    frame.Position = UDim2.new(0.5, -90, 0.4, -120)
    frame.Parent = itemListGui

    local scroll = Instance.new("ScrollingFrame")
    scroll.BackgroundTransparency = 1
    scroll.Size = UDim2.new(1, -10, 1, -30)
    scroll.Position = UDim2.new(0, 5, 0, 25)
    scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
    scroll.ScrollBarThickness = 6
    scroll.Parent = frame

    local title = Instance.new("TextLabel")
    title.BackgroundTransparency = 1
    title.Size = UDim2.new(1, 0, 0, 20)
    title.Position = UDim2.new(0, 0, 0, 0)
    title.Text = "选择物品"
    title.TextColor3 = Color3.new(1,1,1)
    title.Font = Enum.Font.GothamBold
    title.TextSize = 14
    title.Parent = frame

    local closeBtn = Instance.new("TextButton")
    closeBtn.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
    closeBtn.Size = UDim2.new(0, 20, 0, 20)
    closeBtn.Position = UDim2.new(1, -20, 0, 0)
    closeBtn.Text = "X"
    closeBtn.TextColor3 = Color3.new(1,1,1)
    closeBtn.TextSize = 12
    closeBtn.Parent = frame
    closeBtn.MouseButton1Click:Connect(function() itemListGui:Destroy() end)

    local yOffset = 0
    local folder = Workspace.Map.Util.Items
    local seen = {}
    table.insert(seen, "全部")
    if folder then
        for _, obj in ipairs(folder:GetDescendants()) do
            if obj:IsA("Tool") then
                local cn = translateText(obj.Name)
                if not table.find(seen, cn) then
                    table.insert(seen, cn)
                end
            end
        end
    end

    for _, name in ipairs(seen) do
        local btn = Instance.new("TextButton")
        btn.BackgroundColor3 = Color3.fromRGB(45,45,45)
        btn.Size = UDim2.new(1, -10, 0, 22)
        btn.Position = UDim2.new(0, 5, 0, yOffset)
        btn.Text = name
        btn.TextColor3 = Color3.new(1,1,1)
        btn.Font = Enum.Font.SourceSans
        btn.TextSize = 14
        btn.Parent = scroll
        btn.MouseButton1Click:Connect(function()
            selectedChinese = name
            itemListGui:Destroy()
            if itemStatusParagraph then
                itemStatusParagraph:SetDesc("当前目标: " .. selectedChinese)
            end
        end)
        yOffset = yOffset + 24
    end
    scroll.CanvasSize = UDim2.new(0, 0, 0, yOffset)
end

MainTab:Section({ Title = "拾取设置" })
itemStatusParagraph = MainTab:Paragraph({
    Title = "当前目标",
    Desc = "当前目标: 全部"
})

MainTab:Button({
    Title = "选择物品",
    Desc = "点击打开物品列表进行选择",
    Callback = function()
        createItemListGui()
    end
})

local maxSlots = 5
local npcSafeDistance = 10

local function getBackpackCount()
    local count = 0
    local backpack = player:FindFirstChild("Backpack")
    if backpack then
        for _, item in ipairs(backpack:GetChildren()) do
            if item:IsA("Tool") then
                count = count + 1
            end
        end
    end
    return count
end

local function isNearNPC(position)
    local enemiesFolder = workspace:FindFirstChild("Enemies")
    if not enemiesFolder then return false end
    for _, npc in ipairs(enemiesFolder:GetChildren()) do
        if npc:IsA("Model") and npc:FindFirstChild("HumanoidRootPart") then
            local dist = (npc.HumanoidRootPart.Position - position).Magnitude
            if dist <= npcSafeDistance then
                return true
            end
        end
    end
    return false
end

MainTab:Toggle({
    Title = "自动拾取",
    Default = false,
    Callback = function(state)
        autoLootEnabled = state
        if state then
            autoLootThread = task.spawn(function()
                local char = player.Character or player.CharacterAdded:Wait()
                local root = char:WaitForChild("HumanoidRootPart")
                local humanoid = char:WaitForChild("Humanoid")
                local RequestPickupItem = ReplicatedStorage.Remotes.RequestPickupItem
                local ItemEquipped = ReplicatedStorage.Remotes.Item.Equipped
                local TARGET_FOLDER = Workspace.Map.Util.Items

                while autoLootEnabled do
                    if getBackpackCount() >= maxSlots then
                        task.wait(1)
                        continue
                    end

                    local targets = {}
                    if TARGET_FOLDER then
                        for _, obj in ipairs(TARGET_FOLDER:GetDescendants()) do
                            if obj:IsA("Tool") and not obj:FindFirstAncestorOfClass("Backpack") then
                                local cn = translateText(obj.Name)
                                if selectedChinese == "全部" or cn == selectedChinese then
                                    local handle = obj:FindFirstChild("Handle")
                                    if handle and not isNearNPC(handle.Position) then
                                        table.insert(targets, obj)
                                    end
                                end
                            end
                        end
                    end

                    for _, tool in ipairs(targets) do
                        if not autoLootEnabled then break end
                        if not tool or tool.Parent ~= TARGET_FOLDER then continue end

                        if char:FindFirstChildWhichIsA("Tool") then
                            humanoid:UnequipTools()
                            task.wait(0.05)
                        end

                        local handle = tool:FindFirstChild("Handle")
                        local targetPos = handle and handle.Position or tool:GetPivot().Position
                        root.CFrame = CFrame.new(targetPos + Vector3.new(0, 2, 2))
                        task.wait(0.05)

                        RequestPickupItem:FireServer(tool)

                        local picked = false
                        local startTime = tick()
                        while tick() - startTime < 2 and autoLootEnabled do
                            if not tool.Parent or tool:FindFirstAncestorOfClass("Backpack") then
                                picked = true
                                break
                            end
                            task.wait(0.05)
                        end

                        if picked then
                            local toolInBag = player.Backpack:FindFirstChild(tool.Name)
                            if toolInBag then ItemEquipped:FireServer(toolInBag) end
                        end
                        task.wait(0.05)
                    end
                    task.wait(0.5)
                end
            end)
        else
            if autoLootThread then task.cancel(autoLootThread) autoLootThread = nil end
        end
    end
})

MainTab:Section({ Title = "角色状态" })

MainTab:Toggle({
    Title = "无限体力",
    Default = false,
    Callback = function(state)
        if state then
            local char = player.Character or player.CharacterAdded:Wait()
            local charData = char:WaitForChild("CharacterData")
            local stamina = charData:WaitForChild("Stamina")
            local maxStamina = charData:WaitForChild("MaxStamina")
            if staminaConnection then staminaConnection:Disconnect() end
            staminaConnection = RunService.Heartbeat:Connect(function()
                stamina.Value = maxStamina.Value
            end)
        else
            if staminaConnection then staminaConnection:Disconnect() end
        end
    end
})

MainTab:Toggle({
    Title = "夜视",
    Default = false,
    Callback = function(v)
        if v then
            Lighting.Ambient = Color3.new(1, 1, 1)
            Lighting.Brightness = 2
            Lighting.FogEnd = 100000
            Lighting.GlobalShadows = false
            for _, effect in ipairs(Lighting:GetDescendants()) do
                if effect:IsA("PostEffect") then effect.Enabled = false end
                if effect:IsA("Atmosphere") then effect:Destroy() end
            end
        else
            Lighting.Ambient = Color3.new(0, 0, 0)
            Lighting.Brightness = 1
            Lighting.FogEnd = 100000
            Lighting.GlobalShadows = true
        end
    end
})

MainTab:Toggle({
    Title = "快速互动",
    Default = false,
    Callback = function(state)
        quickInteractEnabled = state
        if state then
            quickInteractConnection = ProximityPromptService.PromptButtonHoldBegan:Connect(function(prompt)
                prompt.HoldDuration = 0
            end)
        else
            if quickInteractConnection then
                quickInteractConnection:Disconnect()
                quickInteractConnection = nil
            end
        end
    end
})

MoveTab:Toggle({
    Title = "冲刺加速",
    Desc = "你跑不过 你信吗?",
    Default = false,
    Callback = function(state)
        sprintEnabled = state
        if state then
            local char = player.Character or player.CharacterAdded:Wait()
            local charData = char:WaitForChild("CharacterData")
            local sprintingAndMoving = charData:WaitForChild("SprintingAndMoving")
            local humanoid = char:WaitForChild("Humanoid")
            if speedConnection then speedConnection:Disconnect() end
            speedConnection = RunService.RenderStepped:Connect(function()
                if sprintingAndMoving.Value == true then humanoid.WalkSpeed = sprintSpeed end
            end)
        else
            if speedConnection then speedConnection:Disconnect() end
        end
    end
})

MoveTab:Slider({
    Title = "冲刺速度",
    Value = { Min = 20, Max = 200, Default = 50 },
    Callback = function(value) sprintSpeed = value end
})

local noClipEnabled = false
local noClipConnection = nil
MoveTab:Toggle({
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
            if noClipConnection then noClipConnection:Disconnect() noClipConnection = nil end
            local char = player.Character
            if char then
                for _, part in ipairs(char:GetChildren()) do
                    if part:IsA("BasePart") then part.CanCollide = true end
                end
            end
        end
    end
})

local infiniteJumpEnabled = false
local infJumpConnection = nil
MoveTab:Toggle({
    Title = "无限跳",
    Default = false,
    Callback = function(state)
        infiniteJumpEnabled = state
        if state then
            infJumpConnection = UserInputService.JumpRequest:Connect(function()
                if infiniteJumpEnabled then
                    local char = player.Character
                    if char then
                        local humanoid = char:FindFirstChildOfClass("Humanoid")
                        if humanoid then
                            humanoid:ChangeState("Jumping")
                        end
                    end
                end
            end)
        else
            if infJumpConnection then infJumpConnection:Disconnect() infJumpConnection = nil end
        end
    end
})

local flyGui = Instance.new("ScreenGui")
flyGui.Name = "FlyControl"
flyGui.ResetOnSpawn = false
flyGui.Parent = player:WaitForChild("PlayerGui")
flyGui.Enabled = false

local flyFrame = Instance.new("Frame")
flyFrame.Parent = flyGui
flyFrame.BackgroundColor3 = Color3.fromRGB(163, 255, 137)
flyFrame.BorderColor3 = Color3.fromRGB(103, 221, 213)
flyFrame.Position = UDim2.new(0.1, 0, 0.3, 0)
flyFrame.Size = UDim2.new(0, 190, 0, 57)
flyFrame.Active = true
flyFrame.Draggable = true

local function createFlyButton(text, position, size, color)
    local btn = Instance.new("TextButton")
    btn.Parent = flyFrame
    btn.BackgroundColor3 = color or Color3.fromRGB(79, 255, 152)
    btn.Position = position or UDim2.new(0, 0, 0, 0)
    btn.Size = size or UDim2.new(0, 44, 0, 28)
    btn.Font = Enum.Font.SourceSans
    btn.Text = text
    btn.TextColor3 = Color3.new(0, 0, 0)
    btn.TextSize = 14
    return btn
end

local upBtn = createFlyButton("上", UDim2.new(0, 0, 0, 0), UDim2.new(0, 44, 0, 28), Color3.fromRGB(79, 255, 152))
local downBtn = createFlyButton("下", UDim2.new(0, 0, 0.5, 0), UDim2.new(0, 44, 0, 28), Color3.fromRGB(215, 255, 121))
local flyToggleBtn = createFlyButton("飞行", UDim2.new(0.7, 0, 0.5, 0), UDim2.new(0, 56, 0, 28), Color3.fromRGB(255, 249, 74))
local speedLabel = Instance.new("TextLabel")
speedLabel.Parent = flyFrame
speedLabel.BackgroundColor3 = Color3.fromRGB(255, 85, 0)
speedLabel.Position = UDim2.new(0.47, 0, 0.5, 0)
speedLabel.Size = UDim2.new(0, 44, 0, 28)
speedLabel.Font = Enum.Font.SourceSans
speedLabel.Text = "1"
speedLabel.TextColor3 = Color3.new(0, 0, 0)
speedLabel.TextScaled = true
speedLabel.TextSize = 14

local plusBtn = createFlyButton("加速", UDim2.new(0.23, 0, 0, 0), UDim2.new(0, 45, 0, 28), Color3.fromRGB(133, 145, 255))
local minusBtn = createFlyButton("减速", UDim2.new(0.23, 0, 0.5, 0), UDim2.new(0, 45, 0, 29), Color3.fromRGB(123, 255, 247))

local closeBtn = Instance.new("TextButton")
closeBtn.Parent = flyFrame
closeBtn.BackgroundColor3 = Color3.fromRGB(225, 25, 0)
closeBtn.Font = "SourceSans"
closeBtn.Size = UDim2.new(0, 45, 0, 28)
closeBtn.Text = "关闭"
closeBtn.TextSize = 30
closeBtn.Position = UDim2.new(0, 0, -1, 27)

local flyNowe = false
local flySpeeds = 1
local flyTpwalking = false
local flyBodyGyro, flyBodyVelocity, flyHeartbeat

local function stopFly()
    if flyBodyGyro then flyBodyGyro:Destroy() flyBodyGyro = nil end
    if flyBodyVelocity then flyBodyVelocity:Destroy() flyBodyVelocity = nil end
    if flyHeartbeat then flyHeartbeat:Disconnect() flyHeartbeat = nil end
    local char = player.Character
    if char then
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum then
            hum.PlatformStand = false
            hum:SetStateEnabled(Enum.HumanoidStateType.Climbing, true)
            hum:SetStateEnabled(Enum.HumanoidStateType.FallingDown, true)
            hum:SetStateEnabled(Enum.HumanoidStateType.Flying, true)
            hum:SetStateEnabled(Enum.HumanoidStateType.Freefall, true)
            hum:SetStateEnabled(Enum.HumanoidStateType.GettingUp, true)
            hum:SetStateEnabled(Enum.HumanoidStateType.Jumping, true)
            hum:SetStateEnabled(Enum.HumanoidStateType.Landed, true)
            hum:SetStateEnabled(Enum.HumanoidStateType.Physics, true)
            hum:SetStateEnabled(Enum.HumanoidStateType.PlatformStanding, true)
            hum:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, true)
            hum:SetStateEnabled(Enum.HumanoidStateType.Running, true)
            hum:SetStateEnabled(Enum.HumanoidStateType.RunningNoPhysics, true)
            hum:SetStateEnabled(Enum.HumanoidStateType.Seated, true)
            hum:SetStateEnabled(Enum.HumanoidStateType.StrafingNoPhysics, true)
            hum:SetStateEnabled(Enum.HumanoidStateType.Swimming, true)
            char.Animate.Disabled = false
        end
    end
    flyTpwalking = false
    flyNowe = false
end

local function startFly()
    local char = player.Character
    if not char then return end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hum then return end
    flyNowe = true

    for _, state in ipairs({
        Enum.HumanoidStateType.Climbing,
        Enum.HumanoidStateType.FallingDown,
        Enum.HumanoidStateType.Flying,
        Enum.HumanoidStateType.Freefall,
        Enum.HumanoidStateType.GettingUp,
        Enum.HumanoidStateType.Jumping,
        Enum.HumanoidStateType.Landed,
        Enum.HumanoidStateType.Physics,
        Enum.HumanoidStateType.PlatformStanding,
        Enum.HumanoidStateType.Ragdoll,
        Enum.HumanoidStateType.Running,
        Enum.HumanoidStateType.RunningNoPhysics,
        Enum.HumanoidStateType.Seated,
        Enum.HumanoidStateType.StrafingNoPhysics,
        Enum.HumanoidStateType.Swimming,
    }) do
        hum:SetStateEnabled(state, false)
    end
    hum:ChangeState(Enum.HumanoidStateType.Swimming)
    char.Animate.Disabled = true

    flyTpwalking = true
    task.spawn(function()
        while flyTpwalking and char and hum and hum.Parent do
            local dir = hum.MoveDirection
            if dir.Magnitude > 0 then
                char:TranslateBy(dir * flySpeeds)
            end
            task.wait()
        end
    end)

    local rootPart = char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("Torso") or char:FindFirstChild("UpperTorso")
    if rootPart then
        flyBodyGyro = Instance.new("BodyGyro", rootPart)
        flyBodyGyro.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
        flyBodyGyro.P = 9e4
        flyBodyVelocity = Instance.new("BodyVelocity", rootPart)
        flyBodyVelocity.MaxForce = Vector3.new(9e9, 9e9, 9e9)
        flyBodyVelocity.Velocity = Vector3.zero

        hum.PlatformStand = true
        local camera = Workspace.CurrentCamera
        flyHeartbeat = RunService.RenderStepped:Connect(function()
            if not flyNowe or not char or not char.Parent or not hum or hum.Health <= 0 then
                stopFly()
                flyToggleBtn.Text = "飞行"
                return
            end
            if camera and flyBodyGyro and flyBodyVelocity then
                local moveDir = hum.MoveDirection
                local velocity = Vector3.zero
                if moveDir.Magnitude > 0 then
                    velocity = camera.CFrame.LookVector * moveDir.Z + camera.CFrame.RightVector * moveDir.X
                    velocity = velocity * 50
                end
                local upDown = 0
                if UserInputService:IsKeyDown(Enum.KeyCode.Space) then upDown = 50 end
                if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then upDown = -50 end
                velocity = velocity + Vector3.new(0, upDown, 0)
                flyBodyVelocity.Velocity = velocity
                flyBodyGyro.CFrame = camera.CFrame
            end
        end)
    end
end

flyToggleBtn.MouseButton1Down:Connect(function()
    if flyNowe then
        stopFly()
        flyToggleBtn.Text = "飞行"
    else
        startFly()
        flyToggleBtn.Text = "停止"
    end
end)

upBtn.MouseButton1Down:Connect(function()
    local tis
    tis = upBtn.MouseEnter:Connect(function()
        while tis do
            local char = player.Character
            if char then
                local hrp = char:FindFirstChild("HumanoidRootPart")
                if hrp then hrp.CFrame = hrp.CFrame * CFrame.new(0, 1, 0) end
            end
            task.wait()
        end
    end)
    upBtn.MouseLeave:Connect(function()
        if tis then tis:Disconnect() tis = nil end
    end)
end)

downBtn.MouseButton1Down:Connect(function()
    local dis
    dis = downBtn.MouseEnter:Connect(function()
        while dis do
            local char = player.Character
            if char then
                local hrp = char:FindFirstChild("HumanoidRootPart")
                if hrp then hrp.CFrame = hrp.CFrame * CFrame.new(0, -1, 0) end
            end
            task.wait()
        end
    end)
    downBtn.MouseLeave:Connect(function()
        if dis then dis:Disconnect() dis = nil end
    end)
end)

plusBtn.MouseButton1Down:Connect(function()
    flySpeeds = flySpeeds + 1
    speedLabel.Text = flySpeeds
end)

minusBtn.MouseButton1Down:Connect(function()
    if flySpeeds > 1 then
        flySpeeds = flySpeeds - 1
        speedLabel.Text = flySpeeds
    end
end)

closeBtn.MouseButton1Click:Connect(function()
    flyGui.Enabled = false
    stopFly()
    flyToggleBtn.Text = "飞行"
end)

player.CharacterAdded:Connect(function()
    stopFly()
    flyToggleBtn.Text = "飞行"
    flyNowe = false
    flyGui.Enabled = false
end)

MoveTab:Button({
    Title = "飞行",
    Desc = "",
    Callback = function()
        flyGui.Enabled = true
    end
})

player.CharacterAdded:Connect(function()
    task.wait(1)
    local char = player.Character
    if not char then return end
    if staminaConnection then
        staminaConnection:Disconnect()
        local charData = char:WaitForChild("CharacterData")
        local stamina = charData:WaitForChild("Stamina")
        local maxStamina = charData:WaitForChild("MaxStamina")
        staminaConnection = RunService.Heartbeat:Connect(function() stamina.Value = maxStamina.Value end)
    end
    if sprintEnabled then
        if speedConnection then speedConnection:Disconnect() end
        local charData = char:WaitForChild("CharacterData")
        local sprintingAndMoving = charData:WaitForChild("SprintingAndMoving")
        local humanoid = char:WaitForChild("Humanoid")
        speedConnection = RunService.RenderStepped:Connect(function()
            if sprintingAndMoving.Value == true then humanoid.WalkSpeed = sprintSpeed end
        end)
    end
    if infiniteJumpEnabled then
        if infJumpConnection then infJumpConnection:Disconnect() end
        infJumpConnection = UserInputService.JumpRequest:Connect(function()
            if infiniteJumpEnabled then
                local humanoid = char:FindFirstChildOfClass("Humanoid")
                if humanoid then humanoid:ChangeState("Jumping") end
            end
        end)
    end
end)

local npcESPEnabled = false
local npcHighlights = {}
local npcBillboards = {}

local function removeNPCESP(npc)
    if npcHighlights[npc] then npcHighlights[npc]:Destroy() npcHighlights[npc] = nil end
    if npcBillboards[npc] then npcBillboards[npc]:Destroy() npcBillboards[npc] = nil end
end

local function createNPCESP(npc)
    local highlight = Instance.new("Highlight")
    highlight.FillColor = Color3.fromRGB(255, 255, 255)
    highlight.FillTransparency = 0.75
    highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
    highlight.OutlineTransparency = 0.3
    highlight.Adornee = npc
    highlight.Parent = npc
    npcHighlights[npc] = highlight

    local billboard = Instance.new("BillboardGui")
    billboard.Size = UDim2.new(0, 100, 0, 20)
    billboard.StudsOffset = Vector3.new(0, 2.5, 0)
    billboard.AlwaysOnTop = true
    billboard.MaxDistance = 500
    billboard.Adornee = npc:FindFirstChild("HumanoidRootPart") or npc.PrimaryPart or npc
    billboard.Parent = npc

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.TextColor3 = Color3.fromRGB(200, 200, 200)
    label.TextStrokeTransparency = 0.8
    label.Font = Enum.Font.GothamBold
    label.TextSize = 13
    label.Text = "[--.--]"
    label.Parent = billboard
    npcBillboards[npc] = billboard
end

local function updateNPCESP()
    if not npcESPEnabled then return end
    local enemiesFolder = workspace:FindFirstChild("Enemies")
    if not enemiesFolder then return end
    local char = player.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    local playerPos = root and root.Position

    for _, npc in ipairs(enemiesFolder:GetChildren()) do
        if npc:IsA("Model") and npc:FindFirstChild("Humanoid") and npc.Humanoid.Health > 0 then
            if not npcHighlights[npc] then createNPCESP(npc) end
            if playerPos and npcBillboards[npc] then
                local part = npc:FindFirstChild("HumanoidRootPart") or npc.PrimaryPart
                if part then
                    local dist = (part.Position - playerPos).Magnitude
                    local label = npcBillboards[npc]:FindFirstChildWhichIsA("TextLabel")
                    if label then label.Text = string.format("[%.2f]", dist) end
                end
            end
        else
            removeNPCESP(npc)
        end
    end
    for npc, _ in pairs(npcHighlights) do
        if not npc.Parent or npc.Parent ~= enemiesFolder then removeNPCESP(npc) end
    end
end

ESPTab:Toggle({
    Title = "NPC透视",
    Default = false,
    Callback = function(state)
        npcESPEnabled = state
        if state then
            task.spawn(function()
                while npcESPEnabled do updateNPCESP() task.wait(0.3) end
                for npc in pairs(npcHighlights) do removeNPCESP(npc) end
            end)
        else
            for npc in pairs(npcHighlights) do removeNPCESP(npc) end
        end
    end
})

local itemESPEnabled = false
local itemBillboards = {}

local function removeItemESP(tool)
    if itemBillboards[tool] then itemBillboards[tool]:Destroy() itemBillboards[tool] = nil end
end

local function createItemESP(tool)
    local handle = tool:FindFirstChild("Handle")
    if not handle then return end
    local cn = translateText(tool.Name)
    local color = Color3.fromRGB(255, 200, 100)

    local billboard = Instance.new("BillboardGui")
    billboard.Size = UDim2.new(0, 100, 0, 20)
    billboard.StudsOffset = Vector3.new(0, 1.5, 0)
    billboard.AlwaysOnTop = true
    billboard.MaxDistance = 300
    billboard.Adornee = handle
    billboard.Parent = tool

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.Text = cn
    label.TextColor3 = color
    label.TextStrokeTransparency = 0.7
    label.Font = Enum.Font.GothamBold
    label.TextSize = 12
    label.Parent = billboard
    itemBillboards[tool] = billboard
end

local function updateItemESP()
    if not itemESPEnabled then return end
    local folder = Workspace.Map.Util.Items
    if not folder then return end
    local char = player.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    local playerPos = root and root.Position

    for _, obj in ipairs(folder:GetDescendants()) do
        if obj:IsA("Tool") and not obj:FindFirstAncestorOfClass("Backpack") then
            if not itemBillboards[obj] then createItemESP(obj) end
            if playerPos and itemBillboards[obj] then
                local handle = obj:FindFirstChild("Handle")
                if handle then
                    local dist = (handle.Position - playerPos).Magnitude
                    local label = itemBillboards[obj]:FindFirstChildWhichIsA("TextLabel")
                    if label then
                        local cn = translateText(obj.Name)
                        label.Text = cn .. " [" .. string.format("%.2f", dist) .. "]"
                    end
                end
            end
        end
    end
    for tool, _ in pairs(itemBillboards) do
        if not tool.Parent or tool:FindFirstAncestorOfClass("Backpack") then removeItemESP(tool) end
    end
end

ESPTab:Toggle({
    Title = "物品透视",
    Default = false,
    Callback = function(state)
        itemESPEnabled = state
        if state then
            task.spawn(function()
                while itemESPEnabled do updateItemESP() task.wait(0.5) end
                for tool in pairs(itemBillboards) do removeItemESP(tool) end
            end)
        else
            for tool in pairs(itemBillboards) do removeItemESP(tool) end
        end
    end
})

local homePosition = nil
local isAvoiding = false
local busy = false

local function isPlayerNearNPC()
    local char = player.Character
    if not char then return false end
    local root = char:FindFirstChild("HumanoidRootPart")
    if not root then return false end
    local enemiesFolder = workspace:FindFirstChild("Enemies")
    if not enemiesFolder then return false end
    for _, npc in ipairs(enemiesFolder:GetChildren()) do
        if npc:IsA("Model") and npc:FindFirstChild("HumanoidRootPart") then
            local dist = (npc.HumanoidRootPart.Position - root.Position).Magnitude
            if dist <= 10 then return true end
        end
    end
    return false
end

local function getHealthPercent()
    local char = player.Character
    if not char then return nil end
    local hum = char:FindFirstChild("Humanoid")
    if not hum then return nil end
    return (hum.Health / hum.MaxHealth) * 100
end

local function getEnergy()
    local char = player.Character
    if not char then return nil end
    local charData = char:FindFirstChild("CharacterData")
    if not charData then return nil end
    local energy = charData:FindFirstChild("Energy")
    if not energy then return nil end
    return energy.Value
end

local function findSafeFood()
    local folder = Workspace.Map.Util.Items
    if not folder then return nil end
    local best = nil
    local bestDist = math.huge
    local char = player.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    if not root then return nil end

    for _, obj in ipairs(folder:GetDescendants()) do
        if obj:IsA("Tool") and not obj:FindFirstAncestorOfClass("Backpack") then
            local stats = obj:FindFirstChild("ToolStats")
            if stats and (stats:FindFirstChild("HungerRestore") or stats:FindFirstChild("ThirstRestore")) then
                local handle = obj:FindFirstChild("Handle")
                if handle and not isNearNPC(handle.Position) then
                    local dist = (handle.Position - root.Position).Magnitude
                    if dist < bestDist then
                        bestDist = dist
                        best = obj
                    end
                end
            end
        end
    end
    return best
end

local function findSafeMedical()
    local folder = Workspace.Map.Util.Items
    if not folder then return nil end
    local bestMedkit = nil
    local bestBandage = nil
    local bestMedkitDist = math.huge
    local bestBandageDist = math.huge
    local char = player.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    if not root then return nil end

    for _, obj in ipairs(folder:GetDescendants()) do
        if obj:IsA("Tool") and not obj:FindFirstAncestorOfClass("Backpack") then
            local handle = obj:FindFirstChild("Handle")
            if not handle or isNearNPC(handle.Position) then continue end
            local dist = (handle.Position - root.Position).Magnitude
            if obj.Name == "Medkit" and dist < bestMedkitDist then
                bestMedkitDist = dist
                bestMedkit = obj
            elseif obj.Name == "Bandage" and dist < bestBandageDist then
                bestBandageDist = dist
                bestBandage = obj
            end
        end
    end

    if bestMedkit then return bestMedkit end
    if bestBandage then return bestBandage end
    return nil
end

local function findNearestToken()
    local folder = Workspace.Map.Util.Items
    if not folder then return nil end
    local best = nil
    local bestDist = math.huge
    local char = player.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    if not root then return nil end

    for _, obj in ipairs(folder:GetDescendants()) do
        if obj:IsA("Tool") and not obj:FindFirstAncestorOfClass("Backpack") then
            local name = obj.Name
            if name == "Token" or name:find("Token") then
                local handle = obj:FindFirstChild("Handle")
                if handle then
                    local dist = (handle.Position - root.Position).Magnitude
                    if dist < bestDist then
                        bestDist = dist
                        best = obj
                    end
                end
            end
        end
    end
    return best
end

local function pickupItem(target)
    local char = player.Character
    if not char then return false end
    local root = char:FindFirstChild("HumanoidRootPart")
    local humanoid = char:FindFirstChild("Humanoid")
    if not root or not humanoid or humanoid.Health <= 0 then return false end

    if char:FindFirstChildWhichIsA("Tool") then
        humanoid:UnequipTools()
        task.wait(0.05)
    end

    local handle = target:FindFirstChild("Handle")
    local pos = handle and handle.Position or target:GetPivot().Position
    root.CFrame = CFrame.new(pos + Vector3.new(0, 2, 2))
    task.wait(0.05)

    ReplicatedStorage.Remotes.RequestPickupItem:FireServer(target)

    local start = tick()
    while tick() - start < 2 do
        if not target.Parent or target:FindFirstAncestorOfClass("Backpack") then break end
        task.wait(0.05)
    end

    local toolInBag = player.Backpack:FindFirstChild(target.Name)
    if toolInBag then
        ReplicatedStorage.Remotes.Item.Equipped:FireServer(toolInBag)
        return true
    end
    return false
end

local function goHome()
    local char = player.Character
    if not char or not homePosition then return end
    local root = char:FindFirstChild("HumanoidRootPart")
    if root and char:FindFirstChild("Humanoid") and char.Humanoid.Health > 0 then
        root.CFrame = CFrame.new(homePosition)
    end
end

local function waitForRespawn()
    repeat task.wait(1) until player.Character and player.Character:FindFirstChild("HumanoidRootPart")
    task.wait(0.05)
    goHome()
end

local function forceTeleportToSafeZone()
    local char = player.Character
    if not char then return end
    local root = char:FindFirstChild("HumanoidRootPart")
    if root then
        root.CFrame = CFrame.new(371.58, 36.46, -540.39)
    end
end

local function cleanTrash()
    local folder = Workspace.Map.Util.Items
    if not folder then return end
    local keepNames = {"Ham", "Hotdog", "Burger", "Drink"}
    for _, obj in ipairs(folder:GetDescendants()) do
        if obj:IsA("Tool") and not obj:FindFirstAncestorOfClass("Backpack") then
            local keep = false
            for _, kw in ipairs(keepNames) do
                if obj.Name:lower() == kw:lower() then
                    keep = true
                    break
                end
            end
            if not keep then
                pcall(function() obj:Destroy() end)
            end
        end
    end
end

local farmEnabled = false
local farmThread = nil
local farmThreshold = 60

FarmTab:Toggle({
    Title = "自动进食补给",
    Desc = "搭配连点器使用最佳",
    Default = false,
    Callback = function(state)
        farmEnabled = state
        if state then
            homePosition = player.Character and player.Character:FindFirstChild("HumanoidRootPart") and player.Character.HumanoidRootPart.Position or homePosition
            farmThread = task.spawn(function()
                while farmEnabled do
                    if isAvoiding or medicalEnabled or busy then
                        task.wait(0.5)
                        continue
                    end
                    if getBackpackCount() >= maxSlots then
                        goHome()
                        task.wait(0.5)
                        continue
                    end
                    if not player.Character or player.Character.Humanoid.Health <= 0 then
                        waitForRespawn()
                        continue
                    end
                    if isPlayerNearNPC() then
                        task.wait(0.5)
                        continue
                    end
                    local energy = getEnergy()
                    if energy and energy < farmThreshold then
                        local food = findSafeFood()
                        if food then
                            busy = true
                            if pickupItem(food) then
                                if getEnergy() >= farmThreshold then goHome() end
                            end
                            busy = false
                        else
                            WindUI:Notify({ Title = "补给", Content = "无安全食物", Duration = 2 })
                        end
                    else
                        if homePosition then
                            local char = player.Character
                            if char and char:FindFirstChild("HumanoidRootPart") then
                                local currentPos = char.HumanoidRootPart.Position
                                if (currentPos - homePosition).Magnitude > 5 then goHome() end
                            end
                        end
                    end
                    task.wait(0.5)
                end
            end)
        else
            if farmThread then task.cancel(farmThread) farmThread = nil end
            homePosition = nil
        end
    end
})

FarmTab:Slider({
    Title = "能量低于多少开始捡",
    Value = { Min = 0, Max = 100, Default = 60 },
    Callback = function(value) farmThreshold = math.floor(value) end
})

local medicalEnabled = false
local medicalThread = nil
local medThreshold = 90

FarmTab:Toggle({
    Title = "自动医疗补给",
    Desc = "生命低于阈值时自动捡医疗箱/绷带",
    Default = false,
    Callback = function(state)
        medicalEnabled = state
        if state then
            homePosition = player.Character and player.Character:FindFirstChild("HumanoidRootPart") and player.Character.HumanoidRootPart.Position or homePosition
            medicalThread = task.spawn(function()
                while medicalEnabled do
                    if isAvoiding or busy then
                        task.wait(0.5)
                        continue
                    end
                    if getBackpackCount() >= maxSlots then
                        goHome()
                        task.wait(0.5)
                        continue
                    end
                    if not player.Character or player.Character.Humanoid.Health <= 0 then
                        waitForRespawn()
                        continue
                    end
                    if isPlayerNearNPC() then
                        task.wait(0.5)
                        continue
                    end
                    local hpPercent = getHealthPercent()
                    if hpPercent and hpPercent < medThreshold then
                        local medical = findSafeMedical()
                        if medical then
                            busy = true
                            if pickupItem(medical) then
                                local newHp = getHealthPercent()
                                if newHp and newHp >= medThreshold then goHome() end
                            end
                            busy = false
                        end
                    else
                        if homePosition then
                            local char = player.Character
                            if char and char:FindFirstChild("HumanoidRootPart") then
                                local currentPos = char.HumanoidRootPart.Position
                                if (currentPos - homePosition).Magnitude > 5 then goHome() end
                            end
                        end
                    end
                    task.wait(0.5)
                end
            end)
        else
            if medicalThread then task.cancel(medicalThread) medicalThread = nil end
            homePosition = nil
        end
    end
})

FarmTab:Slider({
    Title = "生命低于多少开始捡",
    Value = { Min = 0, Max = 100, Default = 90 },
    Callback = function(value) medThreshold = math.floor(value) end
})

local npcAvoidEnabled = false
local npcAvoidThread = nil

FarmTab:Toggle({
    Title = "NPC回避",
    Desc = "全员10米",
    Default = false,
    Callback = function(state)
        npcAvoidEnabled = state
        if state then
            npcAvoidThread = task.spawn(function()
                while npcAvoidEnabled do
                    if not player.Character or player.Character.Humanoid.Health <= 0 then
                        task.wait(1)
                        continue
                    end
                    if isPlayerNearNPC() then
                        isAvoiding = true
                        forceTeleportToSafeZone()
                        WindUI:Notify({ Title = "NPC回避", Content = "传送至安全区", Duration = 2 })
                        task.wait(3)
                        isAvoiding = false
                    end
                    task.wait(0.3)
                end
            end)
        else
            if npcAvoidThread then task.cancel(npcAvoidThread) npcAvoidThread = nil end
            isAvoiding = false
        end
    end
})

local tokenPurpleEnabled = false
local tokenThread = nil

FarmTab:Toggle({
    Title = "自动拾取令牌",
    Desc = "检测到令牌时传送拾取并回家",
    Default = false,
    Callback = function(state)
        tokenPurpleEnabled = state
        if state then
            homePosition = player.Character and player.Character:FindFirstChild("HumanoidRootPart") and player.Character.HumanoidRootPart.Position or homePosition
            tokenThread = task.spawn(function()
                while tokenPurpleEnabled do
                    if isAvoiding then
                        task.wait(0.5)
                        continue
                    end
                    if not player.Character or player.Character.Humanoid.Health <= 0 then
                        waitForRespawn()
                        continue
                    end
                    if isPlayerNearNPC() then
                        task.wait(0.5)
                        continue
                    end
                    local token = findNearestToken()
                    if token then
                        busy = true
                        pickupItem(token)
                        task.wait(0.5)
                        goHome()
                        busy = false
                    end
                    task.wait(0.5)
                end
            end)
        else
            if tokenThread then task.cancel(tokenThread) tokenThread = nil end
            homePosition = nil
        end
    end
})

local cleanEnabled = false
local cleanThread = nil

FarmTab:Toggle({
    Title = "定时清理",
    Desc = "每5秒清除无用物品（只留火腿/热狗/汉堡/饮料）",
    Default = false,
    Callback = function(state)
        cleanEnabled = state
        if state then
            cleanThread = task.spawn(function()
                while cleanEnabled do
                    cleanTrash()
                    task.wait(5)
                end
            end)
        else
            if cleanThread then
                task.cancel(cleanThread)
                cleanThread = nil
            end
        end
    end
})

Window:SelectTab(1)
