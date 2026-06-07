local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
local SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/SaveManager.lua"))()
local InterfaceManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/InterfaceManager.lua"))()

local Window = Fluent:CreateWindow({
    Title = "哥斯拉皮套Hub - 第二夜",
    SubTitle = "by.小梦",
    TabWidth = 160,
    Size = UDim2.fromOffset(580, 360),
    Acrylic = false,
    Theme = "Darker",
    MinimizeKey = Enum.KeyCode.LeftControl
})

Window.Root.Visible = true

local Tabs = {
    Main = Window:AddTab({ Title = "主要", Icon = "box" }),
    Auto = Window:AddTab({ Title = "自动", Icon = "bot" }),
    ESP = Window:AddTab({ Title = "透视", Icon = "eye" }),
    Teleport = Window:AddTab({ Title = "传送", Icon = "map-pin" }),
    Other = Window:AddTab({ Title = "其他", Icon = "settings" })
}

do
    local CUSTOM_IMAGE = "rbxassetid://10709791437"
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "FluentFloatButton"
    screenGui.ResetOnSpawn = false
    screenGui.Parent = game:GetService("CoreGui")
    screenGui.Enabled = true

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

    Instance.new("UICorner", button).CornerRadius = UDim.new(1, 0)
    local stroke = Instance.new("UIStroke", button)
    stroke.Thickness = 1
    stroke.Color = Color3.fromRGB(100, 100, 100)
    stroke.Transparency = 0.5

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
        if Window.Root then Window.Root.Visible = not Window.Root.Visible end
    end)

    button.MouseEnter:Connect(function()
        button:TweenSize(UDim2.fromOffset(55, 55), Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0.2, true)
    end)
    button.MouseLeave:Connect(function()
        button:TweenSize(UDim2.fromOffset(50, 50), Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0.2, true)
    end)
end

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local player = Players.LocalPlayer

local safeZonePosition = Vector3.new(-171.49, -451.59, -153.56)
local generatorRoomPosition = Vector3.new(-12.83, -9.90, -143.77)
local spawnPosition = Vector3.new(-6.98, -9.84, -0.95)
local buildPosition = Vector3.new(60.25, -9.88, -94.91)
local ironDoorPosition = Vector3.new(23.12, -9.90, 11.75)

local monsterEspEnabled = false
local monsterHighlights = {}
local screenDistanceLabel

local monsterNames = {
    ["ai"] = "哥斯拉",
    ["ai_anguirus"] = "安吉拉斯",
    ["ai_anguirus2"] = "安吉拉斯2",
    ["ai_cybot"] = "机械哥斯拉"
}

local function getMonsterDisplayName(actualName)
    local key = actualName:lower()
    return monsterNames[key] or actualName
end

local function createScreenGui()
    if screenDistanceLabel then return end
    local gui = Instance.new("ScreenGui")
    gui.Name = "MonsterDistances"
    gui.ResetOnSpawn = false
    gui.Parent = game:GetService("CoreGui")

    screenDistanceLabel = Instance.new("TextLabel")
    screenDistanceLabel.Size = UDim2.fromScale(1, 0)
    screenDistanceLabel.Position = UDim2.fromScale(0.5, 0.92)
    screenDistanceLabel.AnchorPoint = Vector2.new(0.5, 0)
    screenDistanceLabel.BackgroundTransparency = 1
    screenDistanceLabel.TextColor3 = Color3.fromRGB(255, 80, 80)
    screenDistanceLabel.TextStrokeTransparency = 0.5
    screenDistanceLabel.Font = Enum.Font.SourceSansBold
    screenDistanceLabel.TextSize = 14
    screenDistanceLabel.Text = ""
    screenDistanceLabel.Parent = gui
end

local function destroyScreenGui()
    if screenDistanceLabel then
        screenDistanceLabel.Parent:Destroy()
        screenDistanceLabel = nil
    end
end

local function updateScreenDistances(distances)
    if not screenDistanceLabel then return end
    local parts = {}
    for name, dist in pairs(distances) do
        table.insert(parts, name .. ": " .. string.format("%.1f米", dist))
    end
    if #parts == 0 then
        screenDistanceLabel.Text = "无怪物"
    else
        table.sort(parts)
        screenDistanceLabel.Text = table.concat(parts, "  |  ")
    end
end

