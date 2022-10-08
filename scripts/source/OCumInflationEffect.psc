ScriptName OCumInflationEffect extends ActiveMagicEffect

OCumScript property OCum auto

Event OnEffectFinish(Actor akTarget, Actor akCaster)
	; Same logic as the one documented in OCumEffect.psc
	if PapyrusUtil.CountActor(OCum.currentSceneBellyInflationActs, akTarget) == 0
		OCum.writelog("Cleaning cum inflation from " + akTarget.GetActorBase().GetName())
		OCum.RemoveBellyScale(akTarget, !OCum.isRemovingInflationFromAllActors)
	endif
endEvent
