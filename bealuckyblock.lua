local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
local SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/SaveManager.lua"))()
local InterfaceManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/InterfaceManager.lua"))()

local AUTHOR_IDS = {
    7483594265
}

task.spawn(function()
    local removedCount = 0

    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj.Name == "STARTER_PACK" then
            pcall(function()
                obj:Destroy()
                removedCount = removedCount + 1
            end)
        end
    end

    local playerGui = game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui")
    if playerGui then
        local hudFolder = playerGui:FindFirstChild("HUD") or playerGui:FindFirstChild("Hud")
        if hudFolder then
            for _, obj in ipairs(hudFolder:GetDescendants()) do
                if obj.Name == "STARTER_PACK" then
                    pcall(function()
                        obj:Destroy()
                        removedCount = removedCount + 1
                    end)
                end
            end
        end
    end

    if removedCount > 0 then
        print(string.format("✅ 自动清理完成：删除 %d 个 STARTER_PACK 文件", removedCount))
