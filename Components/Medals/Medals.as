// Medals.as
class Medals : Component {
    Medal bronze;
    Medal silver;
    Medal gold;
    Medal author;
    
    Medals() {}

    Medals(
        uint64 bronze_time,
        uint64 silver_time,
        uint64 gold_time,
        uint64 author_time
    ) {
        bronze = Medal(bronze_time);
        silver = Medal(silver_time);
        gold = Medal(gold_time);
        author = Medal(author_time);
    }

    void handler() override {
        while(running){ 
            auto app = GetApp();
            auto playground = app.CurrentPlayground;
            auto playgroundScript = cast<CSmArenaRulesMode>(app.PlaygroundScript);
            auto network = cast<CTrackManiaNetwork>(app.Network);

            if (playground !is null && playgroundScript !is null && playground.GameTerminals.Length > 0) {
                auto terminal = playground.GameTerminals[0];
#if TMNEXT
                auto gui_player = cast<CSmPlayer>(terminal.GUIPlayer);
                auto ui_sequence = terminal.UISequence_Current;

                if (gui_player !is null) {

                    if (!handled && ui_sequence == CGamePlaygroundUIConfig::EUISequence::Finish) {
                        handled = true;

                        auto map = app.RootMap;
                        auto playerScriptAPI = cast<CSmScriptPlayer>(gui_player.ScriptAPI);
                        auto ghost = playgroundScript.Ghost_RetrieveFromPlayer(playerScriptAPI);

                        auto curr_total_time = data.timer.total;
                        auto finish_time = ghost.Result.Time;

                        if (bronze.time == 0 && finish_time <= map.TMObjective_BronzeTime) {
                            bronze.time = curr_total_time;
                        }
                        if (silver.time == 0 && finish_time <= map.TMObjective_SilverTime) {
                            silver.time = curr_total_time;
                        }
                        if (gold.time == 0 && finish_time <= map.TMObjective_GoldTime) {
                            gold.time = curr_total_time;
                        }
                        if (author.time == 0 && finish_time <= map.TMObjective_AuthorTime) {
                            author.time = curr_total_time;
                        }
                        
                        playgroundScript.DataFileMgr.Ghost_Release(ghost.Id);
                    }
                    if (handled && ui_sequence != CGamePlaygroundUIConfig::EUISequence::Finish)
                        handled = false;
                }
#endif
            }
            yield();
        }
    };
}
