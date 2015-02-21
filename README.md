NBA Team Stats
=========================

A ruby script to pull team stats from stats.nba.com (via semi-private JSON API used by page).

There are some useful general methods for pulling down and caching season stats by team
for the 'standard', 'four factor' and 'advanced' stats, to organize them by team and merge
them altogether. There's also a method for examining a single team and extracting a set
of interesting stats and rank among all teams.

Finally, the main method defines a set of interesting date ranges to compare - so we can
look at a particular team's (The Pistons in this case) metrics for the previous season,
the current season to date, and a few segments - leading up to dropping Josh Smith, and
then up to Jennings' injury, and most recently, the trade for Reggie Jackson.

This could be easily adjusted to examine some interesting segments for any nba team.

Sample output from running `ruby doit.rb`

```
metric,2013-14,rank,2014-15 to date,rank,Until drop Josh Smith,rank,Until Brandon Jennings Injured,rank,"Until Trade DJ,Singler/Jackson Jerebko/Tayshaun",rank,recent,rank
W,29,23,22,17,5,28,12,4,5,18,1,5
L,53,8,33,9,23,2,5,28,7,10,0,11
OFF_RATING,102.9,20,101.9,18,97.6,28,107.0,5,103.6,12,100.5,7
DEF_RATING,107.3,5,103.9,14,105.8,7,100.0,23,105.6,7,96.1,9
NET_RATING,-4.4,24,-2.0,17,-8.2,28,7.1,5,-2.0,20,4.4,6
EFG_PCT,0.482,24,0.479,24,0.458,30,0.506,9,0.485,17,0.488,7
OPP_EFG_PCT,0.52,3,0.506,6,0.508,10,0.504,14,0.514,6,0.455,10
TM_TOV_PCT,0.148,20,0.141,23,0.143,21,0.14,22,0.145,12,0.121,12
OPP_TOV_PCT,0.154,13,0.148,14,0.142,19,0.16,7,0.149,13,0.211,2
OREB_PCT,0.314,1,0.276,6,0.269,8,0.284,4,0.29,4,0.268,8
OPP_OREB_PCT,0.266,8,0.244,23,0.251,19,0.216,28,0.256,15,0.295,6
FTA_RATE,0.296,11,0.272,17,0.274,18,0.257,20,0.29,8,0.393,3
OPP_FTA_RATE,0.288,16,0.244,27,0.263,20,0.217,30,0.236,24,0.282,8
PACE,97.39,11,95.63,20,95.12,19,97.82,10,94.34,24,97.1,10
FG3A,1580,22,1379,9,652,8,490,4,289,6,22,6
FG3_PCT,0.321,29,0.343,19,0.33,25,0.367,10,0.322,23,0.273,8
```

Imported into google sheets:

https://docs.google.com/spreadsheets/d/1VN3C-eseWwqc44EAnd1VIbduGrDhJPKmL3UV-1SClZI/edit#gid=0
