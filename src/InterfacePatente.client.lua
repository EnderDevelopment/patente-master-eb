--[[
	InterfacePatente.client.lua
	Client-side UI that shows the player's current patente (rank) and divisão.
	Place in: StarterPlayerScripts
]]

local Players = game:GetService("Players")

local player = Players.LocalPlayer

-- =========================================================
-- CONSTRUCAO DA GUI
-- =========================================================

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "PatenteGui"
screenGui.ResetOnSpawn = false
screenGui.IgnoreGuiInset = true
screenGui.Parent = player:WaitForChild("PlayerGui")

-- Background frame
local frame = Instance.new("Frame")
frame.Name = "PatenteFrame"
frame.AnchorPoint = Vector2.new(1, 0)
frame.Position = UDim2.new(1, -20, 0, 20)
frame.Size = UDim2.new(0, 240, 0, 90)
frame.BackgroundColor3 = Color3.fromRGB(20, 25, 40)
frame.BackgroundTransparency = 0.15
frame.BorderSizePixel = 0
frame.Parent = screenGui

local uiCorner = Instance.new("UICorner")
uiCorner.CornerRadius = UDim.new(0, 10)
uiCorner.Parent = frame

-- Title
local title = Instance.new("TextLabel")
title.Name = "Titulo"
title.AnchorPoint = Vector2.new(0.5, 0)
title.Position = UDim2.new(0.5, 0, 0, 8)
title.Size = UDim2.new(1, -20, 0, 20)
title.BackgroundTransparency = 1
title.Text = "EB DA RESIDENCIA"
title.TextColor3 = Color3.fromRGB(220, 180, 70)
title.TextScaled = true
title.Font = Enum.Font.GothamBold
title.Parent = frame

-- Patente label
local patenteLabel = Instance.new("TextLabel")
patenteLabel.Name = "PatenteLabel"
patenteLabel.AnchorPoint = Vector2.new(0.5, 0)
patenteLabel.Position = UDim2.new(0.5, 0, 0, 34)
patenteLabel.Size = UDim2.new(1, -20, 0, 20)
patenteLabel.BackgroundTransparency = 1
patenteLabel.Text = "Patente: Nenhuma"
patenteLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
patenteLabel.TextScaled = true
patenteLabel.Font = Enum.Font.Gotham
patenteLabel.Parent = frame

-- Divisao label
local divisaoLabel = Instance.new("TextLabel")
divisaoLabel.Name = "DivisaoLabel"
divisaoLabel.AnchorPoint = Vector2.new(0.5, 0)
divisaoLabel.Position = UDim2.new(0.5, 0, 0, 58)
divisaoLabel.Size = UDim2.new(1, -20, 0, 20)
divisaoLabel.BackgroundTransparency = 1
divisaoLabel.Text = "Divisao: Nenhuma"
divisaoLabel.TextColor3 = Color3.fromRGB(200, 220, 255)
divisaoLabel.TextScaled = true
divisaoLabel.Font = Enum.Font.GothamLight
divisaoLabel.Parent = frame

-- =========================================================
-- ATUALIZACAO DOS ATRIBUTOS
-- =========================================================

local function refreshDisplay()
	local patente = player:GetAttribute("Patente")
	local divisao = player:GetAttribute("Divisao")

	patenteLabel.Text = "Patente: " .. (patente or "Nenhuma")
	divisaoLabel.Text = "Divisao: " .. (divisao or "Nenhuma")
end

-- Update when attributes change
player:GetAttributeChangedSignal("Patente"):Connect(refreshDisplay)
player:GetAttributeChangedSignal("Divisao"):Connect(refreshDisplay)

-- Initial refresh (small delay so the server can set attributes)
task.wait(1)
refreshDisplay()
