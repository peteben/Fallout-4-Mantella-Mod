Scriptname MantellaRepository extends Quest Conditional

;keycode properties

int property MenuEventSelector auto
MantellaConversation property conversation auto
MantellaConstants property ConstantsScript auto

Quest Property MantellaVisibleCollectionQuest Auto                      ; for vision hints
RefCollectionAlias Property MantellaVisibleNPCRefCollection  Auto       ; max 10 dist 5000

bool Property allowNearbyActors auto

Quest Property MantellaNPCCollectionQuest Auto  ;;Unused
RefCollectionAlias Property MantellaNPCCollection  Auto         ;max 30, dist 25000  ;;Unused

Quest Property NearbyActorsQuest Auto
RefCollectionAlias Property NearbyActorsCollection Auto
GlobalVariable Property NearbyActorDistance Auto                ;Used to parameterize NPC scan distance 


;endFlagMantellaConversationOne exists to prevent conversation loops from getting stuck on NPCs if Mantella crashes or interactions gets out of sync
;bool property endFlagMantellaConversationOne auto
string property currentFO4version auto
bool property isFO4VR auto Conditional

bool property isFlat auto

bool property microphoneEnabled auto Conditional
bool property useHotkeyToStartMic auto
bool property showReminderMessages auto

bool property radiantEnabled auto
int property radiantQuantity auto
float property radiantDistance auto
float property radiantFrequency auto conditional
bool property approachEnabled auto
int property triggerRatio auto
bool property showRadiantDialogueMessages auto  ;;Unused

bool property allowVanillaDialogue auto Conditional  ;;Used by MCM and MantellaPlugin
float property dialogueExpirationTime = 48.0 auto  ;;Used by MCM and MantellaPlugin

string property playerCharacterDescription1 auto
string property playerCharacterDescription2 auto
bool property playerCharacterUsePlayerDescription2 auto

;vision parameters
bool property hideVisionMenu auto Conditional
bool property allowVision auto Conditional
bool property allowVisionHints auto Conditional
bool property hasPendingVisionCheck auto
string property visionResolution auto
int property visionResize auto Conditional
String property ActorsInCellArray auto
String property VisionDistanceArray auto

;function calling parameters
bool property hideFunctionMenu auto Conditional
bool property allowFunctionCalling auto Conditional
Quest Property MantellaFunctionNPCCollectionQuest Auto                          ;;Unused
RefCollectionAlias Property MantellaFunctionNPCCollection  Auto                 ;;Unused

Actor[] Property MantellaFunctionInferenceActorList  Auto               ;is this really necessary?
String Property MantellaFunctionInferenceActorNamesList  Auto
String Property MantellaFunctionInferenceActorDistanceList  Auto
String Property MantellaFunctionInferenceActorIDsList  Auto
int property NPCAIPackageSelector auto Conditional  ;;Unused
bool property isAParticipantInteractingWithGroundItems auto conditional  ;;Unused
;MantellaFunctionSourceFaction values
;-1 = default state
;0 = wait
;1 = follow non-player
;2 = attack
;3 = loot
;4 = use item (item must be specified below)
;5 = follow player
;6 = use spell (skyrim only)
int property NPCAIItemToUseSelector auto Conditional  ;;Unused
;1 = stimpak
int property NPCAIItemToLootSelector auto Conditional  ;;Unused
;0 = any
;1 = weapon
;2 = armor
;3 = junk
;4 = consumables


int Property HTTPTimeOutHolotapeValue Auto Conditional
bool property allowActionAggro auto Conditional
bool property allowNPCsStayInPlace auto Conditional
bool property allowFollow auto Conditional
bool property allowActionInventory auto Conditional
bool property allowCrosshairTracking auto Conditional
Spell property MantellaSpell auto
Perk property ActivatePerk auto
bool property hasActivatePerk auto
;variables below for Player game event tracking
bool property playerTrackingOnItemAdded auto Conditional
bool property playerTrackingOnItemRemoved auto Conditional
bool property playerTrackingOnSurvivalItemAdded auto Conditional  ;;Unused
bool property playerTrackingOnSurvivalItemRemoved auto Conditional  ;;Unused
bool property playerTrackingOnHit auto Conditional
bool property playerTrackingOnLocationChange auto Conditional
bool property playerTrackingOnObjectEquipped auto Conditional
bool property playerTrackingOnObjectUnequipped auto Conditional
bool property playerTrackingOnSit auto Conditional
bool property playerTrackingOnGetUp auto Conditional
bool property playerTrackingFireWeapon auto Conditional
bool property playerTrackingRadiationDamage auto Conditional
bool property playerTrackingSleep auto Conditional
bool property playerTrackingCripple auto Conditional
bool property playerTrackingHealTeammate auto Conditional

