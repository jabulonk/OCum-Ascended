ScriptName OCumMaleScript extends Quest

import OCumUtils
import OCumSceneDataUtils

; ------------------------ Properties and script wide Vars ------------------------ ;

int cumPatternNone = 0
int cumPatternVaginal = 1
int cumPatternOral = 2
int cumPatternAnal = 3
int cumPatternBoobOral = 4
int cumPatternFeet = 5
int cumPatternVaginalPullout = 6
int cumPatternAnalPullout = 7

bool curPoseIsBlowjob = false
bool curPoseIsVaginal = false
bool curPoseIsAnal = false
bool curPoseIsVaginalPullout = false
bool curPoseIsAnalPullout = false
bool curPoseIsHandjob = false
bool curPoseIsBreastjob = false
bool curPoseIsFootjob = false

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

Faction property HasCumFaction auto

Keyword property AppliedCumKeyword auto

Spell property OCumSpell auto

Spell property CumSpell1 auto
Spell property CumSpell2 auto
Spell property CumSpell3 auto
Spell property CumSpell4 auto

Activator property CumLauncher auto

OSexIntegrationMain property OStim auto

OCumScript property OCum auto

Form OCumPseudoArmor

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

	RegisterForModEvent("ostim_thread_start", "OStimStart")
	RegisterForModEvent("ostim_actor_orgasm", "OStimOrgasm")
	RegisterForModEvent("ocum_play_cum_shoot_effect", "OCumPlayCumShoot")

	TeraElinRace = Game.GetFormFromFile(0x00001000, "TeraElinRace.esm") As Race
	TeraElinRaceVampire = Game.GetFormFromFile(0x00001001, "TeraElinRace.esm") As Race

	if HasCumFaction == None
		HasCumFaction = Game.GetFormFromFile(0xF46, "OCum.esp") As Faction
	endif

	OCumPseudoArmor = Game.GetFormFromFile(0xF49, "OCum.esp")
EndFunction


Event OStimStart(string eventName, string strArg, float numArg, Form sender)
	int threadID = numArg as int

	if threadID > 0 && !OCum.enableNPCSceneSupport
		return
	endif

	Actor[] sceneActors = OThread.GetActors(threadID)

	int i = sceneActors.length

	Actor currentAct

	while i > 0
		i -= 1

		currentAct = sceneActors[i]

		AddActorToStagesFactions(currentAct)

		if !NiOverride.HasOverlays(currentAct)
			Form armorIn32 = currentAct.GetWornForm(0x00000004)

			; this is a very dirty workaround for a Racemenu bug where overlays do not apply properly
			; but it works without breaking anything, so that's what matters
			If armorIn32 == None
				currentAct.EquipItem(OCumPseudoArmor, false, true)
				Utility.Wait(0.05)
				NiOverride.AddOverlays(currentAct)
				Utility.Wait(0.05)
				currentAct.UnequipItem(OCumPseudoArmor, false, true)
				currentAct.Removeitem(OCumPseudoArmor, 1, true)
			else
				NiOverride.AddOverlays(currentAct)
			EndIf
		endif

		if threadID == 0 && !OStim.IsFemale(currentAct)
			SetUrethra(currentAct)
		endif
	endwhile
EndEvent


Event OstimOrgasm(string eventName, string strArg, float numArg, Form sender)
	; The main OCum event
	; Handles the logic when an orgasm is reached:
	; Applies cum decals and cum shots
	; Drains the cum bar accordingly
	; Plays the respective sounds

	int threadID = numArg as int

	if threadID > 0 && !OCum.enableNPCSceneSupport
		return
	endif

	Actor orgasmer = sender as Actor

	if !OStim.IsFemale(orgasmer)
		OThread.StallClimax(threadID)

		string sceneID = strArg

		float amountML

		float currentCum = OCum.GetCumStoredAmount(orgasmer)

		float maxStorage = OCum.GetMaxCumStoragePossible(orgasmer)

		float rand = (Utility.RandomInt(10, 50) as float) / 100.0

		float idealMax = (maxStorage / currentCum) + (maxStorage * rand)

		if idealMax < currentCum
			amountML = idealMax
		else
			amountML = currentCum
		endif

		OCum.AdjustStoredCumAmount(orgasmer, 0 - amountML, currentCum)

		

		; stuff to only do if the orgasm was in the player thread
		if threadID == 0
			WriteLog("Blowing load size: " + amountML + " ML")

			OCum.TempDisplayBar()

			; don't play cum shoot animation in NPC scenes - it might cause CTDs or other weird visual artifacts
			; don't listen for this event, it's only for self consumption so cum shoot runs asynchronously
			orgasmer.SendModEvent("ocum_play_cum_shoot_effect", StrArg = sceneID, NumArg = amountML)
		else
			; only do the "simple" cum applying if it's an npc scene.
			; if it's a player scene, we want to keep applying it
			if OThread.GetActors(threadID).Length > 1
				int intensity = GetLoadSizeFromStoragePercent(amountML / maxStorage)
	
				if intensity > 0
					ApplyCumAsNecessary(orgasmer, threadID, intensity, amountML, sceneID)
				endif
			EndIf
		endif

		OThread.PermitClimax(threadID)
	endif
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


