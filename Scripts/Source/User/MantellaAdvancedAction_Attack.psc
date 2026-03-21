Scriptname MantellaAdvancedAction_Attack extends Quest Hidden

MantellaRepository  repository 
MantellaConstants  mConsts 
MantellaInterface  EventInterface 
MantellaConversation  conversation 
ActorValue WaitingForPlayer
Faction MantellaFunctionSourceFaction
Faction MantellaFunctionTargetFaction

ObjectReference Property PlayerRef Auto Const Mandatory
RefCollectionAlias Property AttackSourceAliases Auto Const
ReferenceAlias Property AttackTargetAlias Auto Const
    
Function InitVars()
    Form conversationForm = Game.GetFormFromFile(0x066FBB, "Mantella.esp") ; MantellaConversation
    Form questForm = Game.GetFormFromFile(0x000F99, "Mantella.esp") ; MantellaQuest
    WaitingForPlayer = Game.GetForm(0x00031C) as ActorValue; WaitingForPlayer ActorValue
    MantellaFunctionSourceFaction = Game.GetFormFromFile(0x056E10, "Mantella.esp") as Faction
    MantellaFunctionTargetFaction = Game.GetFormFromFile(0x04BF41, "Mantella.esp") as Faction

    conversation = conversationForm as MantellaConversation
    repository = questForm as MantellaRepository
    mConsts =conversationForm as MantellaConstants
    EventInterface = conversationForm as MantellaInterface
    
    Debug.TraceUser("MC", "Attack Variables initialized: conversation=" + conversation + ", repository=" + repository + ", mConsts=" + mConsts + ", EventInterface=" + EventInterface)
EndFunction

event OnInit()
    InitVars()
    string eventName = EventInterface.EVENT_ADVANCED_ACTIONS_PREFIX + mConsts.ACTION_NPC_OFFENDED
    Debug.OpenUserLog("MC")
    Debug.TraceUser("MC", "Attack Registering for Attack event: " + eventName)
    RegisterForExternalEvent(eventName, "OnNpcAttackActionReceived")
EndEvent

Event OnQuestInit()
    Debug.TraceUser("MC", "Attack OnQuestInit called in MantellaAdvancedAction_Attack")
    ;OnInit() ; Ensure that the event registration happens on quest init as well, in case the quest is added after game start
EndEvent

int _usedAliasCount = 0
Actor[] _movingActors

Function OnNpcAttackActionReceived(int speakerID, string unused, int argumentsHandle)
    if !self.isrunning()
        self.Start()
    EndIf

    if argumentsHandle == -1
        if speakerID != 0
            Actor speaker = Game.GetForm(speakerID) as Actor
            Debug.TraceUser("MC", "Received Attack legacy action event")
            AttackTargetAlias.ForceRefTo(PlayerRef)
            _usedAliasCount = 1

            _movingActors[0] = speaker

            CleanupAttack()
        else
            Debug.TraceUser("MC", "Received Attack legacy action event with no speaker")
        endif
    Else
        Debug.TraceUser("MC", "Received Attack advanced action event " )
        OnNpcAttackAdvancedActionReceived(speakerID, unused, argumentsHandle)
    EndIf

endFunction


Function OnNpcAttackAdvancedActionReceived(int speakerID, string unused, int argumentsHandle)
    ; Extract NPC names from parameters
    string[] sourceNames = MantellaPlugin.getStringArray(argumentsHandle, mConsts.ACTION_ARG_SOURCE)
    string targetName = MantellaPlugin.getString(argumentsHandle, mConsts.ACTION_ARG_TARGET)

    Debug.TraceUser("MC", "Attack action received with target: " + targetName)
    ; Only one target supported for move to action
    Actor targetActor = conversation.GetActorByName(targetName)
    if targetActor
        AttackTargetAlias.ForceRefTo(targetActor)
       
        ; Reset tracking
        _usedAliasCount = 0
        int numSources = sourceNames.Length
        if numSources > 12
            numSources = 12  ; Cap at available aliases
        endif
        
        AttackSourceAliases.RemoveAll()
        self.Start()

        ; Resolve each name to an Actor reference and start movement
        int i = 0
        While i < numSources
            Actor sourceActor = conversation.GetActorByName(sourceNames[i])
            if sourceActor
                Debug.Notification(sourceActor.GetDisplayName() + " moves to " + targetActor.GetDisplayName() + ".")
                Debug.TraceUser("MC", "Initiating Attack for " + sourceActor.GetDisplayName() + " to " + targetActor.GetDisplayName())
                sourceActor.StartCombat(targetActor)

                _movingActors[i] = sourceActor
                _usedAliasCount += 1
                ; Assign to specific alias which has the Attack package
                AttackSourceAliases.AddRef(sourceActor)
            endif
            i += 1
        EndWhile

        AttackSourceAliases.EvaluateAll()
        CleanupAttack()
    endIf
endFunction


Function CleanupAttack()
    AttackSourceAliases.RemoveAll()
    AttackTargetAlias.Clear()
    _usedAliasCount = 0
EndFunction

