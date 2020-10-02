local InitiateClass = class()
local constants = require 'stonehearth.constants'
local CombatJob = require 'stonehearth.jobs.combat_job'
local rng = _radiant.math.get_default_rng()
radiant.mixin(InitiateClass, CombatJob)

function InitiateClass:initialize()
   CombatJob.initialize(self)
   self._sv.max_num_siege_weapons = {}
end

function InitiateClass:activate()
   CombatJob.activate(self)

   if self._sv.is_current_class then
      self:_register_with_town()
   end

   self.__saved_variables:mark_changed()
end

function InitiateClass:restore()
   if self._sv.is_current_class then
      self:_register_with_town()
   end
end

function InitiateClass:promote(json_path, options)
   CombatJob.promote(self, json_path, options)
   self._sv.max_num_siege_weapons = self._job_json.initial_num_siege_weapons or { trap = 0 }
   if next(self._sv.max_num_siege_weapons) then
      self:_register_with_town()
   end
   self.__saved_variables:mark_changed()
end

function InitiateClass:demote()
   local player_id = radiant.entities.get_player_id(self._sv._entity)
   local town = stonehearth.town:get_town(player_id)
   if town then
      town:remove_placement_slot_entity(self._sv._entity)
   end

   CombatJob.demote(self)
end

--Private functions

function InitiateClass:_create_listeners()
   self._clear_trap_listener = radiant.events.listen(self._sv._entity, 'stonehearth:clear_trap', self, self._on_clear_trap)
end

function InitiateClass:_remove_listeners()
   if self._clear_trap_listener then
      self._clear_trap_listener:destroy()
      self._clear_trap_listener = nil
   end

   if self._set_trap_listener then
      self._set_trap_listener:destroy()
      self._set_trap_listener = nil
   end
end

-- Called if the trapper is harvesting a trap for food.
-- @param args - the trapped_entity_id field inside args is nil if there is no critter, and true if there is a critter
function InitiateClass:_on_clear_trap(args)
   if args.trapped_entity_id then
      self._job_component:add_exp(self._xp_rewards['successful_trap'])
   else
      self._job_component:add_exp(self._xp_rewards['unsuccessful_trap'])
   end
end

-- We actually want the XP to be gained on harvesting; this is mostly for testing purposes.
function InitiateClass:_on_set_trap(args)
   --Comment in for testing, or write activation fn for autotests
   --self._job_component:add_exp(90)
end

function InitiateClass:should_tame(target)
      return false
   end
   
function InitiateClass:increase_max_placeable_traps(args)
   self._sv.max_num_siege_weapons = args.max_num_siege_weapons
   self:_register_with_town()
   self.__saved_variables:mark_changed()
end

function InitiateClass:_register_with_town()
   local player_id = radiant.entities.get_player_id(self._sv._entity)
   local town = stonehearth.town:get_town(player_id)
   if town then
      town:add_placement_slot_entity(self._sv._entity, self._sv.max_num_siege_weapons)
   end
end

return InitiateClass