Function ApplyCumAsNecessary(Actor Orgasmer, int ThreadID, int Intensity, float AmountML, string SceneID)
	int actorPos = OThread.GetActorPosition(ThreadID, Orgasmer)

	; cumming actor is the action-actor, so we need cum slots of the action-target (vaginalsex, analsex, etc)
	; custom record parameters are CSV actor,target,performer, so since we want target we lead with a comma
	int[] Actions = OMetadata.FindActionsSuperloadCSVv2(SceneID, ActorPositions = actorPos, AnyCustomStringListRecord = ";cum")
	int i = Actions.Length

	bool cumWasApplied = false

	While i
		i -= 1
		Actor Target = OThread.GetActor(ThreadID, OMetadata.GetActionTarget(SceneID, Actions[i]))

		; some animations might be tagged funny and cause OStim to find the orgasmer as the target
		; so this check serves as a fail-safe
		;if Orgasmer != Target || StringContains(Actions[i], "cum")
			String[] Slots = OMetadata.GetCustomActionTargetStringList(SceneID, Actions[i], "cum")

			int j = Slots.Length

			While j
				j -= 1

				ApplyCum(Orgasmer, Target, Slots[j], Intensity, AmountML, SceneID, ThreadID)
				cumWasApplied = True
			EndWhile
		;endif
	EndWhile

	; cummin actor is the action-target, so we need cum slots of the action-actor (blowjob, boobjob, etc)
	; this time we want the custom record of the action-actor, so no leading comma
	Actions = OMetadata.FindActionsSuperloadCSVv2(SceneID, TargetPositions = actorPos, AnyCustomStringListRecord = "cum")
	i = Actions.Length

	While i
		i -= 1
		Actor Target = OThread.GetActor(ThreadID, OMetadata.GetActionActor(SceneID, Actions[i]))

		; some animations might be tagged funny and cause OStim to find the orgasmer as the target
		; so this check serves as a fail-safe
		;if Orgasmer != Target || StringContains(Actions[i], "cum")
			String[] Slots = OMetadata.GetCustomActionActorStringList(SceneID, Actions[i], "cum")

			int j = Slots.Length

			While j
				j -= 1

				ApplyCum(Orgasmer, Target, Slots[j], Intensity, AmountML, SceneID, ThreadID)
				cumWasApplied = True
			EndWhile
		;endif
	EndWhile

	if !cumWasApplied
		bool isHJ = IsHandjob(SceneID)
		bool isFJ = IsFootJob(SceneID)

		; Handjob and Footjob has no cum target since it can be given in different positions
		; so we must calculate cum area ourselves.
		; Only if cum was not applied through the animation tags previously
		if isHJ || isFJ
			int[] actorsGiving = OMetadata.GetActionActors(SceneID)
	
			i = actorsGiving.Length
	
			string area
	
			Actor actorGiving
			Actor actorReceiving = OThread.GetActor(ThreadID, ActorPos)
	
			while i > 0
				i -= 1
	
				actorGiving = OThread.GetActor(ThreadID, actorsGiving[i])
	
				area = CalculateCumAreaFromSkeleton(actorReceiving, actorGiving)
	
				ApplyCum(Orgasmer, actorGiving, area, Intensity, AmountML, SceneID, ThreadID)
	
				if isHJ
					ApplyCum(Orgasmer, actorGiving, "hands", Intensity, AmountML, SceneID, ThreadID)
				endif
				
				if isFJ
					ApplyCum(Orgasmer, actorGiving, "feet", Intensity, AmountML, SceneID, ThreadID)
				endif
			endwhile
		endif
	endif
EndFunction


