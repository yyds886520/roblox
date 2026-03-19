--------------------------------------------------
-- UI 创建
--------------------------------------------------
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")

local player = Players.LocalPlayer

local ScreenGui = Instance.new("ScreenGui", game.CoreGui)

local Main = Instance.new("Frame", ScreenGui)
Main.Size = UDim2.new(0, 260, 0, 220)
Main.Position = UDim2.new(0.5, -130, 0.4, 0)
Main.BackgroundColor3 = Color3.fromRGB(0,0,0)
Main.BackgroundTransparency = 0.2
Main.BorderSizePixel = 0

-- 圆角
Instance.new("UICorner", Main).CornerRadius = UDim.new(0,12)

--------------------------------------------------
-- 拖动功能
--------------------------------------------------
local dragging, dragInput, dragStart, startPos

Main.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		dragging = true
		dragStart = input.Position
		startPos = Main.Position
		
		input.Changed:Connect(function()
			if input.UserInputState == Enum.UserInputState.End then
				dragging = false
			end
		end)
	end
end)

UIS.InputChanged:Connect(function(input)
	if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
		local delta = input.Position - dragStart
		Main.Position = UDim2.new(
			startPos.X.Scale,
			startPos.X.Offset + delta.X,
			startPos.Y.Scale,
			startPos.Y.Offset + delta.Y
		)
	end
end)

--------------------------------------------------
-- 标题
--------------------------------------------------
local Title = Instance.new("TextLabel", Main)
Title.Size = UDim2.new(1,0,0,40)
Title.Text = "小梦测试script"
Title.TextColor3 = Color3.fromRGB(255,255,255)
Title.TextScaled = true
Title.BackgroundTransparency = 1
Title.Font = Enum.Font.GothamBold

local Author = Instance.new("TextLabel", Main)
Author.Position = UDim2.new(0,0,0,35)
Author.Size = UDim2.new(1,0,0,25)
Author.Text = "小梦制作"
Author.TextColor3 = Color3.fromRGB(180,180,180)
Author.TextScaled = true
Author.BackgroundTransparency = 1

--------------------------------------------------
-- 按钮函数
--------------------------------------------------
local function createToggle(text, yPos)
	local btn = Instance.new("TextButton", Main)
	btn.Size = UDim2.new(1,-20,0,35)
	btn.Position = UDim2.new(0,10,0,yPos)
	btn.BackgroundColor3 = Color3.fromRGB(40,40,40)
	btn.TextColor3 = Color3.new(1,1,1)
	btn.Text = text.." : OFF"
	btn.Font = Enum.Font.Gotham
	btn.TextScaled = true
	
	Instance.new("UICorner", btn).CornerRadius = UDim.new(0,8)
	
	return btn
end

--------------------------------------------------
-- 创建按钮
--------------------------------------------------
local SpeedBtn = createToggle("速度", 70)
local FlyBtn = createToggle("飞行", 110)
local NoclipBtn = createToggle("穿墙", 150)

--------------------------------------------------
-- 功能变量
--------------------------------------------------
local TPWalk = false
local fly = false
local noclip = false

local flyBV, flyBG, flyConn, noclipConn

--------------------------------------------------
-- 🏃 速度
--------------------------------------------------
SpeedBtn.MouseButton1Click:Connect(function()
	TPWalk = not TPWalk
	SpeedBtn.Text = "速度 : "..(TPWalk and "ON" or "OFF")
	
	if TPWalk then
		coroutine.wrap(function()
			while TPWalk do
				local char = player.Character
				if char and char:FindFirstChild("HumanoidRootPart") then
					local hrp = char.HumanoidRootPart
					local hum = char:FindFirstChildOfClass("Humanoid")
					
					if hum and hum.MoveDirection.Magnitude > 0 then
						hrp.CFrame += hum.MoveDirection * 3
					end
				end
				RunService.Heartbeat:Wait()
			end
		end)()
	end
end)

--------------------------------------------------
-- ✈️ 飞行
--------------------------------------------------
FlyBtn.MouseButton1Click:Connect(function()
	fly = not fly
	FlyBtn.Text = "飞行 : "..(fly and "ON" or "OFF")
	
	local char = player.Character
	if not char then return end
	
	local hrp = char:FindFirstChild("HumanoidRootPart")
	if not hrp then return end
	
	if fly then
		flyBV = Instance.new("BodyVelocity", hrp)
		flyBV.MaxForce = Vector3.new(9e9,9e9,9e9)
		
		flyBG = Instance.new("BodyGyro", hrp)
		flyBG.MaxTorque = Vector3.new(9e9,9e9,9e9)
		
		flyConn = RunService.RenderStepped:Connect(function()
			if not fly then return end
			
			local cam = workspace.CurrentCamera
			flyBG.CFrame = cam.CFrame
			
			local dir = Vector3.zero
			
			if UIS:IsKeyDown(Enum.KeyCode.W) then dir += cam.CFrame.LookVector end
			if UIS:IsKeyDown(Enum.KeyCode.S) then dir -= cam.CFrame.LookVector end
			if UIS:IsKeyDown(Enum.KeyCode.A) then dir -= cam.CFrame.RightVector end
			if UIS:IsKeyDown(Enum.KeyCode.D) then dir += cam.CFrame.RightVector end
			if UIS:IsKeyDown(Enum.KeyCode.Space) then dir += Vector3.new(0,1,0) end
			if UIS:IsKeyDown(Enum.KeyCode.LeftControl) then dir -= Vector3.new(0,1,0) end
			
			flyBV.Velocity = dir * 40
		end)
	else
		if flyBV then flyBV:Destroy() end
		if flyBG then flyBG:Destroy() end
		if flyConn then flyConn:Disconnect() end
	end
end)

--------------------------------------------------
-- 👻 穿墙
--------------------------------------------------
NoclipBtn.MouseButton1Click:Connect(function()
	noclip = not noclip
	NoclipBtn.Text = "穿墙 : "..(noclip and "ON" or "OFF")
	
	if noclip then
		noclipConn = RunService.Stepped:Connect(function()
			local char = player.Character
			if char then
				for _,v in pairs(char:GetDescendants()) do
					if v:IsA("BasePart") then
						v.CanCollide = false
					end
				end
			end
		end)
	else
		if noclipConn then noclipConn:Disconnect() end
		
		local char = player.Character
		if char then
			for _,v in pairs(char:GetDescendants()) do
				if v:IsA("BasePart") then
					v.CanCollide = true
				end
			end
		end
	end
end)
