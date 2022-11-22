Scriptname OCumMCMScript extends SKI_ConfigBase

; Settings
int setCleanCumEnterWater
int setDisableCumShot
int setDisableCumDecals
int setDisableInflation
int setDisableCumMeshes
int setCumRegenSpeed
int setCumCleanupTimer
int setInflationCleanupTimer
int setCumBarKey
int setRealisticCumMode
int setCleanCumDecals
int setSquirtChance
int setClearInflation
int setResetDefaults
int setDisableFacialsForElins
int setEnableHigherCumRegenSpeed
int setEnableDeleveledCumBarNPCs
int setEnableDeleveledCumBarPlayer
int setCumBarMaxAmountNPCs
int setCumBarMaxAmountPlayer
int setEnableFixedUterineVolumeNPCs
int setEnableFixedUterineVolumePlayer
int setUterineVolumeNPCs
int setUterineVolumePlayer

bool enableHigherCumRegenSpeed

OCumScript property OCum auto


event OnInit()
	parent.OnInit()

	Modname = "OCum Ascended"
endEvent


event OnGameReload()
	parent.onGameReload()
endevent


event OnPageReset(string page)
	SetCursorFillMode(TOP_TO_BOTTOM)

	AddColoredHeader("$ocum_header_main_settings")
	setDisableCumShot = AddToggleOption("$ocum_option_disable_cum_shots", OCum.disableCumshot)
	setDisableCumDecals = AddToggleOption("$ocum_option_disable_cum_decals", OCum.disableCumDecal)
	setDisableCumMeshes = AddToggleOption("$ocum_option_disable_cum_meshes", OCum.disableCumMeshes)
	setDisableInflation = AddToggleOption("$ocum_option_disable_cum_inflation", OCum.disableInflation)
	setDisableFacialsForElins = AddToggleOption("$ocum_option_disable_facials_elins", OCum.disableFacialsForElins)
	setCleanCumEnterWater = AddToggleOption("$ocum_option_clean_water_enter", OCum.cleanCumEnterWater)
	setRealisticCumMode = AddToggleOption("$ocum_option_realistic_cum_mode", OCum.realisticCumMode)
	setCumBarKey = AddKeyMapOption("$ocum_option_cum_bar_key", OCum.checkCumKey)
	AddEmptyOption()

	AddColoredHeader("$ocum_header_reset")
	setCleanCumDecals = AddToggleOption("$ocum_option_clean_cum_decals", false)
	setClearInflation = AddToggleOption("$ocum_option_clear_inflation", false)
	setResetDefaults = AddToggleOption("$ocum_option_reset_defaults", false)

	SetCursorPosition(1)

	AddColoredHeader("$ocum_header_adjustments")
	setSquirtChance = AddSliderOption("$ocum_option_squirt_chance", OCum.squirtChance, "{0}")
	setCumCleanupTimer = AddSliderOption("$ocum_option_cum_cleanup_timer", OCum.cumCleanupTimer, "{1}")
	setInflationCleanupTimer = AddSliderOption("$ocum_option_inflation_cleanup_timer", OCum.inflationCleanupTimer, "{1}")
	AddEmptyOption()

	setEnableHigherCumRegenSpeed = AddToggleOption("$ocum_option_enable_higher_cum_regen_speed", enableHigherCumRegenSpeed)
	setCumRegenSpeed = AddSliderOption("$ocum_option_cum_regen_speed", OCum.cumRegenSpeed, "{1}")

	AddEmptyOption()

	setEnableDeleveledCumBarNPCs = AddToggleOption("$ocum_option_enable_deleveled_cum_bar_npcs", OCum.enableDeleveledCumBarNPCs)
	setCumBarMaxAmountNPCs = AddSliderOption("$ocum_option_cum_bar_max_amount_npcs", OCum.cumBarMaxAmountNPCs, "{0}")

	AddEmptyOption()

	setEnableDeleveledCumBarPlayer = AddToggleOption("$ocum_option_enable_deleveled_cum_bar_player", OCum.enableDeleveledCumBarPlayer)
	setCumBarMaxAmountPlayer = AddSliderOption("$ocum_option_cum_bar_max_amount_player", OCum.cumBarMaxAmountPlayer, "{0}")

	AddEmptyOption()

	setEnableFixedUterineVolumeNPCs = AddToggleOption("$ocum_option_enable_fixed_uterine_volume_npcs", OCum.enableFixedUterineVolumeNPCs)
	setUterineVolumeNPCs = AddSliderOption("$ocum_option_uterine_volume_npcs", OCum.uterineVolumeNPCs, "{0}")

	AddEmptyOption()

	setEnableFixedUterineVolumePlayer = AddToggleOption("$ocum_option_enable_fixed_uterine_volume_player", OCum.enableFixedUterineVolumePlayer)
	setUterineVolumePlayer = AddSliderOption("$ocum_option_uterine_volume_player", OCum.uterineVolumePlayer, "{0}")

	AddEmptyOption()
