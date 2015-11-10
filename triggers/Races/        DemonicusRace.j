//TESH.scrollpos=0
//TESH.alwaysfold=0
//! zinc

library DemonicusRace requires Races, CustomTitanRace {
    public struct DemonicusRace extends TitanRace {
        method toString() -> string {
            return "Demonicus";
        }
        
        method widgetId() -> integer {
            return 'E00E';
        }
        
        method childId() -> integer {
            return 'U005';
        }

        method itemId() -> integer {
            return 'I02K';
        }

        method icon() -> string {
            return "ReplaceableTextures\\CommandButtons\\BTNVoidWalker.blp";
        }

        method childIcon() -> string {
            return "ReplaceableTextures\\CommandButtons\\BTNVoidwalker2.blp";
        }
        
        method onSpawn(unit u) {
            PlayerData p = PlayerData.get(GetOwningPlayer(u));
            if (GameSettings.getBool("TITAN_AUTOATTACK_ON")) {
                p.say("|cff00bfffAuto-Attack has been turned |r|cff00ff00on|r|cff00bfff. Use \"-aa off\" to turn it off.|r");
            }
            else {
                p.say("|cff00bfffAuto-Attack has been turned |r|cffff0000off|r|cff00bfff. Use \"-aa on\" to turn it on.|r");
            }
			CustomTitanRace.setBaseAbilities(u, this.toString());
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