bool property allowTrackPlayerState auto Conditional
bool property playerTrackingOnTimeChange auto
bool property playerTrackingOnWeatherChange auto


int property worldID auto

;variables below for Mantella Target tracking
bool property targetTrackingItemAdded auto
bool property targetTrackingItemRemoved auto
bool property targetTrackingOnHit auto
bool property targetTrackingOnCombatStateChanged auto
bool property targetTrackingOnObjectEquipped auto
bool property targetTrackingOnObjectUnequipped auto
bool property targetTrackingOnSit auto
bool property targetTrackingOnGetUp auto
bool property targetTrackingCompleteCommands auto
bool property targetTrackingGiveCommands auto


;variables below are to prevent game listener events from firing too often
bool property EventFireWeaponSpamBlocker auto
bool property EventRadiationDamageSpamBlocker auto
int property WeaponFiredCount auto


;player Variables
float property PlayerRadFactoredHealth auto
float property PlayerRadiationPercent auto

;item variables
;int property StimpackCount auto
;int property RadAwayCount auto

;misc Variabales
ActorValue property HealthAV auto
ActorValue property RadsAV auto
float radiationToHealthRatio = 0.229
Actor property CrosshairActor auto
int CleanupconversationTimer=2
int property HttpPort auto

;Callback variables for SimpleTextField
ScriptObject CBscript =  none
string CBfunction
bool Property isFirstConvo = true auto

;tutorial variables
bool property tutorialActivated auto Conditional  ;;Unused
bool property showHolotapeSettingsTutorial auto  ;;Unused
bool property showHotkeysTutorial auto  ;;Unused
bool property showHTTPSettingsTutorial auto  ;;Unused
bool property showRadiantSettingsTutorial auto  ;;Unused
bool property showVisionSettingsTutorial auto  ;;Unused
bool property showNPCActionsTutorial auto  ;;Unused
bool property showEventTrackingTutorial auto  ;;Unused
bool property showConversationTimeoutTutorial auto  ;;Unused

string property testForMCM = "MCM string" auto  ;;Unused
string property testForMCMhelp = "MCM help string" auto  ;;Unused

bool property unregisteredkeys = false auto
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;   Game management functions and events   ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

Event OnInit()
    reinitializeVariables()
EndEvent


Function ResetEventSpamBlockers()
    EventFireWeaponSpamBlocker=false
    WeaponFiredCount=0
    EventRadiationDamageSpamBlocker=false
Endfunction

Function OnLoadGame()  ;;Called from OnPlayerLoadGame() on a player-alias script elsewhere in the mod
    if !unregisteredkeys
        int I = 8
        While i <= 260
            UnregisterForKey(i)
            Utility.Wait(0.2)
            I += 1
        EndWhile
        unregisteredkeys = true
    EndIf

    ;Form acQuest = Game.GetFormFromFile(0x05E000, "Mantella.esp")
    ;Debug.TraceUser("MC", "NearbyActors " +  NearbyActorsQuest)
    ;Quest NearbyActorsVar = acQuest as Quest
    ;Debug.TraceUser("MC", "QuestVar " + NearbyActorsVar)

    ; MantellaNearbyActors = NearbyActorsVar
    ;Debug.TraceUser("MC", "NearbyActorsCollection: " + NearbyActorsCollection)

EndFunction


Function StopConversations()                ;; Used by MCM
    Debug.TraceUser("MC", "StopConversation")
    If (conversation.IsRunning())
        conversation.EndConversation()
        StartTimer(5,CleanupconversationTimer)              ;Start a timer to make second hard reset if conversation is still running after
        conversation.conversationIsEnding = false
    EndIf
EndFunction

Function RestartMantellaExe()               ;Used by MCM
    Debug.notification("Attempting to restart Mantella.exe")
    MantellaPlugin.LaunchMantellaExe()
Endfunction

