ScriptName OCumEffect extends ActiveMagicEffect

OCumScript property OCum auto

Event OnEffectFinish(Actor akTarget, Actor akCaster)
	; If actor is not in an OStim scene, clear decals after time is up
	if !OActor.IsInOStim(akTarget)
		OCumUtils.writelog("Cleaning cum textures from " + akTarget.GetActorBase().GetName())
		OCum.CleanCumTexturesFromActor(akTarget)
	; Otherwise, refresh the effect
	else
		OCum.OCumSpell.Cast(akTarget, akTarget)
	endif
endEvent
