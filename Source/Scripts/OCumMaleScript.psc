ScriptName OCumMaleScript extends Quest

import OCumUtils
import OCumSceneDataUtils

; ------------------------ Properties and script wide Vars ------------------------ ;

Actor property PlayerRef auto

Armor property UrethraNode auto

Armor property CumMeshPussy auto
Armor property CumMeshAnal auto

Faction property ChestStageFaction auto
Faction property ButtStageFaction auto
Faction property BellyStageFaction auto

Faction property ChestStageSlotFaction auto
Faction property ButtStageSlotFaction auto
Faction property BellyStageSlotFaction auto

Keyword property AppliedCumKeyword auto

Spell property OCumSpell auto

Spell property CumSpell1 auto
Spell property CumSpell2 auto
Spell property CumSpell3 auto
Spell property CumSpell4 auto

Activator property CumLauncher auto

OSexIntegrationMain property OStim auto

OCumScript property OCum auto

Race TeraElinRace
Race TeraElinRaceVampire

string faceNode = "R Breast04"
string assNode = "NPC RT Anus2"
string genitalsNode = "NPC Genitals06 [Gen06]"
string genitalsFemaleNode = "NPC Genitals02 [Gen02]"


; ███████╗██╗   ██╗███████╗███╗   ██╗████████╗███████╗
; ██╔════╝██║   ██║██╔════╝████╗  ██║╚══██╔══╝██╔════╝
; █████╗  ██║   ██║█████╗  ██╔██╗ ██║   ██║   ███████╗
; ██╔══╝  ╚██╗ ██╔╝██╔══╝  ██║╚██╗██║   ██║   ╚════██║
; ███████╗ ╚████╔╝ ███████╗██║ ╚████║   ██║   ███████║
; ╚══════╝  ╚═══╝  ╚══════╝╚═╝  ╚═══╝   ╚═╝   ╚══════╝


Event OnInit()
	OnLoad()
EndEvent


Function OnLoad()
	WriteLog("OCum Male init")
	UnregisterForAllModEvents()

	OStim = OUtils.GetOStim()

	RegisterForModEvent("ostim_start", "OStimStart")
	RegisterForModEvent("ostim_orgasm", "OStimOrgasm")
	RegisterForModEvent("ostim_actor_join", "OStimActorJoin")
	RegisterForModEvent("ostim_actor_leave", "OStimActorLeave")
	RegisterForModEvent("ostim_totalend", "OStimTotalEnd")
	RegisterForModEvent("ocum_play_cum_shoot_effect", "OCumPlayCumShoot")

	TeraElinRace = Game.GetFormFromFile(0x00001000, "TeraElinRace.esm") As Race
	TeraElinRaceVampire = Game.GetFormFromFile(0x00001001, "TeraElinRace.esm") As Race
EndFunction


Event OStimStart(string eventName, string strArg, float numArg, Form sender)
	Actor[] sceneActors = OStim.GetActors()

	int i = sceneActors.length

	while i > 0
		i -= 1

		AddActorToStagesFactions(sceneActors[i])
	endwhile
EndEvent


Event OStimActorJoin(string eventName, string strArg, float numArg, Form sender)
	Actor actorWhoJoined = sender as Actor

	AddActorToStagesFactions(actorWhoJoined)
EndEvent


Event OStimActorLeave(string eventName, string strArg, float numArg, Form sender)
	Actor actorWhoLeft = sender as Actor

	RemoveActorFromStagesFactions(actorWhoLeft)

	RemoveItem(actorWhoLeft, CumMeshPussy)
	RemoveItem(actorWhoLeft, CumMeshAnal)
	RemoveItem(actorWhoLeft, UrethraNode)

	if PapyrusUtil.CountActor(OCum.currentSceneCummedOnActs, actorWhoLeft) > 0
		OCumSpell.cast(actorWhoLeft, actorWhoLeft)
	endif

	; account for the spells being cast just in case
	Utility.wait(1.5)
	OCum.currentSceneCummedOnActs = PapyrusUtil.RemoveActor(OCum.currentSceneCummedOnActs, actorWhoLeft)
