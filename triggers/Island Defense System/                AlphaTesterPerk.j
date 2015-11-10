//TESH.scrollpos=35
//TESH.alwaysfold=0
//! zinc

library AlphaTesterPerk requires PerksSystem {
    private struct AlphaTesterPerk extends Perk {
        module PerkModule;
        private static constant integer GLOW_EFFECT_ITEM_ID = 'I03B';
        private static constant integer GLOW_EFFECT_ABILITY_ID = 'A000';
        
        public method name() -> string {
            return "AlphaTesterPerk";
        }
        
        public method onSpawn(PlayerData p){
            Unit u = p.unit();
            unit v = null;
            if (u == 0) return;
            v = u.unit();
            //UnitAddItem(v, CreateItem(thistype.GLOW_EFFECT_ITEM_ID, 0.0, 0.0));
            UnitAddAbility(v, thistype.GLOW_EFFECT_ABILITY_ID);
            UnitMakeAbilityPermanent(v, true, thistype.GLOW_EFFECT_ABILITY_ID);
        }
        
        public method forPlayer(PlayerData p) -> boolean {
            string name = StringCase(p.name(), false);
            if (name == "neco" ||
                name == "phosphia" ||
                name == "burnshady" ||
                name == "stealer" || name == "cambrioleuse" || name == "|cffff1919kurpt" ||
                name == "art)y" ||
                name == "beekauzh" ||
                name == "limiepewpew" ||
                name == "zimmer.is.back" ||
                name == "lynx-" ||
                name == "toonoobforu" ||
                name == "muffinman" ||
                name == "dydax" ||
                name == "mini-cml-" ||
                name == "evilmad666" ||
                name == "terrios" ||
                name == "pandaren-" ||
                name == "timmythetauren" || name == "peterpan" ||
                name == "juking" ||
                name == "jnt94" ||
                name == "justadoormat" ||
                name == "bloodyg" || name == "bloodyguy" ||
                name == "chibi" ||
                name == "anti-god" ||
                name == "hidden" ||
                name == "lichard" ||
                name == "armadageddon" ||
                name == "idtitan" ||
                name == "godtits" ||
                name == "cr4zYf[o.o]l" ||
                name == "d347h" ||
                name == "captainmelon" ||
                name == "craftyer" ||
                name == "dehumanchum" ||
                name == "th3l3dg3n" ||
                name == "tedro32" ||
                name == "fossurious" ||
                name == "virulence" ||
                name == "shadowzz" ||
                name == "luna") return true;
            return false;
        }
        
        private static method initialize() {
        /*
            trigger t = CreateTrigger();
            TriggerRegisterAnyUnitEventBJ( t, EVENT_PLAYER_UNIT_ISSUED_TARGET_ORDER );
            TriggerAddCondition(t, function()->boolean {
                return (GetIssuedOrderId() > 852001 &&
                        GetIssuedOrderId() < 852008);
            });
            TriggerAddAction(t, function() {
                item it = GetOrderTargetItem();
                integer slotid = GetIssuedOrderId()-852002;
                unit u = GetOrderedUnit();
                integer id = GetItemTypeId(it);
                if (it == UnitItemInSlot(u, slotid) &&
                    id == thistype.GLOW_EFFECT_ITEM_ID){
                    // Hopefully persists
                    RemoveItem(it); // Need to remove item here, otherwise abilities clash and the next line won't work.
                    UnitAddAbility(u, thistype.GLOW_EFFECT_ABILITY_ID);
                    UnitMakeAbilityPermanent(u, true, thistype.GLOW_EFFECT_ABILITY_ID);
                }
                u = null;
                it = null;
            });
            t = null;
            */
        }
    }
}
//! endzinc