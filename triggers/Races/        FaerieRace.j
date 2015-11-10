//TESH.scrollpos=30
//TESH.alwaysfold=0
//! zinc

library FaerieRace requires Races {
    public struct FaerieRace extends DefenderRace {
        method toString() -> string {
            return "Faerie";
        }
        
        method widgetId() -> integer {
            return 'h02S';
        }
		
		method isWidgetId(integer id) -> boolean {
			return id == this.widgetId() || id == 'h004'; // Enhanced Form
		}

        method itemId() -> integer {
            return 'I02W';
        }

        method icon() -> string {
            return "ReplaceableTextures\\CommandButtons\\BTNFaerieDragon.blp";
        }

        method difficulty() -> real {
            return 3.0;
        }

        method childId() -> integer {
            return 'H03D'; // Hunter
        }

        method childItemId() -> integer {
            return 'q129'; // Hunter Research
        }
        
        method setupTech(player p) {
			// Ultimate Towers
            SetPlayerTechMaxAllowed(p, 'o017', -1);
            SetPlayerTechMaxAllowed(p, 'o01P', -1);
            SetPlayerTechMaxAllowed(p, 'o00O', -1);
		}
		
        method onSpawn(unit u) {
			UnitMakeAbilityPermanent(u, true, 'A0A4');
			UnitMakeAbilityPermanent(u, true, 'A05K');
			UnitMakeAbilityPermanent(u, true, 'A0A0');
			UnitMakeAbilityPermanent(u, true, 'A0A6');
			UnitMakeAbilityPermanent(u, true, 'A09Z');
			UnitMakeAbilityPermanent(u, true, 'A0BE');
			UnitMakeAbilityPermanent(u, true, 'A079');
			UnitMakeAbilityPermanent(u, true, 'A07C');
			UnitMakeAbilityPermanent(u, true, 'A0AA');
			UnitMakeAbilityPermanent(u, true, 'A09Y');
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