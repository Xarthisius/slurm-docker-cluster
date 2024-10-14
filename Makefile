include .env

.DEFAULT_GOAL := all

build:
	docker build --build-arg SLURM_TAG=${SLURM_TAG} -t xarthisius/slurm-docker-cluster:${IMAGE_TAG} -f Dockerfile .
	docker build --build-arg IMAGE_TAG=${IMAGE_TAG} --build-arg XALT_VERSION=${XALT_VERSION} \
		-t xarthisius/slurm-xalt:$(IMAGE_TAG) -f Dockerfile.xalt .

all: build
	docker compose up -d
	@echo "Slurm cluster is up and running"
	@echo "Login as a user with 'docker exec -ti -u dummy slurmctld bash'"
	@echo "Check that --generate-tro is available with 'sbatch --help | grep generate-tro'"
	@echo "Submit a job with 'sbatch --generate-tro submit.slurm'"
	@echo "Check if TRO is generated after job finishes with 'ls'"

clean:
	docker compose down -v

# local development
update_plugin:
	docker exec -ti -u xarth slurmctld bash -c '. "$$HOME/.cargo/env" && cd ~/spank-tro && cargo build'
	docker exec -ti -u root slurmctld mv ~xarth/spank-tro/target/debug/libspank_tro.so /etc/slurm/plugins/ && docker compose restart

.PHONY: update_plugin build all clean
