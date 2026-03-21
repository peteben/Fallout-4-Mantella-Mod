Scriptname MantellaAdvancedAction_MoveTo extends Quest Hidden 

Actor PlayerRef 
MantellaRepository  repository 
MantellaConstants  mConsts 
MantellaInterface  EventInterface 
MantellaConversation  conversation 
ActorValue WaitingForPlayer
;Faction MantellaFunctionSourceFaction
;Faction MantellaFunctionTargetFaction

RefCollectionAlias Property  MoveToSourceAliases Auto
ReferenceAlias Property MoveToTargetAlias Auto
ObjectReference Property pPlayerRef Auto Const Mandatory

    
Function InitVars()
    PlayerRef = Game.GetPlayer()
    Form conversationForm = Game.GetFormFromFile(0x066FBB, "Mantella.esp") ; MantellaConversation
    Form questForm = Game.GetFormFromFile(0x000F99, "Mantella.esp") ; MantellaQuest
    WaitingForPlayer = Game.GetForm(0x00031C) as ActorValue; WaitingForPlayer ActorValue
    ;MantellaFunctionSourceFaction = Game.GetFormFromFile(0x056E10, "Mantella.esp") as Faction
    ;MantellaFunctionTargetFaction = Game.GetFormFromFile(0x04BF41, "Mantella.esp") as Faction

    conversation = conversationForm as MantellaConversation
    repository = questForm as MantellaRepository
    mConsts =conversationForm as MantellaConstants
    EventInterface = conversationForm as MantellaInterface
    
    ;Debug.TraceUser("MC", "MoveTo Variables initialized: conversation=" + conversation + ", repository=" + repository + ", mConsts=" + mConsts + ", EventInterface=" + EventInterface)
EndFunction

event OnInit()
    InitVars()
    string eventName = EventInterface.EVENT_ADVANCED_ACTIONS_PREFIX + mConsts.ACTION_NPC_MOVETO
    
    Debug.OpenUserLog("MC")
    Debug.TraceUser("MC", "MoveTo Registering for MoveTo event: " + eventName)
    RegisterForExternalEvent(eventName, "OnNpcMoveToActionReceived")
EndEvent

Event OnQuestInit()
    Debug.TraceUser("MC", "MoveTo OnQuestInit called in MantellaAdvancedAction_MoveTo")
    ;OnInit() ; Ensure that the event registration happens on quest init as well, in case the quest is added after game start
EndEvent

int _usedAliasCount = 0
Actor[] _movingActors
bool[] _wasWaitingBeforeMove ; Track wait states to restore after movement


Function OnNpcMoveToActionReceived(int speakerID, string unused, int argumentsHandle)
    if !self.isrunning()
        self.Start()
    EndIf

    if argumentsHandle == -1
        if speakerID != 0
            Actor speaker = Game.GetForm(speakerID) as Actor
            Debug.TraceUser("MC", "Received MoveTo legacy action event")
            MoveToTargetAlias.ForceRefTo(PlayerRef)
            _usedAliasCount = 1

            ; Track moving actors and their wait states
            _movingActors = new Actor[1]
            _wasWaitingBeforeMove = new bool[1]

            NpcMoveTo(speaker, PlayerRef, 0)
            _movingActors[0] = speaker

            WaitForMovement(PlayerRef, 1)
                
            CleanupMoveTo()
        else
            Debug.TraceUser("MC", "Received MoveTo legacy action event with no speaker")
        endif
    Else
        Debug.TraceUser("MC", "Received MoveTo advanced action event " )
        OnNpcMoveToAdvancedActionReceived(speakerID, unused, argumentsHandle)
    EndIf

endFunction


Function OnNpcMoveToAdvancedActionReceived(int speakerID, string unused, int argumentsHandle)
    ; Extract NPC names from parameters
    string[] sourceNames = MantellaPlugin.getStringArray(argumentsHandle, mConsts.ACTION_ARG_SOURCE)
    string targetName = MantellaPlugin.getString(argumentsHandle, mConsts.ACTION_ARG_TARGET)

    ; Only one target supported for move to action
    Actor targetActor = conversation.GetActorByName(targetName)
    if targetActor
        MoveToTargetAlias.ForceRefTo(targetActor)
       
        ; Reset tracking
        _usedAliasCount = 0
        int numSources = sourceNames.Length
        if numSources > 12
            numSources = 12  ; Cap at available aliases
        endif
        
        MoveToSourceAliases.RemoveAll()
        self.Start()

        ; Track moving actors and their wait states
        _movingActors = new Actor[12]
        _wasWaitingBeforeMove = new bool[12]
        
        ; Resolve each name to an Actor reference and start movement
        int i = 0
        While i < numSources
            Actor sourceActor = conversation.GetActorByName(sourceNames[i])
            if sourceActor
                NpcMoveTo(sourceActor, targetActor, i)
                _movingActors[i] = sourceActor
            endif
            i += 1
        EndWhile

        ;Actor testActor = MoveToSourceAliases.GetAt(0) as Actor
        ;Debug.TraceUser("MC", testActor.GetDisplayName() + "(T1) rank is " + testActor.GetFactionRank(MantellaFunctionSourceFaction))
        ;Debug.TraceUser("MC", testActor.GetDisplayName() + "(T1) package: " + testActor.GetCurrentPackage())
        MoveToSourceAliases.EvaluateAll()
        ;Debug.TraceUser("MC", testActor.GetDisplayName() + "(T2) package: " + testActor.GetCurrentPackage())
        ;Debug.TraceUser("MC", testActor.GetDisplayName() + "(T2) rank is " + testActor.GetFactionRank(MantellaFunctionSourceFaction))
        ; Wait for actors to reach destination
        WaitForMovement(targetActor, numSources)
        
        CleanupMoveTo()
    endIf
