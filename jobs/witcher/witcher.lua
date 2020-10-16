local WitcherClass = class()
local CraftingJob = require 'stonehearth.jobs.crafting_job'
local CombatJob = require 'stonehearth.jobs.combat_job'

radiant.mixin(WitcherClass, CraftingJob)
radiant.mixin(WitcherClass, CombatJob)


return WitcherClass