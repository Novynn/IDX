//! zinc

library TitanHuntersUpgrades requires Upgrades, UnitManager, Races, UnitMaxState {
    // Train Titan Hunter
    public struct TitanHuntersUpgrade extends UpgradeDefinition {
        module UpgradeModule;
        
        public static method onTitanHunterEffect(PlayerUpgradeData p, UpgradeLevel data, unit u) {
            integer level = data.level;
            integer id = data.unitId;
            HunterUnit hunter = 0;
            unit a = null;
            if (level == 1 && id == p.race().childItemId() && u != null){
                // It's a hunter!
                hunter = UnitManager.spawnHunter(p.playerData, GetUnitX(u), GetUnitY(u));
                
                a = hunter.unit();
                // Default Specs (maybe this should go in spawnHunter rather than here?)
                SelectHeroSkill(a, 'A00V'); // Spec into Blink
                SelectHeroSkill(a, 'A0EE'); // Spec into Nitro
                SelectHeroSkill(a, 'AHdr'); // Spec into Siphon Mana
                
                IssuePointOrderLoc(a, "move", GetUnitRallyPoint(u));
            }
            u = null;
            a = null;
        }
        
        public static method setupHunter(DefenderRace r) {
            if (r.childItemId() == 0) return;
            Upgrades.begin("Train Titan Hunter", r.toString());
            Upgrades.addWithEvents(r.childItemId(), thistype.onTitanHunterEffect, 0);
            Upgrades.end();
        }
        
        public static method isHunter(unit u) -> boolean {
            return UnitManager.isHunter(u);
        }
        
        public method setup() {
            integer i = 0;
            for (0 <= i < DefenderRace.count()) {
                thistype.setupHunter(DefenderRace[i]);
            }
            
            Upgrades.begin("Hunter Intelligence Training", "all");
            Upgrades.addWithData('q241', UnitManager.isHunter, DefaultUpgrades.incrMaxMana, DefaultUpgrades.decrMaxMana, 150);
            Upgrades.end();
            
            Upgrades.begin("Hunter Survival Training", "all");
            Upgrades.addWithData('q238', UnitManager.isHunter, DefaultUpgrades.incrMaxHealth, DefaultUpgrades.decrMaxHealth, 300);
            Upgrades.end();
        }
    }
}

//! endzinc