extends Node
const upgrades = [
	["+1 Damage", "Increases damage by 1.", {Projectile.base_damage: 1}],
	["+2 Projectiles", "Increases projectile amount by 2.", {Projectile.amount: 2}],
	["Chain", "Projectiles bounce towards the closest enemy.", {Projectile.chain: true}],
	["+1 Split", "Projectiles split +1 more time after hitting an enemy", {Projectile.split: 1}],
]

func get_random() -> Array:
	return upgrades[randi_range(0,upgrades.size()-1)]
	
