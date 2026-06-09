local player = game:GetService("Players").LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local runService = game:GetService("RunService")
local tweenService = game:GetService("TweenService")
local userInputService = game:GetService("UserInputService")
local workspace = game:GetService("Workspace")
local replicatedStorage = game:GetService("ReplicatedStorage")

if playerGui:FindFirstChild("MainGUI") then playerGui.MainGUI:Destroy() end
if game:GetService("CoreGui"):FindFirstChild("AimGUI") then game:GetService("CoreGui").AimGUI:Destroy() end

local starterGui = game:GetService("StarterGui")
starterGui:SetCore("SendNotification", {
	Title = "小梦制作",
	Text = "小梦制作必是精品",
	Duration = 5
})
task.wait(0.5)
starterGui:SetCore("SendNotification", {
	Title = "全明星战场",
	Text = "欢迎使用脚本",
	Duration = 5
})

local mainGui = Instance.new("ScreenGui")
mainGui.Name = "MainGUI"
mainGui.ResetOnSpawn = false
mainGui.Parent = game:GetService("CoreGui")

local expandedHeight = 218
local collapsedHeight = 38
local frameWidth = 240

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, frameWidth, 0, expandedHeight)
mainFrame.Position = UDim2.new(0, 100, 0, 50)
mainFrame.BackgroundColor3 = Color3.new(0, 0, 0)
mainFrame.BackgroundTransparency = 0.15
mainFrame.BorderSizePixel = 0
mainFrame.ClipsDescendants = true
mainFrame.Active = true
mainFrame.Parent = mainGui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 8)
corner.Parent = mainFrame

local titleBar = Instance.new("Frame")
titleBar.Size = UDim2.new(1, 0, 0, 38)
titleBar.BackgroundTransparency = 1
titleBar.BorderSizePixel = 0
titleBar.Active = true
titleBar.Parent = mainFrame

local titleText = Instance.new("TextLabel")
titleText.Size = UDim2.new(1, 0, 1, 0)
titleText.BackgroundTransparency = 1
titleText.Text = "全明星战场"
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
collapseBtn.AutoButtonColor = false
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
	row.Active = true
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

	local function setState(state)
		enabled = state
		checkMark.Visible = state
		if callback then callback(state) end
	end

	row.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
			setState(not enabled)
		end
	end)

	return setState
end

local function getAllTargets()
	local list = {}
	for _, plr in ipairs(game:GetService("Players"):GetPlayers()) do
		if plr ~= player and plr.Character then
			table.insert(list, plr.Character)
		end
	end
	for _, obj in ipairs(workspace:GetDescendants()) do
		if obj:IsA("Model") and obj:FindFirstChild("Humanoid") and obj:FindFirstChild("HumanoidRootPart") then
			if not table.find(list, obj) then
				table.insert(list, obj)
			end
		end
	end
	return list
end

local blockingRemote = replicatedStorage:WaitForChild("Characters").Combat.Remotes.Blocking
local blockEnabled = false
local isBlocking = false
local blockConn
local lastBlockTime = 0
local BLOCK_RANGE = 15
local ANGLE_THRESHOLD = 0.3

local function checkAndBlock()
	if not blockEnabled then return end
	local char = player.Character
	if not char then return end
	local root = char:FindFirstChild("HumanoidRootPart")
	if not root then return end
	local myPos = root.Position

	local shouldBlock = false
	for _, target in ipairs(getAllTargets()) do
		local targetRoot = target:FindFirstChild("HumanoidRootPart")
		local targetHum = target:FindFirstChild("Humanoid")
		if targetRoot and targetHum and targetHum.Health > 0 then
			local dist = (targetRoot.Position - myPos).Magnitude
			if dist <= BLOCK_RANGE then
				local enemyLook = targetRoot.CFrame.LookVector
				local toMe = (myPos - targetRoot.Position).Unit
				local dot = enemyLook:Dot(toMe)
				if dot > ANGLE_THRESHOLD then
					shouldBlock = true
					break
				end
			end
		end
	end

	local now = os.clock()
	if shouldBlock and not isBlocking and (now - lastBlockTime > 0.5) then
		pcall(function() blockingRemote:FireServer(player) end)
		isBlocking = true
		lastBlockTime = now
	elseif not shouldBlock and isBlocking and (now - lastBlockTime > 0.5) then
		pcall(function() blockingRemote:FireServer(player) end)
		isBlocking = false
		lastBlockTime = now
	end
end

local counterEnabled = false
local counterConn
local lastCounterTime = 0
local MIN_COUNTER_INTERVAL = 0.3
local trackedAnims = {}

local function getCounterRemote()
	local char = player.Character
	if not char then return nil end
	for _, child in ipairs(char:GetChildren()) do
		local counter = child:FindFirstChild("CounterActivate")
		if counter then return counter end
	end
	return nil
end

local function checkAndCounter()
	if not counterEnabled then return end
	local char = player.Character
	if not char then return end
	local root = char:FindFirstChild("HumanoidRootPart")
	if not root then return end

	local counterRemote = getCounterRemote()
	if not counterRemote then return end

	local shouldCounter = false
	for _, target in ipairs(getAllTargets()) do
		local targetHum = target:FindFirstChild("Humanoid")
		if targetHum then
			local animator = targetHum:FindFirstChild("Animator")
			if animator then
				local playingTracks = animator:GetPlayingAnimationTracks()
				if #playingTracks > 0 then
					local key = target.Name
					local currentCount = #playingTracks
					if not trackedAnims[key] or trackedAnims[key] ~= currentCount then
						trackedAnims[key] = currentCount
						shouldCounter = true
						break
					end
				end
			end
		end
	end

	if shouldCounter then
		local now = os.clock()
		if now - lastCounterTime > MIN_COUNTER_INTERVAL then
			pcall(function() counterRemote:FireServer(player) end)
			lastCounterTime = now
		end
	end
end

addToggleRow(0, "自动防御", function(state)
	blockEnabled = state
	if state then
		blockConn = runService.Heartbeat:Connect(checkAndBlock)
	else
		if blockConn then blockConn:Disconnect(); blockConn = nil end
		if isBlocking then
			pcall(function() blockingRemote:FireServer(player) end)
			isBlocking = false
		end
	end
end)

addToggleRow(32, "无限防反", function(state)
	counterEnabled = state
	if state then
		trackedAnims = {}
		counterConn = runService.Heartbeat:Connect(checkAndCounter)
	else
		if counterConn then counterConn:Disconnect(); counterConn = nil end
		trackedAnims = {}
	end
end)

local authorRow = Instance.new("Frame")
authorRow.Size = UDim2.new(1, -2 * paddingLeft, 0, 32)
authorRow.Position = UDim2.new(0, paddingLeft, 0, 64)
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
local dragStartPos = nil
local startOffsetX, startOffsetY = 0, 0

titleBar.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		dragging = true
		dragStartPos = input.Position
		startOffsetX = mainFrame.Position.X.Offset
		startOffsetY = mainFrame.Position.Y.Offset
	end
end)

userInputService.InputChanged:Connect(function(input)
	if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
		local delta = input.Position - dragStartPos
		mainFrame.Position = UDim2.new(0, startOffsetX + delta.X, 0, startOffsetY + delta.Y)
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
	collapseBtn.Text = collapsed and "▲" or "▼"
end

collapseBtn.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
		setCollapsed(not isCollapsed)
	end
end)

setCollapsed(false)
