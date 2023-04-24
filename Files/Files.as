// //Files.as


// bool are_you_sure_current = false;
// bool are_you_sure_all = false;
// uint are_you_sure_current_timeout = 0;
// uint are_you_sure_all_timeout = 0;
// [SettingsTab name="Files"]
// void files_render_settings() {
//     if (are_you_sure_current && (Time::Now - are_you_sure_current_timeout) > 5000) {
//         print(Time::Now - are_you_sure_current_timeout);
//         print(are_you_sure_current_timeout + " " + Time::Now);
//         are_you_sure_current = false;
//     }
//     if (are_you_sure_all && (Time::Now - are_you_sure_all_timeout  > 5000)) {
//         are_you_sure_all = false;
//     }
//     if (UI::Button("Reset current map's data")) {
        
//         if (file.get_map_id() == "") {
//             UI::ShowNotification("Grinding Stats","You are not currently in a map.",5000);
//             return;
//         }
//         if (!are_you_sure_current) {
//             UI::ShowNotification("Grinding Stats","Are you sure you want to reset the current map's data?",5000);
//             are_you_sure_current = true;
//             are_you_sure_current_timeout = Time::Now;
//             return;
//         } else {
//             UI::ShowNotification("Grinding Stats","Reset current map's data",5000);
//             file.reset_file();
//             are_you_sure_current = false;
//             return;
//         }
//     }
    
//     if (UI::Button("Reset all map data")) { 
//         if (!are_you_sure_all) {
//             UI::ShowNotification("Grinding Stats","Are you sure you want to reset ALL MAP DATA?",5000);
//             are_you_sure_all = true;
//             are_you_sure_all_timeout = Time::Now;
//             return;
//         } else {
//             UI::ShowNotification("Grinding Stats","Reset ALL MAP DATA",5000);
//             file.reset_all();
//             are_you_sure_all = false;
//             return;
//         }
        
//     }
    
// }

class Files {
    bool created = false;
    string folder_location = "";
    string map_id = "";
    string json_file = "";
    uint finishes = 0;
    uint resets = 0;
    uint64 time = 0;
    bool loaded = false;
    uint respawns = 0;
    uint64 time_to_bronze = 0;
    uint64 time_to_silver = 0;
    uint64 time_to_gold = 0;
    uint64 time_to_author = 0;
    Json::Value json_obj = Json::Parse(
        '{"finishes": 0,"resets": 0,"time": 0,"respawns":0,"timeToBronze":0,"timeToSilver":0,"timeToGold":0,"timeToAuthor":0}'
    );
    Files() {}
    Files(const string &in id) {
        if (id == "" || id == "Unassigned") return;
        folder_location = IO::FromDataFolder("") + "Grinding Stats";
        


        if (!IO::FolderExists(folder_location)) IO::CreateFolder(folder_location);

        map_id = id;
        json_file = folder_location + '/' + map_id + '.json';
        read_file();
        created = true;
    }
    void read_file() {
        if (IO::FileExists(json_file)) {
            auto content = Json::FromFile(json_file);
            uint value_types;
            if (content.Get('map_id') is null && content.Get('respawns') !is null) {
                value_types =
                content.Get('finishes').GetType() |
                 content.Get('resets').GetType() |
                  content.Get('time').GetType() |
                   content.Get('respawns').GetType();
            } else {
                read_file_legacy(content,true);
                //value_types = content.Get('finishes').GetType() | content.Get('resets').GetType() | content.Get('time').GetType();
                return;
            }
            
            if (content.GetType() != Json::Type::Null) {
                if (value_types == 1) {
                    read_file_new(content);
                }
                else if (value_types == 2) {
                    read_file_legacy(content);
                } 
                else {
                    UI::ShowNotification("Grinding Stats","Unable to parse the map's saved data.",UI::HSV(1.0f,1.0f,1.0f),15000);
                }
            }
        }
        loaded = true;
    }
    void read_file_new(const Json::Value &in content) {
        finishes = Text::ParseUInt64(content.Get("finishes"));
        resets = Text::ParseUInt64(content.Get('resets'));
        time = Text::ParseUInt64(content.Get('time'));
        respawns = Text::ParseUInt64(content.Get('respawns'));
        debug_print("Read finishes " + finishes + " resets " + resets + " time " + time + " respawns " + respawns + " from " + json_file);

        time_to_bronze = content.HasKey('timeToBronze')
            ? Text::ParseUInt64(content.Get('timeToBronze'))
            : 0;
        time_to_silver = content.HasKey('timeToSilver')
            ? Text::ParseUInt64(content.Get('timeToSilver'))
            : 0;
        time_to_gold = content.HasKey('timeToGold')
            ? Text::ParseUInt64(content.Get('timeToGold'))
            : 0;
        time_to_author = content.HasKey('timeToAuthor')
            ? Text::ParseUInt64(content.Get('timeToAuthor'))
            : 0;
        debug_print("Read bronze " + time_to_bronze + " silver " + time_to_silver + " gold " + time_to_gold + " author " + time_to_author);
    }

