Scriptname MantellaConversation extends Quest

Import F4SE
Import Utility

Topic property MantellaDialogueLine1 auto
Topic property MantellaDialogueLine2 auto
MantellaRepository property repository auto
MantellaConstants property mConsts auto
Spell property MantellaSpell auto
bool property conversationIsEnding auto
Faction Property MantellaConversationParticipantsFaction Auto
Faction Property MantellaFunctionTargetFaction Auto
Faction Property MantellaFunctionSourceFaction Auto
Faction Property MantellaFunctionModeFaction Auto
Faction Property MantellaFunctionWhoIsSourceTargeting Auto
FormList Property Participants auto
Quest Property MantellaConversationParticipantsQuest auto
SPELL Property MantellaIsTalkingSpell Auto
;MantellaEquipmentDescriber Property EquipmentDescriber auto

Spell Property MantellaIsUsingItem auto ;Used to track if a NPC is using attempting to use spell that is used a signal to signal that the NPC is using an item
;bool Property UseSimpleTextField = true auto
Potion Property StimpackItem auto
Potion Property RadawayItem auto
Quest Property MantellaNPCCollectionQuest Auto 
RefCollectionAlias Property MantellaNPCCollection  Auto
ReferenceAlias Property Narrator Auto
MantellaInterface property EventInterface Auto
;GlobalVariable Property GameDaysPassed Auto
MantellaListenerScript Property Listener Auto
bool property playerIsTalking Auto



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;           Globals           ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

String[] _ingameEvents
String[] _extraRequestActions
int[] _actorHandles = None
int _contextHandle = 0
;bool isVR = false

bool _does_accept_player_input = false
bool _hasBeenStopped
bool _allowTopicSwitching = true
int _PlayerTextInputTimer = 11 const
int _repeatingMessageTimer = 1412 const


string _PlayerTextInput
bool _useNarrator = True
Faction CompanionFaction
Faction SettlerFaction
Faction PlayerFaction
;actor[] CurrentFunctionTargetArray
;;=int CurrentFunctionTargetPointer
bool microphoneEnabledLastKnownStatus = false


VoiceType MantellaVoice
;Actor lastSpokenTo = none
Actor _lastNpcToSpeak = none
Actor property playerRef auto

;Actor CurrentFunctionTargetNPC ;should be remove since actions can have multiple sources with multiple targets now.
bool _isTalking = false
;bool player_speaking = false
;float wavtime = 0.0
bool _shouldRespond = true
int _lastTopicInfo = 0
string lineToSpeakError = "Error: No line transmitted for actor to speak" const
Actor[] _cachedNearbyActors = None
bool _waitingForActionResponse = true
int _actionResponseTimeout = 0
;bool _actorsUpdated = false
string _lastSpeakerName = ""
string _repeatingMessage = ""
string _location = ""
int _initialTime = 0
string property approachAutoResponse auto  ; used for approach conversations, it's the player initial response when player talks first is set.
bool property approachNPChasSpoken auto

bool SettingsSaved = false
bool SettingsApplied = false

Function RegisterForConversationEvents()
    RegisterForExternalEvent("HttpReplyReceived", "OnHttpReplyReceived")
    RegisterForExternalEvent("HttpErrorReceived", "OnHttpErrorReceived")
    RegisterForExternalEvent(EventInterface.EVENT_ACTIONS_PREFIX + mConsts.ACTION_RELOADCONVERSATION,"OnReloadConversationActionReceived")
    RegisterForExternalEvent(EventInterface.EVENT_ACTIONS_PREFIX + mConsts.ACTION_ENDCONVERSATION,"OnEndConversationActionReceived")
    RegisterForExternalEvent(EventInterface.EVENT_ACTIONS_PREFIX + mConsts.ACTION_REMOVECHARACTER,"OnRemoveCharacterActionReceived")
    RegisterForExternalEvent(EventInterface.EVENT_ADD_EVENT,"OnAddEventReceived")
    RegisterForExternalEvent(EventInterface.EVENT_ACTION_RESPONSE_COMPLETED,"OnActionResponseCompleted")
EndFunction

function SetGameRefs()
    playerRef = game.getplayer()
    CompanionFaction = Game.GetForm(0x000023C01) as Faction
    SettlerFaction = Game.GetForm(0x000337F3) as Faction
    PlayerFaction = Game.GetForm(0x0001C21C) as Faction
    MantellaVoice = Game.GetFormFromFile(0x2F7A0, "mantella.esp") as VoiceType
endfunction

event OnInit()
    _ingameEvents = new String[0]
    _extraRequestActions = new String[0]
    Debug.OpenUserLog("MC")
    Debug.TraceUser("MC", "OnInit Conversation" )
    
    SetGameRefs()
    SaveSettings()
    if !UI.isMenuRegistered(SimpleTextField.GetMenuName())
        SimpleTextField:Program.GetProgram().OnQuestInit()              ; Make sure SimpleTextField is initialized
    Endif

    RegisterForConversationEvents()
    ;Debug.TraceUser("MC", "OnInit finished" )
    ;repository.microphoneEnabled = repository.isFO4VR
endEvent

;Get some important variables set before anything else starts
Function OnLoadGame()
    Debug.OpenUserLog("MC")
    Debug.TraceUser("MC", "OnLoadGame" )
    ;isVR = repository.isFO4VR
    repository.hasActivatePerk = Game.GetPlayer().HasPerk(repository.ActivatePerk)

    RegisterForConversationEvents()
    ;Debug.TraceUser("MC", "OnLoadGame finished" )
EndFunction

Function TestFunction()
    Debug.TraceUser("MC", "Test!")
EndFunction


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;    Start new conversation   ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

function StartConversation(Actor[] actorsToStartConversationWith)
    If(actorsToStartConversationWith.Length < 2)
        Debug.Notification("Not enough characters to start a conversation")
        return
    endIf

    if repository.isFirstConvo
        Debug.MessageBox("Mantella conversation started! NPC will speak first.")
        EndIf
    Debug.OpenUserLog("MC")
    ;Reset for new convo
    ; approachAutoResponse = ""
    approachNPChasSpoken = false

    int handle = MantellaPlugin.createDictionary()
    MantellaPlugin.setString(handle, mConsts.KEY_REQUESTTYPE, mConsts.KEY_REQUESTTYPE_INIT)
    ; send request to initialize Mantella settings (set LLM connection, start up TTS service, load character_df etc) 
    ; while waiting for actor info and context to be prepared below
    sendHTTPRequest(handle, mConsts.HTTP_ROUTE_MAIN, mConsts.KEY_REQUESTTYPE_INIT)

    AddActors(actorsToStartConversationWith)

    MantellaPlugin.setString(handle, mConsts.KEY_REQUESTTYPE, mConsts.KEY_REQUESTTYPE_STARTCONVERSATION)
    MantellaPlugin.setString(handle, mConsts.KEY_STARTCONVERSATION_WORLDID, PlayerRef.GetDisplayName() + repository.worldID)
    Debug.TraceUser("MC", "Start conversation build context")
    BuildContext(true)
    AddCurrentActorsAndContext(handle)

    if repository.microphoneEnabled
        if repository.useHotkeyToStartMic
            MantellaPlugin.setString(handle, mConsts.KEY_INPUTTYPE, mConsts.KEY_INPUTTYPE_PTT)
        else
            MantellaPlugin.setString(handle, mConsts.KEY_INPUTTYPE, mConsts.KEY_INPUTTYPE_MIC)
        EndIf
    Else
        MantellaPlugin.setString(handle, mConsts.KEY_INPUTTYPE, mConsts.KEY_INPUTTYPE_TEXT)
    endIf
    microphoneEnabledLastKnownStatus = repository.microphoneEnabled

    sendHTTPRequest(handle,mConsts.HTTP_ROUTE_MAIN, mConsts.KEY_REQUESTTYPE_STARTCONVERSATION)
    MantellaPlugin.SendMantellaEvent(EventInterface.EVENT_CONVERSATION_STARTED, playerRef, "Start conversation", 101)

    ApplySettings()
endFunction

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;    Continue conversation    ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

Function AddActorsToConversation(Actor[] actorsToAdd)
    AddActors(actorsToAdd)    
EndFunction

Function RemoveActorsFromConversation(Actor[] actorsToRemove)
    RemoveActors(actorsToRemove)  
EndFunction

int Function GetNextTopicID()
    If (_lastTopicInfo == 0 || _lastTopicInfo == 2)
        return 1
    Else
        return 2
    EndIf
