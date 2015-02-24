require 'rubygems'
require 'base64'
require 'uri'
require 'net/http'
require 'pp'
require 'fileutils'
require 'digest'
require 'json'
require 'csv'
require 'date'
require 'prettyprint'

def main
  team_segments(
      'Detroit Pistons',
      [
          [Date.new(2014, 12, 21), 'Until drop Josh Smith'],
          [Date.new(2015, 1, 24), 'Until Brandon Jennings Injured'],
          [Date.new(2015, 2, 20), 'Until Trade DJ,Singler/Jackson Jerebko/Tayshaun']
      ]
  )

  # team_segments(
  #     'Charlotte',
  #     [
  #         [Date.new(2015, 1, 24), 'Until Kemba Walker injured'],
  #     ]
  # )

  # team_segments(
  #     'Brooklyn Nets',
  #     [
  #         [Date.new(2015, 1, 23), 'Until Teletovic out'],
  #     ]
  # )

end

def team_segments(team_name, team_dates)
  today = Date.today

  # dates are inclusive to last day of interesting period
  interesting_dates = team_dates + [[today, 'recent']]

  interesting_date_params = interesting_dates.each_with_index.map do |t, i|
    d, label = t
    previous_d = i > 0 ? interesting_dates[i - 1][0] : nil
    {
        season: '2014-15',
        label: label,
        date_from: previous_d,
        date_to: d
    }
  end

  all_date_params = [
      {season: '2013-14', label: '2013-14', date_from: nil, date_to: nil},
      {season: '2014-15', label: '2014-15 to date', date_from: nil, date_to: today}
  ] + interesting_date_params

  interesting_metrics = [
      'W', 'L',
      'OFF_RATING', 'DEF_RATING', 'NET_RATING',
      # 4 factors
      'EFG_PCT', 'OPP_EFG_PCT',
      'TM_TOV_PCT', 'OPP_TOV_PCT',
      'OREB_PCT', 'OPP_OREB_PCT',
      'FTA_RATE', 'OPP_FTA_RATE',
      # MISC
      'PACE',
      'FG3A', 'FG3_PCT'
  ]

  results = all_date_params.map do |dp|
    team_stats_summary(team_name, dp[:season], dp[:date_from], dp[:date_to], interesting_metrics)
  end
  # ['OPP_FTA_RATE', [result, rank], [result, rank]]
  metrics_with_segments = interesting_metrics.zip(results.transpose)

  CSV($stdout) do |csv|
    csv << (['metric'] + all_date_params.map {|p| [p[:label], 'rank']}.flatten)
    metrics_with_segments.each do |row|
      csv << row.flatten
    end
  end
end

def team_stats_summary(name, season, date_from, date_to, metrics)
  params = {
      'Season' => season
  }
  unless date_from.nil?
    params['DateFrom'] = date_from.strftime('%m/%d/%Y')
  end
  unless date_to.nil?
    params['DateTo'] = date_to.strftime('%m/%d/%Y')
  end
  league_stats = merge_team_stats(params)
  team_stats = league_stats.find {|s| s['TEAM_NAME'].include? name}
  metrics.map do |metric|
    rank = league_stats.sort_by {|s| -s[metric]}.index {|s| s['TEAM_NAME'].include? name} + 1
    [team_stats[metric], rank]
  end

end

# merges different stat results so we have standard, advanced, 4 factor all available by team
def merge_team_stats(params)
  ['Base', 'Advanced', 'Four Factors'].map do |measure_type|
    fetch_team_stats_hashes(params.merge('MeasureType' => measure_type))
  end.flatten.group_by do |team_hash|
    team_hash['TEAM_ID']
  end.map do |team_id, hashes|
    hashes.inject({}) do |result, h|
      result.merge(h)
    end
  end
end

def fetch_team_stats_hashes(params={})
  r = JSON.parse(fetch_league_stats(params))['resultSets'][0]
  headers = r['headers']
  rows = r['rowSet']
  rows.map do |row|
    Hash[headers.zip(row)]
  end
end

