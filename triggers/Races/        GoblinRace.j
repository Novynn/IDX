//TESH.scrollpos=12
//TESH.alwaysfold=0
//! zinc

library GoblinRace requires Races {
    public struct GoblinRace extends DefenderRace {
        method toString() -> string {
            return "Goblin";
        }
        
        method widgetId() -> integer {
            return 'h00X';
        }

        method itemId() -> integer {
            return 'I02E';
        }

        method icon() -> string {
            return "ReplaceableTextures\\CommandButtons\\BTNHeroTinker.blp";
        }

        method difficulty() -> real {
            return 3.0;
        }

        method childId() -> integer {
            return 'H00Z'; // Hunter
        }

        method childItemId() -> integer {
            return 'q058'; // Hunter Research
        }
        
        method setupTech(player p) {
            // Ultimate Towers
            SetPlayerTechMaxAllowed(p, 'n01K', -1);
            SetPlayerTechMaxAllowed(p, 'n01J', -1);
            SetPlayerTechMaxAllowed(p, 'n01L', -1);
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