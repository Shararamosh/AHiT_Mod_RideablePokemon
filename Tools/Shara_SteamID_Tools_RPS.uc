class Shara_SteamID_Tools_RPS extends Object
	abstract;

/*	
	This class includes functions that are dealing with players' Steam IDs, indexes and Controllers.
	RPS suffix means RideablePokemon_Script.
	All functions are written by Shararamosh.
	Last edited: 13.02.2023 22:45 GMT+3.
*/

static function string GetMySteamID() //Returns your Steam ID.
{
	local OnlineSubsystemCommonImpl OnlineSubsystem;
	OnlineSubsystem = OnlineSubsystemCommonImpl(class'GameEngine'.static.GetOnlineSubsystem());
	if (OnlineSubsystem == None)
		return "";
	return OnlineSubsystem.GetUserCommunityID();
}

static function string GetOtherSteamID(Hat_GhostPartyPlayerStateBase s) //Returns Steam ID from Hat_GhostPartyPlayerStateBase.
{
	if (s != None)
		return s.GetNetworkingIDString();
	return "";
}

static function bool GetPlayerInfo(Actor a, out string SteamID, out int PlayerIndex) //Returns Hat_Player's and Hat_GhostPartyPlayer's Steam ID and player index as out parameters and true if these parameters have passed proof-check.
{
	local Hat_GhostPartyPlayer gpp;
	local Hat_Player ply;
	SteamID = "";
	PlayerIndex = -1;
	gpp = Hat_GhostPartyPlayer(a);
	if (gpp != None)
	{
		if (gpp.PlayerState != None)
		{
			SteamID = GetOtherSteamID(gpp.PlayerState);
			PlayerIndex = gpp.PlayerState.SubID;
			return IsCorrectPlayerIndex(PlayerIndex) && IsCorrectSteamID(SteamID);
		}
		return false;
	}
	ply = GetPlayerPawn(a);
	if (ply == None)
		return false;
	PlayerIndex = GetPawnPlayerIndex(ply);
	SteamID = GetMySteamID();
	return IsCorrectPlayerIndex(PlayerIndex) && IsCorrectSteamID(SteamID);
}

static function PlayerController GetPlayerController(Object o) //Returns PlayerController. Input parameter can be HUD, Pawn, PlayerReplicationInfo, PlayerController and Player.
{
	local PlayerController pc;
	local HUD H;
	local PlayerReplicationInfo PRI;
	local Player EnginePlayer;
	local Pawn p;
	pc = PlayerController(o);
	if (pc != None)
		return pc;
	p = Pawn(o);
	if (p != None)
		return GetPawnPlayerController(Pawn(o));
	H = HUD(o);
	if (H != None)
		return H.PlayerOwner;
	PRI = PlayerReplicationInfo(o);
	if (PRI != None)
		return GetPlayerController(PRI.Owner);
	EnginePlayer = Player(o);
	if (EnginePlayer != None)
		return EnginePlayer.Actor;
	return None;
}

static function Controller GetPawnController(Pawn p, optional out Array<Pawn> IteratedPawns) //Will return the first found Controller, not necessarily PlayerController. IteratedPawns is used to prevent infinite loop when iterating Vehicle's Driver and Pawn's DrivenVehicle.
{
	local Controller c;
	local Vehicle v;
	if (p == None)
		return None;
	if (p.Controller != None)
		return p.Controller;
	if (IteratedPawns.Find(p) == INDEX_NONE)
		IteratedPawns.AddItem(p);
	else
		return None;
	v = Vehicle(p);
	if (v != None)
	{
		c = GetPawnController(v.Driver, IteratedPawns);
		if (c != None)
			return c;
	}
	return GetPawnController(p.DrivenVehicle, IteratedPawns);
}

