//TESH.scrollpos=9
//TESH.alwaysfold=0
//! zinc

library AetheriousRace requires Races, CurrentTap {
    public struct AetheriousRace extends TitanRace {
		string name = "Aetherious";
        method toString() -> string {
            return name;
        }
        
        method widgetId() -> integer {
            return 'E011';
        }
        
        method childId() -> integer {
            return 'U016';
        }

        method itemId() -> integer {
            return 'I02U';
        }

        method icon() -> string {
            return "ReplaceableTextures\\CommandButtons\\BTNNetherDragon.blp";
        }

        method childIcon() -> string {
            return "ReplaceableTextures\\CommandButtons\\BTNNagaMyrmidonRoyalGuard.blp";
        }
		
		method onSpawn(unit u) {
			CustomTitanRace.setBaseAbilities(u, this.toString());
			name = GetHeroProperName(u);
		}
        
        method inRandomPool() -> boolean {
            return false;
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