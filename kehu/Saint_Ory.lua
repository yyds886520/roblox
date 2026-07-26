local oldNamecall
oldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
    local method = getnamecallmethod()
    local args = {...}
    if method == "FireServer" and self.Name == "PlayerEvent" and args[1] == "772" then
        return
    end
    return oldNamecall(self, ...)
end)

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local HttpService = game:GetService("HttpService")
local player = Players.LocalPlayer

local translationCache = {}

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
    local translated = translateGoogle(text, "auto", "zh-CN")
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
if not WindUI then print("WindUI加载失败") return end

local Window = WindUI:CreateWindow({
    Title = "圣奥里 单透",
    Icon = "eye",
    Author = "私人定制",
    Folder = "圣奥里 单透",
    Size = UDim2.fromOffset(500, 420),
    Theme = "Dark",
    SideBarWidth = 160,
    Transparent = true,
    BackgroundImageTransparency = 0.3,
    User = { Enabled = false },
})

WindUI:SetNotificationLower(true)

Window:EditOpenButton({
    Title = "打开/关闭",
    CornerRadius = UDim.new(0, 8),
    StrokeThickness = 2.5,
    Draggable = true,
})

local ESPTab = Window:Tab({ Title = "ESP", Icon = "eye" })

local teamColors = {}

local teamNameMap = {
    ["Police"] = "警察",
    ["Civilian"] = "平民",
    ["Medical"] = "医生",
    ["Fire"] = "消防",
    ["Prisoner"] = "囚犯",
    ["Road Service"] = "道路服务",
    ["Transit"] = "交通",
    ["Delivery"] = "快递",
}

local featureToggles = {
    playerName = true,
    job = true,
    distance = true,
    health = true,
    glow = true,
}

local heightScale = 0.1
local verticalOffset = 65
local MAX_DISTANCE = 3000

local function scanTeams()
    teamColors = {}
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr.Team then
            local teamName = plr.Team.Name
            if not teamColors[teamName] then
                local teamColor = plr.Team.TeamColor.Color or Color3.fromRGB(128, 128, 128)
                teamColors[teamName] = teamColor
            end
        end
    end
end

local function getTeamDisplayName(teamName)
    local chinese = teamNameMap[teamName]
    if chinese then return chinese end
    return translateText(teamName)
end

local espObjects = {}
local highlightObjects = {}
local camera = Workspace.CurrentCamera

local function createESPForPlayer(targetPlayer)
    local objs = {}

    objs.jobTag = Drawing.new("Text"); objs.jobTag.Visible = false; objs.jobTag.Size = 12; objs.jobTag.Center = true; objs.jobTag.Outline = true
    objs.nameTag = Drawing.new("Text"); objs.nameTag.Visible = false; objs.nameTag.Size = 13; objs.nameTag.Center = true; objs.nameTag.Outline = true
    objs.distTag = Drawing.new("Text"); objs.distTag.Visible = false; objs.distTag.Size = 12; objs.distTag.Center = false; objs.distTag.Outline = true
    objs.hpBg = Drawing.new("Line"); objs.hpBg.Visible = false; objs.hpBg.Thickness = 3; objs.hpBg.Color = Color3.fromRGB(50, 50, 50)
    objs.hpBar = Drawing.new("Line"); objs.hpBar.Visible = false; objs.hpBar.Thickness = 2

    espObjects[targetPlayer] = objs
    return objs
end

local function removeESPForPlayer(targetPlayer)
    if espObjects[targetPlayer] then
        for _, obj in pairs(espObjects[targetPlayer]) do
            if obj.Remove then obj:Remove() end
        end
        espObjects[targetPlayer] = nil
    end
    if highlightObjects[targetPlayer] then
        highlightObjects[targetPlayer]:Destroy()
        highlightObjects[targetPlayer] = nil
    end
end

local function createHighlightForPlayer(targetPlayer, color)
    if highlightObjects[targetPlayer] then
        highlightObjects[targetPlayer]:Destroy()
    end
    if not targetPlayer.Character then return end
    local highlight = Instance.new("Highlight")
    highlight.Name = "ESP_Highlight"
    highlight.FillTransparency = 0.2
    highlight.OutlineTransparency = 0
    highlight.OutlineColor = color
    highlight.FillColor = color
    highlight.Adornee = targetPlayer.Character
    highlight.Parent = targetPlayer.Character
    highlightObjects[targetPlayer] = highlight
end

local function removeHighlightForPlayer(targetPlayer)
    if highlightObjects[targetPlayer] then
        highlightObjects[targetPlayer]:Destroy()
        highlightObjects[targetPlayer] = nil
    end
end

local masterEnabled = false
local espConnection

