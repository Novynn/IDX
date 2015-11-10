//TESH.scrollpos=13
//TESH.alwaysfold=0
//! zinc

library MorphlingRace requires Races {
    public struct MorphlingRace extends DefenderRace {
        method toString() -> string {
            return "Morphling";
        }
        
        method widgetId() -> integer {
            return 'h021';
        }
		method isWidgetId(integer id) -> boolean {
			return id == this.widgetId() || id == 'h024' || id == 'h023'; // Enhanced Forms
		}

        method itemId() -> integer {
            return 'I029';
        }

        method icon() -> string {
            return "ReplaceableTextures\\CommandButtons\\BTNFacelessOne.blp";
        }

        method difficulty() -> real {
            return 2.0;
        }
        
        method onSpawn(unit u) {
            player p = GetOwningPlayer(u);
            SetPlayerTechMaxAllowed(p, 'o01V', -1);
            SetPlayerTechMaxAllowed(p, 'n01L', -1);
            SetPlayerTechMaxAllowed(p, 'o017', -1);
            //UnitMakeAbilityPermanent(u, true, 'A07G'); // <= NO! BAD NECO
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