EndFunction

Topic Function GetTopicToUse(int transmittedID)
    If (transmittedID == 2 && _allowTopicSwitching)
        return MantellaDialogueLine2
    Else
        return MantellaDialogueLine1
    EndIf
EndFunction


;This is the main function that processes the LLM response and decides what to do next based on the 'next action' keyword transmitted by Mantella. 
;It will also extract the relevant information from the transmitted dictionary to perform the required action (e.g. make an NPC speak, raise an event etc)
function ContinueConversation(string nextAction, int handle)
    ;Debug.TraceUser("MC", "ContinueConversation called with nextAction: " + nextAction)
    if(nextAction == mConsts.KEY_REPLYTYPE_STARTCONVERSATIONCOMPLETED) 
        ;Mantella has finished initializing and is ready to start the conversation, 
        ;so we can reset the _hasBeenStopped variable that is used to prevent multiple responses from Mantella when the conversation has ended, 
        ;and request to continue the conversation so that Mantella can send the first line and actions
        _hasBeenStopped = false
        if (MantellaPlugin.hasKey(handle,mConsts.KEY_STARTCONVERSATION_USENARRATOR))
            _useNarrator = MantellaPlugin.getBool(handle, mConsts.KEY_STARTCONVERSATION_USENARRATOR, false) as bool
        endif
        RequestContinueConversation(approachAutoResponse != "")
    elseIf (nextAction == mConsts.KEY_REPLYTYPE_NPCTALK)
        ;A line of dialogue has been generated, make the relevant NPC speak it and perform the relevant actions
        int npcTalkHandle = MantellaPlugin.getNestedDictionary(handle, mConsts.KEY_REPLYTYPE_NPCTALK)
        int eventCount = _ingameEvents.Length

        ;Debug.TraceUser("MC", "NPCTALK Checkingameevents")
        CheckInGameEvents()                
        ProcessNpcSpeak(npcTalkHandle)
        approachNPChasSpoken = true
        RequestContinueConversation(eventCount != 0)
    elseIf (nextAction == mConsts.KEY_REPLYTYPE_PLAYERTALK)
        ;The player needs to respond, either through text input or voice input depending on the player's settings
        WaitForSpecificNpcToFinishSpeaking(_lastNpcToSpeak)

        ;Something in approachAutoResponse means we have an NPC approaching the player
        ;If player is expected to talk first (no autogreeting), and no NPC has spoken yet,
        ;we feed the auto response to Mantella instead of asking for input.
        Debug.TraceUser("MC", "autoResponse: "+ approachAutoResponse + " NPChasSpoken: " + approachNPChasSpoken)
        if approachAutoResponse != "" && !approachNPChasSpoken
            ;Debug.TraceUser("MC", "Auto response")
            sendRequestForPlayerInput(approachAutoResponse, true)
            approachAutoResponse = ""
        else
            If (repository.microphoneEnabled && !repository.useHotkeyToStartMic)
                If repository.isFirstConvo
                    Debug.MessageBox("Speak slowly and clearly into your microphone when you see the 'Listening...' prompt")
                    Debug.MessageBox("Say 'goodbye' as a response to end the conversation")
                    repository.isFirstConvo = false
                EndIf
                Debug.Notification("Listening...")      
                if repository.allowVision
                    repository.GenerateMantellaVision()
                endif
                _does_accept_player_input = True
                sendRequestForVoiceTranscribe()
                repository.ResetEventSpamBlockers()  ;reset spam blockers to allow the Listener Script to pick up on those again
            Else    
                ;Text input, wait for the player to press the 'H' key to open the text input menu and send the input to Mantella
                If repository.isFirstConvo
                    Debug.MessageBox("Use the 'H' key to enter your response")
                    Debug.MessageBox("You can also use the 'Y' key to send events to the LLM")
                    Debug.MessageBox("Type 'goodbye' as a response to end the conversation")
                    repository.isFirstConvo = false
                Endif
                Debug.Notification("Awaiting player text input...")
                _does_accept_player_input = True
            Endif
            ;Execution will continue with 'GetPlayerTextInput' once player has entered their input and submitted it.
        EndIf
    elseIf (nextAction == mConsts.KEY_REQUESTTYPE_TTS) 
        ;Mantella returns the text that was transcribed from the player's voice input
        ClearRepeatingMessage()
        string transcribe = MantellaPlugin.getString(handle, mConsts.KEY_TRANSCRIBE, "*Complete gibberish*")
        if repository.allowVision
            repository.GenerateMantellaVision()
        endif
        sendRequestForPlayerInput(transcribe, updateContext=True) ;Sends the player's transcribed input to Mantella to be fed to the LLM 
        Debug.Notification("Thinking...")
        repository.ResetEventSpamBlockers()  ;reset spam blockers to allow the Listener Script to pick up on those again
    elseIf (nextAction == mConsts.KEY_REPLYTYPE_NPCACTION)
        ; Mantella has detected an action that an NPC needs to perform (e.g. use an item, equip a piece of clothing etc) and 
        ; has transmitted the relevant information for that action in the dictionary, 
        ; so we need to extract that information and make the NPC perform the action
        Debug.TraceUser("MC", "Processing NPC action...")
        int npcActionHandle = MantellaPlugin.getNestedDictionary(handle, mConsts.KEY_REPLYTYPE_NPCACTION)
        ProcessNpcAction(npcActionHandle)
        bool updateInGameEvents = MantellaPlugin.getBool(npcActionHandle, mConsts.ACTION_REQUIRES_RESPONSE, false)
        RequestContinueConversation(updateInGameEvents)
    elseIf (nextAction == mConsts.KEY_REPLYTYPE_ENDCONVERSATION)
        CleanupConversation()
    endIf
endFunction

function RequestContinueConversation(bool updateInGameEvents = false)
    ;Debug.TraceUser("MC", "Requesting continue conversation, updateInGameEvents: " + updateInGameEvents)
    if _hasBeenStopped == false
        int handle = MantellaPlugin.createDictionary()
        MantellaPlugin.setString(handle, mConsts.KEY_REQUESTTYPE, mConsts.KEY_REQUESTTYPE_CONTINUECONVERSATION)
        AddCurrentActorsAndContext(handle)

        int nextTopicInfo = GetNextTopicID()
        MantellaPlugin.setInt(handle, mConsts.KEY_CONTINUECONVERSATION_TOPICINFOFILE, nextTopicInfo)
        _lastTopicInfo = nextTopicInfo

        if(_extraRequestActions && _extraRequestActions.Length > 0)
            ;Debug.Trace("_extraRequestActions contains items. Sending them along with continue!")
            MantellaPlugin.setStringArray(handle, mConsts.KEY_REQUEST_EXTRA_ACTIONS, _extraRequestActions)
            ClearExtraRequestAction()
            ;Debug.Trace("_extraRequestActions got cleared. Remaining items: " + _extraRequestActions.Length)
        endif

        if updateInGameEvents
            _contextHandle = MantellaPlugin.createDictionary()
            
            ; Wait for action to complete with timeout
            _actionResponseTimeout = 0
            
            if _waitingForActionResponse
                Debug.TraceUser("MC", "Waiting for action response before continuing conversation...")
            EndIf

            while _waitingForActionResponse && _actionResponseTimeout < 50
                Utility.Wait(0.1)
                _actionResponseTimeout += 1
            endWhile

            _waitingForActionResponse = true ; Reset for next action
            ;Debug.TraceUser("MC", "Updating in-game events for continue conversation. Current events: " + _ingameEvents.Length)
            Debug.TraceUser("MC", "RequestContinue _ingameEvents: " + _ingameEvents.Length)
            MantellaPlugin.setStringArray(_contextHandle, mConsts.KEY_CONTEXT_INGAMEEVENTS, _ingameEvents)
            MantellaPlugin.setNestedDictionary(handle, mConsts.KEY_CONTEXT, _contextHandle)
            ClearIngameEvent()
        else
            ;Debug.TraceUser("MC", "Not updating ingame events = " + _ingameEvents)
            int Stored_context = MantellaPlugin.getNestedDictionary(handle, mConsts.KEY_CONTEXT)
            if Stored_context  == 0
                ;Debug.TraceUser("MC", "Context is 0")
            Else
                string [] ContextEventsStr = MantellaPlugin.getStringArray(Stored_context,mConsts.KEY_CONTEXT_INGAMEEVENTS)
                ;Debug.TraceUser("MC", "ContextEvent count = " + ContextEventsStr.Length)
            Endif
        endIf

        ; if _actorsUpdated
        ;     MantellaPlugin.setNestedDictionariesArray(handle, mConsts.KEY_ACTORS, _actorHandles)
        ;     _actorsUpdated = false
        ; endIf

        if repository.microphoneEnabled != microphoneEnabledLastKnownStatus
            if repository.microphoneEnabled
                if repository.useHotkeyToStartMic
                    MantellaPlugin.setString(handle, mConsts.KEY_INPUTTYPE, mConsts.KEY_INPUTTYPE_PTT)
                else
                    MantellaPlugin.setString(handle, mConsts.KEY_INPUTTYPE, mConsts.KEY_INPUTTYPE_MIC)
                endIf
            Else
                MantellaPlugin.setString(handle, mConsts.KEY_INPUTTYPE, mConsts.KEY_INPUTTYPE_TEXT)
            endIf
            microphoneEnabledLastKnownStatus = repository.microphoneEnabled
        EndIf
        sendHTTPRequest(handle,mConsts.HTTP_ROUTE_MAIN, mConsts.KEY_REQUESTTYPE_CONTINUECONVERSATION)
    EndIf