endEvent


event OnOptionSelect(int option)
	if (option == setCleanCumEnterWater)
		OCum.cleanCumEnterWater = !OCum.cleanCumEnterWater
		SetToggleOptionValue(setCleanCumEnterWater, OCum.cleanCumEnterWater)
	elseif (option == setDisableCumShot)
		OCum.DisableCumshot = !OCum.DisableCumshot
		SetToggleOptionValue(setDisableCumShot, OCum.DisableCumshot)
	elseif (option == setDisableCumDecals)
		OCum.DisableCumDecal = !OCum.DisableCumDecal
		SetToggleOptionValue(setDisableCumDecals, OCum.DisableCumDecal)
	elseif (option == setDisableCumMeshes)
		OCum.disableCumMeshes = !OCum.disableCumMeshes
		SetToggleOptionValue(setDisableCumMeshes, OCum.disableCumMeshes)

		if (!OCum.disableCumMeshes)
			ShowMessage("$ocum_message_cum_meshes_warning", false)
		endif
	elseif (option == setDisableInflation)
		OCum.DisableInflation = !OCum.DisableInflation
		SetToggleOptionValue(setDisableInflation, OCum.DisableInflation)
	elseif (option == setDisableFacialsForElins)
		OCum.DisableFacialsForElins = !OCum.DisableFacialsForElins
		SetToggleOptionValue(setDisableFacialsForElins, OCum.DisableFacialsForElins)
	elseif (option == setRealisticCumMode)
		OCum.realisticCumMode = !OCum.realisticCumMode
		SetToggleOptionValue(setRealisticCumMode, OCum.realisticCumMode)
	elseif (option == setEnableHigherCumRegenSpeed)
		enableHigherCumRegenSpeed = !enableHigherCumRegenSpeed
		SetToggleOptionValue(setEnableHigherCumRegenSpeed, enableHigherCumRegenSpeed)
	elseif (option == setEnableDeleveledCumBarNPCs)
		OCum.enableDeleveledCumBarNPCs = !OCum.enableDeleveledCumBarNPCs
		SetToggleOptionValue(setEnableDeleveledCumBarNPCs, OCum.enableDeleveledCumBarNPCs)
	elseif (option == setEnableDeleveledCumBarPlayer)
		OCum.enableDeleveledCumBarPlayer = !OCum.enableDeleveledCumBarPlayer
		SetToggleOptionValue(setEnableDeleveledCumBarPlayer, OCum.enableDeleveledCumBarPlayer)
	elseif (option == setEnableFixedUterineVolumeNPCs)
		OCum.enableFixedUterineVolumeNPCs = !OCum.enableFixedUterineVolumeNPCs
		SetToggleOptionValue(setEnableFixedUterineVolumeNPCs, OCum.enableFixedUterineVolumeNPCs)
	elseif (option == setEnableFixedUterineVolumePlayer)
		OCum.enableFixedUterineVolumePlayer = !OCum.enableFixedUterineVolumePlayer
		SetToggleOptionValue(setEnableFixedUterineVolumePlayer, OCum.enableFixedUterineVolumePlayer)
	elseif (option == setCleanCumDecals)
		OCum.CleanCumTexturesFromAllActors()
		ShowMessage("$ocum_message_cum_cleaned", false)
	elseif (option == setClearInflation)
		OCum.RemoveBellyScaleFromAllActors()
		ShowMessage("$ocum_message_inflation_cleaned", false)
	elseif (option == setResetDefaults)
		ResetDefaults()
		ShowMessage("$ocum_message_defaults_reset", false)
	endIf
