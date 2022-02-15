DROP TABLE IF EXISTS post;
CREATE TABLE post (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    local_code TEXT,
    zipcode_old TEXT,
    zipcode TEXT,
    pref_kana TEXT,
    city_kana TEXT,
    town_kana TEXT,
    pref TEXT,
    city TEXT,
    town TEXT,
    double_zipcode TEXT,
    town_display TEXT,
    city_block_display TEXT,
    double_town TEXT,
    update_zipcode TEXT,
    update_reason TEXT,
    deleted INTEGER,
    created_ts TEXT,
    modified_ts TEXT
);
