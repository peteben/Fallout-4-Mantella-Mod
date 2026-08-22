Scriptname MantellaListenerScript extends ReferenceAlias
; ---------------------------------------------
; KGTemplates:GivePlayerItemsOnModStart.psc - by kinggath
; ---------------------------------------------
; Reusage Rights ------------------------------
; You are free to use this script or portions of it in your own mods, provided you give me credit in your description and maintain this section of comments in any released source code (which includes the IMPORTED SCRIPT CREDIT section to give credit to anyone in the associated Import scripts below).
; 
; Warning !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
; Do not directly recompile this script for redistribution without first renaming it to avoid compatibility issues with the mod this came from.
; 
; IMPORTED SCRIPT CREDITS
; N/A
; ---------------------------------------------

Import F4SE

Spell property MantellaSpell auto  ;;Unused
Actor property PlayerRef auto
Weapon property MantellaGun auto
Holotape property MantellaSettingsHolotape auto  ;;Unused
;Quest Property MantellaActorList  Auto                  ;Radiants ; unused
ReferenceAlias Property PotentialActor1  Auto  ;;Unused
ReferenceAlias Property PotentialActor2  Auto  ;;Unused
MantellaRepository property repository auto
MantellaConversation property conversation auto

MantellaConstants Property Constants Auto Const Mandatory
MantellaInterface Property EventInterface Auto Const Mandatory

Keyword Property AmmoKeyword Auto Const
;GlobalVariable property MantellaRadiantEnabled auto
;GlobalVariable property MantellaRadiantDistance auto
;GlobalVariable property MantellaRadiantFrequency auto
int RadiantFrequencyTimerID=1
int CleanupconversationTimer=2
int DictionaryCleanTimer=3

Float meterUnits = 78.74
Worldspace PrewarWorldspace
bool itemsGiven
Quest Property MantellaNPCCollectionQuest Auto 
RefCollectionAlias Property MantellaNPCCollection  Auto
Faction Property MantellaFunctionTargetFaction Auto
Message property MantellaTutorialMessage auto  ;;Unused

FormList property SurvivalItemsList auto 

bool OLDRadiants = false const

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;   Initialization events and functions  ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

Event OnInit ()
	PrewarWorldspace = Game.GetFormFromFile(0x000A7FF4, "Fallout4.esm") as Worldspace
    LoadMantellaEvents()
	TryToGiveItems()
    
EndEvent

Event OnPlayerTeleport()
    if !itemsGiven
	    TryToGiveItems()
    endif
    If !(conversation.IsRunning())
        Actor[] ActorsInCell = repository.ScanAndReturnNearbyActors(MantellaNPCCollectionQuest, MantellaNPCCollection, false)
        repository.DispelAllMantellaMagicEffectsFromActors(ActorsInCell)
        repository.RemoveFactionFromActors(ActorsInCell,MantellaFunctionTargetFaction)
    endif
EndEvent

Function TryToGiveItems()
		;UnregisterForPlayerTeleport()  ;not nessary to interact with this anymore as it's handled in LoadMantellaEvents()
        ;showAndResolveTutorialMessage()
        ;repository.doTutorialIntro()
        repository.allowCrosshairTracking = !repository.isFO4VR
		PlayerRef.AddItem(MantellaGun, 1, false)
        ;PlayerRef.AddItem(MantellaSettingsHolotape, 1, false)
        If !(PlayerRef.HasPerk(repository.ActivatePerk))
            PlayerRef.AddPerk(repository.ActivatePerk, False)
        Endif
        itemsGiven=true
        StartTimer(repository.radiantFrequency,RadiantFrequencyTimerID)   
EndFunction



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;   Message and tutorial resolution  ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; function showAndResolveTutorialMessage()
;     int aButton=MantellaTutorialMessage.show()
;     if aButton==1 ;player chose no
;         repository.TriggerTutorialVariables(false)
;         Debug.MessageBox("You can reactivate the tutorial at any time by using the holotape in main settings.")
;     elseif aButton==0 ;player chose yes
;         repository.TriggerTutorialVariables(true)
        
