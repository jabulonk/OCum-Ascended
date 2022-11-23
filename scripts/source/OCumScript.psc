ScriptName OCumScript Extends OStimAddon Conditional

; ------------------------ Properties and script wide Vars ------------------------ ;

string cumStoredKey
string lastCumCheckTimeKey
string maxCumVolumeKey

int cumPatternNone = 0
int cumPatternVaginal = 1
int cumPatternOral = 2
int cumPatternAnal = 3
int cumPatternBoobOral = 4
int cumPatternFeet = 5
int cumPatternVaginalPullout = 6
int cumPatternAnalPullout = 7

string faceNode = "R Breast04"
string assNode = "NPC RT Anus2"
string genitalsNode = "NPC Genitals06 [Gen06]"
string genitalsFemaleNode = "NPC Genitals02 [Gen02]"

actor[] cummedOnActs
actor[] bellyInflationActs

actor domActor
actor subActor
actor thirdActor

Osexbar CumBar

race teraElinRace
race teraElinRaceVampire

actor[] property currentSceneCummedOnActs auto
actor[] property currentSceneBellyInflationActs auto
actor[] actorsWithCumMeshes
form[] cumMeshesEquipped

spell property cumSpell1 auto
spell property cumSpell2 auto
spell property cumSpell3 auto
spell property cumSpell4 auto
spell property OCumSpell auto
spell property OCumInflationSpell auto
spell property squirtSpell auto
spell property squirtSpell2 auto
spell property squirtSpell3 auto

magicEffect property OCumMagicEffect auto

Activator property CumLauncher auto

armor property UrethraNode auto

armor property CumMeshSemen01 auto
armor property CumMeshSemen02 auto
armor property CumMeshBreast01 auto
armor property CumMeshBreast02 auto
armor property CumMeshBelly01 auto
armor property CumMeshBelly02 auto
armor property CumMeshButt01 auto
armor property CumMeshButt02 auto
armor property CumMeshPussy01 auto

sound property cumSound auto
sound property squirtSound auto
sound property femaleGasp auto

keyword property AppliedCumKeyword auto
keyword property AppliedInflationKeyword auto

bool barVisible

int property checkCumKey auto
int property squirtChance auto

float property cumBarMaxAmountNPCs auto
float property cumBarMaxAmountPlayer auto
float property uterineVolumeNPCs auto
float property uterineVolumePlayer auto
float property cumCleanupTimer auto
float property inflationCleanupTimer auto
float property cumRegenSpeed auto

bool property disableInflation auto
bool property disableCumshot auto
bool property disableCumDecal auto
bool property disableCumMeshes auto
bool property disableFacialsForElins auto
bool property realisticCumMode auto
bool property cleanCumEnterWater auto
bool property enableDeleveledCumBarNPCs auto
bool property enableDeleveledCumBarPlayer auto
bool property enableFixedUterineVolumeNPCs auto
bool property enableFixedUterineVolumePlayer auto

bool property isRemovingCumFromAllActors auto
bool property isRemovingInflationFromAllActors auto


;  ██████╗  ██████╗██╗   ██╗███╗   ███╗
; ██╔═══██╗██╔════╝██║   ██║████╗ ████║
; ██║   ██║██║     ██║   ██║██╔████╔██║
; ██║   ██║██║     ██║   ██║██║╚██╔╝██║
; ╚██████╔╝╚██████╗╚██████╔╝██║ ╚═╝ ██║
;  ╚═════╝  ╚═════╝ ╚═════╝ ╚═╝     ╚═╝

; ------------------------ Main OCum logic functions ------------------------ ;

float Function GetCumStoredAmount(actor npc)
	float lastCheckTime = GetNPCDataFloat(npc, LastCumCheckTimeKey)
	StoreNPCDataFloat(npc, LastCumCheckTimeKey, utility.GetCurrentGameTime())

	if ostim.IsFemale(npc)
		if lastCheckTime == -1 ; never calculated
			StoreNPCDataFloat(npc, CumStoredKey, 0.0)
			return 0
		else
			float cum = GetNPCDataFloat(npc, CumStoredKey)

			; intervaginal sperm will disolve at a rate of 1ml/2hrs (.166 days = 4 hours)
			float currenttime = Utility.GetCurrentGameTime()
			float timePassed = currenttime - lastCheckTime
			float cumToRemove = (timePassed / 0.083)

			writelog(timePassed)

			float max = GetMaxCumStoragePossible(npc)

			if cum > max ; cum overflow drains at double speed and gets special math
				if (cum - cumToRemove) < max ; removing current cum takes you under the limit
					float overflow = cum - max

					cumToRemove += (overflow/2) ; halve the overflow and add it to the amount, so the overflow part of the equation drains at double speed
				elseif (cum - (cumToRemove * 2)) > max ; there is a lot of overflow and we're still going through it
					cumToRemove *= 2 ; just make it drain at double speed
				elseif (cum - (cumToRemove * 2)) < max ;doing normal double-drain math takes you under the limit, need to correct
					float overflow = cum - max

					float a = (cumToRemove * 2) - overflow ; how far under the max we would go with normal double-drain math, the "underflow"
					a = a/2 ; halve the underflow since it drains at half speed compared to overflow

					cumToRemove = (cumToRemove * 2) - a ; subtract the underflow here so it normals out
				endif
			endif

			cum = cum - cumToRemove

			if cum < 0
				cum = 0
			endif

			StoreNPCDataFloat(npc, CumStoredKey, cum)

			return cum
		endif
	else
		float cum = GetNPCDataFloat(npc, CumStoredKey)
		; sperm will regen at a rate of max storage/day
		float currenttime = Utility.GetCurrentGameTime()
		float timePassed = currenttime - lastCheckTime
		float max = GetMaxCumStoragePossible(npc)

		float cumToAdd = timePassed * max

		cum = cum + (cumToAdd * cumRegenSpeed)
		if cum > max
			cum = max
		endif

		StoreNPCDataFloat(npc, CumStoredKey, cum)
		return cum
	endif
EndFunction


