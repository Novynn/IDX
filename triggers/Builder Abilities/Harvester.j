//! zinc

library NatureHarvesters requires GameTimer, Table, ShowTagFromUnit {
    private struct NatureHarvesterData {
        unit u = null;
        integer index;
        integer harvestTicks = 0;
        
        private method getUpgradeId() -> integer {
            if (GetUnitAbilityLevel(this.u, 'A02J') > 0) return 'q051'; // Nature
            if (GetUnitAbilityLevel(this.u, 'A05N') > 0) return 'q279'; // Radio
            return 0;
        }
        
        private method getUpgradeBonus() -> integer {
            PlayerData p = PlayerData.get(GetOwningPlayer(this.u));
            integer level = Upgrades.getPlayerUpgradeLevel(p.player(), this.getUpgradeId());
            return level * 2;
        }
        
        private method act() {
            integer bonus = this.getUpgradeBonus();
            PlayerData p = PlayerData.get(GetOwningPlayer(this.u));
            real x = GetUnitX(this.u);
            real y = GetUnitY(this.u);
            
            if (bonus > 0) {
                // Apply bonus
                if (GetLocalPlayer() == p.player()) {
                    ShowTag("|cff00C850(+" + I2S(bonus) + ")|r", x, y - 48, 120.0);
                }
                p.setWood(p.wood() + bonus);
            }
        }
        
        public method tick() {
            if (this.getUpgradeId() == 0) {
                this.destroy();
                return;
            }
        
            this.harvestTicks = this.harvestTicks + 1;
            
            if (this.harvestTicks == 27) {
                this.act();
                this.resetTick();
            }
        }
        
        public method resetTick() {
            this.harvestTicks = 0;
        }
        
        private static trigger deathTrigger = null;
        
        public static method create(unit u) -> thistype {
            thistype this = thistype.allocate();
            integer id = GetUnitId(u);
            this.u = u;
            this.index = id;
            this.harvestTicks = 0;
            thistype.harvestTable[id] = this;
            return this;
        }
        
        private method onDestroy() {
            this.u = null;
            this.harvestTicks = 0;
            thistype.harvestTable.remove(this.index);
            this.index = 0;
        }
        
        private static Table harvestTable = 0;
        public static method operator[](unit u) -> thistype {
            integer id = GetUnitId(u);
            if (thistype.harvestTable.has(id)) {
                return thistype(thistype.harvestTable[id]);
            }
            return thistype.create(u);
        }
        
        private static method onInit() {
            thistype.harvestTable = Table.create();
            thistype.deathTrigger = CreateTrigger();
            TriggerRegisterAnyUnitEventBJ(thistype.deathTrigger, EVENT_PLAYER_UNIT_DEATH);
            TriggerAddCondition(thistype.deathTrigger, Condition(function() -> boolean {
                unit u = GetDyingUnit();
                integer id = GetUnitId(u);
                thistype this = 0;
                if (id == 0) return false;
                if (thistype.harvestTable.has(id)) {
                    this = thistype(thistype.harvestTable[id]);
                    this.destroy();
                }
                
                u = null;
                return false;
            }));
        }
    }


    private struct NatureHarvesters extends array {
        private static boolexpr harvesterFilter = null;
        private static boolexpr harvestableFilter = null;
        
        private static real currentX = 0.0;
        private static real currentY = 0.0;
    
        private static method tick() {
            group g = CreateGroup();
            
            if (thistype.harvesterFilter == null) {
                thistype.harvesterFilter = Filter(function() -> boolean {
                    return (GetUnitAbilityLevel(GetFilterUnit(), 'A02J') > 0 ||
                            GetUnitAbilityLevel(GetFilterUnit(), 'A05N') > 0);
                });
            }
            
            if (thistype.harvestableFilter == null) {
                thistype.harvestableFilter = Filter(function() -> boolean {
                    return (GetDestructableTypeId(GetFilterDestructable()) == 'ZTtc' ||
                            GetDestructableTypeId(GetFilterDestructable()) == 'ZTtw' ||
                            GetDestructableTypeId(GetFilterDestructable()) == 'Z000' ||
                            GetDestructableTypeId(GetFilterDestructable()) == 'Z002');
                });
            }
            
            GroupEnumUnitsInRect(g, GetWorldBounds(), thistype.harvesterFilter);
            
            ForGroup(g, function() {
                unit u = GetEnumUnit();
                real x = GetUnitX(u);
                real y = GetUnitY(u);
                rect r = Rect(x - 32.0, y - 32.0, x + 32, y + 32);
                real dx = 0.0;
                real dy = 0.0;
                real dist = 0.0;
                NatureHarvesterData data = NatureHarvesterData[u];
                
                thistype.currentX = 0.0;
                thistype.currentY = 0.0;
                
                EnumDestructablesInRect(r, thistype.harvestableFilter, function() {
                    thistype.currentX = GetDestructableX(GetEnumDestructable());
                    thistype.currentY = GetDestructableY(GetEnumDestructable());
                });
                
                if (thistype.currentX == 0.0 && thistype.currentY == 0.0) {
                    // No Tree Found! :(
                    data.resetTick();
                }
                else {
                    dx = GetUnitX(u) - thistype.currentX;
                    dy = GetUnitY(u) - thistype.currentY;
                    dist = SquareRoot(dx * dx + dy * dy);
                    if (dist < 1.0) {
                        // Assume on tree
                        data.tick();
                    }
                    else {
                        // Assume close but not on tree
                        data.resetTick();
                    }
                }
                
                RemoveRect(r);
                r = null;
                u = null;
            });
        
            DestroyGroup(g);
            g = null;
        }
        
        
        private static method onInit() {
            trigger t = CreateTrigger();
            TriggerRegisterTimerEvent(t, 0.5, true);
            TriggerAddAction(t, function() {
                thistype.tick();
            });
            t = null;
        }
    }
}

//! endzinc