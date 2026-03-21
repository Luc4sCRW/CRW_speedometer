local unit = Config.Unit or "KMH"
local tick = Config.UpdateTick or 100

------------------- STYLE HOLEN
CreateThread(function()
    Wait(1000) -- Etwas mehr Zeit für das NUI
    SendNUIMessage({
        action = "setStyle",
        style = Config.Style or "glass"
    })
end)

-----------------------------------------
Citizen.CreateThread(function()
    while true do
        local sleep = 500
        local ped = PlayerPedId()
        local veh = GetVehiclePedIsIn(ped, false)

        if veh ~= 0 and not IsPauseMenuActive() then
            sleep = tick
            local speed = GetEntitySpeed(veh)
            local rpm = GetVehicleCurrentRpm(veh)
                -- Motor aus? RPM auf 0 setzen
            if not GetIsVehicleEngineRunning(veh) then
                rpm = 0
            end
                
            -- Hier die Berechnung für KMH (3.6) oder MPH (2.236)
            local finalSpeed = (unit == "KMH" and speed * 3.6 or speed * 2.236936)
            
            SendNUIMessage({
                type = "updateVehicleHud",
                show = true,
                speed = finalSpeed,
                --rpm = GetVehicleCurrentRpm(veh),
                rpm = rpm,
                fuel = GetVehicleFuelLevel(veh),
                gear = GetVehicleCurrentGear(veh)
            })
        else
            SendNUIMessage({ type = "updateVehicleHud", show = false })
            sleep = 1000
        end
        Citizen.Wait(sleep)
    end
end)



--------------- MOTOR AUS AN --------------

RegisterCommand("toggleEngine", function()
    local ped = PlayerPedId()
    local veh = GetVehiclePedIsIn(ped, false)
    
    if veh ~= 0 and GetPedInVehicleSeat(veh, -1) == ped then
        local engineStatus = GetIsVehicleEngineRunning(veh)
        SetVehicleEngineOn(veh, not engineStatus, false, true)
    end
end, false)

RegisterKeyMapping("toggleEngine", "Motor an/aus", "keyboard", "M")

--------------- STEERING --------------

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
