--[[
    脚本名：踢一个幸运方块获得足球卡片
    Script Name: Kick Lucky Block Get Football Card
    版本号：v1.0
    作者：小梦
]]

local WindUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/Footagesus/WindUI/main/dist/main.lua"))()
if not WindUI then return warn("WindUI 加载失败") end

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local function safeGetRemote(path)
    local success, result = pcall(function()
        local container = ReplicatedStorage
        for part in path:gmatch("[^.]+") do
            container = container:WaitForChild(part, 2)
        end
        return container
    end)
    return success and result or nil
end

local claimEvent = safeGetRemote("Events.ClaimHatchedItem")
local sellEvent = safeGetRemote("Events.RequestSell")

local itemConfig = {}
pcall(function()
    itemConfig = require(ReplicatedStorage:WaitForChild("Modules", 2):WaitForChild("ItemConfigurations", 2))
end)

local cardsByRarity = {}
local cardIncome = {}
for name, data in pairs(itemConfig.Items or {}) do
    local rarity = data.Rarity or "Common"
    if not cardsByRarity[rarity] then cardsByRarity[rarity] = {} end
    table.insert(cardsByRarity[rarity], name)
    cardIncome[name] = data.Income or 0
end

local rarityOrder = {
    { en = "Common",    zh = "普通" },
    { en = "Uncommon",  zh = "罕见" },
    { en = "Rare",      zh = "稀有" },
    { en = "Epic",      zh = "史诗" },
    { en = "Legendary", zh = "传说" },
    { en = "Mythical",  zh = "神话" },
    { en = "Divine",    zh = "神圣" },
    { en = "Celestial", zh = "天界" },
    { en = "Cosmic",    zh = "宇宙" },
    { en = "Eternal",   zh = "永恒" },
    { en = "Hacked",    zh = "已被黑客入侵" },
    { en = "Exclusive", zh = "独家" },
    { en = "Secret",    zh = "秘密" },
}
local raritiesZh = {}
for _, r in ipairs(rarityOrder) do
    if cardsByRarity[r.en] then table.insert(raritiesZh, r.zh) end
end

local mutationOrder = {
    { en = "Normal",   zh = "普通" },
    { en = "Gold",     zh = "黄金" },
    { en = "Diamond",  zh = "钻石" },
    { en = "Rainbow",  zh = "彩虹" },
}
local mutationsZh = {"普通", "黄金", "钻石", "彩虹", "随机", "价值最高"}

local function zhToRarityEn(zh)
    for _, r in ipairs(rarityOrder) do if r.zh == zh then return r.en end end
end
local function zhToMutationEn(zh)
    for _, m in ipairs(mutationOrder) do if m.zh == zh then return m.en end end
end
local function getBestCardInRarity(rarityEn)
    local pool = cardsByRarity[rarityEn]
    if not pool then return nil end
    local best, bestInc = nil, -1
    for _, n in ipairs(pool) do
        if cardIncome[n] > bestInc then
            bestInc = cardIncome[n]; best = n
        end
    end
    return best
end

local Window = WindUI:CreateWindow({
    Title = "踢一个幸运方块获得足球卡片",
    Icon = "soccer",
    Author = "by.小梦",
    Folder = "KickLuckyBlock",
    Size = UDim2.fromOffset(480, 620),
    Theme = "Dark",
    SideBarWidth = 200,
    Transparent = true,
    BackgroundImageTransparency = 0.3,
    User = { Enabled = false },
})
if not Window then return warn("窗口创建失败") end

Window:EditOpenButton({
    Title = "⚽",
    Icon = "soccer",
    CornerRadius = UDim.new(0, 8),
    StrokeThickness = 2.5,
    Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 0, 0)),
        ColorSequenceKeypoint.new(0.2, Color3.fromRGB(255, 255, 0)),
        ColorSequenceKeypoint.new(0.4, Color3.fromRGB(0, 255, 0)),
        ColorSequenceKeypoint.new(0.6, Color3.fromRGB(0, 255, 255)),
        ColorSequenceKeypoint.new(0.8, Color3.fromRGB(0, 0, 255)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 0, 255)),
    }),
    Draggable = true,
})

local ResourceTab = Window:Tab({ Title = "刷资源", Icon = "dollar-sign" })
local selectedRarityZh = raritiesZh[#raritiesZh] or "秘密"
local selectedMutationZh = "彩虹"

ResourceTab:Dropdown({
    Title = "稀有度",
    Values = raritiesZh,
    Default = selectedRarityZh,
    Callback = function(v) selectedRarityZh = v end,
})

ResourceTab:Dropdown({
    Title = "品质",
    Values = mutationsZh,
    Default = selectedMutationZh,
    Callback = function(v) selectedMutationZh = v end,
})

ResourceTab:Button({
    Title = "刷一张卡牌",
    Callback = function()
        if not claimEvent then return end
        local rarityEn = zhToRarityEn(selectedRarityZh)
        if not rarityEn then return end
        local pool = cardsByRarity[rarityEn]
        if not pool or #pool == 0 then return end
        local mutationEn, card
        if selectedMutationZh == "随机" then
            mutationEn = mutationOrder[math.random(#mutationOrder)].en
            card = pool[math.random(#pool)]
        elseif selectedMutationZh == "价值最高" then
            mutationEn = "Rainbow"
            card = getBestCardInRarity(rarityEn)
        else
            mutationEn = zhToMutationEn(selectedMutationZh)
            card = pool[math.random(#pool)]
        end
        if card and mutationEn then
            claimEvent:FireServer(card, rarityEn, mutationEn)
        end
    end,
})

local AutoTab = Window:Tab({ Title = "自动", Icon = "zap" })

AutoTab:Section({ Title = "自动刷卡牌" })
local autoClaim = false
AutoTab:Toggle({
    Title = "自动刷卡牌",
    Desc = "每0.5秒按所选规则刷一张",
    Default = false,
    Callback = function(state)
        if not claimEvent then return end
        autoClaim = state
        if state then
            task.spawn(function()
                while autoClaim do
                    local rarityEn = zhToRarityEn(selectedRarityZh)
                    if not rarityEn then break end
                    local pool = cardsByRarity[rarityEn]
                    if not pool or #pool == 0 then break end
                    local mutationEn, card
                    if selectedMutationZh == "随机" then
                        mutationEn = mutationOrder[math.random(#mutationOrder)].en
                        card = pool[math.random(#pool)]
                    elseif selectedMutationZh == "价值最高" then
                        mutationEn = "Rainbow"
                        card = getBestCardInRarity(rarityEn)
                    else
                        mutationEn = zhToMutationEn(selectedMutationZh)
                        card = pool[math.random(#pool)]
                    end
                    if card and mutationEn then
                        claimEvent:FireServer(card, rarityEn, mutationEn)
                    end
                    task.wait(0.5)
                end
            end)
        end
    end,
})

AutoTab:Section({ Title = "出售" })
AutoTab:Button({
    Title = "出售手持卡牌",
    Callback = function()
        if sellEvent then sellEvent:FireServer("Equipped") end
    end,
})
AutoTab:Button({
    Title = "出售背包全部",
    Callback = function()
        if sellEvent then sellEvent:FireServer("Inventory") end
    end,
})

Window:SelectTab(1)