Function AdjustStoredCumAmount(actor npc, float amount, bool isFemalePartner)
	float set
	float current = GetCumStoredAmount(npc)
	float max = GetMaxCumStoragePossible(npc)

	if (current + amount) > max
		if ostim.IsFemale(npc)
			set = current + amount
			float ratio = set / max
			ratio -= 1
			float inflation = ratio * 0.6
			if inflation > 0.6
				inflation = 0.6
			EndIf
			if !disableInflation && isFemalePartner
				SetBellyScale(npc, inflation)
			endif
			if (set > (max * 2.1))
				set = max * 2.1
			endif
		else
			set = max
		endif
	elseif (current + amount) < 0
		set = 0
	else
		set = current + amount
	endif

	StoreNPCDataFloat(npc, CumStoredKey, set)
EndFunction


Function FireCumBlast(objectreference base, ObjectReference angle, int amount, actor act)
	writelog("FireCumBlast")
	spell cum
	if amount == 1
		cum = cumSpell1
	elseif amount == 2
		cum = cumSpell2
	elseif amount == 3
		cum = cumSpell3
	elseif amount == 4
		cum = cumSpell4
	endif

	cum.Cast(base, aktarget = angle)
	ostim.PlaySound(act, cumsound)

	; Sounds from:
	; https://freesound.org/people/j1987/sounds/106395/
	; https://freesound.org/people/Intimidated/sounds/74511/

	; https://freesound.org/people/Lukeo135/sounds/530617/
	; https://freesound.org/people/nicklas3799/sounds/467348/
EndFunction


Function CumShoot(actor act, float amountML)
	writelog("CumShoot")
	SendModEvent("ocum_cum", NumArg = amountML)

	if disableCumShot
		return
	endif

	; ---  By Migal: stop spurting through head and body by stopping cum shoots in certain animation classes
	string AClass = ostim.GetCurrentAnimationClass()
	if (AClass == "BJ") || (AClass == "ApPJ") || (AClass == "HhBJ") || (AClass == "VBJ") || (AClass == "Sx") || (AClass == "An")
		return
	endif		

	int size = GetLoadSizeFromML(amountml)
	if size == 0
		return
	endif

	int numSpurts
	float Frequency
	int doubleFireChance = 15
	int tripleFireChance = 10
	int inaccuracy = 60

	if size == 1
		Frequency = OSANative.RandomFloat(0.6, 1.0)
		inaccuracy = 40
	elseif size == 2
		Frequency = OSANative.RandomFloat(0.2, 0.5 )
		inaccuracy = 45
	elseif size == 3
		Frequency = OSANative.RandomFloat(0.1, 0.3)
		inaccuracy = 55
	elseif size == 4
		Frequency = OSANative.RandomFloat(0.1, 0.3)
		doubleFireChance = 85
		tripleFireChance = 30
		inaccuracy = 60
	endif

	numSpurts = Math.ceiling(amountML) + 2

	SetUrethra(act)
	int i = 1
	ObjectReference caster = act.PlaceAtMe(CumLauncher)
	ObjectReference target = act.PlaceAtMe(CumLauncher)  ; to aim the spell in the correct direction
	Float[] uPos = new Float[3]
	Float[] uRM = new Float[9]
	Float targetX
	float targetY
	float targetZ
	NetImmerse.GetNodeWorldPosition(act, "Urethra", uPos, False) ;setting arrays like this is possible apparently...........
	caster.SetPosition(uPos[0], uPos[1], uPos[2])
	NetImmerse.GetNodeWorldRotationMatrix(act, "Urethra", uRM, False)  ; (uRM[1] uRM[4] uRM[7]) is the direction vector for the spurts to be launched (local y axis of the node)

	while (i < numSpurts) && ostim.AnimationRunning()

		;aiming
		targetX = uPos[0] + uRM[1] * 200.0 + OSANative.RandomFloat(0-inaccuracy, inaccuracy)
		targetY = uPos[1] + uRM[4] * 200.0 + OSANative.RandomFloat(0-inaccuracy, inaccuracy)
		targetZ = uPos[2] + uRM[7] * 200.0 + OSANative.RandomFloat(-10.0, 10.0) - ((i as Float) / (numSpurts as Float) - 0.5) * 180.0  ; later spurts fly lower, and (usually) less distance
		target.SetPosition(targetX, targetY, targetZ)

		bool doublefire = outils.ChanceRoll(doubleFireChance)
		bool tripleFire = false
		if doublefire
			tripleFire = outils.ChanceRoll(tripleFireChance)
		endif

		FireCumBlast(caster, target, OSANative.RandomInt(1, 4), act)

		if doublefire
			targetX = targetX + OSANative.RandomFloat(0-inaccuracy, inaccuracy)
			targetY = targetY + OSANative.RandomFloat(0-inaccuracy, inaccuracy)
			target.SetPosition(targetX, targetY, targetZ)

			Utility.Wait(OSANative.RandomFloat(0.025, 0.075))
			FireCumBlast(caster, target, OSANative.RandomInt(1, 4), act)
			if tripleFire
				targetX = targetX + OSANative.RandomFloat(0-inaccuracy, inaccuracy)
				targetY = targetY + OSANative.RandomFloat(0-inaccuracy, inaccuracy)
				target.SetPosition(targetX, targetY, targetZ)

				Utility.Wait(OSANative.RandomFloat(0.025, 0.075))
				FireCumBlast(caster, target, OSANative.RandomInt(1, 4), act)
			endif
		endif


		Utility.Wait(Frequency)

	i += 1
	EndWhile

	caster.delete()
	target.delete()
EndFunction


Function SquirtShootFlow(actor act)
	writelog("SquirtShootFlow")
	ostim.PlaySound(act, squirtsound)

	if OUtils.ChanceRoll(50)
		squirtSpell2.cast(act, act)
	else
		squirtSpell3.cast(act, act)
	endif
EndFunction


Function SquirtShootSpurt(actor act)
	writelog("SquirtShootSpurt")
	ostim.PlaySound(act, squirtsound)

	squirtSpell.SetNthEffectDuration(0, OSANative.RandomInt(1, 7))

	squirtSpell.cast(act, act)
