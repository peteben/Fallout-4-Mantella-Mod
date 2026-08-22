Scriptname MantellaConstants extends Quest hidden

int property HTTP_PORT = 4999 auto
string property HTTP_ROUTE_MAIN = "Mantella" autoReadOnly
string property HTTP_ROUTE_STT = "stt" autoReadOnly  ;;Unused

string property HTTP_ERROR = "F4SE_HTTP_error" autoReadOnly

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; JSON keys for communication ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

string property PREFIX = "mantella_" autoReadOnly  ;;Unused
string property KEY_REQUESTTYPE = "mantella_request_type" autoReadOnly
string property KEY_REPLYTYPE = "mantella_reply_type" autoReadOnly
string property KEY_INPUTTYPE = "mantella_input_type" autoReadOnly

string property KEY_REQUEST_EXTRA_ACTIONS = "mantella_extra_actions" autoReadOnly

;Conversation
string property KEY_REQUESTTYPE_INIT = "mantella_initialize" autoReadOnly
string property KEY_REQUESTTYPE_STARTCONVERSATION = "mantella_start_conversation" autoReadOnly
string property KEY_REQUESTTYPE_CONTINUECONVERSATION = "mantella_continue_conversation" autoReadOnly
string property KEY_REQUESTTYPE_PLAYERINPUT = "mantella_player_input" autoReadOnly
string property KEY_REQUESTTYPE_ENDCONVERSATION = "mantella_end_conversation" autoReadOnly

string property KEY_REPLYTYPE_INITCOMPLETED = "mantella_init_completed" autoReadOnly
string property KEY_REPLYTYPE_STARTCONVERSATIONCOMPLETED = "mantella_start_conversation_completed" autoReadOnly

string property KEY_REPLYTYPE_NPCTALK = "mantella_npc_talk" autoReadOnly
string property KEY_REPLYTYPE_PLAYERTALK = "mantella_player_talk" autoReadOnly
string property KEY_REPLYTYPE_NPCACTION = "mantella_npc_action" autoReadOnly
string property KEY_REPLYTYPE_ENDCONVERSATION = "mantella_end_conversation" autoReadOnly

string property KEY_STARTCONVERSATION_WORLDID = "mantella_worldid" autoReadOnly
string property KEY_STARTCONVERSATION_USENARRATOR = "mantella_use_narrator" autoReadOnly
string property KEY_ENDCONVERSATION_TIMESTAMP = "mantella_end_timestamp" autoReadOnly
string property KEY_CONTINUECONVERSATION_TOPICINFOFILE = "mantella_topicinfofile" autoReadOnly

;Actors
string property KEY_ACTORS = "mantella_actors" autoReadOnly
string property KEY_ACTOR_BASEID = "mantella_actor_baseid" autoReadOnly
string property KEY_ACTOR_REFID = "mantella_actor_refid" autoReadOnly
string property KEY_ACTOR_NAME = "mantella_actor_name" autoReadOnly
string property KEY_ACTOR_GENDER = "mantella_actor_gender" autoReadOnly
string property KEY_ACTOR_RACE = "mantella_actor_race" autoReadOnly
string property KEY_ACTOR_ISPLAYER = "mantella_actor_is_player" autoReadOnly
string property KEY_ACTOR_RELATIONSHIPRANK = "mantella_actor_relationshiprank" autoReadOnly
string property KEY_ACTOR_VOICETYPE = "mantella_actor_voicetype" autoReadOnly
string property KEY_ACTOR_ISINCOMBAT = "mantella_actor_is_in_combat" autoReadOnly
string property KEY_ACTOR_ISENEMY = "mantella_actor_is_enemy" autoReadOnly
string property KEY_ACTOR_CUSTOMVALUES = "mantella_actor_custom_values" autoReadOnly

