import QtQuick
import org.kde.plasma.plasma5support as Plasma5Support

Plasma5Support.DataSource {
    id: root
    engine: "executable"
    connectedSources: []

    property bool ready: false
    property bool listing: false
    property ListModel instances: ListModel{}
    // Ranges of `instances` sharing a cluster location, as { location, start, count }.
    // `instances` is sorted so that each location occupies one contiguous range.
    property var groups: []
    // More than one location means the cluster spreads the instances around.
    readonly property bool grouped: groups.length > 1

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
            const lines = data.stdout.split("\n").map(x => x.trim()).filter(x => x);
            const parsed = lines.map(line => {
                const fields = line.split(",");
                const name = fields[0];
                const running = fields[1] === "RUNNING";
                // standalone lxd reports the location as "none"
                const location = fields[4] && fields[4].toLowerCase() !== "none" ? fields[4] : "";
                return {
                    name: name,
                    updating: updateingInstances.includes(name),
                    running: running,
                    type: fields[2],
                    memory: running && fields[3] ? fields[3].replace(/(\d+)\.?\d*([KMG])ib$/i, '$1$2') : "",
                    location: location,
                };
            });
            parsed.sort((a, b) => a.location.localeCompare(b.location) || a.name.localeCompare(b.name));

            const newGroups = [];
            instances.clear();
            for (const inst of parsed) {
                let group = newGroups[newGroups.length - 1];
                if (!group || group.location !== inst.location) {
                    group = { location: inst.location, start: instances.count, count: 0 };
                    newGroups.push(group);
                }
                group.count += 1;
                instances.append(inst);
            }
            groups = newGroups;
            listing = false;
            ready = true;
        } else if (source.startsWith("lxc start ")) {
            const name = source.substring(10);
            for (let i=0; i<instances.count; i++) {
                if (instances.get(i).name === name) {
                    instances.setProperty(i, "running", true);
                    instances.setProperty(i, "updating", false);
                    // call list to query memory usage
                    lxd.list();
                    break;
                }
            }
        } else if (source.startsWith("lxc stop ")) {
            const name = source.substring(9);
            for (let i=0; i<instances.count; i++) {
                if (instances.get(i).name === name) {
                    instances.setProperty(i, "running", false);
                    instances.setProperty(i, "updating", false);
                    break;
                }
            }
        }
        disconnectSource(source);
    }
    function list() {
        if (listing) return;
        listing = true
        root.connectSource("lxc ls -c nstmL -f csv");
    }
    function start(name) {
        for (let i=0; i<instances.count; i++) {
            const inst = instances.get(i);
            if (inst.name === name) {
                if (inst.updating || inst.running) return;
                instances.setProperty(i, "updating", true);
                // optimistic
                instances.setProperty(i, "running", true);
                instances.setProperty(i, "memory", "");
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
                instances.setProperty(i, "memory", "");
                root.connectSource("lxc stop " + name);
                break;
            }
        }
    }
}