;     endif 
; Endfunction




;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;   Events and functions at player load  ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

Event OnPlayerLoadGame()
    Debug.OpenUserLog("MC")
    LoadMantellaEvents()
    conversation.OnLoadGame()
    repository.OnLoadGame()
    EndEvent

Function LoadMantellaEvents()
    Debug.TraceUser("MC","LoadMantellaEvents")
    conversation.SetGameRefs()
    ;repository.reloadKeys()
    registerForPlayerEvents()
    ;Will clean up all all conversation loops if they're still occuring
    ; repository.endFlagMantellaConversationOne = True    
    StartTimer(3000,DictionaryCleanTimer) 
    If (conversation.IsRunning())   
        Actor[] ActorsInCell = repository.ScanAndReturnNearbyActors(MantellaNPCCollectionQuest, MantellaNPCCollection, false)
        repository.DispelAllMantellaMagicEffectsFromActors(ActorsInCell)
        repository.RemoveFactionFromActors(ActorsInCell,MantellaFunctionTargetFaction)
        conversation.conversationIsEnding=false  ;just here as a safety to prevent locking out the player out of initiating conversations
        conversation.EndConversation();Should there still be a running conversation after a load, end it
        StartTimer(5,CleanupconversationTimer) ;Start a timmer to make second hard reset if conversation is still running after
    EndIf
        Worldspace PlayerWorldspace = PlayerRef.GetWorldspace()
    if(PlayerWorldspace != PrewarWorldspace && PlayerWorldspace != None)
        StartTimer(repository.radiantFrequency,RadiantFrequencyTimerID)   
    endif
    CheckGameVersionForMantella()
Endfunction

Function CheckGameVersionForMantella()
    string MantellaVersion="Mantella.esp 0.14.0"
    if  !IsF4SEProperlyInstalled() 
        debug.messagebox("F4SE not properly installed, Mantella will not work correctly")
    endif
    repository.currentFO4version = Debug.GetVersionNumber()
    Debug.Notification("Version " + repository.currentFO4version)
    repository.isFO4VR = false
    if repository.currentFO4version == "1.10.984.0"
        debug.notification("Currently running "+ MantellaVersion + " NG")
    elseif repository.currentFO4version == "1.11.221.0"
        debug.notification("Currently running "+ MantellaVersion + " AE")
    elseif repository.currentFO4version == "1.10.163.0"
        debug.notification("Currently running "+ MantellaVersion)
    elseif repository.currentFO4version == "1.2.72.0"
        repository.isFO4VR = true
        debug.notification("Currently running "+ MantellaVersion+" VR")
        repository.microphoneEnabled = repository.isFO4VR
    else
        debug.messagebox("The current FO4 version doesn't support Mantella.")
    endif
    repository.isFlat = ! repository.isFO4VR
Endfunction

bool Function IsF4SEProperlyInstalled() 
    int major = F4SE.GetVersion()
    int minor = F4SE.GetVersionMinor()
    int beta = F4SE.GetVersionBeta()
    int release = F4SE.GetVersionRelease()

    return (major != 0 || minor != 0 || beta != 0 || release != 0)
EndFunction

Function registerForPlayerEvents()
    ;resets AddInventoryEventFilter, necessary for OnItemAdded & OnItemRemoved to work properl
    RemoveAllInventoryEventFilters()
    AddInventoryEventFilter(none) 
    ;Register for player sleep events
    RegisterForPlayerSleep()
    ;resets RegisterForHitEvent & RegisterForRadiationDamageEvent at load, necessary for Onhit to work properly
    UnregisterForAllHitEvents()
    RegisterForHitEvent(PlayerRef)
    UnregisterForAllRadiationDamageEvents()
    RegisterForRadiationDamageEvent(PlayerRef)
    RegisterForPlayerTeleport()
