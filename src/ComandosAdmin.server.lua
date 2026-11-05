--[[
	ComandosAdmin.server.lua
	Admin commands to give custom ranks (patentes) and divisions (divisões).
	Place in: ServerScriptService

	Usage in chat (prefix "!"):
	  !patente <nome> <patente personalizada>
	  !divisao <nome> <divisao personalizada>
	  !remover-patente <nome>
	  !remover-divisao <nome>
	  !minha-patente
]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

-- =========================================================
-- CONFIGURACAO
-- =========================================================

-- UserId dos administradores autorizados.
-- Substitua pelos IDs reais dos seus admins.
local ADMIN_IDS = {
	-- [123456789] = true,  -- exemplo
	-- [987654321] = true,
}

-- Comando de chat. Para desativar todos os comandos, use um valor vazio: ""
local COMMAND_PREFIX = "!"

-- =========================================================
-- SERVICOS
-- =========================================================

local PatenteService = require(script.Parent:WaitForChild("PatenteService"))
local DivisaoService = require(script.Parent:WaitForChild("DivisaoService"))

-- =========================================================
-- FUNCOES AUXILIARES
-- =========================================================

local function isAdmin(player)
	local userId = player.UserId
	if ADMIN_IDS[userId] then
		return true
	end
	-- Allow the place owner / game creator
	local creatorId = game.CreatorId
	if userId == creatorId then
		return true
	end
	return false
end

local function resolvePlayer(name)
	local lowerName = name:lower()
	local exactMatch = Players:FindFirstChild(name)
	if exactMatch then
		return exactMatch
	end
	for _, player in ipairs(Players:GetPlayers()) do
		if player.Name:lower() == lowerName or player.DisplayName:lower() == lowerName then
			return player
		end
	end
	return nil
end

local function notify(player, message, color)
	color = color or Color3.fromRGB(255, 255, 255)
	-- Use a floating label that fades out, avoiding the deprecated Message class
	local playerGui = player:WaitForChild("PlayerGui")

	local notificationGui = Instance.new("ScreenGui")
	notificationGui.Name = "Notificacao"
	notificationGui.ResetOnSpawn = false
	notificationGui.IgnoreGuiInset = true
	notificationGui.Parent = playerGui

	local label = Instance.new("TextLabel")
	label.AnchorPoint = Vector2.new(0.5, 0)
	label.Position = UDim2.new(0.5, 0, 0, 120)
	label.Size = UDim2.new(0, 400, 0, 40)
	label.BackgroundColor3 = Color3.fromRGB(20, 25, 40)
	label.BackgroundTransparency = 0.2
	label.BorderSizePixel = 0
	label.Text = message
	label.TextColor3 = color
	label.TextScaled = true
	label.Font = Enum.Font.GothamBold
	label.Parent = notificationGui

	local uiCorner = Instance.new("UICorner")
	uiCorner.CornerRadius = UDim.new(0, 8)
	uiCorner.Parent = label

	game:GetService("TweenService"):Create(label, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
		Position = UDim2.new(0.5, 0, 0, 130),
		BackgroundTransparency = 0
	}):Play()

	game:GetService("Debris"):AddItem(notificationGui, 6)
end

local function broadcast(message, color)
	for _, player in ipairs(Players:GetPlayers()) do
		notify(player, message, color)
	end
end

