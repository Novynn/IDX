//TESH.scrollpos=15
//TESH.alwaysfold=0
//! zinc

library TrollRace requires Races {
    public struct TrollRace extends DefenderRace {
        method toString() -> string {
            return "Troll";
        }
        
        method widgetId() -> integer {
            return 'h007';
        }

        method itemId() -> integer {
            return 'I01J';
        }

        method icon() -> string {
            return "ReplaceableTextures\\CommandButtons\\BTNWitchDoctor.blp";
        }

        method difficulty() -> real {
            return 2.0;
        }

        method childId() -> integer {
            return 'H00M'; // Hunter
        }

        method childItemId() -> integer {
            return 'q040'; // Hunter Research
        }
        
        method onSpawn(unit u) {
            player p = GetOwningPlayer(u);
            SetPlayerTechMaxAllowed(p, 'o00M', -1);
            SetPlayerTechMaxAllowed(p, 'h00P', -1);
            SetPlayerTechMaxAllowed(p, 'o00L', -1);
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