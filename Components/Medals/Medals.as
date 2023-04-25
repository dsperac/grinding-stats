// Medals.as
class Medals : Component {
    Medal@ bronze = Medal(0);
    Medal@ silver = Medal(0);
    Medal@ gold = Medal(0);
    Medal@ author = Medal(0);
    
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
#if TMNEXT
        startnew(CoroutineFunc(lock_earlier_medals));
#endif
    }

    void lock_earlier_medals() {
        if (data.map_data.pb > 0) {
            if (
                bronze.time_to_acq == 0
                && data.map_data.pb < data.map_data.bronze
            ) {
                bronze.Lock();
            }
            if (
                silver.time_to_acq == 0
                && data.map_data.pb < data.map_data.silver
            ) {
                silver.Lock();
            }
            if (
                gold.time_to_acq == 0
                && data.map_data.pb < data.map_data.gold
            ) {
                gold.Lock();
            }
            if (
                author.time_to_acq == 0
                && data.map_data.pb < data.map_data.author
            ) {
                author.Lock();
            }
        }
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

                        auto playerScriptAPI = cast<CSmScriptPlayer>(gui_player.ScriptAPI);
                        auto ghost = playgroundScript.Ghost_RetrieveFromPlayer(playerScriptAPI);

                        auto curr_total_time = data.timer.total;
                        auto finish_time = ghost.Result.Time;

                        if (!bronze.IsLocked() && bronze.time_to_acq == 0 && finish_time <= data.map_data.bronze) {
                            bronze.time_to_acq = curr_total_time;
                        }
                        if (!silver.IsLocked() && silver.time_to_acq == 0 && finish_time <= data.map_data.silver) {
                            silver.time_to_acq = curr_total_time;
                        }
                        if (!gold.IsLocked() && gold.time_to_acq == 0 && finish_time <= data.map_data.gold) {
                            gold.time_to_acq = curr_total_time;
                        }
                        if (!author.IsLocked() && author.time_to_acq == 0 && finish_time <= data.map_data.bronze) {
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
