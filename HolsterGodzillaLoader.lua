local gui = Instance.new("ScreenGui")
gui.Name = "ChapterLoader"
gui.ResetOnSpawn = false
gui.Parent = game:GetService("CoreGui")

local overlay = Instance.new("Frame")
overlay.Size = UDim2.fromScale(1, 1)
overlay.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
overlay.BackgroundTransparency = 0.5
overlay.BorderSizePixel = 0
overlay.Parent = gui

local frame = Instance.new("Frame")
frame.Size = UDim2.fromOffset(0, 0)
frame.Position = UDim2.fromScale(0.5, 0.5)
frame.AnchorPoint = Vector2.new(0.5, 0.5)
frame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
frame.BorderSizePixel = 0
frame.ClipsDescendants = true
frame.Parent = gui

Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 16)
local stroke = Instance.new("UIStroke", frame)
stroke.Thickness = 2
stroke.Color = Color3.fromRGB(255, 215, 0)
stroke.Transparency = 0.5

local btn1 = Instance.new("TextButton")
btn1.Size = UDim2.fromOffset(160, 50)
btn1.Position = UDim2.fromScale(0.5, 0.35)
btn1.AnchorPoint = Vector2.new(0.5, 0.5)
btn1.BackgroundColor3 = Color3.fromRGB(255, 215, 0)
btn1.Text = "第1章"
btn1.TextColor3 = Color3.fromRGB(0, 0, 0)
btn1.Font = Enum.Font.SourceSansBold
btn1.TextSize = 20
btn1.BorderSizePixel = 0
btn1.Parent = frame
Instance.new("UICorner", btn1).CornerRadius = UDim.new(0, 10)

local btn2 = Instance.new("TextButton")
btn2.Size = UDim2.fromOffset(160, 50)
btn2.Position = UDim2.fromScale(0.5, 0.65)
btn2.AnchorPoint = Vector2.new(0.5, 0.5)
btn2.BackgroundColor3 = Color3.fromRGB(255, 215, 0)
btn2.Text = "第2章"
btn2.TextColor3 = Color3.fromRGB(0, 0, 0)
btn2.Font = Enum.Font.SourceSansBold
btn2.TextSize = 20
btn2.BorderSizePixel = 0
btn2.Parent = frame
Instance.new("UICorner", btn2).CornerRadius = UDim.new(0, 10)

local TweenService = game:GetService("TweenService")
local openTween = TweenService:Create(frame, TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
    Size = UDim2.fromOffset(220, 180)
})
openTween:Play()

local function closeAndRun(url)
    local closeTween = TweenService:Create(frame, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
        Size = UDim2.fromOffset(0, 0)
    })
    closeTween:Play()
    closeTween.Completed:Connect(function()
        gui:Destroy()
        loadstring(game:HttpGet(url))()
    end)
end

btn1.MouseButton1Click:Connect(function()
    closeAndRun("https://raw.githubusercontent.com/xiaomeng0930/QWQ/refs/heads/main/HolsterGodzillaChapter1.lua")
end)

btn2.MouseButton1Click:Connect(function()
    closeAndRun("https://raw.githubusercontent.com/xiaomeng0930/QWQ/refs/heads/main/HolsterGodzillaChapter2.lua")
end)