local function createMonsterHighlight(model)
    if monsterHighlights[model] then return end
    local highlight = Instance.new("Highlight")
    highlight.Name = "MonsterOutline"
    highlight.FillTransparency = 1
    highlight.OutlineTransparency = 0
    highlight.OutlineColor = Color3.fromRGB(255, 0, 0)
    highlight.Parent = model
    monsterHighlights[model] = highlight
end

local function removeMonsterHighlight(model)
    if monsterHighlights[model] then
        monsterHighlights[model]:Destroy()
        monsterHighlights[model] = nil
    end
end

local function updateMonsterESP()
    task.spawn(function()
        while monsterEspEnabled do
            local char = player.Character
            local root = char and char:FindFirstChild("HumanoidRootPart")
            local kitFolder = workspace:FindFirstChild("kit")
            local distances = {}

            if kitFolder then
                for _, model in ipairs(kitFolder:GetChildren()) do
                    if model:IsA("Model") then
                        local lowerName = model.Name:lower()
                        if monsterNames[lowerName] then
                            local hum = model:FindFirstChild("Humanoid")
                            local hrp = model:FindFirstChild("HumanoidRootPart")
                            if hum and hum.Health > 0 and hrp then
                                local displayName = getMonsterDisplayName(model.Name)
                                if not monsterHighlights[model] then
                                    createMonsterHighlight(model)
                                end
                                if root then
                                    local dist = (hrp.Position - root.Position).Magnitude
                                    if not distances[displayName] or dist < distances[displayName] then
                                        distances[displayName] = dist
                                    end
                                end
                            end
                        end
                    end
                end
            end

            updateScreenDistances(distances)

            for model, _ in pairs(monsterHighlights) do
                local hum = model:FindFirstChild("Humanoid")
                if not hum or hum.Health <= 0 or not model:FindFirstChild("HumanoidRootPart") or not model.Parent then
                    removeMonsterHighlight(model)
                end
            end

            task.wait(0.5)
        end
    end)
end

local function clearMonsterESP()
    for model, _ in pairs(monsterHighlights) do
        removeMonsterHighlight(model)
    end
    monsterHighlights = {}
    destroyScreenGui()
end

local keyEspEnabled = false
local keyBillboards = {}

local function updateKeyESP()
    task.spawn(function()
        while keyEspEnabled do
            local char = player.Character
            local root = char and char:FindFirstChild("HumanoidRootPart")
            local keyPart = workspace:FindFirstChild("Basement")
                and workspace.Basement:FindFirstChild("Fence")
                and workspace.Basement.Fence:FindFirstChild("Keys")
                and workspace.Basement.Fence.Keys:FindFirstChild("Key")
            
            if keyPart and keyPart:IsA("BasePart") then
                if not keyBillboards[keyPart] then
                    local billboard = Instance.new("BillboardGui")
                    billboard.Name = "KeyESP"
                    billboard.Adornee = keyPart
                    billboard.Size = UDim2.new(0, 200, 0, 40)
                    billboard.StudsOffset = Vector3.new(0, 2, 0)
                    billboard.AlwaysOnTop = true
                    billboard.MaxDistance = 500
                    billboard.Parent = keyPart
                    local label = Instance.new("TextLabel")
                    label.Size = UDim2.fromScale(1, 1)
                    label.BackgroundTransparency = 1
                    label.TextColor3 = Color3.fromRGB(0, 255, 255)
                    label.TextStrokeTransparency = 0
                    label.Font = Enum.Font.SourceSansBold
                    label.TextSize = 14
                    label.Parent = billboard
                    keyBillboards[keyPart] = billboard
                end
                local billboard = keyBillboards[keyPart]
                if billboard and root then
                    local label = billboard:FindFirstChildWhichIsA("TextLabel")
                    if label then
                        local dist = (keyPart.Position - root.Position).Magnitude
                        label.Text = "地下室钥匙\n[" .. string.format("%.1f", dist) .. "米]"
                    end
                end
            end

            for part, billboard in pairs(keyBillboards) do
                if not part.Parent then
                    billboard:Destroy()
                    keyBillboards[part] = nil
                end
            end

            task.wait(0.5)
        end
    end)
end

local function clearKeyESP()
    for part, billboard in pairs(keyBillboards) do
        billboard:Destroy()
    end
    keyBillboards = {}
end

local partsEspEnabled = false
local partsBillboards = {}