Endfunction

Function CheckForRadiant()
    ;Debug.traceUser("MC", "CheckFor radiant")
    if !conversation.IsRunning()                    ; Must be enabled in MCM for radiant OR approaches
        if repository.radiantEnabled
            ;Debug.traceuser("MC", "Get actorList")
            Actor [] actorlist = repository.ScanNearbyActors(repository.radiantDistance, repository.radiantQuantity)    ; user-set maximum number of participants
            int randomPct = Utility.RandomInt(1, 100)
            int actorsFound = actorlist.Length

            if actorsFound > 1 && (!repository.approachEnabled || randomPct <= repository.triggerRatio)
                ; Radiant conversation
                Actor [] talkers =  new Actor [0]
                float dist = repository.NearbyActorDistance.GetValue()
                int i = 0
                while i < actorlist.Length
                    Float rand = Utility.RandomFloat(0.3)       ; Random selection of actors
                    if rand > 0.5
                        talkers.Add(actorlist[i])       ; Keep
                    EndIf
                    i = i + 1
                EndWhile
                if talkers.Length > 1           ; Need at least 2
                    string names
                    i = 0
                    while i < talkers.Length
                        names =  names + talkers[i].GetDisplayName()
                        if i < talkers.Length
                            names += ", "
                        EndIf 
                        i += 1
                    EndWhile

                    Debug.TraceUser("MC", "Starting with [" + talkers.Length + "]: " + names)
                    conversation.Start()
                    conversation.StartConversation(talkers)
                EndIf
            ElseIf repository.approachEnabled && actorsFound > 0       ; Approach
                ;Debug.TraceUser("MC","Approach: " + actorlist[0].GetDisplayName() )
                Actor[] actors = new Actor[2]
                actors[0] = PlayerRef
                actors[1] = actorlist[0]

                conversation.Start()
                Debug.Notification(Actors[1].GetDisplayName() + " approaches...")
                int hour =  conversation.GetCurrentHourOfDay()
                if hour > 5 && hour < 12
                    conversation.approachAutoResponse = "Good morning"
                ElseIf hour > 11 && hour < 19
                    conversation.approachAutoResponse = "Good afternoon"
                ElseIf hour > 18 && hour <= 23
                    conversation.approachAutoResponse = "Good evening"
                Else
                    conversation.approachAutoResponse = "Good night"
                Endif
                conversation.approachAutoResponse += ", " + actorlist[0].GetDisplayName()
                Debug.TraceUser("MC", "starting approach conversation")
                Debug.TraceUser("MC", "Adding approach event")
                int sex = actors[1].GetActorBase().GetSex()
                string prefix

                if sex ==1
                    prefix = "her "
                ElseIf sex == 0
                    prefix = "his "
                Else
                    prefix = "it's "
                Endif

                string msg = Actors[1].GetDisplayName() + " approaches " + PlayerRef.GetDisplayName() + " with something on "
                msg += prefix + "mind"
                conversation.AddIngameEvent(msg)
                conversation.StartConversation(actors)
                actors[1].SetLookAt(actors[0])
                actors[0].SetLookAt(actors[1])
                MantellaPlugin.SendMantellaEvent(EventInterface.EVENT_ADVANCED_ACTIONS_PREFIX + constants.ACTION_NPC_FOLLOW, actors[1],"", -1)
                
                ;conversation.TriggerApproachMoveAction(Actor1)
            EndIf
        endIf
    endIf
EndFunction

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;   Timer management  ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
bool conversationActive

