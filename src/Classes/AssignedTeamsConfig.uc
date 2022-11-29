class AssignedTeamsConfig extends Object
	config;

var() config bool bEnabled;
var() config bool Debug;
var() config bool bNoTeamChanges;
var() config string StrategyAssignment;

DefaultProperties {
	bEnabled=true
	Debug=true
	bNoTeamChanges=true
	StrategyAssignment="0000011111"
}