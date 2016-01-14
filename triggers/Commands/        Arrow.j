//TESH.scrollpos=66
//TESH.alwaysfold=0
//! zinc

library Arrow requires TimerUtils, CameraTweak {
    type OnKeyFunc extends function(PlayerData, string);
    
    public struct Arrow {
        private static constant integer KEY_NONE = 0;
        private static constant integer KEY_UP_PRESSED = 1;
        private static constant integer KEY_UP_DEPRESSED = 2;
        private static constant integer KEY_DOWN_PRESSED = 3;
        private static constant integer KEY_DOWN_DEPRESSED = 4;
        private static constant integer KEY_LEFT_PRESSED = 5;
        private static constant integer KEY_LEFT_DEPRESSED = 6;
        private static constant integer KEY_RIGHT_PRESSED = 7;
        private static constant integer KEY_RIGHT_DEPRESSED = 8;
        
        private static constant real RESET_DELAY = 0.5;
        
        private static string playerArrowCodes[];
        private static timer playerArrowTimers[];
        
        private static integer lastArrowKey = 0;
        
        private static OnKeyFunc onKeyFuncs[100];
        private static integer index = 0;
        
        // Registers a callback
        public static method onKeyEvent(OnKeyFunc f){
            thistype.onKeyFuncs[thistype.index] = f;
            thistype.index = thistype.index + 1;
        }
        
        public static method GetArrowKey() -> integer {
            return lastArrowKey;
        }
        
        public static method GetPlayerArrowString(player p) -> string {
            return playerArrowCodes[GetPlayerId(p)];
        }
        
        private static method onKey(player p){
            PlayerData q = PlayerData.get(p);
            OnKeyFunc f = 0;
            integer i = 0;
            for (0 <= i < thistype.index){
                f = thistype.onKeyFuncs[i];
                if (f != 0){
                    f.execute(q, GetPlayerArrowString(p));
                }
            }
            
            if (GetPlayerArrowString(p) == "^v^v"){ // UP DOWN UP DOWN
                Game.say(q.nameColored() + " just made this message appear! Maybe they found a secret?");
            }
        }

        private static method canExecute(player pl) -> boolean {
            PlayerData p = PlayerData.get(pl);
            PlayerDataPick q = 0;
            if (Game.state() != Game.STATE_STARTING) return false;
            if (RacePicker.state() != RacePicker.STATE_RUNNING) return false;
            if (p == 0) return false;
            q = PlayerDataPick[p];
            if (q == 0 || q.hasPicked()) return false;
            return true;
        }
        
        private static method keyEvent(string k){
            player p = GetTriggerPlayer();
            integer i = GetPlayerId(p);
            string c = "";
            timer t = null;
            
            if (thistype.canExecute(p)) {
                c = thistype.playerArrowCodes[i];
                
                thistype.playerArrowCodes[i] = c + k;
                thistype.onKey.execute(p);
                
                MultiboardDefender.setHeader(c + k);
            
                if (thistype.playerArrowTimers[i] != null){
                    ReleaseTimer(thistype.playerArrowTimers[i]);
                }
                thistype.playerArrowTimers[i] = NewTimer();
                
                SetTimerData(thistype.playerArrowTimers[i], i);
                TimerStart(thistype.playerArrowTimers[i], thistype.RESET_DELAY, false, function(){
                    timer t = GetExpiredTimer();
                    integer i = GetTimerData(t);
                    thistype.playerArrowCodes[i] = "";
                    MultiboardDefender.setHeader("");
                    ReleaseTimer(t);
                    t = null;
                });
            }
            t = null;
            p = null;
        }

        private static method onInit(){
            trigger t[];
            integer j = 0;
            
            t[0] = CreateTrigger();
            t[1] = CreateTrigger();
            t[2] = CreateTrigger();
            t[3] = CreateTrigger();

            for(0 <= j <= 12){
                TriggerRegisterPlayerEvent(t[0], Player(j), EVENT_PLAYER_ARROW_UP_DOWN);
                TriggerRegisterPlayerEvent(t[1], Player(j), EVENT_PLAYER_ARROW_DOWN_DOWN);
                TriggerRegisterPlayerEvent(t[2], Player(j), EVENT_PLAYER_ARROW_LEFT_DOWN);
                TriggerRegisterPlayerEvent(t[3], Player(j), EVENT_PLAYER_ARROW_RIGHT_DOWN);
            }
            TriggerAddAction(t[0], function(){              
                thistype.keyEvent("^");         // Up
            });
            TriggerAddAction(t[1], function(){              
                thistype.keyEvent("v");         // Down
            });
            TriggerAddAction(t[2], function(){              
                thistype.keyEvent("<");         // Left
            });
            TriggerAddAction(t[3], function(){              
                thistype.keyEvent(">");         // Right
            });
            

            t[0] = null;
            t[1] = null;
            t[2] = null;
            t[3] = null;
        }
    }
}

//! endzinc