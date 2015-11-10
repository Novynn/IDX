//TESH.scrollpos=0
//TESH.alwaysfold=0
//! zinc

library TerminusRace requires Races, CurrentTap {
    public struct TerminusRace extends TitanRace {
		private string name = "Terminus";
        method toString() -> string {
            return name;
        }
        
        method widgetId() -> integer {
            return 'E00O';
        }
        
        method childId() -> integer {
            return 'U016'; // Lucidious' Minion
        }

        method itemId() -> integer {
            return 'I02J';
        }

        method icon() -> string {
            return "ReplaceableTextures\\CommandButtons\\BTNMountainGiant.blp";
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