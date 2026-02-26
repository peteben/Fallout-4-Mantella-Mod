Scriptname MantellaIsTalkingEffectScript extends ActiveMagicEffect  

Quest Property MantellaConversationQuest Auto

float startTime

Event OnEffectStart(Actor akTarget, Actor akCaster)
    ;startTime = Utility.GetCurrentRealTime()
    (MantellaConversationQuest as MantellaConversation).SetIsTalking(true)
EndEvent

Event OnEffectFinish(Actor akTarget, Actor akCaster)
    ;float duration = Utility.GetCurrentRealTime() - startTime
    ;Debug.TraceUser("MC", akTarget.GetDisplayName() + " finished after " + duration + " seconds")
    (MantellaConversationQuest as MantellaConversation).SetIsTalking(false)
EndEvent