endFunction

function ProcessNpcSpeak(int handle)
    string speakerName = MantellaPlugin.getString(handle, mConsts.KEY_ACTOR_SPEAKER, "Error: No speaker transmitted for action 'NPC talk'")
    Actor speaker = none
    bool isNarration = False
    float lineDuration = MantellaPlugin.getFloat(handle, mConsts.KEY_ACTOR_DURATION, 0)
    if _useNarrator
        isNarration = MantellaPlugin.getBool(handle, mConsts.KEY_ACTOR_ISNARRATION, false) as bool
    endIf
    if isNarration
        ;?
        ;speaker = Narrator.GetReference() as Actor
        speaker = playerRef ;Using player ref due to issues with narrator
        speakerName = "MantellaNarrator"

        ;Debug.Notification("Using Narrator.")
    ; If actor is already loaded, do not load again from actors list
    elseif speakerName == _lastSpeakerName
        speaker = _lastNpcToSpeak
    else
        speaker = GetActorInConversation(speakerName)
    endIf

    if speaker != none
        WaitForNpcToFinishSpeaking(speaker, _lastNpcToSpeak)
        string lineToSpeak = MantellaPlugin.getString(handle, mConsts.KEY_ACTOR_LINETOSPEAK, lineToSpeakError)
        if lineToSpeak == "*" || lineToSpeak == "\"" || linetoSpeak == "'"
            return
        EndIf
        Debug.TraceUser("MC", ">>" + lineToSpeak)
        ;string[] actions = MantellaPlugin.getStringArray(handle, mConsts.KEY_ACTOR_ACTIONS)
        int topidID = MantellaPlugin.getInt(handle, mConsts.KEY_CONTINUECONVERSATION_TOPICINFOFILE,1)

        ;RaiseActionEvent(speaker, lineToSpeak, actions)
        if lineToSpeak != lineToSpeakError
            Topic topicToUse = GetTopicToUse(topidID)
            NpcSpeak(speaker, lineToSpeak, topicToUse, isNarration, lineDuration)
        endif

        _lastNpcToSpeak = speaker           ; Save for next time
        _lastSpeakerName = speakerName
        ; if speaker != playerRef
        ;     _lastNpcToSpeak = speaker
        ; EndIf

        ; Get actions only after the NPC starts speaking to improve response times
        int[] actionsHandles = MantellaPlugin.getNestedDictionariesArray(handle, mConsts.KEY_ACTOR_ACTIONS)
        if actionsHandles && actionsHandles.Length > 0
            RaiseActionEvent(speaker, actionsHandles)
        endIf
    endIf
endFunction


function NpcSpeak(Actor actorSpeaking, string lineToSay, Topic topicToUse, bool isSpokenByNarrator, float duration)
    Actor actorToSpeakTo = GetActorSpokenTo(actorSpeaking)
    actorSpeaking.SetOverrideVoiceType(MantellaVoice)                       ;Force every line to 'MantellaVoice00'   
 
    ;Debug.TraceUser("MC", "NPC " + topicToUse + " : " + lineToSay)
    int ret = MantellaPlugin.PatchTopicInfo(topicToUse, lineToSay)          ;Patch the in-memory text to the new value
    if ret != 0
        Debug.TraceUser("MC", "Failed to patch topic info: " + ret)
    Endif
    if !isSpokenByNarrator
        if actorToSpeakTo != none
            actorSpeaking.SetLookAt(actorToSpeakTo)
        EndIf
        AllSetLookAt(actorSpeaking)
    endif
    
    ;;PB test code
    PB_speak PBQuest = Game.GetFormFromFile(0x000823, "PB.esp") as PB_speak
    if PBQuest != none
        ;Debug.TraceUser("MC", "PBQuest  " + PBQuest + " " +actorSpeaking + " speak line: " + lineToSay + " with topic: " + topicToUse)
        float wt = PBQuest.speak(lineToSay, actorSpeaking, topicToUse)
        ;Debug.TraceUser("MC", actorSpeaking.GetDisplayName() + " (" + wt + ") speak: " + lineToSay)
    Else
        actorSpeaking.Say(topicToUse, abSpeakInPlayersHead=isSpokenByNarrator)
    Endif
    actorSpeaking.SetOverrideVoiceType(none)
    
    ;actorSpeaking.AddSpell(MantellaIsTalkingSpell, False)
    ;Debug.TraceUser("MC", actorSpeaking.GetDisplayName() + " : " + hasSpell + " : " + lineToSay)
endfunction


string function GetActorName(actor actorToGetName)
    string actorName = actorToGetName.GetDisplayName()
    int actorID = actorToGetName.GetFactionRank(MantellaConversationParticipantsFaction)
    if actorID > 0
        actorName = actorName + " " + actorID
    endIf
    return actorName
endFunction


Actor function GetActorInConversation(string actorName)
    int i = 0
    While i < Participants.GetSize()
        Actor currentActor = Participants.GetAt(i) as Actor
        if GetActorName(currentActor) == actorName
            return currentActor
        endIf
        i += 1
    EndWhile
    return none
endFunction

; Any vanilla dialogue accumulated during a Mantella conversation gets accumulated by the plugin.
; It gets fetched here and added to the ingame events, just prior to sending player input to Mantella
bool Function AddVanillaDialogue()
    string vanillaDialogue = MantellaPlugin.GetVanillaDialogue()

    if vanillaDialogue != ""
        AddIngameEvent(vanillaDialogue)
        int evcount =_ingameEvents.Length
        int i = 0
        While i < evcount
            Debug.TraceUser("MC", "Event[" + i + "]: " + _ingameEvents[i])
            i += 1
        EndWhile
        return true
    EndIf
    return false
EndFunction

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;       End conversation      ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


Function OnEndConversationActionReceived(int speakerID, string unused, int handle)
    EndConversation()
endFunction


Function EndConversation()
    _hasBeenStopped=true
    int handle = MantellaPlugin.createDictionary()

    AddVanillaDialogue()

    if _ingameEvents && _ingameEvents.Length > 0
        ;Debug.TraceUser("MC", "Building End context with events: " + _ingameEvents.Length)
        MantellaPlugin.setStringArray(handle, mConsts.KEY_CONTEXT_INGAMEEVENTS, _ingameEvents)
        ClearIngameEvent() 
   Endif
    MantellaPlugin.setString(handle, mConsts.KEY_REQUESTTYPE,mConsts.KEY_REQUESTTYPE_ENDCONVERSATION)
    MantellaPlugin.setFloat(handle, mConsts.KEY_ENDCONVERSATION_TIMESTAMP, Utility.GetCurrentGameTime()) 
    sendHTTPRequest(handle,mConsts.HTTP_ROUTE_MAIN,mConsts.KEY_REQUESTTYPE_ENDCONVERSATION)
EndFunction