Event Ontimer( int TimerID)
    if TimerID==CleanupconversationTimer
        ;debug.notification("checking if conversation is still running")
        if conversation.IsRunning() ;attempts to make a hard reset of the conversation if it's still going on for some reason
             ;previous conversation detected, forcing conversation to end.
             debug.notification("Previous conversation detected after request to end : Cleaning up.")
             Conversation.CleanupConversation()
         endif
     endif
 EndEvent


Function reinitializeVariables()            ;Used by MCM
    ;change the below this is for debug only
    radiantEnabled = true
    radiantDistance = 20
    radiantFrequency = 10
    allowVision = false
    allowVisionHints = true
    allowFunctionCalling = false
    visionResolution="auto"
    visionResize=1024
    allowActionAggro = false
    allowActionInventory = false
    allowFollow = false
    allowNPCsStayInPlace = true
    MenuEventSelector=0
    microphoneEnabled = isFO4VR
    ConstantsScript.HTTP_PORT = 4999
    ;togglePlayerEventTracking(true)
    ;toggleTargetEventTracking(true)
    HTTPTimeOutHolotapeValue = 240
    ;Actor PlayerRef = Game.GetPlayer()
    ; If !(PlayerRef.HasPerk(ActivatePerk))
    ;     PlayerRef.AddPerk(ActivatePerk, False)
    ; Endif
    conversation.conversationIsEnding = false
    hideFunctionMenu=false
    hideVisionMenu=false
EndFunction





Function togglePlayerItemEventTracking(bool bswitch)    ;Used by MCM
    ;Player tracking variables below
    if bswitch
        Debug.notification("Player item pickup/drop event tracking is now ON")
    else
        Debug.notification("Player item pickup/drop event tracking is now OFF")
    endif
    playerTrackingOnItemAdded = bswitch
    playerTrackingOnItemRemoved = bswitch
EndFunction


Function togglePlayerEquipEventTracking(bool bswitch)    ;Used by MCM
    ;Player tracking variables below
    if bswitch
        Debug.notification("Player item equip/unequip event tracking is now ON")
    else
        Debug.notification("Player item equip/unequip event tracking is now OFF")
    endif
    playerTrackingOnObjectEquipped = bswitch
    playerTrackingOnObjectUnequipped = bswitch
EndFunction

Function togglePlayerSitEventTracking(bool bswitch)    ;Used by MCM
    ;Player tracking variables below
    if bswitch
        Debug.notification("Player sitting or using workbenches event tracking is now ON")
    else
        Debug.notification("Player sitting or using workbenches event tracking is now OFF")
    endif
    playerTrackingOnSit = bswitch
    playerTrackingOnGetUp = bswitch
EndFunction


Function toggleTargetItemEventTracking(bool bswitch)    ;Used by MCM
    ;Player tracking variables below
    targetTrackingItemAdded = bswitch
    targetTrackingItemRemoved = bswitch
EndFunction

Function toggleTargetEquipEventTracking(bool bswitch)    ;Used by MCM
    ;Player tracking variables below
    targetTrackingOnObjectEquipped = bswitch
    targetTrackingOnObjectUnequipped = bswitch
EndFunction

Function toggleTargetOnSitEventTracking(bool bswitch)    ;Used by MCM
    ;Player tracking variables below
    targetTrackingOnSit = bswitch
    targetTrackingOnGetUp = bswitch
EndFunction

Function toggleAllowAggro(bool bswitch)  ;;Unused (not called anywhere in these 5 scripts)
    allowActionAggro = bswitch
    if bswitch
        Debug.notification("NPCs are now allowed to aggro")
    else
        Debug.notification("NPCs are not allowed to aggro")
    endif
EndFunction

Function toggleAllowFollow(bool bswitch)  ;;Unused (not called anywhere in these 5 scripts)
    allowFollow = bswitch
EndFunction

Function toggleActionInventory(bool bswitch)  ;;Unused (not called anywhere in these 5 scripts)
    allowActionInventory = bswitch
EndFunction

Function toggleAllowNPCsStayInPlace(bool bswitch)
    allowNPCsStayInPlace = bswitch
EndFunction


Function toggleAllowVision(bool bswitch)  ;;Unused (not called anywhere in these 5 scripts)
    allowVision = bswitch
    if bswitch
        Debug.notification("Vision analysis is now ON")
    else
        Debug.notification("Vision analysis is now OFF")
    endif
EndFunction