endFunction


Function NpcMoveTo(Actor source, Actor target, int aliasIndex)
    if (source && target)
        Debug.Notification(source.GetDisplayName() + " moves to " + target.GetDisplayName() + ".")
        Debug.TraceUser("MC", "Initiating MoveTo for " + source.GetDisplayName() + " to " + target.GetDisplayName())
        ; Store wait state to restore it after movement
        bool wasWaiting = false
        if source.IsPlayerTeammate()
            wasWaiting = (source.GetValue(WaitingForPlayer) == 1)
            if wasWaiting
                ; Temporarily clear wait so the NPC can move
                source.SetValue(WaitingForPlayer, 0)
            endif
        endif
        ; Store wait state for restoration after movement completes
        _wasWaitingBeforeMove[aliasIndex] = wasWaiting
       
        ;Debug.TraceUser("MC", source.GetDisplayName() + "(1) package: " + source.GetCurrentPackage())
        ; Add to MoveTo faction
        ; Faction rank == 1 enables the MoveToPackage
        ;Debug.TraceUser("MC", source.GetDisplayName() + "(1) rank is " + source.GetFactionRank(MantellaFunctionSourceFaction))
        
        ; Assign to specific alias which has the MoveTo package
        MoveToSourceAliases.AddRef(source)
        ;Debug.TraceUser("MC", "Quest is running(2): " + self.IsRunning())
        ; Track moving actors and their wait states
        ;source.AddToFaction(MantellaFunctionSourceFaction)
        ;source.SetFactionRank(MantellaFunctionSourceFaction, 12)
        ;Debug.TraceUser("MC", source.GetDisplayName() + "(2) rank is " + source.GetFactionRank(MantellaFunctionSourceFaction))
        ;Debug.TraceUser("MC", source.GetDisplayName() + "(2) package: " + source.GetCurrentPackage())
        ;source.EvaluatePackage()
        ;Debug.TraceUser("MC", source.GetDisplayName() + "(3) package: " + source.GetCurrentPackage())
        
        _usedAliasCount += 1
    endif
EndFunction


Function WaitForMovement(Actor target, int numActors)
    float elapsedTime = 0.0
    float maxWaitTime = 30.0
    float checkInterval = 5.0
    
    Debug.TraceUser("MC", "Waiting for " + numActors + " NPC(s) to move to " + target.GetDisplayName())
    While elapsedTime < maxWaitTime
        bool allNearTarget = true
        int i = 0
        
        ; Check if all actors are near the target
        While i < numActors
            if _movingActors[i]
                float distance = _movingActors[i].GetDistance(target)
                if distance > 256.0  ; Within default follow distance
                    allNearTarget = false
                endif
            endif
            i += 1
        EndWhile
        
        if allNearTarget
            Debug.TraceUser("MC", "All NPC(s) have reached the target after " + elapsedTime + " seconds.")
            return
        endif
        
        Utility.Wait(checkInterval)
        elapsedTime += checkInterval
    EndWhile
    Debug.TraceUser("MC", "Waited " + maxWaitTime + " seconds. Ending wait for movement.")
EndFunction


Function CleanupMoveTo()
    int i = 0
    While i < _usedAliasCount
        Actor a = MoveToSourceAliases.GetAt(i) as Actor
        if a
            ; Remove from MoveTo faction
            
            ; Restore wait state if actor was waiting before movement
            if _wasWaitingBeforeMove[i] && a.IsPlayerTeammate()
                a.SetValue(WaitingForPlayer, 1)
             endif
            
        endif
        i += 1
    EndWhile

    MoveToSourceAliases.RemoveAll()
    MoveToTargetAlias.Clear()
    _usedAliasCount = 0
    _wasWaitingBeforeMove = None
EndFunction