Function CleanupConversation()
    ;repository.NPCAIPackageSelector=-1
    repository.hasPendingVisionCheck=false
    conversationIsEnding = true
    ClearParticipants()
    ClearIngameEvent() 
    ClearRepeatingMessage()
    _does_accept_player_input = false
    _isTalking = false
    _lastNpcToSpeak = none
    _lastTopicInfo = 0
    _cachedNearbyActors = None

    ;?
    DispelSpellFromActorsInConversation(MantellaSpell)
    ;DispelSpellFromActorsInConversation(MantellaIsTalkingSpell)
    RemoveAllParticipantsFromFaction(MantellaFunctionTargetFaction)
    RemoveAllParticipantsFromFaction(MantellaFunctionSourceFaction)
    RemoveAllParticipantsFromFaction(MantellaFunctionModeFaction)
    RemoveAllParticipantsFromFaction(MantellaFunctionWhoIsSourceTargeting)
    Actor[] ActorsInCell = repository.ScanAndReturnNearbyActors(MantellaNPCCollectionQuest, MantellaNPCCollection, false)
    repository.RemoveFactionFromActors(ActorsInCell,MantellaFunctionTargetFaction)
    repository.RemoveFactionFromActors(ActorsInCell,MantellaFunctionSourceFaction)
    repository.RemoveFactionFromActors(ActorsInCell,MantellaFunctionModeFaction)
    repository.RemoveFactionFromActors(ActorsInCell,MantellaFunctionWhoIsSourceTargeting)

    If (MantellaConversationParticipantsQuest.IsRunning())
        MantellaConversationParticipantsQuest.Stop()
    EndIf  
    
    ;This is commented out because it randomly leads to issue if a Mantella conversation is prematurely ended (infamous Error : Cannot retrieve Error bug)
    ;MantellaPlugin.clearAllDictionaries() 

    MantellaPlugin.SendMantellaEvent(EventInterface.EVENT_CONVERSATION_ENDED, playerRef, "Conversation ended", 102)

    ;;PB
    PB_speak PBQuest = Game.GetFormFromFile(0x000823, "PB.esp") as PB_speak
    if PBQuest != none
        PBQuest.ClearText(0.0)
    Endif

    RestoreSettings()
    if repository.isFirstConvo
        Debug.messagebox("The conversation started but something went wrong. Make sure that Mantella.exe is running and that your filepaths are correctly set.")
        Debug.messagebox("If the problem persists, come to the discord channel and ask for help in the #issues channel (link to the discord on the Mantella Nexus page)")
    Else
        debug.notification("Conversation has ended")
    endif
    Stop()
EndFunction


Function OnRemoveCharacterActionReceived(int speakerID, string unused, int handle)
    Actor speaker = none
    If speakerID != 0
        speaker = Game.GetForm(speakerID) as Actor
    Endif
    
    Actor[] actors = new Actor[1]
    actors[0] = speaker as Actor
    RemoveActors(actors)
EndFunction


Function DispelSpellFromActorsInConversation(Spell SpellToDispel)
    int i=0
    
    While i < Participants.GetSize()
        Actor actorToDispel = Participants.GetAt(i) as actor
        actorToDispel.DispelSpell(SpellToDispel)
        i += 1
    EndWhile
Endfunction

Function RemoveAllParticipantsFromFaction(faction factionToRemove)
    int i=0
    
    While i < Participants.GetSize()
        Actor actorToRemove = Participants.GetAt(i) as actor
        actorToRemove.SetFactionRank(factionToRemove,0)
        actorToRemove.RemoveFromFaction(factionToRemove)
        i += 1
    EndWhile
Endfunction

;HTTP reply received from Mantella
function OnHttpReplyReceived(int typedDictionaryHandle)
    string replyType = MantellaPlugin.getString(typedDictionaryHandle, mConsts.KEY_REPLYTYPE ,"error")
    IF replyType == mConsts.KEY_REPLYTYPE_INITCOMPLETED
        ;_shouldRespond = false
    ElseIf (replyType != "error")
        _shouldRespond = true
        ContinueConversation(replyType, typedDictionaryHandle)        
    Else
        string errorMessage = MantellaPlugin.getString(typedDictionaryHandle, "mantella_message","Error: Could not retrieve error message")
        Debug.Notification(errorMessage)
        CleanupConversation()
    EndIf
endFunction

; Send a request to Mantella app
Function sendHTTPRequest(int handle, string route, string request)
    ;Debug.TraceUser("MC", "SendHTTPrequest: " + request)
    ;_shouldRespond = true
    if _shouldRespond
        if repository.HTTPPort == 0
            repository.HttpPort = mConsts.HTTP_PORT ; Set to default if not set yet
            Debug.TraceUser("MC", "HTTP port not set, using default: " + mConsts.HTTP_PORT)
        EndIf
        MantellaPlugin.sendLocalhostHttpRequest(handle, repository.HttpPort, route)
    else
        Debug.Notification("Not sending HTTP request because _shouldRespond is false")
        Debug.TraceUser("MC", "Discarding " + request) 
        _shouldRespond = true
    endIf
EndFunction

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;   Timer Management    ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
Event Ontimer(int TimerID)
    If TimerID==_PlayerTextInputTimer ;Spacing out the GenerateMantellaVision() to avoid taking a screenshot of the interface
        repository.GenerateMantellaVision()
        Debug.TraceUser("MC", "Player text input timer ended, sending request for player input with vision data")
        sendRequestForPlayerInput(_PlayerTextInput, false)
        _does_accept_player_input = False
        repository.ResetEventSpamBlockers() ;reset spam blockers to allow the Listener Script to pick up on those again
        Debug.Notification("Thinking...")
    ElseIf TimerID == _repeatingMessageTimer  && _repeatingMessage != ""
        Debug.Notification(_repeatingMessage)
        StartTimer(10.0, _repeatingMessageTimer) ; Restart the timer to show the message again
    EndIf
EndEvent

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;   Handle player speaking    ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Send the player's text input to Mantella, along with the current context and actors in the conversation if needed. 
;If updateContext is false, it will skip rebuilding the context and just send the previous context again,
;which can be used to save time if the context was recently updated and is unlikely to have changed much since then. 
;if playerInput is empty, Mantella will capture the player's voice input, transcribe it, and return it to be spoken by the player in-game.
function sendRequestForPlayerInput(string playerInput, bool updateContext)
    ;Debug.TraceUser("MC", "sendRequestForPlayerInput called with input: " + playerInput + " and updateContext: " + updateContext)
    if _hasBeenStopped==false
        ;?
        if repository.allowTrackPlayerState
            AddIngameEvent(repository.constructPlayerState())
        endif

        if AddVanillaDialogue()
            updateContext = true
        EndIf
        
        int handle = MantellaPlugin.createDictionary()
        MantellaPlugin.setString(handle, mConsts.KEY_REQUESTTYPE, mConsts.KEY_REQUESTTYPE_PLAYERINPUT)
        MantellaPlugin.setString(handle, mConsts.KEY_REQUESTTYPE_PLAYERINPUT, playerinput)

        int[] handlesNpcs = BuildNpcsInConversationArray()
        MantellaPlugin.setNestedDictionariesArray(handle, mConsts.KEY_ACTORS, handlesNpcs)

        if updateContext ; if context has not been refreshed recently
            Debug.TraceUser("MC", "sendRequestForPlayerInput BuildContext")
            ;BuildContext()
        endIf
        MantellaPlugin.setNestedDictionary(handle, mConsts.KEY_CONTEXT, _contextHandle)
        sendHTTPRequest(handle,mConsts.HTTP_ROUTE_MAIN, mConsts.KEY_REQUESTTYPE_PLAYERINPUT)
        ClearIngameEvent()
        endif
endFunction


function sendRequestForVoiceTranscribe()
    if(!_does_accept_player_input)
        ;Debug.TraceUser("MC", "Not sending request for voice transcribe because _does_accept_player_input is false")
        return
    Else
        _does_accept_player_input = False
    endif

    ;Debug.TraceUser("MC", "sendRequestForVoiceTranscribe called, sending request for player input with voice transcribe")
    sendRequestForPlayerInput("", updateContext=True)
    ShowRepeatingMessage("Listening...")
endFunction

; Callback function for when player text input is received for dialogue
Function SetPlayerResponseTextInput(string text)
    ;disable for VR
    Debug.TraceUser("MC", "SetPlayerResponseTextInput")
    if !repository.isFO4VR
        text = MantellaPlugin.StringRemoveWhiteSpace(text)
        if text == ""
            return
        Endif

        Debug.TraceUser("MC", "SetPlayerTextResponse Checkingameevents")
        CheckInGameEvents()
        ;BuildContext() ;rebuild context to make sure it's as up to date as possible before sending player input, since text input can sometimes be slow and the context may have changed since the player was prompted for input
        _PlayerTextInput=text
        if repository.allowVision
            StartTimer(0.3,_PlayerTextInputTimer) ;Spacing out the GenerateMantellaVision() to avoid taking a screenshot of the interface
        else
            sendRequestForPlayerInput(_PlayerTextInput, true)
            _does_accept_player_input = False
            repository.ResetEventSpamBlockers() ;reset spam blockers to allow the ListenerScript to pick up on those again
            Debug.notification("Thinking...")
        Endif
    endif
