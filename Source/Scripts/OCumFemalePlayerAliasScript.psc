ScriptName OCumFemalePlayerAliasScript Extends ReferenceAlias

OCumFemaleScript Property OCumFemale Auto

Event OnInit()
	OCumFemale = (GetOwningQuest()) as OCumFemaleScript
EndEvent

Event OnPlayerLoadGame()
	OCumFemale.OnLoad()
EndEvent