local partPaths = {
    {path = {"CybotParts", "Heads", "Head"}, name = "头部"},
    {path = {"CybotParts", "Torsos", "Torso"}, name = "躯干"},
    {path = {"CybotParts", "LegLs", "LegL"}, name = "左腿"},
    {path = {"CybotParts", "LegRs", "LegR"}, name = "右腿"},
    {path = {"CybotParts", "Waists", "Waist"}, name = "腰部"},
}

local function getPartByPath(pathTable)
    local container = workspace
    for _, folderName in ipairs(pathTable) do
        container = container:FindFirstChild(folderName)
        if not container then return nil end
    end
    if container:IsA("BasePart") then return container end
    return nil
end

local function removePartLabel(part)
    if partsBillboards[part] then
        partsBillboards[part]:Destroy()
        partsBillboards[part] = nil
    end
end

local function updatePartsESP()
    for _, partData in ipairs(partPaths) do
        local part = getPartByPath(partData.path)
        if part and not part:GetAttribute("_esp_watched") then
            part:SetAttribute("_esp_watched", true)
            part:GetPropertyChangedSignal("Parent"):Connect(function()
                local currentPart = getPartByPath(partData.path)
                if not currentPart or currentPart ~= part then
                    removePartLabel(part)
                end
            end)
        end
    end

    task.spawn(function()
        while partsEspEnabled do
            local char = player.Character
            local root = char and char:FindFirstChild("HumanoidRootPart")
            
            for _, partData in ipairs(partPaths) do
                local part = getPartByPath(partData.path)
                if part and part:IsA("BasePart") then
                    if not partsBillboards[part] then
                        local billboard = Instance.new("BillboardGui")
                        billboard.Name = "PartESP"
                        billboard.Adornee = part
                        billboard.Size = UDim2.new(0, 200, 0, 40)
                        billboard.StudsOffset = Vector3.new(0, 2, 0)
                        billboard.AlwaysOnTop = true
                        billboard.MaxDistance = 500
                        billboard.Parent = part
                        local label = Instance.new("TextLabel")
                        label.Size = UDim2.fromScale(1, 1)
                        label.BackgroundTransparency = 1
                        label.TextColor3 = Color3.fromRGB(255, 255, 0)
                        label.TextStrokeTransparency = 0
                        label.Font = Enum.Font.SourceSansBold
                        label.TextSize = 14
                        label.Parent = billboard
                        partsBillboards[part] = billboard
                    end
                    local billboard = partsBillboards[part]
                    if billboard and root then
                        local label = billboard:FindFirstChildWhichIsA("TextLabel")
                        if label then
                            local dist = (part.Position - root.Position).Magnitude
                            label.Text = partData.name .. "\n[" .. string.format("%.1f", dist) .. "米]"
                        end
                    end
                else
                    for trackedPart, _ in pairs(partsBillboards) do
                        if getPartByPath(partData.path) ~= trackedPart then
                            removePartLabel(trackedPart)
                        end
                    end
                end
            end

            task.wait(0.5)
        end
    end)
end

local function clearPartsESP()
    for part, billboard in pairs(partsBillboards) do
        billboard:Destroy()
    end
    partsBillboards = {}
end

local function autoInteract(part)
    local prompt = part:FindFirstChildWhichIsA("ProximityPrompt")
    if prompt then
        pcall(function() prompt.HoldDuration = 0 end)
        task.wait(0.2)
        pcall(function() prompt:InputHoldBegin() end)
        task.wait(0.05)
        pcall(function() prompt:InputHoldEnd() end)
        return true
    else
        local clickDetector = part:FindFirstChildWhichIsA("ClickDetector")
        if clickDetector then
            pcall(function() fireclickdetector(clickDetector) end)
            return true
        end
    end
    return false
end

local function findPromptNearPosition(position, range)
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("ProximityPrompt") then
            local parent = obj.Parent
            if parent and parent:IsA("BasePart") and (parent.Position - position).Magnitude < range then
                return obj
            end
        end
    end
    return nil
end

local function findBuildPrompt()
    return findPromptNearPosition(buildPosition, 20)
end

local function findDoorPrompt()
    local padlock = workspace:FindFirstChild("Basement")
        and workspace.Basement:FindFirstChild("Fence")
        and workspace.Basement.Fence:FindFirstChild("PadLock")
    if padlock then
        for _, obj in ipairs(padlock:GetDescendants()) do
            if obj:IsA("ProximityPrompt") then
                return obj
            end
        end
    end
    return findPromptNearPosition(ironDoorPosition, 5)
end

