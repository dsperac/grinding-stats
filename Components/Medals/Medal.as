// Medal.as
class Medal {
    private bool is_locked = false;
    uint64 time_to_acq = 0;

    Medal() {}

    Medal(uint64 _time_to_acq) {
        time_to_acq = _time_to_acq;
    }

    string toString() {
        if (is_locked) {
            return '\\$bbb' + '+';
        }
        return '\\$bbb' + Medal::to_string(time_to_acq);
    }

    void Lock() {
        is_locked = true;
    }

    bool IsLocked() {
        return is_locked;
    }
}

namespace Medal {
    string to_string(uint64 time) {
        if (time == 0) return '-';
        return Time::Format(time, false, true, setting_show_hour_if_0, false);
    }
}
