class AssignedTeamsPlayerInfo extends Actor;

var AssignedTeamsPlayerInfo Next;
var string Key;
var int Team;

// Methods
static function AssignedTeamsPlayerInfo Create(String key, int team, optional AssignedTeamsPlayerInfo next)
{
	local AssignedTeamsPlayerInfo Obj;
	Obj = new class'AssignedTeamsPlayerInfo';
    Obj.Key = key;
    Obj.Team = team;
    Obj.Next = next;
	return Obj;
}