Function toggleAllowFunctionCalling(bool bswitch)  ;;Unused (not called anywhere in these 5 scripts)
    allowFunctionCalling = bswitch
    if allowFunctionCalling
        ;toggle NPC Stay in Place as well since function calling depends on it.
        toggleAllowNPCsStayInPlace(true)
    endif
    if bswitch
        Debug.notification("Function Calling is now ON")
    else
        Debug.notification("Function Calling is now OFF")
    endif
EndFunction

Function toggleAllowVisionHints(bool bswitch)  ;;Unused (not called anywhere in these 5 scripts)
    allowVisionHints = bswitch
    if bswitch
        Debug.notification("Vision hints are now ON")
    else
        Debug.notification("Vision hints are now OFF")
    endif
EndFunction

Function setActivatePerk(bool enable)    ;Used by MCM
    Actor PlayerRef = Game.GetPlayer()
    Debug.Notification("setActivatePerk " + enable)
    hasActivatePerk = enable
    if enable
        PlayerRef.AddPerk(ActivatePerk, False)
    Else
		PlayerRef.RemovePerk(ActivatePerk)
    Endif
EndFunction

Function startConversationKey()    ;Used by MCM
    if allowCrosshairTracking
        int actorID = MantellaPlugin.GetLastCrosshairActorID()
        Debug.TraceUser("MC", "actorID " + actorID)
        if actorID == 0
            return
        Endif

        CrosshairActor = Game.GetForm(actorID) as Actor
        Debug.Notification("Crosshair actor is: " + CrosshairActor.GetDisplayName())

        if CrosshairActor != none
            String actorName = CrosshairActor.GetDisplayName()
            bool isTargetInConversation = conversation.IsActorInConversation(CrosshairActor)
            float distanceFromConversationTarget = Game.GetPlayer().GetDistance(CrosshairActor)

            if distanceFromConversationTarget<1500
                ; if actor not already loaded or player is interrupting radiant dialogue
                bool bIsPlayerInConversation = conversation.IsPlayerInConversation()

                if !isTargetInConversation
                    debug.notification("Attempting to start conversation with "+actorName)
                    MantellaSpell.cast(Game.GetPlayer(), CrosshairActor)
                ElseIf !bIsPlayerInConversation
                    debug.notification("Adding player to radiant conversation with "+actorName)
                    MantellaSpell.cast(CrosshairActor, Game.GetPlayer())
                else
                    debug.notification("Displaying conversation menu for "+actorName)
                    MantellaSpell.cast(Game.GetPlayer(), CrosshairActor)
                endif
                Utility.Wait(0.5)
            endif
        endif
    EndIf
EndFunction



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;   Vision functions    ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

Function GenerateMantellaVision()
    hasPendingVisionCheck=true
    MantellaPlugin.TakeScreenShot("Mantella_Vision.jpg", 0)
    if allowVisionHints
        ScanCellForActorsFilteredLOS()
    endif
EndFunction

bool Function checkAndUpdateVisionPipeline()
    ;automatically triggers to false to allow Camera and Spell to send the vision value only once per exchange.
    if allowVision || hasPendingVisionCheck
        hasPendingVisionCheck=false
        return true
    else
        return false
    endif
EndFunction




;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;   NPC array management    ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;Get list of nearby actors not involved in current conversation
Actor[] Function ScanNearbyActors(Float maxDist, int maxActors = 5)
    ;Debug.TraceUser("MC", "Scan dist: " + maxDist + " count: " + maxActors)
    Float savedDistance = NearbyActorDistance.GetValue()
    NearbyActorDistance.SetValue(maxDist)     ;temporarly change the value for the nearbyactor scan quest

    ;Debug.TraceUser("MC", "NearbyActorsQuest " + NearbyActorsQuest + " Collection:" + NearbyActorsCollection)
    NearbyActorsQuest.start()
    int countNearbyActors = NearbyActorsCollection.GetCount()
    if countNearbyActors > maxActors
        countNearbyActors =  maxActors
    EndIf

    ;Debug.TraceUser("MC", "Scanning for nearby actors... Found " + countNearbyActors)
    Actor[] nearbyActors = new Actor[countNearbyActors]
    int i = 0
    int len = countNearbyActors

    while i < len
        Actor act = NearbyActorsCollection.GetAt(i) as Actor
        nearbyActors[i] = act
        i = i + 1
    endwhile

    i = 0
    while i < nearbyActors.Length
        if conversation.IsActorInConversation(nearbyActors[i])
            nearbyActors.remove(i)
        else
            i = i + 1
        Endif
    Endwhile

    ;Debug.TraceUser("MC", "Actors: " + len + " returning: " + nearbyActors.Length)
    NearbyActorsQuest.stop()
    NearbyActorDistance.SetValue(savedDistance)     ;restore value

    return nearbyActors