string property KEY_ACTOR_PC_DESCRIPTION = "mantella_pc_description" autoReadOnly
string property KEY_ACTOR_PC_VOICEPLAYERINPUT = "mantella_pc_voiceplayerinput" autoReadOnly  ;;Unused
string property KEY_ACTOR_PC_VOICEMODEL = "mantella_pc_voicemodel" autoReadOnly  ;;Unused


;sentence
string property KEY_ACTOR_SPEAKER = "mantella_actor_speaker" autoReadOnly
string property KEY_ACTOR_LINETOSPEAK = "mantella_actor_line_to_speak" autoReadOnly
string property KEY_ACTOR_ISNARRATION = "mantella_is_narration" autoReadOnly
string property KEY_ACTOR_VOICEFILE= "mantella_actor_voice_file" autoReadOnly  ;;Unused
string property KEY_ACTOR_DURATION = "mantella_actor_line_duration" autoReadOnly
string property KEY_ACTOR_ACTIONS = "mantella_actor_actions" autoReadOnly

;context
string property KEY_CONTEXT = "mantella_context" autoReadOnly
string property KEY_CONTEXT_LOCATION = "mantella_location" autoReadOnly
string property KEY_CONTEXT_WEATHER = "mantella_weather" autoReadOnly
string property KEY_CONTEXT_WEATHER_ID = "mantella_weather_id" autoReadOnly
string property KEY_CONTEXT_WEATHER_CLASSIFICATION = "mantella_weather_classification" autoReadOnly
string property KEY_CONTEXT_TIME = "mantella_time" autoReadOnly
string property KEY_CONTEXT_GAMEDAYS = "mantella_gamedays" autoReadOnly
string property KEY_CONTEXT_INGAMEEVENTS = "mantella_ingame_events" autoReadOnly
string property KEY_CONTEXT_NEARBYACTORS = "mantella_nearby_actors" autoReadOnly
;OLD F4
string property KEY_CONTEXT_CUSTOMVALUES = "mantella_custom_context_values" autoReadOnly

;player input
string property KEY_REQUESTTYPE_TTS = "mantella_tts" autoReadOnly
string property KEY_INPUT_NAMESINCONVERSATION = "mantella_names_in_conversation" autoReadOnly  ;;Unused
string property KEY_TRANSCRIBE = "mantella_transcribe" autoReadOnly
string property KEY_INPUTTYPE_TEXT = "mantella_text_input" autoReadOnly
string property KEY_INPUTTYPE_MIC = "mantella_mic_input" autoReadOnly
string property KEY_INPUTTYPE_PTT = "mantella_push_to_talk" autoReadOnly

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;       Possible actions      ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;system
string property ACTION_RELOADCONVERSATION = "mantella_reload_conversation" autoReadOnly
string property ACTION_ENDCONVERSATION = "mantella_end_conversation" autoReadOnly
string property ACTION_REMOVECHARACTER = "mantella_remove_character" autoReadOnly

