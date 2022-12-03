# Assigned Teams

UnrealTournament package containing derived games types for CTFGame and TeamGamePlus for controlling players team assignments by game password.

Version: 0.2-beta<br>
Author: Orel Eraki<br>
Email: orel.eraki@gmail.com<br>

## How does it works ?
`GamePassword` is set with a delimiter(`;`) format. When a player joins, it will iterate through the different tokens and remember the current iteration position.<br>
When a player password match to a token, it will take the iteration position and will look inside the `StrategyAssignment` configuration for the correct Team index.<br>
For any case the password isn't a match (e.g. admin), it will give the responsability for login to the default behavior.

### UnrealTournament Default Team Numbers
| Number| Name
| ---   | ---
| 0     | Red
| 1     | Blue
| 2     | Green
| 3     | Gold
| 255   | `None`

### StrategyAssignment Formats
| Format     | Description |
| ------  | ------ |
| 0000011111    | First 5 passwords will be mapped Team0(Red)<br>Next 5 will be mapped Team1(Blue)
| 0000011111s   | First 5 passwords will be mapped Team0(Red)<br>Next 5 will be mapped Team1(Blue)<br>Last Password(Position 11) will force player to be spectator

### Algorithm examples
Use Case#1
```
- For GamePassword:         one;two;three;four
- For StrategyAssignment:   0123
Player joins with
    Pass="one",     Matched token at Position=1, StrategyAssignment[1] = 0(Red)
    Pass="two",     Matched token at Position=2, StrategyAssignment[2] = 1(Blue)
    Pass="three",   Matched token at Position=3, StrategyAssignment[3] = 2(Green)
    Pass="four",    Matched token at Position=4, StrategyAssignment[4] = 3(Gold)
```

Use Case#2
```
- For GamePassword:         dog;cat;wolf;lion;hawk
- For StrategyAssignment:   0101s
Player joins with
    Pass="dog",     Matched token at Position=1, StrategyAssignment[1] = 0(Red)
    Pass="wolf",    Matched token at Position=3, StrategyAssignment[3] = 0(Red)
    Pass="cat",     Matched token at Position=2, StrategyAssignment[2] = 1(Blue)
    Pass="lion",    Matched token at Position=4, StrategyAssignment[4] = 1(Blue)
    Pass="eagle",   Matched token at Position=5, StrategyAssignment[5] = Spectator
    Pass="falcon",  No Match => Will try Default Login
```

## Installation
1. Copy `AssignedTeams.u` and `AssignedTeams.int` files to **System** folder.
2. Start server with the new Game types.

## Configuration
These are the default values.
```ini
[AssignedTeams.AssignedTeamsConfig]
bEnabled=True
bNoTeamChanges=True
StrategyAssignment=0000011111
```

`StrategyAssignment`

## Game Types
All game types are overriding the original. thus containing the same functionality.

| Name                          | Original      | Package
| -----------                   | -----------   | -----------
| AssignedTeamsCTFGame          | CTFGame       | Botpack (BuiltIn)
| AssignedTeamsTeamGamePlus     | TeamGamePlus  | Botpack (BuiltIn)
| AssignedTeamsNewCTF           | NewCTF        | [NewCTF v17](https://github.com/Deaod/NewCTF/releases/tag/v17)

## Examples

CTFGame (CTF)
```console
ucc.exe server CTF-Coret.unr?Game=AssignedTeams.AssignedTeamsCTFGame log=server.log ini=UnrealTournament.ini
```

TeamGamePlus (TDM)
```console
ucc.exe server DM-Deck16][.unr?Game=AssignedTeams.AssignedTeamsTeamGamePlus log=server.log ini=UnrealTournament.ini
```