EndEvent


Event OstimOrgasm(string eventName, string strArg, float numArg, Form sender)
	; The main OCum event
	; Handles the logic when an orgasm is reached:
	; Applies cum decals and cum shots
	; Drains the cum bar accordingly
	; Plays the respective sounds

	Actor orgasmer = sender as Actor

	if !OStim.IsFemale(orgasmer)
		OStim.SetOrgasmStall(true)

		string sceneID = strArg

		float amountML
		float currentCum = OCum.GetCumStoredAmount(orgasmer)

		int randNum = Utility.RandomInt(1, 100)

		float idealMax

		if randNum < 20
			idealMax = 10 + Utility.RandomFloat(0, 8)
		elseif randNum < 50
			idealMax = 5 + Utility.RandomFloat(0, 4.9)
		elseif randNum < 80
			idealMax = 2 + Utility.RandomFloat(0, 2.9)
		else
			idealMax = 0.1 + Utility.RandomFloat(0, 1.8)
		endif

		if idealMax < currentCum
			amountML = idealMax
		else
			amountML = currentCum
		endif

		WriteLog("Blowing load size: " + amountML + " ML")

		; don't listen for this event, it's only for self consumption so cum shoot runs asynchronously
		orgasmer.SendModEvent("ocum_play_cum_shoot_effect", StrArg = sceneID, NumArg = amountML)

		OCum.AdjustStoredCumAmount(orgasmer, 0 - amountML, currentCum)

		if !OStim.IsSoloScene()
			int intensity = GetLoadSizeFromML(amountML)

			if intensity > 0
				ApplyCumAsNecessary(orgasmer, numArg as int, intensity, amountML, sceneID)
			endif
		EndIf

		OCum.TempDisplayBar()

		OStim.SetOrgasmStall(false)
	endif
EndEvent


Event OStimTotalEnd(string eventName, string strArg, float numArg, Form sender)
	WriteLog("Applying cum magic effect...")

	; check actors which had cum applied to them and give them the OCum spell effect
	; the effect handles the automatic cleaning when it ends
	int i
	int max = OCum.currentSceneCummedOnActs.Length

	Actor act

	while i < max
		act = OCum.currentSceneCummedOnActs[i]
		if act != none
			OCumSpell.cast(act, act)
		endif
		i += 1
	endwhile

	; account for the spells being cast just in case
	Utility.wait(1.5)

	OCum.currentSceneCummedOnActs = PapyrusUtil.ResizeActorArray(OCum.currentSceneCummedOnActs, 0)

	WriteLog("Cleaning up meshes...")

	Actor[] sceneActors = OStim.GetActors()

	i = sceneActors.length

	while i > 0
		i -= 1

		act = sceneActors[i]

		RemoveActorFromStagesFactions(act)

		RemoveItem(act, CumMeshPussy)
		RemoveItem(act, CumMeshAnal)
		RemoveItem(act, UrethraNode)
	endwhile
EndEvent


Event OCumPlayCumShoot(string eventName, string strArg, float numArg, Form sender)
	Actor orgasmer = sender as Actor

	CumShoot(orgasmer, numArg, strArg)
EndEvent


; ██╗   ██╗████████╗██╗██╗     ███████╗
; ██║   ██║╚══██╔══╝██║██║     ██╔════╝
; ██║   ██║   ██║   ██║██║     ███████╗
; ██║   ██║   ██║   ██║██║     ╚════██║
; ╚██████╔╝   ██║   ██║███████╗███████║
;  ╚═════╝    ╚═╝   ╚═╝╚══════╝╚══════╝


