extends Node

#attributes: speed, base_damage, size, lifespan, hits, amount, spread_angle, piercing,
# gravity, split, split_angle, chain, homing, homing_distance
const upgrades = [
	["+1 Damage", "Increases damage by 1.", {Projectile.base_damage: 1}],
	["+2 Projectiles", "Increases projectile amount by 2.", {Projectile.amount: 2}],
	["Chain", "Projectiles bounce towards the closest enemy.", {Projectile.chain: true, Projectile.hits: 1}],
	["+1 Split", "Projectiles split +1 more time after hitting an enemy", {Projectile.split: 1}],
	["+1 Hits", "Projectiles can hit one more enemy before disappearing.", {Projectile.hits: 1}],
	["+0.2 Homing", "Projectiles home in on the closest enemy.", {Projectile.homing: 0.2}],
	["Piercing", "Projectiles pierce through enemies.", {Projectile.piercing: true, Projectile.hits: 1}],
	["+5 Speed", "Increases projectile speed by 5.", {Projectile.speed: 5}],
	["+1 Size", "Increases projectile size by 1.", {Projectile.size: 1}],
	#["+1 Lifespan", "Increases projectile lifespan by 1 second.", {Projectile.lifespan: 1}],
	#["+5 Spread Angle", "Increases projectile spread angle by 5 degrees.", {Projectile.spread_angle: 5}],
	#["+10 Homing Distance", "Increases homing distance by 10 units.", {Projectile.homing_distance: 10}]
]

func get_random() -> Array:
	return upgrades[randi_range(0,upgrades.size()-1)]
	
