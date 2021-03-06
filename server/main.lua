ESX = nil
TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

ESX.RegisterServerCallback('suku:FetchSchematicsInInventory', function(source, cb)
    local xPlayer = ESX.GetPlayerFromId(source)
    local SchematicList = {}
    if not xPlayer then return; end
    
    for k, v in pairs(Config.Blueprints) do
        if xPlayer.getInventoryItem(v.name).count >= 1 then
            table.insert(SchematicList, {name = v.name, label = v.label, itemToCraft = v.itemToCraft})
        end 
    end

    cb(SchematicList)
end)

RegisterServerEvent('suku:PlayerHasRequiredItems')
AddEventHandler('suku:PlayerHasRequiredItems', function(itemToCraft)
    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer then return; end

    for k, v in pairs(Config.Recipes) do
        if v.name == itemToCraft then
            local ingredientList = v.ingredients
            local playerIngredients = {}
            for i = 1, #ingredientList, 1 do
                local _item = xPlayer.getInventoryItem(ingredientList[i].name).count
                if _item >= ingredientList[i].amount then
                    table.insert(playerIngredients, ingredientList[i])
                    if i == #ingredientList then
                        if #ingredientList == #playerIngredients then
                            TriggerClientEvent('suku:BeginCraftingSchematic', source, v, playerIngredients)
                            break
                        end
                    end
                else
                    TriggerClientEvent('mythic_notify:client:SendAlert', source, { type = 'error', text = 'You do not have enough items!' })
                end
            end
        end
    end
end)

RegisterServerEvent('suku:FinishManufacturing')
AddEventHandler('suku:FinishManufacturing', function(craftable, ingredients)
    ConsumeIngredients(ingredients)
    AwardRecipeItem(craftable)
end)

function ConsumeIngredients(ingredients)
    local xPlayer = ESX.GetPlayerFromId(source)
    for i = 1, #ingredients, 1 do
        xPlayer.removeInventoryItem(ingredients[i].name, ingredients[i].amount)
    end
end

function AwardRecipeItem(craftable)
    local xPlayer = ESX.GetPlayerFromId(source)
    xPlayer.addInventoryItem(craftable.name, 1)
end