Endfunction


Function ScanCellForActorsFilteredLOS()
    Actor playerRef = Game.GetPlayer()
    Actor[] ActorsInCell = new Actor[0]
    float[] currentDistanceArray = new float[0]
    MantellaVisibleCollectionQuest.start()
    int icount = MantellaVisibleNPCRefCollection.GetCount()
    int iindex = 0
    while (iindex < icount)
        Actor Actori = MantellaVisibleNPCRefCollection.GetAt(iindex) as Actor
        float currentDistance = playerRef.GetDistance(Actori)
        if Actori.GetDisplayName()!="" && playerRef.HasDetectionLOS (Actori)
            ActorsInCell.add(Actori)
            currentDistanceArray.add(currentDistance)
        endif
        iindex = iindex + 1
    endwhile
    MantellaVisibleCollectionQuest.stop()
    ActorsInCellArray=ActorsArrayToString(ActorsInCell)
    VisionDistanceArray = currentDistanceArrayToString(currentDistanceArray)
Endfunction

Actor[] Function ScanAndReturnNearbyActors(quest QuestForScan, RefCollectionAlias RefCollectionToUse, bool addPlayerToo)
    Actor[] ActorsInCell = new Actor[0]
    QuestForScan.start()
    Utility.Wait(0.1)
    int icount = RefCollectionToUse.GetCount()
    int iindex = 0
    while (iindex < icount)
        Actor Actori = RefCollectionToUse.GetAt(iindex) as Actor
        ActorsInCell.add(Actori)
        iindex = iindex + 1
    endwhile
    if addPlayerToo
        ActorsInCell.add(game.getplayer() as Actor)
    endif
    QuestForScan.stop()
    return ActorsInCell
Endfunction

Function UpdateFunctionInferenceNPCArrays(Actor[] ActorArray)  ;;Unused (not called anywhere in these 5 scripts)
    actor playerRef = game.GetPlayer()
    Float[] currentDistanceArray = new Float[0]
    ;String[] currentFormIDArray = new String[0] ;is this line really necessary?
    int icount = ActorArray.Length
    int iindex = 0
    MantellaFunctionInferenceActorList = new Actor[0]
    while (iindex < icount)
        Actor Actori = ActorArray[iindex]
        float currentDistance = playerRef.GetDistance(Actori)
        MantellaFunctionInferenceActorList.add(Actori) ;is this line really necessary? Could be done in one shot out of the loop
        currentDistanceArray.add(currentDistance)
        ;currentFormIDArray.add(currentFormID) ;is this line really necessary?
        iindex = iindex + 1
    endwhile
    MantellaFunctionInferenceActorNamesList=ActorsArrayToString(MantellaFunctionInferenceActorList)
    MantellaFunctionInferenceActorDistanceList = currentDistanceArrayToString(currentDistanceArray)
    MantellaFunctionInferenceActorIDsList = ActorsArrayToFormIDString(MantellaFunctionInferenceActorList)
Endfunction

String Function ActorsArrayToString (Actor[] ActorArray)
    string StringOutput
    int i = 0
    string currentActorName =""
    While i < ActorArray.Length
        Actor currentActor = ActorArray[i]
        currentActorName = currentActor.GetDisplayName()
        StringOutput += "["+currentActorName+"]"
        if i != (ActorArray.Length-1)
            StringOutput += ","
        endif
        i += 1
    EndWhile
    return StringOutput
Endfunction

String Function currentDistanceArrayToString (Float[] currentDistanceArray)
    string StringOutput
    int i = 0
    While i < currentDistanceArray.Length
        float currentDistance = currentDistanceArray[i]
        StringOutput += "["+currentDistance+"]"
        if i != (currentDistanceArray.Length-1)
            StringOutput += ","
        endif
        i += 1
    EndWhile
    return StringOutput
Endfunction