Tabs.Auto:AddButton({
    Title = "一键拼装哥斯拉",
    Description = "此功能全自动 请不要进行任何操作",
    Callback = function()
        local char = player.Character
        if not char or not char:FindFirstChild("HumanoidRootPart") then
            Fluent:Notify({ Title = "失败", Content = "角色未加载", Duration = 2 })
            return
        end
        local root = char.HumanoidRootPart
        local camera = workspace.CurrentCamera

        local parts = {
            {path = {"CybotParts", "Heads", "Head"}, name = "头部"},
            {path = {"CybotParts", "Torsos", "Torso"}, name = "躯干"},
            {path = {"CybotParts", "LegLs", "LegL"}, name = "左腿"},
            {path = {"CybotParts", "LegRs", "LegR"}, name = "右腿"},
            {path = {"CybotParts", "Waists", "Waist"}, name = "腰部"},
        }

        for _, partData in ipairs(parts) do
            local part = getPartByPath(partData.path)
            if not part then
                Fluent:Notify({ Title = "跳过", Content = partData.name .. " 不存在", Duration = 1 })
                continue
            end

            root.CFrame = CFrame.new(part.Position + Vector3.new(0, 3, 0))
            Fluent:Notify({ Title = "拾取中", Content = "正在获取 " .. partData.name, Duration = 1 })
            task.wait(0.5)

            local oldCameraType = camera.CameraType
            camera.CameraType = Enum.CameraType.Scriptable
            local cameraLockThread = task.spawn(function()
                while part and part.Parent do
                    if root then
                        camera.CFrame = CFrame.new(root.Position + Vector3.new(0, 1.5, 0), part.Position)
                    end
                    task.wait()
                end
            end)

            autoInteract(part)
            task.wait(0.3)

            if cameraLockThread then task.cancel(cameraLockThread) end
            camera.CameraType = oldCameraType
            removePartLabel(part)
        end

        Fluent:Notify({ Title = "完成", Content = "所有零件已拾取，正在传送到拼接点", Duration = 2 })
        task.wait(0.5)

        root.CFrame = CFrame.new(buildPosition + Vector3.new(0, 3, 0))
        Fluent:Notify({ Title = "拼接", Content = "正在等待拼接台加载...", Duration = 2 })
        task.wait(2)

        local buildPrompt = findBuildPrompt()
        if not buildPrompt then
            Fluent:Notify({ Title = "警告", Content = "未找到拼接按钮，请手动互动", Duration = 3 })
        else
            local oldCameraType = camera.CameraType
            camera.CameraType = Enum.CameraType.Scriptable

            local warmupPrompt = findBuildPrompt()
            if warmupPrompt then
                local warmTarget = warmupPrompt.Parent
                local warmLock = task.spawn(function()
                    while warmTarget and warmTarget.Parent do
                        if root then
                            camera.CFrame = CFrame.new(root.Position + Vector3.new(0, 1.5, 0), warmTarget.Position)
                        end
                        task.wait()
                    end
                end)
                warmupPrompt.HoldDuration = 0.5
                pcall(function() warmupPrompt:InputHoldBegin() end)
                task.wait(0.6)
                pcall(function() warmupPrompt:InputHoldEnd() end)
                task.wait(0.5)
                if warmLock then task.cancel(warmLock) end
            end

            for i = 1, 5 do
                Fluent:Notify({ Title = "拼接", Content = "正在安装第 " .. i .. " 个零件...", Duration = 1 })
                local currentPrompt = findBuildPrompt()
                if not currentPrompt then
                    task.wait(0.5)
                    currentPrompt = findBuildPrompt()
                end
                if currentPrompt then
                    local targetPart = currentPrompt.Parent
                    local lockThread = task.spawn(function()
                        while targetPart and targetPart.Parent do
                            if root then
                                camera.CFrame = CFrame.new(root.Position + Vector3.new(0, 1.5, 0), targetPart.Position)
                            end
                            task.wait()
                        end
                    end)

                    currentPrompt.HoldDuration = 1
                    pcall(function() currentPrompt:InputHoldBegin() end)
                    task.wait(1.2)
                    pcall(function() currentPrompt:InputHoldEnd() end)
                    task.wait(1.5)

                    if lockThread then task.cancel(lockThread) end
                else
                    Fluent:Notify({ Title = "出错", Content = "找不到拼接按钮，请手动完成", Duration = 3 })
                    break
                end
            end

            camera.CameraType = oldCameraType
        end

        Fluent:Notify({ Title = "完成", Content = "拼接完毕，立即传回出生点！", Duration = 2 })
        task.wait(0.5)
        root.CFrame = CFrame.new(spawnPosition + Vector3.new(0, 3, 0))
    end
})

