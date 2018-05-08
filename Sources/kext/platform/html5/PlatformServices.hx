package kext.platform.html5;

import kext.platform.IPlatformServices;
import kext.platform.html5.GApi;

import js.Browser;
import js.html.Element;

class PlatformServices implements IPlatformServices {

	public var serviceInited:Bool;
	public var signedIn:Bool;

	public var auth2:Dynamic;

	private var loggingButton:Element;

	private var initCallback:GApiCallback;
	private var signInCallback:GApiCallback;

	public function new() {

	}

	private inline function loadScript(source:String, onLoadCallback:Void -> Void) {
		var script = Browser.document.createScriptElement();
		script.setAttribute("type", "text/javascript");
		script.setAttribute("src", source);
		script.onload = onLoadCallback;
		Browser.document.body.appendChild(script);
	}

	public function init(initCallback:GApiCallback) {
		this.initCallback = initCallback;

		loadScript("https://apis.google.com/js/client.js", loadClient);
	}

	public function loadClient() {
		loadScript("https://apis.google.com/js/api.js", loadAuth2);
	}

	public function loadAuth2() {
		GApi.load("auth2", authLoaded);
	}

	public function authLoaded(response:Dynamic) {
		GApiClient.load("games", "v1", initCallback);
	}

	public function authenticate(config:PlatformConfig, signInCallback:GApiCallback) {
		if(!serviceInited) {
			try(
				GApiAuth2.init(config).then(function(auth2:Dynamic) {
					this.signInCallback = signInCallback;
					this.auth2 = auth2;

					serviceInited = true;
					signedIn = auth2.isSignedIn.get();
					if(!signedIn) {
						auth2.isSignedIn.listen(onSignedIn);
						loggingButton = Browser.document.querySelector("#loggingButton");
						loggingButton.style.visibility = "visible";
						loggingButton.addEventListener('click', function() {
							auth2.signIn();
							loggingButton.style.visibility = "hidden";
						});
					}
				})
			) catch(error:Dynamic) {
				trace(error);
			}
		}
	}

	private function onSignedIn(response:Dynamic) {
		signInCallback(response);
		signedIn = auth2.isSignedIn.get();
	}

	private function getPlayerScores(id:String, timeSpan:String, callback:ServiceResponse) {
		var request = GApiScores.get({leaderboardId: id, playerId: "me", timeSpan: timeSpan});
		request.execute(callback);
	}

	public inline function getPlayerScoreAll(id:String, callback:ScoreListResponse) {
		getPlayerScores(id, TimeSpan.ALL, callback);
	}

	public inline function getPlayerScoreAllTime(id:String, callback:ScoreListResponse) {
		getPlayerScores(id, TimeSpan.ALL, callback);
	}

	public inline function getPlayerScoreWeekly(id:String, callback:ScoreListResponse) {
		getPlayerScores(id, TimeSpan.WEEKLY, callback);
	}

	public inline function getPlayerScoreDaily(id:String, callback:ScoreListResponse) {
		getPlayerScores(id, TimeSpan.DAILY, callback);
	}

	private function getLeaderboardScores(id:String, collection:String, timeSpan:String, callback:ScoreListResponse) {
		var request = GApiScores.list({leaderboardId: id, collection: collection, timeSpan: timeSpan});
		request.execute(parseLeaderboard.bind(_, callback));
	}

	private inline function parsePlayerScore(entry:LeaderboardEntry) {
		var playerScore = {
			value: Std.parseInt(entry.scoreValue),
			rank: Std.parseInt(entry.scoreRank),
			score: entry.formattedScore,
			rankLabel: entry.formattedScoreRank,
			playerName: entry.player.displayName
		};
		return playerScore;
	}

	private function parseLeaderboard(response:LeaderboardGetResponse , callback:ScoreListResponse) {
		var scores:Array<PlayerScore> = [];
		for(entry in response.items) {
			scores.push(parsePlayerScore(entry));
		}

		var data:ScoreListData = {
			scoreCount: response.numScores,
			scoreList: scores,
			playerScore: parsePlayerScore(response.playerScore),
		};
		callback(data);
	}

	public inline function getAllTimePublicScores(id:String, callback:ScoreListResponse) {
		getLeaderboardScores(id, Collection.PUBLIC, TimeSpan.ALL_TIME, callback);
	}

	public inline function getWeeklyPublicScores(id:String, callback:ScoreListResponse) {
		getLeaderboardScores(id, Collection.PUBLIC, TimeSpan.WEEKLY, callback);
	}
	
	public inline function getDailyPublicScores(id:String, callback:ScoreListResponse) {
		getLeaderboardScores(id, Collection.PUBLIC, TimeSpan.DAILY, callback);
	}

	public inline function getAllTimeSocialScores(id:String, callback:ScoreListResponse) {
		getLeaderboardScores(id, Collection.SOCIAL, TimeSpan.ALL_TIME, callback);
	}
	
	public inline function getWeeklySocialScores(id:String, callback:ScoreListResponse) {
		getLeaderboardScores(id, Collection.SOCIAL, TimeSpan.WEEKLY, callback);
	}
	
	public inline function getDailySocialScores(id:String, callback:ScoreListResponse) {
		getLeaderboardScores(id, Collection.SOCIAL, TimeSpan.DAILY, callback);
	}

	public function submitScore(id:String, value:Dynamic, callback:ScoreListResponse) {
		var request = GApiScores.submit({leaderboardId: id, score: value});
		request.execute(callback);
	}

}