endEvent


event OnOptionKeyMapChange(int option, int keyCode, string conflictControl, string conflictName)
	If (option == setCumBarKey)
		bool continue = true

		if (keyCode != 1 && conflictControl != "")
			string msg

			if (conflictName != "")
				msg = "This key is already mapped to:\n\"" + conflictControl + "\"\n(" + conflictName + ")\n\nAre you sure you want to continue?"
			else
				msg = "This key is already mapped to:\n\"" + conflictControl + "\"\n\nAre you sure you want to continue?"
			endIf

			continue = ShowMessage(msg, true, "$ocum_message_box_option_yes", "$ocum_message_box_option_no")
		endIf

		if (continue)
			OCum.updateCheckCumKey(keyCode)
			SetKeymapOptionValue(setCumBarKey, keyCode)
		endIf
	EndIf
endEvent


event OnOptionSliderOpen(int option)
	If (option == setCumRegenSpeed)
		SetSliderDialogStartValue(OCum.cumRegenSpeed)

		if (!enableHigherCumRegenSpeed)
			SetSliderDialogDefaultValue(1.0)
			SetSliderDialogRange(0.1, 20)
			SetSliderDialogInterval(0.1)
		else
			SetSliderDialogDefaultValue(10.0)
			SetSliderDialogRange(1, 50.0)
			SetSliderDialogInterval(1)
		endif
	elseif (option == setSquirtChance)
		SetSliderDialogStartValue(OCum.squirtChance)
		SetSliderDialogDefaultValue(25.0)
		SetSliderDialogRange(0, 100)
		SetSliderDialogInterval(1)
	elseif (option == setCumCleanupTimer)
		SetSliderDialogStartValue(OCum.cumCleanupTimer)
		SetSliderDialogDefaultValue(5.0)
		SetSliderDialogRange(0.5, 60)
		SetSliderDialogInterval(0.5)
	elseif (option == setInflationCleanupTimer)
		SetSliderDialogStartValue(OCum.inflationCleanupTimer)
		SetSliderDialogDefaultValue(5.0)
		SetSliderDialogRange(0.5, 60)
		SetSliderDialogInterval(0.5)
	elseif (option == setCumBarMaxAmountNPCs)
		SetSliderDialogStartValue(OCum.cumBarMaxAmountNPCs)
		SetSliderDialogDefaultValue(52.0)
		SetSliderDialogRange(2, 200)
		SetSliderDialogInterval(1)
	elseif (option == setCumBarMaxAmountPlayer)
		SetSliderDialogStartValue(OCum.cumBarMaxAmountPlayer)
		SetSliderDialogDefaultValue(52.0)
		SetSliderDialogRange(2, 200)
		SetSliderDialogInterval(1)
	elseif (option == setUterineVolumeNPCs)
		SetSliderDialogStartValue(OCum.uterineVolumeNPCs)
		SetSliderDialogDefaultValue(30.0)
		SetSliderDialogRange(5, 100)
		SetSliderDialogInterval(1)
	elseif (option == setUterineVolumePlayer)
		SetSliderDialogStartValue(OCum.uterineVolumePlayer)
		SetSliderDialogDefaultValue(30.0)
		SetSliderDialogRange(5, 100)
		SetSliderDialogInterval(1)
	EndIf
endEvent


