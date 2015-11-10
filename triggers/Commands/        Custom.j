//TESH.scrollpos=15
//TESH.alwaysfold=0
//! zinc

library CustomTestTweak requires TweakManager, CustomTitanRace {
    public struct CustomTestTweak extends Tweak {
        module TweakModule;
        
        public method name() -> string {
            return "CustomTest";
        }
        public method shortName() -> string {
            return "CUSTOMTEST";
        }
        public method description() -> string {
            return "Custom Titan test.";
        }
        public method command() -> string {
            return ":/customtest";
        }
        public method hidden() -> boolean {
            return true;
        }
        
        private method test() {
            CustomTitanRace r = CustomTitanRace.sneakyCreate();
            TitanRace slow = TitanRace.fromName("Lucidious");
            TitanRace hunt = TitanRace.fromName("Glacious");
            TitanRace nuke = TitanRace.fromName("Lucidious");
            TitanRace ww = TitanRace.fromName("Demonicus");
            TitanRace heal = TitanRace.fromName("Sypherious");
            TitanRace unique = TitanRace.fromName("Lucidious");
            TitanRace ultimate = TitanRace.fromName("Sypherious");
            
            // Lucidious
            r.setTitanBase(slow);
            r.setMinion(slow);
            
            r.setTitanName("Customicus");
            
            r.addTitanAbility(slow, "S");
            r.addTitanAbility(hunt, "D");
            r.addTitanAbility(nuke, "Q");
            r.addTitanAbility(ww, "W");
            r.addTitanAbility(heal, "E");
            r.addTitanAbility(unique, "R");
            r.addTitanAbility(ultimate, "F");
            
            r.printAbilityNames();
            r.destroy();
            
            // Don't destroy other bases
        }
        
        public method activate(Args args){
            PlayerData p = PlayerData.get(GetTriggerPlayer());
            PlayerData q = 0;
            if (!GameSettings.getBool("DEBUG") && p.name() != GameSettings.getStr("EDITOR")) return;
            
            this.test();
        }
    }
}
//! endzinc