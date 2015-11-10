//TESH.scrollpos=12
//TESH.alwaysfold=0
//! zinc
library ItemRecipes requires RecipeSYS {
    private itempool ultimateTowersPool;
    public function initTitanItems(){
        // "Hidden" recipes
        AddRecipe('I03Q', 'I03Q', 'I03Q', 0     , 0     , 0     , 'I00D'); // Tridents
        AddRecipe('I000', 'I000', 'I000', 0     , 0     , 0     , 'I00B'); // Shadowstone
        AddRecipe('I03R', 'I03R', 'I03R', 0     , 0     , 0     , 'I042'); // Armor Scales
        AddRecipe('I01G', 'I01G', 0     , 0     , 0     , 0     , 'I036'); // Super Replenishment Flask
        
        AddConsumableMerge('I001');  // Healing Wards (Stacking)
        AddConsumableMerge('I017');  // Healing Wards (Stacking)
        
        AddConsumableMerge('I007'); // Eye of the Ocean (Stacking)
        AddConsumableMerge('I01F'); // Eye of the Ocean (Stacking) 
        
        AddConsumableMerge('I018'); // Scroll of the Beast (Stacking)
        AddConsumableMerge('I004'); // Scroll of the Beast (Stacking) 
        
        AddConsumableMerge('I01I'); // Staff of Teleportation (Stacking)
        AddConsumableMerge('I005'); // Staff of Teleportation (Stacking) 
        
        AddConsumableMerge('I06C'); // Wand of the Wind (Stacking)
        AddConsumableMerge('I01H'); // Wand of the Wind (Stacking) 
        
        AddConsumableMerge('I002');  // Replenishment Potion (Builder-Only)(Stacking)
        
        // IMPORTANT: Recipe "powerups" must be the last item in the list.
        AddRecipe('I017', 'I017', 'I017', 'I01Y', 0     , 0     , 'I01Z'); // Eternal Healing Ward     
        AddRecipe('I01N', 'I01O', 'I00M', 'I031', 0     , 0     , 'I032'); // Shadow Catcher Recipe
        AddRecipe('I00D', 'I00D', 'I01R', 0     , 0     , 0     , 'I01P'); // Titanic Trident
        AddRecipe('I018', 'I018', 'I00B', 'I00B', 'I02T', 0     , 'I02S'); // Berserker Gem
        AddRecipe('I01F', 'I02Q', 0     , 0     , 0     , 0     , 'I02R'); // Floating Eye
        AddRecipe('I016', 'I016', 'I00M', 'I01S', 0     , 0     , 'I01T'); // MSotG
        AddRecipe('I00C', 'I00C', 'I00C', 'I00E', 'I01U', 0     , 'I01Q'); // Super Regen Spines
        AddRecipe('I00C', 'I00C', 'I00M', 'I036', 'I01W', 0     , 'I01V'); // Life Essence
        AddRecipe('I042', 'I042', 'I042', 'I043', 0     , 0     , 'I041'); // Armor of Fate
		
        AddRecipe('I00B', 'I00E', 'I045', 0     , 0     , 0     , 'I044'); // Gauntlets of Rage
        AddRecipe('I027', 'I044', 'I054', 0     , 0     , 0     , 'I04Z'); // Gauntlets of Fury
		
        AddRecipe('I00D', 'I00D', 'I00P', 'I04P', 0     , 0     , 'I04Q'); // Ankh of Power
        AddRecipe('I00B', 'I00E', 'I040', 'I05F', 0     , 0     , 'I030'); // Helm of the Dominator
        AddRecipe('I01Z', 'I053', 0     , 0     , 0     , 0     , 'I052'); // Titanic Wards
        AddRecipe('I00M', 'I00D', 'I06B', 0     , 0     , 0     , 'I069'); // Force Trident of Power
        AddRecipe('I00M', 'I00M', 'I06E', 0     , 0     , 0     , 'I06A'); // Mystical Coral
		
    }

    private function addUltimateTower(integer itemid, real chance) {
        //        recipe, tower , egg
        AddRecipe('I02Z', itemid, 'I022', 0     , 0     , 0     , 'I03C'); // Randomize Ultimate Tower
        
        // Also add to the item pool!
        ItemPoolAddItemType(ultimateTowersPool, itemid, chance);
    }
    
    private function addUltimateTowers() {
        /*== SACRED SEASHELL*/
        addUltimateTower('I00J', 1.0);
        /*== HEAVY CANNON*/
        addUltimateTower('I00Y', 1.0);
        /*== METHANE MACHINE*/
        addUltimateTower('I03A', 1.0);
        /*== SLUDGE LAUNCHER*/
        addUltimateTower('I00K', 1.0);
        /*== TROPICAL GLYPH*/
        addUltimateTower('I00N', 1.0);
        /*== GIANT HERMIT*/
        addUltimateTower('I00T', 1.0);
        /*== CRAB MUTANT*/
        addUltimateTower('I00U', 1.0);
        /*== CATAPULT*/
        addUltimateTower('I00V', 1.0);
        /*== WHIRLPOOL*/
        addUltimateTower('I011', 1.0);
        /*== STATIS TOTEM*/
        addUltimateTower('I00W', 1.0);
        /*== MAGIC PEARL*/
        addUltimateTower('I00O', 1.0);
        /*== MAGIC TOWER*/
        addUltimateTower('I00Z', 1.0);
        /*== BOMBARD*/
        addUltimateTower('I010', 1.0);
        /*== MAGIC MUSHROOM*/
        addUltimateTower('I00X', 1.0);
        /*== AURA TREE*/
        addUltimateTower('I013', 1.0);
        /*== SPELL WELL*/
        addUltimateTower('I014', 1.0);
        /*== SPINY PROTECTOR*/
        addUltimateTower('I015', 1.0);
        /*== RAPID FIRE TOWER*/
        addUltimateTower('I01A', 1.0);
        /*== DEEPFREEZE*/
        addUltimateTower('I01B', 1.0);
        /*== ENERGY SPIRE*/
        addUltimateTower('I01C', 1.0);
        /*== MUTATION TOWER*/
        addUltimateTower('I01K', 1.0);
        /*== TOXIC TOWER*/
        addUltimateTower('I01L', 1.0);
        /*== WAVE TOWER*/
        addUltimateTower('I02V', 1.0);
        /*== DEMOLISHER TOTEM*/
        addUltimateTower('I02Y', 1.0);
        /*== CROWN OF THIEVES*/
        addUltimateTower('I037', 1.0);
        /*== REPLICATOR*/
        addUltimateTower('I038', 1.0);
        /*== BOX OF GAIA*/
        addUltimateTower('I05A', 1.0);
        /*== BOX OF PYROS*/
        addUltimateTower('I058', 1.0);
        /*== BOX OF STORMS*/
        addUltimateTower('I059', 1.0);
        /* HIGH ENERGY CONDUIT*/
        addUltimateTower('I057', 1.0);
        /* ICE PALACE*/
        addUltimateTower('I04O', 1.0);
        /* EGG SACK*/
        addUltimateTower('I05T', 1.0);
        /* FIREWORKS LAUNCHER*/
        addUltimateTower('I04J', 1.0);
        /* TAVERN*/
        addUltimateTower('I04L', 1.0);
        /* WELL OF POWER*/
        addUltimateTower('I056', 1.0);
        /* SPIRITUAL RIFT*/
        //addUltimateTower('I061', 1.0);
        /* ISLAND BLOOM*/
        addUltimateTower('I06D', 1.0);
        /* LIGHT ENERGY TOWER*/
        addUltimateTower('I01M', 1.0);
    }
    
    public function initBuilderItems(){
        AddRecipe('I00H', 'I04B', 0, 0, 0, 0, 'I048'); // Greater Troll Hands
        AddRecipe('I00G', 'I049', 0, 0, 0, 0, 'I046'); // Greater Summoning Stone
        AddRecipe('I00I', 'I04A', 0, 0, 0, 0, 'I047'); // Greater Gnoll Luck

        AddRecipe('I022', 'I022', 'I022', 'I022', 'I047', 'I023', 'I020'); // Ring of Shadows
        AddRecipe('I023', 0, 0, 0, 0, 0, 0); // Destroy
        AddRecipe('I022', 'I022', 'I022', 'I009', 'I021', 0, 'I01X'); // Storm Hammer
        AddRecipe('I021', 0, 0, 0, 0, 0, 0); // Destroy
        AddRecipe('I022', 'I022', 'I005', 'I026', 0, 0, 'I025'); // Teleporter
        AddRecipe('I026', 0, 0, 0, 0, 0, 0); // Destroy
        AddRecipe('I022', 'I00A', 'I00A', 'I03S', 0, 0, 'I03P'); // Shield of Will
        AddRecipe('I03S', 0, 0, 0, 0, 0, 0); // Destroy
        AddRecipe('I022', 'I03P', 'I04H', 0, 0, 0, 'I04G'); // Shield of Might
        AddRecipe('I04H', 0, 0, 0, 0, 0, 0); // Destroy
        AddRecipe('I022', 'I00A', 'I00A', 'I04I', 0, 0, 'I04F'); // Runed Bracers
        AddRecipe('I04I', 0, 0, 0, 0, 0, 0); // Destroy
        AddRecipe('I00Q', 'I04W', 'I022', 0, 0, 0, 'I04Y'); // Great Turtle Summons
        AddRecipe('I04W', 0, 0, 0, 0, 0, 0); // Destroy
        AddRecipe('I05W', 'I022', 'I007', 0, 0, 0, 'I04R'); // Cloak of Shadows
        AddRecipe('I05W', 0, 0, 0, 0, 0, 0); // Destroy
        AddRecipe('I04S', 'I022', 'I022', 'I009', 0, 0, 'I05V'); // Sword of the Magistrate
        AddRecipe('I04S', 0, 0, 0, 0, 0, 0); // Destroy
        AddRecipe('I05G', 'I022', 'I022', 'I005', 0, 0, 'I05X'); // Mystic Stone
        AddRecipe('I05G', 0, 0, 0, 0, 0, 0); // Destroy
		
		// Runed Bracers
		// I04F (25%)
		// I03W (50%)
		// I03Z (75%)
		// I04D (100%)
		/*
		AddRecipe('I04F', 'I04F', 0, 0, 0, 0, 'I03W'); 
		AddRecipe('I04F', 'I03W', 0, 0, 0, 0, 'I03Z');
		AddRecipe('I04F', 'I03Z', 0, 0, 0, 0, 'I04D');
		AddRecipe('I03W', 'I03W', 0, 0, 0, 0, 'I04D');
		*/
        
        // Ultimate Towers
        addUltimateTowers();
        AddRecipe('I02Z', 0, 0, 0, 0, 0, 0); // Destroy
    }
    
    private function onInit(){
        trigger t = CreateTrigger();
        GT_RegisterItemAcquiredEvent(t, 'I03C');
        TriggerAddCondition(t, Condition(function() -> boolean {
            item it = GetManipulatedItem();
            unit u = GetTriggerUnit();
            RemoveItem(it);
            it = PlaceRandomItem(ultimateTowersPool, GetUnitX(u), GetUnitY(u));
            UnitAddItem(u, it);
            it = null;
            u = null;
            return false;
        }));
        t = null;
        
        ultimateTowersPool = CreateItemPool();
        
        initTitanItems();
        initBuilderItems();
    }
}
//! endzinc