EndFunction


Function Squirt(actor act)
	writelog("Squirting")
	SendModEvent("ocum_squirt")

	if OUtils.ChanceRoll(50)
		SquirtShootSpurt(act)
	else
		SquirtShootFlow(act)
	endif
EndFunction


Function ApplyCumVaginal(actor sub, int intensity)
	if realisticCumMode
		CumOntoArea(sub, "Vaginal" + OSANative.RandomInt(1, 8))
	elseif intensity < 3
		CumOntoArea(sub, "Vaginal" + OSANative.RandomInt(1, 10))
	elseif intensity == 3
		CumOntoArea(sub, "Vaginal" + OSANative.RandomInt(11, 15))
	elseif intensity == 4
		CumOntoArea(sub, "Vaginal" + OSANative.RandomInt(13, 18))
	endif

	if !disableCumMeshes
		EquipCumMesh(sub, CumMeshPussy01)
	endif
EndFunction


Function ApplyCumOral(actor sub, int intensity)
	if realisticCumMode
		CumOntoArea(sub, "Facial" + OSANative.RandomInt(1, 8), "Face")
	elseif intensity == 1
		CumOntoArea(sub, "Facial" + OSANative.RandomInt(1, 4), "Face")
	elseif intensity == 2
		CumOntoArea(sub, "Facial" + OSANative.RandomInt(5, 7), "Face")
	elseif intensity == 3
		CumOntoArea(sub, "Facial" + OSANative.RandomInt(8, 11), "Face")
	elseif intensity == 4
		CumOntoArea(sub, "Facial" + OSANative.RandomInt(11, 16), "Face")
	endif
EndFunction


Function ApplyCumAnal(actor sub, int intensity)
	if realisticCumMode
		CumOntoArea(sub, "AnalSprinkle2")
	elseif intensity == 1
		if outils.ChanceRoll(50)
			CumOntoArea(sub, "AnalSprinkle1")
		else
			CumOntoArea(sub, "AnalSprinkle2")
		endif
	elseif intensity == 2
		CumOntoArea(sub, "Anal" + OSANative.RandomInt(1, 3))
	elseif intensity == 3
		CumOntoArea(sub, "Anal" + OSANative.RandomInt(1, 3))
		CumOntoArea(sub, "AnalHeavy1")
	else
		CumOntoArea(sub, "Anal" + OSANative.RandomInt(1, 3))
		if outils.ChanceRoll(50)
			CumOntoArea(sub, "AnalHeavy2")
		else
			CumOntoArea(sub, "AnalHeavy3")
		endif
	endif

	if !disableCumMeshes
		if outils.ChanceRoll(50)
			EquipCumMesh(sub, CumMeshButt01)
		else
			EquipCumMesh(sub, CumMeshButt02)
		endif
	endif
EndFunction


Function ApplyCumBoob(actor sub, int intensity)
	if intensity == 1
		if outils.ChanceRoll(50)
			CumOntoArea(sub, "Breast1")
		else
			CumOntoArea(sub, "Breast2")
		endif
		if outils.ChanceRoll(50)
			CumOntoArea(sub, "Facial" + OSANative.RandomInt(1, 2), "Face")
		endif
	elseif intensity == 2
		CumOntoArea(sub, "Facial" + OSANative.RandomInt(1, 3), "Face")
		CumOntoArea(sub, "Breast" + OSANative.RandomInt(3, 8))
	elseif intensity == 3
		CumOntoArea(sub, "Facial" + OSANative.RandomInt(1, 5), "Face")
		CumOntoArea(sub, "Breast" + OSANative.RandomInt(3, 9))
	else
		CumOntoArea(sub, "Facial" + OSANative.RandomInt(1, 7), "Face")
		CumOntoArea(sub, "Breast" + OSANative.RandomInt(3, 11))
	endif

	if !disableCumMeshes
		if outils.ChanceRoll(50)
			EquipCumMesh(sub, CumMeshBreast01)
		else
			EquipCumMesh(sub, CumMeshBreast02)
		endif
	endif
EndFunction


Function ApplyCumFeet(actor sub, int intensity)
	if intensity == 1
		CumOntoArea(sub, "Feet1", "Feet")
	elseif intensity == 2
		CumOntoArea(sub, "Feet2", "Feet")
	elseif intensity == 3
		CumOntoArea(sub, "Legs1")
		CumOntoArea(sub, "Feet3", "Feet")
	else
		CumOntoArea(sub, "Feet3", "Feet")
		if outils.ChanceRoll(50)
			CumOntoArea(sub, "Legs2")
		else
			CumOntoArea(sub, "Legs3")
		endif
	endif
EndFunction


Function ApplyCumVaginalPullout(actor sub, int intensity)
	if realisticCumMode
		if outils.ChanceRoll(50)
			CumOntoArea(sub, "VaginalBoob" + OSANative.RandomInt(1, 2))
		else
			CumOntoArea(sub, "Vaginal" + OSANative.RandomInt(1, 18))
			CumOntoArea(sub, "Belly" + OSANative.RandomInt(1, 4))
			if outils.ChanceRoll(50)
				CumOntoArea(sub, "Breast" + OSANative.RandomInt(1, 8))
			endif
		endif
	elseif intensity == 1
		CumOntoArea(sub, "Belly" + OSANative.RandomInt(1, 2))
		CumOntoArea(sub, "Vaginal" + OSANative.RandomInt(1, 9))
	elseif intensity == 2
		CumOntoArea(sub, "Breast" + OSANative.RandomInt(1, 5))
		CumOntoArea(sub, "Belly3")
		CumOntoArea(sub, "Vaginal" + OSANative.RandomInt(9, 11))
	elseif intensity == 3
		CumOntoArea(sub, "Breast" + OSANative.RandomInt(5, 7))
		CumOntoArea(sub, "Belly" + OSANative.RandomInt(3, 5))
		CumOntoArea(sub, "Vaginal" + OSANative.RandomInt(11, 15))
	else
		if outils.ChanceRoll(50)
			CumOntoArea(sub, "VaginalBoob" + OSANative.RandomInt(1, 2))
		else
			CumOntoArea(sub, "Breast" + OSANative.RandomInt(7, 11))
			CumOntoArea(sub, "Belly" + OSANative.RandomInt(4, 6))
			CumOntoArea(sub, "Vaginal" + OSANative.RandomInt(15, 18))
		endif
	endif

	if !disableCumMeshes
		if intensity > 3 && !realisticCumMode
			if outils.ChanceRoll(50)
				EquipCumMesh(sub, CumMeshSemen01)
			else
				EquipCumMesh(sub, CumMeshSemen02)
			endif
		else
			EquipCumMesh(sub, CumMeshPussy01)

			if outils.ChanceRoll(50)
				EquipCumMesh(sub, CumMeshBreast01)
				EquipCumMesh(sub, CumMeshBelly01)
			else
				EquipCumMesh(sub, CumMeshBreast02)
				EquipCumMesh(sub, CumMeshBelly02)
			endif
		endif
	endif
