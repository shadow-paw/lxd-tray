import QtQuick

Item {
    id: root
    property bool expanded
    signal triggered()

    Timer {
        id: timer
        interval: 1000
        repeat: true
        property bool needRefresh: true

        onTriggered: {
            if (root.expanded) {
                if (needRefresh) {
                    needRefresh = false;
                    root.triggered();
                }
            } else {
                if (!needRefresh) {
                    needRefresh = true;
                }
            }
        }
    }
    Component.onCompleted: {
        timer.restart();
    }
}