Function ApplyCumAsNecessary(Actor Orgasmer, int ActorPos, int Intensity, float AmountML, string SceneID)
	; Handjob and Footjob has no cum target since it can be given in different positions
	; so we must calculate cum area ourselves

	bool isHJ = IsHandjob(SceneID)
	bool isFJ = IsFootJob(SceneID)

	if isHJ || isFJ
		int[] actorsGiving = OMetadata.GetActionActors(SceneID)

		int i = actorsGiving.Length

		string area

		Actor actorGiving
		Actor actorReceiving = OStim.GetActor(ActorPos)

		while i > 0
			i -= 1

			actorGiving = OStim.GetActor(actorsGiving[i])

			area = CalculateCumAreaFromSkeleton(actorReceiving, actorGiving)

			ApplyCum(Orgasmer, actorGiving, area, Intensity, AmountML, SceneID)

			if isHJ
				ApplyCum(Orgasmer, actorGiving, "hands", Intensity, AmountML, SceneID)
			endif
			
			if isFJ
				ApplyCum(Orgasmer, actorGiving, "feet", Intensity, AmountML, SceneID)
			endif
		endwhile
	else
		; cumming actor is the action-actor, so we need cum slots of the action-target (vaginalsex, analsex, etc)
		; custom record parameters are CSV actor,target,performer, so since we want target we lead with a comma
		int[] Actions = OMetadata.FindActionsSuperloadCSVv2(SceneID, ActorPositions = ActorPos, AnyCustomStringListRecord = ";cum")
		int i = Actions.Length

		While i
			i -= 1
			Actor Target = OStim.GetActor(OMetadata.GetActionTarget(SceneID, Actions[i]))

			String[] Slots = OMetadata.GetCustomActionTargetStringList(SceneID, Actions[i], "cum")

			int j = Slots.Length

			While j
				j -= 1
				ApplyCum(Orgasmer, Target, Slots[j], Intensity, AmountML, SceneID)
			EndWhile
		EndWhile

		; cummin actor is the action-target, so we need cum slots of the action-actor (blowjob, boobjob, etc)
		; this time we want the custom record of the action-actor, so no leading comma
		Actions = OMetadata.FindActionsSuperloadCSVv2(SceneID, TargetPositions = ActorPos, AnyCustomStringListRecord = "cum")
		i = Actions.Length

		While i
			i -= 1
			Actor Target = OStim.GetActor(OMetadata.GetActionActor(SceneID, Actions[i]))

			String[] Slots = OMetadata.GetCustomActionActorStringList(SceneID, Actions[i], "cum")

			int j = Slots.Length

			While j
				j -= 1
				ApplyCum(Orgasmer, Target, Slots[j], Intensity, AmountML, SceneID)
			EndWhile
		EndWhile
	endif
EndFunction


string Function CalculateCumAreaFromSkeleton(actor male, actor female)
	float[] maleGenitals = GetNodeLocation(male, genitalsNode)

	float[] femaleGenitals = GetNodeLocation(female, genitalsFemaleNode)
	float[] femaleFace = GetNodeLocation(female, faceNode)
	float[] femaleAss = GetNodeLocation(female, assNode)

	float distanceFemaleGenitals = ThreeDeeDistance(maleGenitals, femaleGenitals)
	float distanceFemaleFace = ThreeDeeDistance(maleGenitals, femaleFace)
	float distanceFemaleAss = ThreeDeeDistance(maleGenitals, femaleAss)

	string area = "belly"
	float smallestDistance = distanceFemaleGenitals

	if (distanceFemaleFace < smallestDistance)
		area = "face"
	endif
	
	if (distanceFemaleAss < smallestDistance)
		area = "butt"
	endif

	return area
EndFunction