EndFunction


Function ApplyCumAnalPullout(actor sub, int intensity)
	if realisticCumMode
		CumOntoArea(sub, "AnalHeavy" + OSANative.RandomInt(1, 3))
		if outils.ChanceRoll(50)
			CumOntoArea(sub, "Back" + OSANative.RandomInt(1, 3))
		endif
	elseif intensity == 1
		if outils.ChanceRoll(50)
			CumOntoArea(sub, "AnalSprinkle1")
		else
			CumOntoArea(sub, "AnalSprinkle2")
		endif
		CumOntoArea(sub, "Back1")
	elseif intensity == 2
		CumOntoArea(sub, "Anal" + OSANative.RandomInt(1, 3))
		CumOntoArea(sub, "Back2")
	elseif intensity == 3
		CumOntoArea(sub, "AnalHeavy1")
		CumOntoArea(sub, "Back3")
	elseif intensity == 4
		CumOntoArea(sub, "Back3")
		CumOntoArea(sub, "Back4")
	endif

	if !disableCumMeshes
		if outils.ChanceRoll(50)
			EquipCumMesh(sub, CumMeshButt01)
		else
			EquipCumMesh(sub, CumMeshButt02)
		endif
	endif
EndFunction


Function ApplyCumHands(actor sub)
	; the Feet3 texture looks decent on Hands
	; unfortunately, there are no cum textures for Hands in specific
	CumOntoArea(sub, "Feet3", "Hands")
EndFunction


Function ApplyCumAsNecessary(actor cummedAct, float amountML)
	int intensity = GetLoadSizeFromML(amountML)

	if intensity == 0
		return
	endif
	writelog("Applying cum")

	string oclass = ostim.GetCurrentAnimationClass()

	; if animation class is handjob of any sort, also apply cum to hands
	if (oclass == "HJ") || (oclass == "VHJ") || (oclass == "DHJ") || (oclass == "ApHJ")
		ApplyCumHands(cummedAct)
	endif

	int pattern = GetCumPattern()

	if pattern == cumPatternVaginal
		ApplyCumVaginal(cummedAct, intensity)
	elseif pattern == cumPatternOral
		if (disableFacialsForElins)
			Race cummedActRace = cummedAct.GetRace()

			; don't apply facials to Tera Elin race if it is set like that on MCM
			; Elins use a different face map, so facial textures may look bad on them
			if (teraElinRace && teraElinRaceVampire && (cummedActRace == teraElinRace || cummedActRace == teraElinRaceVampire))
				writelog("Cummed actor is an Elin, not applying facial texture")
				return
			endif
		endif

		ApplyCumOral(cummedAct, intensity)
	elseif pattern == cumPatternBoobOral
		ApplyCumBoob(cummedAct, intensity)
	elseif pattern == cumPatternAnal
		ApplyCumAnal(cummedAct, intensity)
	elseif pattern == cumPatternFeet
		ApplyCumFeet(cummedAct, intensity)
	elseif pattern == cumPatternVaginalPullout
		ApplyCumVaginalPullout(cummedAct, intensity)
	elseif pattern == cumPatternAnalPullout
		ApplyCumAnalPullout(cummedAct, intensity)
	endif
EndFunction


Function CumOntoArea(actor act, string TexFilename, string area = "Body")
	writelog("CumOntoArea")
	writelog("Applying texture: " + TexFilename)

	string cumTexture = GetCumTexture(TexFilename)

	if !disableCumDecal
		ReadyOverlay(act, ostim.AppearsFemale(act), area, cumTexture)

		RegisterForCleaningOnEnteringWater(act)

		if PapyrusUtil.CountActor(currentSceneCummedOnActs, act) == 0
			currentSceneCummedOnActs = PapyrusUtil.PushActor(currentSceneCummedOnActs, act)
		endif

		if PapyrusUtil.CountActor(cummedOnActs, act) == 0
			cummedOnActs = PapyrusUtil.PushActor(cummedonacts, act)
		endif
	endif

	; Cum textures from:
	; https://www.loverslab.com/files/file/2968-sexlab-cum-textures-remake-slavetats/
	; https://www.loverslab.com/files/file/243-sexlab-sperm-replacer/ - permission from: https://www.loverslab.com/topic/32080-sexlab-sperm-replacer-3dm-forum-version/
	; https://www.loverslab.com/files/file/14696-slavetats-cum-texturesreplacer
EndFunction


function EquipCumMesh(actor act, armor item)
	writelog("EquipCumMesh")
	writelog("Equipping mesh item: " + item)

	act.equipItem(item, false, true)
	actorsWithCumMeshes = PapyrusUtil.PushActor(actorsWithCumMeshes, act)
	cumMeshesEquipped = PapyrusUtil.PushForm(cumMeshesEquipped, item)

	if ostim.IsInFreeCam() && act == playerRef
		act.QueueNiNodeUpdate()
	endif
endfunction