;in-game
string property ACTION_NPC_OFFENDED = "mantella_npc_offended" autoReadOnly  ;;Unused
string property ACTION_NPC_FORGIVEN = "mantella_npc_forgiven" autoReadOnly  ;;Unused
string property ACTION_NPC_FOLLOW = "mantella_npc_follow" autoReadOnly
string property ACTION_NPC_UNFOLLOW = "mantella_npc_unfollow" autoReadOnly  ;;Unused
string property ACTION_NPC_INVENTORY = "mantella_npc_inventory" autoReadOnly
string property ACTION_NPC_BARTER = "mantella_npc_barter" autoReadOnly
string property ACTION_NPC_BRAWL = "mantella_npc_brawl" autoReadOnly  ;;Unused
string property ACTION_NPC_MOVETO = "mantella_npc_moveto" autoReadOnly  ;;Unused
string property ACTION_NPC_TRAVELTO = "mantella_npc_travelto" autoReadOnly  ;;Unused
string property ACTION_NPC_LEADTO = "mantella_npc_leadto" autoReadOnly  ;;Unused
string property ACTION_NPC_CANCELTRAVEL = "mantella_npc_canceltravel" autoReadOnly  ;;Unused
string property ACTION_NPC_TELEPORT = "mantella_npc_teleport" autoReadOnly  ;;Unused
string property ACTION_NPC_WAIT = "mantella_npc_wait" autoReadOnly  ;;Unused
string property ACTION_NPC_LOOT = "mantella_npc_loot" autoReadOnly  ;;Unused
string property ACTION_NPC_COLLECTINGREDIENTS = "mantella_npc_collectingredients" autoReadOnly  ;;Unused
string property ACTION_NPC_CASTSPELL = "mantella_npc_castspell" autoReadOnly  ;;Unused
string property ACTION_NPC_GIVEDIRECTIONS = "mantella_npc_givedirections" autoReadOnly  ;;Unused
string property ACTION_NPC_ADDTOCONVERSATION = "mantella_npc_addtoconversation" autoReadOnly  ;;Unused
string property ACTION_NPC_SHARECONVERSATION = "mantella_npc_shareconversation" autoReadOnly  ;;Unused
string property ACTION_NPC_REPORTCRIME = "mantella_npc_reportcrime" autoReadOnly  ;;Unused
string property ACTION_NPC_ABSOLVECRIME = "mantella_npc_absolvecrime" autoReadOnly  ;;Unused
string property ACTION_NPC_EMOTE = "mantella_npc_emote" autoReadOnly  ;;Unused
string property ACTION_NPC_FLEE = "mantella_npc_flee" autoReadOnly  ;;Unused
;OLD F4
string property ACTION_NPC_MOVETO_NPC = "mantella_move_character_near_npc" autoReadOnly  ;;Unused
string property ACTION_MULTI_MOVETO_NPC = "mantella_move_characters_near_npc" autoReadOnly  ;;Unused
string property ACTION_MAKE_NPC_WAIT = "mantella_make_npc_wait" autoReadOnly  ;;Unused
string property ACTION_MULTI_MAKE_NPC_WAIT = "mantella_multi_make_npc_wait" autoReadOnly  ;;Unused
string property ACTION_NPC_ATTACK_OTHER_NPC = "mantella_npc_attack_other_npc" autoReadOnly  ;;Unused
string property ACTION_MULTI_NPC_ATTACK_OTHER_NPC = "mantella_multi_npc_attack_other_npc" autoReadOnly  ;;Unused
string property ACTION_NPC_LOOT_ITEMS = "mantella_npc_loot_items" autoReadOnly  ;;Unused
string property ACTION_MULTI_NPC_LOOT_ITEMS ="mantella_multi_npc_loot_items" autoReadOnly  ;;Unused
string property ACTION_NPC_HEAL_PLAYER = "mantella_heal_me" autoReadOnly  ;;Unused
string property ACTION_NPC_USE_ITEM = "mantella_npc_use_item_on_target" autoReadOnly  ;;Unused
string property ACTION_MULTI_NPC_USE_ITEM = "mantella_multi_use_item_on_target" autoReadOnly  ;;Unused

;arguments for actions
string property ACTION_IDENTIFIER = "identifier" autoReadOnly
string property ACTION_ARGUMENTS = "arguments" autoReadOnly
string property ACTION_ARG_SOURCE = "source" autoReadOnly  ;;Unused
string property ACTION_ARG_TARGET = "target" autoReadOnly  ;;Unused
string property ACTION_REQUIRES_RESPONSE = "mantella_actions_require_response" autoReadOnly

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;   Special Fallout4 values   ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

