local ESX = nil
local QBCore = nil

-- Initialize framework
if Config.Framework == "esx" then
    ESX = exports["es_extended"]:getSharedObject()
elseif Config.Framework == "qb-core" then
    QBCore = exports['qb-core']:GetCoreObject()
end

-- Permission check 
function isAdmin(source)
    if Config.Framework == "esx" then
        local xPlayer = ESX.GetPlayerFromId(source)
        if not xPlayer then return false end
        local group = xPlayer.getGroup()
        return (group == 'admin' or group == 'superadmin')

    elseif Config.Framework == "qb-core" then
        local Player = QBCore.Functions.GetPlayer(source)
        if not Player then return false end
        return QBCore.Functions.HasPermission(source, 'admin') or QBCore.Functions.HasPermission(source, 'god')
    end

    return false
end

local function HasPermission(source)
    if isAdmin(source) then
        
        return true
    else
     
        return false
    end
end


local function GetAllPlayers()
    local players = {}
    
    if Config.Framework == "esx" then
        local xPlayers = ESX.GetPlayers()
        for i = 1, #xPlayers, 1 do
            local xPlayer = ESX.GetPlayerFromId(xPlayers[i])
            if xPlayer then
                table.insert(players, {
                    id = xPlayer.source,
                    identifier = xPlayer.identifier,
                    name = xPlayer.getName(),
                    money = xPlayer.getMoney(),
                    bank = xPlayer.getAccount('bank').money,
                    job = xPlayer.job.name,
                    jobLabel = xPlayer.job.label,
                    grade = xPlayer.job.grade,
                    gradeLabel = xPlayer.job.grade_label
                })
            end
        end
    elseif Config.Framework == "qb-core" then
        local Players = QBCore.Functions.GetPlayers()
        for _, v in pairs(Players) do
            local Player = QBCore.Functions.GetPlayer(v)
            if Player then
                table.insert(players, {
                    id = Player.PlayerData.source,
                    identifier = Player.PlayerData.citizenid,
                    name = Player.PlayerData.charinfo.firstname .. " " .. Player.PlayerData.charinfo.lastname,
                    money = Player.PlayerData.money.cash,
                    bank = Player.PlayerData.money.bank,
                    job = Player.PlayerData.job.name,
                    jobLabel = Player.PlayerData.job.label,
                    grade = Player.PlayerData.job.grade.level,
                    gradeLabel = Player.PlayerData.job.grade.name
                })
            end
        end
    end
    
    return players
end

local function GetPlayerDetails(source, targetId)
    if Config.Framework == "esx" then
        local xPlayer = ESX.GetPlayerFromId(tonumber(targetId))
        if xPlayer then
            return {
                id = xPlayer.source,
                identifier = xPlayer.identifier,
                name = xPlayer.getName(),
                money = xPlayer.getMoney(),
                bank = xPlayer.getAccount('bank').money,
                job = xPlayer.job.name,
                jobLabel = xPlayer.job.label,
                grade = xPlayer.job.grade,
                gradeLabel = xPlayer.job.grade_label,
                group = xPlayer.getGroup(),
                accounts = {}
            }
        end
    elseif Config.Framework == "qb-core" then
        local Player = QBCore.Functions.GetPlayer(tonumber(targetId))
        if Player then
            return {
                id = Player.PlayerData.source,
                identifier = Player.PlayerData.citizenid,
                name = Player.PlayerData.charinfo.firstname .. " " .. Player.PlayerData.charinfo.lastname,
                money = Player.PlayerData.money.cash,
                bank = Player.PlayerData.money.bank,
                job = Player.PlayerData.job.name,
                jobLabel = Player.PlayerData.job.label,
                grade = Player.PlayerData.job.grade.level,
                gradeLabel = Player.PlayerData.job.grade.name,
                group = Player.PlayerData.metadata.gang or "none"
            }
        end
    end
    return nil
end

