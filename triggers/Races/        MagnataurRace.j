//TESH.scrollpos=11
//TESH.alwaysfold=0
//! zinc

library MagnataurRace requires Races {
    public struct MagnataurRace extends DefenderRace {
        method toString() -> string {
            return "Magnataur";
        }
        
        method widgetId() -> integer {
            return 'h01B';
        }

        method itemId() -> integer {
            return 'I02C';
        }

        method icon() -> string {
            return "ReplaceableTextures\\CommandButtons\\BTNBlueMagnataur.blp";
        }

        method difficulty() -> real {
            return 2.0;
        }
        
        method onSpawn(unit u) {
            player p = GetOwningPlayer(u);
            SetPlayerTechMaxAllowed(p, 'n01J', -1);
            SetPlayerTechMaxAllowed(p, 'o02R', -1);
            p = null;
        }
        
        private static method create() -> thistype {
            return thistype.allocate();
        }
        
        private static method onInit(){
            super.register(thistype.create());
        }
    }
}

//! endzinc