Event Ontimer(int TimerID)
   ;debug.notification("timer " +TimerID)
    if TimerID==RadiantFrequencyTimerID
        if conversation.IsRunning()
            ;Debug.TraceUSer("MC", "IsRunning")
            conversationActive = true
        else
            ;Debug.TraceUSer("MC", "NotRunning " + conversationActive)
            if !conversationActive      ; Ensure we wait at least radiantFrequency seconds, max 2x radiantFrequency
                CheckForRadiant()
            Endif
            conversationActive = false
        Endif

        StartTimer(repository.radiantFrequency,RadiantFrequencyTimerID)   
    elseif TimerID==CleanupconversationTimer 
        if conversation.IsRunning() ;attempts to make a hard reset of the conversation if it's still going on for some reason
            ;previous conversation detected, forcing conversation to end.
            debug.notification("Previous conversation detected on load : Cleaning up.")
            Conversation.CleanupConversation()
            conversation.conversationIsEnding = false
        endif
    elseif TimerID==DictionaryCleanTimer 
        if conversation.IsRunning() 
            StartTimer(3000,DictionaryCleanTimer) 
            ;debug.Notification("Can't empty dictionaries because there's an ongoing conversation")
        else
            MantellaPlugin.clearAllDictionaries() ;This function might lead to crash, monitor if players are reporting crashes
            StartTimer(3000,DictionaryCleanTimer) 
            ;debug.Notification("Emptying dictionaries after a long period of inactivity to prevent memory leaks")
        endif
    endif
EndEvent

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;   Game event listeners  ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

Event OnItemAdded(Form akBaseItem, int aiItemCount, ObjectReference akItemReference, ObjectReference akSourceContainer)
    if Repository.playerTrackingOnItemAdded
        string desc = akBaseItem as String
        string sourceName = akSourceContainer.getbaseobject().getname()
        bool isHC = SurvivalItemsList.Find(akBaseItem) >= 0                 ; Survival item (hunger, thirst, etc.)
        ;Debug.TraceUser("MC", "Survival item ["+isHC+"]: " + desc)

        if sourceName != "Power Armor" &&  !isHC    ;to prevent gameevent spam from the player entering power armors and survival items
            string itemName = akBaseItem.GetName()
            string itemPickedUpMessage = ""
            if itemName == "Powered Armor Frame" 
                itemPickedUpMessage = "The player entered power armor."
            else
                if sourceName != "" 
                    itemPickedUpMessage = "The player picked up " + itemName + " from " + sourceName + "."
                Else
                    itemPickedUpMessage = "The player picked up " + itemName + "."
                endIf
            Endif
            conversation.AddIngameEvent(itemPickedUpMessage)
        endif
    endif
EndEvent

Event OnItemRemoved(Form akBaseItem, int aiItemCount, ObjectReference akItemReference, ObjectReference akDestContainer)
    if Repository.playerTrackingOnItemRemoved
        bool isHC = SurvivalItemsList.Find(akBaseItem) >= 0
        string destName = akDestContainer.getbaseobject().getname()

        if destName != "Power Armor" && !isHC       ;to prevent gameevent spam from the player exiting power armors 
            string itemName = akBaseItem.GetName()
            string itemDroppedMessage = ""
            if itemName == "Powered Armor Frame" 
                itemDroppedMessage = "The player exited power armor."
            else
                if destName != "" 
                    itemDroppedMessage = "The player placed " + itemName + " in/on " + destName + "."
                    conversation.AddIngameEvent(itemDroppedMessage)
                Elseif akBaseItem.HasKeyword(AmmoKeyword)
                    ;filtering out ammo events to prevent spam and confusion for the LLM
                else
                    itemDroppedMessage = "The player dropped " + itemName + "."
                    conversation.AddIngameEvent(itemDroppedMessage)
                endIf
            Endif
            
        endif
    endif
endEvent



