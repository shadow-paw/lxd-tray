import QtQuick
import QtQuick.Layouts

import org.kde.kirigami 2.20 as Kirigami
import org.kde.plasma.core as PlasmaCore
import org.kde.plasma.components 3.0 as PlasmaComponents3
import org.kde.plasma.plasmoid 2.0

PlasmoidItem {
    id: root
    width: Kirigami.Units.gridUnit * 25
    height: Kirigami.Units.gridUnit * 25
    Layout.minimumWidth: (inPanel && !compactInPanel) ? -1 : width
    Layout.minimumHeight: (inPanel && !compactInPanel) ? -1 : height
    readonly property bool inPanel: [PlasmaCore.Types.TopEdge, PlasmaCore.Types.RightEdge, PlasmaCore.Types.BottomEdge, PlasmaCore.Types.LeftEdge].includes(Plasmoid.location)
    readonly property bool compactInPanel: inPanel && !!compactRepresentationItem?.visible

    Plasmoid.icon: "computer-symbolic"
    Plasmoid.backgroundHints: PlasmaCore.Types.NoBackground

    fullRepresentation: PlasmaComponents3.ScrollView {
        id: scrollView
        clip: true
        contentItem: ListView {
            model: 100
            delegate: PlasmaComponents3.Switch {
                text: i18n("CheckBox #%1", index+1)
                onClicked: console.log(i18n("Clicked #%1: %2", index+1, checked))
            }
        }
    }
}