Tabs.Auto:AddButton({
    Title = "自动使用钥匙开门",
    Description = "此功能全自动 请不要进行任何操作",
    Callback = function()
        local char = player.Character
        if not char or not char:FindFirstChild("HumanoidRootPart") then
            Fluent:Notify({ Title = "失败", Content = "角色未加载", Duration = 2 })
            return
        end
        local root = char.HumanoidRootPart
        local camera = workspace.CurrentCamera

        local keyPart = workspace:FindFirstChild("Basement")
            and workspace.Basement:FindFirstChild("Fence")
            and workspace.Basement.Fence:FindFirstChild("Keys")
            and workspace.Basement.Fence.Keys:FindFirstChild("Key")

        if not keyPart or not keyPart:IsA("BasePart") then
            Fluent:Notify({ Title = "错误", Content = "未找到地下室钥匙", Duration = 2 })
            return
        end

        root.CFrame = CFrame.new(keyPart.Position + Vector3.new(0, 3, 0))
        Fluent:Notify({ Title = "钥匙", Content = "传送到钥匙旁，正在拾取", Duration = 2 })
        task.wait(0.5)

        local oldCameraType = camera.CameraType
        camera.CameraType = Enum.CameraType.Scriptable
        local lockThread = task.spawn(function()
            while keyPart and keyPart.Parent do
                if root then
                    camera.CFrame = CFrame.new(root.Position + Vector3.new(0, 1.5, 0), keyPart.Position)
                end
                task.wait()
            end
        end)

        autoInteract(keyPart)
        task.wait(0.5)

        camera.CameraType = oldCameraType
        if lockThread then task.cancel(lockThread) end

        Fluent:Notify({ Title = "钥匙", Content = "已拾取钥匙，传送至铁门", Duration = 2 })
        task.wait(0.5)

        root.CFrame = CFrame.new(ironDoorPosition + Vector3.new(0, 3, 0))
        Fluent:Notify({ Title = "铁门", Content = "正在搜索开门按钮", Duration = 2 })
        task.wait(1)

        local doorPrompt = findDoorPrompt()
        if not doorPrompt then
            Fluent:Notify({ Title = "错误", Content = "未找到开门按钮，请手动", Duration = 3 })
        else
            camera.CameraType = Enum.CameraType.Scriptable
            local doorTarget = doorPrompt.Parent
            local doorLock = task.spawn(function()
                while doorTarget and doorTarget.Parent do
                    if root then
                        camera.CFrame = CFrame.new(root.Position + Vector3.new(0, 1.5, 0), doorTarget.Position)
                    end
                    task.wait()
                end
            end)

            doorPrompt.HoldDuration = 5
            pcall(function() doorPrompt:InputHoldBegin() end)
            task.wait(5.5)
            pcall(function() doorPrompt:InputHoldEnd() end)

            if doorLock then task.cancel(doorLock) end
            camera.CameraType = oldCameraType

            Fluent:Notify({ Title = "完成", Content = "铁门已开启", Duration = 2 })
        end
    end
})

Tabs.ESP:AddToggle("EnableMonsterESP", {
    Title = "透视怪物",
    Default = false,
    Callback = function(state)
        monsterEspEnabled = state
        if state then
            createScreenGui()
            updateMonsterESP()
        else
            clearMonsterESP()
        end
    end
})

Tabs.ESP:AddToggle("EnableKeyESP", {
    Title = "透视钥匙",
    Default = false,
    Callback = function(state)
        keyEspEnabled = state
        if state then
            updateKeyESP()
        else
            clearKeyESP()
        end
    end
})

Tabs.ESP:AddToggle("EnablePartsESP", {
    Title = "透视零件",
    Default = false,
    Callback = function(state)
        partsEspEnabled = state
        if state then
            updatePartsESP()
        else
            clearPartsESP()
        end
    end
})

Tabs.Teleport:AddButton({
    Title = "传送安全区",
    Callback = function()
        local char = player.Character
        if char and char:FindFirstChild("HumanoidRootPart") then
            pcall(function() char.HumanoidRootPart.CFrame = CFrame.new(safeZonePosition) end)
            Fluent:Notify({ Title = "传送", Content = "已传送到安全区", Duration = 2 })
        end
    end
})