# Base
# ["TEAM_ID","TEAM_NAME","GP","W","L","W_PCT","MIN","FGM","FGA","FG_PCT","FG3M","FG3A","FG3_PCT","FTM","FTA","FT_PCT","OREB","DREB","REB","AST","TOV","STL","BLK","BLKA","PF","PFD","PTS","PLUS_MINUS","CFID","CFPARAMS"]
# Advanced
# ["TEAM_ID","TEAM_NAME","GP","W","L","W_PCT","MIN","OFF_RATING","DEF_RATING","NET_RATING","AST_PCT","AST_TO","AST_RATIO","OREB_PCT","DREB_PCT","REB_PCT","TM_TOV_PCT","EFG_PCT","TS_PCT","PACE","PIE","CFID","CFPARAMS"]
# Four Factors
# ["TEAM_ID","TEAM_NAME","GP","W","L","W_PCT","MIN","EFG_PCT","FTA_RATE","TM_TOV_PCT","OREB_PCT","OPP_EFG_PCT","OPP_FTA_RATE","OPP_TOV_PCT","OPP_OREB_PCT","CFID","CFPARAMS"]
def fetch_league_stats(params={})

  url_params = {
      # dates are inclusive
      'DateFrom' => [''],   # '02/01/2015'
      'DateTo' => [''],
      'GameScope' => [''],
      'GameSegment' => [''],
      'LastNGames' => ['0'],
      'LeagueID' => ['00'],
      'Location' => [''],
      'MeasureType' => ['Advanced'],   # 'Base', 'Advanced', 'Four Factors',
      'Month' => ['0'],
      'OpponentTeamID' => ['0'],
      'Outcome' => [''],
      'PaceAdjust' => ['N'],
      'PerMode' => ['Totals'],
      'Period' => ['0'],
      'PlayerExperience' => [''],
      'PlayerPosition' => [''],
      'PlusMinus' => ['N'],
      'Rank' => ['N'],
      'Season' => ['2014-15'],
      'SeasonSegment' => [''],
      'SeasonType' => ['Regular Season'],
      'StarterBench' => [''],
      'VsConference' => [''],
      'VsDivision' => ['']}

  url_params = merge_valid_params(
      url_params,
      {'MeasureType' => ['Base', 'Advanced', 'Four Factors'],
       'Season' => ['2013-14', '2014-15']
      },
      params
  )
  unless params['DateFrom'].nil?
    url_params['DateFrom'] = params['DateFrom']
  end
  unless params['DateTo'].nil?
    url_params['DateTo'] = params['DateTo']
  end

  fetch_cached_url('http://stats.nba.com/stats/leaguedashteamstats', url_params)
  # y = 'http://stats.nba.com/stats/leaguedashteamstats?DateFrom=&DateTo=&GameScope=&GameSegment=&LastNGames=0&LeagueID=00&Location=&MeasureType=Advanced&Month=0&OpponentTeamID=0&Outcome=&PaceAdjust=N&PerMode=Totals&Period=0&PlayerExperience=&PlayerPosition=&PlusMinus=N&Rank=N&Season=2014-15&SeasonSegment=&SeasonType=Regular+Season&StarterBench=&VsConference=&VsDivision='
end

def merge_valid_params(h, valid, params)
  to_merge = {}
  valid.keys.select {|k| validate_param(params, k, valid.fetch(k))}.each do |k|
    to_merge[k] = params[k]
  end
  h.merge(to_merge)
end

def validate_param(h, k, vs)
  if h.include? k
    v = h.fetch(k)
    raise "#{v} must be one of #{vs}" unless vs.include?(v)
    true
  else
    false
  end

end

def fetch_cached_url(uri, params)
  FileUtils::mkdir_p 'cache/url' unless File.directory? 'cache/url'
  url = "#{uri}?#{URI.encode_www_form(params)}"
  fname = "cache/url/#{friendly_filename(url)}.txt"
  unless File.exists?(fname)
    File.open(fname, 'w') {|f| f.write(fetch_http(url))}
  end
  File.read(fname)
end

def friendly_filename(url)
  Digest::SHA256.hexdigest(url)
end

def fetch_http(url)
  url = URI.parse(url)
  $stderr.puts url.request_uri
  req = Net::HTTP::Get.new(url.request_uri, {'User-Agent' => 'Mozilla/5.0 (Windows NT 6.3; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/37.0.2049.0 Safari/537.36'})
  res = Net::HTTP.start(url.host, url.port) {|http| http.request(req) }
  res.body
end

if __FILE__ == $0
  main
end
