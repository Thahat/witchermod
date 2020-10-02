local Entity = _radiant.om.Entity

local CombatIdleKite = radiant.class()

CombatIdleKite.name = 'combat idle kite'
CombatIdleKite.does = 'stonehearth:combat:idle'
CombatIdleKite.args = {
   target = Entity
}
CombatIdleKite.priority = 0.4

function CombatIdleKite:start_thinking(ai, entity, args)
   local target = args.target

   if stonehearth.player:are_entities_friendly(entity, target) then
      -- in case your target is a friendly that you are buffing
      return
   end

   local destination = self:_choose_destination(entity, target)
   if destination then
      ai:set_think_output({
            location = destination
         })
   end
end

function CombatIdleKite:_choose_destination(entity, target)
   local weapon = stonehearth.combat:get_main_weapon(entity)
   if not weapon or not weapon:is_valid() then
      return nil
   end

   -- Subtract one to make sure we stay inside range and don't invoke
   -- pathfinding on next attack. TODO: compensate for elevation difference
   local desired_distance = stonehearth.combat:get_weapon_range(entity, weapon) - 1
   if desired_distance <= 0 then
      return nil
   end

   -- Not using grid locations to get better angle
   local entity_location = radiant.entities.get_world_location(entity)
   local target_location = radiant.entities.get_world_location(target)
   local opposite_direction = entity_location - target_location

   -- No need to kite if we're not in range
   if opposite_direction:length_squared() >= desired_distance*desired_distance then
      return nil
   end
   opposite_direction.y = 0
   opposite_direction:normalize()

   local entity_grid_location = entity_location:to_int()
   local target_grid_location = target_location:to_int()

   local desired_destination = (target_location:to_int() + opposite_direction*desired_distance):to_int()
   local resolved_destination = radiant.terrain.get_direct_path_end_point(entity_grid_location, desired_destination, entity)

   if resolved_destination == entity_grid_location then
      return nil
   end

   return resolved_destination
end

local ai = stonehearth.ai
return ai:create_compound_action(CombatIdleKite)
         :execute('stonehearth:goto_location', {
            reason = 'combat idle kite',
            location = ai.PREV.location,
         })

