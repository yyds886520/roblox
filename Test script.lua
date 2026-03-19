-- 小梦测试script 高级版 UI (改进版)
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")

local player = Players.LocalPlayer
local function getChar()
    return player.Character or player.CharacterAdded:Wait()
end

-- 创建主界面
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Parent = player:WaitForChild("PlayerGui")
ScreenGui.ResetOnSpawn = false

local Main = Instance.new("Frame")
Main.Parent = ScreenGui
Main.Size = UDim2.new(0, 260, 0, 220)
Main.Position = UDim2.new(0.5, -130, 0.4, 0)
Main.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
Main.BackgroundTransparency = 0.2
Main.BorderSizePixel = 0
Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 12)

-- 标题
local Title = Instance.new("TextLabel", Main)
Title.Size = UDim2.new(1, 0, 0, 40)
Title.Text = "小梦测试script"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextScaled = true
Title.BackgroundTransparency = 1
Title.Font = Enum.Font.GothamBold

local Author = Instance.new("TextLabel", Main)
Author.Position = UDim2.new(0, 0, 0, 35)
Author.Size = UDim2.new(1, 0, 0, 25)
Author.Text = "小梦制作"
Author.TextColor3 = Color3.fromRGB(180, 180, 180)
Author.TextScaled = true
Author.BackgroundTransparency = 1

-- 拖动功能 (修复版)
local dragging = false
local dragStartPos, dragStartMouse

Main.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStartPos = Main.Position
        dragStartMouse = UIS:GetMouseLocation()
    end
end)

Main.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = false
    end
end)

UIS.InputChanged:Connect(function(input)
    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
        local delta = input.Position - dragStartMouse
        Main.Position = UDim2.new(
            dragStartPos.X.Scale,
            dragStartPos.X.Offset + delta.X,
            dragStartPos.Y.Scale,
            dragStartPos.Y.Offset + delta.Y
        )
    end
end)

-- 辅助函数：创建按钮（保持原样）
local function createToggle(text, yPos)
    local btn = Instance.new("TextButton", Main)
    btn.Size = UDim2.new(1, -20, 0, 35)
    btn.Position = UDim2.new(0, 10, 0, yPos)
    btn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    btn.TextColor3 = Color3.new(1, 1, 1)
    btn.Text = text .. " : OFF"
    btn.Font = Enum.Font.Gotham
    btn.TextScaled = true
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)
    return btn
end

-- 创建三个主按钮
local SpeedBtn = createToggle("速度", 70)
local FlyBtn = createToggle("飞行", 110)
local NoclipBtn = createToggle("穿墙", 150)

-- 功能状态变量
local speedEnabled = false
local flyEnabled = false
local noclipEnabled = false

-- 速度值（默认3）
local speedValue = 3
-- 飞行速度（默认40）
local flySpeedValue = 40

-- 滑块菜单的父容器（放在主界面下方）
local menuContainer = Instance.new("Frame")
menuContainer.Parent = ScreenGui
menuContainer.Size = UDim2.new(1, 0, 0, 80)
menuContainer.Position = UDim2.new(0, 0, 0.4, 230) -- 主界面下方
menuContainer.BackgroundTransparency = 1
menuContainer.Visible = true

-- 滑块菜单列表
local speedMenu = nil
local flyMenu = nil

