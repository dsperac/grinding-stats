class FileMedalTime {

    private BoolRef@ _is_unknown = BoolRef();
    private NullableUint64@ _time = NullableUint64();

    FileMedalTime() {}

    uint64 time {
        get const {
            return _time.value_or_default;
        }
    }

    void set_time_from_medal(Medal medal) {
        if (medal.is_locked()) {
            _is_unknown.value = true;
            return;
        }
        _time = medal.time_to_acq;
    }

    void decode_time(const string &in json_value) {
        if (json_value == '')
            return;

        if (json_value == 'unknown') {
            _is_unknown.value = true;
            return;
        }
        _time = NullableUint64(Text::ParseUInt64(json_value));
    }

    string encode_time() {
        if (_is_unknown.value) {
            return 'unknown';
        }
        return Text::Format("%11d", this.time);
    }
    
    string to_string() {
        if (_is_unknown.value) {
            return '+';
        }
        if (!_time.has_value) {
            return '?';
        }
        return Medal::to_string(_time.value);
    }
}
