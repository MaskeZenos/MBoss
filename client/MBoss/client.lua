ESX = false
TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

societyMoney = 0
EmployeeList = {}
GradeSalary = {}
identifier = ""
Name = ""
GradeLabel = "" 
GradeSalary = "" 

--IS HERE FOR CONFIG !!!!! -----------------------------------------------

BossMenuList = {
    Police = {
        coord = vector3(441.19302368164, -1002.2189941406, 30.718111038208), -- Position of the boss menu
        label = "Police", -- Name in the menu
        job = "police", -- Job name 
    },
    Ambulance = {
        coord = vector3(400.2, -981.2, 30.6),
        label = "Ambulance",
        job = "ambulance",
    },
    --Ambulance2 = {
    --    coord = vector3(400.2, -981.2, 30.6),
    --    label = "Ambulance2,
    --    job = "ambulance2",
    --},
}

-----------------------------------------------------------------------------------------------

RegisterNetEvent('esx:playerLoaded')
AddEventHandler('esx:playerLoaded', function(xPlayer)
	ESX.PlayerData = xPlayer
end)


RegisterNetEvent('esx:setJob')
AddEventHandler('esx:setJob', function(job)
	ESX.PlayerData.job = job
end)

RMenu.Add('Boss', 'mainBoss', RageUI.CreateMenu("Boss", "Boss"))
RMenu.Add('Boss', 'subBoss', RageUI.CreateSubMenu(RMenu:Get('Boss', 'mainBoss'), "Boss", "Boss"))
RMenu.Add('Boss', 'subBoss2', RageUI.CreateSubMenu(RMenu:Get('Boss', 'subBoss'), "Boss", "Boss"))
RMenu.Add('Boss', 'subBoss3', RageUI.CreateSubMenu(RMenu:Get('Boss', 'subBoss'), "Boss", "Boss"))

Citizen.CreateThread(function()

    while true do
        RageUI.IsVisible(RMenu:Get('Boss', 'mainBoss'), function()
        
            RageUI.Separator("↓ ~b~ Menu Boss ~s~↓")

            RageUI.Separator("Vous êtes ~b~"..ESX.PlayerData.job.label.." ~s~!")
            RageUI.Separator("Grade : ~b~"..ESX.PlayerData.job.grade_label.." ~s~!")
            RageUI.Separator("La société possède ~b~"..societyMoney.."$ ~s~!")
            
            RageUI.Line()

            RageUI.Button('Retirer de l\'argent', nil, { RightLabel = "→→→" }, true, {
                onSelected = function()
                    local amount = KeyboardInput("Montant", "", 8)
                    if not tonumber(amount) then
                        ESX.ShowNotification("Veuillez entrer un nombre")
                        return
                    end
                    if amount ~= nil then
                        TriggerServerEvent('esx_society:withdrawMoney', ESX.PlayerData.job.name, tonumber(amount))
                        Wait(200)
                        RefreshAccountMoney()
                    end
                end
            })

            RageUI.Button('Déposer de l\'argent', nil, { RightLabel = "→→→" }, true, {
                onSelected = function()
                    local amount = KeyboardInput("Montant", "", 8)
                    if not tonumber(amount) then
                        ESX.ShowNotification("Veuillez entrer un nombre")
                        return
                    end
                    if amount ~= nil then
                        TriggerServerEvent('esx_society:depositMoney', ESX.PlayerData.job.name, tonumber(amount))
                        Wait(200)
                        RefreshAccountMoney()
                    end
                end
            })

            RageUI.Button('Recruter un employé', nil, { RightLabel = "→→→" }, true, {
                onSelected = function()
                    local player, distance = ESX.Game.GetClosestPlayer()
                    if distance ~= -1 and distance <= 3.0 then
                        TriggerServerEvent('esx_society:setJob', ESX.PlayerData.job.name, GetPlayerServerId(player), ESX.PlayerData.job.grade_name)
                    else
                        ESX.ShowNotification("Aucun joueur à proximité")
                    end
                end
            })

            RageUI.Button('Voir liste des employés', nil, { RightLabel = "→→→" }, true, {
                onSelected = function()
                end
            }, RMenu:Get('Boss', 'subBoss'))

            RageUI.Button('Gestion salaire', nil, { RightLabel = "→→→" }, true, {
                onSelected = function()
                end
            }, RMenu:Get('Boss', 'subBoss3'))


        end, function()
        end)
        RageUI.IsVisible(RMenu:Get('Boss', 'subBoss3'), function()
            RageUI.Separator("↓ ~b~ Gestion des salaires ~s~↓")
            RageUI.Line()
            for i=1, #GradeSalary, 1 do
                RageUI.Button(GradeSalary[i].label .. "", nil, { RightLabel = "~y~".. GradeSalary[i].salary.." $" }, true, {
                    onSelected = function()
                        local amount = KeyboardInput("Montant", "", 4)
                        if not tonumber(amount) then
                            ESX.ShowNotification("Veuillez entrer un nombre")
                            return
                        end
                        if amount ~= nil then
                            TriggerServerEvent('MBoss:ChangeSalary', GradeSalary[i].label, tonumber(amount), ESX.PlayerData.job.name, GradeSalary[i].id)
                            Wait(200)
                            RefreshAccountMoney()
                        end
                    end
                })
            end


        end, function()
        end)
        RageUI.IsVisible(RMenu:Get('Boss', 'subBoss'), function()
            RageUI.Separator("↓ ~b~ Liste des employés ~s~↓")
            RageUI.Line()
            for i=1, #EmployeeList, 1 do
                RageUI.Button(EmployeeList[i].name .. "", nil, { RightLabel = "~y~".. EmployeeList[i].job.grade_label }, true, {
                    onSelected = function()
                        Name = EmployeeList[i].name
                        GradeLabel = EmployeeList[i].job.grade_label
                        identifier = EmployeeList[i].identifier
                    end
                }, RMenu:Get('Boss', 'subBoss2'))
            end
        end, function()
        end)

        RageUI.IsVisible(RMenu:Get('Boss', 'subBoss2'), function()
            RageUI.Separator("↓ ~b~ Gestion de employé ~s~↓")
            RageUI.Separator("Nom : ~b~"..Name.." ~s~!")
            RageUI.Separator("Grade : ~b~"..GradeLabel.." ~s~!")
            for i=1, #GradeSalary, 1 do
                if GradeSalary[i].label == GradeLabel then
                    RageUI.Separator("Salaire : ~b~"..GradeSalary[i].salary.." $ ~s~!")
                end
            end

            RageUI.Line()
            RageUI.Button('Virer', nil, { RightLabel = "→→→" }, true, {
                onSelected = function()
                    TriggerServerEvent('MBoss:FirePlayer', identifier, ESX.PlayerData.job.name)
                    Wait(200)
                    RefreshAccountMoney()
                    RageUI.GoBack()
                end
            })

            RageUI.Button('Promouvoir', nil, { RightLabel = "→→→" }, true, {
                onSelected = function()
                    TriggerServerEvent('MBoss:PromotePlayer', identifier, ESX.PlayerData.job.name)
                    RageUI.GoBack()
                end
            })

            RageUI.Button('Rétrograder', nil, { RightLabel = "→→→" }, true, {
                onSelected = function()
                    TriggerServerEvent('MBoss:DemotePlayer', identifier, ESX.PlayerData.job.name)
                    RageUI.GoBack()
                end
            })



        end, function()
        end)

 

        Citizen.Wait(0)
    end
end)





