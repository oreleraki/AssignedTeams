class AssignedTeamsUtils extends Object;

var AssignedTeamsPlayerInfo PlayerInfoRoot;
var() bool Debug;

function static MyLog(coerce String S, optional name Tag)
{
	if (Tag == '')
	{
		Tag = 'AssignedTeams';
	}
	Log("++ [AssignedTeams]: "$S, Tag);
}

function SavePlayerInfo(String key, int teamIndex)
{
	local AssignedTeamsPlayerInfo newPlayer;
	newPlayer = class'AssignedTeamsPlayerInfo'.Static.Create(key, teamIndex);
	if (PlayerInfoRoot == None)
	{
		PlayerInfoRoot = newPlayer;
	}
	else
	{
		newPlayer.Next = PlayerInfoRoot;
		PlayerInfoRoot = newPlayer;
	}
}

function AssignedTeamsPlayerInfo PopPlayerInfo(String key)
{
	local AssignedTeamsPlayerInfo current;
	local AssignedTeamsPlayerInfo matchedPlayer;

	if (PlayerInfoRoot == None)
	{
		return None;
	}
	if (PlayerInfoRoot.Key == key)
	{
		matchedPlayer = PlayerInfoRoot;
		PlayerInfoRoot = PlayerInfoRoot.Next;
	}
	else 
	{
		for (current = PlayerInfoRoot; current.Next != None; current = current.Next)
		{
			if (current.Next.Key == key)
			{
				matchedPlayer = current.Next;
				current.Next = matchedPlayer.Next;
				break;
			}
		}
	}
	
	if (matchedPlayer != None)
	{
		MyLog("Matched => Key:"$matchedPlayer.Key$", Team:"$matchedPlayer.Team);
		matchedPlayer.Next = None;
	}
	return matchedPlayer;
}

function bool IsCandidateForTeamAssignment(String gamePassword, String inPassword)
{
    return inPassword != "" && InStr(gamePassword, ";") > 0;
}

function String ReplaceTeamValueInOptions(String options, int teamIndex)
{
    local int teamOptionPos, teamOptionPosEnd;

    if (InStr(options, "?Team=") > 0)
    {
        teamOptionPos = InStr(options, "?Team=");
    }
    else
    {
        teamOptionPos = InStr(options, "?team=");
    }
	teamOptionPosEnd = InStr(Mid(options, teamOptionPos+1), ";");
	
	options = Left(options, teamOptionPos)$"?Team="$teamIndex$Mid(options, teamOptionPos+teamOptionPosEnd+1);
    return options;
}

function String SetAsSpectatorValueInOptions(String options)
{
	local int pos;
	pos = InStr(options, "?OverrideClass=");
	if (pos > 0) {
		return Left(options, pos)$"?OverrideClass=Botpack.CHSpectator?"$Mid(options, pos+Len("?OverrideClass="));
	}
	return options;
}

function bool ChangeTeam(Pawn other, int desiredTeam)
{
	local PlayerPawn Player;
	local PlayerReplicationInfo PRI;
	local bool disallowChange;
	
	Player = PlayerPawn(other);
	if (Player != None)
	{
		PRI = Player.PlayerReplicationInfo;
		if (Other.IsA('Bot') || (PRI != None && PRI.Team == 255))
		{
			if (Debug)
			{
				if (PRI != None)
					MyLog("CurrentTeam:"$PRI.Team$", DesiredTeam:"$desiredTeam, Name) ;

				MyLog("ChangeTeam: "$desiredTeam, Name);
			}
		}
		else
		{
			disallowChange = true;
			if (Debug)
				MyLog("Will not ChangeTeam: "$desiredTeam, Name);
		}
	}
	return !disallowChange;
}

function bool GetTeamIndex(String options, String inPassword, String gamePassword, string strategyAssignment, out int index)
{
	local bool matchedTeam;
	local String currentPasword, gamePasswordsLeft, assignmentValue;
	local int i, seperatorPos;


	MyLog("GetTeamIndex:InPassword:"@inPassword$", GamePassword:"@gamePassword, Name);

    if (IsCandidateForTeamAssignment(gamePassword, inPassword))
	{
		gamePasswordsLeft = gamePassword;
		for (i = 0; i < Len(strategyAssignment) && Len(gamePasswordsLeft) > 0; i++)
		{
			seperatorPos = InStr(gamePasswordsLeft, ";");
			if (seperatorPos < 0)
			{
				seperatorPos = Len(gamePasswordsLeft);
			}
			currentPasword = Left(gamePasswordsLeft, seperatorPos);
			matchedTeam = currentPasword == inPassword;
			if (Debug || matchedTeam)
				MyLog("Authentication [User]=>"$inPassword$" = "$currentPasword$"<=[Position] ? "$matchedTeam, Name);

			if (matchedTeam) {
				assignmentValue = Mid(strategyAssignment, i, 1);
				if (assignmentValue == "s")
				{
					index = -1;
				}
				else
				{
					index = Int(assignmentValue);
				}
				MyLog("Authentication Success, future assigned team index: "$assignmentValue, Name);
				break;
			}
			gamePasswordsLeft = Mid(gamePasswordsLeft, seperatorPos+1);
		}
    }
	
	if (!matchedTeam)
    {
		MyLog("Passing responsability to super class.", Name);
    }
    return matchedTeam;
}

function PrintHello(AssignedTeamsConfig config)
{
	Debug = config.Debug;

    Log("");
    Log(" :======================================:");
    Log(" :    AssignedTeams v1");
    Log(" :");
    Log(" : bEnabled          	= " $ string(config.bEnabled));
    Log(" : Debug             	= " $ string(config.Debug));
    Log(" : bNoTeamChanges    	= " $ string(config.bNoTeamChanges));
    Log(" : StrategyAssignment	= " $ config.StrategyAssignment);
    Log(" :======================================:");
    Log("");
}

DefaultProperties {
	Debug=false
}