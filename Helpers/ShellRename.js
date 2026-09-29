.pragma library

// Noctalia → Noctaliaa rename of saved settings (see Commons/Migrations/Migration61.qml).
// Kept free of QML dependencies so it can be unit tested (see Tests/tst_shellrename.qml).

var renamedIds = {
  "NoctaliaPerformance": "NoctaliaaPerformance"
};

var renamedKeys = {
  "showNoctaliaPerformance": "showNoctaliaaPerformance"
};

// Deep copy of a saved settings value with renamed widget ids and widget setting keys.
// Returns the same value when nothing needed renaming, so callers can skip writing it back.
function renameValue(value) {
  if (Array.isArray(value)) {
    var changed = false;
    var arr = value.map(function (v) {
      var r = renameValue(v);
      if (r !== v)
        changed = true;
      return r;
    });
    return changed ? arr : value;
  }
  if (value && typeof value === "object") {
    var out = {};
    var anyChanged = false;
    for (var key in value) {
      var newKey = renamedKeys.hasOwnProperty(key) ? renamedKeys[key] : key;
      var v = key === "id" && typeof value[key] === "string" && renamedIds.hasOwnProperty(value[key]) ? renamedIds[value[key]] : renameValue(value[key]);
      if (newKey !== key || v !== value[key])
        anyChanged = true;
      out[newKey] = v;
    }
    return anyChanged ? out : value;
  }
  return value;
}
