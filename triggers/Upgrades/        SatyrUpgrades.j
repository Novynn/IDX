//! zinc

library SatyrUpgrades requires Upgrades, DefaultUpgrades, UnitManager, UnitMaxState {
  
    // Rending Blade
    public struct Upgrade66Upgrade extends UpgradeDefinition {
        module UpgradeModule;
        public static method appliesTo(unit u) -> boolean {
            integer id = GetUnitTypeId(u);
            return id == 'h035';
        }
        public method setup() {
            Upgrades.begin("Rending Blade", "all");
            // Level 1 - Improves the Satyr's weapon, causing it to deal 25 extra damage and reduce the armour of damaged units by 2 for two seconds.
            Upgrades.add('q111', thistype.appliesTo, function(unit u) {
                
            }, function(unit u) {
                
            });
            // Level 2 - Further improves the Satyr's weapon, causing it to deal 50 extra damage and reduce the armour of damaged units by 4 for two seconds.
            Upgrades.add('q112', thistype.appliesTo, function(unit u) {
                
            }, function(unit u) {
                
            });
            // Level 3 - Further improves the Satyr's weapon, causing it to deal 75 extra damage and reduce the armour of damaged units by 6 for two seconds.
            Upgrades.add('q113', thistype.appliesTo, function(unit u) {
                
            }, function(unit u) {
                
            });
            // Level 4 - Hones the Satyr's weapon to a razor edge, giving it 100 bonus damage and causing it to reduce the armour of damaged units by 8 for two seconds.
            Upgrades.add('q114', thistype.appliesTo, function(unit u) {
                
            }, function(unit u) {
                
            });
            Upgrades.end();
        }
    }
    

    // Basic Stealth Training
    public struct Upgrade67Upgrade extends UpgradeDefinition {
        module UpgradeModule;
        public static method appliesTo(unit u) -> boolean {
            integer id = GetUnitTypeId(u);
            return id == 'h035';
        }
        public method setup() {
            Upgrades.begin("Basic Stealth Training", "all");
            // Level 1 - Improves the Satyr's ability to fade himself to 2 seconds.
            Upgrades.add('q115', thistype.appliesTo, function(unit u) {
                
            }, function(unit u) {
                
            });
            // Level 2 - Improves the Satyr's ability to fade himself to 1.7 seconds.
            Upgrades.add('q116', thistype.appliesTo, function(unit u) {
                
            }, function(unit u) {
                
            });
            Upgrades.end();
        }
    }
    // Sapphire Blade
    public struct Upgrade69Upgrade extends UpgradeDefinition {
        module UpgradeModule;
        public static method appliesTo(unit u) -> boolean {
            integer id = GetUnitTypeId(u);
            return id == 'h035';
        }
        public method setup() {
            Upgrades.begin("Sapphire Blade", "all");
            // Level 1 - The Satyr's wealth allows him the best in weaponry, allowing him to aquire a brilliant sapphire blade. Adds 100 damage.
            Upgrades.add('q118', thistype.appliesTo, function(unit u) {
                
            }, function(unit u) {
                
            });
            // Level 2 - The Satyr's wealth allows him the best in weaponry, allowing him to aquire a dark ruby blade. Adds a further 100 damage.
            Upgrades.add('q119', thistype.appliesTo, function(unit u) {
                
            }, function(unit u) {
                
            });
            // Level 3 - The Satyr's wealth allows him the best in weaponry, allowing him to aquire a legendary assassins blade, coveted by all shadowy figures. Gives a total of 300 bonus damage to the Satyr.
            Upgrades.add('q120', thistype.appliesTo, function(unit u) {
                
            }, function(unit u) {
                
            });
            Upgrades.end();
        }
    }
    // Basic Combat Mastery
    public struct Upgrade95Upgrade extends UpgradeDefinition {
        module UpgradeModule;
        public static method appliesTo(unit u) -> boolean {
            integer id = GetUnitTypeId(u);
            return id == 'h035';
        }
        public method setup() {
            Upgrades.begin("Basic Combat Mastery", "all");
            // Level 1 - Raises the Satyr's combat prowness to a higher state, allowing him to avoid fatal blows and hit enemy weak points. Improves the Satyr's Shadow Dash and gives 8% evasion and a 10% chance to deal 2x damage.
            Upgrades.add('q161', thistype.appliesTo, function(unit u) {
                
            }, function(unit u) {
                
            });
            // Level 2 - Further raises the Satyr's combat prowness, allowing him to avoid fatal blows with greater ease and hit enemy weak points more effectively. Improves the Satyr's Shadow Dash and gives 16% evasion and a 10% chance to deal 3x damage.
            Upgrades.add('q162', thistype.appliesTo, function(unit u) {
                
            }, function(unit u) {
                
            });
            // Level 3 - Completes the Satyr's combat training, allowing him to avoid fatal blows and hit enemy weak points with devastating results. Allows the Satyr to Blur and gives 32% evasion and a 10% chance to deal 4x damage.
            Upgrades.add('q163', thistype.appliesTo, function(unit u) {
                
            }, function(unit u) {
                
            });
            Upgrades.end();
        }
    }
    // Shadow Dust
    public struct Upgrade97Upgrade extends UpgradeDefinition {
        module UpgradeModule;
        public static method appliesTo(unit u) -> boolean {
            integer id = GetUnitTypeId(u);
            return id == 'h035';
        }
        public method setup() {
            Upgrades.begin("Shadow Dust", "all");
            // Level 1 - Allows the Satyr to turn allied units invisible at will.|n|cffffd700Last for 15 seconds.|r
            Upgrades.add('q166', thistype.appliesTo, function(unit u) {
                
            }, function(unit u) {
                
            });
            // Level 2 - Allows you to use Shadow Dust on allied structures as well as units. Also reduces the cooldown of the Satyr's Shadowdust ability by 15 seconds.
            Upgrades.add('q167', thistype.appliesTo, function(unit u) {
                
            }, function(unit u) {
                
            });
            Upgrades.end();
        }
    }
    

    // Endurance Training - [|cffffcc00Level 1|r]
    public struct Upgrade98Upgrade extends UpgradeDefinition {
        module UpgradeModule;
        public static method appliesTo(unit u) -> boolean {
            integer id = GetUnitTypeId(u);
            return id == 'h035';
        }
        public method setup() {
            Upgrades.begin("Endurance Training - [|cffffcc00Level 1|r]", "all");
            // Level 1 - Toughens the Satyr, granting him an additional 50 hit points and extra armour.
            Upgrades.add('q168', thistype.appliesTo, function(unit u) {
                
            }, function(unit u) {
                
            });
            // Level 2 - Toughens the Satyr, granting him an additional 50 hit points and extra armour.
            Upgrades.add('q169', thistype.appliesTo, function(unit u) {
                
            }, function(unit u) {
                
            });
            // Level 3 - Toughens the Satyr, granting him an additional 50 hit points and extra armour.
            Upgrades.add('q170', thistype.appliesTo, function(unit u) {
                
            }, function(unit u) {
                
            });
            // Level 4 - Toughens the Satyr, granting him an additional 50 hit points and extra armour.
            Upgrades.add('q171', thistype.appliesTo, function(unit u) {
                
            }, function(unit u) {
                
            });
            // Level 5 - Toughens the Satyr, granting him an additional 50 hit points and extra armour.
            Upgrades.add('q172', thistype.appliesTo, function(unit u) {
                
            }, function(unit u) {
                
            });
            // Level 6 - Toughens the Satyr, granting him an additional 50 hit points and extra armour.
            Upgrades.add('q173', thistype.appliesTo, function(unit u) {
                
            }, function(unit u) {
                
            });
            Upgrades.end();
        }
    }

    // Sixth Sense
    public struct Upgrade149Upgrade extends UpgradeDefinition {
        module UpgradeModule;
        public static method appliesTo(unit u) -> boolean {
            integer id = GetUnitTypeId(u);
            return id == 'h035';
        }
        public method setup() {
            Upgrades.begin("Sixth Sense", "all");
            // Level 1 - The Satyr trains his senses, being able to know when he has been detected by the enemy.|n|nGrants a visual buff on your Satyr whenever he is visible to an enemy player.
            Upgrades.add('q259', thistype.appliesTo, 0, 0); // No effects
            Upgrades.end();
        }
    }
    

    // Pick Pocket
    public struct Upgrade151Upgrade extends UpgradeDefinition {
        module UpgradeModule;
        public static method appliesTo(unit u) -> boolean {
            integer id = GetUnitTypeId(u);
            return id == 'h035';
        }
        public method setup() {
            Upgrades.begin("Pick Pocket", "all");
            // Level 1 - The Satyr learns how to steal resources from his enemies without them even noticing.|n|nAllows you to Plunder from your enemies before landing a hit.|n|n|cffff0000Note:|r This allows you to speed poke.
            Upgrades.add('q276', thistype.appliesTo, function(unit u) {
                
            }, function(unit u) {
                
            });
            Upgrades.end();
        }
    }
}

//! endzinc