-- 函数：创建带滑块的调节菜单
local function createSliderMenu(title, minVal, maxVal, defaultVal, yOffset, valueChangedCallback)
    local menu = Instance.new("Frame")
    menu.Parent = menuContainer
    menu.Size = UDim2.new(0, 200, 0, 60)
    menu.Position = UDim2.new(0, 10 + yOffset * 210, 0, 0) -- 水平排列，间隔210
    menu.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    menu.BackgroundTransparency = 0.1
    menu.BorderSizePixel = 0
    Instance.new("UICorner", menu).CornerRadius = UDim.new(0, 8)

    -- 标题 + 数值显示
    local label = Instance.new("TextLabel")
    label.Parent = menu
    label.Size = UDim2.new(1, -10, 0, 20)
    label.Position = UDim2.new(0, 5, 0, 5)
    label.BackgroundTransparency = 1
    label.Text = title .. ": " .. defaultVal
    label.TextColor3 = Color3.fromRGB(255, 255, 255)
    label.Font = Enum.Font.Gotham
    label.TextSize = 14
    label.TextXAlignment = Enum.TextXAlignment.Left

    -- 滑块轨道
    local track = Instance.new("Frame")
    track.Parent = menu
    track.Size = UDim2.new(1, -20, 0, 6)
    track.Position = UDim2.new(0, 10, 0, 35)
    track.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
    track.BorderSizePixel = 0
    Instance.new("UICorner", track).CornerRadius = UDim.new(1, 0)

    -- 滑块按钮 (可拖动)
    local thumb = Instance.new("ImageButton")
    thumb.Parent = menu
    thumb.Size = UDim2.new(0, 16, 0, 16)
    thumb.Position = UDim2.new(0, 10, 0, 30) -- 初始位置对应最小值
    thumb.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    thumb.Image = "rbxasset://textures/ui/GuiImagePlaceholder.png" -- 白色圆点
    thumb.BackgroundTransparency = 1
    Instance.new("UICorner", thumb).CornerRadius = UDim.new(1, 0)

    -- 拖动逻辑
    local draggingThumb = false
    local thumbStartPos, thumbStartMouse

    thumb.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            draggingThumb = true
            thumbStartPos = thumb.Position
            thumbStartMouse = UIS:GetMouseLocation()
        end
    end)

    thumb.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            draggingThumb = false
        end
    end)

    UIS.InputChanged:Connect(function(input)
        if draggingThumb and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - thumbStartMouse
            local newX = thumbStartPos.X.Offset + delta.X
            -- 限制在轨道范围内
            local minX = 10
            local maxX = menu.AbsoluteSize.X - 30 -- 轨道右边界
            newX = math.clamp(newX, minX, maxX)

            thumb.Position = UDim2.new(0, newX, 0, 30)

            -- 计算百分比并转换为速度值
            local percent = (newX - minX) / (maxX - minX)
            local val = minVal + (maxVal - minVal) * percent
            val = math.floor(val * 10) / 10 -- 保留一位小数

            label.Text = title .. ": " .. val
            valueChangedCallback(val)
        end
    end)

    -- 根据默认值设置初始滑块位置
    local function updateThumbFromValue(val)
        local percent = (val - minVal) / (maxVal - minVal)
        local minX = 10
        local maxX = menu.AbsoluteSize.X - 30
        local newX = minX + (maxX - minX) * percent
        thumb.Position = UDim2.new(0, newX, 0, 30)
    end

    -- 由于 AbsoluteSize 在下一帧才可用，延迟设置初始位置
    task.wait()
    updateThumbFromValue(defaultVal)

    -- 返回菜单对象和更新函数
    return menu
end

--------------------------------------------------
-- 🏃 速度功能（带滑块）
--------------------------------------------------
SpeedBtn.MouseButton1Click:Connect(function()
    speedEnabled = not speedEnabled
    SpeedBtn.Text = "速度 : " .. (speedEnabled and "ON" or "OFF")

    if speedEnabled then
        -- 创建速度滑块菜单（如果尚未存在）
        if not speedMenu then
            speedMenu = createSliderMenu("行走速度", 1, 20, speedValue, 0, function(newVal)
                speedValue = newVal
            end)
        else
            speedMenu.Visible = true
        end

        -- 启动速度循环
        coroutine.wrap(function()
            while speedEnabled do
                local char = getChar()
                if char and char:FindFirstChild("HumanoidRootPart") then
                    local hrp = char.HumanoidRootPart
                    local hum = char:FindFirstChildOfClass("Humanoid")
                    if hum and hum.MoveDirection.Magnitude > 0 then
                        hrp.CFrame += hum.MoveDirection * speedValue
                    end
                end
                RunService.Heartbeat:Wait()
            end
        end)()
    else
        -- 隐藏速度滑块菜单
        if speedMenu then
            speedMenu.Visible = false
        end
    end
end)