    void read_file_legacy(const Json::Value &in content, bool is_old_dev = false) {
        time = is_file_time_corrupt(content) ? 0 : content.Get('time');
        finishes = content.Get('finishes');
        resets = content.Get('resets');
        respawns = is_old_dev ? 0 : content.Get('respawns');
        debug_print("Read (legacy) finishes " + finishes + " resets " + resets + " time " + time + " respawns " + respawns + " from " + json_file);

        time_to_bronze = !is_old_dev && content.HasKey('timeToBronze')
            ? Text::ParseUInt64(content.Get('timeToBronze'))
            : 0;
        time_to_silver = !is_old_dev && content.HasKey('timeToSilver')
            ? Text::ParseUInt64(content.Get('timeToSilver'))
            : 0;
        time_to_gold = !is_old_dev && content.HasKey('timeToGold')
            ? Text::ParseUInt64(content.Get('timeToGold'))
            : 0;
        time_to_author = !is_old_dev && content.HasKey('timeToAuthor')
            ? Text::ParseUInt64(content.Get('timeToAuthor'))
            : 0;
        debug_print("Read (legacy) bronze " + time_to_bronze + " silver " + time_to_silver + " gold " + time_to_gold + " author " + time_to_author);
    }


    bool is_file_time_corrupt(const Json::Value &in content) {
        int64 signed_time = content.Get('time');
        if (signed_time < 0) return true;
        if (signed_time > 100000000 && finishes == 0 && resets == 0) return true; 
        
        return false;
    }


    void write_file() {
        if (map_id == "" || map_id == "Unassigned") {
            return;
        }
        auto content = Json::Object();
        content["finishes"] = Text::Format("%6d",finishes);
        content["resets"]   = Text::Format("%6d", resets);
        content["time"]     = Text::Format("%11d", time);
        content["respawns"] = Text::Format("%6d", respawns);
#if TMNEXT
        content["timeToBronze"] = Text::Format("%11d", time_to_bronze);
        content["timeToSilver"] = Text::Format("%11d", time_to_silver);
        content["timeToGold"] = Text::Format("%11d", time_to_gold);
        content["timeToAuthor"] = Text::Format("%11d", time_to_author);
#endif
        Json::ToFile(json_file,content);
        
        debug_print("Wrote finishes " + finishes + " resets " + resets + " time " + time + " respawns " + respawns + " to " + json_file);
#if TMNEXT
        debug_print("Wrote bronze " + time_to_bronze + " silver " + time_to_silver + " gold " + time_to_gold + " author " + time_to_author);
#endif
    }

    string get_map_id() {
        return map_id;
    }
    string get_folder_location() {
        return folder_location;
    }
    void set_folder_location(const string &in loc) {
        folder_location = loc;
    }
    void set_map_id(const string &in i) {
        map_id = i;
    }
    void set_finishes(uint f) {
        finishes = f;
    }
    void set_resets(uint r) {
        resets = r;
    }
    void set_time(uint64 t) {
        time = t;   
    }
    uint64 get_time() {
        return time;
    }
    uint get_finishes() {
        return finishes;
    }
    uint get_resets() {
        return resets;
    }
    uint get_respawns() {
        return respawns;
    }
    void set_respawns(uint r) {
        respawns = r;
    }
    void set_time_to_bronze(uint64 t) {
        time_to_bronze = t;
    }
    uint64 get_time_to_bronze() {
        return time_to_bronze;
    }
    void set_time_to_silver(uint64 t) {
        time_to_silver = t;
    }
    uint64 get_time_to_silver() {
        return time_to_silver;
    }
    void set_time_to_gold(uint64 t) {
        time_to_gold = t;
    }
    uint64 get_time_to_gold() {
        return time_to_gold;
    }
    void set_time_to_author(uint64 t) {
        time_to_author = t;
    }
    uint64 get_time_to_author() {
        return time_to_author;
    }
    void reset_file() {
        print(json_file);
        IO::Delete(json_file);
    }
    void reset_all() {
        auto files = IO::IndexFolder(folder_location,true);
        for (uint i = 0; i < files.Length; i++) {
            IO::Delete(files[i]);
        }
    }
    void debug_print(const string &in text) {
        print(text);
    }
}
