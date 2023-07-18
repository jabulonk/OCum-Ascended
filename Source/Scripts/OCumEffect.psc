ScriptName OCumEffect extends ActiveMagicEffect

OCumScript property OCum auto

Event OnEffectFinish(Actor akTarget, Actor akCaster)
	; When an actor is cummed on during a scene, he is added to the currentSceneCummedOnActs array.
	; If an actor enters a new scene already with cum, he still has a cum effect active. Therefore, there is
	; a chance that the previous cum effect might end during this new scene.
	; If that happens, current cum textures will be cleaned off, and if the actor was already cummed on during the new
	; scene, we obviously don't want the cleanup to happen. As a result, we don't perform the cleanup if he is currently
	; in the currentSceneCummedOnActs array. At the end of this new scene, the cum effect will be refreshed,
	; and when that effect ends, the cleanup will trigger anyway.
	; Otherwise, we can proceed with the cleaning of the actor's cum when the effect ends with no problems
	if PapyrusUtil.CountActor(OCum.currentSceneCummedOnActs, akTarget) == 0
		OCumUtils.writelog("Cleaning cum textures from " + akTarget.GetActorBase().GetName())
		OCum.CleanCumTexturesFromActor(akTarget, !OCum.isRemovingCumFromAllActors)
	endif
endEvent
