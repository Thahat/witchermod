local FarmerClass = class()
local CraftingJob = require 'stonehearth.jobs.crafting_job'
radiant.mixin(FarmerClass, CraftingJob)

-- Farmers gain XP when they harvest things. The amount of XP depends on the crop
function FarmerClass:_create_listeners()
   self._on_harvest_listener = radiant.events.listen(self._sv._entity, 'stonehearth:harvest_crop', self, self._on_harvest)
   self._on_craft_listener = radiant.events.listen(self._sv._entity, 'stonehearth:crafter:craft_item', self, self._on_craft)
end

function FarmerClass:_remove_listeners()
   if self._on_harvest_listener then
      self._on_harvest_listener:destroy()
      self._on_harvest_listener = nil
   end
   if self._on_craft_listener then
      self._on_craft_listener:destroy()
      self._on_craft_listener = nil
   end
end

function FarmerClass:_on_harvest(args)
   local crop = args.crop_uri
   local xp_to_add = self._xp_rewards["base_exp_per_harvest"]
   if self._xp_rewards[crop] then
      xp_to_add = self._xp_rewards[crop] 
   end
   self._job_component:add_exp(xp_to_add)
end

function FarmerClass:_on_craft(args)
   local recipe_data = args.recipe_data

   local level_key = 'craft_level_0'
   local level_required = 0
   if recipe_data.level_requirement then
      level_key = 'craft_level_' .. recipe_data.level_requirement
      level_required = recipe_data.level_requirement
   end
   local job_level = self:get_job_level()
   local exp = self._xp_rewards[level_key]
   assert(exp, self._job_json.alias .. ' has no exp reward tuned for level ' .. level_key .. ' recipes')

   local exp_addition = 0
   local attributes_component = self._sv._entity:get_component('stonehearth:attributes')
   if attributes_component then
      local curiosity = attributes_component:get_attribute('curiosity')
      exp_addition = radiant.math.round(curiosity * stonehearth.constants.attribute_effects.CURIOSITY_EXPERIENCE_MULTIPLER)
      if exp_addition < 0 then
         exp_addition = 0
      end
   end

   exp = exp + exp_addition

   if level_required < job_level then
      local difference = job_level - level_required
      exp = exp / difference
   end
   exp = radiant.math.round(exp)
   self._job_component:add_exp(exp, false) -- false for do not apply curiosity addition because we've already done so
end

return FarmerClass