--[[
	DivisaoService.lua
	ModuleScript that manages custom divisions (divisoes) for players.
	Place in: ServerScriptService (as a ModuleScript)

	Usage:
		local DivisaoService = require(script.Parent.DivisaoService)
		DivisaoService:SetDivisao(player, "Forca Aerea")
]]

local Players = game:GetService("Players")
local DataStoreService = game:GetService("DataStoreService")

local DivisaoService = {}

local DATASTORE_NAME = "EBResidencia_Divisoes"
local MAX_LENGTH = 60

local divisaoStore
local storeReady = false

local function initDataStore()
	local ok, result = pcall(function()
		divisaoStore = DataStoreService:GetDataStore(DATASTORE_NAME)
		storeReady = true
	end)
	if not ok then
		warn("DivisaoService: DataStore nao disponivel: " .. tostring(result))
		storeReady = false
	end
end

initDataStore()

-- In-memory fallback when DataStore is unavailable (e.g. Studio)
local cache = {}

--- Assigns a division to a player.
--- @param player Player The target player.
--- @param divisao string Any text as the division.
--- @return boolean success
--- @return string|nil errorMessage
function DivisaoService:SetDivisao(player, divisao)
	if not player or not player:IsA("Player") then
		return false, "Jogador invalido."
	end

	divisao = tostring(divisao or ""):gsub("^%s+", ""):gsub("%s+$", "")
	if #divisao == 0 then
		return false, "A divisao nao pode estar vazia."
	end
	if #divisao > MAX_LENGTH then
		return false, "A divisao deve ter no maximo " .. MAX_LENGTH .. " caracteres."
	end

	local userId = tostring(player.UserId)
	cache[userId] = divisao

	if storeReady and divisaoStore then
		local ok, err = pcall(function()
			divisaoStore:SetAsync(userId, divisao)
		end)
		if not ok then
			warn("DivisaoService: Falha ao salvar divisao de " .. userId .. ": " .. tostring(err))
		end
	end

	player:SetAttribute("Divisao", divisao)

	return true, nil
end

--- Gets the current division of a player.
--- @param player Player
--- @return string|nil
function DivisaoService:GetDivisao(player)
	if not player then
		return nil
	end
	local userId = tostring(player.UserId)
	return cache[userId] or player:GetAttribute("Divisao")
end

--- Removes the division from a player.
--- @param player Player
--- @return boolean success
function DivisaoService:RemoveDivisao(player)
	if not player then
		return false
	end
	local userId = tostring(player.UserId)
	cache[userId] = nil
	if storeReady and divisaoStore then
		pcall(function()
			divisaoStore:RemoveAsync(userId)
		end)
	end
	player:SetAttribute("Divisao", nil)
	return true
end

-- Load saved data on player join
local function onPlayerAdded(player)
	local userId = tostring(player.UserId)
	if storeReady and divisaoStore then
		local ok, data = pcall(function()
			return divisaoStore:GetAsync(userId)
		end)
		if ok and data then
			cache[userId] = data
			player:SetAttribute("Divisao", data)
		end
	end
end

local function onPlayerRemoving(player)
	cache[tostring(player.UserId)] = nil
end

Players.PlayerAdded:Connect(onPlayerAdded)
Players.PlayerRemoving:Connect(onPlayerRemoving)

-- Load for players already in game (script may start after they joined)
for _, player in ipairs(Players:GetPlayers()) do
	onPlayerAdded(player)
end

return DivisaoService
