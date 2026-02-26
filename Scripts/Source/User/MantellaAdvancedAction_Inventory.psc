Scriptname MantellaAdvancedAction_Inventory extends Quest Hidden 

Actor PlayerRef 
MantellaRepository  repository 
MantellaConstants  mConsts 
MantellaInterface  EventInterface 
MantellaConversation  conversation 

Function InitVars()
    PlayerRef = Game.GetPlayer()
    Form conversationForm = Game.GetFormFromFile(0x066FBB, "Mantella.esp") ; MantellaConversation
    Form questForm = Game.GetFormFromFile(0x000F99, "Mantella.esp") ; MantellaQuest

    conversation = conversationForm as MantellaConversation
    repository = questForm as MantellaRepository
    mConsts =conversationForm as MantellaConstants
    EventInterface = conversationForm as MantellaInterface
    Debug.TraceUser("MC", "Inventory Variables initialized: conversation=" + conversation + ", repository=" + repository + ", mConsts=" + mConsts + ", EventInterface=" + EventInterface)
EndFunction

event OnInit()
    InitVars()
    string eventName = EventInterface.EVENT_ADVANCED_ACTIONS_PREFIX + mConsts.ACTION_NPC_INVENTORY
    
    Debug.OpenUserLog("MC")
    Debug.TraceUser("MC", "Inventory Registering for inventory event: " + eventName)
    RegisterForExternalEvent(eventName, "OnNpcInventoryAdvancedActionReceived")
EndEvent

Event OnQuestInit()
    Debug.TraceUser("MC", "Inventory OnQuestInit called in MantellaAdvancedAction_Inventory")
    ;OnInit() ; Ensure that the event registration happens on quest init as well, in case the quest is added after game start
EndEvent

Function OnNpcInventoryAdvancedActionReceived(int speakerID, string unused, int argumentsHandle)
    Actor speaker = None
    if speakerID != 0
        speaker = Game.GetForm(speakerID) as Actor
        Debug.TraceUser("MC", "Inventory Speaker is: " + speaker)
    else
        Debug.TraceUser("MC", "Inventory Speaker is None")
    EndIf

    if  argumentsHandle == -1
        Debug.TraceUser("MC", "Received inventory legacy action event")
        return
    Else
        Debug.TraceUser("MC", "Received inventory advanced action event " + unused)
        ; Extract NPC names from parameters
        string sourceName = MantellaPlugin.getString(argumentsHandle, mConsts.ACTION_ARG_SOURCE)
        ; Only one NPC can open their inventory per response
        Actor sourceActor = conversation.GetActorByName(sourceName)

        NpcInventory(sourceActor)
    EndIf
endFunction


Function NpcInventory(Actor source)
    if (source)
        source.OpenInventory(true)
        EventInterface.AddMantellaEvent(source.GetDisplayName() + "'s inventory opened.")
        EventInterface.MarkActionResponseCompleted(mConsts.ACTION_NPC_INVENTORY)
    endif
EndFunction