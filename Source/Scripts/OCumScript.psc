ScriptName OCumScript Extends OStimAddon Conditional

import OCumUtils
import OCumSceneDataUtils

; ------------------------ Properties and script wide Vars ------------------------ ;

string cumStoredKey
string lastCumCheckTimeKey

actor[] property cummedOnActs auto

OSexBar property CumBar auto
OBarsScript OBars

actor[] property currentSceneCummedOnActs auto

spell property OCumSpell auto

keyword property AppliedCumKeyword auto

int property checkCumKey auto
int property squirtChance auto
int property creampieChance auto
int property analpieChance auto

float property cumBarMaxAmountNPCs auto
float property cumBarMaxAmountPlayer auto
float property cumCleanupTimer auto
float property cumRegenSpeed auto

bool property disableCumshot auto
bool property disableCumDecal auto
bool property disableCumMeshes auto
bool property disableFacialsForElins auto
bool property cleanCumEnterWater auto

bool property isRemovingCumFromAllActors auto

GlobalVariable property GameDaysPassed auto


;  ██████╗  ██████╗██╗   ██╗███╗   ███╗
; ██╔═══██╗██╔════╝██║   ██║████╗ ████║
; ██║   ██║██║     ██║   ██║██╔████╔██║
; ██║   ██║██║     ██║   ██║██║╚██╔╝██║
; ╚██████╔╝╚██████╗╚██████╔╝██║ ╚═╝ ██║
;  ╚═════╝  ╚═════╝ ╚═════╝ ╚═╝     ╚═╝

; ------------------------ Main OCum logic functions ------------------------ ;


float Function GetCumStoredAmount(actor npc)
	if !ostim.IsFemale(npc)
		float lastCheckTime = GetNPCDataFloat(npc, LastCumCheckTimeKey)

		float currentTime = GameDaysPassed.GetValue()

		StoreNPCDataFloat(npc, LastCumCheckTimeKey, currentTime)

		if lastCheckTime <= 0
			float maxCum = GetMaxCumStoragePossible(npc)
			StoreNPCDataFloat(npc, CumStoredKey, maxCum)
			return maxCum
		endif

		float cum = GetNPCDataFloat(npc, CumStoredKey)

		; sperm will regen at a rate of max storage/day
		float timePassed = currentTime - lastCheckTime
		float max = GetMaxCumStoragePossible(npc)

		float cumToAdd = timePassed * max

		cum = cum + (cumToAdd * cumRegenSpeed)
		if cum > max
			cum = max
		endif

		StoreNPCDataFloat(npc, CumStoredKey, cum)

		return cum
	endif

	return 0.0
EndFunction


Function AdjustStoredCumAmount(actor npc, float amount, float currentAmount)
	float set
	float max = GetMaxCumStoragePossible(npc)

	if (currentAmount + amount) > max
		set = max
	elseif (currentAmount + amount) < 0
		set = 0
	else
		set = currentAmount + amount
	endif

	StoreNPCDataFloat(npc, CumStoredKey, set)
EndFunction


; ███████╗██╗   ██╗███████╗███╗   ██╗████████╗███████╗
; ██╔════╝██║   ██║██╔════╝████╗  ██║╚══██╔══╝██╔════╝
; █████╗  ██║   ██║█████╗  ██╔██╗ ██║   ██║   ███████╗
; ██╔══╝  ╚██╗ ██╔╝██╔══╝  ██║╚██╗██║   ██║   ╚════██║
; ███████╗ ╚████╔╝ ███████╗██║ ╚████║   ██║   ███████║
; ╚══════╝  ╚═══╝  ╚══════╝╚═╝  ╚═══╝   ╚═╝   ╚══════╝
; Events that add more features to OCum based on OStim scenes stages and player actions

Event OnInit()
	OnLoad()
EndEvent


Function OnLoad()
	CumStoredKey = "CumStoredAmountV2"
	LastCumCheckTimeKey = "CumLastCalcTimeV2"

	OStim = OUtils.GetOStim()
	PlayerRef = Game.GetPlayer()

	OBars = Ostim.GetBarScript()

	UnregisterForAllModEvents()

	RegisterForKey(CheckCumKey)
	OCumSpell.SetNthEffectDuration(0, (cumCleanupTimer * 60) as int)

	Utility.Wait(1)
	InitBar()
EndFunction


Event OnKeyDown(Int KeyPress)
	; Event which listens for the cum bar key press
	if (KeyPress != 1 && KeyPress == CheckCumKey)
		TempDisplayBar()
	endif
EndEvent


Event OnAnimationEvent(ObjectReference akSource, string asEventName)
	; clean cum when actor enters water
	if asEventName == "SoundPlay.FSTSwimSwim"
		Actor act = akSource as Actor

		if PapyrusUtil.CountActor(cummedOnActs, act) > 0
			if act.HasMagicEffectWithKeyWord(AppliedCumKeyword)
				act.DispelSpell(OCumSpell)
			else
				CleanCumTexturesFromActor(act, true)
			endif
		else
			; here mostly for safety, in theory it should never enter this else body
			UnregisterForAnimationEvent(act, "SoundPlay.FSTSwimSwim")
		endif
	endIf
