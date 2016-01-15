//! zinc

library SatyrUpgrades requires Upgrades, DefaultUpgrades, UnitManager, UnitMaxState {
    public struct SatyrUpgrades extends UpgradeDefinition {
        module UpgradeModule;
        
        //public static DefenderRace Satyr = 0;
        
        public method setup() {
            UpgradeLevel level = 0;
            //thistype.Satyr = DefenderRace.fromName("Satyr");
            
            Upgrades.begin("Rending Blade", "all");
            Upgrades.addEx('q111', UnitManager.isDefender);
                Upgrades.addEffect(UpgradeAbilityEffect.create('A0BQ')); // Ability
            level = Upgrades.addEx('q112', UnitManager.isDefender);
                Upgrades.addEffect(UpgradeAbilityEffect.create('A0C3')); // Icon
                Upgrades.addEffect(UpgradeAbilityEffect.create('A0BQ')); // Ability
            Upgrades.addEx('q113', UnitManager.isDefender);
                Upgrades.continueEffects(level);
            Upgrades.addEx('q114', UnitManager.isDefender);
                Upgrades.continueEffects(level);
            Upgrades.end();
            
            Upgrades.begin("Basic Stealth Training", "all");
            Upgrades.addEx('q115', UnitManager.isDefender);
                Upgrades.addEffect(UpgradeAbilityEffect.create('A0BQ')); // Ability
            Upgrades.addEx('q116', UnitManager.isDefender);
                Upgrades.continueEffect();
            Upgrades.end();
            
            Upgrades.begin("Sapphire Blade", "all");
            Upgrades.addEx('q118', UnitManager.isDefender);
                Upgrades.addEffect(UpgradeBonusEffect.create(BONUS_DAMAGE, 100));
            Upgrades.addEx('q119', UnitManager.isDefender);
                Upgrades.continueEffect();
            Upgrades.addEx('q120', UnitManager.isDefender);
                Upgrades.continueEffect();
            Upgrades.end();
            
            Upgrades.begin("Basic Combat Mastery", "all");
            Upgrades.addEx('q161', UnitManager.isDefender);
                Upgrades.addEffect(UpgradeAbilityEffect.create('A0C8')); // Ability
            level = Upgrades.addEx('q162', UnitManager.isDefender);
                Upgrades.addEffect(UpgradeAbilityEffect.create('A0OD')); // Icon
                Upgrades.addEffect(UpgradeAbilityEffect.create('A0C8')); // Ability
            Upgrades.addEx('q163', UnitManager.isDefender);
                Upgrades.continueEffects(level);
            Upgrades.end();
            
            Upgrades.begin("Blur", "all");
                Upgrades.addRequirement('q287'); // No effects
            Upgrades.end();
            
            Upgrades.begin("Shadow Dust", "all");
            Upgrades.addRequirement('q166');
            Upgrades.addEx('q167', UnitManager.isDefender);
                Upgrades.addEffect(UpgradeAbilityEffect.create('A0BP')); // Ability
            Upgrades.end();
            
            Upgrades.begin("Endurance Training", "all");
            level = Upgrades.addEx('q168', UnitManager.isDefender);
                Upgrades.addEffect(UpgradeHPEffect.create(50));
                Upgrades.addEffect(UpgradeBonusEffect.create(BONUS_ARMOR, 1));
            Upgrades.addEx('q169', UnitManager.isDefender);
                Upgrades.continueEffects(level);
            Upgrades.addEx('q170', UnitManager.isDefender);
                Upgrades.continueEffects(level);
            Upgrades.addEx('q171', UnitManager.isDefender);
                Upgrades.continueEffects(level);
            Upgrades.addEx('q172', UnitManager.isDefender);
                Upgrades.continueEffects(level);
            Upgrades.addEx('q173', UnitManager.isDefender);
                Upgrades.continueEffects(level);
            Upgrades.end();
            
            Upgrades.begin("Sixth Sense", "all");
            Upgrades.addRequirement('q259'); // No effects
            Upgrades.end();
            
            Upgrades.begin("Pick Pocket", "all");
            Upgrades.addEx('q276', UnitManager.isDefender);
                Upgrades.addEffect(UpgradeAbilityEffect.create('A0BS')); // Ability
            Upgrades.end();
        }
    }
}

//! endzinc