function UnequipCumMeshes()
	writelog("UnequipCumMeshes")

	if actorsWithCumMeshes.Length <= 0
		return
	endif

	int x = 0

	while x < actorsWithCumMeshes.Length
		int k = 0

		while k < cumMeshesEquipped.Length
			actorsWithCumMeshes[x].removeItem(cumMeshesEquipped[k], 99, true)
			k += 1
		endwhile

		x += 1
	endwhile

	actorsWithCumMeshes = papyrusutil.ResizeActorArray(actorsWithCumMeshes, 0)
	cumMeshesEquipped = PapyrusUtil.ResizeFormArray(cumMeshesEquipped, 0)
endfunction


; ███████╗██╗   ██╗███████╗███╗   ██╗████████╗███████╗
; ██╔════╝██║   ██║██╔════╝████╗  ██║╚══██╔══╝██╔════╝
; █████╗  ██║   ██║█████╗  ██╔██╗ ██║   ██║   ███████╗
; ██╔══╝  ╚██╗ ██╔╝██╔══╝  ██║╚██╗██║   ██║   ╚════██║
; ███████╗ ╚████╔╝ ███████╗██║ ╚████║   ██║   ███████║
; ╚══════╝  ╚═══╝  ╚══════╝╚═╝  ╚═══╝   ╚═╝   ╚══════╝
; Events that add more features to OCum based on OStim scenes stages and player actions

Function OnLoad()
	; this is needed for those who upgraded from OCum 1.3, don't remove
	ostim = OUtils.GetOStim()
	PlayerRef = Game.GetPlayer()

	teraElinRace = Game.GetFormFromFile(0x00001000, "TeraElinRace.esm") As Race
	teraElinRaceVampire = Game.GetFormFromFile(0x00001001, "TeraElinRace.esm") As Race

	RegisterForModEvent("ostim_orgasm", "OstimOrgasm")
	RegisterForModEvent("ostim_start", "OstimStart")
	RegisterForModEvent("ostim_thirdactor_join", "OstimThirdActorJoin")
	RegisterForModEvent("ostim_thirdactor_leave", "OstimThirdActorLeave")
	RegisterForModEvent("ostim_redresscomplete", "OstimRedressEnd")
	RegisterForModEvent("ostim_end", "OstimEnd")
	RegisterForModEvent("ostim_totalend", "OstimTotalEnd")
	RegisterForKey(CheckCumKey)
	OCumSpell.SetNthEffectDuration(0, (cumCleanupTimer * 60) as int)
	OCumInflationSpell.SetNthEffectDuration(0, (inflationCleanupTimer * 60) as int)
EndFunction


Event OnInit()
	writelog("OnInit")
	LoadGameEvents = false
	RequiredVersion = 25
	InstallAddon("OCum")

	CumStoredKey = "CumStoredAmount"
	LastCumCheckTimeKey = "CumLastCalcTime"
	MaxCumVolumeKey = "CumMaxAmount"
	CumBar = (Self as Quest) as Osexbar
	InitBar(cumbar)

	OnLoad()
EndEvent


Event OnKeyDown(Int KeyPress)
	; Event which listens for the cum bar key press
	if (KeyPress != 1 && KeyPress == CheckCumKey)
		TempDisplayBar()
	endif
EndEvent


Event OstimStart(string eventName, string strArg, float numArg, Form sender)
	domActor = ostim.GetDomActor()
	subActor = ostim.GetSubActor()
	thirdActor = ostim.GetThirdActor()
EndEvent


Event OstimOrgasm(string eventName, string strArg, float numArg, Form sender)
	; The main OCum event
	; Handles the logic when an orgasm is reached:
	; Applies squirt, cum decals and cum shots
	; Drains the cum bar accordingly
	; Plays the respective sounds

	writelog("OstimOrgasm")
	ostim.SetOrgasmStall(true)
	actor orgasmer = ostim.GetMostRecentOrgasmedActor()
	bool male = !ostim.IsFemale(orgasmer)

	if male
		ostim.PlaySound(orgasmer, cumsound)
		float CumAmount
		float MaxStorage = GetMaxCumStoragePossible(orgasmer)
		float idealMax = (MaxStorage / 2) + (MaxStorage * OSANative.RandomFloat(-0.15, 0.15))
		float currentCum = GetCumStoredAmount(orgasmer)

		if idealMax < currentCum
			cumamount = idealMax
		else
			cumamount = currentCum
		endif

		writelog("Blowing load size: " + CumAmount + " ML")
		AdjustStoredCumAmount(orgasmer, 0 - CumAmount, false)

		if !ostim.IsSoloScene()
			actor partner = ostim.GetSexPartner(orgasmer)
			bool malePartner = !ostim.IsFemale(partner)

			ApplyCumAsNecessary(partner, CumAmount)

			if (thirdActor)
				ApplyCumAsNecessary(thirdActor, CumAmount)
			endif

			if ostim.IsVaginal()
				if !malePartner ; give it to female
					AdjustStoredCumAmount(partner, CumAmount, true)
				endif
			ElseIf (cumAmount > 0 && ostim.IsOral())
				SendModEvent("ocum_cumoral", numArg=cumAmount)

			endif
		EndIf

		CumShoot(orgasmer, cumamount)

		if ostim.IsPlayerInvolved()
			ostim.SetOrgasmStall(false)
			TempDisplayBar()
		endif
	else
		if outils.ChanceRoll(50)
			if !ostim.MuteOSA
				ostim.PlaySound(orgasmer, femaleGasp)
			endif
		endif
		if outils.ChanceRoll(squirtChance)
			Squirt(orgasmer)
		endif
	endif
	ostim.SetOrgasmStall(false)
EndEvent


Event OstimThirdActorJoin(string eventName, string strArg, float numArg, Form sender)
	thirdActor = ostim.GetThirdActor()
EndEvent


