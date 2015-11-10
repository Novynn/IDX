//TESH.scrollpos=186
//TESH.alwaysfold=0
//! zinc

library GameTimer requires TimerUtils {
    type TickFunction extends function(GameTimer);

    public struct GameTimer {
        private static thistype timerList[];
        private static integer count = 0;

        private static method add(thistype this){
            thistype.timerList[thistype.count] = this;
            thistype.count = thistype.count + 1;

            if (thistype.count > 400){
                Game.say("|cffff0000A lot of GameTimers are being created... please report this, along with the replay, as a bug. The game may start to lag soon.|r");
            }
        }
        private static method first() -> thistype {
            return thistype.at(0);
        }
        private static method at(integer i) -> thistype {
            return thistype.timerList[i];
        }
        private static method indexOf(thistype this) -> integer {
            integer i = 0;
            for (0 <= i < thistype.count){
                if (thistype.timerList[i] == this)
                    return i;
            }
            return -1;
        }
        private static method remove(thistype this) -> thistype {
            integer i = thistype.indexOf(this);
            if (i == -1) return 0;
            return thistype.removeAt(i);
            
        }
        private static method removeAt(integer i) -> thistype {
            thistype this = 0;
            if (thistype.count == 0) return 0;
            thistype.count = thistype.count - 1;
            this = thistype.timerList[i];
            thistype.timerList[i] = thistype.timerList[thistype.count];
            thistype.timerList[thistype.count] = 0;
            return this;
        }
        private integer mId = -1;
        private integer mData = 0;
        private timer mTimer = null;
        private string mName = "|cffff0000Unknown|r";
        private boolean mPeriodic = false;
        private TickFunction mFunc = 0;
        private TickFunction mCleanFunc = 0;
        private boolean mDeleting = false;
        private boolean mDeletingNow = false;
        private boolean mRunning = false;
        private integer mLooped = 0;
        private real timeout = 0.0;
        private real elapsedOffset = 0.0; // Fix for restarting a timer breaking it's elapsed time

        method looped() -> integer {
            return this.mLooped;
        }

        method cleanup(TickFunction func) -> thistype {
            this.mCleanFunc = func;
            return this;
        }
        
        public static method new(TickFunction func) -> thistype {
            thistype this = thistype.create(func);
            this.mFunc = func;
            SetTimerData(this.mTimer, this);
            return this;
        }
        
        public static method newNamed(TickFunction func, string name) -> thistype {
            thistype this = thistype.new(func);
            this.setName(name);
            return this;
        }
        
        public static method newPeriodic(TickFunction func) -> thistype {
            thistype this = thistype.new(func);
            this.setPeriodic(true);
            return this;
        }

        public static method newNamedPeriodic(TickFunction func, string name) -> thistype {
            thistype this = thistype.newNamed(func, name);
            this.setPeriodic(true);
            return this;
        }
        
        public static method create(TickFunction func) -> thistype {
            thistype this = thistype.allocate();
            this.mId = Game.id();
            this.mTimer = NewTimer();
            this.mFunc = func;
            
            thistype.add(this);

            return this;
        }
        private timerdialog mDialog = null;
        private string mDialogMessage = "";
        public method showDialog(string message){
            this.mDialogMessage = message;
            this.mDialog = CreateTimerDialog(this.mTimer);
            TimerDialogSetTitle(this.mDialog, this.mDialogMessage);
            TimerDialogDisplay(this.mDialog, true);
        }

        public method hideDialog(){
            if (this.mDialog == null) return;
            TimerDialogDisplay(this.mDialog, false);
            DestroyTimerDialog(this.mDialog);
            this.mDialog = null;
        }
        
        public method start(real timeout) -> thistype {
            this.mLooped = 0;
            this.timeout = timeout;
            TimerStart(this.mTimer, this.timeout, this.mPeriodic, function(){
                timer t = GetExpiredTimer();
                thistype this = GetTimerData(t);
                if (this != 0){
                    this.onTick();
                }
                else {
                    this.destroy();
                }
                
                t = null;
            });
            this.mRunning = true;

            // To allow chaining
            return this;
        }

        public method deleteLater(){
            this.mDeleting = true;
        }

        public method deleteNow(){
            this.mDeletingNow = true;
            this.mDeleting = true;
            this.hideDialog();
        }
        
        public method isDeleting() -> boolean {
            return this.mDeleting;
        }
        
        public method onTick(){
            if (this.mTimer == null) return;
            // Check we're in the right game instance
            if (this.mId != Game.id() || this.mDeletingNow){
                // Quit early
                this.mCleanFunc.execute(this);
                this.mRunning = false;
                this.destroy();
                return;
            }
            if (!this.mPeriodic){
                this.mRunning = false;
            }
            // Here we want to call the passed in function
            this.execute();
            // Then clean up if not periodic
            if (!this.mRunning || this.mDeleting){
                this.mCleanFunc.execute(this);
                this.mRunning = false;
                this.destroy();
                return;
            }
            if (this.mPeriodic && this.justResumed) {
                // Execute periodic timer fix by restarting the timer.
                this.start(this.timeout);
            }
            this.mLooped = this.mLooped + 1;
        }
        
        private method execute(){
            debug {
                string s = "Tick: " + this.name() + " after " + R2S(this.timeout) + "s (" + I2S(thistype.count) + " timers remaining).";
                if (this.mPeriodic) {
                    s = "|cffa0bf22" + s + "|r";
                }
                if (this.mPeriodic && this.timeout <= 1.0){
                }
                else {
                    //Game.say(s);
                }
            }
            
            this.mFunc.evaluate(this);
        }
        
        public method elapsed() -> real {
            return TimerGetElapsed(this.mTimer);
        }
        
        public method stop(){
            this.mRunning = false;
            ReleaseTimer(this.mTimer);
            this.mTimer = null;
        }
        
        public method pause(){
            this.mRunning = false;
            PauseTimer(this.mTimer);
        }
        
        private boolean justResumed = false;
        public method resume(){
            this.mRunning = true;
            if (this.mPeriodic) {
                this.justResumed = true;
            }
            ResumeTimer(this.mTimer);
        }
        
        public method setPeriodic(boolean periodic){
            this.mPeriodic = periodic;
        }
        
        public method setName(string name){
            this.mName = name;
        }

        public method name() -> string {
            return this.mName;
        }

        public method setData(integer data){
            this.mData = data;
        }

        public method data() -> integer {
            return this.mData;
        }

        public method timer() -> timer {
            return this.mTimer;
        }

        private method onDestroy(){
            if (this.mDialog != null){
                TimerDialogDisplay(this.mDialog, false);
                DestroyTimerDialog(this.mDialog);
                // Should be destroyed
                this.mDialog = null;
            }
            
            debug {
                if (this.mRunning) {
                    Game.say("DWR: " + this.name() + " after " + R2S(this.timeout) + "s (" + I2S(thistype.count) + " timers remaining).");
                }
            }

            this.mRunning = false;
            if (this.mTimer != null)
                ReleaseTimer(this.mTimer);
            this.mTimer = null;

            thistype.remove(this);

            this.mFunc = 0;
            this.mCleanFunc = 0;
        }
        
        public static method B2S(boolean b) -> string {
            if (b) return "true";
            return "false";
        }

        public static method printList(){
            thistype this = 0;
            integer i = 0;
            Game.say("Printing timer list:");
            for (0 <= i < thistype.count){
                this = thistype.at(i);
                Game.say(this.name() + ", Periodic=" + thistype.B2S(this.mPeriodic) + ", Tick=" + R2S(this.timeout));
            }
        }
        
        public static method pauseTimers(){
            thistype this = 0;
            integer i = 0;
            for (0 <= i < thistype.count){
                this = thistype.at(i);
                this.pause();
            }
        }
        
        public static method resumeTimers(){
            thistype this = 0;
            integer i = 0;
            for (0 <= i < thistype.count){
                this = thistype.at(i);
                this.resume();
            }
        }

        public static method destroyTimers(){
            thistype this = 0;

            while(thistype.count > 0){
                this = thistype.first();
                this.destroy();
                this = 0;
            }
        }
    }
}

//! endzinc