event OnOptionSliderAccept(int option, float value)
	If (option == setCumRegenSpeed)
		OCum.cumRegenSpeed = value
		SetSliderOptionValue(setCumRegenSpeed, value, "{1}")
	elseif (option == setSquirtChance)
		OCum.squirtChance = value as int
		SetSliderOptionValue(setSquirtChance, value, "{0}")
	elseif (option == setCumCleanupTimer)
		OCum.cumCleanupTimer = value
		OCum.OCumSpell.SetNthEffectDuration(0, (value * 60) as int)
		SetSliderOptionValue(setCumCleanupTimer, value, "{1}")
	elseif (option == setInflationCleanupTimer)
		OCum.inflationCleanupTimer = value
		OCum.OCumInflationSpell.SetNthEffectDuration(0, (value * 60) as int)
		SetSliderOptionValue(setInflationCleanupTimer, value, "{1}")
	elseif (option == setCumBarMaxAmountNPCs)
		OCum.cumBarMaxAmountNPCs = value
		SetSliderOptionValue(setCumBarMaxAmountNPCs, value, "{0}")
	elseif (option == setCumBarMaxAmountPlayer)
		OCum.cumBarMaxAmountPlayer = value
		SetSliderOptionValue(setCumBarMaxAmountPlayer, value, "{0}")
	elseif (option == setUterineVolumeNPCs)
		OCum.uterineVolumeNPCs = value
		SetSliderOptionValue(setUterineVolumeNPCs, value, "{0}")
	elseif (option == setUterineVolumePlayer)
		OCum.uterineVolumePlayer = value
		SetSliderOptionValue(setUterineVolumePlayer, value, "{0}")
	EndIf
endEvent


event OnOptionHighlight(int option)
	if (option == setCleanCumEnterWater)
		SetInfoText("$ocum_highlight_clean_water_enter")
	elseif (option == setDisableCumShot)
		SetInfoText("$ocum_highlight_disable_cum_shots")
	elseif (option == setDisableCumDecals)
		SetInfoText("$ocum_highlight_disable_cum_decals")
	elseif (option == setDisableCumMeshes)
		SetInfoText("$ocum_highlight_disable_cum_meshes")
	elseif (option == setDisableInflation)
		SetInfoText("$ocum_highlight_disable_cum_inflation")
	elseif (option == setDisableFacialsForElins)
		SetInfoText("$ocum_highlight_disable_facials_elins")
	elseif (option == setCumRegenSpeed)
		SetInfoText("$ocum_highlight_cum_regen_speed")
	elseif (option == setSquirtChance)
		SetInfoText("$ocum_highlight_squirt_chance")
	elseif (option == setCumCleanupTimer)
		SetInfoText("$ocum_highlight_cum_cleanup_timer")
	elseif (option == setInflationCleanupTimer)
		SetInfoText("$ocum_highlight_inflation_cleanup_timer")
	elseif (option == setCumBarKey)
		SetInfoText("$ocum_highlight_cum_bar_key")
	elseif (option == setRealisticCumMode)
		SetInfoText("$ocum_highlight_realistic_cum_mode")
	elseif (option == setCleanCumDecals)
		SetInfoText("$ocum_highlight_clean_cum_decals")
	elseif (option == setClearInflation)
		SetInfoText("$ocum_highlight_clear_inflation")
	elseif (option == setEnableHigherCumRegenSpeed)
		SetInfoText("$ocum_highlight_enable_higher_cum_regen_speed")
	elseif (option == setEnableDeleveledCumBarNPCs)
		SetInfoText("$ocum_highlight_enable_develed_cum_bar_npcs")
	elseif (option == setEnableDeleveledCumBarPlayer)
		SetInfoText("$ocum_highlight_enable_develed_cum_bar_player")
	elseif (option == setCumBarMaxAmountNPCs)
		SetInfoText("$ocum_highlight_cumbar_max_amount")
	elseif (option == setCumBarMaxAmountPlayer)
		SetInfoText("$ocum_highlight_cumbar_max_amount")
	elseif (option == setEnableFixedUterineVolumeNPCs)
		SetInfoText("$ocum_highlight_enable_fixed_uterine_volume_npcs")
	elseif (option == setEnableFixedUterineVolumePlayer)
		SetInfoText("$ocum_highlight_enable_fixed_uterine_volume_player")
	elseif (option == setUterineVolumeNPCs)
		SetInfoText("$ocum_highlight_uterine_volume_npcs")
	elseif (option == setUterineVolumePlayer)
		SetInfoText("$ocum_highlight_uterine_volume_player")
	endif