local function startsWithCommand(message)
	if COMMAND_PREFIX == "" then
		return false  -- commands disabled
	end
	return message:sub(1, #COMMAND_PREFIX) == COMMAND_PREFIX
end

-- =========================================================
-- PROCESSAMENTO DE COMANDOS
-- =========================================================

local function processCommand(player, message)
	-- Escape Lua pattern special characters in the prefix
	local escapedPrefix = COMMAND_PREFIX:gsub("([%^%$%(%)%%%.%[%]%*%+%-%?])", "%%%1")
	local text = message:gsub("^" .. escapedPrefix, "")
	local parts = {}
	for part in string.gmatch(text, "%S+") do
		table.insert(parts, part)
	end

	if #parts == 0 then
		return
	end

	local command = parts[1]:lower()

	-- !minha-patente : jogador vê a própria patente/divisão
	if command == "minha-patente" then
		local patente = PatenteService:GetPatente(player) or "Nenhuma"
		local divisao = DivisaoService:GetDivisao(player) or "Nenhuma"
		notify(player, "Sua patente: " .. patente .. " | Sua divisao: " .. divisao, Color3.fromRGB(0, 255, 170))
		return
	end

	-- Todos os demais comandos exigem admin
	if not isAdmin(player) then
		notify(player, "Voce nao tem permissao para usar este comando.", Color3.fromRGB(255, 80, 80))
		return
	end

	if command == "patente" then
		-- !patente <nome> <patente...>
		if #parts < 3 then
			notify(player, "Uso: " .. COMMAND_PREFIX .. "patente <nome> <patente>", Color3.fromRGB(255, 200, 0))
			return
		end
		local targetName = parts[2]
		local patente = table.concat(parts, " ", 3)
		local target = resolvePlayer(targetName)
		if not target then
			notify(player, "Jogador '" .. targetName .. "' nao encontrado.", Color3.fromRGB(255, 80, 80))
			return
		end
		local ok, err = PatenteService:SetPatente(target, patente)
		if ok then
			broadcast("[" .. player.DisplayName .. "] concedeu a patente '" .. patente .. "' a " .. target.DisplayName, Color3.fromRGB(0, 255, 170))
		else
			notify(player, "Erro: " .. tostring(err), Color3.fromRGB(255, 80, 80))
		end
		return
	end

	if command == "divisao" then
		-- !divisao <nome> <divisao...>
		if #parts < 3 then
			notify(player, "Uso: " .. COMMAND_PREFIX .. "divisao <nome> <divisao>", Color3.fromRGB(255, 200, 0))
			return
		end
		local targetName = parts[2]
		local divisao = table.concat(parts, " ", 3)
		local target = resolvePlayer(targetName)
		if not target then
			notify(player, "Jogador '" .. targetName .. "' nao encontrado.", Color3.fromRGB(255, 80, 80))
			return
		end
		local ok, err = DivisaoService:SetDivisao(target, divisao)
		if ok then
			broadcast("[" .. player.DisplayName .. "] colocou " .. target.DisplayName .. " na divisao '" .. divisao .. "'", Color3.fromRGB(0, 170, 255))
		else
			notify(player, "Erro: " .. tostring(err), Color3.fromRGB(255, 80, 80))
		end
		return
	end

	if command == "remover-patente" then
		if #parts < 2 then
			notify(player, "Uso: " .. COMMAND_PREFIX .. "remover-patente <nome>", Color3.fromRGB(255, 200, 0))
			return
		end
		local target = resolvePlayer(parts[2])
		if not target then
			notify(player, "Jogador nao encontrado.", Color3.fromRGB(255, 80, 80))
			return
		end
		PatenteService:RemovePatente(target)
		notify(player, "Patente de " .. target.DisplayName .. " removida.", Color3.fromRGB(0, 255, 170))
		return
	end

	if command == "remover-divisao" then
		if #parts < 2 then
			notify(player, "Uso: " .. COMMAND_PREFIX .. "remover-divisao <nome>", Color3.fromRGB(255, 200, 0))
			return
		end
		local target = resolvePlayer(parts[2])
		if not target then
			notify(player, "Jogador nao encontrado.", Color3.fromRGB(255, 80, 80))
			return
		end
		DivisaoService:RemoveDivisao(target)
		notify(player, "Divisao de " .. target.DisplayName .. " removida.", Color3.fromRGB(0, 255, 170))
		return
	end

	-- Comando desconhecido
	notify(player, "Comando desconhecido. Use '!patente', '!divisao', '!remover-patente', '!remover-divisao' ou '!minha-patente'.", Color3.fromRGB(255, 80, 80))
end

-- =========================================================
-- CARREGAMENTO
-- =========================================================

if RunService:IsServer() then
	Players.PlayerAdded:Connect(function(player)
		player.Chatted:Connect(function(message)
			if startsWithCommand(message) then
				processCommand(player, message)
			end
		end)
	end)

	for _, player in ipairs(Players:GetPlayers()) do
		player.Chatted:Connect(function(message)
			if startsWithCommand(message) then
				processCommand(player, message)
			end
		end)
	end
end
