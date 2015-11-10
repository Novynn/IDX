//TESH.scrollpos=9
//TESH.alwaysfold=0
//! zinc

library MakruraRace requires Races {
    public struct MakruraRace extends DefenderRace {
        method toString() -> string {
            return "Makrura";
        }
        
        method widgetId() -> integer {
            return 'h008';
        }

        method itemId() -> integer {
            return 'I02D';
        }

        method icon() -> string {
            return "ReplaceableTextures\\CommandButtons\\BTNLobstrokkGreen.blp";
        }

        method difficulty() -> real {
            return 1.0;
        }

        method childId() -> integer {
            return 'H00N'; // Hunter
        }

        method childItemId() -> integer {
            return 'q041'; // Hunter Research
        }
        
        method onSpawn(unit u) {
            player p = GetOwningPlayer(u);
            SetPlayerTechMaxAllowed(p, 'o00J', -1);
            SetPlayerTechMaxAllowed(p, 'o00K', -1);
            SetPlayerTechMaxAllowed(p, 'o00N', -1);
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