--[[
  Universal Vehicle Script dengan proteksi anti-deteksi
  Versi aman dengan teknik obfuskasi dan bypass
]]

-- Obfuskasi dasar variabel
local _L = loadstring
local _H = game.HttpGet
local _G = game
local _P = _G:GetService("Players")
local _R = _G:GetService("RunService")
local _U = _G:GetService("UserInputService")
local _LP = _P.LocalPlayer
local _WS = _G:GetService("Workspace")

-- Mode stealth dan proteksi
local _StealthMode = (syn and true) or (getreg and true) or false
local _ModeratorPresent = false

-- Deteksi moderator
local function _CheckModerators()
    for _, player in ipairs(_P:GetPlayers()) do
        if player:GetRankInGroup(1) > 100 then -- Ganti dengan group ID yang sesuai
            _ModeratorPresent = true
            return
        end
    end
end

_CheckModerators()
_P.PlayerAdded:Connect(function(p)
    if p:GetRankInGroup(1) > 100 then
        _ModeratorPresent = true
    end
end)

-- Load library dengan proteksi
local VenyxLibrary = _L(_H(_G, "https://raw.githubusercontent.com/Documantation12/Universal-Vehicle-Script/main/Library.lua", true))()
local Venyx = VenyxLibrary.new("Vehicle Utilities", 5013109572)

-- Theme dengan warna acak untuk penyamaran
local Theme = {
    Background = Color3.fromRGB(61, 60, 124),
    Glow = Color3.fromRGB(60, 63, 221),
    Accent = Color3.fromRGB(55, 52, 90),
    LightContrast = Color3.fromRGB(64, 65, 128),
    DarkContrast = Color3.fromRGB(32, 33, 64),
    TextColor = Color3.fromRGB(255, 255, 255)
}

for index, value in pairs(Theme) do
    pcall(Venyx.setTheme, Venyx, index, value)
end

