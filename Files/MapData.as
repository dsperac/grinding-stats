// MapData.as
class MapData {
    string mapUid = '';
    MedalTimes@ medal_times = MedalTimes();
    
    MapData() {}

    MapData(string _mapUid) {
        mapUid = _mapUid;
#if TMNEXT
        if (_mapUid != '') {
            load_medal_times();
            startnew(CoroutineFunc(load_personal_best));
            startnew(CoroutineFunc(load_online_pb));
        }
#endif
    }

    void load_medal_times() {
        auto app = GetApp();
        auto playground = cast<CSmArenaClient>(app.CurrentPlayground);
        auto map = playground !is null ? playground.Map : null;

        if (map !is null) {
            medal_times.bronze = map.TMObjective_BronzeTime;
            medal_times.silver = map.TMObjective_SilverTime;
            medal_times.gold = map.TMObjective_GoldTime;
            medal_times.author = map.TMObjective_AuthorTime;
        }
    }

    void load_personal_best() {
        auto app = cast<CTrackMania>(GetApp());
        auto network = cast<CTrackManiaNetwork>(app.Network);
        auto scoreMgr = network.ClientManiaAppPlayground.ScoreMgr;

        auto userMgr = network.ClientManiaAppPlayground.UserMgr;
        auto userId = userMgr.Users.Length > 0 ? userMgr.Users[0].Id : uint(-1);

        uint local_pb = scoreMgr.Map_GetRecord_v2(userId, mapUid, "PersonalBest", "", "TimeAttack", "");

        if (local_pb > 0) {
            medal_times.personal_best = local_pb;
            startnew(CoroutineFunc(data.medals.lock_earlier_medals));
        }
    }

    void load_online_pb() {
#if DEPENDENCY_NADEOSERVICES
        auto info = FetchEndpoint(NadeoServices::BaseURL() + "/api/token/leaderboard/group/Personal_Best/map/" + mapUid + "/surround/0/0?onlyWorld=true");
        if (info.GetType() == Json::Type::Null) {
            return;
        }

        auto tops = info["tops"];
        if (tops.GetType() != Json::Type::Array) {
            return;
        }

        auto top = tops[0]["top"];
        if (top.Length == 0) {
            return;
        }

        uint score = top[0]["score"];
        if (score == 0) {
            return;
        }

        medal_times.personal_best = medal_times.personal_best > 0 ? Math::Min(medal_times.personal_best, score) : score;
        startnew(CoroutineFunc(data.medals.lock_earlier_medals));
#endif
    }
}

// Helpers
class MedalTimes {
    uint bronze = 0;
    uint silver = 0;
    uint gold = 0;
    uint author = 0;
    uint personal_best = 0;

    MedalTimes() {}
}

/**
 * Fetch an endpoint from the Nadeo Live Services
 * 
 * Needs to be called from a yieldable function
 */
Json::Value FetchEndpoint(const string &in route) {
    while (!NadeoServices::IsAuthenticated("NadeoLiveServices")) {
        yield();
    }
    auto req = NadeoServices::Get("NadeoLiveServices", route);
    req.Start();
    while(!req.Finished()) {
        yield();
    }
    return Json::Parse(req.String());
}