local function UpdatePlayerMoney(targetId, moneyType, amount)
    if Config.Framework == "esx" then
        local xPlayer = ESX.GetPlayerFromId(tonumber(targetId))
        if xPlayer then
            if moneyType == "cash" then
                xPlayer.addMoney(tonumber(amount))
            elseif moneyType == "bank" then
                xPlayer.addAccountMoney('bank', tonumber(amount))
            end
            return true
        end
    elseif Config.Framework == "qb-core" then
        local Player = QBCore.Functions.GetPlayer(tonumber(targetId))
        if Player then
            if moneyType == "cash" then
                Player.Functions.AddMoney("cash", tonumber(amount))
            elseif moneyType == "bank" then
                Player.Functions.AddMoney("bank", tonumber(amount))
            end
            return true
        end
    end
    return false
end

local function SetPlayerMoney(targetId, moneyType, amount)
    if Config.Framework == "esx" then
        local xPlayer = ESX.GetPlayerFromId(tonumber(targetId))
        if xPlayer then
            if moneyType == "cash" then
                xPlayer.setMoney(tonumber(amount))
            elseif moneyType == "bank" then
                xPlayer.setAccountMoney('bank', tonumber(amount))
            end
            return true
        end
    elseif Config.Framework == "qb-core" then
        local Player = QBCore.Functions.GetPlayer(tonumber(targetId))
        if Player then
            if moneyType == "cash" then
                Player.Functions.SetMoney("cash", tonumber(amount))
            elseif moneyType == "bank" then
                Player.Functions.SetMoney("bank", tonumber(amount))
            end
            return true
        end
    end
    return false
end

local function IsQuerySafe(query)
    if not Config.AllowSQL then
        return false, "SQL Editor is disabled"
    end
    
    if string.len(query) > Config.SQLMaxQueryLength then
        return false, "Query too long"
    end
    
    local upperQuery = string.upper(query)
    for _, keyword in ipairs(Config.SQLBlockedKeywords) do
        if string.find(upperQuery, keyword) then
            return false, "Blocked keyword: " .. keyword
        end
    end
    
    return true, nil
end

local function GetServerStatistics()
    local stats = {
        totalPlayers = 0,
        onlinePlayers = 0,
        totalCash = 0,
        totalBank = 0,
        jobs = {},
        sexInfo = {male = 0, female = 0, total = 0}
    }
    
    if Config.Framework == "esx" then
        local xPlayers = ESX.GetPlayers()
        stats.onlinePlayers = #xPlayers
        
        if Config.Database == "oxmysql" then
            local result = exports.oxmysql:querySync('SELECT * FROM users', {})
            if result then
                stats.totalPlayers = #result
                for _, user in ipairs(result) do
                    local accounts = {}
                    if user.accounts then
                        if type(user.accounts) == "string" then
                            accounts = json.decode(user.accounts)
                        else
                            accounts = user.accounts
                        end
                    end
                    if accounts and accounts.bank then
                        stats.totalBank = stats.totalBank + (accounts.bank or 0)
                    end
                    if accounts and accounts.money then
                        stats.totalCash = stats.totalCash + (accounts.money or 0)
                    end
                    
                    local sex = user.sex
                    if sex == "m" or sex == "male" then
                        stats.sexInfo.male = stats.sexInfo.male + 1
                    elseif sex == "f" or sex == "female" then
                        stats.sexInfo.female = stats.sexInfo.female + 1
                    end
                    stats.sexInfo.total = stats.sexInfo.total + 1
                end
            end
        end
    elseif Config.Framework == "qb-core" then
        local Players = QBCore.Functions.GetPlayers()
        stats.onlinePlayers = #Players
        
        if Config.Database == "oxmysql" then
            local result = exports.oxmysql:querySync('SELECT * FROM players', {})
            if result then
                stats.totalPlayers = #result
                for _, player in ipairs(result) do
                    local money = json.decode(player.money or '{}')
                    if money.cash then
                        stats.totalCash = stats.totalCash + money.cash
                    end
                    if money.bank then
                        stats.totalBank = stats.totalBank + money.bank
                    end
                    
                    local charinfo = json.decode(player.charinfo or '{}')
                    if charinfo.gender == 0 then
                        stats.sexInfo.male = stats.sexInfo.male + 1
                    elseif charinfo.gender == 1 then
                        stats.sexInfo.female = stats.sexInfo.female + 1
                    end
                    stats.sexInfo.total = stats.sexInfo.total + 1
                end
            end
        end
    end
    
    return stats
end