Event OstimThirdActorLeave(string eventName, string strArg, float numArg, Form sender)
	if PapyrusUtil.CountActor(currentSceneCummedOnActs, thirdActor) > 0
		OCumSpell.cast(thirdActor, thirdActor)
	endif

	if PapyrusUtil.CountActor(currentSceneBellyInflationActs, thirdActor) > 0
		OCumInflationSpell.cast(thirdActor, thirdActor)
	endif

	; account for the spells being cast just in case
	Utility.wait(1.5)
	currentSceneCummedOnActs = PapyrusUtil.RemoveActor(currentSceneCummedOnActs, thirdActor)
	currentSceneBellyInflationActs = PapyrusUtil.RemoveActor(currentSceneBellyInflationActs, thirdActor)
	thirdActor = none
EndEvent


Event OStimEnd(string eventName, string strArg, float numArg, Form sender)
	writelog("Applying cum magic effect...")

	; check actors which had cum applied to them and give them the OCum spell effect
	; the effect handles the automatic cleaning when it ends
	int i
	int max = currentSceneCummedOnActs.Length
	actor act

	while i < max
		act = currentSceneCummedOnActs[i]
		if act != none
			OCumSpell.cast(act, act)
		endif
		i += 1
	endwhile

	; check actors which had belly inflation applied to them and give them the inflation spell effect
	; the effect handles the automatic cleaning when it ends
	i = 0
	max = currentSceneBellyInflationActs.Length

	while i < max
		act = currentSceneBellyInflationActs[i]
		if act != none
			OCumInflationSpell.cast(act, act)
		endif
		i += 1
	endwhile
EndEvent


Event OstimRedressEnd(string eventName, string strArg, float numArg, Form sender)
	writelog("Cleaning up armors...")

	if domActor
		domActor.RemoveItem(UrethraNode, 99, true)
	endif
	if subActor
		subActor.RemoveItem(UrethraNode, 99, true)
	endif
	if thirdActor
		thirdActor.RemoveItem(UrethraNode, 99, true)
	endif

	UnequipCumMeshes()

	domActor = None
	subActor = None
	thirdActor = None
EndEvent


Event OStimTotalEnd(string eventName, string strArg, float numArg, Form sender)
	; account for the spells being cast just in case
	Utility.Wait(1.5)
	currentSceneCummedOnActs = PapyrusUtil.ResizeActorArray(currentSceneCummedOnActs, 0)
	currentSceneBellyInflationActs = PapyrusUtil.ResizeActorArray(currentSceneBellyInflationActs, 0)
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
	if (barVisible)
		barVisible = false
		SetBarVisible(cumbar, false)
	endif
endEvent


;  ██████╗██╗   ██╗███╗   ███╗    ██████╗  █████╗ ██████╗ 
; ██╔════╝██║   ██║████╗ ████║    ██╔══██╗██╔══██╗██╔══██╗
; ██║     ██║   ██║██╔████╔██║    ██████╔╝███████║██████╔╝
; ██║     ██║   ██║██║╚██╔╝██║    ██╔══██╗██╔══██║██╔══██╗
; ╚██████╗╚██████╔╝██║ ╚═╝ ██║    ██████╔╝██║  ██║██║  ██║
;  ╚═════╝ ╚═════╝ ╚═╝     ╚═╝    ╚═════╝ ╚═╝  ╚═╝╚═╝  ╚═╝


Function TempDisplayBar()
	if (!barVisible)
		float amount = GetCumStoredAmount(playerref)

		writelog("Current cum storage for player: " + amount)

		cumbar.SetPercent(amount / GetMaxCumStoragePossible(playerref))
		SetBarVisible(cumbar, true)

		barVisible = true

		; make bar disappear in 10 seconds
		RegisterForSingleUpdate(10.0)
	endif
Endfunction


Function InitBar(Osexbar Bar)
	Bar.HAnchor = "left"
	Bar.VAnchor = "bottom"
	Bar.X = 980.0
	Bar.Alpha = 0.0
	Bar.SetPercent(0.0)
	Bar.FillDirection = "Left"

	Bar.Y = 120.0
	Bar.SetColors(0xb0b0b0, 0xfff5fd)

	SetBarVisible(Bar, False)
EndFunction


Function SetBarVisible(Osexbar Bar, Bool Visible)
	If (Visible)
		Bar.FadeTo(100.0, 1.0)
		Bar.FadedOut = False
	Else
		Bar.FadeTo(0.0, 1.0)
		Bar.FadedOut = True
	EndIf
EndFunction


; ██╗   ██╗████████╗██╗██╗     ███████╗
; ██║   ██║╚══██╔══╝██║██║     ██╔════╝
; ██║   ██║   ██║   ██║██║     ███████╗
; ██║   ██║   ██║   ██║██║     ╚════██║
; ╚██████╔╝   ██║   ██║███████╗███████║
;  ╚═════╝    ╚═╝   ╚═╝╚══════╝╚══════╝


; ------------------------  Console logging utility functions ------------------------  ;

Function writelog(string a)
	a = "OCum: "+a
	consoleutil.printmessage(a)
	debug.trace(a)
EndFunction


; ------------------------ Cum utility functions ------------------------  ;

Function updateCheckCumKey(int newKey)
	UnregisterForKey(CheckCumKey)

	CheckCumKey = newKey
	RegisterForKey(newKey)
EndFunction


Function StoreNPCDataFloat(actor npc, string keys, Float num)
	StorageUtil.SetFloatValue(npc as form, keys, num)
EndFunction


Float Function GetNPCDataFloat(actor npc, string keys)
	return StorageUtil.GetFloatValue(npc, keys, -1)
EndFunction


int Function GetLoadSizeFromML(float ml)
	; Load size
	; none: 0 ml
	; Small: 0 - 3 ml
	; Medium: 3 - 8 ml
	; Large: 8 - 16 ml
	; Massive 16 ml+

	if ml < 0.1
		return 0
	elseif ml < 3.0
		return 1
	elseif ml < 8.0
		return 2
	elseif ml < 16
		return 3
	else
		return 4
	endif
EndFunction


