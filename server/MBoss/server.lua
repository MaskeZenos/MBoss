ESX = nil 
TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
RegisterNetEvent('MBoss:FirePlayer')
AddEventHandler('MBoss:FirePlayer', function(identifier, job)
    local tPlayer = ESX.GetPlayerFromIdentifier(identifier)
    local xPlayer = ESX.GetPlayerFromId(source)
    if job == xPlayer.job.name then
        if tPlayer ~= nil then
            TriggerClientEvent('esx:showNotification', tPlayer.source, "~r~Vous avez été viré de votre job !")
            TriggerClientEvent('esx:showNotification', source, "~r~Vous avez viré ~b~"..tPlayer.name.." ~r~de son job !")
            tPlayer.setJob('unemployed', 0)
        else
            MySQL.Async.execute('UPDATE users SET job = @job WHERE identifier = @identifier', {
                ['@job'] = 'unemployed',
                ['@identifier'] = identifier
            })
            TriggerClientEvent('esx:showNotification', source, "~r~Le joueur a été viré !")
        end
    end
end)

RegisterNetEvent('MBoss:DemotePlayer')
AddEventHandler('MBoss:DemotePlayer', function(identifier, job)
    local tPlayer = ESX.GetPlayerFromIdentifier(identifier)
    local xPlayer = ESX.GetPlayerFromId(source)
    if job == xPlayer.job.name then
        if tPlayer ~= nil then
            TriggerClientEvent('esx:showNotification', tPlayer.source, "~r~Vous avez été rétrogradé !")
            TriggerClientEvent('esx:showNotification', source, "~r~Vous avez rétrogradé ~b~"..tPlayer.name.." ~r~!")
            tPlayer.setJob(job, tPlayer.job.grade - 1)
        else
            MySQL.Async.execute('UPDATE users SET job_grade = job_grade - 1 WHERE identifier = @identifier', {
                ['@identifier'] = identifier
            })
            TriggerClientEvent('esx:showNotification', source, "~r~Le joueur a été rétrogradé !")
        end
    end
end)

RegisterNetEvent('MBoss:PromotePlayer')
AddEventHandler('MBoss:PromotePlayer', function(identifier, job)
    local tPlayer = ESX.GetPlayerFromIdentifier(identifier)
    local xPlayer = ESX.GetPlayerFromId(source)
    if job == xPlayer.job.name then
        if tPlayer ~= nil then
            TriggerClientEvent('esx:showNotification', tPlayer.source, "~g~Vous avez été promu !")
            TriggerClientEvent('esx:showNotification', source, "~g~Vous avez promu ~b~"..tPlayer.name.." ~g~!")
            tPlayer.setJob(job, tPlayer.job.grade + 1)
        else
            MySQL.Async.execute('UPDATE users SET job_grade = job_grade + 1 WHERE identifier = @identifier', {
                ['@identifier'] = identifier
            })
            TriggerClientEvent('esx:showNotification', source, "~r~Le joueur a été promu !")
        end
    end
end)

ESX.RegisterServerCallback('GetSalary', function(source, cb)
    xPlayer = ESX.GetPlayerFromId(source)
    Result = MySQL.Sync.fetchAll('SELECT * FROM job_grades WHERE job_name = @job_name', {
        ['@job_name'] = xPlayer.job.name
    })
    cb(Result)

end)

RegisterNetEvent('MBoss:ChangeSalary')
AddEventHandler('MBoss:ChangeSalary', function(grade, amount, jobname, id )
    xPlayer = ESX.GetPlayerFromId(source)
    if xPlayer.job.name == jobname then
        if xPlayer.job.grade_name ~= 'boss' then
            TriggerClientEvent('esx:showNotification', source, "~r~Vous n'avez pas les droits pour faire cela !")
            return
        else 
            TriggerClientEvent('esx:showNotification', source, "~g~Vous avez changé le salaire de ~b~"..grade.." ~g~à ~b~"..amount.." $ ~g~!")
            MySQL.Async.execute('UPDATE job_grades SET salary = @salary WHERE id = @id', {
                ['@salary'] = amount,
                ['@id'] = id,
            })
        end 
    end

end)