String Function ActorsArrayToFormIDString (Actor[] ActorArray)
    string StringOutput
    int i = 0
    string currentActorFormID =""
    While i < ActorArray.Length
        Actor currentActor = ActorArray[i]
        currentActorFormID = currentActor.GetFormID() as string
        StringOutput += "["+currentActorFormID+"]"
        if i != (ActorArray.Length-1)
            StringOutput += ","
        endif
        i += 1
    EndWhile
    return StringOutput
Endfunction

Function resetVisionHintsArrays()
    ActorsInCellArray=""
    VisionDistanceArray = ""
Endfunction

Function resetFunctionInferenceNPCArrays()  ;;Unused (not called anywhere in these 5 scripts)
    MantellaFunctionInferenceActorNamesList=""
    MantellaFunctionInferenceActorDistanceList=""
    MantellaFunctionInferenceActorIDsList=""
Endfunction

Actor Function getActorFromArray(string targetID, actor[] actorarray)  ;;Unused (not called anywhere in these 5 scripts)
    int i = 0
    int convertedTargetID = targetID as int
    While i < actorarray.Length
        Actor currentActor = actorarray[i]
        if currentActor.GetFormID() == convertedTargetID
            return currentActor
        endIf
        i += 1
    EndWhile
    return none
Endfunction


Function DispelAllMantellaMagicEffectsFromActors(Actor[] ActorArray)
    int i=0
    While i < ActorArray.Length
        Actor actorToDispel = ActorArray[i]
        actorToDispel.DispelSpell(MantellaSpell)
        i += 1
    EndWhile
Endfunction

Function RemoveFactionFromActors(Actor[] ActorArray, faction FactionToRemove)
    ;This function is mostly used to remove NPCs from the MantellaFunctionTargetFaction
    int i=0
    While i < ActorArray.Length
        Actor actorToDispel = ActorArray[i]
        actorToDispel.RemoveFromFaction(FactionToRemove)
        i += 1
    EndWhile
Endfunction


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;   Player and NPC state reporting   ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

string lastPlayerState

string function constructPlayerState()
    If !allowTrackPlayerState
        return ""
    EndIf

    String[] playerStateArray = new String[10]
    string playerState = "The player is "
    int playerStatePositiveCount=0
    Actor playerRef = Game.GetPlayer()
    if playerRef.IsInPowerArmor()
        playerStateArray[playerStatePositiveCount]="in power armor"
        playerStatePositiveCount+=1
    endif
    if playerRef.IsOverEncumbered()
        playerStateArray[playerStatePositiveCount]="overencumbered"
        playerStatePositiveCount+=1
    endif
    if playerRef.IsSneaking()
        playerStateArray[playerStatePositiveCount]="sneaking"
        playerStatePositiveCount+=1
    endif
    if playerRef.IsBleedingOut()
        playerStateArray[playerStatePositiveCount]="bleeding out"
        playerStatePositiveCount+=1
    endif
    PlayerRadFactoredHealth = getRadFactoredPercentHealth(playerRef)
    PlayerRadiationPercent = getRadPercent(playerRef)

    if 0.9 > PlayerRadFactoredHealth && PlayerRadFactoredHealth >= 0.7
        playerStateArray[playerStatePositiveCount]="lightly wounded"
        playerStatePositiveCount+=1
    ElseIf 0.7 > PlayerRadFactoredHealth && PlayerRadFactoredHealth >= 0.4
        playerStateArray[playerStatePositiveCount]="moderately wounded"
        playerStatePositiveCount+=1
    ElseIf 0.4 > PlayerRadFactoredHealth
        playerStateArray[playerStatePositiveCount]="heavily wounded"
        playerStatePositiveCount+=1
    endif
    if PlayerRadiationPercent > 0.15 && PlayerRadiationPercent <= 0.3
        playerStateArray[playerStatePositiveCount]="lightly irradiated"
        playerStatePositiveCount+=1
    ElseIf PlayerRadiationPercent > 0.3 && PlayerRadiationPercent <= 0.6
        playerStateArray[playerStatePositiveCount]="moderately irradiated"
        playerStatePositiveCount+=1
    ElseIf 0.6 < PlayerRadiationPercent
        playerStateArray[playerStatePositiveCount]="heavily irradiated"
        playerStatePositiveCount+=1
    endif

    if playerStatePositiveCount>0
        playerState += playerStateArray[0]
        if playerStatePositiveCount>2
            playerState += ", "
         endif
    endif
    int i=1
    while i <= (playerStatePositiveCount-2)
        if i == playerStatePositiveCount -2
            playerState += playerStateArray[i]
        else
            playerState += playerStateArray[i] + ", "
        endif
        i+=1
    endwhile
    ; Add the last entry with a different separator if there is more than one entry
    If playerStatePositiveCount > 1
        playerState += " & "
        playerState+= playerStateArray[playerStatePositiveCount - 1]
    EndIf


    ;debug.notification(playerState)
    if playerStatePositiveCount>0 && lastPlayerState != playerState
        lastPlayerState = playerState
        return playerState
    Else
        return ""
    endIf
