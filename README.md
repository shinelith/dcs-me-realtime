# DCS-MissionEditor-Realtime 

### Sender Install

* copy `realtime_sender.lua` to `DCS\MissionEditor\modules\`
* insert the code into `DCS\MissionEditor\MissionEditor.lua`

```lua
-- Realtime Viewer Sender Client--------------------------------------------------
local realtime_sender = require("realtime_sender")
realtime_sender.hook(_G)
-- Realtime Viewer Sender Client -------------------------------------------------
```

### Viewer Install

* copy `realtime_viewer.lua` to `DCS\Scripts\`
* insert the code into `DCS\Scripts\MissionScripting.lua` after line 1

```lua
-- Realtime Viewer Client--------------------------------------------------
realtime_viewer = {port = 46587}
dofile('Scripts/realtime_viewer.lua')
-- Realtime Viewer Client--------------------------------------------------
```

