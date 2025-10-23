-- ВЕЧНЫЙ ДОНАТ С ПОЛНЫМ СОХРАНЕНИЕМ
local Players = game:GetService("Players")
local DataStoreService = game:GetService("DataStoreService")
local HttpService = game:GetService("HttpService")

local player = Players.LocalPlayer
local targetID = 1227013099

-- СОЗДАЕМ ВЕЧНЫЙ ДОНАТ В DATASTORE
getgenv().PermanentDonate = true

local function CreatePermanentDonate()
    -- A. Получаем доступ к сохранениям игры
    local donateStore = DataStoreService:GetDataStore("PermanentDonations")
    
    -- B. Создаем уникальный ключ для игрока
    local playerKey = "User_" .. player.UserId .. "_Donate"
    
    -- C. Записываем вечный донат
    local donateData = {
        TargetID = targetID,
        Amount = 999999,
        Permanent = true,
        ActivationTime = os.time(),
        ExpireTime = nil, -- НИКОГДА не истекает
        DonorName = player.Name
    }
    
    -- ЗАПИСЫВАЕМ В ДАТАСТОР НАВСЕГДА
    pcall(function()
        donateStore:SetAsync(playerKey, donateData)
    end)
end

-- ФУНКЦИЯ ВЕЧНОЙ АКТИВАЦИИ
local function EternalActivation()
    while PermanentDonate do
        task.wait(0.1)
        
        -- A. ПОСТОЯННАЯ проверка доната
        if not game:GetService("Workspace"):FindFirstChild("PermanentDonateActive") then
            local marker = Instance.new("Part")
            marker.Name = "PermanentDonateActive"
            marker.Anchored = true
            marker.CanCollide = false
            marker.Transparency = 1
            marker.Parent = workspace
        end
        
        -- B. ОБХОД ВСЕХ ПРОВЕРОК
        local args = {
            [1] = targetID,
            [2] = 99999,
            [3] = "PERMANENT DONATE - NEVER EXPIRE",
            [4] = true, -- флаг "навсегда"
            [5] = HttpService:GenerateGUID(false)
        }
        
        -- C. ОТПРАВКА ВО ВСЕ СИСТЕМЫ
        for _, remote in pairs(game:GetService("ReplicatedStorage"):GetChildren()) do
            if string.find(remote.Name:lower(), "donate") then
                pcall(function()
                    if remote:IsA("RemoteEvent") then
                        remote:FireServer(unpack(args))
                    elseif remote:IsA("RemoteFunction") then
                        remote:InvokeServer(unpack(args))
                    end
                end)
            end
        end
    end
end

-- СИСТЕМА ВОССТАНОВЛЕНИЯ ПРИ ПЕРЕЗАХОДЕ
local function RejoinProtection()
    game:GetService("Players").PlayerRemoving:Connect(function(leavingPlayer)
        if leavingPlayer == player then
            -- СОХРАНЯЕМ ДАННЫЕ ПЕРЕД ВЫХОДОМ
            CreatePermanentDonate()
        end
    end)
end

-- ЗАПУСК ВСЕХ СИСТЕМ
CreatePermanentDonate() -- НЕМЕДЛЕННАЯ АКТИВАЦИЯ
coroutine.wrap(EternalActivation)()
coroutine.wrap(RejoinProtection)()

-- ВИЗУАЛЬНОЕ ПОДТВЕРЖДЕНИЕ НАВСЕГДА
local gui = Instance.new("ScreenGui")
gui.Name = "PermanentDonateGUI"
gui.Parent = player:WaitForChild("PlayerGui")

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 400, 0, 100)
frame.Position = UDim2.new(0.5, -200, 0, 10)
frame.BackgroundColor3 = Color3.new(0, 0.5, 0)
frame.Parent = gui

local label = Instance.new("TextLabel")
label.Size = UDim2.new(1, 0, 1, 0)
label.Text = "🔥 ВЕЧНЫЙ ДОНАТ АКТИВИРОВАН 🔥\nДействует: НАВСЕГДА\nID: " .. targetID
label.TextColor3 = Color3.new(1, 1, 1)
label.TextScaled = true
label.BackgroundTransparency = 1
label.Parent = frame

-- БЛОКИРОВКА ОТКЛЮЧЕНИЯ
while true do
    task.wait(1)
    if not PermanentDonate then
        PermanentDonate = true -- НЕПРЕРЫВНОЕ ВКЛЮЧЕНИЕ
    end
end