string property KEY_CONTEXT_CUSTOMVALUES_PLAYERHEALTH = "mantella_player_health_percent" autoReadOnly  ;;Unused
string property KEY_CONTEXT_CUSTOMVALUES_PLAYERRAD = "mantella_player_rad_percent" autoReadOnly  ;;Unused
string property KEY_CONTEXT_CUSTOMVALUES_VISION_READY = "mantella_vision_ready" autoReadOnly  ;;Unused
string property KEY_CONTEXT_CUSTOMVALUES_VISION_RES = "mantella_vision_resolution" autoReadOnly  ;;Unused
string property KEY_CONTEXT_CUSTOMVALUES_VISION_RESIZE = "mantella_vision_resize" autoReadOnly  ;;Unused
string property KEY_ACTOR_CUSTOMVALUES_VISION_HINTSNAMEARRAY = "mantella_vision_hints_names" autoReadOnly
string property KEY_ACTOR_CUSTOMVALUES_VISION_HINTSDISTANCEARRAY = "mantella_vision_hints_distance" autoReadOnly
string property KEY_ACTOR_CUSTOMVALUES_POSX = "mantella_actor_pos_x" autoReadOnly  ;;Unused
string property KEY_ACTOR_CUSTOMVALUES_POSY = "mantella_actor_pos_y" autoReadOnly  ;;Unused
;string property KEY_CONTEXT_CUSTOMVALUES_ACTORS_ALL_FOLLOWERS = "mantella_actors_all_followers" autoReadOnly
;string property KEY_CONTEXT_CUSTOMVALUES_ACTORS_ALL_SETTLERS = "mantella_actors_all_settlers" autoReadOnly
;string property KEY_CONTEXT_CUSTOMVALUES_ACTORS_ALL_GENERICNPCS = "mantella_actors_all_generic_npcs" autoReadOnly
string property KEY_CONTEXT_CUSTOMVALUES_ACTORS_AT_LEAST_ONE_FOLLOWER = "mantella_actors_one_follower" autoReadOnly  ;;Unused
string property KEY_CONTEXT_CUSTOMVALUES_ACTORS_AT_LEAST_ONE_SETTLER = "mantella_actors_one_settler" autoReadOnly  ;;Unused
string property KEY_CONTEXT_CUSTOMVALUES_ACTORS_AT_LEAST_ONE_GENERIC = "mantella_actors_one_generic" autoReadOnly  ;;Unused

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;       Functions Inference Value (MantellaMod -> Mantella Software)      ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;; OUPUT ('Mantella Mod -> Mantella Software') ;;;;;;;;;;;;;
string property KEY_CONTEXT_CUSTOMVALUES_FUNCTIONS_ENABLED = "mantella_function_enabled" autoReadOnly  ;;Unused

string property KEY_CONTEXT_CUSTOMVALUES_FUNCTIONS_NPCDISPLAYNAMES = "mantella_function_npc_display_names" autoReadOnly  ;;Unused
string property KEY_CONTEXT_CUSTOMVALUES_FUNCTIONS_NPCDISTANCES = "mantella_function_npc_distances" autoReadOnly  ;;Unused
string property KEY_CONTEXT_CUSTOMVALUES_FUNCTIONS_NPCIDS = "mantella_function_npc_ids" autoReadOnly  ;;Unused
;string property KEY_CONTEXT_CUSTOMVALUES_FUNCTIONS_STIMPACKCOUNT = "mantella_function_npc_stimpackcount" autoReadOnly
string property KEY_CONTEXT_CUSTOMVALUES_FUNCTIONS_STIMPAK_ACTOR_LIST = "mantella_function_npc_stimpak_list" autoReadOnly  ;;Unused
string property KEY_CONTEXT_CUSTOMVALUES_FUNCTIONS_RADAWAY_ACTOR_LIST = "mantella_function_npc_radaway_list" autoReadOnly  ;;Unused

;;;;;;;;;;; INPUT ('Mantella Mod <- Mantella Software') ;;;;;;;;;;;;;

string property FUNCTION_DATA_TARGET_IDS = "mantella_function_data_target_ids" autoReadOnly  ;;Unused
string property FUNCTION_DATA_TARGET_NAMES = "mantella_function_data_target_names" autoReadOnly  ;;Unused
string property FUNCTION_DATA_SOURCE_IDS = "mantella_function_data_source_ids"autoReadOnly  ;;Unused
string property FUNCTION_DATA_MODES = "mantella_function_data_modes" autoReadOnly  ;;Unused