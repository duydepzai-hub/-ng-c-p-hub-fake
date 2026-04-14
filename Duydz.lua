-- [[ 1. KÍCH HOẠT AUTO ATTACK PREMIUM V6 ]]
pcall(function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/duydepzai-hub/Duydepzaihub-PREMIUMv6/refs/heads/main/bananacat-duydepzai%3F.lua"))()
end)

-- [[ 2. KHỞI TẠO UI GLOW (DRAGGABLE FIX) ]]
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")

if CoreGui:FindFirstChild("DuyHub_Final_Drag") then CoreGui.DuyHub_Final_Drag:Destroy() end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "DuyHub_Final_Drag"
ScreenGui.Parent = CoreGui
ScreenGui.ResetOnSpawn = false

-- HÀM LÀM UI KÉO ĐƯỢC (CHUYÊN NGHIỆP)
local function MakeDraggable(gui)
    local dragging, dragInput, dragStart, startPos
    gui.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = gui.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then dragging = false end
            end)
        end
    end)
    gui.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            gui.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
end

-- NÚT MỞ MENU (KÉO THOẢI MÁI)
local ToggleButton = Instance.new("TextButton")
ToggleButton.Parent = ScreenGui
ToggleButton.BackgroundColor3 = Color3.fromRGB(0, 200, 255)
ToggleButton.Position = UDim2.new(0, 50, 0, 50)
ToggleButton.Size = UDim2.new(0, 60, 0, 60)
ToggleButton.Text = "DY"
ToggleButton.Font = Enum.Font.GothamBold
ToggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleButton.TextSize = 20
Instance.new("UICorner", ToggleButton).CornerRadius = UDim.new(1, 0)
MakeDraggable(ToggleButton)

-- KHUNG MENU CHÍNH
local MainFrame = Instance.new("Frame")
MainFrame.Parent = ScreenGui
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
MainFrame.Position = UDim2.new(0.5, -110, 0.5, -175)
MainFrame.Size = UDim2.new(0, 220, 0, 350)
MainFrame.Visible = false
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 10)
MakeDraggable(MainFrame)

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 40)
Title.Text = "TELEPORT PRO - DY"
Title.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
Title.TextColor3 = Color3.fromRGB(0, 200, 255)
Title.Font = Enum.Font.GothamBold
Title.Parent = MainFrame
Instance.new("UICorner", Title).CornerRadius = UDim.new(0, 10)

local Container = Instance.new("ScrollingFrame")
Container.Parent = MainFrame
Container.Position = UDim2.new(0, 10, 0, 50)
Container.Size = UDim2.new(1, -20, 1, -60)
Container.BackgroundTransparency = 1
Container.ScrollBarThickness = 0
Container.CanvasSize = UDim2.new(0, 0, 1.4, 0)

local Layout = Instance.new("UIListLayout")
Layout.Parent = Container
Layout.Padding = UDim.new(0, 10)

-- [[ 3. BIẾN ĐIỀU KHIỂN ]]
_G.AutoFarmNear = false
_G.AutoStalk = false
_G.TargetName = ""
_G.LockedPlayer = nil
_G.FarmHeight = 15
local Player = game:GetService("Players").LocalPlayer

-- [[ 4. HÀM TẠO WIDGET ]]
local function NewToggle(name, color, callback)
    local b = Instance.new("TextButton")
    b.Size = UDim2.new(1, 0, 0, 38)
    b.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    b.Text = name .. ": OFF"
    b.TextColor3 = Color3.fromRGB(255, 255, 255)
    b.Parent = Container
    Instance.new("UICorner", b).CornerRadius = UDim.new(0, 6)
    local active = false
    b.MouseButton1Click:Connect(function()
        active = not active
        b.Text = active and name .. ": ON" or name .. ": OFF"
        b.BackgroundColor3 = active and color or Color3.fromRGB(35, 35, 35)
        callback(active, b)
    end)
end

