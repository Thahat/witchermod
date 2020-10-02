local Entity = _radiant.om.Entity
local Point3 = _radiant.csg.Point3

local AttackAcolyteRangedMoveToLOS = class()

AttackAcolyteRangedMoveToLOS.name = 'attack acolyte ranged move to targetable location'
AttackAcolyteRangedMoveToLOS.does = 'stonehearth:combat:attack'
AttackAcolyteRangedMoveToLOS.args = {
   target = Entity
}
AttackAcolyteRangedMoveToLOS.version = 2
AttackAcolyteRangedMoveToLOS.priority = 3
AttackAcolyteRangedMoveToLOS.weight = 1

local ai = stonehearth.ai
return ai:create_compound_action(AttackAcolyteRangedMoveToLOS)
   :execute('stonehearth:combat:abort_on_leash_changed')
   :execute('stonehearth:combat:move_to_targetable_location', {
      target = ai.ARGS.target,
   })
   :execute('stonehearth:bump_allies', {
      distance = 2,
   })
   :execute('witchermod:combat:attack_acolyte_ranged', {
      target = ai.ARGS.target,
   })