Function ApplyCum(Actor Orgasmer, Actor Target, String Area, Int Intensity, Float AmountML, String SceneID)
	if OCum.DisableFacialsForElins && (Area == "face" || Area == "mouth" || Area == "throat")
		Race cummedActRace = Target.GetRace()

		; don't apply facials to Tera Elin race if it is set like that on MCM
		; Elins use a different face map, so facial textures may look bad on them
		if (teraElinRace && teraElinRaceVampire && (cummedActRace == teraElinRace || cummedActRace == teraElinRaceVampire))
			writelog("Cummed actor is an Elin, not applying facial texture")
			return
		endif
	endif

	int handle = ModEvent.Create("ocum_applied_cum")
	ModEvent.PushForm(handle, Orgasmer)
    ModEvent.PushForm(handle, Target)
    ModEvent.PushFloat(handle, amountML)
    ModEvent.PushString(handle, Area)
    ModEvent.PushString(handle, SceneID)
    ModEvent.Send(handle)

	; creampie, facial and cumonXXX are new actions which are supposed to be used in designated climax animations
	; basically they all just mean the male pulls out, jerks off and them cums on a part of the female

	; some of these slots might overlap in a single scene depending on how much actions it contains
	; so there is a chance the same slot is called twice in a single orgasm event
	If Area == "belly"
		ApplyCumBelly(Target, Intensity)
	ElseIf Area == "butt"
		ApplyCumButt(Target, Intensity)
	ElseIf Area == "chest"
		ApplyCumBoob(Target, Intensity)
	ElseIf Area == "face"
		ApplyCumFacial(Target, Intensity)
	ElseIf Area == "feet"
		ApplyCumFeet(Target, Intensity)
	ElseIf Area == "hands"
		ApplyCumHands(Target)
	ElseIf Area == "mouth"
		ApplyCumMouth(Target, Intensity)
	ElseIf Area == "rectum"
		ApplyCumAnal(Target)
	ElseIf Area == "thighs"
		ApplyCumThighs(Target)
	ElseIf Area == "throat"
		ApplyCumThroat(Target, Intensity)
	ElseIf Area == "vagina"
		ApplyCumVaginal(Target)
	EndIf
EndFunction


Function ApplyCumAnal(Actor Target)
	if !OCum.disableCumMeshes && !Target.IsEquipped(CumMeshAnal) && ChanceRoll(OCum.analpieChance)
		EquipCumMesh(Target, CumMeshAnal, OStim.IsInFreeCam(), Target == PlayerRef)
	endif
EndFunction


Function ApplyCumBelly(actor Target, int intensity)
	int actFactionRank = Target.GetFactionRank(BellyStageFaction)
	int actSlot = Target.GetFactionRank(ChestStageSlotFaction)

	int returnedSlot

	if actFactionRank < 1
		if intensity == 1
			returnedSlot = CumOntoArea(Target, "Vaginal1", "Body", actSlot)
			Target.SetFactionRank(BellyStageFaction, 1)
			Target.SetFactionRank(BellyStageSlotFaction, returnedSlot)
		else
			returnedSlot = CumOntoArea(Target, "Vaginal2", "Body", actSlot)
			Target.SetFactionRank(BellyStageFaction, 2)
			Target.SetFactionRank(BellyStageSlotFaction, returnedSlot)
		endif
	else
		if actFactionRank < 7
			returnedSlot = CumOntoArea(Target, "Vaginal" + (actFactionRank+1), "Body", actSlot)
			Target.SetFactionRank(BellyStageFaction, actFactionRank+1)
			Target.SetFactionRank(BellyStageSlotFaction, returnedSlot)
		endif
	endif
EndFunction


Function ApplyCumBoob(actor Target, int intensity)
	int actFactionRank = Target.GetFactionRank(ChestStageFaction)
	int actSlot = Target.GetFactionRank(ChestStageSlotFaction)

	int returnedSlot = actSlot

	if actFactionRank < 1
		if intensity == 1
			returnedSlot = CumOntoArea(Target, "Breast1", "Body", actSlot)
			Target.SetFactionRank(ChestStageFaction, 1)
			Target.SetFactionRank(ChestStageSlotFaction, returnedSlot)
		else
			returnedSlot = CumOntoArea(Target, "Breast2", "Body", actSlot)
			Target.SetFactionRank(ChestStageFaction, 2)
			Target.SetFactionRank(ChestStageSlotFaction, returnedSlot)
		endif
	else
		if actFactionRank < 6
			returnedSlot = CumOntoArea(Target, "Breast" + (actFactionRank+1), "Body", actSlot)
			Target.SetFactionRank(ChestStageFaction, actFactionRank+1)
			Target.SetFactionRank(ChestStageSlotFaction, returnedSlot)
		endif
	endif

	if Intensity >= 2 && ChanceRoll(50)
		CumOntoArea(Target, "BreastFace" + Utility.RandomInt(1, 2), "Face")
	endif
EndFunction


