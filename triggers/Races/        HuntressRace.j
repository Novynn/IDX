//TESH.scrollpos=0
//TESH.alwaysfold=0
//! zinc

library HuntressRace requires Races {
    public struct HuntressRace extends DefenderRace {
        method toString() -> string {
            return "Huntress";
        }
        
        method widgetId() -> integer {
            return 'h01O';
        }

        method itemId() -> integer {
            return 'I05E';
        }

        method icon() -> string {
            return "ReplaceableTextures\\CommandButtons\\BTNSylvanusWindrunner.blp";
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