String lastHitSource = ""
String lastAggressor = ""
Int timesHitSameAggressorSource = 0
Event OnHit(ObjectReference akTarget, ObjectReference akAggressor, Form akSource, Projectile akProjectile, bool abPowerAttack, bool abSneakAttack, bool abBashAttack, bool abHitBlocked, string apMaterial)
    if repository.playerTrackingOnHit
        string aggressor = akAggressor.getdisplayname()
        string hitSource = akSource.getname()

        ; avoid writing events too often (continuous spells record very frequently)
        ; if the actor and weapon hasn't changed, only record the event every 5 hits
        if ((hitSource != lastHitSource) && (aggressor != lastAggressor)) || (timesHitSameAggressorSource > 5)
            lastHitSource = hitSource
            lastAggressor = aggressor
            timesHitSameAggressorSource = 0

            if (hitSource == "None") || (hitSource == "")
                ;Debug.MessageBox(aggressor + " punched the player.")
                conversation.AddIngameEvent(aggressor + " punched the player.")
            else
                if aggressor == PlayerRef.getdisplayname()
                    if playerref.getleveledactorbase().getsex() == 0
                        conversation.AddIngameEvent("The player hit himself with " + hitSource+".")
                    else
                        conversation.AddIngameEvent("The player hit herself with " + hitSource+".")
                    endIf
                else
                    conversation.AddIngameEvent(aggressor + " hit the player with " + hitSource+".")
                endif
            endIf
        else
            timesHitSameAggressorSource += 1
        endIf
    endif
    ;RegisterForHitEvent necessary for Onhit to work properly
    RegisterForHitEvent(PlayerRef)
EndEvent

Event OnLocationChange(Location akOldLoc, Location akNewLoc)
    ; check if radiant dialogue is playing, and end conversation if the player leaves the area
    If (conversation.IsRunning() && !conversation.IsPlayerInConversation())
        conversation.EndConversation()
    EndIf

    if repository.playerTrackingOnLocationChange
        String currLoc = (akNewLoc as form).getname()
        if currLoc == ""
            currLoc = "Commonwealth"
        endIf
        Debug.MessageBox("Current location is now " + currLoc)
        Debug.TraceUser("MC", "Location is now " + currLoc+ ".")
        conversation.AddIngameEvent("Current location is now " + currLoc+ ".")
    endif
endEvent

Event OnItemEquipped(Form akBaseObject, ObjectReference akReference)
    if repository.playerTrackingOnObjectEquipped
        bool isHC = SurvivalItemsList.Find(akBaseObject) >= 0
        string itemEquipped = akBaseObject.getname()
        ;Debug.MessageBox("The player equipped " + itemEquipped)
        if itemEquipped != "Mantella" && !isHC
            conversation.AddIngameEvent("The player equipped " + itemEquipped + ".")
        endif
    endif
endEvent


Event OnItemUnequipped (Form akBaseObject, ObjectReference akReference)
    if repository.playerTrackingOnObjectUnequipped
        string itemUnequipped = akBaseObject.getname()
        bool isHC = SurvivalItemsList.Find(akBaseObject) >= 0
        ;Debug.MessageBox("The player unequipped " + itemUnequipped)
        if itemUnequipped != "Mantella Enchantment" && itemUnequipped != "Mantella" && !isHC
            conversation.AddIngameEvent("The player unequipped " + itemUnequipped + ".")
        Endif
    endif
endEvent

Event OnSit(ObjectReference akFurniture)
    if repository.playerTrackingOnSit
        ;Debug.MessageBox("The player sat down.")
        String furnitureName = akFurniture.getbaseobject().getname()
        if furnitureName != "Power Armor"
            conversation.AddIngameEvent("The player rested on / used a(n) "+furnitureName+ ".")
        endif
    endif
endEvent


Event OnGetUp(ObjectReference akFurniture)
    if repository.playerTrackingOnGetUp
        ;Debug.MessageBox("The player stood up.")
        String furnitureName = akFurniture.getbaseobject().getname()
        if furnitureName != "Power Armor"
            conversation.AddIngameEvent("The player stood up from a(n) "+furnitureName+ ".")
        endif    
    endif
