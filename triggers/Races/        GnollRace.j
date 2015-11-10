//TESH.scrollpos=18
//TESH.alwaysfold=0
//! zinc

library GnollRace requires Races {
    public struct GnollRace extends DefenderRace {
        method toString() -> string {
            return "Gnoll";
        }
        
        method widgetId() -> integer {
            return 'h009';
        }

        method itemId() -> integer {
            return 'I02A';
        }

        method icon() -> string {
            return "ReplaceableTextures\\CommandButtons\\BTNGnollKing.blp";
        }

        method difficulty() -> real {
            return 1.0;
        }

        method childId() -> integer {
            return 'H00O'; // Hunter
        }

        method childItemId() -> integer {
            return 'q037'; // Hunter Research
        }
        
        method onSpawn(unit u) {
            player p = GetOwningPlayer(u);
            SetPlayerTechMaxAllowed(p, 'o003', -1);
            SetPlayerTechMaxAllowed(p, 'o006', -1);
            SetPlayerTechMaxAllowed(p, 'o00Q', -1);
            SetPlayerTechMaxAllowed(p, 'o00P', -1);
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