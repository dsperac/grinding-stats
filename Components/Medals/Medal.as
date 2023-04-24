// Medal.as
class Medal {
    uint64 time_to_acq;

    Medal() {}

    Medal(uint64 _time_to_acq) {
        time_to_acq = _time_to_acq;
    }

    string toString() {
        return '\\$bbb' + Medal::to_string(time_to_acq);
    }
}

namespace Medal {
    string to_string(uint64 time) {
        if (time == 0) return '-';
        return Time::Format(time, false, true, setting_show_hour_if_0, false);
    }
}
