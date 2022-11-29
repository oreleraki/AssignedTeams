class AssignedTeamsNewCTF extends NewCTF;

var AssignedTeamsConfig Config;
var AssignedTeamsUtils Utils;

event PreBeginPlay()
{
	Super.PreBeginPlay();
	Config = new class'AssignedTeamsConfig'();
	Config.SaveConfig();
	Utils = new class'AssignedTeamsUtils'();
	Utils.PrintHello(Config);
}

event PreLogin
(
	string Options,
	string Address,
	out string Error,
	out string FailCode
)
{
	local int playerTeamIndex;
	local bool matchedTeam;
	local String inPassword, gamePassword;

	if (!CheckIPPolicy(Address))
	{
		Error = IPBanned;
		return;
	}

	if (Config.bEnabled)
	{
		inPassword = ParseOption(Options, "Password");
		gamePassword = Level.ConsoleCommand("get engine.gameinfo GamePassword");
		matchedTeam = Utils.GetTeamIndex(Options, inPassword, gamePassword, Config.StrategyAssignment, playerTeamIndex);
		if (matchedTeam)
		{
			Utils.SavePlayerInfo(ParseOption(Options, "Name"), playerTeamIndex);
		}
	}

	if (!matchedTeam)
	{
		Super.PreLogin(Options, Address, Error, FailCode);
	}
}

function PlayerPawn Login
(
	string Portal,
	string Options,
	out string Error,
	class<PlayerPawn> SpawnClass
)
{
	local AssignedTeamsPlayerInfo playerInfo;

	if (Config.bEnabled)
	{
		playerInfo = Utils.PopPlayerInfo(ParseOption(Options, "Name"));
		if (playerInfo != None)
		{
			if (playerInfo.Team == -1)
			{
				// Should be spec, but is not a spec.
				// Utils.MyLog("Testing if not spec. =>"$Options);
				if (InStr(Options, "?OverrideClass=?") > 0)
				{
					Utils.MyLog("Setting player["$playerInfo.Key$"] as spectator.");
					Options = Utils.SetAsSpectatorValueInOptions(Options);
				}
			}
			else
			{
				Options = Utils.ReplaceTeamValueInOptions(Options, playerInfo.Team);
			}
		}
	}

	return Super.Login(Portal, Options, Error, SpawnClass);
}

function bool ChangeTeam(Pawn Other, int N)
{
	local bool isTeamChanged;

	isTeamChanged = true;
	if (Config.bEnabled)
	{
		isTeamChanged = Utils.ChangeTeam(Other, N);
	}

	return isTeamChanged && super.ChangeTeam(Other, N);
}