--------------------------------------------------
-- ✈️ 飞行功能（带滑块）
--------------------------------------------------
FlyBtn.MouseButton1Click:Connect(function()
    flyEnabled = not flyEnabled
    FlyBtn.Text = "飞行 : " .. (flyEnabled and "ON" or "OFF")

    if flyEnabled then
        -- 创建飞行滑块菜单（如果尚未存在）
        if not flyMenu then
            flyMenu = createSliderMenu("飞行速度", 10, 100, flySpeedValue, 1, function(newVal)
                flySpeedValue = newVal
            end)
        else
            flyMenu.Visible = true
        end

        -- 启动飞行逻辑
        local char = getChar()
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if not hrp then return end

        -- 创建 BodyVelocity 和 BodyGyro（如果已存在则先清理）
        if hrp:FindFirstChild("FlyBV") then hrp.FlyBV:Destroy() end
        if hrp:FindFirstChild("FlyBG") then hrp.FlyBG:Destroy() end

        local flyBV = Instance.new("BodyVelocity")
        flyBV.Name = "FlyBV"
        flyBV.MaxForce = Vector3.new(9e9, 9e9, 9e9)
        flyBV.Parent = hrp

        local flyBG = Instance.new("BodyGyro")
        flyBG.Name = "FlyBG"
        flyBG.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
        flyBG.Parent = hrp

        -- 飞行更新循环
        local flyConnection
        flyConnection = RunService.RenderStepped:Connect(function()
            if not flyEnabled then
                flyConnection:Disconnect()
                return
            end

            -- 重新获取角色（防止角色重生后失效）
            local char = getChar()
            local hrp = char:FindFirstChild("HumanoidRootPart")
            if not hrp then return end

            -- 确保 BodyVelocity/BodyGyro 存在
            local bv = hrp:FindFirstChild("FlyBV")
            local bg = hrp:FindFirstChild("FlyBG")
            if not bv or not bg then return end

            local cam = workspace.CurrentCamera
            bg.CFrame = cam.CFrame

            local dir = Vector3.zero
            if UIS:IsKeyDown(Enum.KeyCode.W) then dir += cam.CFrame.LookVector end
            if UIS:IsKeyDown(Enum.KeyCode.S) then dir -= cam.CFrame.LookVector end
            if UIS:IsKeyDown(Enum.KeyCode.A) then dir -= cam.CFrame.RightVector end
            if UIS:IsKeyDown(Enum.KeyCode.D) then dir += cam.CFrame.RightVector end
            if UIS:IsKeyDown(Enum.KeyCode.Space) then dir += Vector3.new(0, 1, 0) end
            if UIS:IsKeyDown(Enum.KeyCode.LeftControl) then dir -= Vector3.new(0, 1, 0) end

            bv.Velocity = dir * flySpeedValue
        end)
    else
        -- 关闭飞行：清理 BodyVelocity/BodyGyro
        local char = getChar()
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if hrp then
            local bv = hrp:FindFirstChild("FlyBV")
            if bv then bv:Destroy() end
            local bg = hrp:FindFirstChild("FlyBG")
            if bg then bg:Destroy() end
        end

        -- 隐藏飞行滑块菜单
        if flyMenu then
            flyMenu.Visible = false
        end
    end
end)

--------------------------------------------------
-- 👻 穿墙功能（保持不变，仅调整变量名）
--------------------------------------------------
NoclipBtn.MouseButton1Click:Connect(function()
    noclipEnabled = not noclipEnabled
    NoclipBtn.Text = "穿墙 : " .. (noclipEnabled and "ON" or "OFF")

    if noclipEnabled then
        -- 持续关闭 CanCollide
        noclipConn = RunService.Stepped:Connect(function()
            local char = getChar()
            if char then
                for _, v in pairs(char:GetDescendants()) do
                    if v:IsA("BasePart") then
                        v.CanCollide = false
                    end
                end
            end
        end)
    else
        if noclipConn then
            noclipConn:Disconnect()
            noclipConn = nil
        end
        -- 恢复 CanCollide
        local char = getChar()
        if char then
            for _, v in pairs(char:GetDescendants()) do
                if v:IsA("BasePart") then
                    v.CanCollide = true
                end
            end
        end
    end
end)
