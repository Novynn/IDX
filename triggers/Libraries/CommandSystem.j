//TESH.scrollpos=67
//TESH.alwaysfold=0
/*
	CommandParser v1.33
		by quraji

		About:
			CommandParser is an easy to use system that allows you to register functions to a chat command. When a player enters that command,
			the functions will be called and passed an array of the entered arguments. You may then access these arguments in string form, 
			or have the system try to typecast the argument into another type (as of right now, those are integer, real, boolean and player).
			Read below for more details and usage examples.
			
		Config:
			You will find configuration constants at the top of the library. Change them only if you know what you're doing.
			
			constant boolean START_PLAYER_INDECES_AT_ZERO = false;
				If false, player indeces start at 1, otherwise they start at 0. Keep this as false if you want "1" to be player 1 (red).
				Change to true if you want "1" to be player 2 (blue).
			
			constant string ARG_DELIMITER = " ";
				This defines the string that separates arguments in a command. The default is the space character.
				ARG_DELIMITER is automatically appended to the command when it is registered.
				You can change this if you feel the need.
			
			constant boolean DEFAULT_PERMISSION = true;
				This defines the default permission for all players when a command is registered. If true, all players
				may activate the command as soon as it is created. If false, you must allow certain players to use it yourself
				using the functions below.

		Command Functions:
			These are the functions you use to implement the system. x is any string you want to use for a command, like "-mycommand".
			
			Command[x].register(commandFunc func)
				Call this to register a function to command x. This function must take type Args and return nothing.
				Ex:
				function myfunc takes Args args returns nothing
					//stuff
				endfunction
				
				function registercommand takes nothing returns nothing
					call Command["-mycommand"].register(myfunc)
				endfunction
				
				Note: Only one function at a time may be registered to a command (this may change)
				
			Command[x].unregister(commandFunc func)
				Unregisters the function func from the command x.
				
			Command[x].enable(boolean flag)
				Enables the command x if flag is true, else disables the command.
				
			Command[x].isEnabled() -> boolean
				Returns true if the command is enabled, false if it isn't.
				
			Command[x].setPermission(player p, boolean flag)
				Enables the command for player p if flag is true, or disables it if false.
			
			Command[x].setPermissionAll(boolean flag)
				Allows the command for all players if flag is true, else disallows it for all players.
				
			Command[x].getPermission(player p) -> boolean
				Returns true if the command is enabled for player p, false if not.
		
			Command[x].remove() or Command[x].destroy()
				Removes the command entirely.

			GetEnteredCommand() -> string
				Call this from within your commandFunc to get the command string that was entered.
			
		Args Methods:
			These are methods that you may use within your callback function on the Args parameter. x is the array index of the argument you want.
			x can be an integer from 0 (the first argument) to args.size()-1 (the last argument).
			
			args.size() -> integer
				Returns the size of the array.
			
			args[x].getStr() -> string
				This will return a string matching the argument as the player typed it.
			
			args[x].isBool() -> boolean
				This will return true if the argument can be interpreted as a boolean (it is "true", "false", "yes", "no", "on", "off", "1", or "0").
				It will return false otherwise.
			
			args[x].getBool() -> boolean
				Will return true if the argument is "true", "yes", "no", or "1". Will return false if is "false", "no", "off", "0", or something undefined.
				You should use .isBool() first to see if it is a boolean value.
				
			args[x].isInt() -> boolean
				Will return true if the argument is an integer value, or false if it isn't.
				
			args[x].getInt() -> integer
				Will return the integer value of the argument. You should use .isInt() first to see if it is an integer.
				If you use this and the argument is not an integer, it will return 0
				
			args[x].isReal() -> boolean
				Will return true if the argument is a real value (an integer or a number with a decimal point), or false if it isn't.
				
			args[x].getReal() -> real
				Will return the real value of the argument. You should use .isReal() first to see if it is a real.
				If you use this and the argument is not a real, it will return 0.000
				
			args[x].isPlayer() -> boolean
				Will return true if the arg can be interpreted as a player (it is a player number, name or color).
				This will recognize if an argument is only a substring at the start of a player's name ("worl" can match "WorldEdit").
				Returns false if not.
				
			args[x].getPlayer() -> player
				Will return the a player matching the argument. You should use .isPlayer() first to see if it may be interpreted as a player.
				This will recognize if an argument is only a substring at the start of a player's name ("worl" can match "WorldEdit").
				If you use this and the system can't find a matching player, it returns null.
				
		Useage:
			Once you register a function to a command, that function will be called when a player enters the command.
			A pseudo-array of type Args holding the entered parameters will be passed to the function, which you can then access, just like an array.
			You may use the .size() method to get the size of the array.
			Ex:
			function mycommandfunc takes Args args returns nothing
				local integer i = 0
				
				// this loop displays all the arguments that the player entered
				loop
					exitwhen (i==args.size())
					call BJDebugMsg(args[i].getStr())
					set i = i + 1
				endloop
			endfunction
		
		Notes:
			You may use GetTriggerPlayer() to get the player who entered the command.
			You may use waits inside the callback function, but be aware both GetTriggerPlayer() and the Args array will not persist after it, 
			so if you need to use a wait make sure you save all the values you want to keep in variables beforehand.
		
		Thanks:
			Executor for pointing out a bug that allowed multiple commands to execute if a command contained another command inside it.
			Prozix for inspiring me to add argument type-checking and type-casting.
					
		And that's it.
*/