endEvent


; Shamelessly copied from OStim's OSexIntegrationMCM.psc
bool Color1
function AddColoredHeader(String In)
	string Blue = "#6699ff"
	string Pink = "#ff3389"
	string Color

	If Color1
		Color = Pink
		Color1 = False
	Else
		Color = Blue
		Color1 = True
	EndIf

	AddHeaderOption("<font color='" + Color +"'>" + In)
endFunction


function ResetDefaults()
	OCum.cleanCumEnterWater = true
	SetToggleOptionValue(setCleanCumEnterWater, OCum.cleanCumEnterWater)

	OCum.DisableCumshot = false
	SetToggleOptionValue(setDisableCumShot, OCum.disableCumshot)

	OCum.DisableCumDecal = false
	SetToggleOptionValue(setDisableCumDecals, OCum.disableCumDecal)

	OCum.disableCumMeshes = true
	SetToggleOptionValue(setDisableCumMeshes, OCum.disableCumMeshes)

	OCum.DisableInflation = false
	SetToggleOptionValue(setDisableInflation, OCum.disableInflation)

	OCum.DisableFacialsForElins = false
	SetToggleOptionValue(setDisableFacialsForElins, OCum.disableFacialsForElins)

	OCum.realisticCumMode = false
	SetToggleOptionValue(setRealisticCumMode, OCum.realisticCumMode)

	OCum.updateCheckCumKey(157) ; Right Control
	SetKeymapOptionValue(setCumBarKey, 157)

	enableHigherCumRegenSpeed = false
	SetToggleOptionValue(setEnableHigherCumRegenSpeed, enableHigherCumRegenSpeed)

	OCum.cumRegenSpeed = 1.0
	SetSliderOptionValue(setCumRegenSpeed, 1.0, "{1}")
	
	OCum.squirtChance = 25
	SetSliderOptionValue(setSquirtChance, 25.0, "{0}")

	OCum.cumCleanupTimer = 5
	OCum.OCumSpell.SetNthEffectDuration(0, 5 * 60)
	SetSliderOptionValue(setCumCleanupTimer, 5.0, "{1}")

	OCum.inflationCleanupTimer = 5
	OCum.OCumInflationSpell.SetNthEffectDuration(0, 5 * 60)
	SetSliderOptionValue(setInflationCleanupTimer, 5.0, "{1}")

	OCum.enableDeleveledCumBarNPCs = false
	SetToggleOptionValue(setEnableDeleveledCumBarNPCs, OCum.enableDeleveledCumBarNPCs)

	OCum.enableDeleveledCumBarPlayer = false
	SetToggleOptionValue(setEnableDeleveledCumBarPlayer, OCum.enableDeleveledCumBarPlayer)

	OCum.cumBarMaxAmountNPCs = 52.0
	SetSliderOptionValue(setCumBarMaxAmountNPCs, 52.0, "{0}")

	OCum.cumBarMaxAmountPlayer = 52.0
	SetSliderOptionValue(setCumBarMaxAmountPlayer, 52.0, "{0}")

	OCum.enableFixedUterineVolumeNPCs = false
	SetToggleOptionValue(setEnableFixedUterineVolumeNPCs, OCum.enableFixedUterineVolumeNPCs)

	OCum.enableFixedUterineVolumePlayer = false
	SetToggleOptionValue(setEnableFixedUterineVolumePlayer, OCum.enableFixedUterineVolumePlayer)

	OCum.uterineVolumeNPCs = 30.0
	SetSliderOptionValue(setUterineVolumeNPCs, 30.0, "{0}")

	OCum.uterineVolumePlayer = 30.0
	SetSliderOptionValue(setUterineVolumePlayer, 30.0, "{0}")
endFunction
