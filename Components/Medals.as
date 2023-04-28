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
    }

    void lock_earlier_medals() {
        auto map_times = data.map_data.map_times;
        if (map_times.personal_best > 0) {
            if (
                bronze.time_to_acq == 0
                && map_times.personal_best < map_times.bronze
            ) {
                bronze.lock();
            }
            if (
                silver.time_to_acq == 0
                && map_times.personal_best < map_times.silver
            ) {
                silver.lock();
            }
            if (
                gold.time_to_acq == 0
                && map_times.personal_best < map_times.gold
            ) {
                gold.lock();
            }
            if (
                author.time_to_acq == 0
                && map_times.personal_best < map_times.author
            ) {
                author.lock();
            }
        }
    }

    void handler() override {
#if TMNEXT
        while (running) {
            auto app = GetApp();
            auto playground = app.CurrentPlayground;

            if (playground is null || playground.GameTerminals.Length == 0) {
                yield();
                continue;
            }

            auto terminal = playground.GameTerminals[0];
            auto gui_player = cast<CSmPlayer>(terminal.GUIPlayer);

            if (gui_player is null) {
                yield();
                continue;
            }

            auto ui_sequence = terminal.UISequence_Current;

            if (!handled && ui_sequence == CGamePlaygroundUIConfig::EUISequence::Finish) {
                handled = true;
                
                auto playgroundScript = cast<CSmArenaRulesMode>(app.PlaygroundScript);

                if (playgroundScript is null) {
                    // TODO: figure out how to get finish time when playing online
                    yield();
                    continue;
                }

                auto playerScriptAPI = cast<CSmScriptPlayer>(gui_player.ScriptAPI);
                auto ghost = playgroundScript.Ghost_RetrieveFromPlayer(playerScriptAPI);

                auto finish_time = ghost.Result.Time;
                auto curr_total_time = data.timer.total;
                auto map_times = data.map_data.map_times;

                if (!bronze.is_locked() && bronze.time_to_acq == 0 && finish_time <= map_times.bronze) {
                    bronze.time_to_acq = curr_total_time;
                }
                if (!silver.is_locked() && silver.time_to_acq == 0 && finish_time <= map_times.silver) {
                    silver.time_to_acq = curr_total_time;
                }
                if (!gold.is_locked() && gold.time_to_acq == 0 && finish_time <= map_times.gold) {
                    gold.time_to_acq = curr_total_time;
                }
                if (!author.is_locked() && author.time_to_acq == 0 && finish_time <= map_times.author) {
                    author.time_to_acq = curr_total_time;
                }

                playgroundScript.DataFileMgr.Ghost_Release(ghost.Id);
            } else if (handled && ui_sequence != CGamePlaygroundUIConfig::EUISequence::Finish) {
                handled = false;
            }

            yield();
        }
#endif
    };
}
