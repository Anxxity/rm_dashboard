local isOpen = false

RegisterNetEvent('m_dashboard:open', function()
    if not isOpen then
        isOpen = true
        SetNuiFocus(true, true)
        SendNUIMessage({
            type = "open"
        })
    end
end)

-- NUI Callbacks (must be in client)
RegisterNUICallback('getPlayers', function(data, cb)
    TriggerServerEvent('m_dashboard:getPlayers')
    cb('ok')
end)

RegisterNUICallback('getPlayerDetails', function(data, cb)
    TriggerServerEvent('m_dashboard:getPlayerDetails', data.playerId)
    cb('ok')
end)

RegisterNUICallback('updatePlayerMoney', function(data, cb)
    TriggerServerEvent('m_dashboard:updatePlayerMoney', data.playerId, data.moneyType, data.amount)
    cb('ok')
end)

RegisterNUICallback('setPlayerMoney', function(data, cb)
    TriggerServerEvent('m_dashboard:setPlayerMoney', data.playerId, data.moneyType, data.amount)
    cb('ok')
end)

RegisterNUICallback('executeSQL', function(data, cb)
    TriggerServerEvent('m_dashboard:executeSQL', data.query)
    cb('ok')
end)

RegisterNUICallback('getStatistics', function(data, cb)
    TriggerServerEvent('m_dashboard:getStatistics')
    cb('ok')
end)

RegisterNUICallback('getAllPlayersDB', function(data, cb)
    TriggerServerEvent('m_dashboard:getAllPlayersDB')
    cb('ok')
end)

RegisterNUICallback('getPlayerInventory', function(data, cb)
    TriggerServerEvent('m_dashboard:getPlayerInventory', data.identifier)
    cb('ok')
end)

RegisterNUICallback('getActivity', function(data, cb)
    TriggerServerEvent('m_dashboard:getActivity', data.date)
    cb('ok')
end)

RegisterNUICallback('getPlayerVehicles', function(data, cb)
    TriggerServerEvent('m_dashboard:getPlayerVehicles', data.identifier)
    cb('ok')
end)

RegisterNUICallback('changePlayerJob', function(data, cb)
    TriggerServerEvent('m_dashboard:changePlayerJob', data.identifier, data.jobName, data.grade)
    cb('ok')
end)

RegisterNUICallback('close', function(data, cb)
    isOpen = false
    SetNuiFocus(false, false)
    cb('ok')
end)

-- Server Response Handlers
RegisterNetEvent('m_dashboard:getPlayersResponse', function(data)
    SendNUIMessage({
        type = "getPlayersResponse",
        data = data
    })
end)

RegisterNetEvent('m_dashboard:getPlayerDetailsResponse', function(data)
    SendNUIMessage({
        type = "getPlayerDetailsResponse",
        data = data
    })
end)

RegisterNetEvent('m_dashboard:updatePlayerMoneyResponse', function(data)
    SendNUIMessage({
        type = "updatePlayerMoneyResponse",
        data = data
    })
end)

RegisterNetEvent('m_dashboard:setPlayerMoneyResponse', function(data)
    SendNUIMessage({
        type = "setPlayerMoneyResponse",
        data = data
    })
end)

RegisterNetEvent('m_dashboard:executeSQLResponse', function(data)
    SendNUIMessage({
        type = "executeSQLResponse",
        data = data
    })
end)

RegisterNetEvent('m_dashboard:getStatisticsResponse', function(data)
    SendNUIMessage({
        type = "getStatisticsResponse",
        data = data
    })
end)

RegisterNetEvent('m_dashboard:getAllPlayersDBResponse', function(data)
    SendNUIMessage({
        type = "getAllPlayersDBResponse",
        data = data
    })
end)

RegisterNetEvent('m_dashboard:getPlayerInventoryResponse', function(data)
    SendNUIMessage({
        type = "getPlayerInventoryResponse",
        data = data
    })
end)

RegisterNetEvent('m_dashboard:getActivityResponse', function(data)
    SendNUIMessage({
        type = "getActivityResponse",
        data = data
    })
end)

RegisterNetEvent('m_dashboard:getPlayerVehiclesResponse', function(data)
    SendNUIMessage({
        type = "getPlayerVehiclesResponse",
        data = data
    })
end)

RegisterNetEvent('m_dashboard:changePlayerJobResponse', function(data)
    SendNUIMessage({
        type = "changePlayerJobResponse",
        data = data
    })
end)