-- Fungsi utama dengan proteksi
local function _SafeGetVehicle(descendant)
    if not descendant or not _LP.Character then return nil end
    
    return descendant:FindFirstAncestor(_LP.Name .. "'s Car") or
           (descendant:FindFirstAncestor("Body") and descendant:FindFirstAncestor("Body").Parent or
           (descendant:FindFirstAncestor("Misc") and descendant:FindFirstAncestor("Misc").Parent) or
           descendant:FindFirstAncestorWhichIsA("Model")
end

local function _SafeTeleport(cframe)
    if _ModeratorPresent or not _StealthMode then return end
    
    local success, result = pcall(function()
        local char = _LP.Character
        if not char then return end
        
        local humanoid = char:FindFirstChildWhichIsA("Humanoid")
        if not humanoid then return end
        
        local seat = humanoid.SeatPart
        if not seat then return end
        
        local vehicle = _SafeGetVehicle(seat)
        if not vehicle then return end
        
        char.Parent = vehicle
        
        local primary = vehicle:FindFirstChild("PrimaryPart") or vehicle:FindFirstChildWhichIsA("BasePart")
        if primary then
            vehicle:SetPrimaryPartCFrame(cframe)
        else
            vehicle:PivotTo(cframe)
        end
    end)
    
    if not success then
        warn("Teleport failed:", result)
    end
end

-- Implementasi fitur dengan proteksi
local vehiclePage = Venyx:addPage("Vehicle Controls", 8356815386)
local usageSection = vehiclePage:addSection("Main Controls")

local _KeybindsActive = true
usageSection:addToggle("Enable Keybinds", _KeybindsActive, function(v)
    if _ModeratorPresent then 
        _KeybindsActive = false
        return 
    end
    _KeybindsActive = v
end)

-- Flight system dengan proteksi
local flightSection = vehiclePage:addSection("Flight System")
local _FlightEnabled = false
local _FlightSpeed = 1

flightSection:addToggle("Flight Mode", false, function(v)
    if _ModeratorPresent then 
        _FlightEnabled = false
        return 
    end
    _FlightEnabled = v and _StealthMode
end)

flightSection:addSlider("Flight Speed", 100, 0, 800, function(v)
    _FlightSpeed = v / 100
end)

-- Velocity controls dengan proteksi
local speedSection = vehiclePage:addSection("Speed Controls")
local _VelocityMult = 0.025
speedSection:addSlider("Speed Multiplier", 25, 0, 50, function(v)
    _VelocityMult = v / 1000
end)

local _DefaultCharParent
local _LastCheck = 0

_R.Stepped:Connect(function()
    if _ModeratorPresent or not _StealthMode then return end
    
    -- Batasi pemeriksaan untuk mengurangi beban CPU
    if time() - _LastCheck > 5 then
        _CheckModerators()
        _LastCheck = time()
    end
    
    local char = _LP.Character
    if not char then return end
    
    local humanoid = char:FindFirstChildWhichIsA("Humanoid")
    if not humanoid then return end
    
    local seat = humanoid.SeatPart
    if not seat or not seat:IsA("VehicleSeat") then
        if _DefaultCharParent then
            char.Parent = _DefaultCharParent
        end
        return
    end
    
    -- Simpan parent default
    if not _DefaultCharParent then
        _DefaultCharParent = char.Parent
    end
    
    -- Flight system
    if _FlightEnabled then
        char.Parent = _SafeGetVehicle(seat) or char.Parent
        
        local vehicle = _SafeGetVehicle(seat)
        if vehicle then
            if not vehicle.PrimaryPart then
                vehicle.PrimaryPart = seat.Parent == vehicle and seat or vehicle:FindFirstChildWhichIsA("BasePart")
            end
            
            if vehicle.PrimaryPart then
                local cam = workspace.CurrentCamera
                if cam then
                    local look = cam.CFrame.LookVector
                    local pos = vehicle.PrimaryPart.Position
                    
                    local moveX = (_U:IsKeyDown(Enum.KeyCode.D) and _FlightSpeed) or (_U:IsKeyDown(Enum.KeyCode.A) and -_FlightSpeed) or 0
                    local moveY = (_U:IsKeyDown(Enum.KeyCode.E) and _FlightSpeed/2) or (_U:IsKeyDown(Enum.KeyCode.Q) and -_FlightSpeed/2) or 0
                    local moveZ = (_U:IsKeyDown(Enum.KeyCode.S) and _FlightSpeed or (_U:IsKeyDown(Enum.KeyCode.W) and -_FlightSpeed) or 0
                    
                    vehicle:SetPrimaryPartCFrame(CFrame.new(pos, pos + look) * CFrame.new(moveX, moveY, moveZ))
                end
            end
            
            seat.AssemblyLinearVelocity = Vector3.zero
            seat.AssemblyAngularVelocity = Vector3.zero
        end
    else
        char.Parent = _DefaultCharParent or char.Parent
    end
end)

-- Keybind system dengan proteksi
local _VelocityKey = Enum.KeyCode.W
local _BrakeKey = Enum.KeyCode.S
local _StopKey = Enum.KeyCode.P

speedSection:addKeybind("Accelerate", _VelocityKey, function()
    if not _KeybindsActive or _ModeratorPresent then return end
    
    while _U:IsKeyDown(_VelocityKey) and _KeybindsActive and _StealthMode do
        task.wait()
        local seat = _LP.Character and _LP.Character:FindFirstChildWhichIsA("Humanoid") and _LP.Character:FindFirstChildWhichIsA("Humanoid").SeatPart
        if seat and seat:IsA("VehicleSeat") then
            seat.AssemblyLinearVelocity = seat.AssemblyLinearVelocity * Vector3.new(1 + _VelocityMult, 1, 1 + _VelocityMult)
        end
    end
end, function(v) _VelocityKey = v.KeyCode end)

-- Brake system
local _BrakeMult = 0.15
local brakeSection = vehiclePage:addSection("Brake Controls")
brakeSection:addSlider("Brake Force", _BrakeMult*1000, 0, 300, function(v)
    _BrakeMult = v / 1000
end)

brakeSection:addKeybind("Brake", _BrakeKey, function()
    if not _KeybindsActive or _ModeratorPresent then return end
    
    while _U:IsKeyDown(_BrakeKey) and _KeybindsActive and _StealthMode do
        task.wait()
        local seat = _LP.Character and _LP.Character:FindFirstChildWhichIsA("Humanoid") and _LP.Character:FindFirstChildWhichIsA("Humanoid").SeatPart
        if seat and seat:IsA("VehicleSeat") then
            seat.AssemblyLinearVelocity = seat.AssemblyLinearVelocity * Vector3.new(1 - _BrakeMult, 1, 1 - _BrakeMult)
        end
    end
end, function(v) _BrakeKey = v.KeyCode end)

brakeSection:addKeybind("Instant Stop", _StopKey, function()
    if not _KeybindsActive or _ModeratorPresent then return end
    
    local seat = _LP.Character and _LP.Character:FindFirstChildWhichIsA("Humanoid") and _LP.Character:FindFirstChildWhichIsA("Humanoid").SeatPart
    if seat and seat:IsA("VehicleSeat") then
        seat.AssemblyLinearVelocity = Vector3.zero
        seat.AssemblyAngularVelocity = Vector3.zero
    end
end)

-- Spring visibility toggle
local springSection = vehiclePage:addSection("Visuals")
springSection:addToggle("Show Springs", false, function(v)
    if _ModeratorPresent then return end
    
    local seat = _LP.Character and _LP.Character:FindFirstChildWhichIsA("Humanoid") and _LP.Character:FindFirstChildWhichIsA("Humanoid").SeatPart
    if seat then
        local vehicle = _SafeGetVehicle(seat)
        if vehicle then
            for _, spring in ipairs(vehicle:GetDescendants()) do
                if spring:IsA("SpringConstraint") then
                    spring.Visible = v
                end
            end
        end
    end
end)

-- Game-specific features dengan proteksi
local function _AddGameSpecificFeatures()
    local placeId = _G.PlaceId
    
    -- Wayfort (Driving Empire)
    if placeId == 3351674303 then
        local wayfortPage = Venyx:addPage("Wayfort", 8357222903)
        local dealershipSection = wayfortPage:addSection("Dealership Teleport")
        
        local dealerships = {}
        local success, result = pcall(function()
            return _WS:WaitForChild("Game"):WaitForChild("Dealerships"):WaitForChild("Dealerships"):GetChildren()
        end)
        
        if success then
            for _, dealer in ipairs(result) do
                table.insert(dealerships, dealer.Name)
            end
        end
        
        dealershipSection:addDropdown("Select Dealership", dealerships, function(v)
            if _ModeratorPresent then return end
            pcall(function()
                _G:GetService("ReplicatedStorage").Remotes.Location:FireServer("Enter", v)
            end)
        end)
    end
end

-- Delay game-specific features untuk menghindari deteksi
task.spawn(function()
    wait(5) -- Tunggu game sepenuhnya load
    if not _ModeratorPresent then
        _AddGameSpecificFeatures()
    end
end)

-- GUI toggle dengan proteksi
local function _ToggleGUI()
    if _ModeratorPresent then return end
    Venyx:toggle()
end

_U.InputBegan:Connect(function(input, processed)
    if processed or _ModeratorPresent then return end
    if input.KeyCode == Enum.KeyCode.RightBracket then
        _ToggleGUI()
    end
end)

-- Anti-kick protection (hanya di environment yang mendukung)
if _StealthMode then
    local originalKick = _LP.Kick
    _LP.Kick = function(self, ...)
        warn("[Protection] Kick attempt blocked")
        return
    end
end

-- Final setup message
print("[Vehicle Utilities] Loaded successfully in stealth mode:", _StealthMode)