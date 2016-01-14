//TESH.scrollpos=15
//TESH.alwaysfold=0
//! zinc

library PirateRace requires Races {
    public struct PirateRace extends DefenderRace {
        method toString() -> string {
            return "Pirate";
        }
        
        method widgetId() -> integer {
            return 'h043';
        }

        method itemId() -> integer {
            return 'I04C';
        }

        method icon() -> string {
            return "ReplaceableTextures\\CommandButtons\\BTNMedivh.blp";
        }

        method difficulty() -> real {
            return 1.0;
        }

        method childId() -> integer {
            return 'H046'; // Hunter
        }

        method childItemId() -> integer {
            return 'q205'; // Hunter Research
        }
        
        method setupTech(player p) {
            // Ultimate Towers
            SetPlayerTechMaxAllowed(p, 'o02P', -1);
            SetPlayerTechMaxAllowed(p, 'o02Q', -1);
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