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
metric,2014-15,rank,2015-16,rank,2016-17,rank,until Reggie injury,rank,until Blake,rank,recent,rank
W,32,23,44,13,37,19,19,11,4,29,2,6
L,50,23,38,12,45,19,14,8,12,29,0,5
OFF_RATING,102.3,17,103.3,15,103.3,25,104.6,15,103.0,27,111.0,15
DEF_RATING,104.2,21,103.4,13,105.3,11,104.5,12,106.3,12,102.8,8
NET_RATING,-1.8,20,-0.2,16,-2.0,22,0.2,14,-3.4,22,8.1,7
EFG_PCT,0.482,24,0.491,22,0.492,27,0.513,18,0.511,23,0.544,14
OPP_EFG_PCT,0.502,19,0.504,17,0.516,19,0.527,21,0.535,21,0.508,11
TM_TOV_PCT,0.139,7,0.137,8,0.121,2,0.146,11,0.129,5,0.139,16
OPP_TOV_PCT,0.146,16,0.137,23,0.131,23,0.16,5,0.151,8,0.118,23
OREB_PCT,0.277,3,0.27,2,0.241,12,0.242,6,0.196,25,0.207,19
OPP_OREB_PCT,0.25,15,0.207,2,0.188,1,0.223,14,0.203,6,0.189,11
FTA_RATE,0.261,20,0.296,5,0.218,30,0.224,27,0.209,28,0.338,4
OPP_FTA_RATE,0.249,8,0.25,5,0.253,10,0.235,9,0.228,6,0.112,1
PACE,95.18,23,97.39,20,97.09,24,97.77,22,99.03,18,99.25,16
FG3A,2043,11,2148,10,1915,26,963,18,434,22,51,24
FG3_PCT,0.344,17,0.345,22,0.33,28,0.38,7,0.371,9,0.314,22
AST_PCT,0.582,15,0.512,29,0.53,28,0.569,18,0.602,12,0.544,22
```

I keep the output up to date in [this google sheet](https://docs.google.com/spreadsheets/d/1VN3C-eseWwqc44EAnd1VIbduGrDhJPKmL3UV-1SClZI/edit?usp=sharing)