Tabs.Teleport:AddButton({
    Title = "传送发电室",
    Callback = function()
        local char = player.Character
        if char and char:FindFirstChild("HumanoidRootPart") then
            pcall(function() char.HumanoidRootPart.CFrame = CFrame.new(generatorRoomPosition) end)
            Fluent:Notify({ Title = "传送", Content = "已传送到发电室", Duration = 2 })
        end
    end
})

Tabs.Teleport:AddButton({
    Title = "传送出生点(看监控)",
    Callback = function()
        local char = player.Character
        if char and char:FindFirstChild("HumanoidRootPart") then
            pcall(function() char.HumanoidRootPart.CFrame = CFrame.new(spawnPosition) end)
            Fluent:Notify({ Title = "传送", Content = "已传送到出生点(看监控)", Duration = 2 })
        end
    end
})

Tabs.Teleport:AddButton({
    Title = "传送到逃生门",
    Callback = function()
        local function findEscapeDoor()
            for _, obj in ipairs(workspace:GetDescendants()) do
                if obj:IsA("BasePart") and obj.Name == "EscapeDoor" then
                    for _, child in ipairs(obj:GetChildren()) do
                        if child:IsA("TouchTransmitter") then
                            return obj
                        end
                    end
                elseif obj:IsA("Model") and obj.Name == "EscapeDoor" then
                    local part = obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart")
                    if part then
                        for _, child in ipairs(part:GetChildren()) do
                            if child:IsA("TouchTransmitter") then
                                return part
                            end
                        end
                    end
                end
            end
            return nil
        end

        local targetPart = findEscapeDoor()
        if not targetPart then
            Fluent:Notify({ Title = "未触发", Content = "还未触发逃生门，请您尽快完成任务", Duration = 3 })
            return
        end

        local char = player.Character
        if char and char:FindFirstChild("HumanoidRootPart") then
            char.HumanoidRootPart.CFrame = CFrame.new(targetPart.Position + Vector3.new(0, 2, 0))
            Fluent:Notify({ Title = "传送", Content = "已传送到逃生门", Duration = 2 })
        else
            Fluent:Notify({ Title = "传送失败", Content = "角色未加载", Duration = 2 })
        end
    end
})

local autoEscapeEnabled = false

Tabs.Main:AddToggle("AutoEscape", {
    Title = "自动逃生",
    Default = false,
    Callback = function(state)
        autoEscapeEnabled = state
        if state then
            task.spawn(function()
                while autoEscapeEnabled do
                    local char = player.Character
                    if char then
                        local root = char:FindFirstChild("HumanoidRootPart")
                        if root then
                            local kitFolder = workspace:FindFirstChild("kit")
                            if kitFolder then
                                for _, model in ipairs(kitFolder:GetChildren()) do
                                    if model:IsA("Model") then
                                        local lowerName = model.Name:lower()
                                        if monsterNames[lowerName] then
                                            local hum = model:FindFirstChild("Humanoid")
                                            local hrp = model:FindFirstChild("HumanoidRootPart")
                                            if hum and hum.Health > 0 and hrp then
                                                if (hrp.Position - root.Position).Magnitude < 20 then
                                                    pcall(function() root.CFrame = CFrame.new(safeZonePosition) end)
                                                    Fluent:Notify({ Title = "⚠️ 自动逃生", Content = "怪物接近！已传送到安全区", Duration = 2 })
                                                    break
                                                end
                                            end
                                        end
                                    end
                                end
                            end
                        end
                    end
                    task.wait(0.3)
                end
            end)
        end
    end
})

local autoLowerAnxietyEnabled = false
local monitorPrompt = nil

local function stopAnxietyControl()
    if monitorPrompt then
        pcall(function()
            monitorPrompt:InputHoldEnd()
        end)
        monitorPrompt = nil
    end
end

Tabs.Main:AddToggle("AutoLowerAnxiety", {
    Title = "自动降低焦虑",
    Default = false,
    Callback = function(state)
        autoLowerAnxietyEnabled = state
        if state then
            task.spawn(function()
                while autoLowerAnxietyEnabled do
                    local char = player.Character
                    if char and char:FindFirstChild("HumanoidRootPart") and not monitorPrompt then
                        char.HumanoidRootPart.CFrame = CFrame.new(spawnPosition)
                        task.wait(1)
                        for _, part in ipairs(workspace:GetPartBoundsInRadius(spawnPosition, 10)) do
                            local model = part.Parent
                            if model then
                                local prompt = model:FindFirstChildWhichIsA("ProximityPrompt")
                                if prompt then
                                    monitorPrompt = prompt
                                    break
                                end
                            end
                        end
                        if monitorPrompt then
                            pcall(function() monitorPrompt.HoldDuration = 0 end)
                            pcall(function() monitorPrompt:InputHoldBegin() end)
                            Fluent:Notify({ Title = "降焦虑", Content = "已锁定焦虑值", Duration = 2 })
                        end
                    end
                    task.wait(2)
                end
                stopAnxietyControl()
            end)
        else
            autoLowerAnxietyEnabled = false
            stopAnxietyControl()
        end
    end
})

