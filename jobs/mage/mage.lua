local CraftingJob = require 'stonehearth.jobs.crafting_job'

local HELPER_RECIPES = {
   ['stonehearth:jobs:mason'] = {
      'refined:golem_parts',
   },
   ['stonehearth:jobs:potter'] = {
      'refined:golem_parts',
   },
   ['stonehearth:jobs:blacksmith'] = {
      'tools:golem_pick',
   },
   ['stonehearth:jobs:weaver'] = {
      'crafting_materials:golem_backpack',
   },
}

local MageClass = class()
radiant.mixin(MageClass, CraftingJob)

function MageClass:initialize()
   CraftingJob.initialize(self)
   self._sv.max_num_golems = {}
end

function MageClass:activate()
   CraftingJob.activate(self)

   if self._sv.is_current_class then
      self:_register_with_town()
   end

   self.__saved_variables:mark_changed()
end

function MageClass:restore()
   if self._sv.is_current_class then
      self:_register_with_town()
   end
end

function MageClass:promote(json_path, options)
   CraftingJob.promote(self, json_path, options)
   self._sv.max_num_golems = { golem = 0 }
   self:_register_with_town()
   self.__saved_variables:mark_changed()
end

function MageClass:demote()
   local player_id = radiant.entities.get_player_id(self._sv._entity)
   local town = stonehearth.town:get_town(player_id)
   if town then
      town:remove_placement_slot_entity(self._sv._entity)
   end

   CraftingJob.demote(self)
end

function MageClass:increase_max_golems(perk_json)
   self._sv.max_num_golems = { golem = perk_json.max_num_golems }
   self:_register_with_town()
   self.__saved_variables:mark_changed()
end

function MageClass:_create_listeners()
   CraftingJob._create_listeners(self)
end

function MageClass:_remove_listeners()
   CraftingJob._remove_listeners(self)
end

function MageClass:_register_with_town()
   local player_id = radiant.entities.get_player_id(self._sv._entity)

   -- Enforce golem limit.
   local town = stonehearth.town:get_town(player_id)
   if town then
      town:add_placement_slot_entity(self._sv._entity, self._sv.max_num_golems)
   end
   
   -- Unlock recipes for other classes used by the geomancer.
   for job, recipe_keys in pairs(HELPER_RECIPES) do
      local job_info = stonehearth.job:get_job_info(player_id, job)
      for _, recipe_key in ipairs(recipe_keys) do
         job_info:manually_unlock_recipe(recipe_key)
      end
   end
end

return MageClass
