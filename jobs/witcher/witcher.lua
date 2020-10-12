local WitcherClass = class()
local CombatJob = require 'stonehearth.jobs.combat_job'
local CraftingJob = require 'stonehearth.jobs.crafting_job'

radiant.mixin(WitcherClass, CombatJob)
radiant.mixin(WitcherClass, CraftingJob)

return WitcherClass