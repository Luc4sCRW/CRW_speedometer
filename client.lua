----------------------------------------------------- v1.0.0 -----------------------------------------------------
local unit = Config.Unit or "KMH"
local tick = Config.UpdateTick or 100

-- Stil holen. // get style.
CreateThread(function()
    Wait(100)
    SendNUIMessage({
        action = "setStyle",
        style = Config.Style or "glass"
    })
end)

CreateThread(function()
    Wait(100)
    SendNUIMessage({
        action = "setShape",
        style = Config.Shape or "rounded"
    })
end)

-- Haupt Schleife // main loop
CreateThread(function()
    while true do
        local sleep = 500
        local ped = PlayerPedId()
        local vehicle = GetVehiclePedIsIn(ped, false)

        if vehicle ~= 0 and GetIsVehicleEngineRunning(vehicle) then
            sleep = Config.UpdateTick or 100
            
            local speed = GetEntitySpeed(vehicle)
            local displaySpeed = (Config.Unit == "KMH") and (speed * 3.6) or (speed * 2.236936)
            local fuel = GetVehicleFuelLevel(vehicle) -- Nutze GetVehicleFuelLevel oder dein Fuel-System Export
            
            SendNUIMessage({
                type = "updateVehicleHud",
                show = not IsPauseMenuActive(),
                speed = displaySpeed,
                rpm = GetVehicleCurrentRpm(vehicle),
                gear = GetVehicleCurrentGear(vehicle),
                fuel = fuel
            })
        else
            SendNUIMessage({
                type = "updateVehicleHud",
                show = false
            })
        end
        Wait(sleep)
    end
end)

-- Tastenbelegung für Motor an/aus. // keybind for engine toggle.
RegisterCommand("toggleEngine", function()
    local ped = PlayerPedId()
    local veh = GetVehiclePedIsIn(ped, false)
    
    if veh ~= 0 and GetPedInVehicleSeat(veh, -1) == ped then
        local engineStatus = GetIsVehicleEngineRunning(veh)
        SetVehicleEngineOn(veh, not engineStatus, false, true)
    end
end, false)

RegisterKeyMapping("toggleEngine", "Engine on/off", "keyboard", "M")

-- Einschlagwinkel des Lenkrads speichern, wenn Motor aus. // save the steering wheel angle when the engine is off.
Citizen.CreateThread(function()
    local angle = 0.0
    local speed = 0.0
    while true do
        Citizen.Wait(0)
        local veh = GetVehiclePedIsUsing(PlayerPedId())
        if DoesEntityExist(veh) then
            local tangle = GetVehicleSteeringAngle(veh)
            if tangle > 10.0 or tangle < -10.0 then
                angle = tangle
            end
            speed = GetEntitySpeed(veh)
            local vehicle = GetVehiclePedIsIn(PlayerPedId(), true)
            if speed < 0.1 and DoesEntityExist(vehicle) and not GetIsTaskActive(PlayerPedId(), 151) and not GetIsVehicleEngineRunning(vehicle) then
                SetVehicleSteeringAngle(GetVehiclePedIsIn(PlayerPedId(), true), angle)
            end
        end
    end
end)
