local HealTarget = class()

function HealTarget.use(consumable, consumable_data, user, target_entity)
   radiant.assert(user, "Unable to use consumable %s because it requires a user and user was nil", consumable)
   radiant.assert(target_entity, "Unable to use consumable %s because it requires a target entity and target entity was nil", consumable)

   local attributes_component = target_entity:get_component('stonehearth:attributes')
   if not attributes_component then
      return false
   end
    
   local current_health = radiant.entities.get_health(target_entity)
    local max_health = attributes_component:get_attribute('max_health')
    
   if current_health > 0 then      
        local healed_amount = consumable_data.health_healed
        
        if consumable_data.is_percentage then
            healed_amount = math.floor(healed_amount * max_health)
        end
        
        if consumable_data.minimum_health_healed and consumable_data.minimum_health_healed >= healed_amount then            
            healed_amount = consumable_data.minimum_health_healed
        end

      -- Apply job perks to amount healed
      local job_component = user:get_component('stonehearth:job')
      if job_component and job_component:curr_job_has_perk('increase_healing_item_effect_50_percent') then
         healed_amount = math.floor(healed_amount * 1.5)
      end

      radiant.entities.modify_health(target_entity, healed_amount)
   else
      local guts_healed = consumable_data.guts_healed or 1
      radiant.entities.modify_resource(target_entity, 'guts', guts_healed)
   end
   return true
end

return HealTarget