float Function GetMaxCumStoragePossible(actor npc)
	if ostim.IsFemale(npc)
		float max = GetNPCDataFloat(npc, MaxCumVolumeKey)

		if (max != -1)
			if (npc == PlayerRef && enableFixedUterineVolumePlayer)
				return uterineVolumePlayer
			elseif (npc != PlayerRef && enableFixedUterineVolumeNPCs)
				return uterineVolumeNPCs
			endif

			return max
		else
			if (npc == PlayerRef && enableFixedUterineVolumePlayer)
				max = uterineVolumePlayer
			elseif (npc != PlayerRef && enableFixedUterineVolumeNPCs)
				max = uterineVolumeNPCs
			else
				max = OSANative.RandomFloat(15, 56)
			endif

			writelog("Uterine volume for " + npc.GetDisplayName() + ":" + max)
			StoreNPCDataFloat(npc, MaxCumVolumeKey, max)
			return max
		EndIf
	else
		if (npc == PlayerRef)
			if (enableDeleveledCumBarPlayer)
				return cumBarMaxAmountPlayer
			endif
		else
			if (enableDeleveledCumBarNPCs)
				return cumBarMaxAmountNPCs
			endif
		endif

		return 2 * ( (npc.GetLevel() * 0.5) + 1)
	endif
EndFunction


string Function GetCumTexture(string filename)
	return "CumOverlays\\" + filename + ".dds"
EndFunction


Function RemoveCumOverlay(actor act, string nodeArea, int numOverlays)
	int i = 0
	bool Gender = ostim.AppearsFemale(act)

	while i < numOverlays
		String Node = nodeArea + " [ovl" + i + "]"

		string tex = NiOverride.GetNodeOverrideString(act, Gender, Node, 9, 0)

		If outils.StringContains(tex, "Cum")
			NiOverride.AddNodeOverrideString(act, Gender, Node, 9, 0, "actors\\character\\overlays\\default.dds", false)
			NiOverride.RemoveNodeOverride(act, Gender, node , 9, 0)
			NiOverride.RemoveNodeOverride(act, Gender, Node, 7, -1)
			NiOverride.RemoveNodeOverride(act, Gender, Node, 0, -1)
			NiOverride.RemoveNodeOverride(act, Gender, Node, 8, -1)
			NiOverride.RemoveNodeOverride(act, Gender, Node, 2, -1)
			NiOverride.RemoveNodeOverride(act, Gender, Node, 3, -1)
		EndIf

		i += 1
	endwhile
EndFunction


Function RemoveCumTex(actor act)
	writelog("RemoveCumTex")

	RemoveCumOverlay(act, "Body", NiOverride.GetNumBodyOverlays())
	RemoveCumOverlay(act, "Face", NiOverride.GetNumFaceOverlays())
	RemoveCumOverlay(act, "Feet", NiOverride.GetNumFeetOverlays())
	RemoveCumOverlay(act, "Hands", NiOverride.GetNumFeetOverlays())
EndFunction


int Function GetCumPattern()
	string oclass = ostim.GetCurrentAnimationClass()
	string currentAnimation = ostim.GetCurrentAnimationSceneID()

	if ostim.IsVaginal()
		return cumPatternVaginal
	elseif oclass == "An"
		return cumPatternAnal
	elseif (oclass == "ApPJ") || (oclass == "BJ") || (oclass == "HhPJ") || (oclass == "HhBJ") || (oclass == "VBJ") || (oclass == "HhPo")
		return cumPatternOral
	elseif (oclass == "BoJ") || (oclass == "VHJ")
		return cumPatternBoobOral
	elseif (oclass == "FJ")
		return cumPatternFeet
	elseif (oclass == "Po") || (oclass == "HJ")  || (oclass == "ApHJ") || (oclass == "DHJ")
		return CalculateCumPatternFromSkeleton(ostim.GetDomActor(), ostim.GetSubActor())
	endif
EndFunction


Function CleanCumTexturesFromActor(actor act, bool removeActorFromCummedOnArrays)
	RemoveCumTex(act)
	UnregisterForAnimationEvent(act, "SoundPlay.FSTSwimSwim")

	if removeActorFromCummedOnArrays
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


; ------------------------ Body skeleton utility functions ------------------------  ;

Function SetBellyScale(actor akActor, float bellyScale)
	NiOverride.SetBodyMorph(akActor, "PregnancyBelly", "OCum", bellyScale)
	NiOverride.UpdateModelWeight(akActor)

	if PapyrusUtil.CountActor(currentSceneBellyInflationActs, akActor) == 0
		currentSceneBellyInflationActs = PapyrusUtil.PushActor(currentSceneBellyInflationActs, akActor)
	endif

	if PapyrusUtil.CountActor(bellyInflationActs, akActor) == 0
		bellyInflationActs = PapyrusUtil.PushActor(bellyInflationActs, akActor)
	endif
EndFunction


Function RemoveBellyScale(actor akActor, bool removeActorFromInflationArrays)
	NiOverride.SetBodyMorph(akActor, "PregnancyBelly", "OCum", 0.0)
	NiOverride.ClearBodyMorph(akActor, "PregnancyBelly", "OCum")
	NiOverride.UpdateModelWeight(akActor)

	if removeActorFromInflationArrays
		bellyInflationActs = PapyrusUtil.RemoveActor(bellyInflationActs, akActor)
		currentSceneBellyInflationActs = PapyrusUtil.RemoveActor(currentSceneBellyInflationActs, akActor)
	endif
EndFunction


Function RemoveBellyScaleFromAllActors()
	isRemovingInflationFromAllActors = true

	int i
	int max = bellyInflationActs.Length

	actor act

	while i < max
		act = bellyInflationActs[i]

		if act != none
			if act.HasMagicEffectWithKeyWord(AppliedInflationKeyword)
				act.DispelSpell(OCumInflationSpell)
			else
				RemoveBellyScale(act, false)
			endif
		endif

		i += 1
	endwhile

	bellyInflationActs = PapyrusUtil.ResizeActorArray(bellyInflationActs, 0)
	currentSceneBellyInflationActs = PapyrusUtil.ResizeActorArray(currentSceneBellyInflationActs, 0)

	isRemovingInflationFromAllActors = false
EndFunction


