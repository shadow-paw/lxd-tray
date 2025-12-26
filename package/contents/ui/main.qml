import QtQuick
import QtQuick.Layouts

import org.kde.kirigami 2.20 as Kirigami
import org.kde.plasma.core as PlasmaCore
import org.kde.plasma.plasmoid 2.0

PlasmoidItem {
    id: root

    switchWidth: Kirigami.Units.gridUnit * 5
    switchHeight: Kirigami.Units.gridUnit * 5
    Layout.minimumWidth: (inPanel && !compactInPanel) ? -1 : Kirigami.Units.gridUnit * 16
    Layout.minimumHeight: (inPanel && !compactInPanel) ? -1 : Kirigami.Units.gridUnit * 16

    readonly property real horizontalMargins: width * 0.07
    readonly property real verticalMargins: height * 0.07
    readonly property bool inPanel: [PlasmaCore.Types.TopEdge, PlasmaCore.Types.RightEdge, PlasmaCore.Types.BottomEdge, PlasmaCore.Types.LeftEdge].includes(Plasmoid.location)
    readonly property bool compactInPanel: inPanel && !!compactRepresentationItem?.visible

    Plasmoid.icon: "computer-symbolic"
    Plasmoid.backgroundHints: PlasmaCore.Types.NoBackground

    fullRepresentation: FullRepresentation {
        model: lxd.instances
        loading: !lxd.ready
        onToggleInstance: (name, checked) => checked ? lxd.start(name) : lxd.stop(name)
    }

    LXDController {
        id: lxd
    }

    RefreshTimer {
        expanded: root.expanded
        onTriggered: lxd.list()
    }
}
