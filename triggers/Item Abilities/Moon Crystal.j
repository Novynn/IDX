//TESH.scrollpos=0
//TESH.alwaysfold=0
//! zinc

library MoonCrystalItem requires xecast, GT, GameTimer {
    private function onInit(){
        trigger t = CreateTrigger();
        GT_RegisterItemUsedEvent(t, 'I01O');
        TriggerAddCondition(t, Condition(function() -> boolean {
            unit u = GetTriggerUnit();
            player p = GetOwningPlayer(u);
            xecast xe = 0;
            
            // 20% chance
            if (GetRandomInt(0, 4) == 1) {
                xe = xecast.createBasicA('A06S', 852274, p); // Illusion order id
                xe.recycledelay = 5.1;
                xe.castOnTarget(u);
                PlaySoundBJ(gg_snd_Titan_MoonCrystal);
            }
            
            Game.say("|cff00bfffThe sky grows dark... Distrust your senses...|r");
            
            p = null;
            u = null;
            return false;
        }));
        t = null;
    }
}

//! endzinc