//! zinc
library CommandParser requires Ascii, GetPlayerActualName
// v1.33 - by quraji
{
	/* CONFIG */
	
	// If false, "1" refers to Player 1 (red), if true "1" refers to Player 2 (blue).
	// default value: false
	constant boolean START_PLAYER_NUMBERS_AT_ZERO = true;
	
	// The string that separates arguments when a command is typed.
	// default value: " "
	constant string ARG_DELIMITER = " ";
	
	// The default permission for all players when a command is first registered.
	// If true, all players have access to any new command by default.
	// default value: true
	constant boolean DEFAULT_PERMISSION = true;
	
	/* ENDCONFIG */

	private constant string MSG_COLOR = "|cffCC33CC";

	// Display a CommandParser error.
	private function msg_error (string msg)
	{
		DisplayTimedTextToPlayer(GetLocalPlayer(), .0, .0, 60., MSG_COLOR + "CommandParser Error:|r " + msg);
	}
	// Display a CommandParser warning.
	private function msg_warning (string msg)
	{
		DisplayTimedTextToPlayer(GetLocalPlayer(), .0, .0, 60., MSG_COLOR + "CommandParser Warning:|r " + msg);
	}	
	
	// Global string to record the entered command, and the function to return it
	string EnteredCommand;
	public function GetEnteredCommand()-> string { return EnteredCommand; }

	// Function interface for functions to run on command
	public type commandFunc extends function(Args);
	
	// Struct to store/typecheck/typecast values
	public struct ArgsValue
	{
		private static string DEF_BOOL_TRUE[], DEF_BOOL_FALSE[];
		private static constant integer DEF_BOOL_SIZE = 4;
		
		private static string DEF_PLAYERCOLORS[];
		private static constant integer DEF_PLAYERCOLORS_SIZE = 15;
		
		private static integer MIN_PLAYER_INDEX = 1, MAX_PLAYER_INDEX = 12;
		
		private string source;
		
		// Returns the source string
		method getStr ()-> string
		{
			return source;
		}
		
		// Checks to see if source can be interpreted as a boolean.
		// Returns true if source can be found in the array of "true" definitions, false if not.
		method isBool ()-> boolean
		{
			integer i;
			string s = StringCase(source, false);
			for (i=0; i<DEF_BOOL_SIZE; i+=1)
			{
				if (s==DEF_BOOL_TRUE[i] || s==DEF_BOOL_FALSE[i])
					return true;
			}
			return false;
		}
		
		// Returns a boolean value interpreted from source.
		// Returns true if source is found to be a "true" value, false otherwise.
		method getBool ()-> boolean
		{
			integer i;
			string s = StringCase(source, false);
			for (i=0; i<DEF_BOOL_SIZE; i+=1)
			{
				if (s==DEF_BOOL_TRUE[i])
					return true;
			}
			return false;
		}
		
		
		// Checks to see if source can be interpreted as an integer.
		// Returns true if it only contains number characters, false if not.
		method isInt ()-> boolean
		{
			string s = source;
			integer ascii;
			while (s!="")
			{
				ascii = Char2Ascii(SubString(s, 0, 1));
				s = SubString(s, 1, StringLength(s));
				if (!(ascii>=48 && ascii<=57)) // 0-9
					return false;
			}
			return true;                                                       
		}
		
		// Returns source as an integer.
		// Returns 0 if source can't be interpreted as an integer.
		method getInt ()-> integer
		{
			return S2I(source);
		}
		
		// Checks to see if source can be interpreted as a real.
		// Returns true if source only contains number characters, and at max 1 decimal point.
		method isReal ()-> boolean
		{
			string s = source;
			integer ascii, decimal_count = 0;
			while (s!="")
			{
				ascii = Char2Ascii(SubString(s, 0, 1));
				s = SubString(s, 1, StringLength(s));
				if (ascii==46) // decimal point
					decimal_count+=1;
				else if (!(ascii>=48 && ascii<=57)) // 0-9
					return false;
			}
			return (decimal_count<=1); // no self respecting real number has more than one decimal point
		}
		
		// Returns source as a real.
		// Returns 0.000 if source can't be interpreted as a real.
		method getReal ()-> real
		{
			return S2R(source);
		}
		
		// Checks to see if source can be interpreted as a player.
		// Returns true if source matches a player number 1-12, or 0-11 if START_PLAYER_NUMBERS_AT_ZERO is true.
		// Returns true if source matches a player color.
		// Returns true if source matches a player's name, or is a substring at the start of a player's name.
		method isPlayer ()-> boolean
		{
			integer i, length;
			string s = StringCase(source, false);
			
			// check if source is a player number
			if (isInt())
			{
				i = getInt();
				if (i>=MIN_PLAYER_INDEX && i<=MAX_PLAYER_INDEX)
					return true;
			}
			// check if source is a player color
			for (i=0; i<DEF_PLAYERCOLORS_SIZE; i+=1)
			{
				if (s==DEF_PLAYERCOLORS[i])
					return true;
			}
			// check to see if source matches or starts a player name
			length = StringLength(s);
			for (i=0; i<bj_MAX_PLAYERS; i+=1)
			{
				if (s==SubString(StringCase(GetPlayerActualName(Player(i)), false), 0, length))
					return true;
			}
			return false;
		}
		
		// Returns source as a player.
		// Returns null if source can not be interpreted as a player.
		method getPlayer ()-> player
		{
			integer i, j, length;
			string s = StringCase(source, false);
			
			// check if source is a player number
			if (isInt())
			{
				i = getInt();
				if (i>=MIN_PLAYER_INDEX && i<=MAX_PLAYER_INDEX)
					return Player(i-MIN_PLAYER_INDEX);
			}
			
			if (s==DEF_PLAYERCOLORS[12]) // cyan -> teal
			{
				s = DEF_PLAYERCOLORS[2];
			}
			if (s==DEF_PLAYERCOLORS[13]) // grey -> gray
			{
				s = DEF_PLAYERCOLORS[8];
			}
            if (s==DEF_PLAYERCOLORS[14]){ // lb -> lightblue
                s = DEF_PLAYERCOLORS[9];
            }
			// check if source is a player color
			for (i=0; i<bj_MAX_PLAYERS; i+=1)
			{
				if (s==DEF_PLAYERCOLORS[i])
				{
					for (j=0; j<bj_MAX_PLAYERS; j+=1)
					{
						if (GetPlayerColor(Player(j))==ConvertPlayerColor(i))
						{
							return Player(j);
						}
					}
				}
			}
			
			// Check if source matches or starts a player name
			length = StringLength(s);
			for (i=0; i<bj_MAX_PLAYERS; i+=1)
			{
				if (s==SubString(StringCase(GetPlayerActualName(Player(i)), false), 0, length))
					return Player(i);
			}
			
			return null;
		}
		
		// Deallocate this struct and it's child.
		method destroy ()
		{
			deallocate();
		}
		
		// Allocate thistype struct.
		static method create (string s)-> thistype
		{
			thistype vi = thistype.allocate();
			vi.source = s;
			return vi;
		}
		
		// Initialize data
		private static method onInit ()
		{
			// stole these definitions from Prozix :)
			DEF_BOOL_TRUE[0] = "true";
			DEF_BOOL_TRUE[1] = "yes";
			DEF_BOOL_TRUE[2] = "1";
			DEF_BOOL_TRUE[3] = "on";
			DEF_BOOL_FALSE[0] = "false";
			DEF_BOOL_FALSE[1] = "no";
			DEF_BOOL_FALSE[2] = "0";
			DEF_BOOL_FALSE[3] = "off";
			
			// player color strings
			DEF_PLAYERCOLORS[0] = "red";
			DEF_PLAYERCOLORS[1] = "blue";
			DEF_PLAYERCOLORS[2] = "teal";
			DEF_PLAYERCOLORS[3] = "purple";
			DEF_PLAYERCOLORS[4] = "yellow";
			DEF_PLAYERCOLORS[5] = "orange";
			DEF_PLAYERCOLORS[6] = "green";
			DEF_PLAYERCOLORS[7] = "pink";
			DEF_PLAYERCOLORS[8] = "gray";
			DEF_PLAYERCOLORS[9] = "lightblue";
			DEF_PLAYERCOLORS[10] = "darkgreen";
			DEF_PLAYERCOLORS[11] = "brown";
			
			// extra spellings..
			DEF_PLAYERCOLORS[12] = "cyan";
			DEF_PLAYERCOLORS[13] = "grey";
            DEF_PLAYERCOLORS[14] = "lb";
			
			static if (START_PLAYER_NUMBERS_AT_ZERO)
			{
				MIN_PLAYER_INDEX = 0;
				MAX_PLAYER_INDEX = 11;
			}
		}
	}
	
	// List of ArgsValue structs
	public struct Args
	{
		private thistype last;
		private thistype next;
		private ArgsValue arg;
        private string cmd;
        
        method command() -> string {
            return cmd;
        }
		
		private integer list_size;
		method size ()-> integer { return list_size; }
			
		method operator[] (integer index)-> ArgsValue
		{
			thistype a = this;
			integer i = 0;
			if (index<0 || index>size())
			{
				debug msg_error("Attempt to access Args element out of bounds.");
				return 0;
			}
			while (i<=index)
			{
				a = a.next;
				i +=1;
			}
			return a.arg;
		}
		
		// Allocate a new node, add it to the list and set it's value.
		method add_arg (string s)
		{
			thistype a = thistype.allocate();
			last.next = a;
			last = a;
			a.next = -1;
			a.arg = ArgsValue.create(s);
			list_size += 1;
		}
		
		// Deallocate this struct, and members of it's list.
		method destroy ()
		{
			thistype a = this, b;
			while (a.next!=-1)
			{
				a = a.next;
				b = a;
				a.deallocate();
				a = b;
			}
			deallocate();
		}
		
		// Allocate thistype and initialize variables.
		static method create (string command)-> thistype
		{
			thistype a = thistype.allocate();
			a.last = a;
            a.cmd = command;
			a.next = -1;
			a.list_size = 0;
			return a;
		}
	}
	
	// List of commandFuncs
	struct Commandfuncs
	{
		private thistype last;
		private thistype next;
		private commandFunc func;
		
		private integer list_size;
		method size ()-> integer { return list_size; }
			
		// Executes all commandFuncs in the list
		method execute (Args args)
		{
			thistype c = this;
			while (c.next!=-1)
			{
				c = c.next;
				c.func.execute(args);
			}
		}
		
		// Attempts to find f in the list. If it is found, it is removed.
		method remove_func (commandFunc f)
		{
			thistype prev, c = this;
			while (c.next!=-1)
			{
				prev = c;
				c = c.next;
				if (c.func==f) // f was found, unlink it.
				{
					prev.next = c.next;
					c.deallocate();
					list_size -= 1;
					return;
				}
			}
			debug msg_warning("Attempt to unregister a function that didn't exist from a command.");
		}
			
		
		// Allocate a new node, add it to the list and set it's value.
		method add_func (commandFunc f)
		{
			thistype c = this;
			// Check for duplicate function
			while (c.next!=-1)
			{
				c = c.next;
				if (c.func == f)
				{
					debug msg_warning("Attempt to register function twice to a command.");
					return;
				}
			}
			// A duplicate was not found, allocate the node
			c = thistype.allocate();
			last.next = c;
			last = c;
			c.next = -1;
			c.func = f;
			list_size += 1;
		}
		
		// Deallocate this struct, and members of it's list.
		method destroy ()
		{
			thistype a = this, b;
			while(a.next!=-1)
			{
				a = a.next;
				b = a;
				a.deallocate();
				a = b;
			}
			deallocate();
		}
		
		// Allocate thistype and initialize variables.
		static method create ()-> thistype
		{
			thistype c = thistype.allocate();
			c.last = c;
			c.next = -1;
			c.list_size = 0;
			return c;
		}
		
	}

	public struct Command
	{
		private static hashtable Table = InitHashtable();
		private static key KEY_COMMANDS;

		private trigger trig;
		private Commandfuncs funcs;
		private string cmd;
		private boolean player_permissions[12];
		
		static method operator[] (string s) -> thistype
		{
			thistype c = thistype(LoadInteger(Table, KEY_COMMANDS, StringHash(s)));
			if (integer(c)==0)
			{
				// c doesn't exist, create it
				c = thistype.create(s);
			}
			return c;
		}
		
		private static method parse (Args args, string input)
		{
			integer i = 0;
			while(i<StringLength(input))
			{
				if (SubString(input, i, i+1)==ARG_DELIMITER)
				{
					if (i>0) // there's something before the delimiter
					{
						args.add_arg(SubString(input, 0, i));
					}
					input = SubString(input, i+1, StringLength(input));
					i = -1;
				}
				i += 1;
			}
			if (i>0) // there's stuff left
			{
				args.add_arg(input);
			}
		}
		
		private static method onChat ()-> boolean
		{
			Args args;
			string input = GetEventPlayerChatString();
			string command = GetEventPlayerChatStringMatched();
			thistype c;
			
			// the command was found in the input, but it isn't the first thing, so exit
			if (SubString(input, 0, StringLength(command))!=command) 
				return false;
                
            // only continue if the chat message matches:
            // -command<ARG_DELIMITER>... or
            // -command<ENDL>
            if (StringLength(input) > StringLength(command) &&
                SubString(input, 0, StringLength(command) + 1) != command + ARG_DELIMITER){
                return false;
            }

            EnteredCommand = SubString(input, 0, StringLength(command));
            command = EnteredCommand;
            c = thistype(LoadInteger(Table, KEY_COMMANDS, StringHash(command)));
            
            // the player is not allowed to use this command, exit
            if (c.player_permissions[GetPlayerId(GetTriggerPlayer())]==false) 
                return false;
            
            input = SubString(input, StringLength(command), StringLength(input));
            
            args = Args.create(command);
            parse(args, input);
            c.funcs.execute(args);
            args.destroy();
			
			return false;
		}
		
		private static method create (string s)-> thistype
		{
			thistype c = thistype.allocate();
			integer i;
			
			// create the trigger and register the chat event for it
			c.trig = CreateTrigger();
			for (i=0; i<bj_MAX_PLAYERS; i+=1)
			{
				TriggerRegisterPlayerChatEvent(c.trig, Player(i), s, false);
				c.player_permissions[i] = DEFAULT_PERMISSION;
			}
			TriggerAddCondition(c.trig, static method thistype.onChat);
			
			c.funcs = funcs.create();
			c.cmd = s;
			
			SaveInteger(Table, KEY_COMMANDS, StringHash(c.cmd), integer(c)); // save the struct into the table, using the command string as a key
			
			return c;
		}
		
		method destroy ()
		{
			RemoveSavedInteger(Table, KEY_COMMANDS, StringHash(cmd));
			DisableTrigger(trig);
			DestroyTrigger(trig);
			funcs.destroy();
			deallocate();
		}
		method remove () { destroy(); } // alias for destroy
		
		// enable/disable the command
		method enable (boolean flag)
		{
			if (flag) EnableTrigger(trig);
			else DisableTrigger(trig);
		}
		// get whether or not the command is enabled
		method isEnabled ()-> boolean
		{
			return IsTriggerEnabled(trig);
		}
		
		// set permission for all players
		method setPermissionAll (boolean flag)
		{
			integer i;
			for (i=0; i<bj_MAX_PLAYERS; i+=1)
			{
				player_permissions[i] = flag;
			}
		}
		// set permission to use a command for one player
		method setPermission (player p, boolean flag)
		{
			player_permissions[GetPlayerId(p)] = flag;
		}
		// get command permission for a player
		method getPermission (player p)-> boolean
		{
			return player_permissions[GetPlayerId(p)];
		}
		
		// register a func to the command
		method register (commandFunc func)
		{
			if (func == 0)
			{
				debug msg_warning("Attempt to register a null commandFunc to command: \""+cmd+"\"");
			}
			else
			{
				funcs.add_func(func);
			}
		}
		// unregister a func from the command
		method unregister (commandFunc func)
		{
			if (func == 0)
			{
				debug msg_warning("Attempt to unregister a null commandFunc from command: \""+cmd+"\"");
			}
			else
			{
				funcs.remove_func(func);
				if (funcs.size()==0)
				{
					destroy();
				}
			}
		}	
	}
}
//! endzinc