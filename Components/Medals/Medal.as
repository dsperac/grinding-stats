// Medal.as
class Medal {
    uint64 time;

    Medal() {}

    Medal(uint64 _time) {
        time = _time;
    }

    string toString() {
        return '\\$bbb' + Medal::to_string(time);
    }
}

namespace Medal {
    string to_string(uint64 time) {
        if (time == 0) return '-';
        string str = Time::Format(time,false,true,setting_show_hour_if_0,false);
        return setting_show_thousands ? str: str.SubStr(0, str.Length - 1);
    }
}