local function GetAllPlayersFromDB()
    local players = {}
    
    if Config.Framework == "esx" then
        if Config.Database == "oxmysql" then
            local result = exports.oxmysql:querySync('SELECT identifier, firstname, lastname, accounts, job FROM users', {})
            if result then
                for _, user in ipairs(result) do
                    local accounts = {}
                    local job = {}
                    if user.accounts then
                        if type(user.accounts) == "string" then
                            accounts = json.decode(user.accounts) or {}
                        else
                            accounts = user.accounts
                        end
                    end
                    if user.job then
                        if type(user.job) == "string" then
                            job = json.decode(user.job) or {}
                        else
                            job = user.job
                        end
                    end
                    table.insert(players, {
                        identifier = user.identifier,
                        name = user.firstname .. " " .. user.lastname,
                        icName = user.firstname .. " " .. user.lastname,
                        cash = accounts.money or 0,
                        bank = accounts.bank or 0,
                        job = job.label or job.name or "Unemployed"
                    })
                end
            end
        end
    elseif Config.Framework == "qb-core" then
        if Config.Database == "oxmysql" then
            local result = exports.oxmysql:querySync('SELECT citizenid, charinfo, money, job FROM players', {})
            if result then
                for _, player in ipairs(result) do
                    local charinfo = {}
                    local money = {}
                    local job = {}
                    if player.charinfo then
                        if type(player.charinfo) == "string" then
                            charinfo = json.decode(player.charinfo) or {}
                        else
                            charinfo = player.charinfo
                        end
                    end
                    if player.money then
                        if type(player.money) == "string" then
                            money = json.decode(player.money) or {}
                        else
                            money = player.money
                        end
                    end
                    if player.job then
                        if type(player.job) == "string" then
                            job = json.decode(player.job) or {}
                        else
                            job = player.job
                        end
                    end
                    table.insert(players, {
                        identifier = player.citizenid,
                        name = (charinfo.firstname or "") .. " " .. (charinfo.lastname or ""),
                        icName = (charinfo.firstname or "") .. " " .. (charinfo.lastname or ""),
                        cash = money.cash or 0,
                        bank = money.bank or 0,
                        job = job.label or job.name or "Unemployed"
                    })
                end
            end
        end
    end
    
    return players
end

local function GetPlayerInventory(identifier)
    local inventory = {
        items = {},
        money = {cash = 0, bank = 0},
        job = {},
        icInfo = {}
    }
    
    if Config.Framework == "esx" then
        if Config.Database == "oxmysql" then
            local result = exports.oxmysql:querySync('SELECT * FROM users WHERE identifier = ?', {identifier})
            if result and result[1] then
                local user = result[1]
                local accounts = {}
                local job = {}
                if user.accounts then
                    if type(user.accounts) == "string" then
                        accounts = json.decode(user.accounts) or {}
                    else
                        accounts = user.accounts
                    end
                end
                if user.job then
                    if type(user.job) == "string" then
                        job = json.decode(user.job) or {}
                    else
                        job = user.job
                    end
                end
                inventory.money.cash = accounts.money or 0
                inventory.money.bank = accounts.bank or 0
                inventory.job = job
                inventory.icInfo = {
                    firstname = user.firstname,
                    lastname = user.lastname,
                    dateofbirth = user.dateofbirth,
                    sex = user.sex,
                    height = user.height
                }
                
                if user.inventory then
                    local inventoryData = {}
                    if type(user.inventory) == "string" then
                        inventoryData = json.decode(user.inventory) or {}
                    else
                        inventoryData = user.inventory
                    end
                    
                    if type(inventoryData) == "table" then
                        for _, item in ipairs(inventoryData) do
                            if item and item.name then
                                local itemInfo = {
                                    name = item.name,
                                    count = item.count or 0,
                                    slot = item.slot or 0,
                                    label = item.name 
                                }
                                
                                if item.metadata then
                                    itemInfo.metadata = item.metadata
                                    if item.metadata.registered then
                                        itemInfo.registered = item.metadata.registered
                                    end
                                    if item.metadata.ammo then
                                        itemInfo.ammo = item.metadata.ammo
                                    end
                                    if item.metadata.durability then
                                        itemInfo.durability = item.metadata.durability
                                    end
                                    if item.metadata.serial then
                                        itemInfo.serial = item.metadata.serial
                                    end
                                end
                                
                                table.insert(inventory.items, itemInfo)
                            end
                        end
                    end
                end
            end
        end
    elseif Config.Framework == "qb-core" then
        if Config.Database == "oxmysql" then
            local result = exports.oxmysql:querySync('SELECT * FROM players WHERE citizenid = ?', {identifier})
            if result and result[1] then
                local player = result[1]
                local money = {}
                local charinfo = {}
                local job = {}
                if player.money then
                    if type(player.money) == "string" then
                        money = json.decode(player.money) or {}
                    else
                        money = player.money
                    end
                end
                if player.charinfo then
                    if type(player.charinfo) == "string" then
                        charinfo = json.decode(player.charinfo) or {}
                    else
                        charinfo = player.charinfo
                    end
                end
                if player.job then
                    if type(player.job) == "string" then
                        job = json.decode(player.job) or {}
                    else
                        job = player.job
                    end
                end
                
                inventory.money.cash = money.cash or 0
                inventory.money.bank = money.bank or 0
                inventory.job = job
                inventory.icInfo = {
                    firstname = charinfo.firstname,
                    lastname = charinfo.lastname,
                    birthdate = charinfo.birthdate,
                    gender = charinfo.gender,
                    nationality = charinfo.nationality
                }
                
                local items = exports.oxmysql:querySync('SELECT * FROM player_inventories WHERE citizenid = ?', {identifier})
                if items then
                    for _, item in ipairs(items) do
                        local itemData = {}
                        if item.items then
                            if type(item.items) == "string" then
                                itemData = json.decode(item.items) or {}
                            else
                                itemData = item.items
                            end
                        end
                        for itemName, itemInfo in pairs(itemData) do
                            table.insert(inventory.items, {
                                name = itemName,
                                count = itemInfo.amount or itemInfo.count or 0,
                                label = itemInfo.label or itemName
                            })
                        end
                    end
                end
            end
        end
    end
    
    return inventory