EndFunction

; Callback function for when player text input is received for dialogue with vision input
Function SetPlayerResponseTextAndVisionInput(string text)
    if !repository.isFO4VR
        text = MantellaPlugin.StringRemoveWhiteSpace(text)
        if text == ""
            return
        Endif

        _PlayerTextInput = text
        repository.hasPendingVisionCheck=true
        StartTimer(0.3,_PlayerTextInputTimer)
    endif
EndFunction

; Callback function for when player text input is received for adding a game event
Function SetGameEventTextInput(string text)
    ;disable for VR
    if !repository.isFO4VR
        text = MantellaPlugin.StringRemoveWhiteSpace(text)
        if text == ""
            return
        Endif
        AddIngameEvent(text)
    endif
EndFunction

;OK
function WaitForNpcToFinishSpeaking(Actor speaker, Actor lastNpcToSpeak)
    ; if this is the start of the conversation there is no need to wait, so skip this function entirely
    if lastNpcToSpeak != None
        ; if the current NPC did not speak last in a multi-NPC conversation, 
        ; wait for the last NPC to finish speaking to avoid interrupting
        if speaker != lastNpcToSpeak 
            WaitForSpecificNpcToFinishSpeaking(lastNpcToSpeak)
        endIf
        ; wait for the current NPC to finish speaking before starting the next voiceline
        if speaker != None
            WaitForSpecificNpcToFinishSpeaking(speaker)
        endIf
    endIf
endFunction

;OK
function WaitForSpecificNpcToFinishSpeaking(Actor selectedNpc)
    if selectedNpc == none
        Debug.TraceUser("MC", "WaitforSpecificNPC is none")
        return
    Endif

    ;selectedNpc.AddSpell(MantellaIsTalkingSpell, False)
    _isTalking = true
    float maxwait = 15.0
    float waitTime = 0.1
    float totalWaitTime = 0.0


    if selectedNpc == playerRef && Game.GetCameraState() == 3
        while playerIsTalking && totalWaitTime <= maxwait  ; wait until the NPC has finished speaking
            Utility.Wait(waitTime)
            totalWaitTime += waitTime
        endWhile
        ;Debug.TraceUser("MC", "Player spoke for " + totalWaitTime + " s")
        playerIsTalking = false
    else
        ;Debug.TraceUser("MC", "Waiting for " + selectedNpc.GetDisplayName() + "To finish speaking")
        ;? Wait for _istalking to be set?
        ; MantellaIsTalkingSpell.cast(selectedNpc as ObjectReference, selectedNpc as ObjectReference)
        while selectedNpc.isTalking() && totalWaitTime <= maxwait  ; wait until the NPC has finished speaking
            Utility.Wait(waitTime)
            totalWaitTime += waitTime
        endWhile
       ; Debug.TraceUser("MC", "TotalWait " + selectedNpc.GetDisplayName() + " for " + totalWaitTime + " s")

        if totalWaitTime > maxwait ; note that this isn't really in seconds due to the overhead of the loop running
            Debug.Notification("NPC speaking too long, ending wait...")
        endIf
        ;Debug.TraceUser("MC", selectedNpc.GetDisplayName() + " finished speaking")
    Endif

    ;;PB
    PB_speak PBQuest = Game.GetFormFromFile(0x000823, "PB.esp") as PB_speak
    if PBQuest != none
        PBQuest.ClearText(totalWaitTime)
    Endif

    _isTalking = false
 endFunction

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;       Action handler        ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


function ProcessNpcAction(int handle)
    ;Get action Jsons from Mantella
    int[] actionsHandles = MantellaPlugin.getNestedDictionariesArray(handle, mConsts.KEY_ACTOR_ACTIONS)
    if actionsHandles && actionsHandles.Length > 0
        RaiseActionEvent(None, actionsHandles)
    endIf
endFunction


Function RaiseActionEvent(Actor speaker, int[] actionsHandles)
    ; Processes actions array, automatically detecting legacy vs advanced actions.
    ;
    ; Args:
    ;     speaker: The NPC who spoke (for context)
    ;     actionsHandles: Array of MantellaPlugin dictionary handles, one per action
    ;
    ; Each action handle contains:
    ;     - "identifier": Action name (e.g., "mantella_npc_follow")
    ;     - "arguments" (optional): Dictionary with parameters
    ;       - If present = advanced action 
    ;       - If absent = legacy action 
    ;
    ; Fallback Behavior:
    ;     If LLM forgets to include arguments for a built-in action, it will be routed
    ;     to the legacy handler, which will execute the action on the speaker only.
    
    Debug.TraceUser("MC", "Raising action event for " + actionsHandles.Length + " actions.")
    if !actionsHandles || actionsHandles.Length == 0
        return ; don't send out an action event if there are no actions to act upon
    endIf
    
    int i = 0
    While i < actionsHandles.Length
        int actionHandle = actionsHandles[i]
        
        ; Extract action identifier
        string actionIdentifier = MantellaPlugin.getString(actionHandle, mConsts.ACTION_IDENTIFIER, "")
        
        Debug.TraceUser("MC", "Processing action with identifier: '" + actionIdentifier + "'")
        if actionIdentifier != ""
            ; Check for special handling (eg inventory action timing)
            if (actionIdentifier == mConsts.ACTION_NPC_INVENTORY) || (actionIdentifier == mConsts.ACTION_NPC_BARTER)
                Utility.Wait(0.5)
                WaitForNpcToFinishSpeaking(speaker, _lastNpcToSpeak)
            endIf
            
            if actionIdentifier == mConsts.KEY_REQUESTTYPE_ENDCONVERSATION
                EndConversation()
            else
                int argumentsHandle = MantellaPlugin.getNestedDictionary(actionHandle, mConsts.ACTION_ARGUMENTS, 0)
                string eventName = EventInterface.EVENT_ADVANCED_ACTIONS_PREFIX + actionIdentifier

                ; Detect if this is an advanced action (has arguments) or legacy action (no arguments)
                ; Both paths now use the EVENT_ADVANCED_ACTIONS_PREFIX. argumentsHandle is used by downstream code to differenciate.
                if argumentsHandle != 0
                    Debug.TraceUser("MC", "Sending advanced action event: " + eventName + " with arguments.")
                    MantellaPlugin.SendMantellaEvent(eventName, _lastNpcToSpeak, "", argumentsHandle)
                else
                    ; LEGACY ACTION PATH
                    if !(speaker)
                        if _lastNpcToSpeak
                            speaker = _lastNpcToSpeak
                        else
                            speaker = GetActorInConversationByIndex(1)
                        endIf
                    endIf
                    ; Legacy action: no arguments, send with simple signature
                    ; This handles both:
                    ;   1. Player-created custom actions built when the old system was in place
                    ;   2. Built-in actions when LLM forgets arguments (fallback to speaker-only)
                    Debug.TraceUser("MC", "Sending legacy action event: " + eventName + " with no arguments.")
                    MantellaPlugin.SendMantellaEvent(eventName, speaker, "", -1)
                endIf
            endIf
        else
            Debug.Trace("Mantella: Warning - Action missing identifier", 1)
        endIf
        
        i += 1
    EndWhile
EndFunction



Function SendActorAddedEvents(Actor[] actorsAdded)
    int index = 0
    While (index < actorsAdded.Length)
        Actor speaker = actorsAdded[index] as Actor
        If (speaker)
			MantellaPlugin.SendMantellaEvent(EventInterface.EVENT_CONVERSATION_NPC_ADDED, speaker, "NPC added to conversation", 103)
        EndIf
        index += 1
    EndWhile
    ;MantellaVanillaDialogue.notifyNpcAdded(actorsAdded)
EndFunction

