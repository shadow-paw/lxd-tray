import QtQuick
import QtQuick.Layouts

import org.kde.kirigami 2.20 as Kirigami
import org.kde.plasma.components 3.0 as PlasmaComponents3

Item {
    id: root
    required property ListModel model
    required property var groups
    required property bool grouped
    required property bool loading
    required property bool showMemory
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
        anchors.bottomMargin: Kirigami.Units.smallSpacing
        // cells are always laid out to the viewport width, there is nothing to scroll sideways
        PlasmaComponents3.ScrollBar.horizontal.policy: PlasmaComponents3.ScrollBar.AlwaysOff
        readonly property int columns: scrollView.availableWidth >= Kirigami.Units.gridUnit * 16 ? 2 : 1
        readonly property real cellWidth: content.width / scrollView.columns
        readonly property int cellHeight: 32

        contentItem: Flickable {
            id: flickable
            contentWidth: flickable.width
            contentHeight: content.implicitHeight
            ColumnLayout {
                id: content
                width: flickable.width
                spacing: 0

                PlasmaComponents3.Label {
                    Layout.fillWidth: true
                    Layout.preferredHeight: scrollView.cellHeight
                    verticalAlignment: Text.AlignVCenter
                    opacity: 0.6
                    text: i18n("LXD Tray - Instances")
                }

                Repeater {
                    model: root.groups
                    delegate: ColumnLayout {
                        id: group
                        required property var modelData
                        required property int index
                        Layout.fillWidth: true
                        // separate the groups, without trailing space below the last one
                        Layout.topMargin: group.index > 0 ? Kirigami.Units.gridUnit : 0
                        spacing: 0

                        // only labelled when the instances live on several cluster members
                        ColumnLayout {
                            visible: root.grouped
                            Layout.fillWidth: true
                            Layout.bottomMargin: Kirigami.Units.smallSpacing
                            spacing: 0
                            PlasmaComponents3.Label {
                                Layout.leftMargin: Kirigami.Units.smallSpacing
                                text: group.modelData.location
                            }
                            Kirigami.Separator {
                                Layout.fillWidth: true
                            }
                        }

                        Grid {
                            Layout.fillWidth: true
                            columns: scrollView.columns

                            Repeater {
                                model: root.model
                                delegate: Rectangle {
                                    id: cell
                                    required property int index
                                    required property string name
                                    required property bool running
                                    required property bool updating
                                    required property string memory

                                    // position within the group, the positioner skips the rest
                                    readonly property int pos: index - group.modelData.start
                                    readonly property int column: pos % scrollView.columns
                                    readonly property bool striped: Math.floor(pos / scrollView.columns) % 2 === 1

                                    visible: pos >= 0 && pos < group.modelData.count
                                    width: scrollView.cellWidth
                                    height: scrollView.cellHeight
                                    color: cell.striped ? Qt.rgba(Kirigami.Theme.highlightColor.r, Kirigami.Theme.highlightColor.g, Kirigami.Theme.highlightColor.b, 0.1) : "transparent"
                                    topLeftRadius: cell.column === 0 ? 8 : 0
                                    bottomLeftRadius: cell.column === 0 ? 8 : 0
                                    topRightRadius: cell.column === scrollView.columns - 1 ? 8 : 0
                                    bottomRightRadius: cell.column === scrollView.columns - 1 ? 8 : 0
                                    RowLayout {
                                        anchors.fill: parent
                                        spacing: 4
                                        Item {
                                            Layout.preferredWidth: 4
                                            Layout.preferredHeight: 16
                                        }
                                        PlasmaComponents3.Label {
                                            Layout.fillWidth: true
                                            text: cell.name
                                        }
                                        PlasmaComponents3.Label {
                                            visible: root.showMemory && cell.running
                                            font.pixelSize: 9
                                            text: cell.memory
                                        }
                                        PlasmaComponents3.BusyIndicator {
                                            Layout.preferredWidth: 16
                                            Layout.preferredHeight: 16
                                            visible: cell.updating
                                        }
                                        PlasmaComponents3.Switch {
                                            checked: cell.running
                                            enabled: !cell.updating
                                            onClicked: root.toggleInstance(cell.name, checked)
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
                }
            }
        }
    }
}
