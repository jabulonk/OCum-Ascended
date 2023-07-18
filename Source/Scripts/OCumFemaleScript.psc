ScriptName OCumFemaleScript extends Quest

import OCumUtils
import OCumSceneDataUtils

; ------------------------ Properties and script wide Vars ------------------------ ;

Actor property PlayerRef auto

Sound property SquirtSound auto

Spell property SquirtSpell auto
Spell property SquirtSpell2 auto
Spell property SquirtSpell3 auto

OSexIntegrationMain property OStim auto

OCumScript property OCum auto


; ███████╗██╗   ██╗███████╗███╗   ██╗████████╗███████╗
; ██╔════╝██║   ██║██╔════╝████╗  ██║╚══██╔══╝██╔════╝
; █████╗  ██║   ██║█████╗  ██╔██╗ ██║   ██║   ███████╗
; ██╔══╝  ╚██╗ ██╔╝██╔══╝  ██║╚██╗██║   ██║   ╚════██║
; ███████╗ ╚████╔╝ ███████╗██║ ╚████║   ██║   ███████║
; ╚══════╝  ╚═══╝  ╚══════╝╚═╝  ╚═══╝   ╚═╝   ╚══════╝


Event OnInit()
	OnLoad()
EndEvent


Event OnLoad()
	WriteLog("OCum Female init")
	UnregisterForAllModEvents()

	OStim = OUtils.GetOStim()

	RegisterForModEvent("ostim_orgasm", "OStimOrgasm")
EndEvent


Event OStimOrgasm(string eventName, string strArg, float numArg, Form sender)
	Actor orgasmer = sender as Actor

	if OStim.IsFemale(orgasmer) && ChanceRoll(OCum.SquirtChance)
		String sceneID = strArg
		Squirt(orgasmer, sceneID)
	endif
EndEvent


; ██╗   ██╗████████╗██╗██╗     ███████╗
; ██║   ██║╚══██╔══╝██║██║     ██╔════╝
; ██║   ██║   ██║   ██║██║     ███████╗
; ██║   ██║   ██║   ██║██║     ╚════██║
; ╚██████╔╝   ██║   ██║███████╗███████║
;  ╚═════╝    ╚═╝   ╚═╝╚══════╝╚══════╝


Function SquirtShootFlow(Actor act)
	WriteLog("Squirt Shoot is of type Flow")
	PlaySound(act, SquirtSound)

	if ChanceRoll(50)
		SquirtSpell2.cast(act, act)
	else
		SquirtSpell3.cast(act, act)
	endif
EndFunction


Function SquirtShootSpurt(Actor act)
	WriteLog("Squirt Shoot is of type Spurt")
	PlaySound(act, SquirtSound)

	SquirtSpell.SetNthEffectDuration(0, Utility.RandomInt(1, 7))

	SquirtSpell.cast(act, act)
EndFunction


Function Squirt(Actor Act, String SceneID)
	WriteLog("Squirting")
	Act.SendModEvent("ocum_squirt", StrArg = SceneID)

	if ChanceRoll(50)
		SquirtShootSpurt(act)
	else
		SquirtShootFlow(act)
	endif
EndFunction
