
/datum/stat/dynamic_mode
	//population curbs, updated every minutes
	var/list/pop_levels = list()

	var/starting_threat_level = 0
	var/list/threat = list()

	var/list/round_start_rulesets = list()
	var/round_start_pop = 0

	var/list/successful_injections = list()//midround/latejoin rulesets should appear here
	var/list/faction_data = list() // data generated by faction's generate_statistics goes here
	var/list/role_data = list() // data generated by an antag role's generate_statistics goes here

/datum/stat/dynamic_mode/proc/update_population(var/datum/gamemode/dynamic/mode)
	var/datum/stat/pop_level/new_pop_level = new
	new_pop_level.time = time2text(world.realtime, "YYYY-MM-DD hh:mm:ss")
	for(var/mob/M in player_list)
		if(M.client)
			new_pop_level.total_server_pop += 1
	new_pop_level.living_players = mode.living_players.len
	new_pop_level.living_antags = mode.living_antags.len
	new_pop_level.dead_players = mode.dead_players.len
	new_pop_level.observers = mode.list_observers.len
	pop_levels.Add(new_pop_level)

/datum/stat/dynamic_mode/proc/successful_injection(var/datum/dynamic_ruleset/ruleset)
	var/datum/stat/successful_injection/new_injection = new
	new_injection.time = time2text(world.realtime, "YYYY-MM-DD hh:mm:ss")
	new_injection.name = ruleset.name
	successful_injections.Add(new_injection)

/datum/stat/dynamic_mode/proc/measure_threat(var/new_threat)
	var/datum/stat/threat_measure/new_threat_mesure = new
	new_threat_mesure.time = time2text(world.realtime, "YYYY-MM-DD hh:mm:ss")
	new_threat_mesure.threat = new_threat
	threat.Add(new_threat_mesure)

/datum/stat/pop_level
	var/time = ""
	var/total_server_pop = 0
	var/living_players = 0
	var/living_antags = 0
	var/dead_players = 0
	var/observers = 0

/datum/stat/successful_injection
	var/time = ""
	var/name = ""

/datum/stat/threat_measure
	var/time = ""
	var/threat = 0


// General role-related stats
/datum/stat/role
	var/name = null
	var/faction_id = null
	var/mind_name = null
	var/mind_key = null
	var/list/objectives = list()
	var/victory = FALSE

/datum/stat/role/proc/generate_statistics(var/datum/role/R, var/victorious)
	name = R.name
	faction_id = R.faction.ID
	mind_name = STRIP_NEWLINE(R.antag.name)
	mind_key = ckey(R.antag.key)
	victory = victorious

	for(var/datum/objective/O in R.objectives.GetObjectives())
		objectives.Add(new /datum/stat/role_objective)

/datum/stat/role_objective
	var/obj_type = null
	var/name = null
	var/desc = null
	var/belongs_to_faction = null
	var/target = null
	var/is_fulfilled = FALSE

/datum/stat/role_objective/New(var/datum/objective/O)
	obj_type = O.type
	name = O.name
	desc = O.explanation_text
	belongs_to_faction = O.faction.ID
	is_fulfilled = O.IsFulfilled()
	if(istype(O, /datum/objective/target))
		var/datum/objective/target/TO = O
		target = TO.target.name

// Faction related stats
/datum/stat/faction
	var/id = null
	var/name = null
	var/desc = null
	var/faction_type = null // typepath
	var/stage = null
	var/victory = FALSE
	var/minor_victory = FALSE

/datum/stat/faction/proc/generate_statistics(var/datum/faction/F)
	id = F.ID
	name = F.name
	desc = F.desc
	faction_type = F.type
	stage = F.stage
	// I could combine these victory values, but I'd rather have future-proofing
	minor_victory = F.minor_victory
	victory = F.check_win()

/datum/stat/faction/malf
	var/list/datum/stat/malf_module_purchase/modules = list()
	var/shunted = FALSE

/datum/stat/malf_module_purchase
	var/typepath = null
	var/module_name = null
	var/cost = null

/datum/stat/malf_module_purchase/New(var/datum/AI_Module/M)
	typepath = M.type
	module_name = M.module_name
	cost = M.cost

/datum/stat/faction/blob
	// count of all blob tiles grown, includes structures built on top of blob tiles
	var/blobs_grown_total = 0
	// same as above, but only living blob tiles
	var/blobs_round_end = 0
	// count of all built structures
	var/datum/stat/faction_data/blob/structure_counts/built_structures = new

/datum/stat/faction/blob/generate_statistics(/var/datum/faction/blob_conglomerate/BF)
	..(BF)
	//we're using global pre-existing global vars here: structure counts are collected
	//throughout the round elsewhere
	blobs_grown_total = blob_tiles_grown_total
	blobs_round_end = blobs.len

/datum/stat/faction_data/blob/structure_counts
	var/factories = 0
	var/nodes = 0
	var/resgens = 0
	var/shields = 0
	var/cores = 0

/datum/stat/role/wizard
	var/list/spellbook_purchases = list()

/datum/stat/role/vampire
	var/list/powers = list()
	var/blood_total = 0

/datum/stat/role/vampire/generate_statistics(var/datum/role/vampire/V)
	..(V)
	for(var/datum/power/P in V.powers)
		powers.Add(P.type)
	blood_total = V.blood_total

/datum/stat/role/revolutionary
// future proofing don't mind me

/datum/stat/role/revolutionary/leader
	var/recruits_converted = 0
	var/flashes_created = 0

/datum/stat/role/ninja
	var/shuriken_thrown = 0
	var/times_charged_sword = 0
	var/stealth_posters_posted = 0

/datum/stat/role/catbeast
	var/ticks_survived = 0
	var/threat_generated = 0
	var/threat_level_inflated = 0
	var/list/areas_defiled = list()

/datum/stat/role/catbeast/generate_statistics(var/datum/role/catbeast/C)
	..(C)
	ticks_survived = C.ticks_survived
	threat_generated = C.threat_generated
	threat_level_inflated = C.threat_level_inflated
	areas_defiled = C.areas_defiled
