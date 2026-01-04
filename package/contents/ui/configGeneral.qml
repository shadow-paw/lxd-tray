import QtQuick 2.15
import QtQuick.Controls 2.5 as QQC2

import org.kde.kirigami 2.20 as Kirigami
import org.kde.kcmutils as KCM

KCM.SimpleKCM {
    id: page
    property alias cfg_showMemory: showMemory.checked
    property bool cfg_showMemoryDefault: true

    Kirigami.FormLayout {
        QQC2.CheckBox {
            id: showMemory
            Kirigami.FormData.label: i18n("Instance List:")
            text: i18n("Show memory usage")
        }
    }
}
