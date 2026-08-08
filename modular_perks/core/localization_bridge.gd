class_name PerkLocalizationBridge
extends RefCounted


static func translate(host, key: String, fallback: String) -> String:
	if host != null and host.has_method("translate"):
		var value := String(host.translate(key, fallback)).strip_edges()
		if value != "" and value != key:
			return value
	return fallback