Function ApplyCumButt(actor Target, int Intensity)
	int actFactionRank = Target.GetFactionRank(ButtStageFaction)
	int actSlot = Target.GetFactionRank(ButtStageSlotFaction)

	int returnedSlot = actSlot

	if actFactionRank < 1
		if intensity == 1
			returnedSlot = CumOntoArea(Target, "Butt1")
			Target.SetFactionRank(ButtStageFaction, 1)
			Target.SetFactionRank(ButtStageSlotFaction, returnedSlot)
		else
			returnedSlot = CumOntoArea(Target, "Butt2")
			Target.SetFactionRank(ButtStageFaction, 2)
			Target.SetFactionRank(ButtStageSlotFaction, returnedSlot)
		endif
	else
		if actFactionRank < 7
			returnedSlot = CumOntoArea(Target, "Butt" + (actFactionRank+1), "Body", actSlot)
			Target.SetFactionRank(ButtStageFaction, actFactionRank+1)
			Target.SetFactionRank(ButtStageSlotFaction, returnedSlot)
		endif
	endif
EndFunction


Function ApplyCumFacial(actor Target, int intensity)
	if intensity <= 2
		CumOntoArea(Target, "Facial" + Utility.RandomInt(1, 3), "Face")
	elseif intensity == 3
		CumOntoArea(Target, "Facial" + Utility.RandomInt(3, 6), "Face")
	else
		CumOntoArea(Target, "Facial" + Utility.RandomInt(3, 11), "Face")
	endif
EndFunction


Function ApplyCumFeet(actor Target, int intensity)
	if intensity == 1
		CumOntoArea(Target, "Feet1", "Feet")
	elseif intensity == 2
		CumOntoArea(Target, "Feet2", "Feet")
	else
		CumOntoArea(Target, "Feet2", "Feet")
		if ChanceRoll(50)
			CumOntoArea(Target, "Legs" + Utility.RandomInt(1, 2))
		endif
	endif
EndFunction


Function ApplyCumHands(actor Target)
	CumOntoArea(Target, "Hands", "Hands")
EndFunction


Function ApplyCumMouth(actor Target, int Intensity)
	if Intensity <= 2
		CumOntoArea(Target, "Mouth" + Utility.RandomInt(1, 4), "Face")
	else
		CumOntoArea(Target, "Mouth" + Utility.RandomInt(3, 7), "Face")
	endif
EndFunction


Function ApplyCumThighs(actor Target)
	CumOntoArea(Target, "Legs" + Utility.RandomInt(1, 2))
EndFunction


Function ApplyCumThroat(actor Target, int Intensity)
	if Intensity <= 2 && ChanceRoll(50)
		return
	endif

	CumOntoArea(Target, "Mouth" + Utility.RandomInt(1, 3), "Face")
EndFunction


Function ApplyCumVaginal(actor Target)
	if !OCum.disableCumMeshes && !Target.IsEquipped(CumMeshPussy) && ChanceRoll(OCum.creampieChance)
		EquipCumMesh(Target, CumMeshPussy, OStim.IsInFreeCam(), Target == PlayerRef)
	endif
EndFunction


int Function CumOntoArea(actor act, string TexFilename, string area = "Body", int Slot = -1)
	WriteLog("CumOntoArea")

	int slotUsed = Slot
	string cumTexture = GetCumTexture(TexFilename)

	if !OCum.DisableCumDecal
		slotUsed = ReadyOverlay(act, ostim.AppearsFemale(act), area, cumTexture, Slot)

		OCum.RegisterForCleaningOnEnteringWater(act)

		if PapyrusUtil.CountActor(OCum.currentSceneCummedOnActs, act) == 0
			OCum.currentSceneCummedOnActs = PapyrusUtil.PushActor(OCum.currentSceneCummedOnActs, act)
		endif

		if PapyrusUtil.CountActor(OCum.cummedOnActs, act) == 0
			OCum.cummedOnActs = PapyrusUtil.PushActor(OCum.cummedOnActs, act)
		endif
	endif

	return slotUsed

	; Cum textures from:
	; https://www.loverslab.com/files/file/2968-sexlab-cum-textures-remake-slavetats/
	; https://www.loverslab.com/files/file/243-sexlab-sperm-replacer/ - permission from: https://www.loverslab.com/topic/32080-sexlab-sperm-replacer-3dm-forum-version/
	; https://www.loverslab.com/files/file/14696-slavetats-cum-texturesreplacer
	; https://www.nexusmods.com/skyrimspecialedition/mods/33555
