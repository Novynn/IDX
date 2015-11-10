//TESH.scrollpos=72
//TESH.alwaysfold=0
//! zinc

// DOES NOT WORK DUE TO BEING UNABLE TO RESET TECH RESEARCHES
// :(

library RestartTweak requires TweakManager {
    public struct RestartTweak extends Tweak {
        module TweakModule;
        
        public method name() -> string {
            return "Restart";
        }
        public method shortName() -> string {
            return "RESTART";
        }
        public method description() -> string {
            return "Restarts the game again with all the current players.";
        }
        public method command() -> string {
            return "-restart";
        }

        private method voteSuccess(){
            this.defaultMessageVoteSuccess();
            VoteBoardGeneric.instance().done();
            Game.reset();
        }
        
        private method voteFailed(){
            this.defaultMessageVoteFailed();
        }
        
        private method vote(PlayerData p, VoteResult r){
            integer required = R2I(PlayerData.countClass(PlayerData.CLASS_DEFENDER) / 2.0);
            // Ignore votes from Minion / Titan / Observers
            if (p.class() == PlayerData.CLASS_MINION ||
                p.class() == PlayerData.CLASS_OBSERVER) return;
                
            // If the vote expired, check conditions
            if (r.expired()){
                if (r.yes(PlayerData.CLASS_DEFENDER) >= required){
                    if (r.yes(PlayerData.CLASS_TITAN) == PlayerData.countClass(PlayerData.CLASS_TITAN)){
                        this.voteSuccess();
                    }
                    else {
                        Game.say("|cff00bfffThe titan must vote too!|r");
                        this.voteFailed();
                    }
                }
                else {
                    this.voteFailed();
                }
            }
            else {
                if (r.isYes(p)){
                    this.defaultMessageVoteYes(p);
                    if (r.yes(PlayerData.CLASS_DEFENDER) >= required){
                        if (r.yes(PlayerData.CLASS_TITAN) == PlayerData.countClass(PlayerData.CLASS_TITAN)){
                            this.voteSuccess();
                        }
                        else {
                            Game.say("|cff00bfffThe titan must vote too!|r");
                        }
                    }
                    else {
                        // Display message of how many more votes are needed
                        this.defaultMessageVoteNeedMore(r.yes(PlayerData.CLASS_DEFENDER), required);
                    }
                }
                else if (r.isNo(p)){
                    this.defaultMessageVoteNo(p);
                }
            }
        }
        
        public method activate(Args args){
            PlayerData p = PlayerData.get(GetTriggerPlayer());
            boolean vote = false;

            vote = VoteBoardGeneric.instance().begin(this.name(),
                function(PlayerData p) -> boolean {
                    return true;
                }, function(VoteResult r, integer data){
                    thistype this = data;
                    PlayerData p = r.lastVoter();
                    this.vote(p, r);
            }, 30.0, this);
            if (!vote){
                this.defaultMessageVoteBusy(p);
            }
            else {
                PlaySoundBJ(gg_snd_Ready);
                this.defaultMessageVoteBegin(p);
                Game.say("|cffff0000IMPORTANT!|r|cffffff00 - The Titan and 50% of the Defenders must agree for the game to restart.|r");
                VoteBoardGeneric.instance().vote(p, "yes");
            }
        }
        public method deactivate(){
            
        }
    }
}
//! endzinc