local function NewInput(label, default, callback)
    local i = Instance.new("TextBox")
    i.Size = UDim2.new(1, 0, 0, 35)
    i.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    i.Text = tostring(default)
    i.PlaceholderText = label
    i.TextColor3 = Color3.fromRGB(255, 255, 255)
    i.Parent = Container
    Instance.new("UICorner", i).CornerRadius = UDim.new(0, 6)
    i.FocusLost:Connect(function() callback(i.Text) end)
end

local Status = Instance.new("TextLabel")
Status.Size = UDim2.new(1, 0, 0, 20)
Status.Text = "Target: None"
Status.TextColor3 = Color3.fromRGB(150, 150, 150)
Status.BackgroundTransparency = 1
Status.Parent = Container

-- [[ 5. CÀI ĐẶT MENU ]]
NewToggle("Auto Farm (Teleport)", Color3.fromRGB(0, 150, 255), function(v) _G.AutoFarmNear = v end)
NewInput("Nhập tên người chơi...", "", function(v) _G.TargetName = v end)
NewToggle("Ghim Theo Tên", Color3.fromRGB(0, 200, 100), function(v, b)
    _G.AutoStalk = v
    if v then
        local found = nil
        for _, p in pairs(game.Players:GetPlayers()) do
            if p.Name:lower():find(_G.TargetName:lower()) and p ~= Player then found = p; break end
        end
        if found then _G.LockedPlayer = found; Status.Text = "Đang ghim: " .. found.Name
        else _G.AutoStalk = false; b.Text = "Ghim Theo Tên: OFF"; b.BackgroundColor3 = Color3.fromRGB(35, 35, 35) end
    else _G.LockedPlayer = nil; Status.Text = "Target: None" end
end)
NewToggle("Ghim Ngẫu Nhiên", Color3.fromRGB(200, 100, 0), function(v)
    _G.AutoStalk = v
    if v then
        local plrs = {}
        for _, p in pairs(game.Players:GetPlayers()) do if p ~= Player then table.insert(plrs, p) end end
        if #plrs > 0 then _G.LockedPlayer = plrs[math.random(1, #plrs)]; Status.Text = "Ghim: " .. _G.LockedPlayer.Name
        else _G.AutoStalk = false end
    else _G.LockedPlayer = nil; Status.Text = "Target: None" end
end)
NewInput("Độ cao (0-50)", 15, function(v) _G.FarmHeight = tonumber(v) or 15 end)

ToggleButton.MouseButton1Click:Connect(function() MainFrame.Visible = not MainFrame.Visible end)

-- [[ 6. LOGIC DỊCH CHUYỂN TỨC THỜI ]]
task.spawn(function()
    while task.wait() do
        pcall(function()
            local character = Player.Character
            if not character or not character:FindFirstChild("HumanoidRootPart") then return end
            if _G.AutoFarmNear then
                local Target = nil
                local Dist = math.huge
                for _, v in pairs(game:GetService("Workspace").Enemies:GetChildren()) do
                    if v:FindFirstChild("HumanoidRootPart") and v.Humanoid.Health > 0 then
                        local m = (character.HumanoidRootPart.Position - v.HumanoidRootPart.Position).Magnitude
                        if m < Dist then Dist = m; Target = v end
                    end
                end
                if Target then character.HumanoidRootPart.CFrame = Target.HumanoidRootPart.CFrame * CFrame.new(0, _G.FarmHeight, 0) end
            elseif _G.AutoStalk and _G.LockedPlayer then
                if _G.LockedPlayer.Parent == nil then _G.LockedPlayer = nil; return end
                local tChar = _G.LockedPlayer.Character
                if tChar and tChar:FindFirstChild("HumanoidRootPart") then
                    character.HumanoidRootPart.CFrame = tChar.HumanoidRootPart.CFrame * CFrame.new(0, _G.FarmHeight, 0)
                end
            end
        end)
    end
end)