EndFunction


Function CumShoot(Actor Act, Float AmountML, String SceneID)
	Act.SendModEvent("ocum_cum_shoot", StrArg = SceneID, NumArg = AmountML)

	if OCum.DisableCumShot
		return
	endif

	if IsVaginalSex(sceneID) || IsBlowjob(sceneID) || isAnalSex(SceneID)
		return
	endif

	int size = GetLoadSizeFromML(AmountML)

	if size == 0
		return
	endif

	int numSpurts
	float Frequency
	int inaccuracy = 40

	Frequency = Utility.RandomFloat(0.1, 0.4)

	numSpurts = Utility.RandomInt(2, 4)

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

	while (i < numSpurts) && OStim.AnimationRunning()

		;aiming
		targetX = uPos[0] + uRM[1] * 200.0 + Utility.RandomFloat(0-inaccuracy, inaccuracy)
		targetY = uPos[1] + uRM[4] * 200.0 + Utility.RandomFloat(0-inaccuracy, inaccuracy)
		targetZ = uPos[2] + uRM[7] * 200.0 + Utility.RandomFloat(-10.0, 10.0) - ((i as Float) / (numSpurts as Float) - 0.5) * 180.0  ; later spurts fly lower, and (usually) less distance
		target.SetPosition(targetX, targetY, targetZ)

		FireCumBlast(caster, target, Utility.RandomInt(1, 4), act)

		Utility.Wait(Frequency)

	i += 1
	EndWhile

	caster.Delete()
	target.Delete()
EndFunction


Function FireCumBlast(ObjectReference base, ObjectReference angle, int amount, actor act)
	Spell cum

	if amount == 1
		cum = CumSpell1
	elseif amount == 2
		cum = CumSpell2
	elseif amount == 3
		cum = CumSpell3
	elseif amount == 4
		cum = CumSpell4
	endif

	cum.Cast(base, aktarget = angle)

	; Sounds from:
	; https://freesound.org/people/j1987/sounds/106395/
	; https://freesound.org/people/Intimidated/sounds/74511/

	; https://freesound.org/people/Lukeo135/sounds/530617/
	; https://freesound.org/people/nicklas3799/sounds/467348/
EndFunction


Function SetUrethra(actor a)
	a.EquipItem(UrethraNode, abPreventRemoval = True, abSilent = True)  ; don't do AddItem first, it will make NPCs redress

	if OStim.IsInFreeCam() && a == playerref
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


Function AddActorToStagesFactions(Actor Act)
	Act.AddToFaction(ChestStageFaction)
	Act.AddToFaction(ButtStageFaction)
	Act.AddToFaction(BellyStageFaction)

	Act.AddToFaction(ChestStageSlotFaction)
	Act.AddToFaction(ButtStageSlotFaction)
	Act.AddToFaction(BellyStageSlotFaction)

	Act.SetFactionRank(ChestStageFaction, 0)
	Act.SetFactionRank(ButtStageFaction, 0)
	Act.SetFactionRank(BellyStageFaction, 0)

	Act.SetFactionRank(ChestStageSlotFaction, -1)
	Act.SetFactionRank(ButtStageSlotFaction, -1)
	Act.SetFactionRank(BellyStageSlotFaction, -1)
EndFunction


Function RemoveActorFromStagesFactions(Actor Act)
	Act.RemoveFromFaction(ChestStageFaction)
	Act.RemoveFromFaction(ButtStageFaction)
	Act.RemoveFromFaction(BellyStageFaction)

	Act.RemoveFromFaction(ChestStageSlotFaction)
	Act.RemoveFromFaction(ButtStageSlotFaction)
	Act.RemoveFromFaction(BellyStageSlotFaction)
EndFunction
