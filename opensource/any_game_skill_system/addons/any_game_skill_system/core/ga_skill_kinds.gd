class_name GaSkillKinds

## Shared enums for LoL-style skill archetypes.

enum Kind {
	ACTIVE, ## Cast with input; may have cooldown and/or cost.
	PASSIVE, ## Applied on register; not castable from bar.
	TOGGLE, ## Input toggles on/off; may tick while active.
	ALWAYS_ACTIVE, ## Always running after register; not castable.
}

enum CooldownMode {
	TIMED, ## Standard cooldown after cast (cooldown > 0).
	NONE, ## No cooldown — spammable if cost/conditions allow.
}

enum CostMode {
	NONE, ## Bedelsiz — no resource spent.
	RESOURCE, ## Bedelli — spends resource_id amount on cast/toggle-on.
}

enum CooldownTrigger {
	ON_ACTIVATE,
	ON_DEACTIVATE,
	NEVER,
}


static func kind_is_castable(kind: Kind) -> bool:
	return kind == Kind.ACTIVE or kind == Kind.TOGGLE


static func kind_auto_starts(kind: Kind) -> bool:
	return kind == Kind.PASSIVE or kind == Kind.ALWAYS_ACTIVE
