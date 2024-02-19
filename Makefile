# all the project/device specific config is done in init_project.tcl

VIVADO_EXEC := /opt/Xilinx/Vivado/2023.2/bin/vivado

build/:
	@if [ -d build/ ]; then \
        echo "Build directory already exists! Exiting."; \
	else \
		mkdir build; \
		echo "Initializing the project..."
		${VIVADO_EXEC} -mode batch -journal build/init.jou -log build/init.log -source scripts/init_project.tcl && \
			echo "Project initialized successfully!"; \
    fi
init: build/

# TODO: this looks like modern tcl:
# https://projectf.io/posts/vivado-tcl-build-script/
# but it's doing everything in memory and we want to save artifacts

synth: build/
	${VIVADO_EXEC} -mode batch -journal build/synth.jou -log build/synth.log -source scripts/synth.tcl

bit:
	${VIVADO_EXEC} -mode batch -journal build/impl.jou -log build/impl.log -source scripts/impl.tcl

clean:
	rm -rf build .Xil

.PHONY: init synth bit clean
