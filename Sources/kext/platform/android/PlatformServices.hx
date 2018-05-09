package kext.platform.android;

import kext.platform.android.GoogleService;
import kext.platform.IPlatformServices;

import com.ktxsoftware.kha.KhaActivity;

import android.content.Intent;

typedef Callback = Void -> Void;

class PlatformServices implements IPlatformServices {

	public var serviceInited:Bool;
	public var isSignedIn(get, null):Bool;

	private var initCallback:GoogleServiceCallback;
	private var signInCallback:GoogleServiceCallback;

	public function new() {

	}

	public function init(initCallback:GoogleServiceCallback) {
		this.initCallback = initCallback;
		initCallback({});
	}

	public function authenticate(config:PlatformConfig, signInCallback:ServiceResponse) {
		this.signInCallback = signInCallback;

		var signInClient:GoogleSignInClient = GoogleSignIn.getClient(KhaActivity.the(), GoogleSignInOptions.DEFAULT_GAMES_SIGN_IN);
		signInClient
		.silentSignIn()
		.addOnCompleteListener(
			KhaActivity.the(),
			untyped __java__('
			new com.google.android.gms.tasks.OnCompleteListener<com.google.android.gms.auth.api.signin.GoogleSignInAccount>() {
				@Override
				public void onComplete(com.google.android.gms.tasks.Task<com.google.android.gms.auth.api.signin.GoogleSignInAccount> task) {
                    if (task.isSuccessful()) {
                        com.google.android.gms.auth.api.signin.GoogleSignInAccount signedInAccount = task.getResult();
                    } else {
						com.google.android.gms.auth.api.signin.GoogleSignInClient signInClient = com.google.android.gms.auth.api.signin.GoogleSignIn.getClient((android.app.Activity) (com.ktxsoftware.kha.KhaActivity.the()),
								com.google.android.gms.auth.api.signin.GoogleSignInOptions.DEFAULT_GAMES_SIGN_IN);
						android.content.Intent intent = signInClient.getSignInIntent();
						//startActivityForResult(intent, 9001); //RC_SIGN_IN = 9001;
						(com.ktxsoftware.kha.KhaActivity.the()).startActivity(intent);
					}
				}
			}')
		);
	}

	private function startSignInIntent() {
		var signInClient:GoogleSignInClient = GoogleSignIn.getClient(KhaActivity.the(), GoogleSignInOptions.DEFAULT_GAMES_SIGN_IN);
		var intent:Intent = signInClient.getSignInIntent();
		KhaActivity.the().startActivity(intent);
	}

	private function onSignedIn(response:Dynamic) {
		signInCallback(response);
	}

	private function getPlayerScores(id:String, timeSpan:String, callback:ServiceResponse) {
		
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
		
	}

	public function get_isSignedIn():Bool {
		return GoogleSignIn.getLastSignedInAccount(KhaActivity.the()) != null;
	}

}