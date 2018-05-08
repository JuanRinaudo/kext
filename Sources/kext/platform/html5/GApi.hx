package kext.platform.html5;

@:enum
abstract TimeSpan(String) {
	public static var ALL = "ALL";
	public static var ALL_TIME = "ALL_TIME";
	public static var DAILY = "DAILY";
	public static var WEEKLY = "WEEKLY";
}

@:enum
abstract Collection(String) {
	public static var PUBLIC = "PUBLIC";
	public static var SOCIAL = "SOCIAL";
	public static var SOCIAL_1P = "SOCIAL_1P";
}

typedef GApiCallback = Dynamic -> Void;
typedef GApiCallbackRejected = Dynamic -> Void;
extern class GApiRequest<T> {
	public function execute(callback:T):Void;
	public function then(onFulfilled:T, ?onRejected:GApiCallbackRejected, ?context:Dynamic):Void;
}

@:native("gapi") extern class GApi {
	public static function load(name:String, callback:GApiCallback):Void;
}

typedef AuthInitParams = {
	client_id:String
}

@:native("gapi.auth2") extern class GApiAuth2 {
	public static function init(params:AuthInitParams):GApiRequest<GApiCallback>;
}

@:native("gapi.client") extern class GApiClient {
	public static function load(name:String, version:String, callback:GApiCallback):Void;
}

@:native("gapi.client.games") extern class GApiGames {

}

typedef GetScoreParameters = {
	leaderboardId:String,
	playerId:String,
	timeSpan:String,
	?consistencyToken:Int,
	?includeRankType:String,
	?language:String,
	?maxResults:Int,
	?pageToken:String
}

typedef ListScoreParameters = {
	collection:String,
	leaderboardId:String,
	timeSpan:String,
	?consistencyToken:Int,
	?language:String,
	?maxResults:Int,
	?pageToken:String
}

typedef ListWindowScoreParameters = {
	collection:String,
	leaderboardId:String,
	timeSpan:String,
	?consistencyToken:Int,
	?language:String,
	?maxResults:Int,
	?pageToken:String,
	?resultsAbove:Int,
	?returnTopIfAbsent:Bool
}

typedef SubmitScoreParameters = {
	leaderboardId:String,
	score:Int,
	?consistencyToken:Int,
	?language:String,
	?scoreTag:String
}

// typedef SubmitMultipleScoreParameters = {
//
// }

@:native("gapi.client.games.scores") extern class GApiScores {
	public static function get(params:GetScoreParameters):GApiRequest<GApiCallback>;
	public static function list(params:ListScoreParameters):GApiRequest<GApiCallback>;
	public static function listWindow(params:ListWindowScoreParameters):GApiRequest<GApiCallback>;
	public static function submit(params:SubmitScoreParameters):GApiRequest<GApiCallback>;
	// public static function submitMultiple(params:):GApiRequest;
}

typedef GetLeaderboardsParameters = {
	leaderboardId:String,
	?consistencyToken:Int,
	?language:String
}

typedef ListLeaderboardsParameters = {
	?consistencyToken:Int,
	?language:String,
	?maxResults:Int,
	?pageToken:String
}

typedef LeaderboardEntry = {
	formattedScore:String,
	formattedScoreRank:String,
	kind:String,
	player:Player,
	scoreRank:String,
	scoreValue:String,
	timeSpan:String,
	writeTimestampMillis:String,
}

typedef Player = {
	bannerUrlLandscape:String,
	bannerUrlPortrait:String,
	displayName:String,
	experienceInfo:ExperienceInfo,
	kind:String,
	playerId:String,
	profileSettings:ProfileSettings,
	title:String
}

typedef ExperienceInfo = {
	currentExperiencePoints:String,
	currentLevel:PlayerLevel,
	kind:String,
	nextLevel:PlayerLevel,
}

typedef PlayerLevel = {
	kind:String,
	level: Int,
	minExperiencePoints: String,
	maxExperiencePoints: String
}

typedef ProfileSettings = {
	kind:String, 
	profileVisible:Bool
}

typedef LeaderboardGetResponse = {
	items:Array<LeaderboardEntry>,
	kind:String,
	numScores:Int,
	playerScore:LeaderboardEntry,
}

typedef Leaderboard = {
	iconUrl:String,
	id:String,
	isIconUrlDefault:Bool,
	kind:String,
	name:String,
	order:String
}

typedef LeaderboardListResponse = {
	items:Array<Leaderboard>,
	kind:String
}

@:native("gapi.client.games.leaderboards") extern class GApiLeaderboards {
	public static function get(params:GetLeaderboardsParameters):GApiRequest<LeaderboardGetResponse>;
	public static function list(params:ListLeaderboardsParameters):GApiRequest<LeaderboardListResponse>;
}