//TESH.scrollpos=0
//TESH.alwaysfold=0
//! zinc

library PandaRace requires Races {
    public struct PandaRace extends DefenderRace {
        method toString() -> string {
            return "Panda";
        }
        
        method widgetId() -> integer {
            return 'h03K';
        }

        method itemId() -> integer {
            return 'I03T';
        }

        method icon() -> string {
            return "ReplaceableTextures\\CommandButtons\\BTNPandarenBrewmaster.blp";
        }

        method difficulty() -> real {
            return 3.0;
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