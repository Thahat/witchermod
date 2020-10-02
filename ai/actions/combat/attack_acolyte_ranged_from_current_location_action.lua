local Entity = _radiant.om.Entity

local AttackAcolyteRangedFromCurrentLocation = class()

AttackAcolyteRangedFromCurrentLocation.name = 'attack acolyte ranged from currrent location'
AttackAcolyteRangedFromCurrentLocation.does = 'stonehearth:combat:attack'
AttackAcolyteRangedFromCurrentLocation.args = {
   target = Entity
}
AttackAcolyteRangedFromCurrentLocation.version = 2
AttackAcolyteRangedFromCurrentLocation.priority = 4
AttackAcolyteRangedFromCurrentLocation.weight = 1

local ai = stonehearth.ai
return ai:create_compound_action(AttackAcolyteRangedFromCurrentLocation)
   :execute('stonehearth:combat:check_entity_targetable', {
      target = ai.ARGS.target,
   })
   :execute('stonehearth:bump_allies', {
      distance = 2,
   })
   :execute('witchermod:combat:attack_acolyte_ranged', {
      target = ai.ARGS.target,
   })