local function updateESP()
    if not masterEnabled then return end

    local localChar = player.Character
    if not localChar then return end
    local localRoot = localChar:FindFirstChild("HumanoidRootPart")
    if not localRoot then return end

    local allPlayers = Players:GetPlayers()

    for _, targetPlayer in ipairs(allPlayers) do
        if targetPlayer == player then continue end

        local char = targetPlayer.Character
        if not char then
            if espObjects[targetPlayer] then
                for _, obj in pairs(espObjects[targetPlayer]) do obj.Visible = false end
            end
            removeHighlightForPlayer(targetPlayer)
            continue
        end

        local root = char:FindFirstChild("HumanoidRootPart")
        local hum = char:FindFirstChild("Humanoid")
        if not root or not hum or hum.Health <= 0 then
            if espObjects[targetPlayer] then
                for _, obj in pairs(espObjects[targetPlayer]) do obj.Visible = false end
            end
            removeHighlightForPlayer(targetPlayer)
            continue
        end

        local dist = (root.Position - localRoot.Position).Magnitude
        if dist > MAX_DISTANCE then
            if espObjects[targetPlayer] then
                for _, obj in pairs(espObjects[targetPlayer]) do obj.Visible = false end
            end
            removeHighlightForPlayer(targetPlayer)
            continue
        end

        local teamName = targetPlayer.Team and targetPlayer.Team.Name or "无队伍"
        local teamColor = teamColors[teamName] or Color3.fromRGB(128,128,128)
        local displayJob = getTeamDisplayName(teamName)
        local defaultColor = Color3.fromRGB(255, 255, 255)

        local rootPos, rootOnScreen = camera:WorldToScreenPoint(root.Position)
        if not rootOnScreen or rootPos.Z < 0 then
            if espObjects[targetPlayer] then
                for _, obj in pairs(espObjects[targetPlayer]) do obj.Visible = false end
            end
            continue
        end

        local characterHeight = 5.5
        local fov = camera.FieldOfView
        local viewportHeight = camera.ViewportSize.Y
        local screenHeight = (characterHeight * viewportHeight) / (2 * dist * math.tan(math.rad(fov) / 2))
        screenHeight = screenHeight * heightScale

        if screenHeight < 8 then screenHeight = 8 end
        if screenHeight > 350 then screenHeight = 350 end

        local adjustedRootY = rootPos.Y + verticalOffset
        local headY = adjustedRootY - screenHeight

        local factor = math.clamp(1 - (dist / MAX_DISTANCE), 0.2, 1)
        local nameSize = math.floor(10 + factor * 6)
        local jobSize = math.floor(9 + factor * 5)
        local distSize = math.floor(9 + factor * 5)
        local barThickness = math.floor(2 + factor * 3)
        local barWidth = math.floor(30 + factor * 40)

        if not espObjects[targetPlayer] then
            createESPForPlayer(targetPlayer)
        end

        local objs = espObjects[targetPlayer]
        local nameY = headY - 18
        local jobY = nameY - jobSize - 4

        if featureToggles.job then
            objs.jobTag.Text = displayJob
            objs.jobTag.Size = jobSize
            objs.jobTag.Position = Vector2.new(rootPos.X, jobY)
            objs.jobTag.Color = teamColor
            objs.jobTag.Visible = true
        else
            objs.jobTag.Visible = false
        end

        if featureToggles.playerName then
            local playerName = targetPlayer.DisplayName ~= targetPlayer.Name and targetPlayer.DisplayName or targetPlayer.Name
            objs.nameTag.Text = playerName
            objs.nameTag.Size = nameSize
            objs.nameTag.Position = Vector2.new(rootPos.X, nameY)
            objs.nameTag.Color = teamColor
            objs.nameTag.Visible = true
        else
            objs.nameTag.Visible = false
        end

        if featureToggles.distance then
            objs.distTag.Text = string.format("%.0fm", dist)
            objs.distTag.Size = distSize
            objs.distTag.Position = Vector2.new(rootPos.X + barWidth/2 + 5, adjustedRootY - 12)
            objs.distTag.Color = defaultColor
            objs.distTag.Visible = true
        else
            objs.distTag.Visible = false
        end

        if featureToggles.health then
            local hpPercent = hum.Health / hum.MaxHealth
            local hpY = adjustedRootY + 4
            local barLeft = rootPos.X - barWidth / 2

            objs.hpBg.From = Vector2.new(barLeft, hpY)
            objs.hpBg.To = Vector2.new(barLeft + barWidth, hpY)
            objs.hpBg.Thickness = barThickness + 1
            objs.hpBg.Visible = true

            objs.hpBar.Color = hpPercent > 0.5 and Color3.fromRGB(0,255,0) or (hpPercent > 0.25 and Color3.fromRGB(255,255,0) or Color3.fromRGB(255,0,0))
            objs.hpBar.From = Vector2.new(barLeft, hpY)
            objs.hpBar.To = Vector2.new(barLeft + barWidth * hpPercent, hpY)
            objs.hpBar.Thickness = barThickness
            objs.hpBar.Visible = true
        else
            objs.hpBg.Visible = false
            objs.hpBar.Visible = false
        end

        if featureToggles.glow then
            if not highlightObjects[targetPlayer] then
                createHighlightForPlayer(targetPlayer, teamColor)
            end
        else
            removeHighlightForPlayer(targetPlayer)
        end
    end

    for targetPlayer, _ in pairs(espObjects) do
        if not targetPlayer.Parent or not table.find(allPlayers, targetPlayer) then
            removeESPForPlayer(targetPlayer)
        end
    end
end

ESPTab:Toggle({
    Title = "总开关",
    Default = false,
    Callback = function(state)
        masterEnabled = state
        if state then
            scanTeams()
            espConnection = RunService.RenderStepped:Connect(updateESP)
        else
            if espConnection then espConnection:Disconnect(); espConnection = nil end
            for p in pairs(espObjects) do removeESPForPlayer(p) end
        end
    end
})

ESPTab:Section({ Title = "显示元素" })

ESPTab:Toggle({
    Title = "名字",
    Default = true,
    Callback = function(state)
        featureToggles.playerName = state
    end
})

ESPTab:Toggle({
    Title = "职位",
    Default = true,
    Callback = function(state)
        featureToggles.job = state
    end
})

ESPTab:Toggle({
    Title = "距离",
    Default = true,
    Callback = function(state)
        featureToggles.distance = state
    end
})

ESPTab:Toggle({
    Title = "血条",
    Default = true,
    Callback = function(state)
        featureToggles.health = state
    end
})

ESPTab:Toggle({
    Title = "高亮",
    Default = true,
    Callback = function(state)
        featureToggles.glow = state
    end
})

scanTeams()
Window:SelectTab(1)