Function SendActorRemovedEvents(Actor[] actorsRemoved)
    int index = 0
    While (index < actorsRemoved.Length)
        Actor speaker = actorsRemoved[index] as Actor
        if speaker != none
    		MantellaPlugin.SendMantellaEvent(EventInterface.EVENT_CONVERSATION_NPC_REMOVED, speaker, "NPC removed from conversation", 104)
        Endif
        index += 1
    EndWhile
    ;MantellaVanillaDialogue.notifyNpcRemoved(actorsRemoved)
EndFunction

;;;;;;;;;;;;;;;;;

Function AddExtraRequestAction(string extraAction)
    if(!_extraRequestActions)
        _extraRequestActions = new string[0]
    endif
    _extraRequestActions.Add(extraAction)
EndFunction

Function ClearExtraRequestAction()
    _extraRequestActions.Clear()
EndFunction

Function OnAddEventReceived(int speakerID, string text, int handle)
    ;Debug.TraceUser("MC", "AddEvent " + text)
    AddIngameEvent(text)
    EndFunction

;Signalled by actions that require waiting for a response before continuing the conversation, such as the NPC inventory action which requires waiting for the player to finish interacting with the inventory menu. 
;This prevents the conversation from continuing and potentially sending more actions while the player is still interacting with the previous action.
Function OnActionResponseCompleted(int speakerID, string actionIdentifier, int unused)
    _waitingForActionResponse = false
EndFunction

Function OnReloadConversationActionReceived(int speakerID, string unused, int handle)
    AddExtraRequestAction(mConsts.ACTION_RELOADCONVERSATION)
endFunction


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;        Ingame events        ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

Function AddIngameEvent(string eventText)
    if(!_ingameEvents)
        _ingameEvents = new string[0]
    endif
    _ingameEvents.Add(eventText)
    ;Debug.TraceUser("MC", "Added in-game event: " + eventText + ". Current events: " + _ingameEvents.Length)
EndFunction

Function ClearIngameEvent()
    Debug.TraceUser("MC", "Clearing " + _ingameEvents.Length + " events")
    _ingameEvents.Clear()
EndFunction

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Action: Reload conversation ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

function TriggerReloadConversation()
    AddExtraRequestAction(mConsts.ACTION_RELOADCONVERSATION)
endFunction

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;       Error handling        ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

function OnHttpErrorReceived(int typedDictionaryHandle)
    string errorMessage = MantellaPlugin.getString(typedDictionaryHandle, mConsts.HTTP_ERROR ,"error")
    If (errorMessage != "error")
        Debug.Notification("Received MantellaPlugin error: " + errorMessage)        
        CleanupConversation()
    Else
        Debug.Notification("Error: Could not retrieve error")
        CleanupConversation()
    EndIf
endFunction

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;            Utils            ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