Function ApplyCum(Actor Orgasmer, Actor Target, String Area, Int Intensity, Float AmountML, String SceneID, Int ThreadID)
	if OCum.DisableFacialsForElins && (Area == "face" || Area == "mouth" || Area == "throat")
		Race cummedActRace = Target.GetRace()

		; don't apply facials to Tera Elin race if it is set like that on MCM
		; Elins use a different face map, so facial textures may look bad on them
		if (teraElinRace && teraElinRaceVampire && (cummedActRace == teraElinRace || cummedActRace == teraElinRaceVampire))
			writelog("Cummed actor is an Elin, not applying facial texture")
			return
		endif
	endif

	SendCumAppliedEvents(ThreadID, Orgasmer, Target, AmountML, Area, SceneID)

	; creampie, facial and cumonXXX are new actions which are supposed to be used in designated climax animations
	; basically they all just mean the male pulls out, jerks off and them cums on a part of the female

	; some of these slots might overlap in a single scene depending on how much actions it contains
	; so there is a chance the same slot is called twice in a single orgasm event
	If Area == "belly"
		ApplyCumBelly(Target, Intensity, ThreadID)
	ElseIf Area == "butt"
		ApplyCumButt(Target, Intensity, ThreadID)
	ElseIf Area == "chest"
		ApplyCumBoob(Target, Intensity, ThreadID)
	ElseIf Area == "face"
		ApplyCumFacial(Target, Intensity, ThreadID)
	ElseIf Area == "feet"
		ApplyCumFeet(Target, Intensity, ThreadID)
	ElseIf Area == "hands"
		ApplyCumHands(Target, ThreadID)
	ElseIf Area == "mouth"
		ApplyCumMouth(Target, Intensity, ThreadID)
	ElseIf Area == "rectum"
		ApplyCumAnal(Target, ThreadID)
	ElseIf Area == "thighs"
		ApplyCumThighs(Target, ThreadID)
	ElseIf Area == "throat"
		ApplyCumThroat(Target, Intensity, ThreadID)
	ElseIf Area == "vagina"
		ApplyCumVaginal(Target, Intensity, ThreadID)
	EndIf
EndFunction


Function ApplyCumAnal(Actor Target, int ThreadID)
	if ThreadID == 0 && !OCum.disableCumMeshes && !Target.IsEquipped(CumMeshAnal) && ChanceRoll(OCum.analpieChance)
		OActor.EquipObject(Target, "ocumanmesh")
	endif

	if OCum.enableVagAnOverlays || ThreadID > 0
		CumOntoArea(Target, "Anal" + Utility.RandomInt(1, 4), "Body")
	endif
EndFunction


Function ApplyCumBelly(actor Target, int Intensity, int ThreadID)
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


Function ApplyCumBoob(actor Target, int Intensity, int ThreadID)
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


Function ApplyCumButt(actor Target, int Intensity, int ThreadID)
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


Function ApplyCumFacial(actor Target, int Intensity, int ThreadID)
	if intensity <= 2
		CumOntoArea(Target, "Facial" + Utility.RandomInt(1, 3), "Face")
	elseif intensity == 3
		CumOntoArea(Target, "Facial" + Utility.RandomInt(3, 6), "Face")
	else
		CumOntoArea(Target, "Facial" + Utility.RandomInt(4, 11), "Face")
	endif
EndFunction


Function ApplyCumFeet(Actor Target, int Intensity, int ThreadID)
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


Function ApplyCumHands(Actor Target, int ThreadID)
	CumOntoArea(Target, "Hands", "Hands")
EndFunction


Function ApplyCumMouth(Actor Target, int Intensity, int ThreadID)
	if Intensity <= 2
		CumOntoArea(Target, "Mouth" + Utility.RandomInt(1, 4), "Face")
	else
		CumOntoArea(Target, "Mouth" + Utility.RandomInt(3, 7), "Face")
	endif
EndFunction


Function ApplyCumThighs(Actor Target, int ThreadID)
	CumOntoArea(Target, "Legs" + Utility.RandomInt(1, 2))
EndFunction


Function ApplyCumThroat(Actor Target, int Intensity, int ThreadID)
	if Intensity <= 2 && ChanceRoll(50)
		return
	endif

	CumOntoArea(Target, "Mouth" + Utility.RandomInt(1, 3), "Face")
EndFunction


