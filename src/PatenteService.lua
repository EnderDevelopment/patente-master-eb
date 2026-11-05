--[[
	PatenteService.lua
	ModuleScript that manages custom ranks (patentes) for players.
	Place in: ServerScriptService (as a ModuleScript)

	Usage:
		local PatenteService = require(script.Parent.PatenteService)
		PatenteService:SetPatente(player, "Coronel-Comandante")
]]

local Players = game:GetService("Players")
local DataStoreService = game:GetService("DataStoreService")

local PatenteService = {}

local DATASTORE_NAME = "EBResidencia_Patentes"
local MAX_LENGTH = 60

local patenteStore
local storeReady = false

local function initDataStore()
	local ok, result = pcall(function()
		patenteStore = DataStoreService:GetDataStore(DATASTORE_NAME)
		storeReady = true
	end)
	if not ok then
		warn("PatenteService: DataStore nao disponivel: " .. tostring(result))
		storeReady = false
	end
end

initDataStore()

-- In-memory fallback when DataStore is unavailable (e.g. Studio)
local cache = {}

--- Sets a custom rank (patente) for a player.
--- @param player Player The target player.
--- @param patente string Any text as the rank.
--- @return boolean success
--- @return string|nil errorMessage
function PatenteService:SetPatente(player, patente)
	if not player or not player:IsA("Player") then
		return false, "Jogador invalido."
	end

	patente = tostring(patente or ""):gsub("^%s+", ""):gsub("%s+$", "")
	if #patente == 0 then
		return false, "A patente nao pode estar vazia."
	end
	if #patente > MAX_LENGTH then
		return false, "A patente deve ter no maximo " .. MAX_LENGTH .. " caracteres."
	end

	local userId = tostring(player.UserId)
	cache[userId] = patente

	if storeReady and patenteStore then
		local ok, err = pcall(function()
			patenteStore:SetAsync(userId, patente)
		end)
		if not ok then
			warn("PatenteService: Falha ao salvar patente de " .. userId .. ": " .. tostring(err))
		end
	end

	player:SetAttribute("Patente", patente)

	return true, nil
end

--- Gets the current rank of a player.
--- @param player Player
--- @return string|nil
function PatenteService:GetPatente(player)
	if not player then
		return nil
	end
	local userId = tostring(player.UserId)
	return cache[userId] or player:GetAttribute("Patente")
end

--- Removes the rank from a player.
--- @param player Player
--- @return boolean success
function PatenteService:RemovePatente(player)
	if not player then
		return false
	end
	local userId = tostring(player.UserId)
	cache[userId] = nil
	if storeReady and patenteStore then
		pcall(function()
			patenteStore:RemoveAsync(userId)
		end)
	end
	player:SetAttribute("Patente", nil)
	return true
end

-- Load saved data on player join
local function onPlayerAdded(player)
	local userId = tostring(player.UserId)
	if storeReady and patenteStore then
		local ok, data = pcall(function()
			return patenteStore:GetAsync(userId)
		end)
		if ok and data then
			cache[userId] = data
			player:SetAttribute("Patente", data)
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

return PatenteService
