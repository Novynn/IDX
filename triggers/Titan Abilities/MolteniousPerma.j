//! zinc

// BUG FIX!
library MolteniousUnique requires GenericTitanTargets {
    private struct MolteniousUnique {
        public static method onSetup() {
            trigger t = CreateTrigger();
            GT_RegisterLearnsAbilityEvent(t, 'TMAR');
            TriggerAddCondition(t, Condition(function() -> boolean {
                unit u = GetLearningUnit();
                integer level = GetLearnedSkillLevel();
                
                if (level == 2) {
                    SetPlayerAbilityAvailable(GetOwningPlayer(u), 'TMAR', false);
                    SetPlayerAbilityAvailable(GetOwningPlayer(u), 'TMAR', true);
                }
                
                return false;
            }));
        }
    }
    
    private function onInit(){
        MolteniousUnique.onSetup.execute();
    }
}

//! endzinc