local repairActive = false

local function findGeneratorPrompt()
    local generator = workspace:FindFirstChild("Map") and workspace.Map:FindFirstChild("Generator")
    if not generator then return nil end
    for _, obj in ipairs(generator:GetDescendants()) do
        if obj:IsA("ProximityPrompt") then
            return obj
        end
    end
    return nil
end

local function getProgress()
    local batteryLabel = workspace:FindFirstChild("Map")
        and workspace.Map:FindFirstChild("Generator")
        and workspace.Map.Generator:FindFirstChild("Inside")
        and workspace.Map.Generator.Inside:FindFirstChild("SurfaceGui")
        and workspace.Map.Generator.Inside.SurfaceGui:FindFirstChild("BatteryLabel")
    if batteryLabel and batteryLabel:IsA("TextLabel") then
        local num = tonumber(batteryLabel.Text:match("%d+"))
        return num
    end
    return 0
end

local function startRepairLoop()
    task.spawn(function()
        local prompt = findGeneratorPrompt()
        if not prompt then
            Fluent:Notify({ Title = "错误", Content = "未找到发电机按钮", Duration = 3 })
            repairActive = false
            return
        end

        prompt.MaxActivationDistance = 500
        pcall(function() prompt:InputHoldBegin() end)

        while repairActive do
            local progress = getProgress()
            if progress >= 100 then
                pcall(function() prompt:InputHoldEnd() end)
                Fluent:Notify({ Title = "修电完成", Content = "发电机已修好", Duration = 3 })
                repairActive = false
                break
            end
            task.wait(0.3)
        end
    end)
end

Tabs.Main:AddToggle("AutoRepair", {
    Title = "远程修电",
    Default = false,
    Callback = function(state)
        repairActive = state
        if state then
            startRepairLoop()
        else
            local prompt = findGeneratorPrompt()
            if prompt then
                pcall(function() prompt:InputHoldEnd() end)
            end
        end
    end
})

local batteryDisplayGui = nil
local batteryLabelGlobal = nil

local function updateBatteryDisplay()
    local percent = getProgress()
    if batteryLabelGlobal then
        batteryLabelGlobal.Text = "电量: " .. tostring(percent) .. "%"
    end
end

local function createBatteryDisplay()
    if batteryDisplayGui then return end
    batteryDisplayGui = Instance.new("ScreenGui")
    batteryDisplayGui.Name = "BatteryDisplay"
    batteryDisplayGui.ResetOnSpawn = false
    batteryDisplayGui.Parent = game:GetService("CoreGui")

    batteryLabelGlobal = Instance.new("TextLabel")
    batteryLabelGlobal.Size = UDim2.fromOffset(120, 24)
    batteryLabelGlobal.Position = UDim2.new(0.02, 0, 0.94, 0)
    batteryLabelGlobal.BackgroundTransparency = 1
    batteryLabelGlobal.TextColor3 = Color3.fromRGB(0, 255, 100)
    batteryLabelGlobal.TextStrokeTransparency = 0.5
    batteryLabelGlobal.Font = Enum.Font.SourceSansBold
    batteryLabelGlobal.TextSize = 14
    batteryLabelGlobal.Text = "电量: --%"
    batteryLabelGlobal.Parent = batteryDisplayGui
end

local function destroyBatteryDisplay()
    if batteryDisplayGui then
        batteryDisplayGui:Destroy()
        batteryDisplayGui = nil
        batteryLabelGlobal = nil
    end
end

local batteryDisplayEnabled = false
local batteryUpdateConnection = nil

Tabs.Main:AddToggle("ShowBattery", {
    Title = "显示电量",
    Default = false,
    Callback = function(state)
        batteryDisplayEnabled = state
        if state then
            createBatteryDisplay()
            batteryUpdateConnection = RunService.Heartbeat:Connect(function()
                if batteryDisplayEnabled then
                    updateBatteryDisplay()
                end
            end)
        else
            if batteryUpdateConnection then
                batteryUpdateConnection:Disconnect()
                batteryUpdateConnection = nil
            end
            destroyBatteryDisplay()
        end
    end
})

