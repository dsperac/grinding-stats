//Respawns.as (currently only working for TMNEXT)
class Respawns : Component {
    uint current;

    Respawns() {}

    Respawns(uint total) {
        super(total);
        current = 0;
    }

    string toString() override {
        // session / total display
        if (!setting_show_respawns_current) {
            if (
                !setting_show_respawns_session
                || (!setting_show_duplicates && session == total)
            ) {
                return "\\$bbb" + total;
            }
            if (!setting_show_respawns_total) {
                return "\\$bbb" + session;
            }
            return "\\$bbb" + session + " \\$fff / " + "\\$bbb" + total;
        }

        // display one value only
        if (
            (!setting_show_respawns_session && !setting_show_respawns_total) // if only current enabled
            || (!setting_show_respawns_session && !setting_show_duplicates && current == total) // session disabled and current and total are same
            || (!setting_show_respawns_total && !setting_show_duplicates && current == session) // total disabled and current and session are same
            || (!setting_show_duplicates && current == session && current == total) // all 3 are the same
        ) {
            return "\\$bbb" + current;
        }

        // current / total display
        if (!setting_show_respawns_session) {
            return "\\$bbb" + current + " \\$fff / " + "\\$bbb" + total;
        }

        // current / session display
        if (!setting_show_respawns_total) {
            return "\\$bbb" + current + " \\$fff / " + "\\$bbb" + session;
        }

        // 2 out of 3 are the same (and not showing duplicates)
        if (!setting_show_duplicates && 
        (current != session && session == total) ||
        (current == session && session != total)) {
            return "\\$bbb" + current + " \\$fff / " + "\\$bbb" + total;
        }

        return "\\$bbb" + current + " \\$fff / " 
              + "\\$bbb" + session + " \\$fff / "
              + "\\$bbb" + total;
}

    void handler() override {
#if TMNEXT
        while(running) {
            auto app = GetApp();
            auto playground = app.CurrentPlayground;
            if (playground !is null && playground.GameTerminals.Length > 0) {
                auto terminal = playground.GameTerminals[0];
                auto gui_player = cast<CSmPlayer>(terminal.GUIPlayer);
                if (gui_player !is null) {
                    auto script = cast<CSmScriptPlayer>(gui_player.ScriptAPI);
                    auto post = script.Post;

                    if (script.Score.NbRespawnsRequested > current && post != CSmScriptPlayer::EPost::Char) {
                        current += 1;
                        session += 1;
                        total += 1;   
                    }
                    if (script.Score.NbRespawnsRequested == 0) {
                        current = 0;
                    }
                }
            }
            yield();
        }
#endif
    }
}
