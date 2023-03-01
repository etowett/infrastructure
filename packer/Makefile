TAG=$(shell git rev-parse --short=8 HEAD)

base:
	packer build base.json

pritunl:
	packer build pritunl.json
