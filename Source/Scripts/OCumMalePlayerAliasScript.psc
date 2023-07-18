ScriptName OCumMalePlayerAliasScript Extends ReferenceAlias

OCumMaleScript Property OCumMale Auto

Event OnInit()
	OCumMale = (GetOwningQuest()) as OCumMaleScript
EndEvent

Event OnPlayerLoadGame()
	OCumMale.OnLoad()
EndEvent
