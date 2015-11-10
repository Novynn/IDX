//! textmacro InjectUpgrade takes ID, X, Y, NAME, ICON, TIME, HOTKEY, TIP, DETAIL, REQ, GOLD, WOOD
	//! externalblock extension=lua ObjectMerger $FILENAME$
	
	//! i reqf = "$REQ$"
	//! i req = ""
	//! i reqLevels = ""
	//! i for part in (reqf .. ","):gmatch('([^,]*),') do
	//! i   if part ~= nil and part ~= '' then
    //! i     i, j = string.find(part, '_')
	//! i     thisReq = string.sub(part, 1, i - 1)
	//! i     thisLevel = string.sub(part, j + 1)
	//! i     print(thisReq .. "_" .. thisLevel)
	//! i     req = req .. thisReq .. ","
	//! i     reqLevels = reqLevels .. thisLevel .. ","
	//! i   end
	//! i end
	//! i if string.len(req) > 0 and string.len(reqLevels) > 0 then
	//! i   req = string.sub(req, 1, -2)
	//! i   reqLevels = string.sub(reqLevels, 1, -2)
	//! i end
	//! i setobjecttype("units")
	//! i createobject("ncop", "$ID$")
	//! i makechange(current, "uabi", "Aloc,Avul,UPGR")
	//! i makechange(current, "ubpx", $X$)
	//! i makechange(current, "ubpy", $Y$)
	//! i makechange(current, "ushr", 0)
	//! i makechange(current, "uico", "$ICON$")
	//! i makechange(current, "umdl", "Doodads\\LordaeronSummer\\Props\\PeasantGrave\\PeasantGrave.mdl")
	//! i makechange(current, "usca", 0.10)
	//! i makechange(current, "uspe", 1)
	//! i makechange(current, "umvt", "fly")
	//! i makechange(current, "ucol", 0.00)
	//! i makechange(current, "usnd", " ")
	//! i makechange(current, "ubld", $TIME$)
	//! i makechange(current, "uhom", 1);
	//! i makechange(current, "ubdg", 0);
	//! i makechange(current, "upoi", 0);
	//! i makechange(current, "usid", 1);
	//! i makechange(current, "usin", 1);
	//! i makechange(current, "ides", " ")
	//! i makechange(current, "uhot", "$HOTKEY$")
	//! i makechange(current, "unam", "$NAME$")
	//! i makechange(current, "unsf", "(4.0.0 - Triggered Upgrade)")
	//! i makechange(current, "utip", "$TIP$")
	//! i makechange(current, "utub", "$DETAIL$")
	//! i makechange(current, "ureq", req)
	//! i makechange(current, "urqa", reqLevels)
	//! i makechange(current, "ulum", $WOOD$)
	//! i makechange(current, "ugol", $GOLD$)

	//! endexternalblock
//! endtextmacro