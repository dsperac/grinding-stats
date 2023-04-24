// Medals.as
class Medals : Component {
    Medal bronze;
    Medal silver;
    Medal gold;
    Medal author;
    
    Medals() {}

    Medals(
        uint64 time_to_bronze,
        uint64 time_to_silver,
        uint64 time_to_gold,
        uint64 time_to_author
    ) {
        bronze = Medal(time_to_bronze);
        silver = Medal(time_to_silver);
        gold = Medal(time_to_gold);
        author = Medal(time_to_author);
    }

    void handler() override {
#if TMNEXT
        while(running) { 
            auto app = GetApp();
            auto playground = app.CurrentPlayground;
            auto playgroundScript = cast<CSmArenaRulesMode>(app.PlaygroundScript);
            auto network = cast<CTrackManiaNetwork>(app.Network);

            if (playground !is null && playgroundScript !is null && playground.GameTerminals.Length > 0) {
                auto terminal = playground.GameTerminals[0];
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

                        if (bronze.time_to_acq == 0 && finish_time <= map.TMObjective_BronzeTime) {
                            bronze.time_to_acq = curr_total_time;
                        }
                        if (silver.time_to_acq == 0 && finish_time <= map.TMObjective_SilverTime) {
                            silver.time_to_acq = curr_total_time;
                        }
                        if (gold.time_to_acq == 0 && finish_time <= map.TMObjective_GoldTime) {
                            gold.time_to_acq = curr_total_time;
                        }
                        if (author.time_to_acq == 0 && finish_time <= map.TMObjective_AuthorTime) {
                            author.time_to_acq = curr_total_time;
                        }
                        
                        playgroundScript.DataFileMgr.Ghost_Release(ghost.Id);
                    }
                    if (handled && ui_sequence != CGamePlaygroundUIConfig::EUISequence::Finish)
                        handled = false;
                }
            }
            yield();
        }
#endif
    };
}