end

-- Get activity logs 
local function GetActivityLogs(date)
   -- todo 
    -- For now, return empty array
    return {}
end

local function GetPlayerVehicles(identifier)
    local vehicles = {}
    
    if Config.Framework == "esx" then
        if Config.Database == "oxmysql" then
            local result = exports.oxmysql:querySync('SELECT * FROM owned_vehicles WHERE owner = ?', {identifier})
            if result then
                for _, vehicle in ipairs(result) do
                    local vehicleData = {}
                    if vehicle.vehicle then
                        if type(vehicle.vehicle) == "string" then
                            vehicleData = json.decode(vehicle.vehicle) or {}
                        else
                            vehicleData = vehicle.vehicle
                        end
                    end
                    
                    table.insert(vehicles, {
                        plate = vehicle.plate,
                        vehicle = vehicle.vehicle,
                        vehicleData = vehicleData,
                        model = vehicleData.model or vehicle.vehicle or "Unknown",
                        stored = vehicle.stored or 0,
                        garage = vehicle.garage or "Unknown"
                    })
                end
            end
        end
    elseif Config.Framework == "qb-core" then
        if Config.Database == "oxmysql" then
            local result = exports.oxmysql:querySync('SELECT * FROM player_vehicles WHERE citizenid = ?', {identifier})
            if result then
                for _, vehicle in ipairs(result) do
                    local mods = {}
                    if vehicle.mods then
                        if type(vehicle.mods) == "string" then
                            mods = json.decode(vehicle.mods) or {}
                        else
                            mods = vehicle.mods
                        end
                    end
                    
                    table.insert(vehicles, {
                        plate = vehicle.plate,
                        vehicle = vehicle.vehicle,
                        mods = mods,
                        model = vehicle.vehicle or "Unknown",
                        stored = vehicle.state or 0,
                        garage = vehicle.garage or "Unknown"
                    })
                end
            end
        end
    end
    
    return vehicles
end

