Scriptname MantellaEquipmentDescriber extends Quest

string property Equipment = "mantella_equipment" autoReadOnly
string property Body = "body" autoReadOnly          ;Armor, clothes
;string property Head = "head" autoReadOnly
;string property hands = "hands" autoReadOnly
;string property Feet = "feet" autoReadOnly
;string property Amulet = "amulet" autoReadOnly
string property RightHand = "righthand" autoReadOnly
;string property LeftHand = "lefthand" autoReadOnly ;weapon

MantellaRepository property repository auto

FormList property ArmorKeywords auto
;Ea8B Trapper
;10815 Marine
;26B86 Disciples
; 2744A Pack
;287CF Operators

; int[] _armorSlots
; string[] _constants
; string[] _spells

string [] armorNames

event OnInit()
    Debug.TraceUser("MC", "EquipmentDescriber OnInit ArmorKeywords: " + ArmorKeywords)

    armorNames =  new string[10]
    armorNames[0] = "Combat"            ; base game armors
    armorNames[1] = "Leather"
    armorNames[2] = "Metal"
    armorNames[3] = "Raider"
    armorNames[4] = "Synth"
    armorNames[5] = "T-45"            ; base game armors
    armorNames[6] = "T-51"
    armorNames[7] = "T-60"
    armorNames[8] = "X-01"
    armorNames[9] = "Raider"

    if Game.IsPluginInstalled("DLCCoast.esm")
        Keyword trapper = Game.GetFormFromFile(0x0Ea8B, "DLCCoast.esm") as Keyword
        Keyword marine = Game.GetFormFromFile(0x010815, "DLCCoast.esm") as Keyword
        ArmorKeywords.AddForm(trapper)
        ArmorKeywords.AddForm(marine)
        armorNames.Add("Trapper")
        armorNames.Add("Marine")
    Endif
    if Game.IsPluginInstalled("DLCNukaWorld")
        Keyword disciples = Game.GetFormFromFile(0x026B86, "DLCNukaWorld.esm") as Keyword
        Keyword pack = Game.GetFormFromFile(0x02744A, "DLCNukaWorld.esm") as Keyword
        Keyword operators = Game.GetFormFromFile(0x0287CF, "DLCNukaWorld.esm") as Keyword
        ArmorKeywords.AddForm(disciples)
        ArmorKeywords.AddForm(pack)
        ArmorKeywords.AddForm(operators)
        armorNames.Add("Disciples")
        armorNames.Add("Pack")
        armorNames.Add("Operators")
    EndIf

endEvent

string Function GetArmorLabel(Armor piece)
    Keyword[] kws = piece.GetKeywords()
    int i = 0

    While i < kws.Length
        int idx = ArmorKeywords.Find(kws[i])
        if idx >= 0
            ;Debug.TraceUser("MC", "Idx =" + idx)
            return armorNames[idx]
        Endif
        i += 1
    EndWhile

    return ""
EndFunction

string Function DescribeArmor(Actor user)
    int i = 11
    int numPieces = 0
    string armorType = ""
    bool identical = true
    string matching
    string complete
    int showArmorVar
    bool isPower = false
    bool isDrawn = user.IsWeaponDrawn()
    string powerStr = ""

    OnInit()

    ;Debug.TraceUser("MC", "Formlist " + ArmorKeywords.GetSize())
    while I < 16
        Actor:WornItem armorItem = user.GetWornItem(i)
        Armor armorPiece = armorItem.item as Armor
        if armorItem != none && armorPiece != none
            if i == 11
                isPower = armorPiece.HasKeyword(Game.Getform(0x04D8A1) as Keyword)
                if isPower
                    powerStr = " power"
                Endif
            EndIf

            Debug.TraceUser("MC", user.GetDisplayName() + ": " + powerStr + "Armor Item[" + i + "] " + armorItem.item.GetName())
            string pieceType = GetArmorLabel(armorPiece)
            if armorType == ""
                armorType = pieceType
            ElseIf identical && armorType != pieceType
                identical = false
            Endif
            numPieces += 1
        EndIf
            i += 1
    EndWhile

    if numPieces == 0
        matching = ""
        complete = "no"
    Else
        if numPieces == 5
            complete = "a complete"
        Else
            complete = "a partial"
        EndIf
        If identical
            matching = armorType + powerStr
        Else
            matching = "mixed"
        Endif
    EndIf

    string ret = complete + " set of " + matching + " armor"
    Debug.TraceUser("MC", User.GetDisplayName() + " is wearing " + ret)

    If user == Game.GetPlayer()
        showArmorVar = repository.playerReportArmor
    Else
        showArmorVar = repository.NPCReportArmor
    Endif

    If showArmorVar == 2 || (showArmorVar == 1 && isDrawn)
        return ret
    Else
        return ""
    EndIf
    return ret
EndFunction

string Function DescribeWeapon(Actor user)
    Weapon weap = user.GetEquippedWeapon()
    string weapStr = "no weapon"
    int showWeaponVar
    bool isDrawn = user.IsWeaponDrawn()

    if weap !=  none
        weapStr = "a " + weap.GetName()
        If isDrawn
            weapStr += " (drawn)"
        EndIf
    EndIf

    If user == Game.GetPlayer()
        showWeaponVar = repository.playerReportWeapon
    Else
        showWeaponVar = repository.NPCReportWeapon
    Endif

    If showWeaponVar == 2 || (showWeaponVar == 1 && isDrawn)
        return "carries " + weapStr
    Else
        return ""
    EndIf

EndFunction