function KeyboardInput(TextEntry, ExampleText, MaxStringLenght)
    AddTextEntry('FMMC_KEY_TIP1', TextEntry .. ':')
    DisplayOnscreenKeyboard(1, "FMMC_KEY_TIP1", "", ExampleText or "", "", "", "", MaxStringLenght)
    blockinput = true

    while UpdateOnscreenKeyboard() ~= 1 and UpdateOnscreenKeyboard() ~= 2 do
        Citizen.Wait(0)
    end

    if UpdateOnscreenKeyboard() ~= 2 then
        local result = GetOnscreenKeyboardResult()
        Citizen.Wait(500)
        blockinput = false
        return result
    else
        Citizen.Wait(500)
        blockinput = false
        return nil
    end
end


Citizen.CreateThread(function()
    while true do
        if RageUI.Visible(RMenu:Get('Boss', 'mainBoss')) or RageUI.Visible(RMenu:Get('Boss', 'subBoss')) then
            for k,v in pairs(BossMenuList) do
                if ESX.PlayerData.job.name ~= BossMenuList[k].job  and ESX.PlayerData.job.grade_name ~= 'boss' then
                    RageUI.CloseAll()
                end
            end 
        end 
        for k,v in pairs(BossMenuList) do
            if ESX.PlayerData.job.name == BossMenuList[k].job  and ESX.PlayerData.job.grade_name == 'boss' then
                local plyCoords = GetEntityCoords(GetPlayerPed(-1), false)
                local dist = Vdist(plyCoords.x, plyCoords.y, plyCoords.z, BossMenuList[k].coord.x, BossMenuList[k].coord.y, BossMenuList[k].coord.z)
                if dist <= 5.0 then
                    DrawMarker(27, BossMenuList[k].coord.x, BossMenuList[k].coord.y, BossMenuList[k].coord.z-0.98, 0, 0, 0, 0, 0, 0, 0.5, 0.5, 0.5, 255, 255, 255, 255, 0, 0, 0, 0)
                    ESX.ShowHelpNotification("Appuyez sur E pour accéder au ~b~Boss")
                    if IsControlJustPressed(1,51) then
                        RefreshAccountMoney()
                        OpenMenuBoss()
                    end
                end 
            end
        end
        Citizen.Wait(0)
    end
end)

Citizen.CreateThread(function()
    while true do 
        Wait(5000)
        for k,v in pairs(BossMenuList) do
            if ESX.PlayerData.job.name == BossMenuList[k].job  and ESX.PlayerData.job.grade_name == 'boss' then
                RefreshAccountMoney()
            end
        end 
    end 

end)

function RefreshAccountMoney()
    ESX.TriggerServerCallback('esx_society:getSocietyMoney', function(money)
        societyMoney = ESX.Math.GroupDigits(money)
    end, ESX.PlayerData.job.name)
    ESX.TriggerServerCallback('esx_society:getEmployees' , function(employees)
        EmployeeList = employees
    end, ESX.PlayerData.job.name, GetPlayerServerId(PlayerId()))

    ESX.TriggerServerCallback('GetSalary', function(salary)
        GradeSalary = salary
    end)
end

function OpenMenuBoss()
    RageUI.Visible(RMenu:Get('Boss', 'mainBoss'), not RageUI.Visible(RMenu:Get('Boss', 'mainBoss')))
end