Function ApplyCumVaginal(Actor Target, int Intensity, int ThreadID)
	if ThreadID == 0 && !OCum.disableCumMeshes && !Target.IsEquipped(CumMeshPussy) && ChanceRoll(OCum.creampieChance)
		OActor.EquipObject(Target, "ocumvagmesh")
	endif

	if OCum.enableVagAnOverlays || ThreadID > 0
		if Intensity <= 2
			CumOntoArea(Target, "VaginalCreampie" + Utility.RandomInt(1, 3), "Body")
		else
			CumOntoArea(Target, "VaginalCreampie" + Utility.RandomInt(2, 6), "Body")
		endif
	endif
EndFunction


int Function CumOntoArea(Actor Act, string TexFilename, string area = "Body", int Slot = -1)
	WriteLog("CumOntoArea")

	int slotUsed = Slot
	string cumTexture = GetCumTexture(TexFilename)

	if !OCum.DisableCumDecal
		slotUsed = ReadyOverlay(Act, ostim.AppearsFemale(Act), area, cumTexture, Slot)

		OCum.RegisterForCleaningOnEnteringWater(Act)

		if !Act.IsInFaction(HasCumFaction)
			Act.AddToFaction(HasCumFaction)
			Act.SetFactionRank(HasCumFaction, 1)
		endif

		if !Act.HasMagicEffectWithKeyWord(AppliedCumKeyword)
			OCumSpell.Cast(Act, Act)
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
	if OCum.DisableCumShot
		return
	endif

	; we can assume thread id 0 because only player scenes can have shots
	bool isSolo = OThread.GetActors(0).Length <= 1

	bool shouldApplyOverlays = !isSolo

	int size = GetLoadSizeFromML(AmountML)

	if size == 0
		return
	endif

	float mlsLeft = AmountML
	float baseMlPerProj = Utility.RandomFloat(0.45, 0.78)

	float maxMlPerSpurt = AmountML / 12.0

	if maxMlPerSpurt < baseMlPerProj
		maxMlPerSpurt = baseMlPerProj + 1.0
	endif

	; blasts should start with smaller intervals and then get bigger intervals as the orgasm ends 
	float StartFrequency = Utility.RandomFloat(0.45, 0.75) / AmountML
	float EndFrequencyIncrement = Utility.RandomFloat(0.15, 0.25)

	float Frequency = StartFrequency
	int inaccuracy = 10

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

	float maxContractionAngle = 15.0
	float contractionAngleStep = 3.0
	float[] contractionAddRot = new float[3]
	float[] contractionSubRot = new float[3]
	contractionAddRot[2] = contractionAngleStep
	contractionSubRot[2] = -contractionAngleStep

	int cumPatternOfLastPose = GetCumPattern(SceneID)
	int cumPatternOfNewPose = cumPatternOfLastPose
	bool hasAppliedCumMeshOnCurrentPose = false

	; so that we can add new slots as spurts accumulate in the same animation,
	; but without adding the same ones over and over
	int[] decalSlotsToUse = new int[15]
	int i_decalslot = decalSlotsToUse.Length
	while i_decalslot > 0
		i_decalslot -= 1
		decalSlotsToUse[i_decalslot] = -1
	endwhile

	float mlShotOnCurrentPose = 0.0

	while (mlsLeft > 0.0) && OThread.IsRunning(0)

		bool shouldShoot = true
		shouldApplyOverlays = !isSolo

		float spurtML = Utility.RandomFloat(baseMlPerProj / 2.0, maxMlPerSpurt)
		if spurtML > mlsLeft
			spurtML = mlsLeft
		endif

		mlsLeft -= spurtML

		; orgasm contraction!
		float desiredContraction = Utility.RandomFloat(maxContractionAngle * 0.5, maxContractionAngle)
		float accumulatedAngle = 0.0

		while accumulatedAngle < desiredContraction
			accumulatedAngle += contractionAngleStep * 2.0 ; contraction is faster than relaxing

			if accumulatedAngle > desiredContraction
				accumulatedAngle = desiredContraction
			endif

			contractionAddRot[2] = accumulatedAngle
			contractionSubRot[2] = -accumulatedAngle

			; bend one in one direction, the other in the opposite
			NiOverride.AddNodeTransformRotation(act, false, false, "CME GenitalsBase [GenBase]", "Ocum-custom", contractionSubRot)
			NiOverride.AddNodeTransformRotation(act, true, false, "CME GenitalsBase [GenBase]", "Ocum-custom", contractionSubRot)
			NiOverride.UpdateNodeTransform(act, false, false, "CME GenitalsBase [GenBase]")
			NiOverride.UpdateNodeTransform(act, true, false, "CME GenitalsBase [GenBase]")
			NiOverride.AddNodeTransformRotation(act, false, false, "CME Genitals01 [Gen01]", "Ocum-custom", contractionAddRot)
			NiOverride.AddNodeTransformRotation(act, true, false, "CME Genitals01 [Gen01]", "Ocum-custom", contractionAddRot)
			NiOverride.UpdateNodeTransform(act, false, false, "CME Genitals01 [Gen01]")
			NiOverride.UpdateNodeTransform(act, true, false, "CME Genitals01 [Gen01]")

			Utility.Wait(0.01)
		endwhile

		; check for pose, for overlay applying and projectile spawning
		; since there may be a lot of spurts and the animation can change before it's finished, we should keep checking for each blast
		curPoseIsBlowjob = false
		curPoseIsVaginal = false
		curPoseIsAnal = false
		curPoseIsVaginalPullout = false
		curPoseIsAnalPullout = false
		curPoseIsHandjob = false
		curPoseIsBreastjob = false
		curPoseIsFootjob = false

		SceneId = OThread.GetScene(0)
		if IsBlowjob(SceneId)
			curPoseIsBlowjob = true
		ElseIf IsVaginalSex(SceneId)
			curPoseIsVaginal = true
		ElseIf IsAnalSex(SceneId)
			curPoseIsAnal = true
		ElseIf IsVaginalPullout(SceneId)
			curPoseIsVaginalPullout = true
		ElseIf IsAnalPullout(SceneId)
			curPoseIsAnalPullout = true
		ElseIf IsHandjob(SceneId)
			curPoseIsHandjob = true
		ElseIf IsBreastjob(SceneId)
			curPoseIsBreastjob = true
		ElseIf IsFootjob(SceneId)
			curPoseIsFootjob = true
		endif

		if curPoseIsBlowjob || curPoseIsVaginal || curPoseIsAnal
			shouldShoot = false
		endif

		if spurtML < baseMlPerProj && spurtML + mlsLeft < AmountML
			; too little cum in this spurt!
			; it's a dry contraction.
			; we force the first spurt to have some content though
			shouldShoot = false
			shouldApplyOverlays = false
		endif

		; apply cum layers
		If shouldApplyOverlays
			cumPatternOfNewPose = GetCumPattern(SceneId)
			if cumPatternOfNewPose != cumPatternOfLastPose
				; pose has changed! reset pose-dependent vars
				cumPatternOfLastPose = cumPatternOfNewPose
				mlShotOnCurrentPose = 0.0

				i_decalslot = decalSlotsToUse.Length
				while i_decalslot > 0
					i_decalslot -= 1
					decalSlotsToUse[i_decalslot] = -1
				endwhile
			endif

			mlShotOnCurrentPose += spurtML

			ApplyCumAsNecessary(Act, 0, GetLoadSizeFromML(mlShotOnCurrentPose), spurtML, SceneID)
			
		EndIf

		If shouldShoot
			NetImmerse.GetNodeWorldPosition(act, "Urethra", uPos, False) ;setting arrays like this is possible apparently...........
			caster.SetPosition(uPos[0], uPos[1], uPos[2])
			NetImmerse.GetNodeWorldRotationMatrix(act, "Urethra", uRM, False)  ; (uRM[1] uRM[4] uRM[7]) is the direction vector for the spurts to be launched (local y axis of the node)

			;aiming
			targetZ = uPos[2] + uRM[7] * 200.0 + 45.0 + Utility.RandomFloat(-10.0, 10.0) + (1.0 - (AmountML - mlsLeft) / (AmountML)) * 45.0  ; later spurts fly lower, and (usually) less distance

			while spurtML > 0.0
				targetX = uPos[0] + uRM[1] * 200.0 + Utility.RandomFloat(0-inaccuracy, inaccuracy)
				targetY = uPos[1] + uRM[4] * 200.0 + Utility.RandomFloat(0-inaccuracy, inaccuracy)

				target.SetPosition(targetX, targetY, targetZ)

				FireCumBlast(caster, target, Utility.RandomInt(1, 4), act)

				spurtML -= baseMlPerProj
				Utility.Wait(0.01)
			endwhile
		else
			; add extra waiting according to the spurt size, to not make cumming inside/outside too different in terms of duration
			Utility.Wait(0.08 / (spurtML / baseMlPerProj))
		endif
		

		frequency = StartFrequency + EndFrequencyIncrement * ((AmountML - mlsLeft) / (AmountML))

		; undo contraction after the spurt
		while accumulatedAngle > 0.0
			accumulatedAngle -= contractionAngleStep

			If accumulatedAngle < 0.0
				accumulatedAngle = 0.0
			EndIf

			contractionAddRot[2] = accumulatedAngle
			contractionSubRot[2] = -accumulatedAngle

			; bend in opposite directions from the starting contraction, to undo it
			NiOverride.AddNodeTransformRotation(act, false, false, "CME GenitalsBase [GenBase]", "Ocum-custom", contractionSubRot)
			NiOverride.AddNodeTransformRotation(act, true, false, "CME GenitalsBase [GenBase]", "Ocum-custom", contractionSubRot)
			NiOverride.AddNodeTransformRotation(act, false, false, "CME Genitals01 [Gen01]", "Ocum-custom", contractionAddRot)
			NiOverride.AddNodeTransformRotation(act, true, false, "CME Genitals01 [Gen01]", "Ocum-custom", contractionAddRot)
			NiOverride.UpdateNodeTransform(act, false, false, "CME GenitalsBase [GenBase]")
			NiOverride.UpdateNodeTransform(act, true, false, "CME GenitalsBase [GenBase]")
			NiOverride.UpdateNodeTransform(act, false, false, "CME Genitals01 [Gen01]")
			NiOverride.UpdateNodeTransform(act, true, false, "CME Genitals01 [Gen01]")

			Utility.Wait(0.01)
		endwhile

		Utility.Wait(frequency)
		
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
EndFunction