static function PlayerController GetPawnPlayerController(Pawn p, optional out Array<Pawn> IteratedPawns) //Returns PlayerController for Pawn. Will check Pawn itself and DrivenVehicle for PlayerController. IteratedPawns is used to prevent infinite loop when iterating Vehicle's Driver and Pawn's DrivenVehicle.
{
	local PlayerController pc;
	local Vehicle v;
	if (p == None)
		return None;
	pc = PlayerController(p.Controller);
	if (pc != None)
		return pc;
	if (p.PlayerReplicationInfo != None)
	{
		pc = PlayerController(p.PlayerReplicationInfo.Owner);
		if (pc != None)
			return pc;
	}
	if (IteratedPawns.Find(p) == INDEX_NONE)
		IteratedPawns.AddItem(p);
	else
		return None;
	v = Vehicle(p);
	if (v != None)
	{
		pc = GetPawnPlayerController(v.Driver, IteratedPawns);
		if (pc != None)
			return pc;
	}
	return GetPawnPlayerController(p.DrivenVehicle, IteratedPawns);
}

static function int GetPawnPlayerIndex(Pawn p) //Returns player index of Pawn by first finding PlayerController of it.
{
	return GetPlayerIndex(GetPawnPlayerController(p));
}

static function int GetPlayerIndex(PlayerController pc) //Returns player index of PlayerController by either casting to Hat_PlayerController_Base or GamePlayerController or by checking Engine.GamePlayers Array.
{
	local GamePlayerController gpc;
	local Hat_PlayerController_Base hpcb;
	local Engine e;
	local int i;
	if (pc == None)
		return -1;
	gpc = GamePlayerController(pc);
	if (gpc != None)
	{
		hpcb = Hat_PlayerController_Base(gpc);
		if (hpcb != None)
			return hpcb.GetPlayerIndex();
		return gpc.GetUIPlayerIndex();
	}
	e = class'Engine'.static.GetEngine();
	if (e == None)
		return -1;
	for (i = 0; i < e.GamePlayers.Length; i++)
	{
		if (e.GamePlayers[i] == None)
			continue;
		if (e.GamePlayers[i].Actor == pc)
			return i;
	}
	return -1;
}

static function PlayerController GetPlayerByIndex(int PlayerIndex) //Returns PlayerController that corresponds to this player index.
{
	local PlayerController pc;
	local Engine e;
	if (!IsCorrectPlayerIndex(PlayerIndex))
		return None;
	pc = class'Hat_PlayerController_Base'.static.GetPlayerByIndex(PlayerIndex);
	if (pc != None)
		return pc;
	e = class'Engine'.static.GetEngine();
	if (e == None)
		return None;
	if (e.GamePlayers.Length <= PlayerIndex)
		return None;
	if (e.GamePlayers[PlayerIndex] == None)
		return None;
	return e.GamePlayers[PlayerIndex].Actor;
}

static function Pawn GetPawn(Object o) //Returns ANY Pawn, including Vehicle and Hat_Player. Input parameter can be Pawn, Controller, HUD, PlayerReplicationInfo, PlayerController and Player.
{
	local Controller c;
	local Pawn p;
	local HUD H;
	local PlayerReplicationInfo PRI;
	local Hat_PlayerReplicationInfo HPRI;
	local Player EnginePlayer;
	if (o == None)
		return None;
	p = Pawn(o);
	if (p != None)
		return p;
	c = Controller(o);
	if (c != None)
		return c.Pawn;
	H = HUD(o);
	if (H != None)
		return GetPawn(H.PlayerOwner);
	PRI = PlayerReplicationInfo(o);
	if (PRI != None)
	{
		HPRI = Hat_PlayerReplicationInfo(PRI);
		if (HPRI != None && HPRI.PlyOwner != None)
			return HPRI.PlyOwner;
		return GetPawn(PRI.Owner);
	}
	EnginePlayer = Player(o);
	if (EnginePlayer != None)
		return GetPawn(EnginePlayer.Actor);
	return None;
}

static function Pawn GetNonVehiclePawn(Object o, optional out Array<Vehicle> IteratedVehicles) //Returns ONLY NON-VEHICLE Pawn, including Hat_Player. Uses GetPawn function to get the result and then checks whether it's a Vehicle. IteratedPawns is used to prevent infinite loop when iterating Vehicle's Driver and Pawn's DrivenVehicle.
{
	local Pawn p;
	local Vehicle v;
	p = GetPawn(o);
	if (p == None)
		return None;
	v = Vehicle(o);
	if (v == None)
		return p;
	if (IteratedVehicles.Find(v) == INDEX_NONE) //Preventing a chain of Vehicles that have Driver set as another Vehicle (or itself). This should NEVER occur.
		IteratedVehicles.AddItem(v);
	else
		return None;
	return GetNonVehiclePawn(v.Driver, IteratedVehicles);
}

