
const Hooks = {

    ResetInputOnUpdate: {
        mounted() {
            this.handleEvent("reset_input_field", message => {
                this.el.value = "";
            });
        },
    }

};

export default Hooks;