Function SetUrethra(Actor Act)
	OActor.EquipObject(Act, "ocumurnode")

	if Act == playerref
		Act.QueueNiNodeUpdate()
	endif

	Float[] move0 = new Float[3]
	Float[] move100 = new Float[3]
	Float[] rotate = new Float[3]
	Float[] move = new Float[3]

	Float aWeight = Act.GetActorBase().GetWeight()

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

	NiOverride.AddNodeTransformPosition(Act, False, False, "Urethra", "SLCCumAdjust", move)
	NiOverride.AddNodeTransformRotation(Act, False, False, "Urethra", "SLCCumAdjust", rotate)
	NiOverride.UpdateNodeTransform(Act, False, False, "Urethra")
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


Function SendCumAppliedEvents(Int ThreadID, Actor Orgasmer, Actor Target, Float AmountML, String Area, String SceneID)
	if ThreadID == 0
		int handle = ModEvent.Create("ocum_applied_cum")
		ModEvent.PushForm(handle, Orgasmer)
		ModEvent.PushForm(handle, Target)
		ModEvent.PushFloat(handle, AmountML)
		ModEvent.PushString(handle, Area)
		ModEvent.PushString(handle, SceneID)
		ModEvent.Send(handle)
	else
		int handleNPC = ModEvent.Create("ocum_applied_cum_npc_scene")
		ModEvent.PushForm(handleNPC, Orgasmer)
		ModEvent.PushForm(handleNPC, Target)
		ModEvent.PushInt(handleNPC, ThreadID)
		ModEvent.PushFloat(handleNPC, amountML)
		ModEvent.PushString(handleNPC, Area)
		ModEvent.PushString(handleNPC, SceneID)
		ModEvent.Send(handleNPC)
	endif
EndFunction


; This function will soon be deprecated
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


int Function GetCumPattern(string sceneId)
	if curPoseIsVaginal
		return cumPatternVaginal
	elseif curPoseIsAnal
		return cumPatternAnal
	elseif curPoseIsBlowjob
		return cumPatternOral
	elseif curPoseIsBreastjob
		return cumPatternBoobOral
	elseif curPoseIsFootjob
		return cumPatternFeet
	elseif curPoseIsHandjob || curPoseIsVaginalPullout || curPoseIsAnalPullout
		return CalculateCumPatternFromSkeleton(ostim.GetDomActor(), ostim.GetSubActor(), sceneId)
	else
		return cumPatternNone
	endif
EndFunction

int Function CalculateCumPatternFromSkeleton(actor male, actor female, string sceneId)
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
	if IsVaginalPullout(sceneId) || IsAnalPullout(sceneId)
		if smallestDistance == cumPatternVaginal
			pattern = cumPatternVaginalPullout
		elseif smallestDistance == cumPatternAnal
			pattern = cumPatternAnalPullout
		endif
	endif

	return pattern
EndFunction