static function Hat_Player GetPlayerPawn(Object o) //Returns Hat_Player Actor. Simply casts result of GetNonVehiclePawn to Hat_Player.
{
	return Hat_Player(GetNonVehiclePawn(o));
}

static function InventoryManager GetPawnInventoryManager(Pawn p) //Returns InventoryManager Actor. Tries to find InventoryManager from Hat_PlayerReplicationInfo too.
{
	local Hat_PlayerReplicationInfo HPRI;
	if (p == None)
		return None;
	if (p.InvManager != None)
		return p.InvManager;
	HPRI = Hat_PlayerReplicationInfo(p.PlayerReplicationInfo);
	if (HPRI != None && HPRI.InvManager != None)
		return HPRI.InvManager;
	return None;
}

static function int GetOtherPlayerIndex(Hat_Player ply) //Returns player index of another player (in Co-op or whatever).
{
	local int i;
	local PlayerController pc;
	local Hat_PlayerController_Base hpcb;
	local Engine e;
	if (ply == None)
		return -1;
	pc = GetPawnPlayerController(ply);
	if (pc == None)
		return -1;
	hpcb = Hat_PlayerController_Base(pc);
	if (hpcb != None)
		return hpcb.GetOtherPlayerIndex();
	e = class'Engine'.static.GetEngine();
	if (e == None)
		return -1;
	for (i = 0; i < e.GamePlayers.Length; i++)
	{
		if (e.GamePlayers[i] == None)
			continue;
		if (e.GamePlayers[i].Actor == None)
			continue;
		if (e.GamePlayers[i].Actor == pc)
			continue;
		return i;
	}
	return -1;
}

static function bool IsCorrectPlayerIndex(int n) //Very obvious check: player index can't be lower than 0.
{
	if (n < 0)
		return false;
	return true;
}

static function bool IsCorrectSteamID(string s) //Checks if the length is exactly 17 symbols and each symbol is a 0-9 number.
{
	if (Len(s) != 17)
		return false;
	if (!IsStringNumber(s))
		return false;
	return true;
}

static function bool IsCharNumber(string s) //Is this exactly a 0-9 number?
{
	switch(s)
	{
		case "0":
			return true;
		case "1":
			return true;
		case "2":
			return true;
		case "3":
			return true;
		case "4":
			return true;
		case "5":
			return true;
		case "6":
			return true;
		case "7":
			return true;
		case "8":
			return true;
		case "9":
			return true;
		default:
			return false;
	}
}

static function bool IsStringNumber(string s) //Is whole string a number?
{
	local int i;
	local string StringLetter;
	for (i = 0; i < Len(s); i++)
	{
		StringLetter = Mid(s, i, 1);
		if (IsCharNumber(StringLetter))
			continue;
		return false;
	}
	return true;
}

static function bool WhichSteamIDIsBigger(string s1, string s2, out string LongerID) //GUYS, WE HAVE KILLED MODDING!!! REMEMBER??? That's why we can't have Steam IDs as integers! :hueh:
{
	local Array<int> s1Chars, s2Chars;
	local string s1Letter, s2Letter;
	local int i;
	if (Len(s1) != 17 || Len(s2) != 17)
		return false;
	for (i = 0; i < 17; i++)
	{
		s1Letter = Mid(s1, i, 1);
		s2Letter = Mid(s2, i, 1);
		if (!IsCharNumber(s1Letter) || !IsCharNumber(s2Letter))
			return false;
		s1Chars.AddItem(int(s1Letter));
		s2Chars.AddItem(int(s2Letter));
	}
	for (i = 0; i < 17; i++)
	{
		if (s1Chars[i] > s2Chars[i])
		{
			LongerID = s1;
			return true;
		}
		if (s2Chars[i] > s1Chars[i])
		{
			LongerID = s2;
			return true;
		}
	}
	return false;
}