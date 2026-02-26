Scriptname MantellaInterface extends Quest

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;    Mod event identifiers    ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; Prefix for any events raised by Mantella when it receives an action. See example below for usage
string property EVENT_ACTIONS_PREFIX = "MantellaConversation_Action_" autoReadOnly
string property EVENT_ADVANCED_ACTIONS_PREFIX = "MantellaConversation_Advanced_Action_" autoReadOnly

; Called when a conversation is started
string property EVENT_CONVERSATION_STARTED = "MantellaConversation_Started" autoReadOnly
; Called when a conversation is ended
string property EVENT_CONVERSATION_ENDED = "MantellaConversation_Ended" autoReadOnly
; Called when an actor is added to the conversation, actor is passed to event as Form
string property EVENT_CONVERSATION_NPC_ADDED = "MantellaConversation_NPC_Added" autoReadOnly
; Called when an actor is removed from the conversation, actor is passed to event as Form
string property EVENT_CONVERSATION_NPC_REMOVED = "MantellaConversation_NPC_Removed" autoReadOnly

; Mantella itself listens for this event to add ingame events for the next user message. Don't use this directly, use the 'AddMantellaEvent' function below
string property EVENT_ADD_EVENT = "MantellaAddEvent" autoReadOnly

; When an action requires a response (in-game events added), Mantella will wait for this event before continuing the conversation
string property EVENT_ACTION_RESPONSE_COMPLETED = "Mantella_ActionResponseCompleted" autoReadOnly

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;           Example           ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;Scriptname MyExampleMantellaPlugin extends Quest

;MantellaInterface property EventInterface autoReadOnly

; Function OnInit()
;     RegisterForExternalEvent(EventInterface.EVENT_ACTIONS_PREFIX + "myActionIdentifier","OnMyActionIdentifierReceived")
; EndFunction

; event OnMyActionIdentifierReceived(int speakerID, string unused, int handle)
;    Actor speaker = None
;     if speakerID != 0
;         speaker = Game.GetForm(speakerID) as Actor
;     EndIf

;     Do whatever your action needs to do here

;     Let Mantella know what just happened
;     EventInterface.AddMantellaEvent(speaker.GetDisplayName() + "just performed MyActionIdentifier")
;     EventInterface.MarkActionResponseCompleted("myActionIdentifier") ; If this action requires the in-game event to be seen before continuing the conversatio
; endEvent

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;      Add Mantella Event     ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

Function AddMantellaEvent(string text)
    MantellaPlugin.SendMantellaEvent(EVENT_ADD_EVENT, none, text, 0)
EndFunction


Function MarkActionResponseCompleted(string actionIdentifier)
    MantellaPlugin.SendMantellaEvent(EVENT_ACTION_RESPONSE_COMPLETED, none, actionIdentifier, 0)
EndFunction