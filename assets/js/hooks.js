
const Hooks = {

    ResetInputOnUpdate: {
        mounted() {
            this.handleEvent("reset_input_field", message => {
                this.el.value = "";
            });
        },
    },

    SessionStorage: {
        // cf https://fly.io/phoenix-files/saving-and-restoring-liveview-state/
        mounted() {
            this.handleEvent("session_store", this.store);
            this.handleEvent("session_load", this.load.bind(this));
            this.handleEvent("session_clear", this.clear);
        },
        store(obj) {
            sessionStorage.setItem(obj.key, JSON.stringify(obj.data));
        },
        load(obj) {
            let result = null;
            try {
                const stored = sessionStorage.getItem(obj.key);
                result = stored ? JSON.parse(stored) : null;
            } catch {
                console.warn("SessionStorage Read/Parse Error.");
            }
            this.pushEvent(obj.event, result);
        },
        clear(obj) {
            sessionStorage.removeItem(obj.key);
        }
    }

};

export default Hooks;
