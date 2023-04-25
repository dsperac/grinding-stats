// MapData.as
class MapData {
    string mapUid = '';

    uint bronze = 0;
    uint silver = 0;
    uint gold = 0;
    uint author = 0;
    uint pb = 0;

    MapData() {}

    MapData(string _mapUid) {
        mapUid = _mapUid;
#if TMNEXT
        get_map_data();
#endif
    }

    void get_map_data() {
        auto app = GetApp();
        auto playground = cast<CSmArenaClient>(app.CurrentPlayground);
        auto map = playground !is null ? playground.Map : null;

        if (map !is null) {
            bronze = map.TMObjective_BronzeTime;
            silver = map.TMObjective_SilverTime;
            gold = map.TMObjective_GoldTime;
            author = map.TMObjective_AuthorTime;
            pb = 1; // todo get pb
        }
    }
}
