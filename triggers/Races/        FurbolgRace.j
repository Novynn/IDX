//TESH.scrollpos=0
//TESH.alwaysfold=0
//! zinc

library FurbolgRace requires Races {
    public struct FurbolgRace extends DefenderRace {
        method toString() -> string {
            return "Furbolg";
        }
        
        method inRandomPool() -> boolean {
            return false;
        }
        
        method isPickable() -> boolean {
            return false;
        }
        
        method widgetId() -> integer {
            return 'h016';
        }

        method itemId() -> integer {
            return 'I03D';
        }

        method icon() -> string {
            return "ReplaceableTextures\\CommandButtons\\BTNFurbolgElder.blp";
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