local function ChangePlayerJob(identifier, jobName, grade)
    if Config.Framework == "esx" then
        if Config.Database == "oxmysql" then
            local result = exports.oxmysql:querySync('SELECT job FROM users WHERE identifier = ?', {identifier})
            if result and result[1] then
                local job = {}
                if result[1].job then
                    if type(result[1].job) == "string" then
                        job = json.decode(result[1].job) or {}
                    else
                        job = result[1].job
                    end
                end
                
                job.name = jobName
                job.grade = tonumber(grade) or 0
                
                local jobInfo = exports.oxmysql:querySync('SELECT label FROM jobs WHERE name = ?', {jobName})
                if jobInfo and jobInfo[1] then
                    job.label = jobInfo[1].label
                end
                
                local gradeInfo = exports.oxmysql:querySync('SELECT label FROM job_grades WHERE job_name = ? AND grade = ?', {jobName, grade})
                if gradeInfo and gradeInfo[1] then
                    job.grade_label = gradeInfo[1].label
                end
                
                local updatedJob = json.encode(job)
                exports.oxmysql:execute('UPDATE users SET job = ? WHERE identifier = ?', {updatedJob, identifier})
                
                local xPlayer = ESX.GetPlayerFromIdentifier(identifier)
                if xPlayer then
                    xPlayer.setJob(jobName, tonumber(grade))
                end
                
                return true
            end
        end
    elseif Config.Framework == "qb-core" then
        if Config.Database == "oxmysql" then
            local result = exports.oxmysql:querySync('SELECT job FROM players WHERE citizenid = ?', {identifier})
            if result and result[1] then
                local job = {}
                if result[1].job then
                    if type(result[1].job) == "string" then
                        job = json.decode(result[1].job) or {}
                    else
                        job = result[1].job
                    end
                end
                
                job.name = jobName
                job.grade = {}
                job.grade.level = tonumber(grade) or 0
                
                local updatedJob = json.encode(job)
                exports.oxmysql:execute('UPDATE players SET job = ? WHERE citizenid = ?', {updatedJob, identifier})
                
                local Player = QBCore.Functions.GetPlayerByCitizenId(identifier)
                if Player then
                    Player.Functions.SetJob(jobName, tonumber(grade))
                end
                
                return true
            end
        end
    end
    return false
end

RegisterNetEvent('m_dashboard:getStatistics', function()
    local source = source
    if not HasPermission(source) then
        TriggerClientEvent('m_dashboard:getStatisticsResponse', source, {success = false, error = "No permission"})
        return
    end
    
    local stats = GetServerStatistics()
    TriggerClientEvent('m_dashboard:getStatisticsResponse', source, {success = true, statistics = stats})
end)

RegisterNetEvent('m_dashboard:getAllPlayersDB', function()
    local source = source
    if not HasPermission(source) then
        TriggerClientEvent('m_dashboard:getAllPlayersDBResponse', source, {success = false, error = "No permission"})
        return
    end
    
    local players = GetAllPlayersFromDB()
    TriggerClientEvent('m_dashboard:getAllPlayersDBResponse', source, {success = true, players = players})
end)

RegisterNetEvent('m_dashboard:getPlayerInventory', function(identifier)
    local source = source
    if not HasPermission(source) then
        TriggerClientEvent('m_dashboard:getPlayerInventoryResponse', source, {success = false, error = "No permission"})
        return
    end
    
    local inventory = GetPlayerInventory(identifier)
    TriggerClientEvent('m_dashboard:getPlayerInventoryResponse', source, {success = true, inventory = inventory, identifier = identifier})
end)

RegisterNetEvent('m_dashboard:getPlayerVehicles', function(identifier)
    local source = source
    if not HasPermission(source) then
        TriggerClientEvent('m_dashboard:getPlayerVehiclesResponse', source, {success = false, error = "No permission"})
        return
    end
    
    local vehicles = GetPlayerVehicles(identifier)
    TriggerClientEvent('m_dashboard:getPlayerVehiclesResponse', source, {success = true, vehicles = vehicles})
end)

RegisterNetEvent('m_dashboard:changePlayerJob', function(identifier, jobName, grade)
    local source = source
    if not HasPermission(source) then
        TriggerClientEvent('m_dashboard:changePlayerJobResponse', source, {success = false, error = "No permission"})
        return
    end
    
    local success = ChangePlayerJob(identifier, jobName, grade)
    if success then
        TriggerClientEvent('m_dashboard:changePlayerJobResponse', source, {success = true, message = "Player job updated"})
    else
        TriggerClientEvent('m_dashboard:changePlayerJobResponse', source, {success = false, error = "Failed to update player job"})
    end
end)

