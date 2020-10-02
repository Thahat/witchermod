local Entity = _radiant.om.Entity
local Point3 = _radiant.csg.Point3

local AttackAcolyteRangedPathToTarget = class()

AttackAcolyteRangedPathToTarget.name = 'attack acolyte ranged path to target'
AttackAcolyteRangedPathToTarget.does = 'stonehearth:combat:attack'
AttackAcolyteRangedPathToTarget.args = {
   target = Entity
}
AttackAcolyteRangedPathToTarget.version = 2
AttackAcolyteRangedPathToTarget.priority = 2
AttackAcolyteRangedPathToTarget.weight = 1

local ai = stonehearth.ai
return ai:create_compound_action(AttackAcolyteRangedPathToTarget)
   :execute('stonehearth:combat:abort_on_leash_changed')
   :execute('stonehearth:combat:chase_entity_until_targetable', {
      target = ai.ARGS.target,
   })
   :execute('stonehearth:bump_allies', {
      distance = 2,
   })
   :execute('witchermod:combat:attack_acolyte_ranged', {
      target = ai.ARGS.target,
   })