local daylightEnabled = false
local daylightLoopThread = nil
local configLoaded = false

local function setBrightLighting()
    pcall(function()
        local lighting = game:GetService("Lighting")
        lighting.Brightness = 2
        lighting.ClockTime = 14
        lighting.FogEnd = 100000
        lighting.FogStart = 0
        lighting.GlobalShadows = false
        lighting.Outlines = true
        lighting.EnvironmentSpecularScale = 1
        lighting.EnvironmentDiffuseScale = 1
    end)
end

local function destroyPostEffects()
    local effects = {"BlurEffect","BloomEffect","DepthOfFieldEffect","ColorCorrectionEffect","SunRaysEffect","Atmosphere"}
    for _, container in ipairs({game:GetService("Lighting"), workspace.CurrentCamera, workspace}) do
        if container then
            for _, obj in ipairs(container:GetDescendants()) do
                for _, ef in ipairs(effects) do
                    if obj:IsA(ef) then
                        obj:Destroy()
                    end
                end
            end
        end
    end
end

local function destroyNoiseUI()
    local noiseKeys = {"tvLines","Static","Noise","Grain","Scanline","CRT","VHS","nightVision","Vignette","Fade","flash","Gradient"}
    local playerGui = player:FindFirstChild("PlayerGui")
    if not playerGui then return end
    for _, gui in ipairs(playerGui:GetChildren()) do
        if gui:IsA("ScreenGui") or gui:IsA("LayerCollector") then
            for _, obj in ipairs(gui:GetDescendants()) do
                if obj:IsA("ImageLabel") or obj:IsA("Frame") then
                    local nameLower = obj.Name:lower()
                    for _, key in ipairs(noiseKeys) do
                        if nameLower:find(key:lower()) then
                            obj:Destroy()
                            break
                        end
                    end
                end
            end
        end
    end
end

local function destroyRedOverlay()
    local playerGui = player:FindFirstChild("PlayerGui")
    if not playerGui then return end
    for _, gui in ipairs(playerGui:GetChildren()) do
        if gui:IsA("ScreenGui") or gui:IsA("LayerCollector") then
            for _, obj in ipairs(gui:GetDescendants()) do
                if (obj:IsA("Frame") or obj:IsA("ImageLabel")) and obj.Size == UDim2.new(1,0,1,0) then
                    local color = obj:IsA("Frame") and obj.BackgroundColor3 or obj:IsA("ImageLabel") and obj.ImageColor3
                    local trans = obj:IsA("Frame") and obj.BackgroundTransparency or obj.ImageTransparency
                    if color and trans < 1 and (color.r > 0.7 or color.r > color.g + 0.3) and obj.Visible then
                        obj:Destroy()
                    end
                end
            end
        end
    end
end

local function daylightCleanup()
    setBrightLighting()
    destroyPostEffects()
    destroyNoiseUI()
    destroyRedOverlay()
end

Tabs.Main:AddToggle("Daylight", {
    Title = "天亮",
    Description = "没有黑暗 只有光明",
    Default = false,
    Callback = function(state)
        if not configLoaded then return end
        daylightEnabled = state
        if state then
            daylightCleanup()
            daylightLoopThread = task.spawn(function()
                while daylightEnabled do
                    daylightCleanup()
                    task.wait(2)
                end
            end)
            Fluent:Notify({ Title = "天亮", Content = "画面已净化", Duration = 2 })
        else
            if daylightLoopThread then
                task.cancel(daylightLoopThread)
                daylightLoopThread = nil
            end
            Fluent:Notify({ Title = "天亮", Content = "已关闭", Duration = 2 })
        end
    end
})

SaveManager:SetLibrary(Fluent)
InterfaceManager:SetLibrary(Fluent)
SaveManager:IgnoreThemeSettings()
SaveManager:SetIgnoreIndexes({})
InterfaceManager:SetFolder("FluentScriptHub")
SaveManager:SetFolder("FluentScriptHub/godzilla-chapter2-night")
InterfaceManager:BuildInterfaceSection(Tabs.Other)
SaveManager:BuildConfigSection(Tabs.Other)

Window:SelectTab(1)
SaveManager:LoadAutoloadConfig()
configLoaded = true
