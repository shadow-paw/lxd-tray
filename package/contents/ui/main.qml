import QtQuick
import QtQuick.Layouts

import org.kde.kirigami 2.20 as Kirigami
import org.kde.plasma.core as PlasmaCore
import org.kde.plasma.plasmoid 2.0

PlasmoidItem {
    id: root
    Plasmoid.icon: "computer-symbolic"
    Plasmoid.backgroundHints: PlasmaCore.Types.NoBackground

    fullRepresentation: FullRepresentation {
        Layout.minimumWidth: Kirigami.Units.gridUnit * 12
        Layout.minimumHeight: Kirigami.Units.gridUnit * 8
        model: lxd.instances
        loading: !lxd.ready
        showMemory: plasmoid.configuration.showMemory
        onToggleInstance: (name, checked) => checked ? lxd.start(name) : lxd.stop(name)
    }

    LXDController {
        id: lxd
    }

    // refresh upon main UI shown
    Timer {
        interval: 1
        repeat: false
        running: root.expanded
        onTriggered: lxd.list()
    }
}