RegisterNetEvent('m_dashboard:getActivity', function(date)
    local source = source
    if not HasPermission(source) then
        TriggerClientEvent('m_dashboard:getActivityResponse', source, {success = false, error = "No permission"})
        return
    end
    
    local activity = GetActivityLogs(date)
    TriggerClientEvent('m_dashboard:getActivityResponse', source, {success = true, activity = activity})
end)

RegisterNetEvent('m_dashboard:getPlayers', function()
    local source = source
    if not HasPermission(source) then
        TriggerClientEvent('m_dashboard:getPlayersResponse', source, {success = false, error = "No permission"})
        return
    end
    
    local players = GetAllPlayers()
    TriggerClientEvent('m_dashboard:getPlayersResponse', source, {success = true, players = players})
end)

RegisterNetEvent('m_dashboard:getPlayerDetails', function(playerId)
    local source = source
    if not HasPermission(source) then
        TriggerClientEvent('m_dashboard:getPlayerDetailsResponse', source, {success = false, error = "No permission"})
        return
    end
    
    local playerDetails = GetPlayerDetails(source, playerId)
    if playerDetails then
        TriggerClientEvent('m_dashboard:getPlayerDetailsResponse', source, {success = true, player = playerDetails})
    else
        TriggerClientEvent('m_dashboard:getPlayerDetailsResponse', source, {success = false, error = "Player not found"})
    end
end)

RegisterNetEvent('m_dashboard:updatePlayerMoney', function(playerId, moneyType, amount)
    local source = source
    if not HasPermission(source) then
        TriggerClientEvent('m_dashboard:updatePlayerMoneyResponse', source, {success = false, error = "No permission"})
        return
    end
    
    local success = UpdatePlayerMoney(playerId, moneyType, amount)
    if success then
        TriggerClientEvent('m_dashboard:updatePlayerMoneyResponse', source, {success = true, message = "Money updated successfully"})
    else
        TriggerClientEvent('m_dashboard:updatePlayerMoneyResponse', source, {success = false, error = "Failed to update money"})
    end
end)

RegisterNetEvent('m_dashboard:setPlayerMoney', function(playerId, moneyType, amount)
    local source = source
    if not HasPermission(source) then
        TriggerClientEvent('m_dashboard:setPlayerMoneyResponse', source, {success = false, error = "No permission"})
        return
    end
    
    local success = SetPlayerMoney(playerId, moneyType, amount)
    if success then
        TriggerClientEvent('m_dashboard:setPlayerMoneyResponse', source, {success = true, message = "Money set successfully"})
    else
        TriggerClientEvent('m_dashboard:setPlayerMoneyResponse', source, {success = false, error = "Failed to set money"})
    end
end)

RegisterNetEvent('m_dashboard:executeSQL', function(query)
    local source = source
    if not HasPermission(source) then
        TriggerClientEvent('m_dashboard:executeSQLResponse', source, {success = false, error = "No permission"})
        return
    end
    
    local isSafe, errorMsg = IsQuerySafe(query)
    if not isSafe then
        TriggerClientEvent('m_dashboard:executeSQLResponse', source, {success = false, error = errorMsg})
        return
    end
    
    if Config.Database == "oxmysql" then
        exports.oxmysql:execute(query, {}, function(result)
            TriggerClientEvent('m_dashboard:executeSQLResponse', source, {success = true, result = result})
        end)
    elseif Config.Database == "mysql-async" then
        MySQL.Async.fetchAll(query, {}, function(result)
            TriggerClientEvent('m_dashboard:executeSQLResponse', source, {success = true, result = result})
        end)
    elseif Config.Database == "ghmattimysql" then
        exports.ghmattimysql:execute(query, {}, function(result)
            TriggerClientEvent('m_dashboard:executeSQLResponse', source, {success = true, result = result})
        end)
    else
        TriggerClientEvent('m_dashboard:executeSQLResponse', source, {success = false, error = "Database not configured"})
    end
end)

RegisterCommand('dashboard', function(source, args, rawCommand)
    if HasPermission(source) then
        TriggerClientEvent('m_dashboard:open', source)
    else
        TriggerClientEvent('chat:addMessage', source, {
            color = {255, 0, 0},
            multiline = true,
            args = {"System", "You don't have permission to use this command."}
        })
    end
end, false)

print("^2[m_dashboard]^7 Dashboard loaded successfully!")

