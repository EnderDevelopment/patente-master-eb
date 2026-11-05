--[[
	InterfaceDivisao.client.lua
	Client-side script that provides a quick way for the local player to see
	their current division (divisão), and displays a badge in the top-left.
	Place in: StarterPlayerScripts
]]

local Players = game:GetService("Players")

local player = Players.LocalPlayer

-- =========================================================
-- CONSTRUCAO DA GUI (top-left badge for divisão)
-- =========================================================

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "DivisaoGui"
screenGui.ResetOnSpawn = false
screenGui.IgnoreGuiInset = true
screenGui.Parent = player:WaitForChild("PlayerGui")

local frame = Instance.new("Frame")
frame.Name = "DivisaoFrame"
frame.AnchorPoint = Vector2.new(0, 0)
frame.Position = UDim2.new(0, 20, 0, 20)
frame.Size = UDim2.new(0, 180, 0, 36)
frame.BackgroundColor3 = Color3.fromRGB(10, 15, 30)
frame.BackgroundTransparency = 0.2
frame.BorderSizePixel = 0
frame.Parent = screenGui

local uiCorner = Instance.new("UICorner")
uiCorner.CornerRadius = UDim.new(0, 8)
uiCorner.Parent = frame

-- Small color bar on the left (division accent)
local accentBar = Instance.new("Frame")
accentBar.Name = "AccentBar"
accentBar.Size = UDim2.new(0, 4, 1, 0)
accentBar.BackgroundColor3 = Color3.fromRGB(70, 170, 255)
accentBar.BorderSizePixel = 0
accentBar.Parent = frame

local uiCornerBar = Instance.new("UICorner")
uiCornerBar.CornerRadius = UDim.new(0, 4)
uiCornerBar.Parent = accentBar

local divisaoLabel = Instance.new("TextLabel")
divisaoLabel.Name = "DivisaoLabel"
divisaoLabel.AnchorPoint = Vector2.new(0.5, 0.5)
divisaoLabel.Position = UDim2.new(0.5, 6, 0.5, 0)
divisaoLabel.Size = UDim2.new(1, -30, 1, -8)
divisaoLabel.BackgroundTransparency = 1
divisaoLabel.Text = "Divisao: Nenhuma"
divisaoLabel.TextColor3 = Color3.fromRGB(200, 220, 255)
divisaoLabel.TextScaled = true
divisaoLabel.Font = Enum.Font.Gotham
divisaoLabel.Parent = frame

-- =========================================================
-- ATUALIZACAO
-- =========================================================

local function refreshDisplay()
	local divisao = player:GetAttribute("Divisao")
	divisaoLabel.Text = "Divisao: " .. (divisao or "Nenhuma")
end

player:GetAttributeChangedSignal("Divisao"):Connect(refreshDisplay)

task.wait(1)
refreshDisplay()
