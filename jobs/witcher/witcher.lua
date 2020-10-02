local WitcherClass = class()
local CombatJob = require 'stonehearth.jobs.combat_job'
radiant.mixin(WitcherClass, CombatJob)
return WitcherClass