EndEvent


Event OnDying(Actor akKiller)
    If (conversation.IsRunning())
        conversation.EndConversation()
    EndIf
EndEvent

string lastWeaponFired =""
Event OnPlayerFireWeapon(Form akBaseObject)
    if repository.playerTrackingFireWeapon 
        string weaponName=akBaseObject.getname()
        if weaponName!="Mantella"
            if lastWeaponFired!=akBaseObject && !repository.EventFireWeaponSpamBlocker
                if weaponName!=""
                    conversation.AddIngameEvent("The player used their "+weaponName+" weapon.")
                else
                    conversation.AddIngameEvent("The player used an unarmed attack.")
                endif
                lastWeaponFired=akBaseObject
                repository.WeaponFiredCount+=1
                if repository.WeaponFiredCount>=3
                    repository.EventFireWeaponSpamBlocker=true
                    repository.WeaponFiredCount=0
                endif
            endif    
        endif
    endif
endEvent

Event OnRadiationDamage(ObjectReference akTarget, bool abIngested)
    if repository.playerTrackingRadiationDamage
        if ( abIngested )
            conversation.AddIngameEvent("The player consumed irradiated sustenance.")
        elseif repository.EventRadiationDamageSpamBlocker!=true
            conversation.AddIngameEvent("The player took damage from radiation exposure.")
            repository.EventRadiationDamageSpamBlocker=true
        endif
    endif
    RegisterForRadiationDamageEvent(PlayerRef)
EndEvent

float sleepstartTime
Event OnPlayerSleepStart(float afSleepStartTime, float afDesiredSleepEndTime, ObjectReference akBed)
    sleepstartTime=afSleepStartTime
EndEvent

Event OnPlayerSleepStop(bool abInterrupted, ObjectReference akBed)
    if repository.playerTrackingSleep
        float timeSlept= Utility.GetCurrentGameTime()-sleepstartTime
        string sleepMessage
        string bedName=akBed.getbaseobject().getname()
        string messagePrefix
        if abInterrupted
            messagePrefix="The player's sleep in a "+bedName+" was interrupted after "
        else
            messagePrefix="The player slept in a "+bedName+" for "
        endif
        ;if timeSlept>1
        ;    int daysPassed=Math.floor(timeSlept)
        ;    float remainingDayFraction=(timeSlept- daysPassed)
        ;    int hoursPassed=Math.Floor(remainingDayFraction*24)
        ;    sleepMessage=messagePrefix+daysPassed+" days and "+hoursPassed+" hours."
        ;    SUP_F4SE.WriteStringToFile("_mantella_in_game_events.txt", sleepMessage, 2)
        ;Else
            int hoursPassed=Math.Floor(timeSlept*24)
            sleepMessage=messagePrefix+hoursPassed+" hours."
            conversation.AddIngameEvent(sleepMessage)
        ;endif
    endif
EndEvent

Event OnCripple(ActorValue akActorValue, bool abCrippled)
    if repository.playerTrackingCripple
        string messageSuffix=" is crippled."
        if !abCrippled
            messageSuffix=" is now healed."
        endif
        if akActorValue
            conversation.AddIngameEvent("The player's "+akActorValue.getname()+messageSuffix)
        endif
    endif

EndEvent
Event OnPlayerHealTeammate(Actor akTeammate)
    if repository.playerTrackingHealTeammate
        string messageEvent="The player has healed "+akTeammate.getdisplayname()+"."
        conversation.AddIngameEvent(messageEvent)
    endif
EndEvent

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;   Math functions  ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

Float Function ConvertMeterToGameUnits(Float meter)  ;;Unused (not called anywhere in these 5 scripts)
    Return Meter * meterUnits
EndFunction

Float Function ConvertGameUnitsToMeter(Float gameUnits)  ;;Unused (not called anywhere in these 5 scripts)
    Return gameUnits / meterUnits
EndFunction