endfunction

float function getRadPercent(actor currentActor)
    float radPercent
    radPercent=((currentActor.getvalue(RadsAV)) * radiationToHealthRatio) / (currentActor.getvalue(HealthAV)/currentActor.GetValuePercentage(HealthAV))
    return radPercent
endfunction

float function getRadFactoredMaxHealth(actor currentActor)
    float MaxHealth= currentActor.getvalue(HealthAV)/currentActor.GetValuePercentage(HealthAV)
    float radFactoredMaxHealth=MaxHealth*(1-getRadPercent(currentActor))
    return radFactoredMaxHealth
endfunction

float function getRadFactoredPercentHealth(actor currentActor)
    float radFactoredPercentHealth= currentActor.getvalue(HealthAV)/getRadFactoredMaxHealth(currentActor)

    return radFactoredPercentHealth
endfunction


;Proxy functions for calling the SimpleTextField dialog
;The code handling the callback would occasionaly get confused
;When calling back to MantellaConversation because
;MantellaConversation quest has two scripts associated with it: MantellaConversation and
;MantellaConstants. It would sometimes try calling back to the wrong one.
;Since MantellaQuest has only a single script, no confusion occurs and
;we just call the requested function from here

Function TextInputCB(string text)  ;;Used indirectly via SimpleTextField.Open callback string, not a direct call
    var[] _args = new var[1]
    _args[0] = text
    CBscript.CallFunctionNoWait(CBfunction,_args)
EndFunction

Function GetTextInput(ScriptObject akReceiver, string asFunctionName, string asTitle = "", string asText = "")
    CBscript = akReceiver
    CBfunction = asFunctionName
    SimpleTextField.Open(self as ScriptObject, "TextInputCB", asTitle, asText)
EndFunction

; string function SUPF4SEformatText(string TextToFormat)
;     TextToFormat = MantellaPlugin.StringRemoveWhiteSpace(TextToFormat)
;     return TextToFormat
; endfunction

;Called by MCM hotkeys
;Calls the SimpleTextField menu to get text input from the player, which will then call back to
;the appropriate SetPlayerResponse...Input function below depending on the type of input requested (dialogue response vs game event log)

function GetPlayerTextInput(string entrytype)  ;;Used by MCM hotkeys (see comment above)
    ;Debug.TraceUser("MC", "GetPlayerTextInput called with entrytype: " + entrytype)
    ;disable for VR
    if !isFO4VR && conversation.IsRunning()
        if entryType == "playerResponseTextEntry" ; && conversation._does_accept_player_input
            GetTextInput(conversation as ScriptObject,"SetPlayerResponseTextInput","Enter Mantella text dialogue")
        elseif entryType == "gameEventEntry"
            GetTextInput(conversation as ScriptObject, "SetGameEventTextInput","Enter Mantella a new game event log")
        elseif entryType == "playerResponseTextAndVisionEntry"
            GetTextInput(conversation as ScriptObject, "SetPlayerResponseTextAndVisionInput","Enter Mantella text dialogue")
        endif
    endif
endFunction


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;   LLM Function Calling Functions   ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; Actor[] Function GetFunctionInferenceActorList()
;     return ScanAndReturnNearbyActors(MantellaFunctionNPCCollectionQuest ,MantellaFunctionNPCCollection, true)
; Endfunction

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;   Tutorial Functions   ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

Function ResetTutorial()  ;;Unused (not called anywhere in these 5 scripts)
    while Utility.IsInMenuMode()        ; Wait for MCM
        Utility.Wait(0.5)
    EndWhile
    ;Debug.Notification("Reset tutorial")
    Utility.Wait(2.0)
    ;TriggerTutorialVariables(true)
    ;doTutorialIntro()
Endfunction
