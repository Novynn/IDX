//TESH.scrollpos=12
//TESH.alwaysfold=0
//! zinc

library OgreRace requires Races {
    public struct OgreRace extends DefenderRace {
        method toString() -> string {
            return "Ogre";
        }
        
        method widgetId() -> integer {
            return 'h037';
        }
		
		method isWidgetId(integer id) -> boolean {
			return id == this.widgetId() || id == 'h01N'; // Enhanced Form
		}

        method itemId() -> integer {
            return 'I039';
        }

        method icon() -> string {
            return "ReplaceableTextures\\CommandButtons\\BTNOgreLord.blp";
        }

        method difficulty() -> real {
            return 2.0;
        }

        method childId() -> integer {
            return 'H039'; // Hunter
        }

        method childItemId() -> integer {
            return 'q126'; // Hunter Research
        }
		
		method setupTech(player p) {
			// Ultimate Towers
            SetPlayerTechMaxAllowed(p, 'o01Y', -1);
            SetPlayerTechMaxAllowed(p, 'o016', -1);
            SetPlayerTechMaxAllowed(p, 'o003', -1);
            SetPlayerTechMaxAllowed(p, 'h00P', -1);
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