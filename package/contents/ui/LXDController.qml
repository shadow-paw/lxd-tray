import QtQuick
import org.kde.plasma.plasma5support as Plasma5Support

Plasma5Support.DataSource {
    id: root
    engine: "executable"
    connectedSources: []

    property bool ready: false
    property bool listing: false
    property ListModel instances: ListModel{}

    onNewData: function(source, data) {
        if (source.startsWith("lxc ls ")) {
            // preserve states
            const updateingInstances = []
            for (let i=0; i<instances.count; i++) {
                const inst = instances.get(i);
                if (inst.updating) {
                    updateingInstances.push(inst.name);
                }
            }
            instances.clear();
            const lines = data.stdout.split("\n").map(x => x.trim()).filter(x => x);
            for (const line of lines) {
                const fields = line.split(",");
                const name = fields[0];
                const updating = updateingInstances.includes(name);
                const running = fields[1] === "RUNNING";
                instances.append({
                    name: name,
                    updating: updating,
                    running: running,
                    type: fields[2],
                    memory: fields[3],
                });
            }
            listing = false;
            ready = true;
        } else if (source.startsWith("lxc start ")) {
            const name = source.substring(10);
            for (let i=0; i<instances.count; i++) {
                if (instances.get(i).name === name) {
                    instances.setProperty(i, "running", true);
                    instances.setProperty(i, "updating", false);
                }
            }
        } else if (source.startsWith("lxc stop ")) {
            const name = source.substring(9);
            for (let i=0; i<instances.count; i++) {
                if (instances.get(i).name === name) {
                    instances.setProperty(i, "running", false);
                    instances.setProperty(i, "updating", false);
                }
            }
        }
        disconnectSource(source);
    }
    function list() {
        if (listing) return;
        listing = true
        root.connectSource("lxc ls -c nstm -f csv");
    }
    function start(name) {
        for (let i=0; i<instances.count; i++) {
            const inst = instances.get(i);
            if (inst.name === name) {
                if (inst.updating || inst.running) return;
                instances.setProperty(i, "updating", true);
                // optimistic
                instances.setProperty(i, "running", true);
                root.connectSource("lxc start " + name);
                break;
            }
        }
    }
    function stop(name) {
        for (let i=0; i<instances.count; i++) {
            const inst = instances.get(i);
            if (inst.name === name) {
                if (inst.updating || !inst.running) return;
                instances.setProperty(i, "updating", true);
                // optimistic
                instances.setProperty(i, "running", false);
                root.connectSource("lxc stop " + name);
                break;
            }
        }
    }
}