endEvent


Event OnUpdate()
	if (OBars.IsBarVisible(CumBar))
		OBars.SetBarVisible(CumBar, False)
	endif
endEvent


;  ██████╗██╗   ██╗███╗   ███╗    ██████╗  █████╗ ██████╗ 
; ██╔════╝██║   ██║████╗ ████║    ██╔══██╗██╔══██╗██╔══██╗
; ██║     ██║   ██║██╔████╔██║    ██████╔╝███████║██████╔╝
; ██║     ██║   ██║██║╚██╔╝██║    ██╔══██╗██╔══██║██╔══██╗
; ╚██████╗╚██████╔╝██║ ╚═╝ ██║    ██████╔╝██║  ██║██║  ██║
;  ╚═════╝ ╚═════╝ ╚═╝     ╚═╝    ╚═════╝ ╚═╝  ╚═╝╚═╝  ╚═╝


Function InitBar()
	CumBar.HAnchor = "left"
	CumBar.VAnchor = "bottom"
	CumBar.X = 980.0
	CumBar.Alpha = 0.0
	CumBar.SetPercent(0.0)
	CumBar.FillDirection = "Left"

	CumBar.Y = 120.0
	CumBar.SetColors(0xb0b0b0, 0xfff5fd)

	OBars.SetBarVisible(CumBar, False)
EndFunction


Function TempDisplayBar()
	If !OBars.IsBarVisible(CumBar)
		float amount = GetCumStoredAmount(playerref)

		CumBar.SetPercent(amount / GetMaxCumStoragePossible(playerref))

		OBars.SetBarVisible(CumBar, True)

		; make bar disappear in 10 seconds
		RegisterForSingleUpdate(10.0)
	EndIf
Endfunction


; ██╗   ██╗████████╗██╗██╗     ███████╗
; ██║   ██║╚══██╔══╝██║██║     ██╔════╝
; ██║   ██║   ██║   ██║██║     ███████╗
; ██║   ██║   ██║   ██║██║     ╚════██║
; ╚██████╔╝   ██║   ██║███████╗███████║
;  ╚═════╝    ╚═╝   ╚═╝╚══════╝╚══════╝


Function updateCheckCumKey(int newKey)
	UnregisterForKey(CheckCumKey)

	CheckCumKey = newKey
	RegisterForKey(newKey)
EndFunction


Function StoreNPCDataFloat(actor npc, string keys, Float num)
	StorageUtil.SetFloatValue(npc, keys, num)
EndFunction


Float Function GetNPCDataFloat(actor npc, string keys)
	return StorageUtil.GetFloatValue(npc, keys, -1)
EndFunction

Function UnsetActorDataFloats(Actor Act)
	StorageUtil.UnsetFloatValue(Act, CumStoredKey)
	StorageUtil.UnsetFloatValue(Act, LastCumCheckTimeKey)
EndFunction


float Function GetMaxCumStoragePossible(actor npc)
	if npc == PlayerRef
		return cumBarMaxAmountPlayer
	else
		return cumBarMaxAmountNPCs
	endif
EndFunction


Function CleanCumTexturesFromActor(Actor Act, Bool RemoveActorFromCummedOnArrays)
	bool gender = OStim.AppearsFemale(Act)

	RemoveCumDecals(Act, gender)
	UnregisterForAnimationEvent(act, "SoundPlay.FSTSwimSwim")

	if RemoveActorFromCummedOnArrays
		cummedOnActs = PapyrusUtil.RemoveActor(cummedOnActs, act)
		currentSceneCummedOnActs = PapyrusUtil.RemoveActor(currentSceneCummedOnActs, act)
	endif
endFunction


Function CleanCumTexturesFromAllActors()
	isRemovingCumFromAllActors = true

	int i
	int max = cummedOnActs.Length

	actor act

	while i < max
		act = cummedOnActs[i]

		if act != none
			if act.HasMagicEffectWithKeyWord(AppliedCumKeyword)
				act.DispelSpell(OCumSpell)
			else
				CleanCumTexturesFromActor(act, false)
			endif
		endif

		i += 1
	endwhile

	cummedOnActs = PapyrusUtil.ResizeActorArray(cummedOnActs, 0)
	currentSceneCummedOnActs = PapyrusUtil.ResizeActorArray(currentSceneCummedOnActs, 0)

	isRemovingCumFromAllActors = false
EndFunction


Function RegisterForCleaningOnEnteringWater(actor act)
	UnregisterForAnimationEvent(act, "SoundPlay.FSTSwimSwim")

	if (cleanCumEnterWater)
		RegisterForAnimationEvent(act, "SoundPlay.FSTSwimSwim")
	endif
EndFunction