float Function ThreeDeeDistance(float[] pointSet1, float[] pointSet2)
	return math.sqrt( ((pointset2[0] - pointSet1[0]) * (pointset2[0] - pointSet1[0])) +  ((pointset2[1] - pointSet1[1]) * (pointset2[1] - pointSet1[1])) + ((pointset2[2] - pointSet1[2]) * (pointset2[2] - pointSet1[2])))
EndFunction


float[] Function GetNodeLocation(actor act, string node)
	float[] ret = new float[3]
	NetImmerse.GetNodeWorldPosition(act, node, ret, false)
	return ret
EndFunction


Int Function GetNumSlots(String Area)
	If Area == "Body"
		Return NiOverride.GetNumBodyOverlays()
	ElseIf Area == "Face"
		Return NiOverride.GetNumFaceOverlays()
	ElseIf Area == "Hands"
		Return NiOverride.GetNumHandOverlays()
	Else
		Return NiOverride.GetNumFeetOverlays()
	EndIf
EndFunction


Int Function GetEmptySlot(Actor akTarget, Bool Gender, String Area)
	Int i = 0
	Int NumSlots = GetNumSlots(Area)
	String TexPath
	Bool FirstPass = true

	While i < NumSlots
		TexPath = NiOverride.GetNodeOverrideString(akTarget, Gender, Area + " [ovl" + i + "]", 9, 0)
		writelog(TexPath)
		If TexPath == "" || TexPath == "actors\\character\\overlays\\default.dds"
			writelog("Slot " + i + " chosen for area: " + area)
			Return i
		EndIf
		i += 1
		If !FirstPass && i == NumSlots
			FirstPass = true
			i = 0
		EndIf
	EndWhile
	Return -1
EndFunction


Function SetUrethra(actor a)
	a.EquipItem(UrethraNode, abPreventRemoval = True, abSilent = True)  ; don't do AddItem first, it will make NPCs redress
	if ostim.IsInFreeCam() && a == playerref
		a.QueueNiNodeUpdate()
	endif

	bool isFemale = ostim.IsFemale(a)

	Float[] move0 = new Float[3]
	Float[] move100 = new Float[3]
	Float[] rotate = new Float[3]
	Float[] move = new Float[3]

	Float aWeight = a.GetActorBase().GetWeight()

	move0[0] = 0
	move0[1] = -0.5
	move0[2] = 0.1
	move100[0] = 0
	move100[1] = 0.4
	move100[2] = 0.3
	rotate[0] = 0
	rotate[1] = 0
	rotate[2] = -3 + 10


	move[0] = move0[0] + (move100[0] - move0[0]) * aWeight / 100.0  ; interpolate between body weight 0 and 100
	move[1] = move0[1] + (move100[1] - move0[1]) * aWeight / 100.0
	move[2] = move0[2] + (move100[2] - move0[2]) * aWeight / 100.0

	Utility.Wait(0.05)

	NiOverride.AddNodeTransformPosition(a, False, isFemale, "Urethra", "SLCCumAdjust", move)
	NiOverride.AddNodeTransformRotation(a, False, isFemale, "Urethra", "SLCCumAdjust", rotate)
	NiOverride.UpdateNodeTransform(a, False, isFemale, "Urethra")
EndFunction


Function ApplyOverlay(Actor akTarget, Bool Gender, String Area, String OverlaySlot, String TextureToApply)
	writelog("ApplyOverlay")
	float alpha = OSANative.RandomFloat(0.75, 1.0)

	NiOverride.AddOverlays(akTarget)
	String Node = Area + " [ovl" + OverlaySlot + "]"
	NiOverride.AddNodeOverrideString(akTarget, Gender, Node, 9, 0, TextureToApply, true)
	NiOverride.AddNodeOverrideInt(akTarget, Gender, Node, 7, -1, 0, true)
	NiOverride.AddNodeOverrideInt(akTarget, Gender, Node, 0, -1, 0, true)
	NiOverride.AddNodeOverrideFloat(akTarget, Gender, Node, 8, -1, Alpha, true)
	NiOverride.AddNodeOverrideFloat(akTarget, Gender, Node, 2, -1, 0.0, true)
	NiOverride.AddNodeOverrideFloat(akTarget, Gender, Node, 3, -1, 0.0, true)

	NiOverride.ApplyNodeOverrides(akTarget)
EndFunction


Function ReadyOverlay(Actor akTarget, Bool Gender, String Area, String TextureToApply)
	Int SlotToUse = GetEmptySlot(akTarget, Gender, Area)
	If SlotToUse != -1
		ApplyOverlay(akTarget, Gender, Area, SlotToUse, TextureToApply)
	Else
		writelog("No slots available")
	EndIf
EndFunction


int Function CalculateCumPatternFromSkeleton(actor male, actor female)
	float[] maleGenitals = GetNodeLocation(male, genitalsNode)

	float[] femaleGenitals = GetNodeLocation(female, genitalsFemaleNode)
	float[] femaleFace = GetNodeLocation(female, faceNode)
	float[] femaleAss = GetNodeLocation(female, assNode)

	float distanceFemaleGenitals = ThreeDeeDistance(maleGenitals, femaleGenitals)
	float distanceFemaleFace = ThreeDeeDistance(maleGenitals, femaleFace)
	float distanceFemaleAss = ThreeDeeDistance(maleGenitals, femaleAss)

	int pattern = cumPatternVaginal
	float smallestDistance = distanceFemaleGenitals

	if (distanceFemaleFace < smallestDistance)
		pattern = cumPatternOral
	endif
	
	if (distanceFemaleAss < smallestDistance)
		pattern = cumPatternAnal
	endif

	; if animation class is masturbation and it is nearer to ass, it makes sense to apply cum on back
	; likewise, if it is nearer to vagina, it makes sense to also apply cum on belly+chest area
	; this will work especially great for Pull-Out animations from OpenSex
	if ostim.GetCurrentAnimationClass() == "Po"
		if smallestDistance == cumPatternVaginal
			pattern = cumPatternVaginalPullout
		elseif smallestDistance == cumPatternAnal
			pattern = cumPatternAnalPullout
		endif
	endif

	return pattern
EndFunction
