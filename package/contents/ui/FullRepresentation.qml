import QtQuick
import QtQuick.Layouts

import org.kde.kirigami 2.20 as Kirigami
import org.kde.plasma.core as PlasmaCore
import org.kde.plasma.extras 2.0 as PlasmaExtras
import org.kde.plasma.components 3.0 as PlasmaComponents3

Item {
    id: root
    property ListModel model
    property bool loading: false
    signal toggleInstance(string name, bool checked)

    PlasmaComponents3.BusyIndicator {
        visible: root.loading
        anchors.centerIn: parent
    }

    PlasmaComponents3.ScrollView {
        id: scrollView
        clip: true
        anchors.fill: parent
        anchors.margins: Kirigami.Units.gridUnit

        contentItem: GridView {
            id: grid
            model: root.model
            cellWidth: scrollView.availableWidth/2
            cellHeight: 32
            header: RowLayout {
                anchors.left: parent.left
                anchors.right: parent.right
                height: 32
                PlasmaComponents3.Label {
                    width: grid.cellWidth
                    font.weight: Font.DemiBold
                    text: i18n("LXD Instances")
                }
                PlasmaComponents3.Label {
                    visible: root.model.count > 1
                    width: grid.cellWidth
                    font.weight: Font.DemiBold
                    text: i18n("LXD Instances")
                }
            }
            delegate: Rectangle {
                width: grid.cellWidth
                height: grid.cellHeight
                color: index % 4 < 2 ? "#00000000" : Qt.hsla(PlasmaCore.Theme.highlightColor.hslHue, PlasmaCore.Theme.highlightColor.hslSaturation, PlasmaCore.Theme.highlightColor.hslLightness, 0.1)
                topLeftRadius: index % 2 == 0 ? 8 : 0
                bottomLeftRadius: index % 2 == 0 ? 8 : 0
                topRightRadius: index % 2 == 1 ? 8 : 0
                bottomRightRadius: index % 2 == 1 ? 8 : 0
                RowLayout {
                    width: grid.cellWidth
                    height: grid.cellHeight
                    Layout.leftMargin: 16
                    Layout.rightMargin: 16
                    spacing: 4
                    Item {
                        Layout.preferredWidth: 4
                        Layout.preferredHeight: 16
                    }
                    PlasmaComponents3.Label {
                        Layout.fillWidth: true
                        text: model.name
                    }
                    PlasmaComponents3.BusyIndicator {
                        Layout.preferredWidth: 16
                        Layout.preferredHeight: 16
                        visible: model.updating
                    }
                    Item {
                        Layout.preferredWidth: 16
                        Layout.preferredHeight: 16
                        visible: !model.updating
                    }
                    PlasmaComponents3.Switch {
                        checked: model.running
                        enabled: !root.listing && !model.updating
                        onClicked: root.toggleInstance(model.name, checked)
                    }
                    Item {
                        Layout.preferredWidth: 2
                        Layout.preferredHeight: 16
                    }
                }
            }
        }
    }
}