Actor function GetActorByName(string actorName)
    ; First, search conversation participants
    Actor currentActor = GetActorInConversation(actorName)
    if currentActor != None
        return currentActor
    endIf
    
    ; If not in conversation, search the most recent nearby actors cache
    if _cachedNearbyActors
        int i = 0
        While i < _cachedNearbyActors.Length
            Actor nearbyActor = _cachedNearbyActors[i]
            if nearbyActor != None
                ; Match by display name (nearby actors don't have numbered suffixes)
                if nearbyActor.GetDisplayName() == actorName
                    return nearbyActor
                endIf
            endIf
            i += 1
        EndWhile
    endIf
    
    ; Not found in conversation or nearby - return None
    return None
endFunction

bool Function IsPlayerInConversation()
    int i = 0
    While i < Participants.GetSize()
        if (Participants.GetAt(i) == playerRef)
            return true
        endif
        i += 1
    EndWhile
    return false    
EndFunction

Bool function IsActorInConversation(Actor ActorRef)      
    int i = 0
    While i < Participants.GetSize()
        Actor currentActor = Participants.GetAt(i) as Actor
        if currentActor == ActorRef
            return true
        endIf
        i += 1
    EndWhile
    return false
endFunction

Function CauseReassignmentOfParticipantAlias()
    ;Debug.TraceUser("MC", "Causing reassignment of participant aliases")
    ;This causes Mantella NPC to change AI packages so that they enter specific behavior (usually staying in place while the player talks to them) 
    If (MantellaConversationParticipantsQuest.IsRunning())
        MantellaConversationParticipantsQuest.Stop()
    EndIf
    ; if repository.allowFunctionCalling
    ;     repository.isAParticipantInteractingWithGroundItems=CheckIfAtLeastOneParticipantHasSpecificFactionRank(MantellaFunctionSourceFaction,3) ;Confirming if a participant is looting by checking rank to avoid pointless refColl checks
    ; endif
    if repository.allowNPCsStayInPlace || repository.allowFunctionCalling
        MantellaConversationParticipantsQuest.Reset()
        MantellaConversationParticipantsQuest.Start()
        ; Utility.wait(1.0)
        int i = Participants.GetSize()
        While i > 0
            i -= 1
            Actor tmpActor = Participants.GetAt(i) as Actor
            tmpActor.EvaluatePackage(true)
        EndWhile
    endif
EndFunction


Function AddActors(Actor[] actorsToAdd)
    int i = 0
    Actor[] actorsAdded = new Actor[0]
    While i < actorsToAdd.Length
        Actor possibleNewActor = actorsToAdd[i]
        int pos = Participants.Find(possibleNewActor)
        if(pos < 0)
            Participants.AddForm(possibleNewActor)
            possibleNewActor.AddToFaction(MantellaConversationParticipantsFaction)
            actorsAdded.Add(possibleNewActor)

            ; check if there are multiple actors with the same name
            int nameCount = 0
            int j = 0
            bool break = false
            if (possibleNewActor != playerRef) ; ignore the player having the same name as an actor
                While (j < Participants.GetSize()) && (break==false)
                    Actor currentActor = Participants.GetAt(j) as Actor
                    if (currentActor.GetDisplayName() == possibleNewActor.GetDisplayName())
                        nameCount += 1
                        if (currentActor == possibleNewActor) ; stop counting when the exact actor is found (not just the same name)
                            break = true
                        endIf
                    endIf
                    j += 1
                EndWhile

                if (nameCount > 1)
                    ; set an ID to this non-uniquely-named actor in the form of a faction rank
                    ; these uniquely ID'd names can be called via the GetActorName() function
                    possibleNewActor.SetFactionRank(MantellaConversationParticipantsFaction, nameCount)
                endIf
            endIf
        endIf
        i += 1
    EndWhile

    If (actorsAdded.Length > 0)
        CauseReassignmentOfParticipantAlias()
        BuildNpcsInConversationArray()
        SendActorAddedEvents(actorsAdded)
    EndIf
    
    ;PrintActorsInConversation()
EndFunction

Function StopFollowing(Actor tmpActor)
    tmpActor.RemoveFromFaction(MantellaConversationParticipantsFaction)
    if !tmpActor.IsinFaction(CompanionFaction) || tmpActor.GetFactionRank(CompanionFaction) < 0
        tmpActor.SetPlayerTeammate(false)
        ;speaker.EvaluatePackage()
    EndIf

EndFunction

Function RemoveActors(Actor[] actorsToRemove)
    Actor[] actorsRemoved =  new Actor[0]
    int i = 0
    While (i < actorsToRemove.Length)
        Actor actorInQuestion = actorsToRemove[i] as Actor
        If (Participants.HasForm(actorInQuestion))
            Participants.RemoveAddedForm(actorInQuestion)
            actorsRemoved.Add(actorInQuestion)
            StopFollowing(actorInQuestion)

            ;actorInQuestion.RemoveFromFaction(MantellaFunctionSourceFaction)
            ;actorInQuestion.RemoveFromFaction(MantellaFunctionModeFaction)
            ;actorInQuestion.RemoveFromFaction(MantellaFunctionWhoIsSourceTargeting)
        EndIf
        i += 1
    EndWhile
    if (Participants.GetSize() < 2)
        EndConversation()
    ElseIf (actorsRemoved.Length > 0)
        CauseReassignmentOfParticipantAlias()
        BuildNpcsInConversationArray()
        SendActorRemovedEvents(actorsRemoved)
    endIf
    ;PrintActorsInConversation()
EndFunction


Function ClearParticipants()
    int i = 0
    While i < Participants.GetSize()
        Actor tmpActor = Participants.GetAt(i) as Actor
        StopFollowing(tmpActor)
        i += 1
    EndWhile
    Participants.Revert()
EndFunction


bool Function ContainsActor(Actor[] arrayToCheck, Actor actorCheckFor)
    int i = 0
    While i < arrayToCheck.Length
        If (arrayToCheck[i] == actorCheckFor)
            return True
        EndIf
        i += 1
    EndWhile
    return False
EndFunction


Function PrintActorsArray(string prefix, Actor[] actors)
    int i = 0
    string actor_message = ""
    While i < actors.Length
        actor_message += GetActorName(actors[i]) + ", "
        i += 1
    EndWhile
    Debug.Notification(prefix + actor_message)
EndFunction


Function PrintActorsInConversation()
    int i = 0
    string actor_message = ""
    While i < Participants.GetSize()
        actor_message += GetActorName(Participants.GetAt(i) as Actor) + ", "
        i += 1
    EndWhile
    Debug.Notification(actor_message)
EndFunction


int Function CountActorsInConversation()
    return Participants.GetSize()
EndFunction


Actor Function GetActorInConversationByIndex(int indexOfActor) 
    If (indexOfActor >= 0 && indexOfActor < Participants.getSize())
        return Participants.GetAt(indexOfActor) as Actor
    EndIf
    return none
EndFunction


Function AddCurrentActorsAndContext(int handleToAddTo)
    ;Add Actors
    MantellaPlugin.setNestedDictionariesArray(handleToAddTo, mConsts.KEY_ACTORS, _actorHandles)
    ;Clear events
    ;string [] empty = new string[0]
    ;MantellaPlugin.setStringArray(_contextHandle, mConsts.KEY_CONTEXT_INGAMEEVENTS,empty)      ;??
    ;add context
    MantellaPlugin.setNestedDictionary(handleToAddTo, mConsts.KEY_CONTEXT, _contextHandle)
EndFunction


int[] function BuildNpcsInConversationArray()
    int i = Participants.GetSize()
    _actorHandles =  new int[i]
    While i > 0
        i -= 1
        _actorHandles[i] = buildActorSetting(Participants.GetAt(i) as Actor)
    EndWhile
    return _actorHandles
endFunction

;?
; int[] function UpdateNpcsInConversationArray()
;     ; Update NPC details where variables are dynamic
;     int i = 0
;     While i < Participants.GetSize()
;         Actor actorToBuild = Participants.GetAt(i) as Actor
;         MantellaPlugin.setBool(_actorHandles[i], mConsts.KEY_ACTOR_ISINCOMBAT, actorToBuild.IsInCombat())
;         i += 1
;     EndWhile
; endFunction

;?
Function AllSetLookAt(Actor speaker)    ; make sure everybody in conversation is looking at speaker
    int i = 0
    While i < Participants.GetSize()
        Actor tmpActor = Participants.GetAt(i) as Actor 
        if speaker != tmpActor
            tmpActor.SetLookAt(speaker)
        EndIf
        i += 1
    EndWhile
EndFunction

;?
Actor Function GetActorSpokenTo(Actor speaker)
    Actor spokenTo

    If IsPlayerInConversation()                ; single and multi-NPCs. Either PC or NPC can talk first
        if speaker != playerRef
            spokenTo  = playerRef
        Else
            spokenTo = _lastNpcToSpeak
        EndIf
    Else                                       ; Radiant conversation w/2 NPCs or new player convo w/ single NPC
        If speaker == Participants.GetAt(0)
            spokenTo = Participants.GetAt(1) as Actor
        Else
            spokenTo = Participants.GetAt(0) as Actor
        EndIf
    Endif

    return spokenTo
EndFunction


int function buildActorSetting(Actor actorToBuild)    
    int handle = MantellaPlugin.createDictionary()
    bool isPlayerCharacter = actorToBuild == PlayerRef

    MantellaPlugin.setInt(handle, mConsts.KEY_ACTOR_BASEID, (actorToBuild.getactorbase() as form).getformid())
    MantellaPlugin.setInt(handle, mConsts.KEY_ACTOR_REFID, (actorToBuild as form).getformid())
    MantellaPlugin.setString(handle, mConsts.KEY_ACTOR_NAME, actorToBuild.GetDisplayName())
    MantellaPlugin.setBool(handle, mConsts.KEY_ACTOR_ISPLAYER, actorToBuild == playerRef)
    MantellaPlugin.setInt(handle, mConsts.KEY_ACTOR_GENDER, actorToBuild.getleveledactorbase().getsex())
    MantellaPlugin.setString(handle, mConsts.KEY_ACTOR_RACE, actorToBuild.getrace())
    MantellaPlugin.setInt(handle, mConsts.KEY_ACTOR_RELATIONSHIPRANK, actorToBuild.getrelationshiprank(playerRef))
    MantellaPlugin.setString(handle, mConsts.KEY_ACTOR_VOICETYPE, actorToBuild.GetVoiceType())
    MantellaPlugin.setBool(handle, mConsts.KEY_ACTOR_ISINCOMBAT, actorToBuild.IsInCombat())    
    MantellaPlugin.setBool(handle, mConsts.KEY_ACTOR_ISENEMY, actorToBuild.getcombattarget() == playerRef)

    ;TODO
    ;EquipmentDescriber.AddEquipmentDescription(handle, actorToBuild, isPlayerCharacter, repository)

    int customActorValuesHandle = MantellaPlugin.createDictionary()
    If (isPlayerCharacter)
        AddCustomPCValues(customActorValuesHandle, actorToBuild)
    EndIf

    MantellaPlugin.setNestedDictionary(handle, mConsts.KEY_ACTOR_CUSTOMVALUES, customActorValuesHandle)  
    return handle
endFunction


int Function AddCustomPCValues(int customActorValuesHandle, Actor actorToBuildCustomValuesFor)
    string description = repository.playerCharacterDescription1
    If (repository.playerCharacterUsePlayerDescription2)
        description = repository.playerCharacterDescription2
    EndIf
    MantellaPlugin.setString(customActorValuesHandle, mConsts.KEY_ACTOR_PC_DESCRIPTION, description)

    ;Fallout always has voiced player
    ;MantellaPlugin.setBool(customActorValuesHandle, mConsts.KEY_ACTOR_PC_VOICEPLAYERINPUT, repository.playerCharacterVoicePlayerInput)
    ;If (repository.playerCharacterVoicePlayerInput)
        ;MantellaPlugin.setString(customActorValuesHandle, mConsts.KEY_ACTOR_PC_VOICEMODEL, repository.playerCharacterVoiceModel)
    ;EndIf

    ;Obsolete
    ;MantellaPlugin.setFloat(handleCustomActorValues, mConsts.KEY_ACTOR_CUSTOMVALUES_POSX, actorToBuildCustomValuesFor.getpositionX())
    ;MantellaPlugin.setFloat(handleCustomActorValues, mConsts.KEY_ACTOR_CUSTOMVALUES_POSY, actorToBuildCustomValuesFor.getpositionY())
    return customActorValuesHandle
EndFunction

Function CheckInGameEvents()
    if _ingameEvents && _ingameEvents.Length > 0
        Debug.TraceUser("MC", "Building context with events: " + _ingameEvents.Length)
        MantellaPlugin.setStringArray(_contextHandle, mConsts.KEY_CONTEXT_INGAMEEVENTS, _ingameEvents)
    Else
        string [] prevEvents = MantellaPlugin.getStringArray(_contextHandle, mConsts.KEY_CONTEXT_INGAMEEVENTS)
        int prevEvLen = prevEvents.Length
        ;Debug.TraceUser("MC", "PrevEventsLen " + prevEvLen)
        int i = 0
        string evstr = ""
        while i < prevEvLen
            evstr += prevEvents[i]
            if i < prevEvLen - 1
                evstr += ", "
            EndIf
            i += 1
        Endwhile
        if prevEvLen > 0
            Debug.TraceUser("MC", "Discarding " + prevEvLen + " events: " + evstr)

            string [] empty = new string[0]
            MantellaPlugin.setStringArray(_contextHandle, mConsts.KEY_CONTEXT_INGAMEEVENTS,empty)      ;??
        Endif
    Endif
EndFunction

int function BuildContext(bool isConversationStart = false)
    ;Debug.TraceUser("MC", "Building context, isConversationStart: " + isConversationStart)
    _contextHandle = MantellaPlugin.createDictionary()
    if (isConversationStart)
        _location = ""
        form currentLocation = playerRef.GetCurrentLocation() as Form
        if currentLocation
            _location = currentLocation.getName()
        Else
            _location = "Commonwealth"
        endIf
        MantellaPlugin.setString(_contextHandle, mConsts.KEY_CONTEXT_LOCATION, _location)
    endIf

    if (isConversationStart || repository.playerTrackingOnWeatherChange)
        AddCurrentWeather(_contextHandle)
    endIf

    if (isConversationStart || repository.playerTrackingOnTimeChange)
        _initialTime = GetCurrentHourOfDay()
    endIf
    MantellaPlugin.setInt(_contextHandle, mConsts.KEY_CONTEXT_TIME, _initialTime)
    MantellaPlugin.setFloat(_contextHandle, mConsts.KEY_CONTEXT_GAMEDAYS, Math.Floor(Utility.GetCurrentGameTime()))

    
    Debug.TraceUser("MC", "BuildContext Checkingameevents")
    CheckInGameEvents()
    ;? string[] past_events = deepcopy(_ingameEvents)
     ClearIngameEvent()

    ; Add nearby actors context for action targeting
    if repository.allowNearbyActors
        int[] nearbyActorHandles = BuildNearbyActorsContext()
        if nearbyActorHandles && nearbyActorHandles.Length > 0
            MantellaPlugin.setNestedDictionariesArray(_contextHandle, mConsts.KEY_CONTEXT_NEARBYACTORS, nearbyActorHandles)
        endIf
    Endif

    ; Fallout-specific context values
    int customValuesHandle = BuildCustomContextValues()
    MantellaPlugin.setNestedDictionary(_contextHandle, mConsts.KEY_CONTEXT_CUSTOMVALUES, customValuesHandle)
    return _contextHandle
endFunction


int Function BuildCustomContextValues()
    int handleCustomContextValues = MantellaPlugin.createDictionary()
    ;Unused MantellaPlugin.setFloat(handleCustomContextValues, mConsts.KEY_CONTEXT_CUSTOMVALUES_PLAYERHEALTH, repository.PlayerRadFactoredHealth)
    ;Unused MantellaPlugin.setFloat(handleCustomContextValues, mConsts.KEY_CONTEXT_CUSTOMVALUES_PLAYERRAD, repository.PlayerRadiationPercent)
    bool isVisionReady = repository.checkAndUpdateVisionPipeline()
    ; if isVisionReady
    ;     MantellaPlugin.setBool(handleCustomContextValues, mConsts.KEY_CONTEXT_CUSTOMVALUES_VISION_READY, isVisionReady)
    ;     MantellaPlugin.setString(handleCustomContextValues, mConsts.KEY_CONTEXT_CUSTOMVALUES_VISION_RES, repository.visionResolution)
    ;     MantellaPlugin.setInt(handleCustomContextValues, mConsts.KEY_CONTEXT_CUSTOMVALUES_VISION_RESIZE, repository.visionResize)
    ; endif

    if repository.allowVisionHints && repository.ActorsInCellArray!=""
        MantellaPlugin.setString(handleCustomContextValues, mConsts.KEY_ACTOR_CUSTOMVALUES_VISION_HINTSNAMEARRAY, repository.ActorsInCellArray)
        MantellaPlugin.setString(handleCustomContextValues, mConsts.KEY_ACTOR_CUSTOMVALUES_VISION_HINTSDISTANCEARRAY, repository.VisionDistanceArray)
        repository.resetVisionHintsArrays()
    endif

    return handleCustomContextValues
EndFunction

int[] function BuildNearbyActorsContext()
    ; Scan for nearby actors (excludes Mantella conversation participants)

    Actor[] nearbyActors = repository.ScanNearbyActors(1500.0, 5)
    _cachedNearbyActors = nearbyActors

    Debug.TraceUser("MC", "BuildNearbyActorsContext found " + nearbyActors.Length + " nearby actors.")
    if !nearbyActors || nearbyActors.Length == 0
        return new int[0]
    endIf

    int totalEntries = nearbyActors.Length
    int[] nearbyActorHandles = new int[0]
    float toMeters = 1.0 / 78.74      ;?
    int i = 0
    While i < totalEntries
        Actor nearbyActor = nearbyActors[i]
        if nearbyActor != None
            int actorHandle = MantellaPlugin.createDictionary()
            MantellaPlugin.setString(actorHandle, "name", nearbyActor.GetDisplayName())
            float distanceInMeters = PlayerRef.GetDistance(nearbyActor) * toMeters
            MantellaPlugin.setFloat(actorHandle, "distance", distanceInMeters)
            nearbyActorHandles.Add(actorHandle)
        endIf
        i += 1
    EndWhile

    if nearbyActorHandles.Length == 0
        return new int[0]
    endIf

    return nearbyActorHandles
endFunction

function AddCurrentWeather(int contextHandle)
    If (!PlayerRef.IsInInterior())
        int handle = MantellaPlugin.createDictionary()
        Weather currentWeather = Weather.GetCurrentWeather()
        MantellaPlugin.setString(handle, mConsts.KEY_CONTEXT_WEATHER_ID, currentWeather.GetFormID())
        MantellaPlugin.setInt(handle, mConsts.KEY_CONTEXT_WEATHER_CLASSIFICATION, currentWeather.GetClassification())
        MantellaPlugin.setNestedDictionary(contextHandle, mConsts.KEY_CONTEXT_WEATHER, handle)
    EndIf
endFunction

int function GetCurrentHourOfDay()
	float Time = Utility.GetCurrentGameTime()
	Time -= Math.Floor(Time) ; Remove "previous in-game days passed" bit
	Time *= 24 ; Convert from fraction of a day to number of hours
	int Hour = Math.Floor(Time) ; Get whole hour
	return Hour
endFunction

Function ShowRepeatingMessage(string messageToShow)
    _repeatingMessage = messageToShow
    if repository.showReminderMessages
        Debug.Notification(_repeatingMessage)
        StartTimer(10.0, _repeatingMessageTimer) ; Timer ID 1412 is reserved for repeating message display
    endIf
EndFunction

Function ClearRepeatingMessage()
    _repeatingMessage = ""
EndFunction




; Functions to temporarly change some game settings
; to prevent various NPCs from interrupting conversations in progress
; Need to have the plugin save the values, as loading a game resets script variables,
; possibly losing the saved GameSettings
; All Game settings are reset when starting the game

; Save the game's original GameSettings before we modify them at conversation start
Function SaveSettings()
    if !SettingsSaved
;     MantellaPlugin.saveFloat("fAISocialTimerForConversationsMax")       ; Time to wait before NPC can trigger another conversation
;     MantellaPlugin.saveFloat("fAISocialTimerForConversationsMin")
;     MantellaPlugin.saveInt("iAISocialDistanceToTriggerEvent")
        MantellaPlugin.saveFloat("fAIGreetingTimer")
        MantellaPlugin.saveFloat("fAISocialchanceForConversation")      ; % of how likely a NPC will initiate a dialogue with another NPC
        MantellaPlugin.saveFloat("fAIMinGreetingDistance")        ; How close NPC must be to attempt greeting
        MantellaPlugin.saveFloat("fAIForceGreetingTimer")         ; How long NPC must wait before greeting again
        SettingsSaved = true;
    Endif
EndFunction

; Apply Mantella settings to stop NPCs talking
Function ApplySettings()
    if !SettingsSaved
        SaveSettings()
    Endif
    if !SettingsApplied
        Game.SetGameSettingFloat("fAIGreetingTimer", 600.0)
        Game.SetGameSettingFloat("fAISocialchanceForConversation", 1.0)        ; % of how likely a NPC will initiate a dialogue with another NPC
        Game.SetGameSettingFloat("fAIMinGreetingDistance", 1.0)        ; How close NPC must be to attempt greeting
        Game.SetGameSettingFloat("fAIForceGreetingTimer", 600.0)         ; How long NPC must wait before greeting again
        SettingsApplied = true
    EndIf
EndFunction

; Restore settings after conversation ends
Function RestoreSettings()
    if !SettingsSaved
        SaveSettings()
    Endif
    if SettingsApplied
        MantellaPlugin.restoreFloat("fAIGreetingTimer")
        MantellaPlugin.restoreFloat("fAISocialchanceForConversation")      ; % of how likely a NPC will initiate a dialogue with another NPC
        MantellaPlugin.restoreFloat("fAIMinGreetingDistance")        ; How close NPC must be to attempt greeting
        MantellaPlugin.restoreFloat("fAIForceGreetingTimer")         ; How long NPC must wait before greeting again
        SettingsApplied =  false
    EndIf
EndFunction


